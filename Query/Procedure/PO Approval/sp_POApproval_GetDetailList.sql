CREATE PROCEDURE [dbo].[sp_POApproval_GetDetailList]
    @docNo VARCHAR(15),
    @currentRegNo VARCHAR(30),
    @userType VARCHAR(1),
    @currentPage INT,
    @pageSize INT
AS
BEGIN
    DECLARE
        @allowedRowCount INT = (SELECT CAST(SYSTEM_VALUE AS INT) FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH'),
        @rowCount INT

    -- NOTE: it's called derived table https://msdn.microsoft.com/en-us/library/ms177634.aspx
    SELECT @rowCount = (SELECT MIN(data) FROM (VALUES (@allowedRowCount), (@currentPage * @pageSize)) AS derived(data));

    WITH tmp AS (
        SELECT
        ROW_NUMBER() OVER (ORDER BY poi.PO_ITEM_NO ASC) DataNo,
        poh.PO_NO DOC_NO,
        poi.PO_ITEM_NO DOC_ITEM_NO,
        poi.ITEM_CLASS,
        poi.PR_ITEM_NO ITEM_NO,
        poi.PR_NO,
        poi.VALUATION_CLASS,
        CASE WHEN poi.MAT_NO = 'X' THEN '' ELSE poi.MAT_NO END MAT_NO,
        poi.MAT_DESC,
        poi.PO_QTY_ORI QTY,
        poi.UOM,
        poi.PRICE_PER_UOM PRICE,
        poi.ORI_AMOUNT AMOUNT,
        poi.DELIVERY_PLAN_DT,
        poi.PLANT_CD,
        poi.SLOC_CD,
        CASE WHEN poi.WBS_NO = 'X' THEN '' ELSE poi.WBS_NO END WBS_NO,
        CASE WHEN poi.COST_CENTER_CD = 'X' THEN '' ELSE poi.COST_CENTER_CD END COST_CENTER_CD,
        CASE WHEN poi.GL_ACCOUNT = 'X' THEN '' ELSE poi.GL_ACCOUNT END GL_ACCOUNT,
        (SELECT CASE WHEN COUNT(0) > 0 THEN 1 ELSE 0 END
        FROM TB_R_PO_SUBITEM WHERE PO_NO = poi.PO_NO
        AND PO_ITEM_NO = poi.PO_ITEM_NO) HAS_ITEM
        FROM TB_R_PO_H poh JOIN TB_R_PO_ITEM poi ON poh.PO_NO = poi.PO_NO
        WHERE poh.PO_NO = @docNo
    ) SELECT TOP (@rowCount) * FROM tmp WHERE DataNo BETWEEN (@rowCount - @pageSize + 1) AND @rowCount
END