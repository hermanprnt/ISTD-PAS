USE [PAS_DB_QA]
GO
/****** Object:  StoredProcedure [dbo].[sp_POCreation_Save_ECatalog]    Script Date: 11/23/2017 2:02:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_POCreation_Save_ECatalog]
	@PONO VARCHAR(11),
    @currentUser VARCHAR(50),
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6),
	@purchasing_grp VARCHAR(5),
	@exchangeRate DECIMAL(7,2),
	@tmpLog2 LOG_TEMP READONLY,
	@isSPKCreated BIT,
	@message VARCHAR(MAX) OUTPUT,
	@Status VARCHAR(20) OUTPUT,
	@isDraft BIT = 0,
	@clonePONO VARCHAR(11) = NULL,
	@regno VARCHAR(30) = ''
AS
BEGIN
	--DELETE FROM TB_R_LOG_H WHERE PROCESS_ID = @processId
	--DELETE FROM TB_R_LOG_D WHERE PROCESS_ID = @processId
    DECLARE
        @actionName VARCHAR(50) = 'sp_POCreation_Save_ECatalog',
		@MSG_ID VARCHAR(12),
        @tmpLog LOG_TEMP 

	--INSERT INTO @tmpLog ([PROCESS_ID], [PROCESS_TIME], [MESSAGE_ID], [MESSAGE_TYPE], [MESSAGE_DESC], [MODULE_ID], [MODULE_DESC], [FUNCTION_ID], [STATUS_ID], [USER_NAME])
	--SELECT [PROCESS_ID], [PROCESS_TIME], [MESSAGE_ID], [MESSAGE_TYPE], [MESSAGE_DESC], [MODULE_ID], [MODULE_DESC], [FUNCTION_ID], [STATUS_ID], [USER_NAME] FROM @tmpLog2

    DECLARE @process_level AS TABLE (level_id INT)
    INSERT INTO @process_level VALUES(0)

        /*
            0    => Initial
            1    => Insert PO Header
            2    => Insert PO SPK
            3    => Insert PO Item
            4    => Insert PO Sub-item
            5    => Insert PO Condition
            6    =>
        */

    SET NOCOUNT ON
    BEGIN TRY
		SET @message = 'Initial Create PO Data'
		SET @MSG_ID = 'MSG0000001'
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 0, @currentUser)

        --BEGIN TRAN

        -- Initial
        SELECT @PONO = CASE WHEN @PONO IS NULL THEN '' ELSE @PONO END

        DECLARE @budgetTransactTemp TABLE
        (
            DataNo INT IDENTITY(1, 1), WBSNo VARCHAR(30), RefDocNo VARCHAR(15),
            NewDocNo VARCHAR(15), Currency VARCHAR(3), TotalAmount DECIMAL(18, 6),
            MaterialNo VARCHAR(30), DocDesc VARCHAR(MAX), BmsOperation VARCHAR(50)
        )

        DECLARE @procMonth VARCHAR(1000) = (SELECT SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'PROC_MONTH')
		SET @message = 'Generate PO Data: begin'
		SET @MSG_ID = 'MSG0000002'
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        DECLARE
            @poHeaderStatusCode VARCHAR(5) = CASE WHEN @isDraft = 0 THEN '44' ELSE '47' END, -- '47' /* Draft */ ELSE '40' /* Created */ '44' /* Release */
            @poHeaderNextStatusCode VARCHAR(5) = CASE WHEN @isDraft = 0 THEN '44' ELSE '47' END, --'40' /* Draft */ ELSE '41' /* Created */ '44' /* Release */
			@poReleaseFlag VARCHAR(1) = 'Y'

        DECLARE
            @procChannelPrefix VARCHAR(4),
            @procChannel VARCHAR(4),
			@currency VARCHAR(3),
			@LOCAL_CURRENCY VARCHAR(3),
			@poDesc VARCHAR(MAX), 
			@VENDOR_CD VARCHAR(6),
			@PAYMENT_METHOD_CD VARCHAR(1), 
			@PAYMENT_TERM VARCHAR(4),
			@divisionId int,
			@divisionName VARCHAR(50),
			@departmentId VARCHAR(50),
			@sectionId VARCHAR(50),
            @orgId VARCHAR(50),
            @orgTitle VARCHAR(100),
			@directorateId VARCHAR(50),
			@positionLevel VARCHAR(100),
			@generate_po_workflow VARCHAR(1) = 'N',
			@currentUserNoReg VARCHAR(8) = '00000000' --Dummy for Auto Create PO

		if(ISNULL(@regno,'') <>'')
			SET @currentUserNoReg = @regno


		IF ISNULL(@LOCAL_CURRENCY, '') = '' BEGIN SELECT @LOCAL_CURRENCY = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'LOCAL_CURR_CD' END
		SELECT @procChannel = PROC_CHANNEL_CD, @currency = NEW_CURR_CD, @poDesc = PO_DESC, @VENDOR_CD = VENDOR_CD FROM TB_T_PO_H WHERE PROCESS_ID = @processId
        SELECT @procChannelPrefix = PO_PREFIX  FROM TB_M_PROCUREMENT_CHANNEL WHERE PROC_CHANNEL_CD = @procChannel
		SELECT TOP 1 @divisionId = DIVISION_ID, @sectionId = SECTION_ID FROm TB_M_COORDINATOR_MAPPING mcp1 WHERE mcp1.COORDINATOR_CD = @purchasing_grp AND mcp1.POSITION_LEVEL = 
			(SELECT MAX(mcp2.POSITION_LEVEL) FROM TB_M_COORDINATOR_MAPPING mcp2 WHERE mcp1.COORDINATOR_CD = mcp2.COORDINATOR_CD)
		SELECT @PAYMENT_METHOD_CD = PAYMENT_METHOD_CD,	@PAYMENT_TERM = PAYMENT_TERM_CD FROM TB_M_VENDOR WHERE VENDOR_CD = @VENDOR_CD
		--SELECT TOP 1 @divisionName = DIVISION_NAME FROM TB_R_SYNCH_EMPLOYEE WHERE DIVISION_ID = @divisionId  AND GETDATE() BETWEEN VALID_FROM AND VALID_TO
		SELECT @generate_po_workflow = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'EC' AND SYSTEM_CD = 'PO_APPR_WORKFLOW'

		IF ISNULL(@generate_po_workflow,'N')='Y'
		BEGIN
			SET @generate_po_workflow = CASE WHEN @isDraft = 0 THEN @generate_po_workflow ELSE 'N' END
		END

		IF ISNULL(@generate_po_workflow,'N')='Y'
		BEGIN
			IF EXISTS(SELECT 1 from TB_R_SYNCH_EMPLOYEE WHERE SECTION_ID = @sectionId AND DIVISION_ID = @divisionId  AND CAST(GETDATE() AS DATE) BETWEEN VALID_FROM AND VALID_TO)  
			BEGIN
				select TOP 1
					@orgId = ORG_ID,
					@orgTitle = ORG_TITLE,
					@departmentId = DEPARTMENT_ID,
					@positionLevel = POSITION_LEVEL,
					@divisionName = DIVISION_NAME,
					@directorateId = DIRECTORATE_ID
				from TB_R_SYNCH_EMPLOYEE
				WHERE SECTION_ID = @sectionId AND DIVISION_ID = @divisionId AND CAST(GETDATE() AS DATE) BETWEEN VALID_FROM AND VALID_TO
			END
			ELSE 
			BEGIN 
				SET @divisionName =''
				declare @messageErr VARCHAR(200)
				SET @messageErr = 'Bug - Synch Employee is not well configured for Division : ' + CONVERT (VARCHAR, @divisionId) +', Section Id : '+ @sectionId +' and Valid date in '+ CONVERT (VARCHAR, GETDATE(),102)
				RAISERROR(@messageErr, 16, 1) 
			END

			DECLARE @orgRef TABLE ( OrgId VARCHAR(10), OrgName VARCHAR(50) )
			INSERT INTO @orgRef VALUES
			(@sectionId, 'SectionId'),
			(@departmentId, 'DepartmentId'),
			(@divisionId, 'DivisionId'),
			(@directorateId, 'DirectorateId')
		END

        -- Generate PONo
        DECLARE
            @candidatePONo VARCHAR(10),
            @numberingPrefix VARCHAR(2),
            @numberingVariant VARCHAR(2)

        IF @poNo = ''
        BEGIN
			SET @message = 'Generate PO No: begin'
			SET @MSG_ID = 'MSG0000003'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            DECLARE @docNumbering VARCHAR(MAX)
            DECLARE @docNumberingMessage TABLE ( Severity VARCHAR(1), [Message] VARCHAR(MAX), GeneratedNo VARCHAR(MAX) )
            DECLARE @splittedSPKMonth TABLE ( No INT, Split VARCHAR(100) )

            IF @procChannelPrefix IS NULL BEGIN RAISERROR('Bug - Procurement Channel is not well configured', 16, 1) END

            SELECT @numberingPrefix = LEFT(@procChannelPrefix, 2), @numberingVariant = RIGHT(@procChannelPrefix, 2)
            SELECT @docNumbering = dbo.GetNextDocNumbering(@numberingPrefix, @numberingVariant)
            INSERT INTO @docNumberingMessage
            SELECT
                (SELECT Split FROM dbo.SplitString(@docNumbering, '|') WHERE [No] = 2),
                (SELECT Split FROM dbo.SplitString(@docNumbering, '|') WHERE [No] = 3),
                (SELECT Split FROM dbo.SplitString(@docNumbering, '|') WHERE [No] = 1)

            IF (SELECT TOP 1 Severity FROM @docNumberingMessage) = 'E'
            BEGIN
                SET @message = (SELECT TOP 1 [Message] FROM @docNumberingMessage)
                RAISERROR(@message, 16, 1)
            END

            SELECT @candidatePONo = @numberingPrefix + RTRIM(LTRIM((SELECT TOP 1 GeneratedNo FROM @docNumberingMessage)))
            SET @message = 'Generated PO No: ' + @candidatePONo
			SET @MSG_ID = 'MSG0000004'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            -- Reserve PONo
            UPDATE TB_M_DOC_NUMBERING SET CURRENT_NUMBER = RIGHT(@candidatePONo, LEN(@candidatePONo)-2)
            WHERE NUMBERING_PREFIX = @numberingPrefix AND VARIANT = @numberingVariant

			SET @message = 'Generate PO No: end'
			SET @MSG_ID = 'MSG0000005'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
        END

        DECLARE
            @exactPONo VARCHAR(11) = (SELECT CASE WHEN (@poNo IS NULL OR @poNo = '') THEN @candidatePONo ELSE @poNo END),
            @isAnyUrgentDoc VARCHAR(1) = (SELECT CASE WHEN COUNT(0) > 0 THEN 'Y' ELSE 'N' END FROM TB_T_PO_ITEM WHERE DELETE_FLAG = 'N' AND URGENT_DOC = 'Y')

        BEGIN
            --- Budget Update Start
            -- Commit Budget
            -- NOTE: budget always called using reserved Document No
            DECLARE @isPOManual BIT = (SELECT CASE WHEN COUNT(0) > 0 THEN 1 ELSE 0 END FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId AND ISNULL(PO_NO, '') = ISNULL(@poNo, '') AND ISNULL(PR_NO, '') = '' AND ISNULL(PR_ITEM_NO, '') = '')
            DECLARE
                @wbsIdx INT = 0,
                @poItemGroupedByWBSCount INT,
                @oldPONo VARCHAR(15) = NULL,
                @totalAmount DECIMAL(18, 2), -- NOTE: BMS accept DECIMAL(18,2)
				@totalNewAmount DECIMAL(18, 2), -- NOTE: BMS accept DECIMAL(18,2)
                @totalReturnAmount DECIMAL(18, 2) = NULL,
                @materialNo VARCHAR(30) = '',
                @doc_no VARCHAR(10),
                @wbsNo VARCHAR(30),
                --@bmsOperation VARCHAR(20) = (SELECT CASE WHEN @isPOManual = 1 AND @exactPONo = '' THEN 'NEW_COMMIT' ELSE 'REV_COMMIT' END),
                @bmsOperation VARCHAR(30),
                @additionalAct VARCHAR(1) = NULL,
                @bmsResponse VARCHAR(20),
                @bmsResponseMessage VARCHAR(8000),
                @bmsRetryCounter INT = 0

            --DECLARE @budgetCheck TABLE ( DATA_NO INT, WBS_NO VARCHAR(30), DOC_NO VARCHAR(30), LOCAL_AMOUNT DECIMAL(18,6), ORI_LOCAL_AMOUNT DECIMAL(18,6), TRANS VARCHAR(1))
            DECLARE @budgetCheck TABLE (DATA_NO INT, WBS_NO VARCHAR(30), DOC_NO VARCHAR(30), TRANS VARCHAR(30), TOTAL_AMOUNT DECIMAL(18,4), TOTAL_NEW_AMOUNT DECIMAL(18,4), RETURN_VALUE DECIMAL(18,4) DEFAULT 0)

            --TOTAL AMOUNT : Yang mau di commit ke budget
			--TOTAL NEW AMOUNT : Yang mau dibalikin ke dokumen baru (in case : yang mau dijadikan PO)
			--TOTAL RETURN AMOUNT : Yang mau dibalikin ke dokumen lama (in case : yang mau dijadikan PR kembali)

            -- Budget calculation start (EXCLUDE DELETE FLAG !!!! PERLU DI ANALISA LAGI)
            INSERT INTO @budgetCheck
            SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) DATA_NO, WBS_NO, DOC_NO, TRANS, SUM(TOTAL_AMOUNT), SUM(TOTAL_NEW_AMOUNT), SUM(RETURN_VALUE)
            FROM (
                SELECT WBS_NO, DOC_NO, TRANS, SUM(TOTAL_AMOUNT) AS TOTAL_AMOUNT, SUM(TOTAL_NEW_AMOUNT) AS TOTAL_NEW_AMOUNT, SUM(RETURN_VALUE) AS RETURN_VALUE
                FROM (
                    SELECT
                        POI.WBS_NO, ISNULL((CASE WHEN ISNULL(PRI.PO_NO,'') = '' THEN PRI.PR_NO + '_' + PRI.BUDGET_REF ELSE NULL END), @exactPONo + '_001') AS DOC_NO,
                        CASE WHEN POI.PO_QTY_ORI = 0 THEN 'NEW_COMMIT' 
							WHEN POI.PO_QTY_ORI < POI.PO_QTY_NEW THEN 'CONVERT_COMMIT' 
							WHEN POI.PO_QTY_ORI = POI.PO_QTY_NEW THEN 'CONVERT_COMMIT' 
							ELSE 'REVERSE_COMMIT' END AS TRANS,
                        CASE 
							WHEN POI.PO_QTY_ORI > POI.PO_QTY_NEW THEN POI.ORI_AMOUNT - POI.NEW_AMOUNT
							WHEN POI.PO_QTY_ORI = POI.PO_QTY_NEW THEN (POI.PO_QTY_NEW)*(NEW_PRICE_PER_UOM) --ADD BY YANES
							ELSE POI.NEW_AMOUNT - ISNULL(POI.ORI_AMOUNT, 0) END AS TOTAL_AMOUNT,
						POI.NEW_AMOUNT AS TOTAL_NEW_AMOUNT,
                        CASE
                            WHEN POI.PO_QTY_ORI < POI.PO_QTY_NEW
                                THEN
                                    CASE WHEN POI.PO_QTY_ORI = 0 AND PRI.OPEN_QTY > POI.PO_QTY_NEW
                                        THEN
                                            ((PRI.OPEN_QTY - POI.PO_QTY_NEW)*ISNULL(PRI.PRICE_PER_UOM, POI.ORI_PRICE_PER_UOM))
                                    WHEN POI.PO_QTY_ORI = 0 AND PRI.OPEN_QTY <= POI.PO_QTY_NEW
                                        THEN
                                            ((POI.PO_QTY_NEW - PRI.OPEN_QTY)*ISNULL(PRI.PRICE_PER_UOM, POI.ORI_PRICE_PER_UOM))
                                    ELSE
                                        ((POI.PO_QTY_NEW-POI.PO_QTY_ORI)*ISNULL(PRI.PRICE_PER_UOM, POI.ORI_PRICE_PER_UOM))
                                    END
							--WHEN POI.PO_QTY_ORI = POI.PO_QTY_NEW THEN POI.ORI_AMOUNT - POI.NEW_AMOUNT --ADD BY YANES
                            ELSE
                                ((POI.PO_QTY_ORI-POI.PO_QTY_NEW)*POI.NEW_PRICE_PER_UOM)
                        END AS RETURN_VALUE
                    FROM TB_T_PO_ITEM POI
                        INNER JOIN TB_T_PO_H POH ON POH.PROCESS_ID = POI.PROCESS_ID
                        LEFT JOIN TB_R_PR_ITEM PRI ON PRI.PR_NO = POI.PR_NO AND PRI.PR_ITEM_NO = POI.PR_ITEM_NO
                    WHERE POI.PROCESS_ID = @processId AND ((POI.WBS_NO <> 'X') AND (ISNULL(POI.WBS_NO, '') <> ''))
                        AND POI.DELETE_FLAG = 'N'
                ) tblm GROUP BY WBS_NO, DOC_NO, TRANS
            ) tbla GROUP BY WBS_NO, DOC_NO, TRANS
            -- Budget calculation end

			UPDATE temp set 
				RETURN_VALUE = ISNULL((select SUM(ISNULL(PRI.OPEN_QTY,0)*ISNULL(PRI.PRICE_PER_UOM,0))
						from TB_R_PR_ITEM PRI 
						where PR_NO = LEFT(temp.DOC_NO,(LEN(temp.DOC_NO)-4)) AND WBS_NO = temp.WBS_NO-- AND ISNULL(PRI.PO_NO,'') = ''
						GROUP BY PR_NO, WBS_NO),0)
			FROM @budgetCheck temp

			UPDATE temp set 
				RETURN_VALUE = RETURN_VALUE - temp.TOTAL_AMOUNT
			FROM @budgetCheck temp WHERE RETURN_VALUE > 0

			--Cek amount sama atau tidak untuk proceed ke budget atau tidak ISTD) YHS
			BEGIN
				SET @poItemGroupedByWBSCount = (SELECT COUNT(0) FROM @budgetCheck)

				DECLARE @poNoForBMS VARCHAR(15)
			
				WHILE (@wbsIdx < @poItemGroupedByWBSCount)
				BEGIN
					SELECT
						@wbsNo = WBS_NO,
						@totalAmount = TOTAL_AMOUNT,
						@totalNewAmount = TOTAL_NEW_AMOUNT,
						@totalReturnAmount = RETURN_VALUE,
						@doc_no = DOC_NO,
						@bmsOperation = TRANS
					FROM @budgetCheck WHERE DATA_NO = @wbsIdx+1
			
					SELECT @message = CAST (TOTAL_AMOUNT AS VARCHAR) FROM @budgetCheck WHERE DATA_NO = @wbsIdx+1
					SET @MSG_ID = 'MSG0000006'
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

					IF @isPOManual = 1 AND @poNo = '' BEGIN SET @oldPONo = NULL END -- PO MANUAL BARU
					ELSE IF @isPOManual = 1 AND @poNo <> '' BEGIN SET @oldPONo = @poNo + '_001' END -- PO MANUAL EDIT
					ELSE IF @isPOManual = 0 AND @poNo = '' BEGIN SET @oldPONo = (SELECT TOP 1 DOC_NO FROM @budgetCheck WHERE DATA_NO = @wbsIdx+1) END -- PO ADOPT BARU
					ELSE BEGIN SET @oldPONo = @poNo + '_001' END

					SET @poNoForBMS = @exactPONo + '_001'
					IF (@bmsOperation = 'REVERSE_COMMIT') BEGIN 
						SET @poNoForBMS = (SELECT TOP 1 DOC_NO FROM @budgetCheck WHERE DATA_NO = @wbsIdx+1)
						SET @totalReturnAmount = @totalNewAmount
						SET @totalReturnAmount = ISNULL(@totalReturnAmount, 0)
					END

					SET @message = 'Operation : ' + @bmsOperation + '; Total amount  = ' + cast(@totalAmount as varchar) + '; Total new amount  = ' + cast(@totalNewAmount as varchar) + '; Total return value = ' + cast(@totalReturnAmount as varchar) + ';
							wbs no = ' + @wbsNo + '; old ref = ' + ISNULL(@oldPONo, '') + '; new ref = ' + ISNULL(@poNoForBMS, '') + '; curr = ' + @currency + '; desc = ' + @poDesc 

					SET @MSG_ID = 'MSG0000007'
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

					IF (@bmsOperation = 'CONVERT_COMMIT')
					BEGIN
						SET @oldPONo = (SELECT TOP 1 DOC_NO FROM @budgetCheck WHERE DATA_NO = @wbsIdx+1)
						SET @totalReturnAmount = @totalReturnAmount
						SET @totalReturnAmount = ISNULL(@totalReturnAmount, 0)
						--((SELECT SUM((PRI.OPEN_QTY-PRI.USED_QTY)*PRI.PRICE_PER_UOM) FROM TB_R_PR_ITEM PRI 
						--							WHERE PRI.PR_NO = LEFT(@oldPONo, LEN(@oldPONo)-4) AND PRI.ORI_CURR_CD = @currency AND PRI.WBS_NO = @wbsNo)-@totalNewAmount)
						SET @message = 'Total amount  = ' + cast(@totalAmount as varchar) + '; Total new amount  = ' + cast(@totalNewAmount as varchar) + '; Total return value = ' + cast(@totalReturnAmount as varchar) + ';
							wbs no = ' + @wbsNo + '; old ref = ' + ISNULL(@oldPONo, '') + '; new ref = ' + ISNULL(@poNoForBMS, '') + '; curr = ' + @currency + '; desc = ' + @poDesc 
						
						SET @MSG_ID = 'MSG0000008'
						INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
					END
					IF (@bmsOperation = 'NEW_COMMIT') BEGIN 
						SET @oldPONo = NULL
						SET @totalReturnAmount = 0
						SET @totalAmount = @totalNewAmount

						SET @message = 'Total amount  = ' + cast(@totalAmount as varchar) + '; Total new amount  = ' + cast(@totalNewAmount as varchar) + '; Total return value = ' + cast(@totalReturnAmount as varchar) + ';
							wbs no = ' + @wbsNo + '; old ref = ' + ISNULL(@oldPONo, '') + '; new ref = ' + ISNULL(@poNoForBMS, '') + '; curr = ' + @currency + '; desc = ' + @poDesc 
						
						SET @MSG_ID = 'MSG0000008'
						INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
					END

					SET @message = 'Budget ' + @bmsOperation + ' on WBS No: ' + @wbsNo + ' in the amount of: ' + CAST(@totalAmount AS VARCHAR) + ' with New Doc No ' + ISNULL(@poNoForBMS, '') + ' and Ref Doc No' + ISNULL(@oldPONo, '')+ ' start'
					SET @MSG_ID = 'MSG0000009'
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

					-- BMS operation initialization
					--IF (@isPOManual = 1 AND @exactPONo = '') SET @bmsOperation = 'NEW_COMMIT'
					--ELSE IF (@isPOManual = 1 AND @exactPONo <> '') SET @bmsOperation = 'REV_COMMIT'
					--ELSE SET @additionalAct = 'E'

					SET @message = 'Total amount  = ' + cast(@totalAmount as varchar) + '; Total return value = ' + cast(@totalReturnAmount as varchar) + ';
						wbs no = ' + @wbsNo + '; old ref = ' + ISNULL(@oldPONo, '') + '; new ref = ' + ISNULL(@poNoForBMS, '') + '; curr = ' + @currency + '; desc = ' + @poDesc + '
					'
					SET @MSG_ID = 'MSG0000010'
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

					--SET @bmsResponse = 0
					EXEC @bmsResponse =
						[BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
							@bmsResponseMessage OUTPUT,
							@currentUser,
							@bmsOperation,
							@wbsNo,
							@oldPONo,
							@poNoForBMS,
							@currency,
							@totalAmount,
							@totalReturnAmount,
							@materialNo,
							@poDesc,
							'ECatalogue',
							@additionalAct

					-- NOTE: bmsResponse always 0 or 1 String which means Success or Failed respectively
					WHILE (ISNULL(@bmsResponse, '0') <> '0' AND @bmsRetryCounter < 3)
					BEGIN
						-- NOTE: if Failed retry in 1 sec and log
						SET @message = 'Budget ' + @bmsOperation + ' Failed on WBS No: ' + @wbsNo + ' in the amount of: ' + CAST(@totalAmount AS VARCHAR) + ' with New Doc No ' + ISNULL(@poNoForBMS, '') + ' and Ref Doc No' + ISNULL(@oldPONo, '') + ': retry'
						SET @MSG_ID = 'MSG0000011'
						INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

						WAITFOR DELAY '00:00:01'
							 EXEC @bmsResponse =
								[BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
									@bmsResponseMessage OUTPUT,
									@currentUser,
									@bmsOperation,
									@wbsNo,
									@oldPONo,
									@poNoForBMS,
									@currency,
									@totalAmount,
									@totalReturnAmount,
									@materialNo,
									@poDesc,
									'ECatalogue',
									@additionalAct
						SET @bmsRetryCounter = @bmsRetryCounter + 1
					END

					IF ISNULL(@bmsResponse, '0') <> '0' 
					BEGIN 
						SET @bmsResponseMessage = @bmsResponseMessage + ', with PR no : ' + ISNULL(@oldPONo, '')
						RAISERROR(@bmsResponseMessage, 16, 1) 
					END

					INSERT INTO @budgetTransactTemp VALUES (@wbsNo, @oldPONo, @poNoForBMS, @currency, @totalAmount, @materialNo, @poDesc, @bmsOperation)

					SET @message = 'Budget ' + @bmsOperation + ' on WBS No: ' + @wbsNo + ' in the amount of: ' + CAST(@totalAmount AS VARCHAR) + ' with New Doc No ' + ISNULL(@poNoForBMS, '') + ' and Ref Doc No' + ISNULL(@oldPONo, '') + ' : end'
					SET @MSG_ID = 'MSG0000012'
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

					SET @wbsIdx = @wbsIdx + 1
				END
			END
            --- Budget Update End
        END

		
		DECLARE @QUOTA_WBS_NO VARCHAR(30),
				@QUOTA_VALUATUION_CLASS VARCHAR(4),
				@QUOTA_MAT_NO VARCHAR(23),
				@QUOTA_MAT_DESC VARCHAR(50),
				@QUOTA_DIVISION_ID INT,
				@QUOTA_AMOUNT DECIMAL(18,4),
				@QUOTA_PO_NO VARCHAR(10),
				@QUOTA_PR_NO VARCHAR(10),
				@QUOTA_CONSUME_MONTH VARCHAR(6)
		-- Insert or Update Quota
		BEGIN
			IF CURSOR_STATUS('global','db_cursor_quota') >= -1
			BEGIN
				DEALLOCATE db_cursor_quota
			END

			DECLARE db_cursor_quota CURSOR FOR  
			SELECT  POI.WBS_NO, POI.VALUATION_CLASS, POI.MAT_NO, POI.MAT_DESC, PRH.DIVISION_ID, SUM((POI.PO_QTY_REMAIN*POI.NEW_PRICE_PER_UOM)), @exactPONo,  CASE WHEN ISNULL(@clonePONO,'') ='' THEN PRI.PR_NO ELSE @clonePONO END
                    FROM TB_T_PO_ITEM POI
                        INNER JOIN TB_T_PO_H POH ON POH.PROCESS_ID = POI.PROCESS_ID
                        INNER JOIN TB_R_PR_ITEM PRI ON PRI.PR_NO = POI.PR_NO AND PRI.PR_ITEM_NO = POI.PR_ITEM_NO
						INNER JOIN TB_R_PR_H PRH ON PRH.PR_NO = PRI.PR_NO
						INNER JOIN TB_M_QUOTA MQ ON MQ.WBS_NO = PRI.WBS_NO AND MQ.DIVISION_ID = PRH.DIVISION_ID AND MQ.QUOTA_TYPE = PRI.VALUATION_CLASS 
                    WHERE POH.PROCESS_ID = @processId AND ((POI.WBS_NO <> 'X') AND (ISNULL(POI.WBS_NO, '') <> ''))
                        AND POI.DELETE_FLAG = 'N' AND ISNULL(PRI.QUOTA_FLAG,'N') = 'Y'
			GROUP BY POI.WBS_NO, POI.VALUATION_CLASS, POI.MAT_NO, POI.MAT_DESC, PRH.DIVISION_ID, POI.PO_NO, PRI.PR_NO

			OPEN db_cursor_quota   
			FETCH NEXT FROM db_cursor_quota INTO @QUOTA_WBS_NO, @QUOTA_VALUATUION_CLASS, @QUOTA_MAT_NO, @QUOTA_MAT_DESC, @QUOTA_DIVISION_ID, @QUOTA_AMOUNT, @QUOTA_PO_NO, @QUOTA_PR_NO
			WHILE @@FETCH_STATUS = 0   
			BEGIN
				SELECT @message = 'Quota No: ' + @QUOTA_WBS_NO + ', Reff Doc: '  + @QUOTA_PR_NO + ', New Doc: '  + @QUOTA_PO_NO + ', Total Amount: '  + CONVERT(VARCHAR, @QUOTA_AMOUNT) +':starting' 
				SET @MSG_ID = 'MSG0000011'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

				IF ISNULL(@clonePONO,'') = ''
				BEGIN
					SELECT @QUOTA_CONSUME_MONTH = CONVERT(CHAR(6), CREATED_DT, 112) FROM TB_R_PR_H WHERE PR_NO = @QUOTA_PR_NO
				END
				ELSE
				BEGIN
					SELECT @QUOTA_CONSUME_MONTH = CONVERT(CHAR(6), CREATED_DT, 112) FROM TB_R_PO_H WHERE PO_NO = @clonePONO
				END

				EXEC dbo.sp_ecatalogue_quotaCalculation 'UPDATE', @QUOTA_WBS_NO, @QUOTA_WBS_NO, @QUOTA_VALUATUION_CLASS, @QUOTA_MAT_NO, @QUOTA_MAT_DESC, @QUOTA_DIVISION_ID, @QUOTA_CONSUME_MONTH , @QUOTA_CONSUME_MONTH,
					@QUOTA_AMOUNT, @QUOTA_AMOUNT, @QUOTA_PO_NO, @QUOTA_PR_NO, @actionName, @currentUser, @Status OUTPUT, @message OUTPUT

				IF @STATUS <> 'SUCCESS' BEGIN RAISERROR(@message, 16, 1) END

				SELECT @message = 'Quota No: ' + @QUOTA_WBS_NO + ', Reff Doc: '  + @QUOTA_PR_NO + ', New Doc: '  + @QUOTA_PO_NO + ', Total Amount: '  + CONVERT(VARCHAR, @QUOTA_AMOUNT)+':end' 
				SET @MSG_ID = 'MSG0000012'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

				FETCH NEXT FROM db_cursor_quota INTO @QUOTA_WBS_NO, @QUOTA_VALUATUION_CLASS, @QUOTA_MAT_NO, @QUOTA_MAT_DESC, @QUOTA_DIVISION_ID, @QUOTA_AMOUNT, @QUOTA_PO_NO, @QUOTA_PR_NO
			END

			CLOSE db_cursor_quota   
			DEALLOCATE db_cursor_quota
		END


        -- Insert or Update
        SET @message = 'Insert data to TB_R_PO_H where PO_NO: ' + @exactPONo + ': begin'
		SET @MSG_ID = 'MSG0000013'
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

		IF NOT EXISTS(SELECT 1 FROm TB_R_PO_H WHERE PO_NO = @exactPONo)
        BEGIN -- Insert
            INSERT INTO TB_R_PO_H
            (PO_NO, PO_DESC, VENDOR_CD, VENDOR_NAME, DOC_DT, PROC_MONTH, PAYMENT_METHOD_CD, PAYMENT_TERM_CD, DOC_TYPE, DOC_CATEGORY,
            PURCHASING_GRP_CD, INV_WO_GR_FLAG, PO_CURR, PO_AMOUNT, PO_EXCHANGE_RATE, LOCAL_CURR, PO_STATUS, RELEASED_FLAG, RELEASED_DT, DELETION_FLAG,
            PROCESS_ID, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT, SAP_DOC_NO, URGENT_DOC, DRAFT_FLAG, SYSTEM_SOURCE,
            REF_NO, PO_NEXT_STATUS, PO_NOTE1, PO_NOTE2, PO_NOTE3, PO_NOTE4, PO_NOTE5, PO_NOTE6, PO_NOTE7, PO_NOTE8, PO_NOTE9, PO_NOTE10,
            VENDOR_ADDRESS, COUNTRY, POSTAL_CODE, CITY, ATTENTION, PHONE, FAX, SAP_PO_NO, SPK_NO, SPK_DT, SPK_BIDDING_DT, SPK_WORK_DESC, SPK_LOCATION,
            SPK_AMOUNT, SPK_PERIOD_START, SPK_PERIOD_END, SPK_RETENTION, SPK_TERMIN_I, SPK_TERMIN_I_DESC, SPK_TERMIN_II, SPK_TERMIN_II_DESC,
            SPK_TERMIN_III, SPK_TERMIN_III_DESC, SPK_TERMIN_IV, SPK_TERMIN_IV_DESC, SPK_TERMIN_V, SPK_TERMIN_V_DESC, SPK_SIGN, SPK_SIGN_NAME,
            DELIVERY_ADDR, DELIVERY_NAME, DELIVERY_ADDRESS, DELIVERY_POSTAL_CODE, DELIVERY_CITY, OTHER_MAIL)
            SELECT @exactPONo, PO_DESC, VENDOR_CD, VENDOR_NAME, GETDATE(), @procMonth, @PAYMENT_METHOD_CD, @PAYMENT_TERM, 'PO', '',
            @purchasing_grp, NULL, @currency, 0, @exchangeRate, @LOCAL_CURRENCY, @poHeaderStatusCode, 'N', NULL, 'N', NULL processId,
            @currentUser, GETDATE(), NULL, NULL, NULL, @isAnyUrgentDoc, 0 saveAsDraft, 'ECatalogue', '', @poHeaderNextStatusCode, PO_NOTE1, PO_NOTE2,
            PO_NOTE3, PO_NOTE4, PO_NOTE5, PO_NOTE6, PO_NOTE7, PO_NOTE8, PO_NOTE9, PO_NOTE10, VENDOR_ADDRESS, COUNTRY, POSTAL_CODE,
            CITY, ATTENTION, PHONE, FAX, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, DELIVERY_ADDR, DELIVERY_NAME, DELIVERY_ADDRESS, DELIVERY_POSTAL_CODE, DELIVERY_CITY, OTHER_MAIL
			FROM TB_T_PO_H WHERE PROCESS_ID = @processId		
        END

		INSERT INTO @process_level VALUES(1)

        -- Generate SPK
        DECLARE
            @spkNoCounter VARCHAR(4),
            @spkNo VARCHAR(18),
            @spkDate DATETIME = GETDATE(),
            @signerName VARCHAR(50),
            @signerTitle VARCHAR(50)

        SELECT @spkNo = SPK_NO FROM TB_R_PO_H WHERE PO_NO = @exactPONo
        IF (@isSPKCreated = 1)
        BEGIN
			SET @message = 'Saving SPK: begin'
			SET @MSG_ID = 'MSG0000014'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            IF (ISNULL(@spkNo, '') = '')
            BEGIN
				SET @message = 'Generate SPK No: begin'
				SET @MSG_ID = 'MSG0000015'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

                SELECT @numberingPrefix = 'SP', @numberingVariant = 'PK'
                SELECT @docNumbering = dbo.GetNextDocNumbering(@numberingPrefix, @numberingVariant)
                INSERT INTO @docNumberingMessage
                SELECT
                    (SELECT Split FROM dbo.SplitString(@docNumbering, '|') WHERE [No] = 2),
                    (SELECT Split FROM dbo.SplitString(@docNumbering, '|') WHERE [No] = 3),
                    (SELECT Split FROM dbo.SplitString(@docNumbering, '|') WHERE [No] = 1)

                IF (SELECT TOP 1 Severity FROM @docNumberingMessage) = 'E'
                BEGIN
                    SET @message = (SELECT TOP 1 [Message] FROM @docNumberingMessage)
                    RAISERROR(@message, 16, 1)
                END

                INSERT INTO @splittedSPKMonth
                SELECT No, Split FROM dbo.SplitString('I,II,III,IV,V,VI,VII,VIII,IX,X,XI,XII', ',')
                SELECT @spkNoCounter = RTRIM(LTRIM((SELECT TOP 1 GeneratedNo FROM @docNumberingMessage)))
                SELECT @spkNo = 'SPK/' + @spkNoCounter + '/E/' + (SELECT Split FROM @splittedSPKMonth WHERE No = MONTH(@spkDate)) + '/' + CAST(YEAR(@spkDate) AS VARCHAR)
                SET @message = 'Generated SPK No: ' + @spkNo
				SET @MSG_ID = 'MSG0000016'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

                -- Reserve SPKNo
                UPDATE TB_M_DOC_NUMBERING SET CURRENT_NUMBER = @spkNoCounter
                WHERE NUMBERING_PREFIX = 'SP' AND VARIANT = 'PK'

                -- Update SPK No in POH
                UPDATE TB_R_PO_H SET SPK_NO = @spkNo WHERE PO_NO = @exactPONo

                -- Always archive
                INSERT INTO TB_H_SPK
                (PROCESS_ID, PR_NO, PO_NO, SPK_NO, SPK_DT, SPK_BIDDING_DT, SPK_PARAGRAPH1, SPK_WORK_DESC, SPK_LOCATION, SPK_AMOUNT,
                SPK_PERIOD_START, SPK_PERIOD_END, SPK_RETENTION, SPK_TERMIN_I, SPK_TERMIN_I_DESC, SPK_TERMIN_II, SPK_TERMIN_II_DESC,
                SPK_TERMIN_III, SPK_TERMIN_III_DESC, SPK_TERMIN_IV, SPK_TERMIN_IV_DESC, SPK_TERMIN_V, SPK_TERMIN_V_DESC, SPK_SIGN,
                SPK_SIGN_NAME, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT)
                select @processId, @exactPONo, @exactPONo, @spkNo, @spkDate, SPK_BIDDING_DT, REPLACE('BLANK', '[enter]', '<br/>') SPK_OPENING, SPK_WORK_DESC,
                SPK_LOCATION, SPK_AMOUNT, SPK_PERIOD_START, SPK_PERIOD_END, SPK_RETENTION, SPK_TERMIN_I, SPK_TERMIN_I_DESC, SPK_TERMIN_II, SPK_TERMIN_II_DESC,
                SPK_TERMIN_III, SPK_TERMIN_III_DESC, SPK_TERMIN_IV, SPK_TERMIN_IV_DESC, SPK_TERMIN_V, SPK_TERMIN_V_DESC, @signerTitle, @signerName, @currentUser,
                GETDATE(), NULL, NULL
				FROM TB_T_PO_H WHERE PROCESS_ID = @processId

				SET @message = 'Generate SPK No: end'
				SET @MSG_ID = 'MSG0000017'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
            END

			SET @message = 'Saving SPK: end'
			SET @MSG_ID = 'MSG0000018'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
			INSERT INTO @process_level VALUES(2)
        END

        SET @message = 'Insert data to TB_R_PO_H where PO_NO: ' + @exactPONo + ': end'
		SET @MSG_ID = 'MSG0000019'
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 2, @currentUser)

        DECLARE @poCreatorStatusCode VARCHAR(5) = '40', @poNextStatus VARCHAR(5) = '41', @poApprovalSegmentCode VARCHAR(5) = '4', @itemIdx INT = 0, @detailItemDataCount INT

        -- Move temp (TB_T) to it's real table (TB_R)
        SET @message = 'Insert data to TB_R_PO_ITEM where PO_NO: ' + ISNULL(@exactPONo, 'NULL') + ': begin'
		SET @MSG_ID = 'MSG0000020'
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        DECLARE
            @lastItemNo INT = (SELECT ISNULL(MAX(PO_ITEM_NO), 0) FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId),
            @lastSubItemNo INT = (SELECT ISNULL(MAX(PO_SUBITEM_NO), 0) FROM TB_T_PO_SUBITEM WHERE PROCESS_ID =  @processId)


        IF NOT EXISTS(SELECT 1 FROm TB_R_PO_ITEM WHERE PO_NO = @exactPONo)
		BEGIN
			INSERT INTO TB_R_PO_ITEM
			(PO_NO, PO_ITEM_NO, PR_NO, PR_ITEM_NO, MAT_NO, MAT_DESC, VALUATION_CLASS, VALUATION_CLASS_DESC, PROCUREMENT_PURPOSE, DELIVERY_PLAN_DT,
			SOURCE_TYPE, PLANT_CD, SLOC_CD, DIVISION_ID, DIVISION_NAME, WBS_NO, COST_CENTER_CD, UNLIMITED_FLAG, TOLERANCE_PERCENTAGE, SPECIAL_PROCUREMENT_TYPE,
			PO_QTY_ORI, PO_QTY_USED, PO_QTY_REMAIN, UOM, PRICE_PER_UOM, ORI_AMOUNT, LOCAL_AMOUNT, PO_STATUS, PO_NEXT_STATUS, IS_REJECTED,
			CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT, WBS_NAME, GL_ACCOUNT, RELEASE_FLAG, IS_PARENT, ITEM_CLASS, GROSS_PERCENT, URGENT_DOC)
			SELECT @exactPONo PO_NO, ISNULL(tmp.PO_ITEM_NO, tmp.DATA_NO) PO_ITEM_NO, tmp.PR_NO, tmp.PR_ITEM_NO, tmp.MAT_NO, tmp.MAT_DESC, tmp.VALUATION_CLASS,
			(SELECT TOP 1 VALUATION_CLASS_DESC FROM TB_M_VALUATION_CLASS WHERE VALUATION_CLASS = tmp.VALUATION_CLASS) VALUATION_CLASS_DESC, tmp.PROCUREMENT_PURPOSE,
			tmp.DELIVERY_PLAN_DT, tmp.SOURCE_TYPE, tmp.PLANT_CD, tmp.SLOC_CD, @divisionId DIVISION_ID, @divisionName DIVISION_NAME, tmp.WBS_NO, tmp.COST_CENTER_CD,
			tmp.UNLIMITED_FLAG, tmp.TOLERANCE_PERCENTAGE, tmp.SPECIAL_PROCUREMENT_TYPE, tmp.PO_QTY_NEW, tmp.PO_QTY_USED, (tmp.PO_QTY_NEW-tmp.PO_QTY_USED), tmp.UOM, tmp.NEW_PRICE_PER_UOM,
			tmp.NEW_AMOUNT, tmp.NEW_LOCAL_AMOUNT, @poCreatorStatusCode PO_STATUS, @poNextStatus PO_NEXT_STATUS, 'N' IS_REJECTED, tmp.CREATED_BY,
			tmp.CREATED_DT, NULL CHANGED_BY, NULL CHANGED_DT, tmp.WBS_NAME, tmp.GL_ACCOUNT, @poReleaseFlag RELEASE_FLAG, tmp.IS_PARENT, tmp.ITEM_CLASS, tmp.GROSS_PERCENT, tmp.URGENT_DOC
			FROM (SELECT dbo.GetZeroPaddedNo(5, (@lastItemNo + ROW_NUMBER() OVER (ORDER BY PO_NO ASC, PO_ITEM_NO ASC, SEQ_ITEM_NO ASC)) * 10) DATA_NO, *
				FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId AND DELETE_FLAG = 'N'
			) tmp
		END

  --      -- Don't forget to decrease Adopted PR Qty
        MERGE INTO TB_R_PR_ITEM pri USING (
            SELECT poit.PROCESS_ID, poit.PR_NO, poit.PR_ITEM_NO, --ass.ASSET_NO,
            SUM(poit.PO_QTY_NEW) PO_QTY_NEW, SUM(poit.PO_QTY_ORI) PO_QTY_ORI, poit.DELETE_FLAG FROM TB_T_PO_ITEM poit
            --LEFT JOIN TB_R_ASSET ass ON poit.PR_NO = ass.PR_NO AND poit.PR_ITEM_NO = ass.PR_ITEM_NO AND poit.ASSET_NO = ass.ASSET_NO
            WHERE poit.PROCESS_ID = @processId AND poit.DELETE_FLAG = 'N'
            GROUP BY poit.PROCESS_ID, poit.PR_NO, poit.PR_ITEM_NO,
            --ass.ASSET_NO,
            poit.DELETE_FLAG
        ) tmp ON pri.PR_NO = ISNULL(tmp.PR_NO, '') AND pri.PR_ITEM_NO = ISNULL(tmp.PR_ITEM_NO, '')
        --AND ISNULL(pri.ASSET_NO, '') = ISNULL(tmp.ASSET_NO, '') 
		AND pri.OPEN_QTY > 0
        WHEN MATCHED THEN
        UPDATE SET
        pri.OPEN_QTY = pri.OPEN_QTY - tmp.PO_QTY_ORI,
        pri.USED_QTY = pri.USED_QTY + tmp.PO_QTY_ORI,
		--add info PO No in TB_R_PR_ITEM 25/11/2016
		PO_NO = @exactPONo
        ;

        INSERT INTO @process_level VALUES(3)

        SET @message = 'Insert data to TB_R_PO_ITEM where PO_NO: ' + ISNULL(@exactPONo, 'NULL') + ': end'
		SET @MSG_ID = 'MSG0000021'
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 2, @currentUser)

        SET @message = 'Insert data to TB_R_PO_CONDITION where PO_NO: ' + ISNULL(@exactPONo, 'NULL') + ': begin'
		SET @MSG_ID = 'MSG0000022'
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        -- Delete matching rows first
        MERGE INTO TB_R_PO_CONDITION poc USING (
            SELECT poct.* FROM TB_T_PO_CONDITION poct
            JOIN TB_T_PO_ITEM poit ON poct.PROCESS_ID = poit.PROCESS_ID
            AND poit.DELETE_FLAG = 'N' AND poct.SEQ_ITEM_NO = poit.SEQ_ITEM_NO
            AND poct.PROCESS_ID = @processId AND poct.DELETE_FLAG = 'Y' AND poct.NEW_FLAG = 'N') tmp
        ON poc.PO_NO = ISNULL(tmp.PO_NO, '') AND poc.PO_ITEM_NO = ISNULL(tmp.PO_ITEM_NO, '')
        AND poc.COMP_PRICE_CD = tmp.COMP_PRICE_CD
        WHEN MATCHED THEN DELETE
        ;

        -- Then update matching rows
        MERGE INTO TB_R_PO_CONDITION poc USING (
            SELECT poct.* FROM TB_T_PO_CONDITION poct
            JOIN TB_T_PO_ITEM poit ON poct.PROCESS_ID = poit.PROCESS_ID
            AND poit.DELETE_FLAG = 'N' AND poct.SEQ_ITEM_NO = poit.SEQ_ITEM_NO
            AND poct.PROCESS_ID = @processId AND poct.UPDATE_FLAG = 'Y'
            AND poct.NEW_FLAG = 'N' AND poct.DELETE_FLAG = 'N') tmp
        ON poc.PO_NO = ISNULL(tmp.PO_NO, '') AND poc.PO_ITEM_NO = ISNULL(tmp.PO_ITEM_NO, '')
        AND poc.COMP_PRICE_CD = tmp.COMP_PRICE_CD
        WHEN MATCHED THEN
        UPDATE SET
        poc.CALCULATION_TYPE = tmp.CALCULATION_TYPE,
        poc.QTY_PER_UOM = tmp.QTY_PER_UOM, poc.COMP_PRICE_RATE = tmp.COMP_PRICE_RATE,
        poc.PRICE_AMT = tmp.PRICE_AMT, poc.CHANGED_BY = @currentUser, poc.CHANGED_DT = GETDATE()
        ;

        -- Lastly insert all new rows
        INSERT INTO TB_R_PO_CONDITION
        (PO_NO, PO_ITEM_NO, COMP_PRICE_CD, COMP_PRICE_RATE, INVOICE_FLAG, EXCHANGE_RATE, SEQ_NO, BASE_VALUE_FROM, BASE_VALUE_TO, PO_CURR,
        INVENTORY_FLAG, CALCULATION_TYPE, PLUS_MINUS_FLAG, CONDITION_CATEGORY, ACCRUAL_FLAG_TYPE, CONDITION_RULE, QTY, QTY_PER_UOM, PRICE_AMT, COMP_TYPE,
        PRINT_STATUS, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT)
        SELECT @exactPONo, ISNULL(tmp.PO_ITEM_NO, tmp.PO_ITEM_NO_2), tmp.COMP_PRICE_CD, tmp.COMP_PRICE_RATE, tmp.INVOICE_FLAG, tmp.EXCHANGE_RATE,
        tmp.SEQ_NO, tmp.BASE_VALUE_FROM, tmp.BASE_VALUE_TO, tmp.PO_CURR, tmp.INVENTORY_FLAG, tmp.CALCULATION_TYPE, tmp.PLUS_MINUS_FLAG,
        tmp.CONDITION_CATEGORY, tmp.ACCRUAL_FLAG_TYPE, tmp.CONDITION_RULE, tmp.QTY, tmp.QTY_PER_UOM, tmp.PRICE_AMT, tmp.COMP_TYPE, tmp.PRINT_STATUS,
        tmp.CREATED_BY, tmp.CREATED_DT, NULL, NULL
        FROM (SELECT poit.PO_ITEM_NO_2, poct.* FROM TB_T_PO_CONDITION poct
        JOIN (
            SELECT ISNULL(PO_ITEM_NO, dbo.GetZeroPaddedNo(5, (@lastItemNo + ROW_NUMBER() OVER (ORDER BY PO_NO ASC, PO_ITEM_NO ASC, SEQ_ITEM_NO ASC)) * 10)) PO_ITEM_NO_2, *
            FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId AND DELETE_FLAG = 'N') poit
        ON poct.PROCESS_ID = poit.PROCESS_ID AND poct.SEQ_ITEM_NO = poit.SEQ_ITEM_NO
        AND poct.PROCESS_ID = @processId AND poct.NEW_FLAG = 'Y' AND poct.DELETE_FLAG = 'N') tmp

		INSERT INTO @process_level VALUES(4)

        SET @message = 'Insert data to TB_R_PO_CONDITION where PO_NO: ' + ISNULL(@exactPONo, 'NULL') + ': end'
		SET @MSG_ID = 'MSG0000023'
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 2, @currentUser)

		INSERT INTO @process_level VALUES(5)

        UPDATE TB_R_PO_H SET PO_AMOUNT = (SELECT SUM(ORI_AMOUNT) FROM TB_R_PO_ITEM WHERE PO_NO = @exactPONo) WHERE PO_NO = @exactPONo

		UPDATE temp SET PO_NO = @exactPONo
		FROM TB_R_PR_ITEM temp 
		INNER JOIN TB_T_PO_ITEM tpoi ON tpoi.PR_NO = temp.PR_NO AND tpoi.PR_ITEM_NO = temp.PR_ITEM_NO AND tpoi.DELETE_FLAG = 'N'
		WHERE tpoi.PROCESS_ID = @processId

		INSERT INTO @process_level VALUES(6)

		IF ISNULL(@generate_po_workflow,'N')='Y'
		BEGIN
            -- Set Worklist
            SET @message = 'Insert data to TB_M_WORKFLOW where PO_NO: ' + @exactPONo + ': begin'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000024', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            DECLARE
                @approvalFunctionId VARCHAR(6) = '303001',
                @defaultInterval INT = (SELECT ISNULL(MAX(CAST(mvc.APPROVAL_INTERVAL AS INT)), 0) FROM TB_T_PO_ITEM poi JOIN TB_M_VALUATION_CLASS mvc ON poi.VALUATION_CLASS = mvc.VALUATION_CLASS WHERE poi.PROCESS_ID = @processId ),
                @sumOriAmount DECIMAL(18, 4) = (SELECT SUM(ORI_LOCAL_AMOUNT) FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId),
                @sumNewAmount DECIMAL(18, 4) = (SELECT SUM(NEW_LOCAL_AMOUNT) FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId),
                @exactItemNo VARCHAR(5) = '00000'

            IF @sumNewAmount > @sumOriAmount
            BEGIN
                DELETE FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @exactPONo
                UPDATE TB_R_PO_H SET PO_STATUS = '40', PO_NEXT_STATUS = '41' WHERE PO_NO = @exactPONo
                UPDATE TB_R_PO_ITEM SET PO_STATUS = '40', PO_NEXT_STATUS = '41' WHERE PO_NO = @exactPONo
            END

            IF (NOT EXISTS(SELECT DOCUMENT_NO FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @exactPONo))
            BEGIN
                -- Creator approval workflow
                INSERT INTO TB_R_WORKFLOW
                (DOCUMENT_NO, ITEM_NO, DOCUMENT_SEQ, APPROVAL_CD, APPROVAL_DESC, APPROVED_BY, NOREG, APPROVED_BYPASS, APPROVED_DT, STRUCTURE_ID,
                STRUCTURE_NAME, APPROVER_POSITION, IS_APPROVED, IS_REJECTED, IS_DISPLAY, LIMIT_FLAG, MAX_AMOUNT, CREATED_BY, CREATED_DT, CHANGED_BY,
                CHANGED_DT, IS_CANCELLED, APPROVER_NAME, APPROVAL_INTERVAL, INTERVAL_DATE, RELEASE_FLAG)
                SELECT @exactPONo, @exactItemNo, 1, '40', (SELECT TOP 1 STATUS_DESC FROM TB_M_STATUS WHERE STATUS_CD = '40' AND DOC_TYPE = 'PO'), @currentUserNoReg,
                @currentUserNoReg, @currentUserNoReg, GETDATE(), @orgId, @orgTitle, @positionLevel, 'Y', 'N', 'Y', 'N', 'N', @currentUser, GETDATE(), NULL, NULL,
                'N', @currentUser personnelName, 0, GETDATE(), 'N'

                -- Approver approval workflow
                INSERT INTO TB_R_WORKFLOW
                (DOCUMENT_NO, ITEM_NO, DOCUMENT_SEQ, APPROVAL_CD, 
				APPROVAL_DESC, APPROVED_BY, NOREG, 
				APPROVED_BYPASS, APPROVED_DT, 
				STRUCTURE_ID, STRUCTURE_NAME, 
				APPROVER_POSITION, IS_APPROVED, IS_REJECTED, IS_DISPLAY, LIMIT_FLAG, MAX_AMOUNT, CREATED_BY, CREATED_DT, CHANGED_BY,
                CHANGED_DT, IS_CANCELLED, APPROVER_NAME, APPROVAL_INTERVAL, INTERVAL_DATE, RELEASE_FLAG)
                SELECT @exactPONo, @exactItemNo, ROW_NUMBER() OVER(ORDER BY tmp.PositionLevel DESC) + 1, tmp.POStatus,
				(SELECT TOP 1 STATUS_DESC FROM TB_M_STATUS WHERE STATUS_CD = tmp.POStatus AND DOC_TYPE = 'PO'),tmp.RegNo, tmp.RegNo, 
				NULL, --CASE WHEN @positionLevel < tmp.PositionLevel THEN @currentUserNoReg ELSE NULL END,
                NULL, --CASE WHEN @positionLevel < tmp.PositionLevel THEN GETDATE() ELSE NULL END, 
				tmp.OrgId, tmp.OrgTitle,
                tmp.PositionLevel, 'N',--CASE WHEN @positionLevel < tmp.PositionLevel THEN 'Y' ELSE 'N' END, 
				'N', tmp.IsDisplay,
                'N', tmp.MaxAmount, @currentUser, GETDATE(), NULL, NULL, 'N', tmp.ApproverName, @defaultInterval,
                dbo.fn_dateadd_workday(@defaultInterval, GETDATE()), 'N'
                FROM (
                    SELECT
                        se.ORG_ID OrgId,
                        se.ORG_TITLE OrgTitle,
                        MIN(se.POSITION_LEVEL) PositionLevel,
                        @approvalFunctionId FunctionId,
                        op.LEVEL_ID LevelId,
                        st.SYSTEM_VALUE POStatus,
                        am.SYSTEM_VALUE MaxAmount,
                        CASE WHEN @sumNewAmount > CAST(am.SYSTEM_VALUE AS DECIMAL(18, 4)) THEN 'Y' ELSE 'N' END IsDisplay,
                        se.PERSONNEL_NAME ApproverName,
                        se.NOREG RegNo
                    FROM TB_R_SYNCH_EMPLOYEE se
                    JOIN TB_M_ORG_POSITION op ON se.POSITION_LEVEL = op.POSITION_LEVEL
                    JOIN TB_M_SYSTEM am ON se.POSITION_LEVEL = am.SYSTEM_CD AND am.FUNCTION_ID = 'XPOAMT'
                    JOIN TB_M_SYSTEM st ON op.LEVEL_ID = st.SYSTEM_CD AND st.FUNCTION_ID = @approvalFunctionId
                    WHERE se.DIVISION_ID = @divisionId AND GETDATE() BETWEEN se.VALID_FROM AND VALID_TO AND se.ORG_ID IN (SELECT OrgId FROM @orgRef GROUP BY OrgId)
                    AND CASE WHEN @sumNewAmount > CAST(am.SYSTEM_VALUE AS DECIMAL(18, 4)) THEN 'Y' ELSE 'N' END = 'Y'
                    GROUP BY se.ORG_ID, se.ORG_TITLE, op.LEVEL_ID, st.SYSTEM_VALUE, am.SYSTEM_VALUE, se.PERSONNEL_NAME, se.NOREG
                ) tmp

				DECLARE @last_seq int
				SET @last_seq = (SELECT MAX(DOCUMENT_SEQ) FROM TB_R_WORKFLOW wp WHERE wp.DOCUMENT_NO = @exactPONo AND wp.ITEM_NO = @exactItemNo) 

				-- Add Approver IN SAME LEVEL or higher if current level not exist in approval workflow
                INSERT INTO TB_R_WORKFLOW
                (DOCUMENT_NO, ITEM_NO, DOCUMENT_SEQ, APPROVAL_CD, APPROVAL_DESC, APPROVED_BY, NOREG, APPROVED_BYPASS, APPROVED_DT, STRUCTURE_ID,
                STRUCTURE_NAME, APPROVER_POSITION, IS_APPROVED, IS_REJECTED, IS_DISPLAY, LIMIT_FLAG, MAX_AMOUNT, CREATED_BY, CREATED_DT, CHANGED_BY,
                CHANGED_DT, IS_CANCELLED, APPROVER_NAME, APPROVAL_INTERVAL, INTERVAL_DATE, RELEASE_FLAG)
				SELECT @exactPONo, @exactItemNo, ROW_NUMBER() OVER(ORDER BY tmp.PositionLevel DESC) + @last_seq, tmp.POStatus,
                (SELECT TOP 1 STATUS_DESC FROM TB_M_STATUS WHERE STATUS_CD = tmp.POStatus AND DOC_TYPE = 'PO'),
                tmp.RegNo, tmp.RegNo, CASE WHEN @positionLevel < tmp.PositionLevel THEN @currentUserNoReg ELSE NULL END,
                CASE WHEN @positionLevel < tmp.PositionLevel THEN GETDATE() ELSE NULL END, tmp.OrgId, tmp.OrgTitle,
                tmp.PositionLevel, CASE WHEN @positionLevel < tmp.PositionLevel THEN 'Y' ELSE 'N' END, 'N', tmp.IsDisplay,
                'N', tmp.MaxAmount, @currentUser, GETDATE(), NULL, NULL, 'N', tmp.ApproverName, @defaultInterval,
                dbo.fn_dateadd_workday(@defaultInterval, GETDATE()), 'N'
                FROM (
                    SELECT ROW_NUMBER() OVER(PARTITION BY op.LEVEL_ID ORDER BY op.LEVEL_ID DESC, op.POSITION_LEVEL ASC) AS DATA_ID,
                        se.ORG_ID OrgId,
                        se.ORG_TITLE OrgTitle,
                        se.POSITION_LEVEL PositionLevel,
                        @approvalFunctionId FunctionId,
                        op.LEVEL_ID LevelId,
                        st.SYSTEM_VALUE POStatus,
                        (SELECT TOP 1 am.SYSTEM_VALUE FROM TB_M_SYSTEM am WHERE am.FUNCTION_ID = 'XPOAMT' AND SYSTEM_CD IN (SELECT op2.POSITION_LEVEL FROM TB_M_ORG_POSITION op2 WHERE op2.LEVEL_ID = op.LEVEL_ID)) MaxAmount,
                        CASE WHEN @sumNewAmount > CAST((SELECT TOP 1 am.SYSTEM_VALUE FROM TB_M_SYSTEM am WHERE am.FUNCTION_ID = 'XPOAMT' AND SYSTEM_CD IN (SELECT op2.POSITION_LEVEL FROM TB_M_ORG_POSITION op2 WHERE op2.LEVEL_ID = op.LEVEL_ID)) AS DECIMAL(18, 4)) THEN 'Y' ELSE 'N' END IsDisplay,
                        se.PERSONNEL_NAME ApproverName,
                        se.NOREG RegNo
                    FROM TB_R_SYNCH_EMPLOYEE se
                    JOIN TB_M_ORG_POSITION op ON se.POSITION_LEVEL = op.POSITION_LEVEL AND 
						NOT EXISTS (SELECT 1 FROM TB_R_WORKFLOW wp INNER JOIN TB_M_SYSTEM am2 ON am2.FUNCTION_ID = 'XPOAMT' AND am2.SYSTEM_CD = wp.APPROVER_POSITION JOIN TB_M_ORG_POSITION op2 ON wp.APPROVER_POSITION = op2.POSITION_LEVEL  WHERE wp.DOCUMENT_NO = @exactPONo AND wp.ITEM_NO = @exactItemNo AND op2.LEVEL_ID = op.LEVEL_ID)
                    JOIN TB_M_SYSTEM st ON op.LEVEL_ID = st.SYSTEM_CD AND st.FUNCTION_ID = @approvalFunctionId
                    WHERE se.DIVISION_ID = @divisionId AND GETDATE() BETWEEN se.VALID_FROM AND VALID_TO AND se.ORG_ID IN (SELECT OrgId FROM @orgRef GROUP BY OrgId)
                    AND CASE WHEN @sumNewAmount > CAST((SELECT TOP 1 am.SYSTEM_VALUE FROM TB_M_SYSTEM am WHERE am.FUNCTION_ID = 'XPOAMT' AND SYSTEM_CD IN (SELECT op2.POSITION_LEVEL FROM TB_M_ORG_POSITION op2 WHERE op2.LEVEL_ID = op.LEVEL_ID)) AS DECIMAL(18, 4)) THEN 'Y' ELSE 'N' END = 'Y'
                ) tmp WHERE DATA_ID = 1
				
                --Note : add bypass checking(if PO Creator is SH/DpH/DH then bypass) --comment cause workflow created by system
                --EXEC [dbo].[sp_worklist_bypassChecking]
                --    @exactPONo,
                --    'PO',
                --    @processId,
                --    @currentUserNoReg,
                --    @orgId,
                --    @positionLevel,
                --    @status OUTPUT

                --IF(@status <> 'SUCCESS')
                --BEGIN
                --    RAISERROR(@status, 16, 1)
                --END

                DECLARE @approvalDt VARCHAR(10) = (SELECT TOP 1 CAST(APPROVED_DT AS VARCHAR) FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @exactPONo AND DOCUMENT_SEQ = 1)
                EXEC [dbo].[sp_worklist_calculateInterval]
                    @exactPONo,
                    @exactItemNo,
                    @approvalDt,
                    1

                -- Update status to the latest even if it's bypassed or not
                DECLARE
                    @lastByPassedStatus VARCHAR(3), @lastApprover VARCHAR(20), @lastDocSeq INT,
                    @nextStatus VARCHAR(3), @nextApprover VARCHAR(20), @nextDocSeq INT

                SELECT @lastApprover = w.APPROVED_BY, @lastByPassedStatus = w.APPROVAL_CD, @lastDocSeq = w.DOCUMENT_SEQ
                FROM TB_R_WORKFLOW w
                JOIN (
                    SELECT DOCUMENT_NO, ISNULL(MAX(DOCUMENT_SEQ), 0) DOCUMENT_SEQ
                    FROM dbo.TB_R_WORKFLOW WHERE DOCUMENT_NO = @exactPONo AND ITEM_NO = @exactItemNo AND APPROVED_BYPASS = @currentUserNoReg
                    GROUP BY DOCUMENT_NO
                ) wd ON w.DOCUMENT_NO = wd.DOCUMENT_NO AND w.DOCUMENT_SEQ = wd.DOCUMENT_SEQ

                SELECT
                    @nextApprover = CASE WHEN @lastByPassedStatus = '43' /* Posting */ THEN @lastApprover ELSE APPROVED_BY END,
                    @nextStatus = CASE WHEN @lastByPassedStatus = '43' /* Posting */ THEN @lastByPassedStatus ELSE APPROVAL_CD END
                FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @exactPONo AND ITEM_NO = @exactItemNo AND DOCUMENT_SEQ = @lastDocSeq + 1

                IF (ISNULL((SELECT SAP_DOC_NO FROM TB_R_PO_H WHERE PO_NO = @exactPONo), '') <> '' AND @nextApprover = '43')
                BEGIN
                    SET @lastByPassedStatus = '44'
                    SET @nextApprover = '44'
                    SET @nextStatus = '44'
                END

                UPDATE TB_R_PO_H SET PO_STATUS = @lastByPassedStatus, PO_NEXT_STATUS = @nextStatus WHERE PO_NO = @exactPONo
                --UPDATE TB_R_PO_ITEM SET PO_STATUS = @lastByPassedStatus, PO_NEXT_STATUS = @nextStatus
            END

            INSERT INTO @process_level VALUES(7)

            SET @message = 'Insert data to TB_M_WORKFLOW where PO_NO: ' + @exactPONo + ': end'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000025', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            DECLARE @pohStat CHAR(2), @pohnextStat CHAR(2)
            --Update Status PO_H based on PO_ITEM status
            IF EXISTS(SELECT 1 FROM TB_R_PO_H WHERE PO_NO = @exactPONo AND PO_STATUS <> PO_NEXT_STATUS)
            BEGIN
                SELECT DISTINCT @pohStat = CAST(MAX(CAST(PO_STATUS AS INT)) AS VARCHAR) FROM TB_R_PO_ITEM WHERE PO_NO = @exactPONo
                SELECT DISTINCT @pohnextStat = CAST(MAX(CAST(PO_NEXT_STATUS AS INT)) AS VARCHAR) FROM TB_R_PO_ITEM WHERE PO_NO = @exactPONo
            END
            ELSE
            BEGIN
                SET @pohStat = '43'
                SET @pohnextStat = '43'
                IF (ISNULL((SELECT SAP_DOC_NO FROM TB_R_PO_H WHERE PO_NO = @exactPONo), '') <> '')
                BEGIN
                    SET @pohStat = '44'
                    SET @pohnextStat = '44'
                END
            END

            UPDATE TB_R_PO_H SET PO_STATUS = ISNULL(@pohStat, @poHeaderStatusCode), PO_NEXT_STATUS = ISNULL(@pohnextStat, @poHeaderNextStatusCode) WHERE PO_NO = @exactPONo
        END

        SELECT @message = 'PO with No: ' + @candidatePONo + ' has been created' 
		SET @MSG_ID = 'MSG0000026'
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        SET @message = 'Finish'
		SET @MSG_ID = 'MSG0000027'
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)

		--COMMIT
		SET @STATUS = @candidatePONo
    END TRY
    BEGIN CATCH
        --ROLLBACK

		declare @error_message VARCHAR(1000) = CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()

		IF EXISTS(SELECT 1 FROM @budgetTransactTemp)
		BEGIN
			SELECT @message = 'Rollback Budget' 
			SET @MSG_ID = 'MSG0000028'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

			DECLARE @po_to_rollback AS TABLE(PO_NO VARCHAR(15), TOTAL DECIMAL(18,6))

			INSERT INTO @po_to_rollback
			SELECT NewDocNo, SUM(TotalAmount) FROm @budgetTransactTemp GROUp BY NewDocNo

			DECLARE @1WBSNo VARCHAR(30), @1RefDocNo VARCHAR(15),
				@1NewDocNo VARCHAR(15), @1Currency VARCHAR(3), @1TotalAmount DECIMAL(18, 6), @1TotalReturnAmount DECIMAL(18, 6) = 0,
				@1MaterialNo VARCHAR(30), @1DocDesc VARCHAR(MAX), @1BmsOperation VARCHAR(50), @currentUser_rollback VARCHAR(50)

			DECLARE db_cursor_bms_rollback CURSOR FOR  
			SELECT WBSNo, RefDocNo, NewDocNo, Currency,SUM(TotalAmount) AS TotalAmount, MaterialNo, DocDesc, BmsOperation FROM @budgetTransactTemp GROUP BY WBSNo, RefDocNo, NewDocNo, Currency, MaterialNo, DocDesc, BmsOperation

			SET @currentUser_rollback = 'rollbackBgPOCatalog'

			OPEN db_cursor_bms_rollback   
			FETCH NEXT FROM db_cursor_bms_rollback INTO @1WBSNo, @1RefDocNo, @1NewDocNo, @1Currency, @1TotalAmount, @1MaterialNo, @1DocDesc, @1BmsOperation
			WHILE @@FETCH_STATUS = 0   
			BEGIN
				BEGIN TRY
					IF (@1BmsOperation = 'NEW_COMMIT')
					BEGIN
						SET @1BmsOperation = 'CANCEL_COMMIT'
						SET @1RefDocNo = @1NewDocNo
						SET @1TotalReturnAmount = @1TotalAmount
					END

					IF (@1BmsOperation = 'CONVERT_COMMIT')
					BEGIN
						SELECT @1TotalReturnAmount = TOTAL FROm @po_to_rollback WHERE PO_NO = @1NewDocNo
						SET @1TotalReturnAmount = @1TotalReturnAmount - @1TotalAmount 
						UPDATE @po_to_rollback SET TOTAL = @1TotalReturnAmount  WHERE PO_NO = @1NewDocNo
					END

					SELECT @message = 'Rollback WBS No: ' + @1WBSNo + ', Reff Doc: '  + ISNULL(@1RefDocNo,'NUL') + ', New Doc: '  + ISNULL(@1NewDocNo,'NUL') + ', Total Amount: '  + CONVERT(VARCHAR, @1TotalAmount) + ', Rollback Amount: '+CONVERT(VARCHAR, @1TotalReturnAmount)+', BMS Operation: ' +@1BmsOperation
					SET @MSG_ID = 'MSG0000029'
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

					EXEC @bmsResponse =
							[BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
								@bmsResponseMessage OUTPUT,
								@currentUser_rollback,
								@1BmsOperation,
								@1WBSNo,
								@1NewDocNo, --@oldPONo, -Tukar old dengan new
								@1RefDocNo, --@poNoForBMS,
								@1Currency,
								@1TotalAmount,
								@1TotalReturnAmount,
								@1MaterialNo,
								@1DocDesc,
								'ECatalogue',
								@additionalAct

					IF ISNULL(@bmsResponse, '0') <> '0' BEGIN RAISERROR(@bmsResponseMessage, 16, 1) END

				END TRY
				BEGIN CATCH
					SET @message = CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
					SET @MSG_ID = 'MSG0000030'
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'ERR', @message, @moduleId, @actionName, @functionId, 4, @currentUser)
				END CATCH
				FETCH NEXT FROM db_cursor_bms_rollback INTO @1WBSNo, @1RefDocNo, @1NewDocNo, @1Currency, @1TotalAmount, @1MaterialNo, @1DocDesc, @1BmsOperation
			END

			CLOSE db_cursor_bms_rollback   
			DEALLOCATE db_cursor_bms_rollback
		END

		SET @MSG_ID = 'EXCEPTION'
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), @MSG_ID, 'ERR', @error_message, @moduleId, @actionName, @functionId, 4, @currentUser)

		SET @STATUS = 'FAILED'
    END CATCH

	SET @message = @error_message;
	IF CURSOR_STATUS('global','db_cursor_bms_rollback') >= -1
	BEGIN
		DEALLOCATE db_cursor_bms_rollback
	END
	IF CURSOR_STATUS('global','db_cursor_quota') >= -1
	BEGIN
		DEALLOCATE db_cursor_quota
	END

	--DECLARE @COUNTER INT = 1, @TOTAL_ROW INT  = 0, @ROW_INDEX INT 
	--SELECT @TOTAL_ROW = COUNT(0) FROM @tmpLog
	--WHILE @COUNTER <= @TOTAL_ROW
	--BEGIN
	--	SELECT @ROW_INDEX = MAX(SEQ_NO)+1 FROM TB_R_LOG_D WHERE PROCESS_ID = @processId

	--	INSERT INTO TB_R_LOG_D
	--	SELECT 
	--		T.PROCESS_ID,
	--		@ROW_INDEX,
	--		T.MESSAGE_ID,
	--		T.MESSAGE_TYPE,
	--		T.MESSAGE_DESC,
	--		T.MODULE_DESC,
	--		T.[USER_NAME],
	--		GETDATE(),
	--		NULL,
	--		NULL
	--	FROM @tmpLog T
	--	WHERE T.ROW_INDEX = @COUNTER

	--	SET @COUNTER = @COUNTER + 1
	--END

	EXEC sp_putLog_Temp @tmpLog
    SET NOCOUNT OFF
END

--select @STATUS
--select * from tb_r_log_d where process_id = @processId