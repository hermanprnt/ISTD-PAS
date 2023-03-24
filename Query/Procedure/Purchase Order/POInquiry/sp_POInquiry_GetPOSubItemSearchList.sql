CREATE PROCEDURE [dbo].[sp_POInquiry_GetPOSubItemSearchList]
    @poNo VARCHAR(50), @poItemNo VARCHAR(11),
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
        ROW_NUMBER() OVER (ORDER BY posi.PO_SUBITEM_NO ASC) DataNo,
        posi.PO_NO PONo,
        posi.PO_ITEM_NO POItemNo,
        posi.PO_SUBITEM_NO POSubItemNo,
        posi.WBS_NO WBSNo,
        posi.COST_CENTER_CD CostCenter,
        posi.GL_ACCOUNT GLAccount,
        posi.MAT_NO MatNo,
        posi.MAT_DESC MatDesc,
        posi.PRICE_PER_UOM PricePerUOM,
        posi.ORI_AMOUNT PriceAmount,
        posi.UOM,
        posi.PO_QTY_ORI Qty
        FROM TB_R_PO_SUBITEM posi
        WHERE ISNULL(posi.PO_NO, '') LIKE '%' + ISNULL(@poNo, '') + '%'
        AND ISNULL(posi.PO_ITEM_NO, '') LIKE '%' + ISNULL(@poItemNo, '') + '%'
    ) SELECT * FROM tmp WHERE DataNo BETWEEN (@rowCount - @pageSize + 1) AND @rowCount
END