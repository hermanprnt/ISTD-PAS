
/****** Object:  StoredProcedure [dbo].[sp_POInquiry_Cancel]    Script Date: 8/24/2017 8:52:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_POInquiry_Cancel]
    @currentUser VARCHAR(50),
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6),
    @poNo VARCHAR(11),
	@poStatusRejectByVendor VARCHAR(5) = '49' 
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = 'sp_POInquiry_Cancel',
        @tmpLog LOG_TEMP,
		@return_amount DECIMAL(18, 6)

	DECLARE @budgetTransactTemp TABLE
	(
		DataNo INT IDENTITY(1, 1), WBSNo VARCHAR(30), RefDocNo VARCHAR(15),
		NewDocNo VARCHAR(15), Currency VARCHAR(3), TotalAmount DECIMAL(18, 6), PrevAmount DECIMAL(18, 6),
		MaterialNo VARCHAR(30), DocDesc VARCHAR(MAX), AdditionalAct VARCHAR(1), 
		BmsOperation VARCHAR(20)
	)

    SET NOCOUNT ON
    BEGIN TRY
        EXEC dbo.sp_PutLog 'I|Start', @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0

        BEGIN TRAN CancelPO

        SET @message = 'I|Update TB_R_PO_H where PO_NO: ' + @poNo + ' :begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        UPDATE TB_R_PO_H SET PO_STATUS = @poStatusRejectByVendor WHERE PO_NO = @poNo

        SET @message = 'I|Update TB_R_PO_H where PO_NO: ' + @poNo + ' :end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        SET @message = 'I|Update TB_R_WORKFLOW where DOC_NO: ' + @poNo + ' :begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        --UPDATE TB_R_WORKFLOW SET IS_CANCELLED = 'Y' WHERE DOCUMENT_NO = @poNo
        DELETE FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @poNo

        SET @message = 'I|Update TB_R_WORKFLOW where DOC_NO: ' + @poNo + ' :end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Rolling back qty to PR :begin', @moduleId, @actionName, @functionId, 1, @currentUser)

		DECLARE @checkpartialpr TABLE (PR_NO VARCHAR(30),WBSNo VARCHAR(30), Found_Partial int)

		INSERT INTO @checkpartialpr
		SELECT  pri2.PR_NO, pri2.WBS_NO, COUNT(0) 
		FROM TB_R_PR_ITEM pri2 
		WHERE pri2.PR_NO IN (SELECT DISTINCT(pri.PR_NO) FROM TB_R_PO_ITEM poi JOIN TB_R_PR_ITEM pri ON poi.PO_NO = @poNo AND poi.PR_NO = pri.PR_NO AND poi.PR_ITEM_NO = pri.PR_ITEM_NO) 
			AND ISNULL(pri2.OPEN_QTY,'') > 0 AND pri2.WBS_NO <> 'X' AND pri2.ITEM_CLASS = 'M'
		GROUP BY pri2.PR_NO, pri2.WBS_NO
		UNION ALL
		SELECT  pri2.PR_NO, prs2.WBS_NO, COUNT(0) 
		FROM TB_R_PR_ITEM pri2 
		JOIN TB_R_PR_SUBITEM prs2 ON prs2.PR_NO = pri2.PR_NO AND prs2.PR_ITEM_NO = pri2.PR_ITEM_NO
		WHERE pri2.PR_NO IN (SELECT DISTINCT(pri.PR_NO) FROM TB_R_PO_ITEM poi JOIN TB_R_PR_ITEM pri ON poi.PO_NO = @poNo AND poi.PR_NO = pri.PR_NO AND poi.PR_ITEM_NO = pri.PR_ITEM_NO) 
			AND ISNULL(pri2.OPEN_QTY,'') > 0  AND pri2.WBS_NO = 'X' AND pri2.ITEM_CLASS = 'S'
		GROUP BY pri2.PR_NO, prs2.WBS_NO

		UPDATE TB_R_PO_H SET PROCESS_ID = NULL WHERE PO_NO = @poNo

        MERGE INTO TB_R_PR_ITEM pri USING (
            SELECT poi.PR_NO, poi.PR_ITEM_NO, SUM(poi.PO_QTY_ORI) PO_QTY_ORI
            FROM TB_R_PO_ITEM poi LEFT JOIN TB_R_ASSET ass ON poi.PO_NO = ass.PO_NO AND poi.PO_ITEM_NO = ass.PO_ITEM_NO
            WHERE poi.PO_NO = @poNo
            GROUP BY poi.PR_NO, poi.PR_ITEM_NO
        ) tmp ON pri.PR_NO = tmp.PR_NO AND pri.PR_ITEM_NO = tmp.PR_ITEM_NO
        WHEN MATCHED THEN
        UPDATE SET
        pri.OPEN_QTY = pri.OPEN_QTY + tmp.PO_QTY_ORI,
        pri.USED_QTY = pri.USED_QTY - tmp.PO_QTY_ORI,
		--Delete PO NO by YHS 25-11-2016
		pri.PO_NO = ''
        ;

        MERGE INTO TB_R_ASSET ass USING (
            SELECT poi.PR_NO, poi.PR_ITEM_NO, poi.PO_NO, poi.PO_ITEM_NO, ISNULL(ass.ASSET_NO, '') ASSET_NO
            FROM TB_R_PO_ITEM poi LEFT JOIN TB_R_ASSET ass ON poi.PO_NO = ass.PO_NO AND poi.PO_ITEM_NO = ass.PO_ITEM_NO
            WHERE poi.PO_NO = @poNo
        ) tmp ON ass.PR_NO = tmp.PR_NO AND ass.PR_ITEM_NO = tmp.PR_ITEM_NO
        AND ass.PO_NO = tmp.PO_NO AND ass.PO_ITEM_NO = tmp.PO_ITEM_NO
        AND ass.ASSET_NO = tmp.ASSET_NO
        WHEN MATCHED THEN
        UPDATE SET
        ass.PO_NO = NULL, ass.PO_ITEM_NO = NULL
        ;

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Rolling back qty to PR :end', @moduleId, @actionName, @functionId, 1, @currentUser)

		IF EXISTS(SELECT 1 FROM TB_R_PO_H WHERE PO_NO = @poNo AND SYSTEM_SOURCE = 'GPS')
		BEGIN
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Rolling back budget to PR :begin', @moduleId, @actionName, @functionId, 1, @currentUser)

			DECLARE @isPOManual BIT = (SELECT CASE WHEN COUNT(0) > 0 THEN 1 ELSE 0 END FROM TB_R_PO_ITEM WHERE PO_NO = @poNo AND ISNULL(PR_NO, '') = '' AND ISNULL(PR_ITEM_NO, '') = '')
			DECLARE
				@wbsIdx INT = 1,
				@poItemGroupedByWBSCount INT,
				@oldDocNo VARCHAR(15) = NULL,
				@totalAmount DECIMAL(18, 2), -- NOTE: BMS accept DECIMAL(18,2)
				@prevAmount DECIMAL(18, 2), -- NOTE: BMS accept DECIMAL(18,2)
				@materialNo VARCHAR(30) = '',
				@wbsNo VARCHAR(30),
				@bmsOperation VARCHAR(20),
				@bmsResponse VARCHAR(20),
				@bmsResponseMessage VARCHAR(8000),
				@bmsRetryCounter INT = 0,
				@currency VARCHAR(3),
				@cancelDesc VARCHAR(MAX),
				@additionalAct VARCHAR(1)

			SELECT @bmsOperation = CASE @isPOManual WHEN 1 THEN 'CANCEL_COMMIT' ELSE 'REV_COMMIT' END,
				   @additionalAct = CASE @isPOManual WHEN 1 THEN '' ELSE 'R' END

			DECLARE @budgetCheck TABLE (DATA_NO INT, PO_NO VARCHAR(30), PR_NO VARCHAR(30), WBS_NO VARCHAR(30), CURR_CD VARCHAR(10), TOTAL_AMOUNT DECIMAL(18, 6))
			IF(@bmsOperation = 'REV_COMMIT')
			BEGIN
				INSERT INTO @budgetCheck
				SELECT ROW_NUMBER() OVER (ORDER BY dt.PR_NO ASC),
					   @poNo,
					   dt.PR_NO,
					   dt.WBS_NO,
					   dt.ORI_CURR_CD,
					   SUM(ISNULL(dt.AMOUNT, 0))
				FROM (
					SELECT poi.PR_NO, poi.WBS_NO, pri.ORI_CURR_CD, ISNULL(SUM(ISNULL(poi.ORI_AMOUNT,0)), 0) AMOUNT
							FROM TB_R_PO_ITEM poi JOIN TB_R_PR_ITEM pri ON poi.PO_NO = @poNo AND poi.PR_NO = pri.PR_NO AND poi.PR_ITEM_NO = pri.PR_ITEM_NO AND poi.WBS_NO <> 'X' AND poi.ITEM_CLASS = 'M'
							GROUP BY poi.PR_NO, poi.WBS_NO, pri.ORI_CURR_CD
					UNION
					SELECT poi.PR_NO, prs.WBS_NO, pri.ORI_CURR_CD, ISNULL(SUM(ISNULL(prs.ORI_AMOUNT,0)), 0) AMOUNT
							FROM TB_R_PO_ITEM poi 
								JOIN TB_R_PR_ITEM pri ON poi.PO_NO = @poNo AND poi.PR_NO = pri.PR_NO AND poi.PR_ITEM_NO = pri.PR_ITEM_NO AND poi.WBS_NO = 'X'  AND poi.ITEM_CLASS = 'S'
								JOIN TB_R_PR_SUBITEM prs ON pri.PR_NO = prs.PR_NO AND pri.PR_ITEM_NO = prs.PR_ITEM_NO
							GROUP BY poi.PR_NO, prs.WBS_NO, pri.ORI_CURR_CD
				)dt GROUP BY dt.PR_NO, dt.WBS_NO, dt.ORI_CURR_CD
			END
			ELSE
			BEGIN
				INSERT INTO @budgetCheck
				SELECT ROW_NUMBER() OVER (ORDER BY dt.WBS_NO ASC),
					   @poNo,
					   '',
					   dt.WBS_NO,
					   dt.PO_CURR,
					   SUM(ISNULL(dt.AMOUNT, 0))
				FROM (
					SELECT poi.WBS_NO, poh.PO_CURR, ISNULL(SUM(ISNULL(poi.ORI_AMOUNT, 0)), 0) AMOUNT
							FROM TB_R_PO_ITEM poi JOIN TB_R_PO_H poh ON poi.PO_NO = poh.PO_NO AND poh.PO_NO = @poNo AND poi.WBS_NO <> 'X' AND poi.ITEM_CLASS = 'M'
							GROUP BY poi.WBS_NO, poh.PO_CURR
					UNION
					SELECT pos.WBS_NO, poh.PO_CURR, ISNULL(SUM(ISNULL(pos.ORI_AMOUNT, 0)), 0) AMOUNT
							FROM TB_R_PO_ITEM poi 
								JOIN TB_R_PO_H poh ON poi.PO_NO = poh.PO_NO AND poh.PO_NO = @poNo AND poi.WBS_NO = 'X' AND poi.ITEM_CLASS = 'S'
								JOIN TB_R_PO_SUBITEM pos ON poi.PO_NO = pos.PO_NO AND poi.PO_ITEM_NO = pos.PO_ITEM_NO
							GROUP BY pos.WBS_NO, poh.PO_CURR
				)dt GROUP BY dt.WBS_NO, dt.PO_CURR
			END

			DECLARE @return_wbs AS TABLE(WBS_NO VARCHAR(30), RETURN_AMOUNT DECIMAL(18, 6))

			INSERT INTO @return_wbs
			SELECT  WBS_NO,SUM(TOTAL_AMOUNT) FROM
				(
				SELECT WBS_NO, ISNULL(SUM(poi.ORI_AMOUNT),0) AS TOTAL_AMOUNT
					FROM TB_R_PO_ITEM poi WHERE  PO_NO  = @poNo  AND poi.WBS_NO <> 'X' AND poi.ITEM_CLASS = 'M' GROUp BY WBS_NO
				UNION ALL
				SELECT pos.WBS_NO, ISNULL(SUM(pos.ORI_AMOUNT),0) AS TOTAL_AMOUNT
					FROM TB_R_PO_ITEM poi 
					JOIN TB_R_PO_SUBITEM pos ON poi.PO_NO = pos.PO_NO AND poi.PO_ITEM_NO = pos.PO_ITEM_NO 
					WHERE  poi.PO_NO  = @poNo  AND poi.WBS_NO = 'X'  AND poi.ITEM_CLASS = 'S' GROUp BY pos.WBS_NO
				)dx GROUp BY WBS_NO

			SELECT @poItemGroupedByWBSCount = ISNULL(MAX(DATA_NO), 0) FROM @budgetCheck
		
			DECLARE @newDocNo VARCHAR(15),  @pr_no VARCHAR(10)
			WHILE (@wbsIdx <= @poItemGroupedByWBSCount)
			BEGIN
				SELECT @oldDocNo = PO_NO + '_001', 
					   @newDocNo = PR_NO + CASE WHEN(PR_NO IS NOT NULL) THEN '_001' ELSE '' END, 
					   @wbsNo = WBS_NO, 
					   @currency = CURR_CD,
					   @totalAmount = TOTAL_AMOUNT,
					   @pr_no = PR_NO
				FROM @budgetCheck WHERE DATA_NO = @wbsIdx
							
				IF(@bmsOperation = 'REV_COMMIT')
				BEGIN
					SELECT @cancelDesc = PR_DESC FROM TB_R_PR_H WHERE PR_NO = SUBSTRING(@newDocNo, 1, CHARINDEX('_001', @newDocNo, 1)-1)
					SELECT @bmsOperation = CASE WHEN EXISTS(SELECT 1 FROM @checkpartialpr WHERE PR_NO = @pr_no  AND WBSNo = @wbsNo AND Found_Partial > 0) THEN 'CONVERT_COMMIT' ELSE @bmsOperation END
					SET @return_amount = 0
				END 
				ELSE IF(@bmsOperation = 'CONVERT_COMMIT')
				BEGIN
					SELECT @cancelDesc = PR_DESC FROM TB_R_PR_H WHERE PR_NO = @pr_no
					SELECT @bmsOperation = CASE WHEN EXISTS(SELECT 1 FROM @checkpartialpr WHERE PR_NO = @pr_no  AND WBSNo = @wbsNo AND Found_Partial > 0) THEN 'CONVERT_COMMIT' ELSE @bmsOperation END
				END
				ELSE
				BEGIN
					SELECT @cancelDesc = PO_DESC FROM TB_R_PO_H WHERE PO_NO = @poNo
				END

				--For handling Create PO partial from more then 1 item PR
				IF (@bmsOperation = 'CONVERT_COMMIT' AND @pr_no IS NOT NULL )
				BEGIN
					IF EXISTS(SELECT 1 FROM @checkpartialpr WHERE PR_NO = @pr_no AND WBSNo = @wbsNo AND Found_Partial > 0)
					BEGIN
						DECLARE @budgetpartialCheck TABLE (DATA_NO INT, PR_NO VARCHAR(30), WBS_NO VARCHAR(30), CURR_CD VARCHAR(10), TOTAL_AMOUNT DECIMAL(18, 6), BUDGET_REF VARCHAR(5) )
						DELETE FROM @budgetpartialCheck
						INSERT INTO @budgetpartialCheck
						SELECT ROW_NUMBER() OVER (ORDER BY dt.PR_NO ASC),
							   dt.PR_NO,
							   dt.WBS_NO,
							   dt.ORI_CURR_CD,
							   SUM(ISNULL(dt.AMOUNT, 0))-@totalAmount,
							   BUDGET_REF
						FROM (
							SELECT pri.PR_NO, pri.WBS_NO, pri.ORI_CURR_CD, ISNULL(SUM(pri.PRICE_PER_UOM*pri.OPEN_QTY), 0) AMOUNT, BUDGET_REF
									from TB_R_PR_ITEM pri WHERE pri.PR_NO = @pr_no AND pri.WBS_NO <> 'X' AND pri.ITEM_CLASS = 'M' AND pri.WBS_NO = @wbsNo 
									GROUP BY pri.PR_NO, pri.WBS_NO, pri.ORI_CURR_CD, BUDGET_REF
							UNION
							SELECT pri.PR_NO, prs.WBS_NO, pri.ORI_CURR_CD, ISNULL(SUM(prs.PRICE_PER_UOM*pri.OPEN_QTY), 0) AMOUNT, BUDGET_REF
									from TB_R_PR_ITEM pri
										JOIN TB_R_PR_SUBITEM prs ON pri.PR_NO = prs.PR_NO AND pri.PR_ITEM_NO = prs.PR_ITEM_NO
									 WHERE pri.PR_NO = @pr_no AND pri.WBS_NO = 'X'  AND pri.ITEM_CLASS = 'S'  AND prs.WBS_NO = @wbsNo
									GROUP BY pri.PR_NO, prs.WBS_NO, pri.ORI_CURR_CD, BUDGET_REF
						)dt GROUP BY dt.PR_NO, dt.WBS_NO, dt.ORI_CURR_CD, BUDGET_REF


						declare @prItemGroupedByWBSCount int, @wbsprIdx int = 1
						SELECT @prItemGroupedByWBSCount = ISNULL(MAX(DATA_NO), 0) FROM @budgetpartialCheck

						DECLARE @newPartialDocNo VARCHAR(15), @wbsNoPartial VARCHAR(30), @currencyPartial VARCHAR(3), @totalAmountPartial DECIMAL(18, 2)
						WHILE (@wbsprIdx <= @prItemGroupedByWBSCount)
						BEGIN
							SELECT @newPartialDocNo = PR_NO +'_'+ CASE WHEN(PR_NO IS NOT NULL) THEN BUDGET_REF ELSE '' END, 
								   @wbsNoPartial = WBS_NO, 
								   @currencyPartial = CURR_CD,
								   @totalAmountPartial = TOTAL_AMOUNT
							FROM @budgetpartialCheck WHERE DATA_NO = @wbsprIdx

							IF(@totalAmountPartial>0)
							BEGIN
								SET @message = 'I|Budget CANCEL_COMMIT for partial PO on WBS No: ' + @wbsNoPartial + ' with Doc No ' + ISNULL(@newPartialDocNo, 'NULL') + ', Currency Cd ' + @currencyPartial + ' Amount ' + CAST(@totalAmountPartial AS VARCHAR) 
								INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
							
								EXEC @bmsResponse =
									[BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
										@bmsResponseMessage OUTPUT, @currentUser, 'CANCEL_COMMIT', @wbsNoPartial, @newPartialDocNo, @newPartialDocNo,
										@currencyPartial, @totalAmountPartial, 0, @materialNo, @cancelDesc, 'GPS', @additionalAct

								WHILE (@bmsResponse = '1' AND @bmsRetryCounter < 3)
								BEGIN
									-- NOTE: if Failed retry in 1 sec and log
									SET @message = 'I|Budget CANCEL_COMMIT  for partial PO Failed on WBS No: ' + @wbsNoPartial + ' with New Doc No ' + ISNULL(@newPartialDocNo, 'NULL') + ', Currency Cd ' + @currencyPartial + ' Amount ' + CAST(@totalAmountPartial AS VARCHAR)  + ': retry'
									INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

									WAITFOR DELAY '00:00:01'
									EXEC @bmsResponse =
									[BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
										@bmsResponseMessage OUTPUT, @currentUser, 'CANCEL_COMMIT', @wbsNoPartial, @newPartialDocNo, @newPartialDocNo,
										@currencyPartial, @totalAmountPartial, 0, @materialNo, @cancelDesc, 'GPS', @additionalAct

									SET @bmsRetryCounter = @bmsRetryCounter + 1
								END

								IF ISNULL(@bmsResponse, '0') <> '0' BEGIN RAISERROR(@bmsResponseMessage, 16, 1) END

								INSERT INTO @budgetTransactTemp VALUES (@wbsNoPartial, @newPartialDocNo, @newPartialDocNo, @currencyPartial, @totalAmountPartial, @totalAmount, @materialNo, @cancelDesc, @additionalAct, 'CANCEL_COMMIT')
							END
							
							UPDATE @return_wbs SET RETURN_AMOUNT = RETURN_AMOUNT - @totalAmount WHERE WBS_NO = @wbsNo
							SELECT @return_amount = RETURN_AMOUNT  FROM @return_wbs where WBS_NO = @wbsNo
							
							SET @totalAmount = @totalAmount + @totalAmountPartial
							SET @bmsRetryCounter = 0
							SET @wbsprIdx = @wbsprIdx + 1
						END
					END
				END

				SET @message = 'I|Budget ' + @bmsOperation + ' on WBS No: ' + @wbsNo + ' with New Doc No ' + ISNULL(@newDocNo, 'NULL') + ', Currency Cd ' + @currency + ' Amount ' + CAST(@totalAmount AS VARCHAR) + ' and Ref Doc No' + ISNULL(@oldDocNo, 'NULL')
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

				EXEC @bmsResponse =
				    [BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
				        @bmsResponseMessage OUTPUT, @currentUser, @bmsOperation, @wbsNo, @oldDocNo, @newDocNo,
				        @currency, @totalAmount, @return_amount, @materialNo, @cancelDesc, 'GPS', @additionalAct

				-- NOTE: bmsResponse always 0 or 1 String which means Success or Failed respectively
				WHILE (@bmsResponse = '1' AND @bmsRetryCounter < 3)
				BEGIN
					-- NOTE: if Failed retry in 1 sec and log
					SET @message = 'I|Budget ' + @bmsOperation + ' Failed on WBS No: ' + @wbsNo + ' with New Doc No ' + ISNULL(@newDocNo, 'NULL') + ', Currency Cd ' + @currency + ' Amount ' + CAST(@totalAmount AS VARCHAR) + ' and Ref Doc No' + ISNULL(@oldDocNo, 'NULL') + ': retry'
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

					WAITFOR DELAY '00:00:01'
					EXEC @bmsResponse =
					    [BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
					        @bmsResponseMessage OUTPUT, @currentUser, @bmsOperation, @wbsNo, @oldDocNo, @newDocNo,
							@currency, @totalAmount, @return_amount, @materialNo, @cancelDesc, 'GPS', @additionalAct

					SET @bmsRetryCounter = @bmsRetryCounter + 1
				END

				IF ISNULL(@bmsResponse, '0') <> '0' BEGIN RAISERROR(@bmsResponseMessage, 16, 1) END

				INSERT INTO @budgetTransactTemp VALUES (@wbsNo, @oldDocNo, @newDocNo, @currency, @totalAmount, 0, @materialNo, @cancelDesc, @additionalAct, @bmsOperation)
				
				SET @message = 'I|Budget ' + @bmsOperation + ' on WBS No: ' + @wbsNo + ' with New Doc No ' + ISNULL(@newDocNo, 'NULL') + ' and Ref Doc No' + ISNULL(@oldDocNo, 'NULL') + ' : end'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
				
				SET @wbsIdx = @wbsIdx + 1
			END

			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Rolling back budget to PR :end', @moduleId, @actionName, @functionId, 1, @currentUser)
		END

        -- Clear Temp table
        SET @message = 'I|Delete data from TB_T_PO_H where CREATED_BY = ' + @currentUser + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        DELETE FROM TB_T_PO_H WHERE CREATED_BY = @currentUser AND ISNULL(PO_NO, '') = @poNo

        SET @message = 'I|Delete data from TB_T_PO_H where CREATED_BY = ' + @currentUser + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

		SET @message = 'I|Delete data from TB_T_PO_ITEM where CREATED_BY = ' + @currentUser + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        DELETE FROM TB_T_PO_ITEM WHERE CREATED_BY = @currentUser AND ISNULL(PO_NO, '') = @poNo

        SET @message = 'I|Delete data from TB_T_PO_ITEM where CREATED_BY = ' + @currentUser + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        SET @message = 'I|Delete data from TB_T_PO_SUBITEM where CREATED_BY = ' + @currentUser + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        DELETE FROM TB_T_PO_SUBITEM WHERE CREATED_BY = @currentUser AND ISNULL(PO_NO, '') = @poNo

        SET @message = 'I|Delete data from TB_T_PO_SUBITEM where CREATED_BY = ' + @currentUser + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        SET @message = 'I|Delete data from TB_T_PO_CONDITION where CREATED_BY = ' + @currentUser + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        DELETE FROM TB_T_PO_CONDITION WHERE CREATED_BY = @currentUser AND ISNULL(PO_NO, '') = @poNo

        SET @message = 'I|Delete data from TB_T_PO_CONDITION where CREATED_BY = ' + @currentUser + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        COMMIT TRAN CancelPO

        SET @message = 'S|Finish'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
        IF EXISTS(SELECT 1 FROM TB_R_PO_H WHERE PO_NO = @poNo AND SYSTEM_SOURCE = 'GPS')
		BEGIN
			SET @message = 'I|Rolling back budget started'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
			DECLARE @counter INT = 0, @oldDocNo_rollback VARCHAR(15)

			IF (SELECT COUNT(0) FROM @budgetTransactTemp) > 0
			BEGIN
				WHILE (@counter < (SELECT COUNT(0) FROM @budgetTransactTemp))
				BEGIN
					DECLARE @oldPONo VARCHAR(20), @poDesc VARCHAR(200)
					SELECT
						@wbsNo = WBSNo, 
						@oldPONo = CASE WHEN @isPOManual = 1 THEN NewDocNo ELSE RefDocNo END,
						@bmsOperation = CASE WHEN BmsOperation = 'CANCEL_COMMIT' THEN 'CONVERT_COMMIT' ELSE 'CANCEL_COMMIT' END,
						@newDocNo = NewDocNo, 
						@currency = Currency, 
						@totalAmount = TotalAmount,
						@prevAmount = PrevAmount,
						@materialNo = MaterialNo, 
						@poDesc = DocDesc,
						@oldDocNo_rollback = CASE WHEN BmsOperation = 'CANCEL_COMMIT' THEN RefDocNo ELSE @oldDocNo END
					FROM @budgetTransactTemp WHERE DataNo = (@counter + 1)


					SET @message = 'I|Rolling back budget for WBS No ' + @wbsNo + ' Ref Doc No ' + ISNULL(@oldDocNo_rollback, 'NULL') + ' New Doc No ' + ISNULL(@newDocNo, NULL) + ' Currency ' + @currency + ' from Amount ' + CAST(@totalAmount AS VARCHAR) +  ' to Amount ' + CAST(@prevAmount AS VARCHAR) + ' started'
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)


					EXEC @bmsResponse =
						[BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
							@bmsResponseMessage OUTPUT, @currentUser, @bmsOperation, @wbsNo,  @oldDocNo_rollback, @newDocNo,
								@currency, @totalAmount, 0, @materialNo, @cancelDesc, 'PAS', NULL

					SET @message = 'I|Rolling back budget for WBS No ' + @wbsNo + ' Ref Doc No ' + ISNULL(@oldDocNo_rollback, 'NULL') + ' New Doc No ' + ISNULL(@newDocNo, NULL) + ' Currency ' + @currency + ' from Amount ' + CAST(@totalAmount AS VARCHAR) +  ' to Amount ' + CAST(@prevAmount AS VARCHAR) + '  : end'
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

					/*
					-- For debugging purposes
					SELECT @bmsOperation CommitOperation, CASE @bmsResponse WHEN '0' THEN 'Success' WHEN '1' THEN 'Failed' END CommitResult, @bmsResponseMessage CommitMessage
					EXEC sp_Util_BudgetMonitor @wbsNo
					*/

					IF ISNULL(@bmsResponse, '0') <> '0'
					BEGIN
						SET @message = 'E|' + @bmsResponseMessage
						INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
					END

					SET @counter = @counter + 1
				END
				DELETE FROM @budgetTransactTemp
			END
			ROLLBACK TRAN CancelPO
		END
		SET @message = 'I|Rolling back budget finished'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 2, @currentUser)

        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
    END CATCH

	UPDATE TB_R_PO_H SET PROCESS_ID = NULL WHERE PO_NO = @poNo AND PROCESS_ID = @processId
	DELETE FROM TB_T_LOCK WHERE PROCESS_ID = @processId

    EXEC sp_putLog_Temp @tmpLog
    SET NOCOUNT OFF
    SELECT @message
END