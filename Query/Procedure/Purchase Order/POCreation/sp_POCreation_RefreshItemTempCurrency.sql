CREATE PROCEDURE [dbo].[sp_POCreation_RefreshItemTempCurrency]
    @currentUser VARCHAR(50),
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6),
    @currency VARCHAR(3)
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = 'sp_POCreation_RefreshItemTempCurrency',
        @tmpLog LOG_TEMP

    SET NOCOUNT ON
    BEGIN TRY
        EXEC dbo.sp_PutLog 'I|Start', @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0

        BEGIN TRAN Refresh

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Get currency rate: begin', @moduleId, @actionName, @functionId, 1, @currentUser)

        DECLARE @currencyRate TABLE ( CurrencyCode VARCHAR(3), ExchangeRate DECIMAL(7,2), ValidFrom DATETIME, ValidTo DATETIME )
        DECLARE @currentExchangeRate DECIMAL(7,2), @currentCurrency VARCHAR(3) = (SELECT TOP 1 CURR_CD FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId AND DELETE_FLAG = 'N')
        INSERT INTO @currencyRate EXEC sp_Currency_GetCurrency @currentCurrency
        IF (SELECT COUNT(0) FROM @currencyRate) > 1 BEGIN RAISERROR('Bug - Currently applicable currency rate is duplicate', 16, 1) END
        SELECT @currentExchangeRate = ExchangeRate FROM @currencyRate
        DELETE FROM @currencyRate

        IF (@currentCurrency <> @currency)
        BEGIN
            DECLARE @exchangeRate DECIMAL(7,2)
            INSERT INTO @currencyRate EXEC sp_Currency_GetCurrency @currency
            IF (SELECT COUNT(0) FROM @currencyRate) > 1 BEGIN RAISERROR('Bug - Currently applicable currency rate is duplicate', 16, 1) END
            SELECT @exchangeRate = ExchangeRate FROM @currencyRate

            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Get currency rate: end', @moduleId, @actionName, @functionId, 1, @currentUser)

            DECLARE @poItemRef TABLE
            (
                DataNo INT IDENTITY(1,1), ProcessId BIGINT, PONo VARCHAR(11), POItemNo VARCHAR(5),
                SeqItemNo VARCHAR(5), CalculationScheme VARCHAR(4), Qty DECIMAL(7,2), Price DECIMAL(18,4),
                ItemClass VARCHAR(1), NewPrice DECIMAL(18,4), NewAmount DECIMAL(18,4), NewLocalAmount DECIMAL(18,4)
            )

            INSERT INTO @poItemRef
            SELECT poit.PROCESS_ID, poit.PO_NO, poit.PO_ITEM_NO, poit.SEQ_ITEM_NO, valc.CALCULATION_SCHEME_CD,
                poit.PO_QTY_REMAIN, poit.NEW_PRICE_PER_UOM, poit.ITEM_CLASS, (poit.NEW_PRICE_PER_UOM * @currentExchangeRate) / @exchangeRate,
                poit.PO_QTY_REMAIN * ((poit.NEW_PRICE_PER_UOM * @currentExchangeRate) / @exchangeRate),
                poit.PO_QTY_REMAIN * (poit.NEW_PRICE_PER_UOM * @currentExchangeRate)
            FROM TB_T_PO_ITEM poit JOIN TB_M_VALUATION_CLASS valc ON poit.VALUATION_CLASS = valc.VALUATION_CLASS
            WHERE poit.PROCESS_ID = @processId AND poit.ITEM_CLASS = 'M' AND poit.DELETE_FLAG = 'N'
            UNION
            SELECT poit.PROCESS_ID, poit.PO_NO, poit.PO_ITEM_NO, poit.SEQ_ITEM_NO, valc.CALCULATION_SCHEME_CD, poit.PO_QTY_REMAIN,
                SUM(posit.PRICE_PER_UOM) NEW_PRICE_PER_UOM, poit.ITEM_CLASS,
                (SUM(posit.PRICE_PER_UOM) * @currentExchangeRate) / @exchangeRate,
                poit.PO_QTY_REMAIN * ((SUM(posit.PRICE_PER_UOM) * @currentExchangeRate) / @exchangeRate),
                poit.PO_QTY_REMAIN * (SUM(posit.PRICE_PER_UOM) * @currentExchangeRate)
            FROM TB_T_PO_ITEM poit JOIN TB_T_PO_SUBITEM posit
            ON poit.PROCESS_ID = posit.PROCESS_ID AND ISNULL(poit.PO_NO, '') = ISNULL(posit.PO_NO, '')
                AND ISNULL(poit.PO_ITEM_NO, '') = ISNULL(posit.PO_ITEM_NO, '') AND poit.SEQ_ITEM_NO = posit.SEQ_ITEM_NO
            JOIN TB_M_VALUATION_CLASS valc ON poit.VALUATION_CLASS = valc.VALUATION_CLASS
            WHERE poit.PROCESS_ID = @processId AND poit.ITEM_CLASS = 'S' AND poit.DELETE_FLAG = 'N'
            GROUP BY poit.PROCESS_ID, poit.PO_NO, poit.PO_ITEM_NO, poit.SEQ_ITEM_NO,
                valc.CALCULATION_SCHEME_CD, poit.PO_QTY_REMAIN, poit.ITEM_CLASS

            MERGE INTO TB_T_PO_ITEM poit USING @poItemRef poitr
            ON poit.PROCESS_ID = poitr.ProcessId AND ISNULL(poit.PO_NO, '') = ISNULL(poitr.PONo, '')
            AND ISNULL(poit.PO_ITEM_NO, '') = ISNULL(poitr.POItemNo, '') AND poit.SEQ_ITEM_NO = poitr.SeqItemNo
            WHEN MATCHED THEN
            UPDATE SET
            poit.CURR_CD = @currency, poit.NEW_PRICE_PER_UOM = NewPrice,
            poit.NEW_AMOUNT = NewAmount, poit.NEW_LOCAL_AMOUNT = NewLocalAmount,
            poit.UPDATE_FLAG = 'Y', poit.CHANGED_DT = GETDATE(), poit.CHANGED_BY = @currentUser
            ;

            UPDATE TB_T_PO_H SET
            NEW_CURR_CD = @currency, NEW_EXCHANGE_RATE = @exchangeRate,
            NEW_AMOUNT = (SELECT SUM(NewAmount) FROM @poItemRef),
            NEW_LOCAL_AMOUNT = (SELECT SUM(NewLocalAmount) FROM @poItemRef),
            UPDATE_FLAG = 'Y', CHANGED_DT = GETDATE(), CHANGED_BY = @currentUser
            WHERE PROCESS_ID = @processId AND ISNULL(PO_NO, '') = (SELECT TOP 1 ISNULL(PONo, '') FROM @poItemRef)

            DECLARE @dataCount INT = (SELECT COUNT(0) FROM @poItemRef), @counter INT = 1
            DECLARE @calculationRef CALC_COMP_PRICE

            WHILE @counter <= @dataCount
            BEGIN
                DECLARE @poNo VARCHAR(11), @poItemNo VARCHAR(5), @seqItemNo INT, @calcScheme VARCHAR(4), @itemQty DECIMAL(9,4), @basePrice DECIMAL(18,4)
                SELECT @poNo = PONo, @poItemNo = POItemNo, @seqItemNo = SeqItemNo, @calcScheme = CalculationScheme, @itemQty = Qty, @basePrice = (Price * @currentExchangeRate) / @exchangeRate FROM @poItemRef WHERE DataNo = @counter

                SET @message = 'I|Calculating TB_T_PO_CONDITION price amount where PROCESS_ID: ' + CAST(@processId AS VARCHAR) +' and PO_NO: ' + ISNULL(@poNo, '') + ' and SEQ_ITEM_NO: ' + REPLACE(CAST(@seqItemNo AS VARCHAR(3)), '0', '') + ': begin'
                INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

                IF (SELECT COUNT(0) FROM TB_M_CALCULATION_MAPPING WHERE CALCULATION_SCHEME_CD = @calcScheme AND CONDITION_CATEGORY = 'H') <= 0
                BEGIN RAISERROR('Bug - Base price is not defined in TB_M_CALCULATION_MAPPING', 16, 1) END

                IF (SELECT COUNT(0) FROM TB_M_CALCULATION_MAPPING WHERE CALCULATION_SCHEME_CD = @calcScheme AND CONDITION_CATEGORY = 'H') > 1
                BEGIN RAISERROR('Bug - Base price is defined more than once in TB_M_CALCULATION_MAPPING', 16, 1) END

                INSERT INTO @calculationRef
                SELECT *
                FROM (
                    SELECT SEQ_NO SeqNo, CONDITION_CATEGORY Category, CALCULATION_TYPE CalcType, COMP_PRICE_CD CompPriceCode,
                        BASE_VALUE_FROM BaseFrom, BASE_VALUE_TO BaseTo, PLUS_MINUS_FLAG PlusMinus, @basePrice Rate, ACCRUAL_FLAG_TYPE AccrualType,
                        CONDITION_RULE ConditionRule, 'M' CompType, @itemQty Qty, (CASE QTY_PER_UOM WHEN 'N' THEN @itemQty ELSE CAST(QTY_PER_UOM AS INT) END) QtyPerUOM, 0 Price
                    FROM TB_M_CALCULATION_MAPPING WHERE CALCULATION_SCHEME_CD = @calcScheme AND CONDITION_CATEGORY = 'H'
                    UNION
                    SELECT calcm.SEQ_NO SeqNo, calcm.CONDITION_CATEGORY Category, calcm.CALCULATION_TYPE CalcType, calcm.COMP_PRICE_CD CompPriceCode,
                        calcm.BASE_VALUE_FROM BaseFrom, calcm.BASE_VALUE_TO BaseTo, calcm.PLUS_MINUS_FLAG PlusMinus, cmppr.COMP_PRICE_RATE Rate,
                        calcm.ACCRUAL_FLAG_TYPE AccrualType, calcm.CONDITION_RULE ConditionRule, 'M' CompType, @itemQty Qty,
                        (CASE QTY_PER_UOM WHEN 'N' THEN @itemQty ELSE CAST(QTY_PER_UOM AS INT) END) QtyPerUOM, 0 Price
                    FROM TB_M_CALCULATION_MAPPING calcm
                    JOIN TB_M_COMP_PRICE_RATE cmppr ON calcm.COMP_PRICE_CD = cmppr.COMP_PRICE_CD
                    WHERE calcm.CALCULATION_SCHEME_CD = @calcScheme AND calcm.CONDITION_CATEGORY = 'D'
                    UNION
                    SELECT podt.SEQ_NO SeqNo, podt.CONDITION_CATEGORY Category, podt.CALCULATION_TYPE CalcType, podt.COMP_PRICE_CD CompPriceCode,
                        podt.BASE_VALUE_FROM BaseFrom, podt.BASE_VALUE_TO BaseTo, podt.PLUS_MINUS_FLAG PlusMinus, podt.COMP_PRICE_RATE Rate,
                        podt.ACCRUAL_FLAG_TYPE AccrualType, podt.CONDITION_RULE ConditionRule, 'S' CompType, @itemQty Qty, QTY_PER_UOM QtyPerUOM, 0 Price
                    FROM TB_T_PO_CONDITION podt
                    LEFT JOIN TB_M_COMP_PRICE cmpp ON podt.COMP_PRICE_CD = cmpp.COMP_PRICE_CD
                    LEFT JOIN TB_M_COMP_PRICE_RATE cmppr ON cmpp.COMP_PRICE_CD = cmppr.COMP_PRICE_CD
                    WHERE podt.PROCESS_ID = @processId AND ISNULL(podt.PO_NO, '') = ISNULL(@poNo, '')
                    AND ISNULL(podt.PO_ITEM_NO, '') = ISNULL(@poItemNo, '') AND podt.SEQ_ITEM_NO = @seqItemNo AND podt.COMP_TYPE = 'S'
                ) tmp

                INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Clean calculation temp data: begin', @moduleId, @actionName, @functionId, 1, @currentUser)
                DELETE FROM TB_T_PO_CONDITION WHERE PROCESS_ID = @processId AND ISNULL(PO_NO, '') = ISNULL(@poNo, '') AND SEQ_ITEM_NO = @seqItemNo
                INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Clean calculation temp data: end', @moduleId, @actionName, @functionId, 1, @currentUser)

                DECLARE @detailIdx INT = 0, @calcCount INT = (SELECT COUNT(0) FROM @calculationRef)
                WHILE (@detailIdx < @calcCount)
                BEGIN
                    DECLARE @seqNo INT = (SELECT @detailIdx + 1)
                    DECLARE @calculationRes CALC_COMP_PRICE

                    IF (SELECT CASE WHEN COUNT(0) > 0 THEN 0 ELSE 1 END FROM @calculationRef WHERE SeqNo = @seqNo) = 1
                    BEGIN
                        SET @detailIdx = @seqNo
                        CONTINUE
                    END

                    INSERT INTO @calculationRes
                    SELECT
                    cr.SeqNo, cr.Category, cr.CalcType, cr.CompPriceCode, cr.BaseFrom, cr.BaseTo,
                    cr.PlusMinus, cr.Rate, cr.AccrualType, cr.ConditionRule, cr.CompType, cr.Qty, cr.QtyPerUOM,
                    CASE
                        WHEN cr.Category = 'H' THEN
                            CASE WHEN cr.PlusMinus = 1 THEN cr.Rate
                            ELSE cr.Rate * -1
                            END
                        WHEN cr.Category = 'D' THEN
                            CASE cr.CalcType
                                WHEN 1 THEN -- Fix Amount
                                    CASE WHEN cr.PlusMinus = 1 THEN cr.Rate
                                    ELSE cr.Rate * -1
                                    END
                                WHEN 2 THEN -- By Quantity
                                    CASE WHEN cr.PlusMinus = 1 THEN cr.Rate / cr.QtyPerUOM
                                    ELSE (cr.Rate / cr.QtyPerUOM) * -1
                                    END
                                WHEN 3 THEN -- Percentage or Percentage Summary
                                    CASE WHEN cr.PlusMinus = 1 THEN (cr.Rate/100) * (SELECT SUM(cri.Price) FROM @calculationRes cri WHERE cri.SeqNo BETWEEN cr.BaseFrom AND ISNULL(cr.BaseTo, cr.BaseFrom))
                                    ELSE ((cr.Rate/100) * (SELECT SUM(cri.Price) FROM @calculationRes cri WHERE cri.SeqNo BETWEEN cr.BaseFrom AND ISNULL(cr.BaseTo, cr.BaseFrom))) * -1
                                    END
                                WHEN 4 THEN -- Summary
                                    CASE WHEN cr.PlusMinus = 1 THEN (SELECT SUM(cri.Price) FROM @calculationRes cri WHERE cri.SeqNo BETWEEN cr.BaseFrom AND ISNULL(cr.BaseTo, cr.BaseFrom))
                                    ELSE (SELECT SUM(cri.Price) FROM @calculationRes cri WHERE cri.SeqNo BETWEEN cr.BaseFrom AND ISNULL(cr.BaseTo, cr.BaseFrom)) * -1
                                    END
                            END
                    END Price
                    FROM @calculationRef cr WHERE cr.SeqNo = @seqNo

                    SET @message = 'I|Insert data to TB_T_PO_CONDITION where PROCESS_ID: ' + CAST(@processId AS VARCHAR) +' and PO_NO: ' + ISNULL(@poNo, '') + ' and SEQ_ITEM_NO: ' + CAST(@seqItemNo AS VARCHAR) + ' and COMP_PRICE_CD: ' + (SELECT CompPriceCode FROM @calculationRef WHERE SeqNo = @seqNo) + ': begin'
                    INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

                    INSERT INTO TB_T_PO_CONDITION
                    (PROCESS_ID, SEQ_ITEM_NO, PO_NO, PO_ITEM_NO, COMP_PRICE_CD, COMP_PRICE_RATE, INVOICE_FLAG, EXCHANGE_RATE, SEQ_NO, BASE_VALUE_FROM,
                    BASE_VALUE_TO, PO_CURR, INVENTORY_FLAG, CALCULATION_TYPE, PLUS_MINUS_FLAG, CONDITION_CATEGORY, ACCRUAL_FLAG_TYPE, CONDITION_RULE, PRICE_AMT, QTY, QTY_PER_UOM,
                    COMP_TYPE, PRINT_STATUS, NEW_FLAG, UPDATE_FLAG, DELETE_FLAG, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT)
                    SELECT @processId, @seqItemNo, @poNo, NULL, CompPriceCode, Rate, 'N', @exchangeRate, @seqNo, BaseFrom, BaseTo, @currency, 'N', CalcType, 1,
                    'D', 'Y', 'V', Price * (Qty / QtyPerUOM), Qty, QtyPerUOM, CompType, 'N', 'Y', 'N', 'N', @currentUser, GETDATE(), NULL, NULL
                    FROM @calculationRes WHERE SeqNo = @seqNo

                    /*
                    -- For debugging purposes
                    SELECT @currency Currency, @exchangeRate ExchRate, @calcScheme CalcScheme, @basePrice BasePrice, @prNo PRNo, @prItemNo PRItemNo, @itemQty ItemQty
                    SELECT * FROM @calculationRef
                    SELECT *, Price * (Qty / QtyPerUOM) PriceAmount FROM @calculationRes
                    */

                    SET @message = 'I|Insert data to TB_T_PO_CONDITION where PROCESS_ID: ' + CAST(@processId AS VARCHAR) +' and PO_NO: ' + ISNULL(@poNo, '') + ' and SEQ_ITEM_NO: ' + CAST(@seqItemNo AS VARCHAR) + ' and COMP_PRICE_CD: ' + (SELECT CompPriceCode FROM @calculationRef WHERE SeqNo = @seqNo) + ': end'
                    INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

                    SET @detailIdx = @seqNo
                END

                SET @message = 'I|Calculating TB_T_PO_CONDITION price amount where PROCESS_ID: ' + CAST(@processId AS VARCHAR) +' and PO_NO: ' + ISNULL(@poNo, '') + ' and SEQ_ITEM_NO: ' + CAST(@seqItemNo AS VARCHAR) + ': end'
                INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

                DELETE FROM @calculationRef
                DELETE FROM @calculationRes

                SET @counter = @counter + 1
            END
        END

        COMMIT TRAN Refresh

        SET @message = 'S|Finish'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN Refresh
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
    END CATCH

    EXEC sp_PutLog_Temp @tmpLog
    SET NOCOUNT OFF
    SELECT @message [Message]
END