CREATE PROCEDURE [dbo].[sp_SAPImportMonitor_GetList]
    @processId BIGINT, @poNo VARCHAR(11), @status VARCHAR(1),
    @purchasingGroup VARCHAR(3), @executionDateFrom DATETIME,
    @executionDateTo DATETIME, @currentPage INT, @pageSize INT
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
        ROW_NUMBER() OVER (ORDER BY EXECUTION_DT DESC) DataNo,
        PROCESS_ID ProcessId,
        PO_NO PONo,
        EXECUTION_DT ExecutionDate,
        PURCH_GROUP PurchasingGroup,
        st.StatusDesc [Status],
        MESSAGE_OUT [Message],
        CREATED_BY CreatedBy,
        CREATED_DT CreatedDate,
        CHANGED_BY ChangedBy,
        CHANGED_DT ChangedDate
        FROM TB_H_SAP_PO_MONITORING
        JOIN (
            SELECT StatusCode, StatusDesc
            FROM (VALUES
                    (0, 'Initial'),
                    (1, 'On Progress'),
                    (2, 'Finish'),
                    (3, 'Finish with error'))
            AS Derived(StatusCode, StatusDesc)
        ) st ON STATUS_SYNCH = st.StatusCode
        WHERE ISNULL(CAST(PROCESS_ID AS VARCHAR), '') LIKE '%' + ISNULL(CAST(@processId AS VARCHAR), '') + '%'
        AND ISNULL(PO_NO, '') LIKE '%' + ISNULL(@poNo, '') + '%'
        AND ISNULL(STATUS_SYNCH, '') LIKE '%' + ISNULL(@status, '') + '%'
        AND ISNULL(PURCH_GROUP, '') LIKE '%' + ISNULL(@purchasingGroup, '') + '%'
        AND (ISNULL(EXECUTION_DT, CAST('1753-1-1' AS DATETIME))
            BETWEEN ISNULL(@executionDateFrom, CAST('1753-1-1' AS DATETIME))
                AND ISNULL(@executionDateTo, CAST('9999-12-31' AS DATETIME))
        )
    ) SELECT * FROM tmp WHERE DataNo BETWEEN (@rowCount - @pageSize + 1) AND @rowCount
END