CREATE PROCEDURE [dbo].[sp_Material_GetUploadTempList]
    @processId BIGINT
AS
BEGIN
    SELECT
        ROW_NUMBER() OVER (ORDER BY PROCESS_ID ASC, SEQ_NO ASC) DataNo,
        PROCESS_ID ProcessId,
        SEQ_NO SeqNo,
        CLASS Class,
        MAT_NO MaterialNo,
        MAT_DESC MaterialDesc,
        UOM,
        CAR_FAMILY_CD CarFamilyCode,
        MAT_TYPE_CD MaterialTypeCode,
        MAT_GRP_CD MaterialGroupCode,
        MRP_TYPE MRPType,
        RE_ORDER_VALUE ReOrderValue,
        RE_ORDER_METHOD ReOrderMethod,
        STD_DELIVERY_TIME StandardDelivTime,
        AVG_DAILY_CONSUMPTION AvgDailyConsump,
        MIN_STOCK MinStock,
        MAX_STOCK MaxStock,
        PCS_PER_KANBAN PcsPerKanban,
        STOCK_FLAG StockFlag,
        MRP_FLAG MRPFlag,
        ASSET_FLAG AssetFlag,
        QUOTA_FLAG QuotaFlag,
        VALUATION_CLASS ValuationClass,
        PROC_USAGE_CD ProcUsageCode,
        CONSIGNMENT_CD ConsignmentCode,
        CREATED_BY CreatedBy,
        CREATED_DT CreatedDate,
        CHANGED_BY ChangedBy,
        CHANGED_DT ChangedDate
    FROM TB_T_MATERIAL_TEMP WHERE PROCESS_ID = @processId
END

