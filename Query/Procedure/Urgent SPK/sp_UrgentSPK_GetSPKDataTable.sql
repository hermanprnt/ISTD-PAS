CREATE PROCEDURE [dbo].[sp_UrgentSPK_GetSPKDataTable]
    @prNo VARCHAR(11),
    @spkNo VARCHAR(18)
AS
BEGIN
    SELECT
    spk.SPK_NO SPKNo,
    spk.SPK_DT SPKDate,
    spk.SPK_BIDDING_DT BiddingDate,
    spk.VENDOR_NAME VendorName,
    spk.VENDOR_ADDRESS VendorAddress,
    spk.CITY VendorCity,
    spk.POSTAL_CODE VendorPostal,
    spk.SPK_WORK_DESC SPKWork,
    spk.SPK_LOCATION SPKLocation,
    '-' SPKPONo,
    CASE WHEN ISNULL(spk.SPK_AMOUNT, 0) = 0 THEN ISNULL(SUM(pri.ORI_AMOUNT), 0)
    ELSE spk.SPK_AMOUNT END SPKAmount,
    spk.SPK_PERIOD_START SPKStartDate,
    spk.SPK_PERIOD_END SPKEndDate,
    spk.SPK_RETENTION SPKRetention,
    dbo.Terbilang(spk.SPK_RETENTION) SPKRetentionWord,
    spk.SPK_TERMIN_I + '%' TerminI,
    spk.SPK_TERMIN_I_DESC TerminIDesc,
    spk.SPK_TERMIN_II + '%' TerminII,
    spk.SPK_TERMIN_II_DESC TerminIIDesc,
    spk.SPK_TERMIN_III + '%' TerminIII,
    spk.SPK_TERMIN_III_DESC TerminIIIDesc,
    spk.SPK_TERMIN_IV + '%' TerminIV,
    spk.SPK_TERMIN_IV_DESC TerminIVDesc,
    spk.SPK_TERMIN_V + '%' TerminV,
    spk.SPK_TERMIN_V_DESC TerminVDesc,
    spk.SPK_SIGN SPKSigner,
    spk.SPK_SIGN_NAME SPKSignerName,
    'PT. TOYOTA MOTOR MANUFACTURING INDONESIA' Employer
    FROM TB_R_URGENT_SPK spk
    JOIN TB_R_PR_H prh ON spk.PR_NO = prh.PR_NO
    JOIN TB_R_PR_ITEM pri ON prh.PR_NO = pri.PR_NO
    WHERE spk.PR_NO = @prNo OR (spk.PR_NO = @prNo AND spk.SPK_NO = @spkNo)
    GROUP BY
    spk.SPK_NO,
    spk.SPK_DT,
    spk.SPK_BIDDING_DT,
    spk.VENDOR_NAME,
    spk.VENDOR_ADDRESS,
    spk.CITY,
    spk.POSTAL_CODE,
    spk.SPK_WORK_DESC,
    spk.SPK_LOCATION,
    spk.SPK_AMOUNT,
    spk.SPK_PERIOD_START,
    spk.SPK_PERIOD_END,
    spk.SPK_RETENTION,
    dbo.Terbilang(spk.SPK_RETENTION),
    spk.SPK_TERMIN_I + '%',
    spk.SPK_TERMIN_I_DESC,
    spk.SPK_TERMIN_II + '%',
    spk.SPK_TERMIN_II_DESC,
    spk.SPK_TERMIN_III + '%',
    spk.SPK_TERMIN_III_DESC,
    spk.SPK_TERMIN_IV + '%',
    spk.SPK_TERMIN_IV_DESC,
    spk.SPK_TERMIN_V + '%',
    spk.SPK_TERMIN_V_DESC,
    spk.SPK_SIGN,
    spk.SPK_SIGN_NAME
END