ALTER PROCEDURE [dbo].[sp_POInquiry_GetList]
    @poNo VARCHAR(11), @vendor VARCHAR(50), @status VARCHAR(2),
    @createdBy VARCHAR(20), @dateFrom DATETIME, @dateTo DATETIME,
    @purchasingGroup VARCHAR(3), @poHeaderText VARCHAR(100), 
	@orderBy VARCHAR(20), @prNo VARCHAR(11), @currentPage INT, @pageSize INT
AS
BEGIN
    DECLARE
        @allowedRowCount INT = (SELECT CAST(SYSTEM_VALUE AS INT) FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH'),
        @rowCount INT

    -- NOTE: it's called derived table https://msdn.microsoft.com/en-us/library/ms177634.aspx
    SELECT @rowCount = (SELECT MIN(data) FROM (VALUES (@allowedRowCount), (@currentPage * @pageSize)) AS derived(data))
    ;

    WITH tmp AS (
        SELECT --TOP (@pageSize)
		CASE @orderBy WHEN 'ATTACHMENT|ASC' THEN ROW_NUMBER() OVER (ORDER BY dt.IsHaveAttachment ASC, dt.PODate DESC, dt.PONo DESC)
					  WHEN 'ATTACHMENT|DESC' THEN ROW_NUMBER() OVER (ORDER BY dt.IsHaveAttachment DESC, dt.PODate DESC, dt.PONo DESC)
					  WHEN 'PO|ASC' THEN ROW_NUMBER() OVER (ORDER BY dt.PONo ASC, dt.PODate DESC)
					  WHEN 'PO|DESC' THEN ROW_NUMBER() OVER (ORDER BY dt.PONo DESC, dt.PODate DESC)
					  WHEN 'DESC|ASC' THEN ROW_NUMBER() OVER (ORDER BY dt.POHeaderText ASC, dt.PODate DESC, dt.PONo DESC)
					  WHEN 'DESC|DESC' THEN ROW_NUMBER() OVER (ORDER BY dt.POHeaderText DESC, dt.PODate DESC, dt.PONo DESC)
					  WHEN 'DATE|ASC' THEN ROW_NUMBER() OVER (ORDER BY dt.PODate ASC, dt.PONo DESC)
					  WHEN 'DATE|DESC' THEN ROW_NUMBER() OVER (ORDER BY dt.PODate DESC, dt.PONo DESC)
					  WHEN 'PURCH|ASC' THEN ROW_NUMBER() OVER (ORDER BY dt.PurchasingGroup ASC, dt.PODate DESC, dt.PONo DESC)
					  WHEN 'PURCH|DESC' THEN ROW_NUMBER() OVER (ORDER BY dt.PurchasingGroup DESC, dt.PODate DESC, dt.PONo DESC)
					  WHEN 'VENDOR|ASC' THEN ROW_NUMBER() OVER (ORDER BY dt.VendorCode ASC, dt.PODate DESC, dt.PONo DESC)
					  WHEN 'VENDOR|DESC' THEN ROW_NUMBER() OVER (ORDER BY dt.VendorCode DESC, dt.PODate DESC, dt.PONo DESC)
					  WHEN 'CURR|ASC' THEN ROW_NUMBER() OVER (ORDER BY dt.Currency ASC, dt.PODate DESC, dt.PONo DESC)
					  WHEN 'CURR|DESC' THEN ROW_NUMBER() OVER (ORDER BY dt.Currency DESC, dt.PODate DESC, dt.PONo DESC)
					  WHEN 'AMOUNT|ASC' THEN ROW_NUMBER() OVER (ORDER BY dt.Amount ASC, dt.PODate DESC, dt.PONo DESC)
					  WHEN 'AMOUNT|DESC' THEN ROW_NUMBER() OVER (ORDER BY dt.Amount DESC, dt.PODate DESC, dt.PONo DESC)
					  WHEN 'STATUS|ASC' THEN ROW_NUMBER() OVER (ORDER BY dt.POStatus ASC, dt.PODate DESC, dt.PONo DESC)
					  WHEN 'STATUS|DESC' THEN ROW_NUMBER() OVER (ORDER BY dt.POStatus DESC, dt.PODate DESC, dt.PONo DESC)
					  WHEN 'SPK|ASC' THEN ROW_NUMBER() OVER (ORDER BY dt.HasSPK ASC, dt.PODate DESC, dt.PONo DESC)
					  WHEN 'SPK|DESC' THEN ROW_NUMBER() OVER (ORDER BY dt.HasSPK DESC, dt.PODate DESC, dt.PONo DESC)
					  WHEN 'LETTER|ASC' THEN ROW_NUMBER() OVER (ORDER BY (CASE WHEN (dt.POStatusCode = '43' OR dt.POStatusCode = '44') THEN 1 ELSE 0 END) ASC, dt.PODate DESC, dt.PONo DESC)
					  WHEN 'LETTER|DESC' THEN ROW_NUMBER() OVER (ORDER BY (CASE WHEN (dt.POStatusCode = '43' OR dt.POStatusCode = '44') THEN 1 ELSE 0 END) DESC, dt.PODate DESC, dt.PONo DESC)
					  ELSE ROW_NUMBER() OVER (ORDER BY dt.PODate DESC, dt.PONo DESC)
					END AS DataNo,
		dt.* FROM (
			SELECT 
			poh.PO_NO PONo,
			poh.VENDOR_CD VendorCode,
			poh.VENDOR_NAME VendorName,
			poh.DOC_DT PODate,
			poh.PO_DESC POHeaderText,
			poh.PO_CURR Currency,
			poh.PO_AMOUNT Amount,
			RTRIM(LTRIM(poh.PO_STATUS)) POStatusCode,
			stat.STATUS_DESC POStatus,
			poh.PURCHASING_GRP_CD PurchasingGroup,
			poh.DOWNLOAD_BY DownloadedBy,
			poh.DOWNLOAD_DT DownloadedDate,
			poh.CREATED_BY CreatedBy,
			poh.CREATED_DT CreatedDate,
			poh.CHANGED_BY ChangedBy,
			poh.CHANGED_DT ChangedDate,
			poh.PROCESS_ID ProcessId,
			poh.SAP_PO_NO SAPPONo,
			lock.[USER_NAME] LockedBy,
			CASE WHEN ISNULL(poh.SPK_NO, '') = '' THEN 0 ELSE 1 END HasSPK,
			CASE WHEN EXISTS(SELECT 1 FROM TB_R_ATTACHMENT WHERE DOC_NO = poh.PO_NO) THEN 1 ELSE 0 END AS IsHaveAttachment
			FROM TB_R_PO_H poh
			JOIN TB_M_STATUS stat ON poh.PO_STATUS = stat.STATUS_CD AND stat.DOC_TYPE IN ('PO', 'DOC')
			LEFT JOIN TB_T_LOCK lock ON poh.PROCESS_ID = lock.PROCESS_ID
			WHERE ISNULL(poh.PO_NO, '') LIKE '%' + ISNULL(@poNo, '') + '%'
			AND (ISNULL(poh.VENDOR_CD, '') LIKE '%' + ISNULL(@vendor, '') + '%'
				OR ISNULL(poh.VENDOR_NAME, '') LIKE '%' + ISNULL(@vendor, '') + '%')
			AND ISNULL(poh.PO_STATUS, '') LIKE '%' + ISNULL(@status, '') + '%'
			AND ISNULL(poh.CREATED_BY, '') LIKE '%' + ISNULL(@createdBy, '') + '%'
			AND ISNULL(poh.PURCHASING_GRP_CD, '') LIKE '%' + ISNULL(@purchasingGroup, '') + '%'
			AND ISNULL(poh.PO_DESC, '') LIKE '%' + ISNULL(@poHeaderText, '') + '%'
			AND (ISNULL(poh.CREATED_DT, CAST('1753-1-1' AS DATETIME))
				BETWEEN ISNULL(@dateFrom, CAST('1753-1-1' AS DATETIME)) AND DATEADD(MILLISECOND, 86399998, ISNULL(@dateTo, CAST('9999-12-31' AS DATETIME))))
			AND exists (SELECT 1 FROM TB_R_PO_ITEM poi WITH(NOLOCK) WHERE poi.PO_NO = poh.PO_NO AND 
																		(
																		poi.PR_NO LIKE +'%' + ISNULL(@prNo,'') + '%' AND ISNULL(@prNo,'')  <> ''
																		OR (ISNULL(@prNo,'') = '')
																		)
						)
		)dt --ORDER BY DataNo ASC
    ) SELECT TOP (@rowCount) * FROM tmp WHERE DataNo BETWEEN (@rowCount - @pageSize + 1) AND @rowCount ORDER BY DataNo ASC
END