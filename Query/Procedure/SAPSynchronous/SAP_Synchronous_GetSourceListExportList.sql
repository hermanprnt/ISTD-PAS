USE [PAS_DB_QA]
GO
/****** Object:  StoredProcedure [dbo].[SAP_Synchronous_GetMaterialPriceExportList]    Script Date: 12/13/2017 6:34:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SAP_Synchronous_GetSourceListExportList]
	@FunctionId VARCHAR(10),
	@PROCESS_ID BIGINT OUTPUT
AS
BEGIN
	DECLARE @@PROCESS_ID BIGINT

	EXEC [dbo].[sp_PutLog] 'Locking SourceList No for Posting to SAP', 'SYSTEM', 'SAP SourceList Synchronous Service', @@PROCESS_ID OUTPUT, 'INF', 'INF', '0', @FunctionId, 2

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
				,@FunctionId
				,'SYSTEM'
				,'SYSTEM'
				,'SYSTEM'
				,GETDATE()
				,NULL
				,NULL)

	SET @PROCESS_ID = @@PROCESS_ID

	select DISTINCT ISNULL(CAST(CAST(SL.SOURCE_LIST_ID AS DECIMAL(14, 0)) AS VARCHAR), '') + '\t' + 
					ISNULL(SL.MAT_NO, '') + '\t' +  
					ISNULL(SL.VENDOR_CD, '') + '\t' + 
					ISNULL(MV.VENDOR_PLANT , '') + '\t' +  
					ISNULL([dbo].[fn_date_format](SL.VALID_DT_FROM), '') + '\t' +
					ISNULL([dbo].[fn_date_format](SL.VALID_DT_TO), '') + '\t' +
					ISNULL(VC.PROC_CHANNEL_CD , '') + '\t' 
	from TB_M_SOURCE_LIST SL
		INNER JOIN TB_M_MATERIAL_NONPART MNP ON MNP.MAT_NO = SL.MAT_NO
		INNER JOIN TB_M_VALUATION_CLASS VC ON VC.VALUATION_CLASS = MNP.VALUATION_CLASS AND ITEM_CLASS = 'M' AND PROCUREMENT_TYPE ='RM'
		INNER JOIN TB_M_VENDOR MV ON MV.VENDOR_CD = SL.VENDOR_CD
		WHERE 1 = 1 AND (ISNULL(SL.SAP_NO,'') = '') AND ISNULL(DELETE_FLAG,'N') = 'N' 
END

