CREATE PROCEDURE [dbo].[sp_POCommon_GetSPKDataTable]
    @poNo VARCHAR(11)
AS
BEGIN
    SELECT
    SPK_NO SPKNo,
    [dbo].IndonesianMonthFormat(CONVERT(VARCHAR(11), SPK_DT, 113)) SPKDate,
    [dbo].IndonesianMonthFormat(CONVERT(VARCHAR(11), SPK_BIDDING_DT, 113)) BiddingDate,
    VENDOR_NAME VendorName,
    VENDOR_ADDRESS VendorAddress,
    CITY VendorCity,
    POSTAL_CODE VendorPostal,
    SPK_WORK_DESC SPKWork,
    SPK_LOCATION SPKLocation,
    CASE WHEN DRAFT_FLAG = 'Y' THEN 'Under Process' ELSE PO_NO END SPKPONo,
    CASE WHEN ISNULL(SPK_AMOUNT, 0) = 0 THEN PO_AMOUNT ELSE SPK_AMOUNT END SPKAmount,
    [dbo].IndonesianMonthFormat(CONVERT(VARCHAR(11), SPK_PERIOD_START, 113)) SPKStartDate,
    [dbo].IndonesianMonthFormat(CONVERT(VARCHAR(11), SPK_PERIOD_END, 113)) SPKEndDate,
    SPK_RETENTION SPKRetention,
    dbo.Terbilang(SPK_RETENTION) SPKRetentionWord,
    SPK_TERMIN_I + '%' TerminI,
    SPK_TERMIN_I_DESC TerminIDesc,
    SPK_TERMIN_II + '%' TerminII,
    SPK_TERMIN_II_DESC TerminIIDesc,
    SPK_TERMIN_III + '%' TerminIII,
    SPK_TERMIN_III_DESC TerminIIIDesc,
    SPK_TERMIN_IV + '%' TerminIV,
    SPK_TERMIN_IV_DESC TerminIVDesc,
    SPK_TERMIN_V + '%' TerminV,
    SPK_TERMIN_V_DESC TerminVDesc,
    SPK_SIGN SPKSigner,
    SPK_SIGN_NAME SPKSignerName,
    'PT. TOYOTA MOTOR MANUFACTURING INDONESIA' Employer,
	SPK_PARAGRAPH1 SPKParagraph1
    FROM TB_R_PO_H WHERE PO_NO = @poNo
END