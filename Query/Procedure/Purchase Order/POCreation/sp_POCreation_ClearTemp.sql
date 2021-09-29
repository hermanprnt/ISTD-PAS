CREATE PROCEDURE [dbo].[sp_POCreation_ClearTemp]
    @currentUser VARCHAR(50),
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6)
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = 'sp_POCreation_ClearTemp',
        @tmpLog LOG_TEMP

    BEGIN TRY
        SET @message = 'I|Start'
        EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0
		
		DECLARE @PROCESS_TEMP AS TABLE (PROCESS_ID BIGINT)
		
        BEGIN TRAN ClearTemp

        SET @message = 'I|Delete data from TB_T_PO_H where CREATED_BY = ' + @currentUser + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

		INSERT INTO @PROCESS_TEMP SELECT PROCESS_ID FROM TB_T_PO_H WHERE CREATED_BY = @currentUser
        DELETE FROM TB_T_PO_H WHERE CREATED_BY = @currentUser

        SET @message = 'I|Delete data from TB_T_PO_H where CREATED_BY = ' + @currentUser + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        SET @message = 'I|Delete data from TB_T_PO_ITEM where CREATED_BY = ' + @currentUser + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        DELETE FROM TB_T_PO_ITEM WHERE CREATED_BY = @currentUser
        UPDATE TB_R_PR_ITEM SET PROCESS_ID = NULL WHERE PROCESS_ID IN (SELECT PROCESS_ID FROM @PROCESS_TEMP)

        SET @message = 'I|Delete data from TB_T_PO_ITEM where CREATED_BY = ' + @currentUser + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        SET @message = 'I|Delete data from TB_T_PO_SUBITEM where CREATED_BY = ' + @currentUser + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        DELETE FROM TB_T_PO_SUBITEM WHERE CREATED_BY = @currentUser

        SET @message = 'I|Delete data from TB_T_PO_SUBITEM where CREATED_BY = ' + @currentUser + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        SET @message = 'I|Delete data from TB_T_PO_CONDITION where CREATED_BY = ' + @currentUser + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        DELETE FROM TB_T_PO_CONDITION WHERE CREATED_BY = @currentUser

        SET @message = 'I|Delete data from TB_T_PO_CONDITION where CREATED_BY = ' + @currentUser + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

		-- Release Process Id locking
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Release Process Id locking in TB_R_PO_H, TB_R_ASSET: begin', @moduleId, @actionName, @functionId, 1, @currentUser)
        UPDATE TB_R_PO_H SET PROCESS_ID = NULL WHERE PROCESS_ID = @processId
		UPDATE TB_R_PR_ITEM SET PROCESS_ID = NULL WHERE PROCESS_ID = @processId
        UPDATE TB_R_ASSET SET PROCESS_ID = NULL WHERE PROCESS_ID = @processId
		DELETE FROM TB_T_LOCK WHERE PROCESS_ID = @processId
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Release Process Id locking in TB_R_PO_H, TB_R_ASSET: end', @moduleId, @actionName, @functionId, 1, @currentUser)
		
        COMMIT TRAN ClearTemp

        SET @message = 'S|Finish'
        EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @processId OUTPUT, 'SUC', 'SUC', @moduleId, @functionId, 2
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN ClearTemp
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
    END CATCH

    EXEC sp_PutLog_Temp @tmpLog
    SET NOCOUNT OFF
    SELECT @message [Message]
END