/****** Object:  StoredProcedure [dbo].[sp_GoodReceive_CreateGR]    Script Date: 10/31/2017 10:56:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_GoodReceive_CreateGR]
    @currentUser VARCHAR(50),
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6),
    @grList VARCHAR(MAX),
    @postingDate DATETIME,
    @shortText VARCHAR(MAX)
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = 'sp_GoodReceive_CreateGR',
        @tmpLog LOG_TEMP,
        @itemDelimiter CHAR(1) = ';',
        @listDelimiter CHAR(1) = ',',
        @dataCount INT, @counter INT = 0

    BEGIN TRY
        SET @message = 'I|Start'
        EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0

        BEGIN TRAN CreateGR
		DECLARE @budgetCheck TABLE
        (
            DataNo INT, WBSNo VARCHAR(30), RefDocNo VARCHAR(15),
            NewDocNo VARCHAR(30), BMSOperation VARCHAR(30), Currency VARCHAR(3),
            MatNo VARCHAR(50), ConsumeAmount DECIMAL(18,4), ReturnAmount DECIMAL(18,4)
        )
		DECLARE @budgetCheckTemp TABLE
        (
            DataNo INT, WBSNo VARCHAR(30), RefDocNo VARCHAR(15),
            NewDocNo VARCHAR(30), BMSOperation VARCHAR(30), Currency VARCHAR(3),
            MatNo VARCHAR(50), ConsumeAmount DECIMAL(18,4), ReturnAmount DECIMAL(18,4)
        )
        DECLARE @budgetTransactTemp TABLE
        (
            DataNo INT IDENTITY(1,1), WBSNo VARCHAR(30), RefDocNo VARCHAR(15),
            NewDocNo VARCHAR(30), Currency VARCHAR(3),
            MatNo VARCHAR(50), ConsumeAmount DECIMAL(18,4), ReturnAmount DECIMAL(18,4)
        )

        DECLARE @splittedGRList TABLE ( Idx INT, Split VARCHAR(50) )
        INSERT INTO @splittedGRList
        SELECT [No], Split FROM dbo.SplitString(@grList, @listDelimiter)
        SELECT @dataCount = COUNT(0) FROM @splittedGRList
		--INSERT INTO YHS3 SELECT * FROM @splittedGRList
        DECLARE @itemNoList TABLE ( PONo VARCHAR(11), ItemNo VARCHAR(5) )

        -- Generate GR No
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Generate GR No: begin', @moduleId, @actionName, @functionId, 1, @currentUser)

        DECLARE
            @candidateGRNo VARCHAR(10),
            @numberingPrefix VARCHAR(2),
            @numberingVariant VARCHAR(2),
            @docNumbering VARCHAR(MAX)
        DECLARE @docNumberingMessage TABLE ( Severity VARCHAR(1), [Message] VARCHAR(MAX), GeneratedNo VARCHAR(MAX) )

        SELECT @numberingPrefix = SYSTEM_VALUE, @numberingVariant = '01' FROM TB_M_SYSTEM WHERE FUNCTION_ID = @functionId AND SYSTEM_CD = 'GRPref'
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

        SELECT @candidateGRNo = @numberingPrefix + RTRIM(LTRIM((SELECT TOP 1 GeneratedNo FROM @docNumberingMessage)))
        SET @message = 'I|Generated GR No: ' + @candidateGRNo
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        -- Reserve GR No
        UPDATE TB_M_DOC_NUMBERING SET CURRENT_NUMBER = RIGHT(@candidateGRNo, LEN(@candidateGRNo)-2)
        WHERE NUMBERING_PREFIX = @numberingPrefix AND VARIANT = @numberingVariant

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Generate GR No: end', @moduleId, @actionName, @functionId, 1, @currentUser)

        DECLARE @currency VARCHAR(3) = ''

        WHILE (@counter < @dataCount)
        BEGIN
            DECLARE
                @gr VARCHAR(MAX) = (SELECT Split FROM @splittedGRList WHERE Idx = @counter + 1),
                @poNo VARCHAR(11), @poItemNo VARCHAR(11), @qty DECIMAL(9,3),
                @currentDate DATETIME = (SELECT GETDATE())

            DECLARE @splittedGR TABLE ( Idx INT, Split VARCHAR(50) )

            INSERT INTO @splittedGR
            SELECT [No], Split FROM dbo.SplitString(@gr, @itemDelimiter)

            SELECT
                @poNo = (SELECT Split FROM @splittedGR WHERE Idx = 1),
                @poItemNo = (SELECT Split FROM @splittedGR WHERE Idx = 2),
                @qty = (SELECT Split FROM @splittedGR WHERE Idx = 3)

            DELETE FROM @splittedGR

            -- ExchangeRate
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Get currency rate: begin', @moduleId, @actionName, @functionId, 1, @currentUser)

            DECLARE @currencyRate TABLE ( CurrencyCode VARCHAR(3), ExchangeRate DECIMAL(7,2), ValidFrom DATETIME, ValidTo DATETIME )
            DECLARE @exchangeRate DECIMAL(7,2)
            SELECT @currency = PO_CURR FROM TB_R_PO_H WHERE PO_NO = @poNo
            INSERT INTO @currencyRate EXEC sp_Currency_GetCurrency @currency
            SET @message = 'Bug - Currently applicable currency rate of ''' + ISNULL(@currency, '') + ''' is duplicate'
            IF (SELECT COUNT(0) FROM @currencyRate) > 1 BEGIN RAISERROR(@message, 16, 1) END
            SELECT @exchangeRate = ExchangeRate FROM @currencyRate
            DELETE FROM @currencyRate

            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Get currency rate: end', @moduleId, @actionName, @functionId, 1, @currentUser)

            -- Create GR
            INSERT INTO TB_R_GR_IR
            (PO_NO, PO_ITEM, PO_DT, MAT_DOC_YEAR, MAT_DOC_NO, MAT_DOC_ITEM_NO, DOCUMENT_DT, SPECIAL_STOCK_TYPE, GR_IR_AMOUNT, GR_EXCHANGE_RATE,
            LOCAL_GR_IR_AMOUNT, VENDOR_CD, COMPONENT_PRICE_CD, INVENTORY_FLAG, DELIVERY_NOTE, ACCRUAL_POSTING_FLAG, PO_DETAIL_PRICE, INVOICE_NO, INVOICE_DOC_ITEM, LIV_SEND_FLAG,
            LIV_SPECIAL_TYPE, LIV_SPECIAL_MAT_NO, INVOICE_WO_GR_FLAG, DOCK_CD, KANBAN_ORDER_NO, DELIVERY_NOTE_COMPLETE_FLAG, MATERIAL_NO, SOURCE_TYPE, PRODOCTION_PURPOSE_CD, MATERIAL_DESCRIPTION,
            PLANT_CD, SLOC_CD, UNIT_OF_MEASURE_CD, CANCEL_STATUS, PART_COLOR_SUFFIX, ORI_MATERIAL_NO, BATCH_NO, ITEM_CURRENCY, REF_CANCEL_MAT_DOC_NO, REF_CANCEL_MAT_DOC_YEAR,
            REF_CANCEL_MAT_DOC_ITEM, MOVEMENT_QTY, PACKING_TYPE, CONDITION_CATEGORY, TAX_CD, LIV_SEND_SUPP_FLAG, STATUS_CD, INTERFACE_METHOD, INTERFACE_DT, PLUS_MINUS_FLAG,
            CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT, PO_SUBITEM_NO, HEADER_TEXT, POSTING_DT, SAP_MAT_DOC_NO, SAP_MAT_DOC_YEAR, PROCESS_ID,
            CANCEL_DT, CANCEL_REASON)
            SELECT @poNo, @poItemNo, poh.DOC_DT, YEAR(@currentDate), @candidateGRNo, dbo.GetZeroPaddedNo(5, @counter + 1), @currentDate, NULL,
            CASE WHEN @qty > 0 THEN (@qty / PO_QTY_ORI) * poc.PRICE_AMT ELSE 0 END, @exchangeRate, CASE WHEN @qty > 0 THEN (@qty / PO_QTY_ORI) * poc.PRICE_AMT * @exchangeRate ELSE 0  END, poh.VENDOR_CD,
            poc.COMP_PRICE_CD, 'Y', '', poc.ACCRUAL_FLAG_TYPE, poc.PRICE_AMT, NULL, NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL,
            poi.MAT_NO, NULL, NULL, poi.MAT_DESC, poi.PLANT_CD, poi.SLOC_CD, poi.UOM, 'N', NULL, NULL, NULL, @currency, NULL,
            NULL, NULL, @qty, NULL, poc.CONDITION_CATEGORY, NULL, 'N', '60', NULL, NULL, poc.PLUS_MINUS_FLAG, @currentUser, @currentDate,
            NULL, NULL, NULL, @shortText, @postingDate, NULL, NULL, NULL, NULL, NULL
            FROM TB_R_PO_CONDITION poc
            JOIN TB_R_PO_ITEM poi ON poc.PO_ITEM_NO = poi.PO_ITEM_NO AND poc.PO_NO = poi.PO_NO
            JOIN TB_R_PO_H poh ON poi.PO_NO = poh.PO_NO
            WHERE poc.PO_NO = @poNo AND poc.PO_ITEM_NO = @poItemNo AND @qty > 0

			--- REMARK RUBAH POSISI DIBAWAH SUPAYA Proses Budget bisa diketahuin Kondisi QTY Remain nya
            ---- Update item's qty
            --UPDATE TB_R_PO_ITEM SET PO_QTY_USED = PO_QTY_USED + @qty, PO_QTY_REMAIN = PO_QTY_REMAIN - @qty
            --WHERE PO_NO = @poNo AND PO_ITEM_NO = @poItemNo

			DELETE FROM @itemNoList

            INSERT INTO @itemNoList VALUES (@poNo, @poItemNo)
			
			 -- List down all wbs to consume
			INSERT INTO @budgetCheckTemp
			SELECT (@counter + 1) DataNo,
			WBSNo, RefDocNo, NewDocNo, BMSOperation, Currency, MatNo,
			SUM(ConsumeAmount) ConsumeAmount, SUM(ReturnAmount) ReturnAmount
			FROM (
				SELECT poi.WBS_NO WBSNo, poi.PO_NO + '_001' RefDocNo, @candidateGRNo + '_001' NewDocNo,
				CASE WHEN @qty < poi.PO_QTY_ORI THEN 'CONVERT_CONSUME_PARTIAL' ELSE 'CONVERT_CONSUME' END BMSOperation,
				poh.PO_CURR Currency, '' MatNo,
				@qty * poi.PRICE_PER_UOM ConsumeAmount,
				(poi.PO_QTY_REMAIN - @qty) * poi.PRICE_PER_UOM ReturnAmount
				FROM TB_R_PO_ITEM poi
				JOIN TB_R_PO_H poh ON poi.PO_NO = poh.PO_NO
				WHERE poi.PO_NO = (SELECT TOP 1 PONo FROM @itemNoList) AND poi.PO_ITEM_NO IN (SELECT ItemNo FROM @itemNoList)
			) tmp WHERE 1 = 1 AND NOT(ConsumeAmount <= 0  AND ReturnAmount <= 0)
			GROUP BY tmp.WBSNo, tmp.RefDocNo, tmp.NewDocNo, tmp.BMSOperation, tmp.Currency, tmp.MatNo

			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Update Qty Used & Qty Remain: begin', @moduleId, @actionName, @functionId, 1, @currentUser)
			-- Update item's qty
			UPDATE poi
				SET PO_QTY_USED = PO_QTY_USED + @qty, PO_QTY_REMAIN = PO_QTY_REMAIN - @qty
			FROM TB_R_PO_ITEM poi
			INNER JOIN @itemNoList temp ON temp.PONo = poi.PO_NO AND temp.ItemNo = poi.PO_ITEM_NO

			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Update Qty Used & Qty Remain: end', @moduleId, @actionName, @functionId, 1, @currentUser)

			SET @counter = @counter + 1
        END
	--	INSERT INTO YHS SELECT * FROM @budgetCheck
        DELETE FROM @splittedGRList

		--Jika Ketemu Partial dan Konsum dalam 1 PO, maka anggap semuanya sebagai partial 2017-10-05
		UPDATE temp  SET BMSOperation = 'CONVERT_CONSUME_PARTIAL' 
			FROM @budgetCheckTemp temp WHERE BMSOperation = 'CONVERT_CONSUME'
			AND EXISTS (SELECT 1 FROM @budgetCheckTemp WHERE BMSOperation = 'CONVERT_CONSUME_PARTIAL' AND WBSNo = temp.WBSNo)
			AND EXISTS (SELECT 1 FROM @budgetCheckTemp WHERE BMSOperation = 'CONVERT_CONSUME' AND WBSNo = temp.WBSNo)

		INSERT INTO @budgetCheck
		SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) DataNo,
			WBSNo, RefDocNo, NewDocNo, BMSOperation, Currency, MatNo,
			SUM(ConsumeAmount) ConsumeAmount, SUM(ReturnAmount) ReturnAmount
			FROM @budgetCheckTemp
			GROUP BY WBSNo, RefDocNo, NewDocNo, BMSOperation, Currency, MatNo

        DECLARE
            @poItemGroupedByWBSCount INT = (SELECT COUNT(0) FROM @budgetCheck),
            @bmsResponse VARCHAR(20),
            @bmsResponseMessage VARCHAR(8000),
            @bmsRetryCounter INT = 0,
            @wbsIdx INT = 1,
            @wbsNo VARCHAR(30),
            @consumeAmount DECIMAL(18, 2),
            @returnAmount DECIMAL(18, 2) = NULL,
            @matNo VARCHAR(50),
            @materialNo VARCHAR(30) = '',
            @bmsOperation VARCHAR(30),
            @refDocNo VARCHAR(15),
            @newDocNo VARCHAR(15)
		

        WHILE (@wbsIdx <= @poItemGroupedByWBSCount)
        BEGIN
            SELECT
            @wbsNo = WBSNo,
			@consumeAmount = ConsumeAmount,-- + ISNULL(@consumeAmount, 0),
            @returnAmount = ReturnAmount, -- + isnull(@returnAmount, 0),
            @currency = Currency,
            @matNo = MatNo,
            @refDocNo = RefDocNo,
            @newDocNo = NewDocNo,
            @bmsOperation = BMSOperation
            FROM @budgetCheck WHERE DataNo = @wbsIdx
			--GROUP BY WBSNo,ConsumeAmount,ReturnAmount,Currency,MatNo,RefDocNo,NewDocNo,BMSOperation
		    
		
			DECLARE @bmsOperationTotal AS INT
			SELECT @bmsOperationTotal = COUNT(1) FROM @budgetCheck WHERE BMSOperation = 'CONVERT_CONSUME_PARTIAL'
		
			IF(@bmsOperationTotal > 0)
			SET @bmsOperation = 'CONVERT_CONSUME_PARTIAL'
			ELSE 
			SET @bmsOperation = 'CONVERT_CONSUME'

            SET @message = 'I|Budget ' + @bmsOperation + ' on WBS No: ' + @wbsNo + ' in the amount of: ' + CAST(@consumeAmount AS VARCHAR) + ' in return amount of: ' + CAST(@returnAmount AS VARCHAR) + ' with New Doc No ' + ISNULL(@newDocNo, '') + ' and Ref Doc No' + ISNULL(@refDocNo, '')+ ': begin'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            EXEC @bmsResponse =
                [BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
                    @bmsResponseMessage OUTPUT, @currentUser, @bmsOperation, @wbsNo,
                    @refDocNo, @newDocNo, @currency, @consumeAmount, @returnAmount,
                    @materialNo, @shortText, 'GPS', NULL

            -- NOTE: bmsResponse always 0 or 1 String which means Success or Failed respectively
            WHILE (@bmsResponse = '1' AND @bmsRetryCounter < 3)
            BEGIN
                -- NOTE: if Failed retry in 1 sec and log
                SET @message = 'I|Budget ' + @bmsOperation + ' Failed on WBS No: ' + @wbsNo + ' in the amount of: ' + CAST(@consumeAmount AS VARCHAR) + ' with New Doc No ' + ISNULL(@newDocNo, '') + ' and Ref Doc No' + ISNULL(@refDocNo, '') + ': retry'
                INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

                WAITFOR DELAY '00:00:01'
                EXEC @bmsResponse =
                    [BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
                        @bmsResponseMessage OUTPUT, @currentUser, @bmsOperation, @wbsNo,
                        @refDocNo, @newDocNo, @currency, @consumeAmount, @returnAmount,
                        @materialNo, @shortText, 'GPS', NULL
                SET @bmsRetryCounter = @bmsRetryCounter + 1
            END

            IF @bmsResponse = '1' BEGIN RAISERROR(@bmsResponseMessage, 16, 1) END

            INSERT INTO @budgetTransactTemp VALUES (@wbsNo, @refDocNo, @newDocNo, @currency, @matNo, @returnAmount, @consumeAmount)

            SET @message = 'I|Budget ' + @bmsOperation + ' on WBS No: ' + @wbsNo + ' in the amount of: ' + CAST(@consumeAmount AS VARCHAR) + ' with New Doc No ' + ISNULL(@newDocNo, '') + ' and Ref Doc No' + ISNULL(@refDocNo, '') + ': end'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

			SET @wbsIdx = @wbsIdx + 1
        END
        COMMIT TRAN CreateGR

        SET @message = 'S|' + @candidateGRNo
        EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @processId OUTPUT, 'SUC', 'SUC', @moduleId, @functionId, 2
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
        DECLARE @budgetRollbackCounter INT = 0
        IF (SELECT COUNT(0) FROM @budgetTransactTemp) > 0
        BEGIN
            WHILE (@budgetRollbackCounter < (SELECT COUNT(0) FROM @budgetTransactTemp))
            BEGIN
                SELECT @wbsNo = WBSNo, @consumeAmount = ReturnAmount,
                @returnAmount = ConsumeAmount, @currency = Currency,
                @matNo = MatNo, @refDocNo = RefDocNo, @newDocNo = NewDocNo,
                @bmsOperation = 'CANCEL_CONSUME'
                FROM @budgetTransactTemp WHERE DataNo = (@budgetRollbackCounter + 1)

                EXEC @bmsResponse =
                    [BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
                        @bmsResponseMessage OUTPUT, @currentUser, @bmsOperation, @wbsNo,
                        @refDocNo, @newDocNo, @currency, @consumeAmount, @returnAmount,
                        @materialNo, @shortText, 'GPS', NULL

                IF @bmsResponse = '1'
                BEGIN
                    SET @message = 'E|' + @bmsResponseMessage
                    INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
                END

                SET @budgetRollbackCounter = @budgetRollbackCounter + 1
            END

            DELETE FROM @budgetTransactTemp
        END

        ROLLBACK TRAN CreateGR
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
       -- SET @message = 'E|Error when saving data to GR/SA table'
	   SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
    END CATCH

    EXEC sp_PutLog_Temp @tmpLog
    SET NOCOUNT OFF
    SELECT @message [Message]
END