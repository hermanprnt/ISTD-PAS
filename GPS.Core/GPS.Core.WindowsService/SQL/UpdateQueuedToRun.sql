DECLARE @@message VARCHAR(MAX)

SET NOCOUNT ON
BEGIN TRY
    BEGIN TRAN UpdateQueued

    UPDATE dbo.TB_R_BACKGROUND_SCHEDULE
    SET PROCESS_ID = @ProcessId, SCH_STATUS = @Status, START_TIME = @ActualExecutionTime, CHANGED_BY = 'GRDataExporterSvc', CHANGED_DT = GETDATE()

    COMMIT TRAN UpdateQueued
    SET @@message = 'S|Finish'
END TRY
BEGIN CATCH
    ROLLBACK TRAN UpdateQueued
    SET @@message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
    RAISERROR (@@message, 16, 1)
END CATCH

SET NOCOUNT OFF

SELECT @@message