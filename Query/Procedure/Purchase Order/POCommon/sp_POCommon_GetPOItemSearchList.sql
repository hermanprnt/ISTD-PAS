CREATE PROCEDURE [dbo].[sp_POCommon_GetPOItemSearchList]
    @poNo VARCHAR(50),
    @currentPage INT, @pageSize INT
AS
BEGIN
    DECLARE
        @allowedRowCount INT = (SELECT CAST(SYSTEM_VALUE AS INT) FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH'),
        @rowCount INT

    SELECT @rowCount = (SELECT MIN(data) FROM (VALUES (@allowedRowCount), (@currentPage * @pageSize)) AS derived(data))
    ;

    WITH tmp AS (
        SELECT TOP (@rowCount)
        ROW_NUMBER() OVER (ORDER BY poi.PO_ITEM_NO ASC) DataNo,
        ISNULL(poi.PR_NO, '') PRNo,
        ISNULL(poi.PR_ITEM_NO, '') PRItemNo,
        poi.PO_NO PONo,
        poi.PO_ITEM_NO POItemNo,
        poi.VALUATION_CLASS ValuationClass,
        CASE WHEN poi.WBS_NO = 'X' THEN ''
        ELSE poi.WBS_NO END WBSNo,
        CASE WHEN poi.COST_CENTER_CD = 'X' THEN ''
        ELSE poi.COST_CENTER_CD END CostCenter,
        CASE WHEN poi.GL_ACCOUNT = 'X' THEN ''
        ELSE poi.GL_ACCOUNT END GLAccount,
        CASE WHEN poi.MAT_NO = 'X' THEN ''
        ELSE poi.MAT_NO END MatNo,
        poi.MAT_DESC MatDesc,
        poi.PRICE_PER_UOM PricePerUOM,
        poi.ORI_AMOUNT PriceAmount,
        poi.UOM,
        poi.DELIVERY_PLAN_DT DeliveryPlanDate,
        poi.PO_QTY_ORI Qty,
        (SELECT CASE WHEN COUNT(0) > 0 THEN 1 ELSE 0 END
        FROM TB_R_PO_SUBITEM WHERE PO_NO = poh.PO_NO
            AND PO_ITEM_NO = poi.PO_ITEM_NO) HasItem
        FROM TB_R_PO_ITEM poi
        JOIN TB_R_PO_H poh ON poi.PO_NO = poh.PO_NO
        WHERE ISNULL(poi.PO_NO, '') LIKE '%' + ISNULL(@poNo, '') + '%'
    ) SELECT * FROM tmp WHERE DataNo BETWEEN (@rowCount - @pageSize + 1) AND @rowCount
END