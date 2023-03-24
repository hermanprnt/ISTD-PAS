DECLARE @@status VARCHAR(MAX)
EXEC [dbo].[sp_common_sendmail] NULL, NULL, @FunctionId, '1', @ProcessResult, @@status OUTPUT


DECLARE @@currentUser VARCHAR(25) = 'SAPBudgetSynch'
DECLARE @@internalProcessId BIGINT = @ProcessId
IF @@internalProcessId = 0
BEGIN
    INSERT INTO dbo.TB_R_LOG_H
    (process_dt, function_id, process_sts, [user_id], end_dt, remarks)
    VALUES (GETDATE(), @FunctionId, 0, @@currentUser, GETDATE(),'BudgetDataImporterSvc')

    SELECT @@internalProcessId = ISNULL(MAX(process_id), 0) + 1 FROM TB_R_LOG_H WHERE [user_id] = @@currentUser
END

INSERT INTO dbo.TB_R_LOG_D
(process_id, seq_no, msg_id, msg_type, err_location, err_message, err_dt)
VALUES (@@internalProcessId, (SELECT ISNULL(MAX(seq_no), 0) + 1 FROM TB_R_LOG_D WHERE process_id = @@internalProcessId),
'INF', 'INF', 'Send Mail', @@status, GETDATE())

SELECT @@status [Status]