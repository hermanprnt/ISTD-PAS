USE [PAS_DB_QA]
GO
/****** Object:  StoredProcedure [dbo].[sp_BudgetConfig_GetBudgetConfig]    Script Date: 11/8/2017 10:32:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SAP_Synchronous_GetMaterialExportList]
	@FunctionId VARCHAR(10),
	@PROCESS_ID BIGINT OUTPUT
AS
BEGIN
	DECLARE @@PROCESS_ID BIGINT

	EXEC [dbo].[sp_PutLog] 'Locking Material No for Posting to SAP', 'SYSTEM', 'SAP Material Synchronous Service', @@PROCESS_ID OUTPUT, 'INF', 'INF', '0', @FunctionId, 2

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

	SELECT  ISNULL(MNP.MAT_NO, '') + '\t' +
			ISNULL(MNP.MAT_DESC, '') + '\t' +
			--ISNULL(MNP.MATERIAL_FEATURE, '') + '\t' + 
			ISNULL(MNP.BASE_UOM, '') + '\t' +
			ISNULL(MNP.ORDER_UOM, '') + '\t' +
			REPLACE(ISNULL(CAST(CAST(MNP.STD_DELIVERY_TIME AS DECIMAL(14, 0)) AS VARCHAR), ''), '.', ',') + '\t' +
			REPLACE(ISNULL(CAST(CAST(MNP.MIN_STOCK AS DECIMAL(14, 0)) AS VARCHAR), ''), '.', ',')  + '\t' +
			ISNULL(MNP.PROC_USAGE_GROUP, '') + '\t' +
			REPLACE(ISNULL(CAST(CAST(MNP.MINIMUM_STOCK AS DECIMAL(14, 0)) AS VARCHAR), ''), '.', ',') + '\t' +
			ISNULL(MNP.MRP_FLAG, '') + '\t' +
			ISNULL(MNP.VALUATION_CLASS, '') + '\t' +
			ISNULL(MNP.STOCK_FLAG, '') + '\t' +
			ISNULL(MNP.ASSET_FLAG, '') + '\t' +
			ISNULL(MNP.QUOTA_FLAG, '') + '\t' +
			ISNULL(MNP.PR_FLAG, '') + '\t' +
			ISNULL(MNP.RO_FLAG, '') + '\t' +
			ISNULL(MNP.CP_FLAG, '') + '\t' +
			ISNULL(MNP.DELETION_FLAG, '') + '\t' +
			ISNULL(MNP.CREATED_BY, '') + '\t' +
			ISNULL([dbo].[fn_date_format](MNP.CHANGED_DT), '')
	FROM TB_M_MATERIAL_NONPART MNP 
		WHERE 1 = 1
	ORDER BY CREATED_DT DESC
END

