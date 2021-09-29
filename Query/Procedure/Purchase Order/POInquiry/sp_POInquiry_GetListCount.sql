ALTER PROCEDURE [dbo].[sp_POInquiry_GetListCount]
    @poNo VARCHAR(11), @vendor VARCHAR(50), @status VARCHAR(2),
    @createdBy VARCHAR(20), @dateFrom DATETIME, @dateTo DATETIME, @purchasingGroup VARCHAR(3),
    @poHeaderText VARCHAR(100), @prNo VARCHAR(11) 
AS
BEGIN
    DECLARE
        @allowedRowCount INT = (SELECT CAST(SYSTEM_VALUE AS INT) FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH'),
        @rowCount INT
    ;

    SELECT @rowCount = COUNT(0)
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

    SELECT CASE WHEN @rowCount > @allowedRowCount THEN @allowedRowCount ELSE @rowCount END
END
