CREATE PROCEDURE [dbo].[sp_ReceivingList_GetListCount]
    @receivingNo VARCHAR(11), @receivingDateFrom DATETIME, @receivingDateTo DATETIME, @vendor VARCHAR(4),
    @poNo VARCHAR(11), @status VARCHAR(3)
AS
BEGIN
    DECLARE @rowCount INT
    ;

    WITH tmp AS (
        SELECT gr.MAT_DOC_NO
        FROM TB_R_GR_IR gr
        JOIN TB_R_PO_H poh ON gr.PO_NO = poh.PO_NO
        JOIN TB_M_VENDOR vnd ON gr.VENDOR_CD = vnd.VENDOR_CD
        JOIN TB_M_STATUS st ON gr.STATUS_CD = st.STATUS_CD
        WHERE gr.COMPONENT_PRICE_CD = 'PB00'
        AND ISNULL(gr.MAT_DOC_NO, '') LIKE '%' + ISNULL(@receivingNo, '') + '%'
        AND ISNULL(gr.VENDOR_CD, '') LIKE '%' + ISNULL(@vendor, '') + '%'
        AND ISNULL(gr.PO_NO, '') LIKE '%' + ISNULL(@poNo, '') + '%'
        AND ISNULL(gr.STATUS_CD, '') LIKE '%' + ISNULL(@status, '') + '%'
        AND (ISNULL(gr.CREATED_DT, CAST('1753-1-1' AS DATETIME))
            BETWEEN ISNULL(@receivingDateFrom, CAST('1753-1-1' AS DATETIME))
            AND DATEADD(MILLISECOND, 86399998, ISNULL(@receivingDateTo, CAST('9999-12-31' AS DATETIME)))
        )
        GROUP BY gr.MAT_DOC_NO,
        gr.DOCUMENT_DT,
        gr.HEADER_TEXT,
        gr.PO_NO,
        gr.VENDOR_CD + ' - ' + vnd.VENDOR_NAME,
        poh.PO_CURR,
        st.STATUS_DESC
    ) SELECT COUNT(0) FROM tmp
END