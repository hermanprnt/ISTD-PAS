CREATE PROCEDURE [dbo].[sp_POCreation_AdoptItemTemp]
    @currentUser VARCHAR(50),
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6),
    @poNo VARCHAR(11),
    @currency VARCHAR(3),
    @prNoPRItemNoAssetNoList VARCHAR(MAX)
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = 'sp_POCreation_AdoptItemTemp',
        @itemDelimiter CHAR(1) = ';',
        @listDelimiter CHAR(1) = ',',
        @dataCount INT, @counter INT = 0,
        @tmpLog LOG_TEMP

    BEGIN TRY
        SET NOCOUNT ON

        EXEC dbo.sp_PutLog 'I|Start', @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0

        BEGIN TRAN AdoptItemTemp
        -- 1. Split paramList into delimited key list
        DECLARE @splittedIdList TABLE ( Idx INT, Split VARCHAR(100) )
        INSERT INTO @splittedIdList
        SELECT No, Split FROM dbo.SplitString(@prNoPRItemNoAssetNoList, @listDelimiter)
        SELECT @dataCount = COUNT(0) FROM @splittedIdList

        WHILE (@counter < @dataCount)
        BEGIN
            -- 2. Split delimited key into separated key
            DECLARE
                @currentId VARCHAR(200) = (SELECT Split FROM @splittedIdList WHERE Idx = @counter + 1),
                @prNo VARCHAR(50), @prItemNo VARCHAR(50), @assetNo VARCHAR(50), @subAssetNo VARCHAR(50)
            DECLARE
                @splittedId TABLE ( Idx INT, Split VARCHAR(50) )

            INSERT INTO @splittedId
            SELECT No, Split FROM dbo.SplitString(@currentId, @itemDelimiter)
            SELECT
                @prNo = (SELECT Split FROM @splittedId WHERE Idx = 1), @prItemNo = (SELECT Split FROM @splittedId WHERE Idx = 2),
                @assetNo = (SELECT Split FROM @splittedId WHERE Idx = 3), @subAssetNo = (SELECT Split FROM @splittedId WHERE Idx = 4)
            DELETE FROM @splittedId

            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Get currency rate: begin', @moduleId, @actionName, @functionId, 1, @currentUser)

            -- This code will a bit confusing
            -- If there're items the rest of adopt will follow existing items's currency
            -- If there're none then use adopted items's currency
            DECLARE @currencyRate TABLE ( CurrencyCode VARCHAR(3), ExchangeRate DECIMAL(7,2), ValidFrom DATETIME, ValidTo DATETIME )
            DECLARE
                @exchangeRate DECIMAL(7,2),
                @existExchangeRate DECIMAL(7,2),
                @existCurrency VARCHAR(3) = (SELECT TOP 1 CURR_CD FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId AND DELETE_FLAG = 'N'),
                @currency2Use VARCHAR(3)
            SELECT @currency = ORI_CURR_CD, @currency2Use = @currency
            FROM TB_R_PR_ITEM pri WHERE pri.PR_NO = @prNo AND pri.PR_ITEM_NO = @prItemNo

            IF ISNULL(@existCurrency, '') = '' AND ISNULL(@currency, '') = ''
            BEGIN RAISERROR('Bug - PR Currency is not valid.', 16, 1) END
            ELSE IF ISNULL(@existCurrency, '') = ''
            BEGIN SET @currency2Use = @currency END
            ELSE IF @existCurrency <> @currency
            BEGIN SET @currency2Use = @existCurrency END

            INSERT INTO @currencyRate EXEC sp_Currency_GetCurrency @currency
            SET @message = 'Bug - Currently applicable currency rate of ''' + ISNULL(@currency, '') + ''' is duplicate'
            IF (SELECT COUNT(0) FROM @currencyRate) > 1 BEGIN RAISERROR(@message, 16, 1) END
            SELECT @existExchangeRate = ExchangeRate FROM @currencyRate
            DELETE FROM @currencyRate

            INSERT INTO @currencyRate EXEC sp_Currency_GetCurrency @currency2Use
            SET @message = 'Bug - Currently applicable currency rate of ''' + ISNULL(@currency2Use, '') + ''' is duplicate'
            IF (SELECT COUNT(0) FROM @currencyRate) > 1 BEGIN RAISERROR(@message, 16, 1) END
            SELECT @exchangeRate = ExchangeRate FROM @currencyRate
            DELETE FROM @currencyRate

            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Get currency rate: end', @moduleId, @actionName, @functionId, 1, @currentUser)

            -- 3. Select then insert data by key
            SET @message = 'I|Select from TB_R_PR_ITEM then Insert to TB_T_PO_ITEM where PR_NO: ' + @prNo + ' and PR_ITEM_NO: ' + @prItemNo + ': begin'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            DECLARE @sequenceNo INT = (SELECT ISNULL(MAX(SEQ_ITEM_NO), 0) + 1 FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId)
            DECLARE @purchasingGroup VARCHAR(6), @calcScheme VARCHAR(4), @basePrice DECIMAL(18,4), @itemQty DECIMAL(9,4)
            SELECT @purchasingGroup = valc.PURCHASING_GROUP_CD, @calcScheme = valc.CALCULATION_SCHEME_CD, @basePrice = (pri.PRICE_PER_UOM * @existExchangeRate) / @exchangeRate, @itemQty = pri.OPEN_QTY
            FROM TB_R_PR_ITEM pri JOIN TB_M_VALUATION_CLASS valc ON pri.VALUATION_CLASS = valc.VALUATION_CLASS
            WHERE pri.PR_NO = @prNo AND pri.PR_ITEM_NO = @prItemNo

            INSERT INTO TB_T_PO_ITEM
            (PROCESS_ID, SEQ_ITEM_NO, PR_NO, PR_ITEM_NO, VENDOR_CD, VENDOR_NAME, QUOTATION_NO, PURCHASING_GRP_CD, VALUATION_CLASS, MAT_NO, MAT_DESC,
            PROCUREMENT_PURPOSE, DELIVERY_PLAN_DT, SOURCE_TYPE, PLANT_CD, SLOC_CD, WBS_NO, COST_CENTER_CD, UNLIMITED_FLAG, TOLERANCE_PERCENTAGE, SPECIAL_PROCUREMENT_TYPE,
            PO_QTY_ORI, PO_QTY_USED, PO_QTY_REMAIN, UOM, CURR_CD, ORI_AMOUNT, NEW_FLAG, UPDATE_FLAG, DELETE_FLAG, PO_NO,
            PO_ITEM_NO, URGENT_DOC, GROSS_PERCENT, ITEM_CLASS, IS_PARENT, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT, WBS_NAME,
            GL_ACCOUNT, PO_QTY_NEW, ORI_PRICE_PER_UOM, NEW_PRICE_PER_UOM, NEW_AMOUNT, ORI_LOCAL_AMOUNT, NEW_LOCAL_AMOUNT, ASSET_NO, SUB_ASSET_NO)
            SELECT @processId, @sequenceNo, pri.PR_NO, pri.PR_ITEM_NO, pri.VENDOR_CD,
            CASE WHEN ISNULL(pri.VENDOR_CD, '') = '' THEN NULL ELSE (SELECT VENDOR_NAME FROM TB_M_VENDOR WHERE VENDOR_CD = pri.VENDOR_CD) END,
            '', @purchasingGroup, pri.VALUATION_CLASS, pri.MAT_NO, pri.MAT_DESC, pri.PROCUREMENT_PURPOSE, ISNULL(pri.DELIVERY_PLAN_DT, prh.DELIVERY_PLAN_DT),
            pri.SOURCE_TYPE, prh.PLANT_CD, prh.SLOC_CD, pri.WBS_NO, pri.COST_CENTER_CD, NULL, 0, pri.SPECIAL_PROC_TYPE, 0, 0,
            CASE WHEN ISNULL(@assetNo, '') = '' THEN pri.OPEN_QTY ELSE 1 END,
            pri.UNIT_OF_MEASURE_CD, @currency2Use, 0, 'Y', 'N', 'N', @poNo, NULL, prh.URGENT_DOC, 0, pri.ITEM_CLASS,
            (SELECT CASE WHEN COUNT(0) > 0 THEN 'Y' ELSE 'N' END FROM TB_R_PR_SUBITEM WHERE PR_NO = @prNo AND PR_ITEM_NO = @prItemNo),
            @currentUser, GETDATE(), NULL, NULL, (SELECT TOP 1 WBS_NAME FROM TB_R_WBS WHERE WBS_NO = WBS_NO), GL_ACCOUNT,
            CASE WHEN ISNULL(@assetNo, '') = '' THEN pri.OPEN_QTY ELSE 1 END, 0, @basePrice,
            CASE WHEN ISNULL(pri.VENDOR_CD, '') = '' THEN (CASE WHEN ISNULL(@assetNo, '') = '' THEN pri.OPEN_QTY ELSE 1 END) * @basePrice ELSE pri.ORI_AMOUNT END, 0,
            CASE WHEN ISNULL(pri.VENDOR_CD, '') = '' THEN ((CASE WHEN ISNULL(@assetNo, '') = '' THEN pri.OPEN_QTY ELSE 1 END) * (pri.PRICE_PER_UOM * @existExchangeRate)) ELSE 0 END,
            @assetNo, @subAssetNo
            FROM TB_R_PR_ITEM pri JOIN TB_R_PR_H prh ON pri.PR_NO = prh.PR_NO
            WHERE pri.PR_NO = @prNo AND pri.PR_ITEM_NO = @prItemNo

            SET @message = 'I|Select from TB_R_PR_ITEM then Insert to TB_T_PO_ITEM where PR_NO: ' + @prNo + ' and PR_ITEM_NO: ' + @prItemNo + ': end'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            SET @message = 'I|Lock TB_R_ASSET where PR_NO: ' + @prNo + ' and PR_ITEM_NO: ' + @prItemNo + ' and ASSET_NO:' + @assetNo + ': begin'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            UPDATE TB_R_PR_ITEM SET PROCESS_ID = @processId WHERE PR_NO = @prNo AND PR_ITEM_NO = @prItemNo

            UPDATE TB_R_ASSET SET PROCESS_ID = @processId, CHANGED_BY = @currentUser, CHANGED_DT = GETDATE()
            WHERE PR_NO = @prNo AND PR_ITEM_NO = @prItemNo AND ASSET_NO = @assetNo AND ISNULL(SUB_ASSET_NO, '') = ISNULL(@subAssetNo, '')

            SET @message = 'I|Lock TB_R_ASSET where PR_NO: ' + @prNo + ' and PR_ITEM_NO: ' + @prItemNo + ' and ASSET_NO:' + @assetNo + ': end'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            SET @message =
                'I|Select from TB_R_PR_SUBITEM then Insert to TB_T_PO_SUBITEM where PO_NO: ' + ISNULL(@poNo, '') + ', SEQ_ITEM_NO: ' + REPLACE(CAST(@sequenceNo AS VARCHAR(3)), '0', '') +
                ', PR_NO: ' + @prNo + ' and PR_ITEM_NO: ' + REPLACE(CAST(@prItemNo AS VARCHAR(3)), '0', '') + ': begin'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            INSERT INTO TB_T_PO_SUBITEM
            (PROCESS_ID, SEQ_ITEM_NO, SEQ_NO, PO_NO, PO_ITEM_NO, PO_SUBITEM_NO, PR_NO, PR_ITEM_NO, PR_SUBITEM_NO, MAT_NO,
            MAT_DESC, WBS_NO, WBS_NAME, GL_ACCOUNT, COST_CENTER_CD, PO_QTY_ORI, PO_QTY_USED, PO_QTY_REMAIN, PO_QTY_NEW, UOM,
            CURR_CD, ORI_PRICE_PER_UOM, PRICE_PER_UOM, ORI_AMOUNT, AMOUNT, ORI_LOCAL_AMOUNT, LOCAL_AMOUNT, NEW_FLAG, UPDATE_FLAG, DELETE_FLAG,
            CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT)
            SELECT @processId, @sequenceNo, ROW_NUMBER() OVER (ORDER BY prsi.PR_NO ASC, prsi.PR_ITEM_NO ASC, prsi.PR_SUBITEM_NO ASC),
            @poNo, NULL, NULL, prsi.PR_NO, prsi.PR_ITEM_NO, prsi.PR_SUBITEM_NO, prsi.MAT_NO, prsi.MAT_DESC, prsi.WBS_NO,
            (SELECT TOP 1 WBS_NAME FROM TB_R_WBS WHERE WBS_NO = prsi.WBS_NO), prsi.GL_ACCOUNT, prsi.COST_CENTER_CD, 0, 0, prsi.SUBITEM_QTY,
            prsi.SUBITEM_QTY, prsi.SUBITEM_UOM, @currency2Use, 0, prsi.PRICE_PER_UOM, 0, prsi.SUBITEM_QTY * prsi.PRICE_PER_UOM,
            0, prsi.SUBITEM_QTY * (prsi.PRICE_PER_UOM * @existExchangeRate), 'Y', 'N', 'N', @currentUser, GETDATE(), NULL, NULL
            FROM TB_R_PR_SUBITEM prsi JOIN TB_R_PR_ITEM pri ON prsi.PR_NO = pri.PR_NO AND prsi.PR_ITEM_NO = pri.PR_ITEM_NO
            WHERE prsi.PR_NO = @prNo AND prsi.PR_ITEM_NO = @prItemNo

            SET @message =
                'I|Select from TB_R_PR_SUBITEM then Insert to TB_T_PO_SUBITEM where PO_NO: ' + ISNULL(@poNo, '') + ', SEQ_ITEM_NO: ' + REPLACE(CAST(@sequenceNo AS VARCHAR(3)), '0', '') +
                ', PR_NO: ' + @prNo + ' and PR_ITEM_NO: ' + REPLACE(CAST(@prItemNo AS VARCHAR(3)), '0', '') + ': end'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            -- 4. Calculate Component Price
            SET @message = 'I|Calculating TB_T_PO_CONDITION price amount where PROCESS_ID: ' + CAST(@processId AS VARCHAR) +' and PO_NO: ' + ISNULL(@poNo, '') + ' and SEQ_ITEM_NO: ' + REPLACE(CAST(@sequenceNo AS VARCHAR(3)), '0', '') + ': begin'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            IF (SELECT COUNT(0) FROM TB_M_CALCULATION_MAPPING WHERE CALCULATION_SCHEME_CD = @calcScheme AND CONDITION_CATEGORY = 'H') <= 0
            BEGIN RAISERROR('Bug - Base price is not defined in TB_M_CALCULATION_MAPPING', 16, 1) END

            IF (SELECT COUNT(0) FROM TB_M_CALCULATION_MAPPING WHERE CALCULATION_SCHEME_CD = @calcScheme AND CONDITION_CATEGORY = 'H') > 1
            BEGIN RAISERROR('Bug - Base price is defined more than once in TB_M_CALCULATION_MAPPING', 16, 1) END

            DECLARE @calculationRef CALC_COMP_PRICE
            INSERT INTO @calculationRef
            SELECT *
            FROM (
                SELECT SEQ_NO SeqNo, CONDITION_CATEGORY Category, CALCULATION_TYPE CalcType, COMP_PRICE_CD CompPriceCode,
                    BASE_VALUE_FROM BaseFrom, BASE_VALUE_TO BaseTo, PLUS_MINUS_FLAG PlusMinus, @basePrice Rate, ACCRUAL_FLAG_TYPE AccrualType,
                    CONDITION_RULE ConditionRule, 'M' CompType, @itemQty Qty, (CASE QTY_PER_UOM WHEN 'N' THEN 1 ELSE CAST(QTY_PER_UOM AS INT) END) QtyPerUOM, 0 Price
                FROM TB_M_CALCULATION_MAPPING WHERE CALCULATION_SCHEME_CD = @calcScheme AND CONDITION_CATEGORY = 'H'
                UNION
                SELECT calcm.SEQ_NO SeqNo, calcm.CONDITION_CATEGORY Category, calcm.CALCULATION_TYPE CalcType, calcm.COMP_PRICE_CD CompPriceCode,
                    calcm.BASE_VALUE_FROM BaseFrom, calcm.BASE_VALUE_TO BaseTo, calcm.PLUS_MINUS_FLAG PlusMinus, cmppr.COMP_PRICE_RATE Rate,
                    calcm.ACCRUAL_FLAG_TYPE AccrualType, calcm.CONDITION_RULE ConditionRule, 'M' CompType, @itemQty Qty,
                    (CASE QTY_PER_UOM WHEN 'N' THEN 1 ELSE CAST(QTY_PER_UOM AS INT) END) QtyPerUOM, 0 Price
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
                WHERE podt.PROCESS_ID = @processId AND podt.SEQ_ITEM_NO = @sequenceNo
            ) tmp

            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Clean calculation temp data: begin', @moduleId, @actionName, @functionId, 1, @currentUser)
            DELETE FROM TB_T_PO_CONDITION WHERE PROCESS_ID = @processId AND ISNULL(PO_NO, '') = ISNULL(@poNo, '') AND SEQ_ITEM_NO = @sequenceNo
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

                SET @message = 'I|Insert data to TB_T_PO_CONDITION where PROCESS_ID: ' + CAST(@processId AS VARCHAR) +' and PO_NO: ' + ISNULL(@poNo, '') + ' and SEQ_ITEM_NO: ' + CAST(@sequenceNo AS VARCHAR) + ' and COMP_PRICE_CD: ' + (SELECT CompPriceCode FROM @calculationRef WHERE SeqNo = @seqNo) + ': begin'
                INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

                INSERT INTO TB_T_PO_CONDITION
                (PROCESS_ID, SEQ_ITEM_NO, PO_NO, PO_ITEM_NO, COMP_PRICE_CD, COMP_PRICE_RATE, INVOICE_FLAG, EXCHANGE_RATE, SEQ_NO, BASE_VALUE_FROM,
                BASE_VALUE_TO, PO_CURR, INVENTORY_FLAG, CALCULATION_TYPE, PLUS_MINUS_FLAG, CONDITION_CATEGORY, ACCRUAL_FLAG_TYPE, CONDITION_RULE, PRICE_AMT, QTY, QTY_PER_UOM,
                COMP_TYPE, PRINT_STATUS, NEW_FLAG, UPDATE_FLAG, DELETE_FLAG, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT)
                SELECT @processId, @sequenceNo, @poNo, NULL, CompPriceCode, Rate, 'N', @exchangeRate, @seqNo, BaseFrom, BaseTo, @currency, 'N', CalcType, 1,
                'D', 'Y', 'V', Price * (Qty / QtyPerUOM), Qty, QtyPerUOM, CompType, 'N', 'Y', 'N', 'N', @currentUser, GETDATE(), NULL, NULL
                FROM @calculationRes WHERE SeqNo = @seqNo

                /*
                -- For debugging purposes
                SELECT @currency Currency, @exchangeRate ExchRate, @calcScheme CalcScheme, @basePrice BasePrice, @prNo PRNo, @prItemNo PRItemNo, @itemQty ItemQty
                SELECT * FROM @calculationRef
                SELECT *, Price * (Qty / QtyPerUOM) PriceAmount FROM @calculationRes
                */

                SET @message = 'I|Insert data to TB_T_PO_CONDITION where PROCESS_ID: ' + CAST(@processId AS VARCHAR) +' and PO_NO: ' + ISNULL(@poNo, '') + ' and SEQ_ITEM_NO: ' + CAST(@sequenceNo AS VARCHAR) + ' and COMP_PRICE_CD: ' + (SELECT CompPriceCode FROM @calculationRef WHERE SeqNo = @seqNo) + ': end'
                INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

                SET @detailIdx = @seqNo
            END

            SET @message = 'I|Calculating TB_T_PO_CONDITION price amount where PROCESS_ID: ' + CAST(@processId AS VARCHAR) +' and PO_NO: ' + ISNULL(@poNo, '') + ' and SEQ_ITEM_NO: ' + CAST(@sequenceNo AS VARCHAR) + ': end'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            DELETE FROM @calculationRef
            DELETE FROM @calculationRes

            SELECT @counter = @counter + 1
        END

        COMMIT TRAN AdoptItemTemp

        SET @message = 'S|Finish'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN AdoptItemTemp
        SET @message = 'E|' + CAST(@processId AS VARCHAR) + ': ' + @actionName + ' - ' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
    END CATCH

    EXEC sp_PutLog_Temp @tmpLog
    SET NOCOUNT OFF
    SELECT @message [Message]
END