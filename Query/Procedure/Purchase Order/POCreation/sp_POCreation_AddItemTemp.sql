CREATE PROCEDURE [dbo].[sp_POCreation_AddItemTemp]
    @currentUser VARCHAR(50),
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6),
    @poNo VARCHAR(11),
    @poItemNo VARCHAR(5),
    @seqItemNo VARCHAR(5),
    @vendor VARCHAR(6),
    @vendorName VARCHAR(100),
    @purchasingGroup VARCHAR(3),
    @valuationClass VARCHAR(4),
    @matNo VARCHAR(23),
    @matDesc VARCHAR(50),
    @qty DECIMAL(7,2),
    @uom VARCHAR(3),
    @pricePerUOM DECIMAL(18,4),
    @wbsNo VARCHAR(30),
    @costCenter VARCHAR(10),
    @glAccount VARCHAR(8),
    @deliveryDate DATETIME,
    @plant VARCHAR(4),
    @sloc VARCHAR(4),
    @currency VARCHAR(3)
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = 'sp_POCreation_AddItemTemp',
        @tmpLog LOG_TEMP
    
    SET @message = 'I|Start'
    EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0
    
    BEGIN TRY
        BEGIN TRAN AddItemTemp
        
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Get currency rate: begin', @moduleId, @actionName, @functionId, 1, @currentUser)
        
        DECLARE @currencyRate TABLE ( CurrencyCode VARCHAR(3), ExchangeRate DECIMAL(7,2), ValidFrom DATETIME, ValidTo DATETIME )
        DECLARE @exchangeRate DECIMAL(7,2)
        INSERT INTO @currencyRate EXEC sp_Currency_GetCurrency @currency
        IF (SELECT COUNT(0) FROM @currencyRate) > 1 BEGIN RAISERROR('Bug - Currently applicable currency rate is duplicate', 16, 1) END
        SELECT @exchangeRate = ExchangeRate FROM @currencyRate
        
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Get currency rate: end', @moduleId, @actionName, @functionId, 1, @currentUser)
        
        DECLARE @itemClass VARCHAR(1) = (SELECT ITEM_CLASS FROM TB_M_VALUATION_CLASS WHERE VALUATION_CLASS = @valuationClass AND PURCHASING_GROUP_CD = @purchasingGroup AND PROCUREMENT_TYPE = 'RM')
        DECLARE
            @sequenceNo INT = (SELECT ISNULL(MAX(SEQ_ITEM_NO), 0) + 1 FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId),
            @isParent VARCHAR(1) = (SELECT CASE WHEN @itemClass = 'S' THEN 'Y' ELSE 'N' END)

        -- 1. Insert PO Temp
        SET @message = 'I|Insert data in TB_T_PO_ITEM where PO_NO: ' + ISNULL(@poNo, 'NULL') + ' and PO_ITEM_NO: NULL and SEQ_ITEM_NO: ' + CAST(@sequenceNo AS VARCHAR) + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
        
        SELECT @vendorName = CASE WHEN ISNULL(@vendorName, '') = '' THEN VENDOR_NAME ELSE @vendorName END
        FROM TB_M_VENDOR WHERE VENDOR_CD = @vendor

		DECLARE @calcValue DECIMAL(7,4) = 0
		SELECT @calcValue = ISNULL(CALC_VALUE, 0) FROM TB_M_UNIT_OF_MEASURE WHERE UNIT_OF_MEASURE_CD = @uom
        
        INSERT INTO TB_T_PO_ITEM
        (PROCESS_ID, SEQ_ITEM_NO, PR_NO, PR_ITEM_NO, VENDOR_CD, VENDOR_NAME, QUOTATION_NO, PURCHASING_GRP_CD, VALUATION_CLASS, MAT_NO, MAT_DESC,
        PROCUREMENT_PURPOSE, DELIVERY_PLAN_DT, SOURCE_TYPE, PLANT_CD, SLOC_CD, WBS_NO, COST_CENTER_CD, UNLIMITED_FLAG, TOLERANCE_PERCENTAGE, SPECIAL_PROCUREMENT_TYPE,
        PO_QTY_ORI, PO_QTY_USED, PO_QTY_REMAIN, UOM, CURR_CD, ORI_AMOUNT, NEW_FLAG, UPDATE_FLAG, DELETE_FLAG, PO_NO,
        PO_ITEM_NO, URGENT_DOC, GROSS_PERCENT, ITEM_CLASS, IS_PARENT, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT, WBS_NAME,
        GL_ACCOUNT, PO_QTY_NEW, ORI_PRICE_PER_UOM, NEW_PRICE_PER_UOM, NEW_AMOUNT, ORI_LOCAL_AMOUNT, NEW_LOCAL_AMOUNT)
        VALUES (@processId, @sequenceNo, NULL, NULL, @vendor, @vendorName, '', @purchasingGroup, @valuationClass, @matNo, @matDesc, '', @deliveryDate,
        '', @plant, @sloc, @wbsNo, @costCenter, NULL, 0, '', 0, 0, @qty, @uom, @currency, 0, 'Y', 'N', 'N',
        @poNo, NULL, 'N', 0, @itemClass, @isParent, @currentUser, GETDATE(), NULL, NULL, (SELECT TOP 1 WBS_NAME FROM TB_R_WBS WHERE WBS_NO = @wbsNo),
        @glAccount, @qty, 0, @pricePerUOM, @qty * @pricePerUOM * @calcValue, 0, @qty * @pricePerUOM * @exchangeRate * @calcValue)

        SET @message = 'I|Insert data in TB_T_PO_ITEM where PO_NO: ' + ISNULL(@poNo, 'NULL') + ' and PO_ITEM_NO: NULL and SEQ_ITEM_NO: ' + CAST(@sequenceNo AS VARCHAR) + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
        
        -- 2. Recalculate PO Item Conditions
        SET @message = 'I|Calculating TB_T_PO_CONDITION price amount where PROCESS_ID: ' + CAST(@processId AS VARCHAR) +' and PO_NO: ' + ISNULL(@poNo, 'NULL') + ' and PO_ITEM_NO: NULL and SEQ_ITEM_NO: ' + CAST(@sequenceNo AS VARCHAR) + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        DECLARE @calcScheme VARCHAR(4), @basePrice DECIMAL(18,4), @itemQty DECIMAL(9,4)
        SELECT @calcScheme = valc.CALCULATION_SCHEME_CD, @basePrice = item.NEW_PRICE_PER_UOM, @itemQty = item.PO_QTY_NEW
        FROM TB_T_PO_ITEM item JOIN TB_M_VALUATION_CLASS valc ON item.VALUATION_CLASS = valc.VALUATION_CLASS
        WHERE item.PROCESS_ID = @processId AND ISNULL(item.PO_NO, '') = ISNULL(@poNo, '') AND ISNULL(item.PO_ITEM_NO, '') = '' AND item.SEQ_ITEM_NO = @sequenceNo
        
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
            AND ISNULL(podt.PO_ITEM_NO, '') = '' AND podt.SEQ_ITEM_NO = @sequenceNo AND podt.COMP_TYPE = 'S'
        ) tmp

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Clean calculation temp data: begin', @moduleId, @actionName, @functionId, 1, @currentUser)
        DELETE FROM TB_T_PO_CONDITION WHERE PROCESS_ID = @processId AND ISNULL(PO_NO, '') = ISNULL(@poNo, '') AND ISNULL(PO_ITEM_NO, '') = '' AND SEQ_ITEM_NO = @sequenceNo
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

            SET @message = 'I|Insert data to TB_T_PO_CONDITION where PROCESS_ID: ' + CAST(@processId AS VARCHAR) +' and PO_NO: ' + ISNULL(@poNo, 'NULL') + ' and PO_ITEM_NO: NULL and SEQ_ITEM_NO: ' + CAST(@sequenceNo AS VARCHAR) + ' and COMP_PRICE_CD: ' + (SELECT CompPriceCode FROM @calculationRef WHERE SeqNo = @seqNo) + ': begin'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            INSERT INTO TB_T_PO_CONDITION
            (PROCESS_ID, SEQ_ITEM_NO, PO_NO, PO_ITEM_NO, COMP_PRICE_CD, COMP_PRICE_RATE, INVOICE_FLAG, EXCHANGE_RATE, SEQ_NO, BASE_VALUE_FROM,
            BASE_VALUE_TO, PO_CURR, INVENTORY_FLAG, CALCULATION_TYPE, PLUS_MINUS_FLAG, CONDITION_CATEGORY, ACCRUAL_FLAG_TYPE, CONDITION_RULE, PRICE_AMT, QTY,
            QTY_PER_UOM, COMP_TYPE, PRINT_STATUS, NEW_FLAG, UPDATE_FLAG, DELETE_FLAG, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT)
            SELECT @processId, @sequenceNo, @poNo, NULL, CompPriceCode, Rate, 'N', @exchangeRate, @seqNo, BaseFrom, BaseTo, @currency, 'N', CalcType, 1,
            'D', 'Y', 'V', Price * (Qty / QtyPerUOM), Qty, QtyPerUOM, CompType, 'N', 'Y', 'N', 'N', @currentUser, GETDATE(), NULL, NULL
            FROM @calculationRes WHERE SeqNo = @seqNo

            /*
            -- For debugging purposes
            SELECT @currency Currency, @exchangeRate ExchRate, @calcScheme CalcScheme, @basePrice BasePrice, @prNo PRNo, @prItemNo PRItemNo, @itemQty ItemQty
            SELECT * FROM @calculationRef
            SELECT *, Price * (Qty / QtyPerUOM) PriceAmount FROM @calculationRes
            */

            SET @message = 'I|Insert data to TB_T_PO_CONDITION where PROCESS_ID: ' + CAST(@processId AS VARCHAR) +' and PO_NO: ' + ISNULL(@poNo, 'NULL') + ' and PO_ITEM_NO: NULL and SEQ_ITEM_NO: ' + CAST(@sequenceNo AS VARCHAR) + ' and COMP_PRICE_CD: ' + (SELECT CompPriceCode FROM @calculationRef WHERE SeqNo = @seqNo) + ': end'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            SET @detailIdx = @seqNo
        END

        SET @message = 'I|Calculating TB_T_PO_CONDITION price amount where PROCESS_ID: ' + CAST(@processId AS VARCHAR) +' and PO_NO: ' + ISNULL(@poNo, 'NULL') + ' and PO_ITEM_NO: NULL and SEQ_ITEM_NO: ' + CAST(@sequenceNo AS VARCHAR) + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        DELETE FROM @calculationRef
        DELETE FROM @calculationRes

        COMMIT TRAN AddItemTemp
        
        SET @message = 'S|Finish'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN AddItemTemp
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ' - ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
    END CATCH
    
    EXEC sp_PutLog_Temp @tmpLog
    SET NOCOUNT OFF
    -- NOTE: idx 0 --> message, idx 1 --> poNo, idx 2 --> poItemNo, idx 3 --> seqItemNo
    SELECT @message + ';' + ISNULL(@poNo, '') + ';' + ISNULL(NULL, '') + ';' + CAST(ISNULL(@sequenceNo, 0) AS VARCHAR) [Message]
END