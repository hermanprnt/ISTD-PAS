CREATE PROCEDURE [dbo].[sp_POCreation_AddSubItemTemp]
    @currentUser VARCHAR(50),
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6),
    @poNo VARCHAR(11),
    @poItemNo VARCHAR(5),
    @seqItemNo VARCHAR(5),
    @matDesc VARCHAR(50),
    @qty DECIMAL(7,2),
    @uom VARCHAR(3),
    @pricePerUOM DECIMAL(18,4),
    @wbsNo VARCHAR(30),
    @costCenter VARCHAR(10),
    @glAccount VARCHAR(8),
    @currency VARCHAR(3)
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = 'sp_POCreation_AddSubItemTemp',
        @tmpLog LOG_TEMP
    
    SET @message = 'I|Start'
    EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0
    
    BEGIN TRY
        BEGIN TRAN AddSubItemTemp
        
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Get currency rate: begin', @moduleId, @actionName, @functionId, 1, @currentUser)
        
        DECLARE @currencyRate TABLE ( CurrencyCode VARCHAR(3), ExchangeRate DECIMAL(7,2), ValidFrom DATETIME, ValidTo DATETIME )
        DECLARE @exchangeRate DECIMAL(7,2)
        INSERT INTO @currencyRate EXEC sp_Currency_GetCurrency @currency
        IF (SELECT COUNT(0) FROM @currencyRate) > 1 BEGIN RAISERROR('Bug - Currently applicable currency rate is duplicate', 16, 1) END
        SELECT @exchangeRate = ExchangeRate FROM @currencyRate
        
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Get currency rate: end', @moduleId, @actionName, @functionId, 1, @currentUser)
        
        SET @message = 'I|Insert data to TB_T_PO_SUBITEM where PO_NO: ' + ISNULL(@poNo, '') + ' and PO_ITEM_NO: NULL and SEQ_ITEM_NO: ' + REPLACE(CAST(@seqItemNo AS VARCHAR(3)), '0', '') + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
        
        DECLARE @lastSubItemSeqNo INT =
            (SELECT ISNULL(MAX(SEQ_NO), 0) FROM TB_T_PO_SUBITEM
            WHERE PROCESS_ID = @processId AND ISNULL(PO_NO, '') = ISNULL(@poNo, '')
                AND ISNULL(PO_ITEM_NO, '') = ISNULL(@poItemNo, '')
                AND SEQ_ITEM_NO = @seqItemNo)
        
		DECLARE @calcValue DECIMAL(7, 4) = 0
		SELECT @calcValue = ISNULL(CALC_VALUE, 0) FROM TB_M_UNIT_OF_MEASURE WHERE UNIT_OF_MEASURE_CD = @uom

        INSERT INTO TB_T_PO_SUBITEM
        (PROCESS_ID, SEQ_ITEM_NO, SEQ_NO, MAT_NO, MAT_DESC, WBS_NO, COST_CENTER_CD, PO_QTY_ORI, PO_QTY_USED, PO_QTY_REMAIN, PO_QTY_NEW,
        UOM, CURR_CD, PRICE_PER_UOM, ORI_AMOUNT, AMOUNT, LOCAL_AMOUNT, NEW_FLAG, UPDATE_FLAG, DELETE_FLAG, PO_NO, PO_ITEM_NO,
        PO_SUBITEM_NO, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT, GL_ACCOUNT)
        VALUES (@processId, @seqItemNo, (SELECT @lastSubItemSeqNo + 1), NULL, @matDesc, @wbsNo, @costCenter, 0, 0, @qty, @qty, @uom, @currency,
        @pricePerUOM, 0, @qty * @pricePerUOM * @calcValue, (@qty * @pricePerUOM) * @exchangeRate * @calcValue, 'Y', 'N', 'N', @poNo, @poItemNo, NULL,
        @currentUser, GETDATE(), NULL, NULL, @glAccount)

        SET @message = 'I|Insert data to TB_T_PO_SUBITEM where PO_NO: ' + ISNULL(@poNo, '') + ' and PO_ITEM_NO: NULL and SEQ_ITEM_NO: ' + REPLACE(CAST(@seqItemNo AS VARCHAR(3)), '0', '') + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        COMMIT TRAN AddSubItemTemp

        SET @message = 'S|Finish'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN AddSubItemTemp
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ' - ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
    END CATCH
    
    EXEC sp_PutLog_Temp @tmpLog
    SET NOCOUNT OFF
    SELECT @message [Message]
END