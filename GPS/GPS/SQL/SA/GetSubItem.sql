﻿SELECT [PO_NO]
      ,[PO_ITEM_NO]
      ,[PO_SUBITEM_NO]
      ,[MAT_NO]
      ,[MAT_DESC]
      ,[WBS_NO]
      ,[WBS_NAME]
      ,[GL_ACCOUNT]
      ,[COST_CENTER_CD]
      ,[UNLIMITED_FLAG]
      ,[TOLERANCE_PERCENTAGE]
      ,[SPECIAL_PROCUREMENT_TYPE]
      ,CAST([PO_QTY_ORI] AS FLOAT) AS PO_QTY_ORI
      ,CAST([PO_QTY_USED] AS FLOAT) AS PO_QTY_USED
      ,CAST(PO_QTY_REMAIN AS FLOAT) AS PO_QTY_REMAIN
      ,[UOM]
      ,[PRICE_PER_UOM]
      ,[ORI_AMOUNT]
      ,[LOCAL_AMOUNT] as ORI_AMOUNT
      ,[CREATED_BY]
      ,[CREATED_DT]
      ,[CHANGED_BY]
      ,[CHANGED_DT]
  FROM [dbo].[TB_R_PO_SUBITEM] where
  [PO_NO]=@PO and [PO_ITEM_NO]=@ITEM_NO order by PO_QTY_REMAIN desc

