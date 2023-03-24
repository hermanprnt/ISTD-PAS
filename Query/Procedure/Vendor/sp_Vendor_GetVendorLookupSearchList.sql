CREATE PROCEDURE [dbo].[sp_Vendor_GetVendorLookupSearchList]
    @searchText VARCHAR(50),
    @currentPage INT,
    @pageSize INT
AS
BEGIN
    DECLARE @rowCount INT = (SELECT @currentPage * @pageSize)
    ;
    
    WITH tmp AS (
        SELECT
        ROW_NUMBER() OVER (ORDER BY VENDOR_CD ASC) DataNo,
        VENDOR_CD VendorCd,
        VENDOR_NAME VendorName
        FROM TB_M_VENDOR
        WHERE (ISNULL(VENDOR_CD, '') LIKE '%' + ISNULL(@searchText, '') + '%'
        OR ISNULL(VENDOR_NAME, '') LIKE '%' + ISNULL(@searchText, '') + '%')
        AND DELETION_FLAG <> '1'
    ) SELECT * FROM tmp WHERE DataNo BETWEEN (@rowCount - @pageSize + 1) AND @rowCount
END