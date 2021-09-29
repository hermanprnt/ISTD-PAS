CREATE PROCEDURE [dbo].[sp_UrgentSPK_GetSPKInfo]
    @prNo VARCHAR(11),
    @spkNo VARCHAR(18)
AS
BEGIN
    SELECT
    SPK_NO SPKNo,
    SPK_BIDDING_DT BiddingDate,
    SPK_WORK_DESC Work,
    ISNULL(SPK_AMOUNT, 0) Amount,
    SPK_LOCATION Location,
    SPK_PERIOD_START PeriodStart,
    SPK_PERIOD_END PeriodEnd,
    SPK_RETENTION Retention,
    SPK_TERMIN_I TerminI,
    SPK_TERMIN_I_DESC TerminIDesc,
    SPK_TERMIN_II TerminII,
    SPK_TERMIN_II_DESC TerminIIDesc,
    SPK_TERMIN_III TerminIII,
    SPK_TERMIN_III_DESC TerminIIIDesc,
    SPK_TERMIN_IV TerminIV,
    SPK_TERMIN_IV_DESC TerminIVDesc,
    SPK_TERMIN_V TerminV,
    SPK_TERMIN_V_DESC TerminVDesc
    FROM TB_R_URGENT_SPK
    WHERE PR_NO = @prNo OR (PR_NO = @prNo AND SPK_NO = @spkNo)
END