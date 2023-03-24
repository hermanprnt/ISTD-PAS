﻿DECLARE @@PROCESS_ID BIGINT

EXEC [dbo].[sp_PutLog] 'Locking PO No for Posting to SAP', 'SYSTEM', 'SAP PO Synchronous Service', @@PROCESS_ID OUTPUT, 'INF', 'INF', '0', '001001', 2

INSERT INTO [dbo].[TB_T_LOCK]
			([PROCESS_ID]
			,[MODULE_ID]
			,[FUNCTION_ID]
			,[USER_ID]
			,[USER_NAME]
			,[CREATED_BY]
			,[CREATED_DT]
			,[CHANGED_BY]
			,[CHANGED_DT])
		VALUES
			(@@PROCESS_ID
			,'0'
			,'001001'
			,'SYSTEM'
			,'SYSTEM'
			,'SYSTEM'
			,GETDATE()
			,NULL
			,NULL)

UPDATE TB_R_PO_H SET PROCESS_ID = @@PROCESS_ID
WHERE PO_STATUS = '43' AND ISNULL(SAP_DOC_NO, '') = '' AND ISNULL(PROCESS_ID, '') = ''

SELECT 
		ISNULL(POH.PO_NO, '') + '\t' +
		ISNULL(POH.VENDOR_CD, '') + '\t' +
		ISNULL(POH.PAYMENT_TERM_CD, '') + '\t' +
		ISNULL(MC.PROC_CHANNEL_CD, '') + '\t' +
		ISNULL(POH.PURCHASING_GRP_CD, '') + '\t' +
		CASE WHEN(ER.DECIMAL_FORMAT = '0') THEN REPLACE(ISNULL(CAST(CAST(POH.PO_EXCHANGE_RATE AS DECIMAL(14, 0)) AS VARCHAR), ''), '.', ',') 
			 WHEN(ER.DECIMAL_FORMAT = '1') THEN REPLACE(ISNULL(CAST(CAST(POH.PO_EXCHANGE_RATE AS DECIMAL(15, 1)) AS VARCHAR), ''), '.', ',')
			 WHEN(ER.DECIMAL_FORMAT = '2') THEN REPLACE(ISNULL(CAST(CAST(POH.PO_EXCHANGE_RATE AS DECIMAL(16, 2)) AS VARCHAR), ''), '.', ',')
			 WHEN(ER.DECIMAL_FORMAT = '3') THEN REPLACE(ISNULL(CAST(CAST(POH.PO_EXCHANGE_RATE AS DECIMAL(17, 3)) AS VARCHAR), ''), '.', ',')
			 WHEN(ER.DECIMAL_FORMAT = '4') THEN REPLACE(ISNULL(CAST(CAST(POH.PO_EXCHANGE_RATE AS DECIMAL(18, 4)) AS VARCHAR), ''), '.', ',')
			 ELSE REPLACE(ISNULL(CAST(CAST(POI.PRICE_PER_UOM AS DECIMAL(18, 4)) AS VARCHAR), ''), '.', ',')
		END + '\t' +
		ISNULL(POH.PO_CURR, '') + '\t' +
		ISNULL([dbo].[fn_date_format](POH.DOC_DT), '') + '\t' +
		ISNULL(POH.PO_NOTE1, '') + '\t' +
		ISNULL(POH.PO_NOTE2, '') + '\t' +
		ISNULL(POH.PO_NOTE3, '') + '\t' +
		ISNULL(POH.PO_NOTE4, '') + '\t' +
		ISNULL(POH.PO_NOTE5, '') + '\t' +
		ISNULL(POH.PO_NOTE6, '') + '\t' +
		ISNULL(POH.PO_NOTE7, '') + '\t' +
		ISNULL(POH.PO_NOTE8, '') + '\t' +
		ISNULL(POH.PO_NOTE9, '') + '\t' +
		ISNULL(POH.PO_NOTE10, '') + '\t' +
		CASE WHEN(POH.VENDOR_CD = '700001') THEN POH.VENDOR_NAME ELSE '' END  + '\t' +
		CASE WHEN(ISNULL(POH.VENDOR_ADDRESS, '') = '' OR ISNULL(POH.VENDOR_ADDRESS, '') = '-') THEN '' ELSE POH.VENDOR_ADDRESS END + '\t' +
		CASE WHEN(ISNULL(POH.POSTAL_CODE, '') = '' OR ISNULL(POH.POSTAL_CODE, '') = '-') THEN '' ELSE POH.POSTAL_CODE END + '\t' + 
		CASE WHEN(ISNULL(POH.CITY, '') = '' OR ISNULL(POH.CITY, '') = '-') THEN '' ELSE POH.CITY END + '\t' +
		CASE WHEN(ISNULL(POH.COUNTRY, '') = '' OR ISNULL(POH.COUNTRY, '') = '-') THEN '' ELSE POH.COUNTRY END + '\t' + 
		CASE WHEN(ISNULL(POH.PHONE, '') = '' OR ISNULL(POH.PHONE, '') = '-') THEN '' ELSE POH.PHONE END + '\t' + 
		CASE WHEN(ISNULL(POH.FAX, '') = '' OR ISNULL(POH.FAX, '') = '-') THEN '' ELSE POH.FAX END + '\t' + 
		ISNULL(POI.PO_ITEM_NO, '') + '\t' +
		ISNULL(POI.MAT_DESC, '') + '\t' + 
		CASE WHEN(ISNULL(POI.MAT_NO, '') = '' OR ISNULL(POI.MAT_NO, '') = 'X') THEN '' ELSE POI.MAT_NO END + '\t' +
		ISNULL(POI.PLANT_CD, '') + '\t' +
		ISNULL(POI.SLOC_CD, '') + '\t' +
		CASE WHEN ((ISNULL(POI.MAT_NO, '') = '') OR (ISNULL(POI.MAT_NO, '') = 'X')) THEN ISNULL(VC.MATL_GROUP, '')
			 ELSE (CASE WHEN(ISNULL(MP.MATL_GROUP, '') = '') THEN (CASE WHEN(ISNULL(MNP.MATL_GROUP, '') = '') THEN '' ELSE MNP.MATL_GROUP END) ELSE MP.MATL_GROUP END)
			 END + '\t' +
		CASE WHEN(ER.DECIMAL_FORMAT = '0') THEN REPLACE(ISNULL(CAST(CAST(POI.PO_QTY_ORI AS DECIMAL(14, 0)) AS VARCHAR), ''), '.', ',') 
			 WHEN(ER.DECIMAL_FORMAT = '1') THEN REPLACE(ISNULL(CAST(CAST(POI.PO_QTY_ORI AS DECIMAL(15, 1)) AS VARCHAR), ''), '.', ',')
			 WHEN(ER.DECIMAL_FORMAT = '2') THEN REPLACE(ISNULL(CAST(CAST(POI.PO_QTY_ORI AS DECIMAL(16, 2)) AS VARCHAR), ''), '.', ',')
			 WHEN(ER.DECIMAL_FORMAT = '3') THEN REPLACE(ISNULL(CAST(CAST(POI.PO_QTY_ORI AS DECIMAL(17, 3)) AS VARCHAR), ''), '.', ',')
			 WHEN(ER.DECIMAL_FORMAT = '4') THEN REPLACE(ISNULL(CAST(CAST(POI.PO_QTY_ORI AS DECIMAL(18, 4)) AS VARCHAR), ''), '.', ',')
			 ELSE REPLACE(ISNULL(CAST(CAST(POI.PRICE_PER_UOM AS DECIMAL(18, 4)) AS VARCHAR), ''), '.', ',')
		END + '\t' + 
		ISNULL(POI.UOM, '') + '\t' +
		ISNULL(POI.UOM, '') + '\t' +
		'1' + '\t' +
		CASE WHEN(ER.DECIMAL_FORMAT = '0') THEN REPLACE(ISNULL(CAST(CAST(POI.PRICE_PER_UOM AS DECIMAL(20, 0)) AS VARCHAR), ''), '.', ',') 
			 WHEN(ER.DECIMAL_FORMAT = '1') THEN REPLACE(ISNULL(CAST(CAST(POI.PRICE_PER_UOM AS DECIMAL(20, 1)) AS VARCHAR), ''), '.', ',')
			 WHEN(ER.DECIMAL_FORMAT = '2') THEN REPLACE(ISNULL(CAST(CAST(POI.PRICE_PER_UOM AS DECIMAL(20, 2)) AS VARCHAR), ''), '.', ',')
			 WHEN(ER.DECIMAL_FORMAT = '3') THEN REPLACE(ISNULL(CAST(CAST(POI.PRICE_PER_UOM AS DECIMAL(20, 3)) AS VARCHAR), ''), '.', ',')
			 WHEN(ER.DECIMAL_FORMAT = '4') THEN REPLACE(ISNULL(CAST(CAST(POI.PRICE_PER_UOM AS DECIMAL(20, 4)) AS VARCHAR), ''), '.', ',')
			 ELSE REPLACE(ISNULL(CAST(CAST(POI.PRICE_PER_UOM AS DECIMAL(20, 5)) AS VARCHAR), ''), '.', ',')
		END
			+ '\t' +
		CASE WHEN(POI.ITEM_CLASS = 'S') THEN 'D' ELSE '' END + '\t' +
		CASE WHEN((SUBSTRING(POI.WBS_NO, 1, 1) = 'P' OR SUBSTRING(POI.WBS_NO, 1, 1) = 'S') AND POI.ITEM_CLASS = 'M') THEN 'P'
			 WHEN((SUBSTRING(POI.WBS_NO, 1, 1) = 'I' OR SUBSTRING(POI.WBS_NO, 1, 1) = 'L') AND POI.ITEM_CLASS = 'M') THEN 'A'
			 WHEN (POI.ITEM_CLASS = 'S' AND ISNULL(RA.ASSET_NO, '') <> '') THEN 'A'
			 ELSE 'Z' END + '\t' +
		ISNULL([dbo].[fn_date_format](POI.DELIVERY_PLAN_DT), '') + '\t' +
		CASE 
			WHEN ((ISNULL(POI.GL_ACCOUNT, '') = '' OR ISNULL(POI.GL_ACCOUNT, '') = 'X') AND POI.ITEM_CLASS = 'M') THEN ''
			WHEN ((ISNULL(POS.GL_ACCOUNT, '') = '' OR ISNULL(POS.GL_ACCOUNT, '') = 'X') AND POI.ITEM_CLASS = 'S') THEN ''
			WHEN ((ISNULL(POS.GL_ACCOUNT, '') <> '' OR ISNULL(POS.GL_ACCOUNT, '') <> 'X') AND POI.ITEM_CLASS = 'S') THEN POS.GL_ACCOUNT
			ELSE POI.GL_ACCOUNT END + '\t' +
		CASE WHEN((SUBSTRING(POI.WBS_NO, 1, 1) = 'I' OR SUBSTRING(POI.WBS_NO, 1, 1) = 'L') AND POI.ITEM_CLASS = 'M') THEN ''
			 WHEN (POI.ITEM_CLASS = 'S' AND ISNULL(RA.ASSET_NO, '') <> '') THEN ''
			 ELSE (CASE 
				WHEN ((ISNULL(POI.COST_CENTER_CD, '') = '' OR ISNULL(POI.COST_CENTER_CD, '') = 'X') AND POI.ITEM_CLASS = 'M') THEN '' 
				WHEN ((ISNULL(POS.COST_CENTER_CD, '') = '' OR ISNULL(POS.COST_CENTER_CD, '') = 'X') AND POI.ITEM_CLASS = 'S') THEN '' 
				WHEN ((ISNULL(POS.COST_CENTER_CD, '') <> '' OR ISNULL(POS.COST_CENTER_CD, '') <> 'X') AND POI.ITEM_CLASS = 'S') THEN POS.COST_CENTER_CD
				ELSE POI.COST_CENTER_CD END) END + '\t' +
		ISNULL(RA.ASSET_NO, '') + '\t' +
		ISNULL(RA.SUB_ASSET_NO, '') + '\t' +
		CASE 
			WHEN ((ISNULL(POI.WBS_NO, '') = '' OR ISNULL(POI.WBS_NO, '') = 'X') AND POI.ITEM_CLASS = 'M') THEN '' 
			WHEN ((ISNULL(POS.WBS_NO, '') = '' OR ISNULL(POS.WBS_NO, '') = 'X') AND POI.ITEM_CLASS = 'S') THEN '' 
			WHEN ((ISNULL(POS.WBS_NO, '') <> '' OR ISNULL(POS.WBS_NO, '') <> 'X') AND POI.ITEM_CLASS = 'S') THEN POS.WBS_NO
			ELSE POI.WBS_NO END + '\t' +
		ISNULL(POS.PO_SUBITEM_NO, '') + '\t' +
		REPLACE(ISNULL(CAST(CAST(POS.PO_QTY_ORI AS DECIMAL(9, 3)) AS VARCHAR), ''), '.', ',') + '\t' +
		ISNULL(POS.UOM, '') + '\t' +
		CASE WHEN(POI.ITEM_CLASS = 'M') THEN '' ELSE '1' END + '\t' +
		CASE WHEN(ER.DECIMAL_FORMAT = '0') THEN REPLACE(ISNULL(CAST(CAST(POS.PRICE_PER_UOM AS DECIMAL(20, 0)) AS VARCHAR), ''), '.', ',') 
			 WHEN(ER.DECIMAL_FORMAT = '1') THEN REPLACE(ISNULL(CAST(CAST(POS.PRICE_PER_UOM AS DECIMAL(20, 1)) AS VARCHAR), ''), '.', ',') 
			 WHEN(ER.DECIMAL_FORMAT = '2') THEN REPLACE(ISNULL(CAST(CAST(POS.PRICE_PER_UOM AS DECIMAL(20, 2)) AS VARCHAR), ''), '.', ',') 
			 WHEN(ER.DECIMAL_FORMAT = '3') THEN REPLACE(ISNULL(CAST(CAST(POS.PRICE_PER_UOM AS DECIMAL(20, 3)) AS VARCHAR), ''), '.', ',') 
			 WHEN(ER.DECIMAL_FORMAT = '4') THEN REPLACE(ISNULL(CAST(CAST(POS.PRICE_PER_UOM AS DECIMAL(20, 4)) AS VARCHAR), ''), '.', ',') 
			 ELSE REPLACE(ISNULL(CAST(CAST(POS.PRICE_PER_UOM AS DECIMAL(20, 5)) AS VARCHAR), ''), '.', ',') 
		END
			+ '\t' +
		ISNULL(POS.MAT_DESC, '') + '\t' + 
		ISNULL(MDA.DELIVERY_NAME, '') + '\t' + 
		CASE WHEN(ISNULL(MDA.[ADDRESS], '') = '' OR ISNULL(MDA.[ADDRESS], '') = '-') THEN '' ELSE MDA.[ADDRESS] END + '\t' +
		CASE WHEN(ISNULL(MDA.POSTAL_CODE, '') = '' OR ISNULL(MDA.POSTAL_CODE, '') = '-') THEN '' ELSE MDA.POSTAL_CODE END + '\t' +
		CASE WHEN(ISNULL(MDA.CITY, '') = '' OR ISNULL(MDA.CITY, '') = '-') THEN '' ELSE MDA.CITY END AS DATA_PO
FROM TB_R_PO_H POH 
	INNER JOIN TB_R_PO_ITEM POI ON POH.PO_NO = POI.PO_NO
	INNER JOIN TB_M_COORDINATOR MC ON MC.COORDINATOR_CD = POH.PURCHASING_GRP_CD 
	LEFT JOIN TB_M_EXCHANGE_RATE ER ON POH.PO_CURR = ER.CURR_CD AND GETDATE() BETWEEN ER.VALID_DT_FROM AND ER.VALID_DT_TO AND ER.RELEASED_FLAG = '1'
	LEFT JOIN TB_R_PO_SUBITEM POS ON POI.PO_NO = POS.PO_NO AND POI.PO_ITEM_NO = POS.PO_ITEM_NO 
	LEFT JOIN TB_R_ASSET RA ON POI.PO_NO = RA.PO_NO AND POI.PO_ITEM_NO = RA.PO_ITEM_NO
	LEFT JOIN TB_M_DELIVERY_ADDR MDA ON MDA.DELIVERY_ADDR = POH.DELIVERY_ADDR 
	LEFT JOIN TB_M_MATERIAL_PART MP ON POI.MAT_NO = MP.MAT_NO
	LEFT JOIN TB_M_MATERIAL_NONPART MNP ON POI.MAT_NO = MNP.MAT_NO
	LEFT JOIN (SELECT DISTINCT VALUATION_CLASS, MATL_GROUP FROM TB_M_VALUATION_CLASS) VC ON VC.VALUATION_CLASS = POI.VALUATION_CLASS
WHERE POH.PO_STATUS = '43' AND ISNULL(POH.SAP_DOC_NO, '') = '' AND POH.PROCESS_ID = @@PROCESS_ID AND SYSTEM_SOURCE <> 'SAP'
ORDER BY POH.PO_NO, POI.PO_ITEM_NO ASC