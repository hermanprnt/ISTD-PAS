CREATE PROCEDURE [dbo].[sp_Material_Initial]
    @currentUser VARCHAR(50),
    @processId BIGINT OUTPUT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(5)
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = 'sp_Material_Initial',
        @tmpLog LOG_TEMP
    
    BEGIN TRY
        SET @message = 'I|Start'
        EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0
    
        BEGIN TRAN Initial
        
        SET @message = 'I|Delete data from TB_T_MATERIAL_TEMP where CREATED_BY = ' + @currentUser + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
        
        DELETE FROM TB_T_MATERIAL_TEMP WHERE CREATED_BY = @currentUser
        
        SET @message = 'I|Delete data from TB_T_MATERIAL_TEMP where CREATED_BY = ' + @currentUser + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
        
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Get ProcessId: begin', @moduleId, @actionName, @functionId, 1, @currentUser)
        DECLARE @unfinishProcessIdList TABLE ( Id VARCHAR(50) )
        INSERT INTO @unfinishProcessIdList
        SELECT PROCESS_ID FROM TB_R_LOG_H WHERE CREATED_BY = @currentUser AND FUNCTION_ID = @functionId AND GETDATE() > CREATED_DT AND PROCESS_STATUS = 1 
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Get ProcessId: end', @moduleId, @actionName, @functionId, 1, @currentUser)
        
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Update unfinish process Log status: begin', @moduleId, @actionName, @functionId, 1, @currentUser)
        UPDATE TB_R_LOG_H SET PROCESS_STATUS = 4, CHANGED_BY = 'System', CHANGED_DT = GETDATE() WHERE PROCESS_ID IN (SELECT Id FROM @unfinishProcessIdList)
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Update unfinish process Log status: end', @moduleId, @actionName, @functionId, 1, @currentUser)
        
        COMMIT TRAN Initial
        
        SET @message = 'S|Finish'
        EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @processId OUTPUT, 'SUC', 'SUC', @moduleId, @functionId, 2
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN Initial
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
    END CATCH
    
    EXEC sp_PutLog_Temp @tmpLog
    SET NOCOUNT OFF
    SELECT @processId ProcessId, @message [Message]
END