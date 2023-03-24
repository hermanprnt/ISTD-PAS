CREATE PROCEDURE [dbo].[sp_MaterialPrice_GetListBySearch]
    @matNo VARCHAR(23), @vendor VARCHAR(6), @sourceType VARCHAR(1), @priceStatus VARCHAR(1),
    @priceType VARCHAR(1), @prodPurpose VARCHAR(5), @partColorSfx VARCHAR(2), @packingType VARCHAR(1),
    @dateFrom DATETIME, @dateTo DATETIME, @currentPage INT, @pageSize INT
AS
BEGIN
    DECLARE
        @allowedRowCount INT = (SELECT CAST(SYSTEM_VALUE AS INT) FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH'),
        @rowCount INT
            
    -- NOTE: it's called derived table https://msdn.microsoft.com/en-us/library/ms177634.aspx
    SELECT @rowCount = (SELECT MIN(data) FROM (VALUES (@allowedRowCount), (@currentPage * @pageSize)) AS derived(data))
    ;
    
    WITH tmp AS (
        SELECT TOP (@rowCount)
        ROW_NUMBER() OVER (ORDER BY prc.MAT_NO ASC) DataNo,
        prc.MAT_NO MaterialNo,
        prc.VENDOR_CD VendorCode,
        vnd.VENDOR_NAME VendorName,
        prc.WARP_BUYER_CD WarpBuyerCode,
        prc.SOURCE_TYPE SourceType,
        prc.PRODUCTION_PURPOSE ProdPurpose,
        prc.PART_COLOR_SFX PartColorSfx,
        prc.PACKING_TYPE PackingType,
        prc.VALID_DT_FROM ValidDateFrom,
        prc.VALID_DT_TO ValidDateTo,
        prc.PRICE_STATUS PriceStatus,
        --prc.PRICE_TYPE PriceType,
        prc.PRICE_AMT Amount,
        prc.CREATED_BY CreatedBy,
        prc.CREATED_DT CreatedDate,
        prc.CHANGED_BY ChangedBy,
        prc.CHANGED_DT ChangedDate
        FROM TB_M_MATERIAL_PRICE prc
        JOIN TB_M_VENDOR vnd ON prc.VENDOR_CD = vnd.VENDOR_CD
        AND ISNULL(prc.MAT_NO, '') LIKE '%' + ISNULL(@matNo, '') + '%'
        AND ISNULL(prc.VENDOR_CD, '') LIKE '%' + ISNULL(@vendor, '') + '%'
        AND ISNULL(prc.SOURCE_TYPE, '') LIKE '%' + ISNULL(@sourceType, '') + '%'
        AND ISNULL(prc.PRICE_STATUS, '') LIKE '%' + ISNULL(@priceStatus, '') + '%'
        --AND ISNULL(prc.PRICE_TYPE, '') LIKE '%' + ISNULL(@priceType, '') + '%'
        AND ISNULL(prc.PRODUCTION_PURPOSE, '') LIKE '%' + ISNULL(@prodPurpose, '') + '%'
        AND ISNULL(prc.PART_COLOR_SFX, '') LIKE '%' + ISNULL(@partColorSfx, '') + '%'
        AND ISNULL(prc.PACKING_TYPE, '') LIKE '%' + ISNULL(@packingType, '') + '%'
        AND (ISNULL(prc.VALID_DT_FROM, CAST('1753-1-1' AS DATETIME)) >= ISNULL(@dateFrom, CAST('1753-1-1' AS DATETIME))
            AND ISNULL(prc.VALID_DT_TO, CAST('9999-12-31' AS DATETIME)) >= ISNULL(@dateTo, CAST('9999-12-31' AS DATETIME)))
    ) SELECT * FROM tmp WHERE DataNo BETWEEN (@rowCount - @pageSize + 1) AND @rowCount
END