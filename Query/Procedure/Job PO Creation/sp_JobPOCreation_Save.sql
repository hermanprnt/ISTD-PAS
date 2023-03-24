
/****** Object:  StoredProcedure [dbo].[sp_JobPOCreation_Save]    Script Date: 12/23/2015 11:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_JobPOCreation_Save]
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6)
AS
BEGIN
    DECLARE
		@refPONo VARCHAR(11),
		@poNo VARCHAR(11),
		@poDesc VARCHAR(100),
		@procChannelPrefix VARCHAR(50),
		@currency VARCHAR(3),
		@released VARCHAR(1),

		@SYSTEM_SOURCE VARCHAR(11),
		@user VARCHAR(20) = 'SYSTEM',
		@functionIdPOCreation VARCHAR(6) = '301001',
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = 'Save PO',
        @tmpLog LOG_TEMP
        
    SET NOCOUNT ON

	BEGIN TRY
		EXEC dbo.sp_PutLog 'PO Saving Process Started', @user, @actionName, @processId, 'INF', 'INF', @moduleId, @functionId, 1

		BEGIN TRAN SaveData
		BEGIN TRY
			SELECT @refPONo = REF_PO_NO, @released = RELEASED_FLAG, @poDesc = REF_PO_DESC, @SYSTEM_SOURCE = SYSTEM_SOURCE FROM TB_T_INPUT_PO_H WHERE PROCESS_ID = @processId
		
			SET @message = 'Save Process for Ref. PO No: ' + @refPONo + ' Started'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)

			-- 2. Generate PO No
			SELECT @procChannelPrefix = PO_PREFIX FROM TB_M_PROCUREMENT_CHANNEL -- dapet dari mana prefixnya
			IF @procChannelPrefix IS NULL BEGIN RAISERROR('Bug - Procurement Channel is not well configured', 16, 1) END

			SET @message = 'Generate PO No Started'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)

			SELECT @poNo = dbo.GenerateAutoNumber(@functionIdPOCreation, @procChannelPrefix)
	        
			SET @message = 'Generated PO No: ' + @poNo
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)
	        
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'Generate PO No Finished', @moduleId, @actionName, @functionId, 1, @user)
			
			-- 7. Reserve PONo
			DECLARE @poNoCounter INT = (SELECT CAST(SYSTEM_VALUE AS INT) + 1 FROM TB_M_SYSTEM WHERE FUNCTION_ID = REPLACE(@functionIdPOCreation, '.', '') AND SYSTEM_CD = @procChannelPrefix)
			UPDATE TB_M_SYSTEM SET SYSTEM_VALUE = @poNoCounter WHERE FUNCTION_ID = REPLACE(@functionIdPOCreation, '.', '') AND SYSTEM_CD = @procChannelPrefix
			
			-- 3. Save PO Header
			SET @message = 'Save data into TB_R_PO_H for PO_NO ' + @poNo + ' where REF_PO_NO: ' + @refPONo + ' Started'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)

			INSERT INTO [dbo].[TB_R_PO_H]
						([PO_NO]
						,[PO_DESC]
						,[VENDOR_CD]
						,[VENDOR_NAME]
						,[DOC_DT]
						,[PROC_MONTH]
						,[PAYMENT_METHOD_CD]
						,[PAYMENT_TERM_CD]
						,[DOC_TYPE]
						,[DOC_CATEGORY]
						,[PURCHASING_GRP_CD]
						,[INV_WO_GR_FLAG]
						,[PO_CURR]
						,[PO_AMOUNT]
						,[PO_EXCHANGE_RATE]
						,[LOCAL_CURR]
						,[PO_STATUS]
						,[RELEASED_FLAG]
						,[RELEASED_DT]
						,[DELETION_FLAG]
						,[PROCESS_ID]
						,[CREATED_BY]
						,[CREATED_DT]
						,[CHANGED_BY]
						,[CHANGED_DT]
						,[URGENT_DOC]
						,[DRAFT_FLAG]
						,[DELIVERY_ADDR]
						,[SYSTEM_SOURCE])
				 SELECT @poNo
						,A.[REF_PO_DESC]
						,A.[VENDOR_CD]
						,CASE WHEN((ISNULL(A.[VENDOR_NAME], '') <> '') AND (ISNULL(A.[VENDOR_CD], '') <> '')) 
							  THEN A.[VENDOR_NAME] 
							  ELSE 
								(CASE WHEN (ISNULL(B.[VENDOR_NAME], '') = '') THEN '-' ELSE B.[VENDOR_NAME] END)
							  END
						,A.[DOC_DT]
						,A.[PROC_MONTH]
						,A.[PAYMENT_METHOD_CD]
						,A.[PAYMENT_TERM_CD]
						,A.[DOC_TYPE]
						,A.[DOC_CATEGORY]
						,A.[PURCHASING_GRP_CD]
						,A.[INV_WO_GR_FLAG]
						,A.[PO_CURR]
						,A.[PO_AMOUNT]
						,A.[PO_EXCHANGE_RATE]
						,A.[LOCAL_CURR]
						,CASE WHEN(A.[RELEASED_FLAG] = 'Y') THEN '43' ELSE '40' END
						,A.[RELEASED_FLAG]
						,A.[RELEASED_DT]
						,'N'
						,NULL
						,A.[CREATED_BY]
						,A.[CREATED_DT]
						,A.[CHANGED_BY]
						,A.[CHANGED_DT]
						,A.[URGENT_DOC]
						,'0'
						,A.[DELIVERY_ADDR]
						,A.[SYSTEM_SOURCE]
				FROM TB_T_INPUT_PO_H A
					LEFT JOIN TB_M_VENDOR B ON A.VENDOR_CD = B.VENDOR_CD
				WHERE PROCESS_ID = @processId

			SET @message = 'Save data into TB_R_PO_H for PO_NO ' + @poNo + ' where REF_PO_NO: ' + @refPONo + ' Finished'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)

			-- 4. Save PO Item
			SET @message = 'Save data into TB_R_PO_ITEM where PO_NO: ' + @poNo + ' Started'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)

			INSERT INTO [dbo].[TB_R_PO_ITEM]
						([PO_NO]
						,[PO_ITEM_NO]
						,[PR_NO]
						,[PR_ITEM_NO]
						,[MAT_NO]
						,[MAT_DESC]
						,[VALUATION_CLASS]
						,[VALUATION_CLASS_DESC]
						,[PROCUREMENT_PURPOSE]
						,[DELIVERY_PLAN_DT]
						,[SOURCE_TYPE]
						,[PLANT_CD]
						,[SLOC_CD]
						,[WBS_NO]
						,[COST_CENTER_CD]
						,[UNLIMITED_FLAG]
						,[TOLERANCE_PERCENTAGE]
						,[SPECIAL_PROCUREMENT_TYPE]
						,[PO_QTY_ORI]
						,[PO_QTY_USED]
						,[PO_QTY_REMAIN]
						,[UOM]
						,[PRICE_PER_UOM]
						,[ORI_AMOUNT]
						,[LOCAL_AMOUNT]
						,[PO_STATUS]
						,[PO_NEXT_STATUS]
						,[IS_REJECTED]
						,[CREATED_BY]
						,[CREATED_DT]
						,[CHANGED_BY]
						,[CHANGED_DT]
						,[WBS_NAME]
						,[RELEASE_FLAG]
						,[IS_PARENT]
						,[ITEM_CLASS]
						,[GROSS_PERCENT])
				 SELECT @poNo
						,A.[REF_PO_ITEM]
						,A.[PR_NO]
						,A.[PR_ITEM_NO]
						,A.[MAT_NO]
						,A.[MAT_DESC]
						,A.[VALUATION_CLASS]
						,B.[VALUATION_CLASS_DESC]
						,A.[PROCUREMENT_PURPOSE]
						,A.[DELIVERY_PLAN_DT]
						,A.[SOURCE_TYPE]
						,A.[PLANT_CD]
						,A.[SLOC_CD]
						,A.[WBS_NO]
						,A.[COST_CENTER_CD]
						,A.[UNLIMITED_FLAG]
						,A.[TOLERANCE_PERCENTAGE]
						,A.[SPECIAL_PROCUREMENT_TYPE]
						,A.[PO_QTY_ORI]
						,A.[PO_QTY_USED]
						,A.[PO_QTY_REMAIN]
						,A.[UOM]
						,A.[PRICE_PER_UOM]
						,A.[ORI_AMOUNT]
						,A.[LOCAL_AMOUNT]
						,CASE WHEN (@released = 'Y') THEN '43' ELSE '40' END
						,CASE WHEN (@released = 'Y') THEN '43' ELSE '41' END
						,'N'
						,A.[CREATED_BY]
						,A.[CREATED_DT]
						,A.[CHANGED_BY]
						,A.[CHANGED_DT]
						,C.[WBS_NAME]
						,'N'
						,A.[IS_PARENT]
						,A.[ITEM_CLASS]
						,A.[GROSS_PERCENT]
				 FROM TB_T_INPUT_PO_ITEM A 
					LEFT JOIN TB_M_VALUATION_CLASS B ON A.VALUATION_CLASS = B.VALUATION_CLASS
					LEFT JOIN TB_R_WBS C ON A.WBS_NO = C.WBS_NO 
					WHERE A.REF_PO_NO = @refPONo ORDER BY A.REF_PO_ITEM ASC
				 
			SET @message = 'Save data into TB_R_PO_ITEM where PO_NO: ' + @poNo + ' Finished'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)

			-- 5. Save PO Subitem
			SET @message = 'Save data into TB_R_PO_SUBITEM where PO_NO: ' + @poNo + ' Started'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)

			INSERT INTO [dbo].[TB_R_PO_SUBITEM]
						([PO_NO]
						,[PO_ITEM_NO]
						,[PO_SUBITEM_NO]
						,[MAT_NO]
						,[MAT_DESC]
						,[WBS_NO]
						,[WBS_NAME]
						,[COST_CENTER_CD]
						,[PO_QTY_ORI]
						,[PO_QTY_USED]
						,[PO_QTY_REMAIN]
						,[UOM]
						,[PRICE_PER_UOM]
						,[ORI_AMOUNT]
						,[LOCAL_AMOUNT]
						,[CREATED_BY]
						,[CREATED_DT]
						,[CHANGED_BY]
						,[CHANGED_DT])
				 SELECT @poNo
						,A.[REF_PO_ITEM]
						,A.[REF_PO_SUBITEM]
						,A.[MAT_NO]
						,A.[MAT_DESC]
						,A.[WBS_NO]
						,CASE WHEN((ISNULL(B.[WBS_NAME], '') <> '') AND (ISNULL(A.[WBS_NO], '') <> '')) THEN B.[WBS_NAME] ELSE '-' END
						,A.[COST_CENTER_CD]
						,A.[PO_QTY_ORI]
						,A.[PO_QTY_USED]
						,A.[PO_QTY_REMAIN]
						,A.[UOM]
						,A.[PRICE_PER_UOM]
						,A.[ORI_AMOUNT]
						,A.[LOCAL_AMOUNT]
						,A.[CREATED_BY]
						,A.[CREATED_DT]
						,A.[CHANGED_BY]
						,A.[CHANGED_DT]
				 FROM TB_T_INPUT_PO_SUBITEM A LEFT JOIN TB_R_WBS B ON A.WBS_NO = B.WBS_NO
				 WHERE A.REF_PO_NO = @poNo ORDER BY A.REF_PO_SUBITEM ASC 

			SET @message = 'Save data into TB_R_PO_SUBITEM where PO_NO: ' + @poNo + ' Finished'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)

			-- 6. Save PO Condition
			SET @message = 'Save data into TB_R_PO_CONDITION where PO_NO: ' + @poNo + ' Started'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)

			INSERT INTO [dbo].[TB_R_PO_CONDITION]
						([PO_NO]
						,[PO_ITEM_NO]
						,[COMP_PRICE_CD]
						,[COMP_PRICE_RATE]
						,[INVOICE_FLAG]
						,[EXCHANGE_RATE]
						,[SEQ_NO]
						,[BASE_VALUE_FROM]
						,[BASE_VALUE_TO]
						,[PO_CURR]
						,[INVENTORY_FLAG]
						,[CALCULATION_TYPE]
						,[PLUS_MINUS_FLAG]
						,[CONDITION_CATEGORY]
						,[ACCRUAL_FLAG_TYPE]
						,[CONDITION_RULE]
						,[QTY]
						,[QTY_PER_UOM]
						,[PRICE_AMT]
						,[COMP_TYPE]
						,[PRINT_STATUS]
						,[CREATED_BY]
						,[CREATED_DT]
						,[CHANGED_BY]
						,[CHANGED_DT])
				 SELECT @poNo
						,[REF_PO_ITEM]
						,[COMP_PRICE_CD]
						,[COMP_PRICE_RATE]
						,[INVOICE_FLAG]
						,[EXCHANGE_RATE]
						,[SEQ_NO]
						,[BASE_VALUE_FROM]
						,[BASE_VALUE_TO]
						,[PO_CURR]
						,[INVENTORY_FLAG]
						,[CALCULATION_TYPE]
						,[PLUS_MINUS_FLAG]
						,[CONDITION_CATEGORY]
						,[ACCRUAL_FLAG_TYPE]
						,[CONDITION_RULE]
						,[QTY]
						,[QTY_PER_UOM]
						,[PRICE_AMT]
						,[COMP_TYPE]
						,[PRINT_STATUS]
						,[CREATED_BY]
						,[CREATED_DT]
						,[CHANGED_BY]
						,[CHANGED_DT]
				 FROM TB_T_INPUT_PO_CONDITION WHERE REF_PO_NO = @refPONo ORDER BY REF_PO_ITEM ASC

			SET @message = 'Save data into TB_R_PO_CONDITION where PO_NO: ' + @poNo + ' Finished'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)
			
			-- 7. Reserve PONo
			SELECT @poNoCounter = CAST(SYSTEM_VALUE AS INT) + 1 FROM TB_M_SYSTEM WHERE FUNCTION_ID = REPLACE(@functionId, '.', '') AND SYSTEM_CD = @procChannelPrefix
			UPDATE TB_M_SYSTEM SET SYSTEM_VALUE = @poNoCounter WHERE FUNCTION_ID = REPLACE(@functionId, '.', '') AND SYSTEM_CD = @procChannelPrefix
			
			-- 5. Set Worklist
			IF(@released = 'N')
			BEGIN
				DECLARE @currentUser VARCHAR(20),
						@divisionId INT,
						@currentUserNoReg VARCHAR(8)
				
				SELECT @currentUser = CREATED_BY FROM TB_T_INPUT_PO_H WHERE PROCESS_ID = @processId
	        
				SET @message = 'Insert data to TB_M_WORKFLOW where PO_NO: ' + @poNo + ' begin'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)
		        
				--INSERT INTO @tmpLog
				--EXEC sp_pocreation_createWorklist @poNo, @processId, @currentUser, @divisionId, @currentUserNoReg, N, @message
		        
				SET @message = 'Insert data to TB_M_WORKFLOW where PO_NO: ' + @poNo + ' end'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)            
			END
			
			-- 8. Commit Budget
			-- NOTE: budget always called using reserved Document No
			DECLARE
				@wbsIdx INT = 0,
				@poItemGroupedByWBSCount INT,
				@oldPONo VARCHAR(15) = NULL,
				@totalAmount DECIMAL(18, 2),
				@materialNo VARCHAR(30) = '',
				@wbsNo VARCHAR(30),
				@bmsOperation VARCHAR(20) = 'REV_COMMIT', -- NOTE: PO always REV_COMMIT or CANCEL_COMMIT (when Cancel PO). NEW_COMMIT is in PR.
				@bmsResponse VARCHAR(20),
				@bmsResponseMessage VARCHAR(8000),
				@bmsRetryCounter INT = 0
	                
			DECLARE @budgetCheck TABLE ( DATA_NO INT, WBS_NO VARCHAR(30), PR_NO VARCHAR(30), LOCAL_AMOUNT DECIMAL(18,6) )
			INSERT INTO @budgetCheck SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) DATA_NO, WBS_NO, PR_NO, SUM(LOCAL_AMOUNT) FROM TB_T_INPUT_PO_ITEM WHERE REF_PO_NO = @refPONo GROUP BY WBS_NO, PR_NO
			SET @poItemGroupedByWBSCount = (SELECT COUNT(0) FROM @budgetCheck)
	            
			SELECT @currency = PO_CURR FROM TB_T_INPUT_PO_H WHERE PROCESS_ID = @processId
	            
			DECLARE @exactPONoCd VARCHAR(15)
	            
			/*WHILE (@wbsIdx < @poItemGroupedByWBSCount)
			BEGIN
				SELECT @wbsNo = WBS_NO, @totalAmount = LOCAL_AMOUNT FROM @budgetCheck WHERE DATA_NO = @wbsIdx+1
				IF @poNo = '' 
				BEGIN 
					SET @oldPONo = (SELECT TOP 1 PR_NO FROM TB_T_INPUT_PO_ITEM WHERE REF_PO_NO = @poNo AND WBS_NO = @wbsNo) + '_001' 
				END
	                
				SET @exactPONoCd = @poNo + '_001'
				SET @message = 'I|Budget commit on WBS No: ' + @wbsNo + ' in the amount of: ' + CAST(@totalAmount AS VARCHAR) + ' with New Doc No ' + ISNULL(@exactPONoCd, '') + ' and Ref Doc No' + ISNULL(@oldPONo, '') + ' : begin'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)
	                
				EXEC @bmsResponse =
					[10.16.20.231].[NEW_BMS_DB].dbo.[sp_BudgetControl]
						@bmsResponseMessage OUTPUT, @user, @bmsOperation, @wbsNo, @oldPONo, @poNo,
						@currency, @totalAmount, @materialNo, @poDesc
	                        
				-- NOTE: bmsResponse always 0 or 1 String which means Success or Failed respectively
				WHILE (@bmsResponse = '1' AND @bmsRetryCounter < 3)
				BEGIN
					-- NOTE: if Failed retry in 1 sec and log
					SET @message = 'I|Budget commit Failed on WBS No: ' + @wbsNo + ' in the amount of: ' + CAST(@totalAmount AS VARCHAR) + ' with New Doc No ' + ISNULL(@exactPONoCd, '') + ' and Ref Doc No' + ISNULL(@oldPONo, '') + ' : end'
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)
	                    
					WAITFOR DELAY '00:00:01' 
					EXEC @bmsResponse =
						[10.16.20.231].[NEW_BMS_DB].dbo.[sp_BudgetControl]
							@bmsResponseMessage OUTPUT, @user, @bmsOperation, @wbsNo, @oldPONo, @poNo,
							@currency, @totalAmount, @materialNo, @poDesc
	                        
					SET @bmsRetryCounter = @bmsRetryCounter + 1
				END
	                
				IF @bmsResponse = '1' BEGIN RAISERROR(@bmsResponseMessage, 16, 1) END
	              
				/*
				-- For debugging purposes
				SELECT @bmsOperation CommitOperation, CASE @bmsResponse WHEN '0' THEN 'Success' WHEN '1' THEN 'Failed' END CommitResult, @bmsResponseMessage CommitMessage
				EXEC sp_Util_BudgetMonitor @wbsNo
				*/
	                
				SET @message = 'I|Budget commit on WBS No: ' + @wbsNo + ' in the amount of: ' + CAST(@totalAmount AS VARCHAR) + ' with New Doc No ' + ISNULL(@exactPONoCd, '') + ' and Ref Doc No' + ISNULL(@oldPONo, '') + ' : end'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)
	               
				SET @wbsIdx = @wbsIdx + 1
			END*/
			
			COMMIT TRAN SaveData
	        
			SET @message = 'Save Process for Ref. PO No: ' + @refPONo + ' Finished'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @user)
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN SaveData
			SELECT ERROR_MESSAGE()
			SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @user)
		END CATCH
		
		-- 9. Save PO OUTPUT
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'Save data into TB_T_OUTPUT_PO with REF_PO_NO: ' + @refPONo + ' Started', @moduleId, @actionName, @functionId, 1, @user)
		
		DECLARE @status VARCHAR(1)
		SELECT @status = CASE WHEN(SUBSTRING(@message, 1, 2) = 'E|') THEN 'E' ELSE 'S' END
		
		INSERT INTO TB_T_OUTPUT_PO
					([SYSTEM_SOURCE]
					,[REF_PO_NO]
					,[REF_PO_DESC]
					,[PROCESS_STATUS]
					,[RETURN_MESSAGE]
					,[PROCESS_ID]
					,[CREATED_BY]
					,[CREATED_DT]
					,[CHANGED_BY]
					,[CHANGED_DT])
			 SELECT @SYSTEM_SOURCE
					,@refPONo
					,@poDesc
					,@status
					,@message
					,@processId
					,'SYSTEM'
					,GETDATE()
					,null
					,null
					
		UPDATE TB_R_SYNCH_PO SET FINISHED_TIME = GETDATE(), PROCESS_STATUS = (CASE WHEN @status = 'S' THEN '2' ELSE '3' END), PROCESS_ID = NULL WHERE SYSTEM_SOURCE = @SYSTEM_SOURCE AND REF_PO_NO = @refPONo
		
		SET @message = 'Save data into TB_T_OUTPUT_PO with REF_PO_NO: ' + @refPONo + ' Finished'
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)

		UPDATE TB_T_INPUT_PO_H SET PROCESS_ID = NULL WHERE PROCESS_ID = @processId

		SET @message = 'PO Saving Process Finished'
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 2, @user)

		EXEC sp_putLog_Temp @tmpLog
    END TRY
    BEGIN CATCH
		SELECT ERROR_MESSAGE()
    END CATCH
    SET NOCOUNT OFF
END