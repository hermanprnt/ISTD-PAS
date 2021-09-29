CREATE PROCEDURE [dbo].[sp_SAPImportMonitor_GetListCount]
    @processId BIGINT, @poNo VARCHAR(11), @status VARCHAR(1),
    @purchasingGroup VARCHAR(3), @executionDateFrom DATETIME,
    @executionDateTo DATETIME
AS
BEGIN
    DECLARE
        @allowedRowCount INT = (SELECT CAST(SYSTEM_VALUE AS INT) FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH'),
        @rowCount INT
    ;

    SELECT @rowCount = COUNT(0)
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

    SELECT CASE WHEN @rowCount > @allowedRowCount THEN @allowedRowCount ELSE @rowCount END
END