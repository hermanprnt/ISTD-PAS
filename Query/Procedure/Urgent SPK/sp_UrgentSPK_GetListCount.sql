CREATE PROCEDURE [dbo].[sp_UrgentSPK_GetListCount]
    @prNo VARCHAR(11), @prStatus VARCHAR(3), @spkNo VARCHAR(11)
AS
BEGIN
    DECLARE
        @allowedRowCount INT = (SELECT CAST(SYSTEM_VALUE AS INT) FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH'),
        @rowCount INT

    SELECT @rowCount = COUNT(0)
    FROM TB_R_PR_H prh
    JOIN TB_R_PR_ITEM pri ON prh.PR_NO = pri.PR_NO
    JOIN TB_M_STATUS st ON prh.PR_STATUS = st.STATUS_CD
    LEFT JOIN TB_R_URGENT_SPK spk ON prh.PR_NO = spk.PR_NO
    WHERE prh.URGENT_DOC = 'Y' -- AND prh.PR_STATUS IN ('90', '91', '92') -- Created / Outstanding / Released
    AND ISNULL(prh.PR_NO, '') LIKE '%' + ISNULL(@prNo, '') + '%'
    AND ISNULL(prh.PR_STATUS, '') LIKE '%' + ISNULL(@prStatus, '') + '%'
    AND ISNULL(spk.SPK_NO, '') LIKE '%' + ISNULL(@spkNo, '') + '%'
    GROUP BY
    prh.PR_NO,
    prh.PR_DESC,
    prh.PR_STATUS,
    st.STATUS_DESC,
    spk.SPK_NO,
    spk.SPK_AMOUNT,
    CASE WHEN ISNULL(spk.SPK_NO, '') = '' THEN 0 ELSE 1 END

    SELECT CASE WHEN @rowCount > @allowedRowCount THEN @allowedRowCount ELSE @rowCount END
END
