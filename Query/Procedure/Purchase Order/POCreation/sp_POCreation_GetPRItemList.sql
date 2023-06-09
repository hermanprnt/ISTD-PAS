
/****** Object:  StoredProcedure [dbo].[sp_POCreation_GetPRItemList]    Script Date: 9/19/2017 11:34:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_POCreation_GetPRItemList]
    @processId BIGINT, @prNo VARCHAR(11), @valuationClass VARCHAR(4), @plantCode VARCHAR(4),
    @materialNo VARCHAR(23), @currency VARCHAR(3), @sLocCode VARCHAR(4),
    @materialDesc VARCHAR(50), @vendorCode VARCHAR(4), @prCoordinator VARCHAR(3),
    @purchasingGroup VARCHAR(6),
    @currentPage INT, @pageSize INT
AS
BEGIN
    DECLARE
        @allowedRowCount INT = (SELECT CAST(SYSTEM_VALUE AS INT) FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH'),
        @rowCount INT

    SELECT @rowCount = (SELECT MIN(data) FROM (VALUES (@allowedRowCount), (@currentPage * @pageSize)) AS derived(data))
    ;

    WITH tmp AS (
        SELECT
        ROW_NUMBER() OVER (ORDER BY pri.CHANGED_DT DESC) DataNo,
        pri.PR_NO PRNo,
        pri.PR_ITEM_NO PRItemNo,
        ass.ASSET_NO AssetNo,
        ass.SUB_ASSET_NO SubAssetNo,
        ass.ASSET_STATUS AssetStatus,
        assst.STATUS_DESC AssetStatusDesc,
        pri.VALUATION_CLASS ValuationClass,
        CASE WHEN pri.WBS_NO = 'X' THEN ''
        ELSE pri.WBS_NO END WBSNo,
        CASE WHEN pri.COST_CENTER_CD = 'X' THEN ''
        ELSE pri.COST_CENTER_CD END CostCenter,
        CASE WHEN pri.GL_ACCOUNT = 'X' THEN ''
        ELSE pri.GL_ACCOUNT END GLAccount,
        CASE WHEN pri.MAT_NO = 'X' THEN ''
        ELSE pri.MAT_NO END MatNo,
        pri.MAT_DESC MatDesc,
        pri.PRICE_PER_UOM PricePerUOM,
        CASE WHEN (ass.ASSET_NO IS NULL OR ass.ASSET_NO = '') THEN pri.OPEN_QTY * pri.PRICE_PER_UOM ELSE pri.PRICE_PER_UOM  END AS PriceAmount,
        pri.UNIT_OF_MEASURE_CD UOM,
        pri.DELIVERY_PLAN_DT DeliveryPlanDate,
        (SELECT CASE WHEN COUNT(SEQ_NO) > 0 THEN 1 ELSE pri.OPEN_QTY END FROM TB_R_ASSET WHERE PR_NO = pri.PR_NO AND PR_ITEM_NO = pri.PR_ITEM_NO) Qty,
        (SELECT CASE WHEN COUNT(0) > 0 THEN 1 ELSE 0 END FROM TB_R_PR_SUBITEM WHERE PR_NO = prh.PR_NO AND PR_ITEM_NO = pri.PR_ITEM_NO) HasItem
        FROM TB_R_PR_ITEM pri
        JOIN TB_R_PR_H prh ON prh.PR_NO = pri.PR_NO --AND prh.RELEASED_FLAG = 'Y'
        JOIN TB_M_VALUATION_CLASS vc ON pri.VALUATION_CLASS = vc.VALUATION_CLASS
            AND vc.PROCUREMENT_TYPE = prh.PR_TYPE
            AND vc.PR_COORDINATOR = prh.PR_COORDINATOR
            AND vc.PURCHASING_GROUP_CD = @purchasingGroup
        LEFT JOIN TB_R_ASSET ass ON pri.PR_NO = ass.PR_NO AND pri.PR_ITEM_NO = ass.PR_ITEM_NO
            AND pri.ASSET_CATEGORY IN ('MA', 'SA') AND ass.ASSET_STATUS = '51'
            AND ISNULL(ass.PROCESS_ID, '') = '' AND ISNULL(ass.PO_NO, '') = '' AND ISNULL(ass.PO_ITEM_NO, '') = ''
        LEFT JOIN TB_M_STATUS assst ON ass.ASSET_STATUS = assst.STATUS_CD
        WHERE
            (((SELECT pri.PR_NO + ';' + CAST(pri.PR_ITEM_NO AS VARCHAR) + ';' + CAST(ass.ASSET_NO AS VARCHAR) + ';' + CAST(ass.SUB_ASSET_NO AS VARCHAR)) NOT IN
                (SELECT PR_NO + ';' + CAST(PR_ITEM_NO AS VARCHAR) + ';' + ASSET_NO + ';' + SUB_ASSET_NO FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId AND DELETE_FLAG = 'N')
                AND ass.ASSET_NO IS NOT NULL) OR
                ((SELECT pri.PR_NO + ';' + CAST(pri.PR_ITEM_NO AS VARCHAR)) NOT IN
                (SELECT PR_NO + ';' + CAST(PR_ITEM_NO AS VARCHAR) FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId AND DELETE_FLAG = 'N')))
        AND pri.OPEN_QTY > 0
		AND pri.PR_STATUS = '14'
		AND pri.SOURCE_TYPE <> 'ECatalogue'
		AND pri.PROCESS_ID IS NULL
        AND 1 = CASE WHEN pri.ASSET_CATEGORY = 'NA'
            OR (pri.ASSET_CATEGORY IN ('MA', 'SA') AND ass.ASSET_STATUS = '51')
            THEN 1 ELSE 2 END
        AND ISNULL(pri.PR_NO, '') LIKE '%' + ISNULL(@prNo, '') + '%'
        AND ISNULL(pri.VALUATION_CLASS, '') LIKE '%' + ISNULL(@valuationClass, '') + '%'
        AND ISNULL(prh.PLANT_CD, '') LIKE '%' + ISNULL(@plantCode, '') + '%'
        AND ISNULL(pri.MAT_NO, '') LIKE '%' + ISNULL(@materialNo, '') + '%'
        AND ISNULL(pri.ORI_CURR_CD, '') LIKE '%' + ISNULL(@currency, '') + '%'
        AND ISNULL(prh.SLOC_CD, '') LIKE '%' + ISNULL(@sLocCode, '') + '%'
        AND ISNULL(pri.MAT_DESC, '') LIKE '%' + ISNULL(@materialDesc, '') + '%'
        AND ISNULL(pri.VENDOR_CD, '') LIKE '%' + ISNULL(@vendorCode, '') + '%'
        AND ISNULL(prh.PR_COORDINATOR, '') LIKE '%' + ISNULL(@prCoordinator, '') + '%'
    ) SELECT TOP (@pageSize) * FROM tmp WHERE DataNo BETWEEN (((@currentPage-1) * @pageSize) + 1) AND (@currentPage * @pageSize)
END