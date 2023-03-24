ALTER PROCEDURE [dbo].[sp_POApproval_CountDetailList]
    @docNo VARCHAR(15),
    @currentRegNo VARCHAR(30),
    @userType VARCHAR(1)
AS
BEGIN
    DECLARE
        @currentApproverPosition VARCHAR(5) = (SELECT TOP 1 POSITION_LEVEL FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = @currentRegNo ORDER BY POSITION_LEVEL ASC),
        @allowedRowCount INT = (SELECT CAST(SYSTEM_VALUE AS INT) FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH'),
        @rowCount INT
    ;

	--Note: Get grantor from HR
	DECLARE @HR_GRANTOR TABLE
		(
			SYSTEM_ID VARCHAR(50),
			POA_NO VARCHAR(50),
			GRANTOR VARCHAR(50),
			ATTORNEY VARCHAR(50),
			VALID_FROM DATE,
			VALID_TO DATE,
			REASON VARCHAR(50),
			CREATED_DT DATE,
			CREATED_BY VARCHAR(50),
			UPDATED_DT DATE,
			UPDATED_BY VARCHAR(50)
		)
	DECLARE @TSQL VARCHAR(MAX)
	SELECT  @TSQL = 'SELECT * FROM OPENQUERY([HRLINK],''EXEC [hrportal].[dbo].[sp_POA_User] ''''' + @currentRegNo + ''''''')'
	
	INSERT INTO @HR_GRANTOR EXEC (@TSQL)

    SELECT @rowCount = COUNT(0)
    FROM (
        SELECT DISTINCT poi.PO_ITEM_NO
        FROM TB_R_WORKFLOW wf
            JOIN TB_R_PO_H poh ON wf.DOCUMENT_NO = poh.PO_NO
			JOIN TB_R_PO_ITEM poi ON poh.PO_NO = poi.PO_NO
            AND wf.IS_APPROVED = 'N'
			AND wf.IS_DISPLAY = 'Y'
			AND poh.PO_STATUS <> '48' -- not rejected
            AND wf.INTERVAL_DATE IS NOT NULL
            AND CASE
                    WHEN @userType = 'C' -- Current user
                        AND (((wf.APPROVED_BY = @currentRegNo OR wf.APPROVED_BY IN ((SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO))) AND (poh.PO_NEXT_STATUS = wf.APPROVAL_CD OR (poh.PO_STATUS = '40' AND wf.APPROVAL_CD = '41')) ) --dummy, because when PO Creation, PO_NEXT_STATUS still null (PO_NEXT_STATUS is new column)
							--wf.APPROVER_POSITION = @currentApproverPosition
                        OR (dbo.fn_dateadd_workday(wf.APPROVAL_INTERVAL, wf.INTERVAL_DATE) < GETDATE()
                            AND wf.APPROVER_POSITION >= @currentApproverPosition
							AND EXISTS (SELECT 1 FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = wf.DOCUMENT_NO AND (APPROVED_BY = @currentRegNo OR APPROVED_BY IN ((SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)))
										AND IS_DISPLAY = 'Y' AND IS_APPROVED = 'N')))
                    THEN 1
                    WHEN @userType = 'A' -- All user
                        AND wf.APPROVER_POSITION >= @currentApproverPosition
						AND EXISTS (SELECT 1 FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = wf.DOCUMENT_NO AND (APPROVED_BY = @currentRegNo OR APPROVED_BY IN (SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO))
										AND IS_DISPLAY = 'Y' AND IS_APPROVED = 'N')
                    THEN 1 
                ELSE 0
                END = 1
            JOIN TB_M_STATUS st ON poh.PO_STATUS = st.STATUS_CD AND st.DOC_TYPE = 'PO'
            AND ISNULL(poh.PO_NO, '') LIKE '%' + ISNULL(@docNo, '') + '%'
    ) dist

    SELECT CASE WHEN @rowCount > @allowedRowCount THEN @allowedRowCount ELSE @rowCount END
END