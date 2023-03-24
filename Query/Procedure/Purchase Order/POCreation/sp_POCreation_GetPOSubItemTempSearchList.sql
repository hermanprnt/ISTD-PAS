CREATE PROCEDURE [dbo].[sp_POCreation_GetPOSubItemTempSearchList]
    @processId BIGINT, @prNo VARCHAR(50), @prItemNo VARCHAR(11), @prSubItemNo VARCHAR(11),
    @poNo VARCHAR(50), @poItemNo VARCHAR(11), @currentPage INT, @pageSize INT
AS
BEGIN
    DECLARE
        @allowedRowCount INT = (SELECT CAST(SYSTEM_VALUE AS INT) FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH'),
        @rowCount INT

    SELECT @rowCount = (SELECT MIN(data) FROM (VALUES (@allowedRowCount), (@currentPage * @pageSize)) AS derived(data))
    ;

    WITH tmp AS (
        SELECT TOP (@rowCount)
        ROW_NUMBER() OVER (ORDER BY posit.PR_SUBITEM_NO ASC) DataNo,
        posit.PR_NO PRNo,
        posit.PR_ITEM_NO PRItemNo,
        posit.PR_SUBITEM_NO PRSubItemNo,
        posit.PO_NO PONo,
        posit.PO_ITEM_NO POItemNo,
        posit.MAT_NO MatNo,
        posit.MAT_DESC MatDesc,
        posit.PRICE_PER_UOM PricePerUOM,
        posit.ORI_AMOUNT PriceAmount,
        posit.UOM UOM,
        posit.PO_QTY_ORI Qty
        FROM TB_T_PO_SUBITEM posit
        WHERE ISNULL(posit.PROCESS_ID, '') LIKE '%' + ISNULL(CAST(@processId AS VARCHAR(50)), '') + '%'
        AND ISNULL(posit.PR_NO, '') LIKE '%' + ISNULL(@prNo, '') + '%'
        AND ISNULL(posit.PR_ITEM_NO, '') LIKE '%' + ISNULL(@prItemNo, '') + '%'
        AND ISNULL(posit.PR_SUBITEM_NO, '') LIKE '%' + ISNULL(@prSubItemNo, '') + '%'
        AND ISNULL(posit.PO_NO, '') LIKE '%' + ISNULL(@poNo, '') + '%'
        AND ISNULL(posit.PO_ITEM_NO, '') LIKE '%' + ISNULL(@poItemNo, '') + '%'
    ) SELECT * FROM tmp WHERE DataNo BETWEEN (@rowCount - @pageSize + 1) AND @rowCount
END