DECLARE @@message VARCHAR(MAX)

SET NOCOUNT ON
BEGIN TRY
    BEGIN TRAN RegisterNew

    INSERT INTO TB_R_BACKGROUND_SCHEDULE
			([SYSTEM_TYPE]
           ,[SYSTEM_CD]
           ,[EXECUTION_DATE]
           ,[EXECUTION_TIME]
           ,[SCH_STATUS]
           ,[START_TIME]
           ,[END_TIME]
           ,[PROCESS_ID]
           ,[CREATED_BY]
           ,[CREATED_DT]
           ,[CHANGED_BY]
           ,[CHANGED_DT])
    VALUES (@SystemType, @SystemCode, @PlanExecutionTime, @PlanExecutionTime, @Status, @ActualExecutionTime, NULL, @ProcessId, 'BudgetDataImportSvc', GETDATE(), NULL, NULL)

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