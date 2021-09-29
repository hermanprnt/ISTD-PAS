CREATE PROCEDURE [dbo].[sp_POCreation_ResetItemTemp]
    @currentUser VARCHAR(50),
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6)
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = '[sp_POCreation_ResetItemTemp]',
        @tmpLog LOG_TEMP
    
    SET @message = 'I|Start'
    EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0
    
    BEGIN TRY
        BEGIN TRAN ResetItemTemp
        
        SET @message = 'I|Reset TB_T_PO_ITEM: begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
        DELETE FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId
        SET @message = 'I|Reset TB_T_PO_ITEM: end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
        
        SET @message = 'I|Reset TB_T_PO_SUBITEM: begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
        DELETE FROM TB_T_PO_SUBITEM WHERE PROCESS_ID = @processId
        SET @message = 'I|Reset TB_T_PO_SUBITEM: end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        SET @message = 'I|Reset TB_T_PO_CONDITION: begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
        DELETE FROM TB_T_PO_CONDITION WHERE PROCESS_ID = @processId
        SET @message = 'I|Reset TB_T_PO_CONDITION: end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        COMMIT TRAN ResetItemTemp
        
        SET @message = 'S|Finish'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN ResetItemTemp
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ' - ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
    END CATCH
    
    EXEC sp_PutLog_Temp @tmpLog
    SET NOCOUNT OFF
    SELECT @message [Message]
END

