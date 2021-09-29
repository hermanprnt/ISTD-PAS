CREATE PROCEDURE [dbo].[sp_POCreation_DeleteItemConditionTemp]
    @currentUser VARCHAR(50),
    @processId BIGINT OUTPUT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(5),
    @poNo VARCHAR(11),
    @poItemNo VARCHAR(30),
    @seqItemNo INT,
    @seqNo INT
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = 'sp_POCreation_DeleteItemConditionTemp',
        @tmpLog LOG_TEMP
    
    SET @message = 'I|Start'
    EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0
    
    BEGIN TRY
        BEGIN TRAN DeleteConditionTemp
        
        DECLARE @compPriceCode VARCHAR(6) = (SELECT COMP_PRICE_CD FROM TB_T_PO_CONDITION WHERE PROCESS_ID = @processId AND ISNULL(PO_NO, '') = ISNULL(@poNo, '') AND ISNULL(PO_ITEM_NO, '') = ISNULL(@poItemNo, '') AND SEQ_ITEM_NO = @seqItemNo AND SEQ_NO = @seqNo)
        
        SET @message = 'I|Delete data in TB_T_PO_D_TEMP where PROCESS_ID: ' + CAST(@processId AS VARCHAR) + ' and PO_NO: ' + ISNULL(@poNo, 'NULL') + ' and PO_ITEM_NO: ' + ISNULL(@poItemNo, 'NULL') + ' and SEQ_ITEM_NO: ' + CAST(@seqItemNo AS VARCHAR) + ' and COMP_PRICE_CD: ' + @compPriceCode + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
        UPDATE TB_T_PO_CONDITION SET DELETE_FLAG = 'Y' WHERE PROCESS_ID = @processId AND ISNULL(PO_NO, '') = ISNULL(@poNo, '') AND ISNULL(PO_ITEM_NO, '') = ISNULL(@poItemNo, '') AND SEQ_ITEM_NO = @seqItemNo AND SEQ_NO = @seqNo
        SET @message = 'I|Delete data in TB_T_PO_D_TEMP where PROCESS_ID: ' + CAST(@processId AS VARCHAR) + ' and PO_NO: ' + ISNULL(@poNo, 'NULL') + ' and PO_ITEM_NO: ' + ISNULL(@poItemNo, 'NULL') + ' and SEQ_ITEM_NO: ' + CAST(@seqItemNo AS VARCHAR) + ' and COMP_PRICE_CD: ' + @compPriceCode + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
        
        COMMIT TRAN DeleteConditionTemp
        
        SET @message = 'S|Finish'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN DeleteConditionTemp
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ' - ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
    END CATCH
    
    EXEC sp_PutLog_Temp @tmpLog
    SET NOCOUNT OFF
    SELECT @message [Message]
END