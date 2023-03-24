CREATE PROCEDURE [dbo].[sp_ReceivingList_GetList]
    @receivingNo VARCHAR(11), @receivingDateFrom DATETIME, @receivingDateTo DATETIME, @vendor VARCHAR(4),
    @poNo VARCHAR(11), @status VARCHAR(3), @currentPage INT, @pageSize INT
AS
BEGIN
    DECLARE @rowCount INT = (SELECT @currentPage * @pageSize)
    ;

    WITH tmp AS (
        SELECT
        ROW_NUMBER() OVER (ORDER BY gr.MAT_DOC_NO, gr.PO_NO) DataNo,
        gr.MAT_DOC_NO ReceivingNo,
        gr.DOCUMENT_DT ReceivingDate,
        gr.HEADER_TEXT HeaderText,
        gr.PO_NO PONo,
        gr.VENDOR_CD + ' - ' + vnd.VENDOR_NAME Vendor,
        poh.PO_CURR Currency,
        gr.STATUS_CD StatusCode,
        st.STATUS_DESC [Status],
        gr.PROCESS_ID ProcessId,
        SUM(gr.MOVEMENT_QTY) TotalQty,
        MAX(gr.CREATED_BY) CreatedBy,
        MAX(gr.CREATED_DT) CreatedDate,
        MAX(gr.CHANGED_BY) ChangedBy,
        MAX(gr.CHANGED_DT) ChangedDate
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
        gr.STATUS_CD,
        st.STATUS_DESC,
        gr.PROCESS_ID
    ) SELECT TOP (@rowCount) * FROM tmp WHERE DataNo BETWEEN (@rowCount - @pageSize + 1) AND @rowCount
END