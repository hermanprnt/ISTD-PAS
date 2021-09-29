CREATE PROCEDURE [dbo].[sp_UrgentSPK_GetList]
    @prNo VARCHAR(11), @prStatus VARCHAR(3), @spkNo VARCHAR(11),
    @currentPage INT, @pageSize INT
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
        ROW_NUMBER() OVER (ORDER BY prh.PR_NO ASC, prh.PR_STATUS ASC, ISNULL(spk.SPK_NO, '') ASC) DataNo,
        prh.PR_NO PRNo,
        prh.PR_DESC [Description],
        st.STATUS_DESC PRStatus,
        spk.SPK_NO SPKNo,
        CASE WHEN ISNULL(spk.SPK_AMOUNT, 0) = 0 THEN ISNULL(SUM(pri.ORI_AMOUNT), 0)
        ELSE spk.SPK_AMOUNT END Amount,
        CASE WHEN ISNULL(spk.SPK_NO, '') = '' THEN 0 ELSE 1 END HasSPK
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
    ) SELECT * FROM tmp WHERE DataNo BETWEEN (@rowCount - @pageSize + 1) AND @rowCount
END