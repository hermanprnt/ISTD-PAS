BEGIN
    DECLARE
        @@message VARCHAR(MAX),
        @@actionName VARCHAR(50) = 'SADataExporter_UpdateSAToPosting.sql',
        @@tmpLog LOG_TEMP,
        @@currentUser VARCHAR(50) = 'SADataExporter'

    SET NOCOUNT ON
    BEGIN TRY
        INSERT INTO @@tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Start', @ModuleId, @@actionName, @FunctionId, 1, @@currentUser)

        BEGIN TRAN UpdatePosting

        UPDATE TB_R_GR_IR SET STATUS_CD = '61' WHERE PROCESS_ID = @ProcessId
        UPDATE TB_R_GR_IR SET PROCESS_ID = NULL WHERE PROCESS_ID = @ProcessId

        COMMIT TRAN UpdatePosting

        INSERT INTO @@tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', 'S|Finish', @ModuleId, @@actionName, @FunctionId, 2, @@currentUser)
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN UpdatePosting
        SET @@message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
        INSERT INTO @@tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @@message, @ModuleId, @@actionName, @FunctionId, 3, @@currentUser)
    END CATCH

    EXEC sp_putLog_Temp @@tmpLog
    SET NOCOUNT OFF

    SELECT @@message [Message]
END
