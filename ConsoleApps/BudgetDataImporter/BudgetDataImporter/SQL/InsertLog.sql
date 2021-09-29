DECLARE @@PROCESS_ID INT

--Note: If Log H not yet inserted
SET @@PROCESS_ID = @PROCESS_ID
IF(@PROCESS_ID = 0)
BEGIN
	INSERT INTO [dbo].[TB_R_LOG_H]
           ([process_dt]
           ,[function_id]
           ,[process_sts]
           ,[user_id]
           ,[end_dt]
           ,[remarks])
     VALUES
           (GETDATE()
           ,''
           ,0
           ,'SAPBudgetSynch'
           ,GETDATE()
           ,'BudgetDataImporterSvc')
	SELECT @@PROCESS_ID = ISNULL(MAX(process_id), 0) + 1 FROM TB_R_LOG_H WHERE [user_id] = 'SAPBudgetSynch'
END

INSERT INTO [dbo].[TB_R_LOG_D]
           ([process_id]
           ,[seq_no]
           ,[msg_id]
           ,[msg_type]
           ,[err_location]
           ,[err_message]
           ,[err_dt])
     VALUES
           (@@PROCESS_ID
           ,(SELECT ISNULL(MAX(seq_no), 0) + 1 FROM TB_R_LOG_D WHERE process_id = @@PROCESS_ID)
           ,@MSG_TYPE
           ,@MSG_TYPE
           ,@LOCATION
           ,@MSG
           ,GETDATE())

SELECT @@PROCESS_ID