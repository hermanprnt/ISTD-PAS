﻿INSERT INTO [dbo].[TB_T_COST_CENTER_GRP]
           ([COST_CENTER_GRP_CD]
           ,[COST_CENTER_GRP_DESC]
           ,[DIVISION_CD]
           ,[CREATED_BY]
           ,[CREATED_DT]
           ,[CHANGED_BY]
           ,[CHANGED_DT]
           ,[PROCESS_ID]
           ,[ROW]
           ,[ERROR_FLAG])
     VALUES
           (@CostGroup
           ,@CostGroupDesc
           ,@DivisionCd
           ,@CreatedBy
           ,GETDATE()
           ,null
           ,null
           ,@ProcessId
           ,@Row
           ,@ErrorFlag)