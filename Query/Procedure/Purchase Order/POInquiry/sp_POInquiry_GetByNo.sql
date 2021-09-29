ALTER PROCEDURE [dbo].[sp_POInquiry_GetByNo]
    @poNo VARCHAR(11)
AS
BEGIN
    DECLARE @vendor VARCHAR(6) = (SELECT VENDOR_CD FROM TB_R_PO_H WHERE PO_NO = @poNo)
    DECLARE @isOneTimeVendor BIT = (SELECT CASE WHEN COUNT(0) > 0 THEN 1 ELSE 0 END FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'OTV' AND SYSTEM_VALUE = @vendor)

    SELECT 1 AS DataNo,
    poh.PO_NO PONo,
    @isOneTimeVendor IsOneTimeVendor,
    poh.PO_DESC POHeaderText,
    poh.VENDOR_CD VendorCode,
    CASE WHEN @isOneTimeVendor = 1 OR poh.SYSTEM_SOURCE = 'SAP' THEN poh.VENDOR_NAME ELSE vnd.VENDOR_NAME END VendorName,
    CASE WHEN @isOneTimeVendor = 1 OR poh.SYSTEM_SOURCE = 'SAP' THEN poh.VENDOR_ADDRESS ELSE vnd.VENDOR_ADDRESS END VendorAddress,
    CASE WHEN @isOneTimeVendor = 1 OR poh.SYSTEM_SOURCE = 'SAP' THEN poh.COUNTRY ELSE vnd.COUNTRY END VendorCountry,
    CASE WHEN @isOneTimeVendor = 1 OR poh.SYSTEM_SOURCE = 'SAP' THEN poh.CITY ELSE vnd.CITY END VendorCity,
    CASE WHEN @isOneTimeVendor = 1 OR poh.SYSTEM_SOURCE = 'SAP' THEN poh.POSTAL_CODE ELSE vnd.POSTAL_CODE END VendorPostalCode,
    CASE WHEN @isOneTimeVendor = 1 OR poh.SYSTEM_SOURCE = 'SAP' THEN poh.PHONE ELSE vnd.PHONE END VendorPhone,
    CASE WHEN @isOneTimeVendor = 1 OR poh.SYSTEM_SOURCE = 'SAP' THEN poh.FAX ELSE vnd.FAX END VendorFax,
    poh.DOC_DT PODate,
    poh.PO_CURR Currency,
    poh.PO_EXCHANGE_RATE ExchangeRate,
    stt.STATUS_DESC POStatus,
	poh.PO_STATUS POStatusCode,
    poh.PO_AMOUNT Amount,
    poh.CHANGED_BY ChangedBy,
    poh.CHANGED_DT ChangedDate,
    poh.PURCHASING_GRP_CD PurchasingGroup,
	ISNULL(poh.PO_NOTE1, '') Note1,
	ISNULL(poh.PO_NOTE2, '') Note2,
	ISNULL(poh.PO_NOTE3, '') Note3,
	ISNULL(poh.PO_NOTE4, '') Note4,
	ISNULL(poh.PO_NOTE5, '') Note5,
	ISNULL(poh.PO_NOTE6, '') Note6,
	ISNULL(poh.PO_NOTE7, '') Note7,
	ISNULL(poh.PO_NOTE8, '') Note8,
	ISNULL(poh.PO_NOTE9, '') Note9,
	ISNULL(poh.PO_NOTE10, '') Note10,
    CASE WHEN LOWER(poh.SYSTEM_SOURCE) = 'gps' THEN 1 ELSE 0 END IsFromGPS,
	rabid.FILE_PATH BidFilePath,
	rabid.FILE_NAME_ORI BidOriFilePath,
	raquot.FILE_PATH QuotFilePath,
	raquot.FILE_NAME_ORI QuotOriFilePath
    FROM TB_R_PO_H poh
    JOIN TB_M_STATUS stt ON poh.PO_STATUS = stt.STATUS_CD
    JOIN TB_M_VENDOR vnd ON poh.VENDOR_CD = vnd.VENDOR_CD
	--For Edit
	LEFT JOIN ( select TOP 1 DOC_NO,FILE_PATH, FILE_NAME_ORI FROM TB_R_ATTACHMENT  Where DOC_NO = @poNo AND --rabid.DELETE_FLAG <> 'Y' AND 
		DOC_TYPE = 'BID')rabid ON poh.PO_NO = rabid.DOC_NO
	LEFT JOIN (select TOP 1 DOC_NO,FILE_PATH, FILE_NAME_ORI FROM TB_R_ATTACHMENT Where DOC_NO = @poNo  AND --raquot.DELETE_FLAG <> 'Y' AND 
		DOC_TYPE = 'QUOT') raquot ON poh.PO_NO = raquot.DOC_NO
    WHERE poh.PO_NO = @poNo
END