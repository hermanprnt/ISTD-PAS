CREATE PROCEDURE [dbo].[sp_UrgentSPK_GetVendorInfo]
    @vendorCode VARCHAR(11)
AS
BEGIN
    SELECT
    VENDOR_CD VendorCode,
    VENDOR_NAME VendorName,
    ISNULL(VENDOR_ADDRESS, '-') VendorAddress,
    ISNULL(POSTAL_CODE, '-') VendorPostal,
    ISNULL(CITY, '-') City
    FROM TB_M_VENDOR
    WHERE VENDOR_CD = @vendorCode
END