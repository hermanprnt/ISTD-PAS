SET NOCOUNT ON

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
           ,'Set Scheduler for Budget Service')

SET NOCOUNT OFF
SELECT ISNULL(MAX(process_id), 0) FROM TB_R_LOG_H WHERE [user_id] = 'SAPBudgetSynch'