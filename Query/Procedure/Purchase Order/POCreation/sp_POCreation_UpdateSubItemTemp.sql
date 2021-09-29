CREATE PROCEDURE [dbo].[sp_POCreation_UpdateSubItemTemp]
    @currentUser VARCHAR(50),
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6),
    @poNo VARCHAR(11),
    @poItemNo VARCHAR(5),
    @seqItemNo VARCHAR(5),
    @seqNo VARCHAR(5),
    @matDesc VARCHAR(50),
    @qty DECIMAL(7,2),
    @uom VARCHAR(3),
    @pricePerUOM DECIMAL(18,4),
    @currency VARCHAR(3),
    @wbs VARCHAR(30),
    @costCenter VARCHAR(10),
    @glAccount VARCHAR(8)
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = 'sp_POCreation_UpdateSubItemTemp',
        @tmpLog LOG_TEMP

    SET @message = 'I|Start'
    EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0

    BEGIN TRY
        BEGIN TRAN UpdateSubItemTemp

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Get currency rate: begin', @moduleId, @actionName, @functionId, 1, @currentUser)

        DECLARE @currencyRate TABLE ( CurrencyCode VARCHAR(3), ExchangeRate DECIMAL(7,2), ValidFrom DATETIME, ValidTo DATETIME )
        DECLARE @exchangeRate DECIMAL(7,2)
        INSERT INTO @currencyRate EXEC sp_Currency_GetCurrency @currency
        IF (SELECT COUNT(0) FROM @currencyRate) > 1 BEGIN RAISERROR('Bug - Currently applicable currency rate is duplicate', 16, 1) END
        SELECT @exchangeRate = ExchangeRate FROM @currencyRate

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Get currency rate: end', @moduleId, @actionName, @functionId, 1, @currentUser)

        SET @message = 'I|Update data to TB_T_PO_SUBITEM where PO_NO: ' + ISNULL(@poNo, '') + ' and PO_ITEM_NO: NULL and SEQ_ITEM_NO: ' + REPLACE(CAST(@seqItemNo AS VARCHAR(3)), '0', '') + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        UPDATE TB_T_PO_SUBITEM SET
        MAT_DESC = @matDesc, PO_QTY_NEW = @qty, UOM = @uom,
        PRICE_PER_UOM = @pricePerUOM, AMOUNT = @qty * @pricePerUOM,
        LOCAL_AMOUNT = @qty * @pricePerUOM * @exchangeRate, WBS_NO = @wbs,
        WBS_NAME = (SELECT TOP 1 WBS_NAME FROM TB_R_WBS WHERE WBS_NO = @wbs),
        COST_CENTER_CD = @costCenter, GL_ACCOUNT = @glAccount,
        UPDATE_FLAG = 'Y', CHANGED_BY = @currentUser, CHANGED_DT = GETDATE()
        WHERE PROCESS_ID = @processId AND ISNULL(PO_NO, '') = ISNULL(@poNo, '') AND ISNULL(PO_ITEM_NO, '') = ISNULL(@poItemNo, '')
        AND SEQ_ITEM_NO = @seqItemNo AND SEQ_NO = @seqNo

        SET @message = 'I|Update data to TB_T_PO_SUBITEM where PO_NO: ' + ISNULL(@poNo, '') + ' and PO_ITEM_NO: NULL and SEQ_ITEM_NO: ' + REPLACE(CAST(@seqItemNo AS VARCHAR(3)), '0', '') + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        COMMIT TRAN UpdateSubItemTemp

        SET @message = 'S|Finish'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN UpdateSubItemTemp
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ' - ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
    END CATCH

    EXEC sp_PutLog_Temp @tmpLog
    SET NOCOUNT OFF
    SELECT @message [Message]
END