DECLARE @@SQL VARCHAR(MAX)

SET @@SQL = 'SELECT * FROM ('

IF (@Kelas = 'P')
BEGIN
	SET @@SQL = @@SQL +
	'SELECT DISTINCT DENSE_RANK() OVER (ORDER BY A.MaterialNo ASC) AS DataNo, * FROM (
	SELECT (select SYSTEM_VALUE from TB_M_SYSTEM where FUNCTION_ID = ''101002'' AND SYSTEM_CD = ''' + @Kelas + ''' ) Class,
		MAT_NO AS MaterialNo,
		MAT_DESC AS MaterialDesc,
		ORDER_UOM AS UOM,
		M.CAR_FAMILY_CD CarFamilyCode,	
		M.MAT_TYPE_CD MaterialTypeCode,	
		M.MAT_GRP_CD MaterialGroupCode,	
		MRP_TYPE MRPtype,
		RE_ORDER_VALUE ReOrderValue,
		RE_ORDER_METHOD ReOrderMethod,
		STD_DELIVERY_TIME StandardDelivTime,
		AVG_DAILY_CONSUMPTION AvgDailyConsump,
		MIN_STOCK MinStock,
		MAX_STOCK MaxStock,
		PCS_PER_KANBAN PcsPerKanban,
		MRP_FLAG MRPFlag,
		M.VALUATION_CLASS ValuationClass,
		STOCK_FLAG StockFlag,
		ASSET_FLAG AssetFlag,
		QUOTA_FLAG QuotaFlag,
		CONSIGNMENT_CD ConsignmentCode,
		PROC_USAGE_GROUP ProcUsageCode,
		DELETION_FLAG DeletionFlag,
		M.CREATED_BY CreatedBy,
		M.CREATED_DT CreatedDate,
		M.CHANGED_BY ChangedBy,
		M.CHANGED_DT ChangedDate,
		MV.VALUATION_CLASS_DESC ValuationClassDesc,
		M.MATL_GROUP MatlGroup
		FROM TB_M_MATERIAL_PART AS M
		LEFT JOIN TB_M_VALUATION_CLASS AS MV ON M.VALUATION_CLASS = MV.VALUATION_CLASS ) A
		WHERE A.DeletionFlag = ''N'' AND 1=1 '
END
ELSE IF(@Kelas = 'N')
BEGIN
	SET @@SQL = @@SQL +
	'SELECT DISTINCT DENSE_RANK() OVER (ORDER BY A.MaterialNo ASC) AS DataNo, * FROM (
	SELECT (select SYSTEM_VALUE from TB_M_SYSTEM where FUNCTION_ID = ''101002'' AND SYSTEM_CD = ''' + @Kelas + ''' ) Class, 
		MAT_NO MaterialNo,
		MAT_DESC MaterialDesc,
		ORDER_UOM AS UOM,	
		MRP_TYPE MRPType,
		RE_ORDER_VALUE ReOrderValue,
		RE_ORDER_METHOD ReOrderMethod,
		STD_DELIVERY_TIME StandardDelivTime,
		AVG_DAILY_CONSUMPTION AvgDailyConsump,
		MIN_STOCK MinStock,
		MAX_STOCK MaxStock,
		PCS_PER_KANBAN PcsPerKanban,
		MRP_FLAG MRPFlag,
		M.VALUATION_CLASS ValuationClass,
		STOCK_FLAG StockFlag,
		ASSET_FLAG AssetFlag,
		QUOTA_FLAG QuotaFlag,
		CONSIGNMENT_CD ConsignmentCode,
		PROC_USAGE_GROUP ProcUsageCode,
		DELETION_FLAG DeletionFlag,
		M.CREATED_BY CreatedBy,
		M.CREATED_DT CreatedDate,
		M.CHANGED_BY ChangedBy,
		M.CHANGED_DT ChangedDate,
		MV.VALUATION_CLASS_DESC ValuationClassDesc,
		M.MATL_GROUP MatlGroup
		FROM TB_M_MATERIAL_NONPART AS M
		LEFT JOIN TB_M_VALUATION_CLASS AS MV ON M.VALUATION_CLASS = MV.VALUATION_CLASS ) A
		WHERE A.DeletionFlag = ''N'' AND 1=1'
END
ELSE
BEGIN
	SET @@SQL = @@SQL +
	'SELECT DISTINCT DENSE_RANK() OVER (ORDER BY A.MaterialNo, A.Class ASC) AS DataNo, * FROM (
		SELECT (select SYSTEM_VALUE from TB_M_SYSTEM where FUNCTION_ID = ''101002'' AND SYSTEM_CD = ''P'' ) Class,
		MAT_NO AS MaterialNo,
		MAT_DESC AS MaterialDesc,
		ORDER_UOM AS UOM,
		MRP_TYPE MRPtype,
		RE_ORDER_VALUE ReOrderValue,
		RE_ORDER_METHOD ReOrderMethod,
		M.CAR_FAMILY_CD CarFamilyCode,	
		M.MAT_TYPE_CD MaterialTypeCode,	
		M.MAT_GRP_CD MaterialGroupCode,	
		STD_DELIVERY_TIME StandardDelivTime,
		AVG_DAILY_CONSUMPTION AvgDailyConsump,
		MIN_STOCK MinStock,
		MAX_STOCK MaxStock,
		PCS_PER_KANBAN PcsPerKanban,
		MRP_FLAG MRPFlag,
		M.VALUATION_CLASS ValuationClass,
		STOCK_FLAG StockFlag,
		ASSET_FLAG AssetFlag,
		QUOTA_FLAG QuotaFlag,
		CONSIGNMENT_CD ConsignmentCode,
		PROC_USAGE_GROUP ProcUsageCode,
		DELETION_FLAG DeletionFlag,
		M.CREATED_BY CreatedBy,
		M.CREATED_DT CreatedDate,
		M.CHANGED_BY ChangedBy,
		M.CHANGED_DT ChangedDate,
		M.DELETION_FLAG,
		MV.VALUATION_CLASS_DESC ValuationClassDesc,
		M.MATL_GROUP MatlGroup
		FROM TB_M_MATERIAL_PART AS M
		LEFT JOIN TB_M_VALUATION_CLASS AS MV ON M.VALUATION_CLASS = MV.VALUATION_CLASS
		WHERE M.DELETION_FLAG = ''N''
	
	UNION 
	
		SELECT (select SYSTEM_VALUE from TB_M_SYSTEM where FUNCTION_ID = ''101002'' AND SYSTEM_CD = ''N'' ) Class, 
		MAT_NO MaterialNo,
		MAT_DESC MaterialDesc,
		ORDER_UOM AS UOM,	
		MRP_TYPE MRPType,
		RE_ORDER_VALUE ReOrderValue,
		RE_ORDER_METHOD ReOrderMethod,
		'''' CarFamilyCode,	
		'''' MaterialTypeCode,	
		'''' MaterialGroupCode,	
		STD_DELIVERY_TIME StandardDelivTime,
		AVG_DAILY_CONSUMPTION AvgDailyConsump,
		MIN_STOCK MinStock,
		MAX_STOCK MaxStock,
		PCS_PER_KANBAN PcsPerKanban,
		MRP_FLAG MRPFlag,
		M.VALUATION_CLASS ValuationClass,
		STOCK_FLAG StockFlag,
		ASSET_FLAG AssetFlag,
		QUOTA_FLAG QuotaFlag,
		CONSIGNMENT_CD ConsignmentCode,
		PROC_USAGE_GROUP ProcUsageCode,
		DELETION_FLAG DeletionFlag,
		M.CREATED_BY CreatedBy,
		M.CREATED_DT CreatedDate,
		M.CHANGED_BY ChangedBy,
		M.CHANGED_DT ChangedDate,
		M.DELETION_FLAG,
		MV.VALUATION_CLASS_DESC ValuationClassDesc,
		M.MATL_GROUP MatlGroup
		FROM TB_M_MATERIAL_NONPART AS M 
		LEFT JOIN TB_M_VALUATION_CLASS AS MV ON M.VALUATION_CLASS = MV.VALUATION_CLASS 
		WHERE M.DELETION_FLAG = ''N'') A
		WHERE 1=1 '
END

IF (ISNULL(@MAT_NO, '') <> '')
	SET @@SQL = @@SQL + ' AND A.MaterialNo LIKE ''%' + @MAT_NO + '%'''

IF (ISNULL(@MAT_DESC, '') <> '')
	SET @@SQL = @@SQL + ' AND A.MaterialDesc LIKE ''%' + @MAT_DESC + '%'''

IF (ISNULL(@UOM, '') <> '')
	SET @@SQL = @@SQL + ' AND A.UOM LIKE ''%' + @UOM + '%'''

IF (ISNULL(@MRP_TYPE, '') <> '')
	SET @@SQL = @@SQL + ' AND A.MRPType LIKE ''%' + @MRP_TYPE + '%'''

IF (ISNULL(@VALUATION_CLASS, '') <> '')
	SET @@SQL = @@SQL + ' AND A.ValuationClass LIKE ''%' + @VALUATION_CLASS + '%'''

IF (ISNULL(@PROC_USAGE_CD, '') <> '')
	SET @@SQL = @@SQL + ' AND A.ProcUsageCode LIKE ''%' + @PROC_USAGE_CD + '%'''

IF (ISNULL(@ASSET_FLAG, '') <> '')
	SET @@SQL = @@SQL + ' AND A.AssetFlag LIKE ''%' + @ASSET_FLAG + '%'''

IF (ISNULL(@QUOTA_FLAG, '') <> '')
	SET @@SQL = @@SQL + ' AND A.QuotaFlag LIKE ''%' + @QUOTA_FLAG + '%'''

SET @@SQL = @@SQL + ' ) TB WHERE DataNo BETWEEN ' + CAST(@Start AS VARCHAR) + ' AND ' + CAST(@End AS VARCHAR)

EXEC (@@SQL)