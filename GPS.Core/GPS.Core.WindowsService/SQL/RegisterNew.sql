DECLARE @@message VARCHAR(MAX)

SET NOCOUNT ON
BEGIN TRY
    BEGIN TRAN RegisterNew

    INSERT INTO TB_R_BACKGROUND_SCHEDULE
    VALUES (@FunctionId, @SystemCode, @PlanExecutionTime, @PlanExecutionTime, @Status, @ActualExecutionTime, NULL, @ProcessId, 'GRDataExporterSvc', GETDATE(), NULL, NULL)

    COMMIT TRAN RegisterNew
    SET @@message = 'S|Finish'
END TRY
BEGIN CATCH
    ROLLBACK TRAN RegisterNew
    SET @@message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
    RAISERROR (@@message, 16, 1)
END CATCH

SET NOCOUNT OFF

SELECT @@message