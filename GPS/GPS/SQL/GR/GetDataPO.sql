﻿
SELECT A.[PO_NO]
      ,A.[PO_DESC]
      ,A.[VENDOR_CD]
      ,A.[VENDOR_NAME] AS VENDOR
      ,A.[DOC_DT]
      ,A.[PROC_MONTH] AS MONTH
      ,A.[PAYMENT_METHOD_CD]
      ,A.[PAYMENT_TERM_CD]
      ,A.[DOC_TYPE]
      ,A.[DOC_CATEGORY]
      ,A.[PURCHASING_GRP_CD]   AS PURCHASE_GROUP
      ,A.[INV_WO_GR_FLAG]
      ,A.[PO_CURR]
      ,A.[PO_AMOUNT]
      ,A.[PO_EXCHANGE_RATE]
      ,A.[LOCAL_CURR]
      ,A.[PO_STATUS]
      ,A.[RELEASED_FLAG]
      ,A.[RELEASED_DT]
      ,A.[DELETION_FLAG]
      ,A.[PROCESS_ID]
      ,A.[CREATED_BY]
      ,A.[CREATED_DT]
      ,A.[CHANGED_BY]
      ,A.[CHANGED_DT]
      ,A.[SAP_DOC_NO]
      ,A.[URGENT_DOC]
  FROM [dbo].[TB_R_PO_H] A 
 -- LEFT JOIN TB_M_PURCHASING_GRP B ON A.[PURCHASING_GRP_CD]=B.[PURCHASING_GRP_CD]
    where PO_NO=@PO 


