﻿
SELECT [PO_NO]
      ,[PO_ITEM_NO]
      ,[COMP_PRICE_CD] 
      ,[COMP_PRICE_RATE]
      ,[INVOICE_FLAG]
      ,[EXCHANGE_RATE]
      ,[SEQ_NO]
      ,[BASE_VALUE_FROM]
      ,[BASE_VALUE_TO]
      ,[PO_CURR]
      ,[INVENTORY_FLAG]
      ,[CALCULATION_TYPE]
      ,[PLUS_MINUS_FLAG]
      ,[CONDITION_CATEGORY]
      ,[ACCRUAL_FLAG_TYPE]
      ,[CONDITION_RULE]
      ,[QTY]
      ,[QTY_PER_UOM]
      ,[PRICE_AMT]
      ,[COMP_TYPE]
      ,[PRINT_STATUS]
      ,[CREATED_BY]
      ,[CREATED_DT]
      ,[CHANGED_BY]
      ,[CHANGED_DT]
  FROM [dbo].[TB_R_PO_CONDITION] where PO_NO=@PO


