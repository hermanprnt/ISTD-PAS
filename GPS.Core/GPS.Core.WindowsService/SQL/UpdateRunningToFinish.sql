DECLARE @@message VARCHAR(MAX)

SET NOCOUNT ON
BEGIN TRY
    BEGIN TRAN UpdateRunning

    UPDATE dbo.TB_R_BACKGROUND_SCHEDULE
    SET SCH_STATUS = @Status, END_TIME = @ActualExecutionTime, CHANGED_BY = 'GRDataExporterSvc', CHANGED_DT = GETDATE()

    COMMIT TRAN UpdateRunning
    SET @@message = 'S|Finish'
END TRY
BEGIN CATCH
    ROLLBACK TRAN UpdateRunning
    SET @@message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
    RAISERROR (@@message, 16, 1)
END CATCH

SET NOCOUNT OFF

SELECT @@message