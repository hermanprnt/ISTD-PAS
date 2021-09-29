CREATE PROCEDURE [dbo].[sp_POCreation_DeleteItemTemp]
    @currentUser VARCHAR(50),
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6),
    @poNo VARCHAR(11),
    @poItemNo INT,
    @seqItemNo INT
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = 'sp_POCreation_DeleteItemTemp',
        @tmpLog LOG_TEMP

    SET @message = 'I|Start'
    EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0

    BEGIN TRY
        BEGIN TRAN DeleteItemTemp

        SET @message = 'I|Delete data in TB_T_PO_ITEM where PO_NO: ' + ISNULL(@poNo, 'NULL') + ' and PO_ITEM_NO: ' + ISNULL(CAST(@poItemNo AS VARCHAR), 'NULL') + ' and SEQ_ITEM_NO: ' + CAST(@seqItemNo AS VARCHAR) + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
        UPDATE TB_T_PO_ITEM SET DELETE_FLAG = 'Y' WHERE PROCESS_ID = @processId AND ISNULL(PO_NO, '') = ISNULL(@poNo, '') AND ISNULL(PO_ITEM_NO, '') = ISNULL(@poItemNo, '') AND SEQ_ITEM_NO = @seqItemNo
        SET @message = 'I|Delete data in TB_T_PO_ITEM where PO_NO: ' + ISNULL(@poNo, 'NULL') + ' and PO_ITEM_NO: ' + ISNULL(CAST(@poItemNo AS VARCHAR), 'NULL') + ' and SEQ_ITEM_NO: ' + CAST(@seqItemNo AS VARCHAR) + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        SET @message = 'I|Delete data in TB_T_PO_SUBITEM where PO_NO: ' + ISNULL(@poNo, 'NULL') + ' and PO_ITEM_NO: ' + ISNULL(CAST(@poItemNo AS VARCHAR), 'NULL') + ' and SEQ_ITEM_NO: ' + CAST(@seqItemNo AS VARCHAR) + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
        UPDATE TB_T_PO_SUBITEM SET DELETE_FLAG = 'Y' WHERE PROCESS_ID = @processId AND ISNULL(PO_NO, '') = ISNULL(@poNo, '') AND ISNULL(PO_ITEM_NO, '') = ISNULL(@poItemNo, '') AND SEQ_ITEM_NO = @seqItemNo
        SET @message = 'I|Delete data in TB_T_PO_SUBITEM where PO_NO: ' + ISNULL(@poNo, 'NULL') + ' and PO_ITEM_NO: ' + ISNULL(CAST(@poItemNo AS VARCHAR), 'NULL') + ' and SEQ_ITEM_NO: ' + CAST(@seqItemNo AS VARCHAR) + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        SET @message = 'I|Delete data in TB_T_PO_SUBITEM where PO_NO: ' + ISNULL(@poNo, 'NULL') + ' and PO_ITEM_NO: ' + ISNULL(CAST(@poItemNo AS VARCHAR), 'NULL') + ' and SEQ_ITEM_NO: ' + CAST(@seqItemNo AS VARCHAR) + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
        UPDATE TB_T_PO_CONDITION SET DELETE_FLAG = 'Y' WHERE PROCESS_ID = @processId AND ISNULL(PO_NO, '') = ISNULL(@poNo, '') AND ISNULL(PO_ITEM_NO, '') = ISNULL(@poItemNo, '') AND SEQ_ITEM_NO = @seqItemNo
        SET @message = 'I|Delete data in TB_T_PO_SUBITEM where PO_NO: ' + ISNULL(@poNo, 'NULL') + ' and PO_ITEM_NO: ' + ISNULL(CAST(@poItemNo AS VARCHAR), 'NULL') + ' and SEQ_ITEM_NO: ' + CAST(@seqItemNo AS VARCHAR) + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        SET @message = 'I|Rollback asset lock where process id: ' + CAST(ISNULL(@processId, 'NULL') AS VARCHAR) + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
        UPDATE TB_R_ASSET SET PROCESS_ID = NULL WHERE PROCESS_ID = @processId
        SET @message = 'I|Rollback asset lock where process id: ' + CAST(ISNULL(@processId, 'NULL') AS VARCHAR) + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        COMMIT TRAN DeleteItemTemp

        SET @message = 'S|Finish'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN DeleteItemTemp
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ' - ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
    END CATCH

    EXEC sp_PutLog_Temp @tmpLog
    SET NOCOUNT OFF
    SELECT @message [Message]
END