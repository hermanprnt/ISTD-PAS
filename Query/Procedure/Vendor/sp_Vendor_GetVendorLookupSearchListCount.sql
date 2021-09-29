CREATE PROCEDURE [dbo].[sp_Vendor_GetVendorLookupSearchListCount]
    @searchText VARCHAR(50)
AS
BEGIN
    SELECT COUNT(0)
    FROM TB_M_VENDOR
    WHERE (ISNULL(VENDOR_CD, '') LIKE '%' + ISNULL(@searchText, '') + '%'
    OR ISNULL(VENDOR_NAME, '') LIKE '%' + ISNULL(@searchText, '') + '%')
    AND DELETION_FLAG <> '1'
END