IF(@Kelas = 'P')
	BEGIN
		SELECT 
		MAT_NO AS MaterialNo,
		@Kelas AS Class,
		MAT_DESC AS MaterialDesc,
		ORDER_UOM AS UOM,
		CAR_FAMILY_CD AS CarFamilyCode,
		MAT_GRP_CD AS MaterialGroupCode,
		MAT_TYPE_CD AS MaterialTypeCode,
		MRP_TYPE AS MRPType,
		RE_ORDER_VALUE AS ReOrderValue,
		RE_ORDER_METHOD AS ReOrderMethod,
		STD_DELIVERY_TIME AS StandardDelivTime,
		AVG_DAILY_CONSUMPTION AS AvgDailyConsump,
		MIN_STOCK AS MinStock,
		MAX_STOCK AS MaxStock,
		PCS_PER_KANBAN AS PcsPerKanban,
		MRP_FLAG AS MRPFlag,
		VALUATION_CLASS AS ValuationClass,
		CONSIGNMENT_CD AS ConsignmentCode,
		PROC_USAGE_GROUP AS ProcUsageCode,
		STOCK_FLAG AS StockFlag,
		ASSET_FLAG AS AssetFlag,
		QUOTA_FLAG AS QuotaFlag,
		MATL_GROUP AS MatlGroup,
		DELETION_FLAG AS DeletionFlag
		FROM TB_M_MATERIAL_PART
		WHERE MAT_NO=@Criteria
	END
ELSE IF(@Kelas = 'N')
	BEGIN
		SELECT 
		MAT_NO AS MaterialNo,
		@Kelas AS Class,
		MAT_DESC AS MaterialDesc,
		ORDER_UOM AS UOM,
		MRP_TYPE AS MRPType,
		RE_ORDER_VALUE AS ReOrderValue,
		RE_ORDER_METHOD AS ReOrderMethod,
		STD_DELIVERY_TIME AS StandardDelivTime,
		AVG_DAILY_CONSUMPTION AS AvgDailyConsump,
		MIN_STOCK AS MinStock,
		MAX_STOCK AS MaxStock,
		PCS_PER_KANBAN AS PcsPerKanban,
		MRP_FLAG AS MRPFlag,
		VALUATION_CLASS AS ValuationClass,
		CONSIGNMENT_CD AS ConsignmentCode,
		PROC_USAGE_GROUP AS ProcUsageCode,
		STOCK_FLAG AS StockFlag,
		ASSET_FLAG AS AssetFlag,
		QUOTA_FLAG AS QuotaFlag,
		MATL_GROUP AS MatlGroup,
		DELETION_FLAG AS DeletionFlag
		FROM TB_M_MATERIAL_NONPART
		WHERE MAT_NO=@Criteria
	END
