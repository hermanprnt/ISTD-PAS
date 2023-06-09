/****** Object:  StoredProcedure [dbo].[sp_POApproval_GetList]    Script Date: 8/29/2017 2:06:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_POApproval_GetList]
    @docNo VARCHAR(15),
    @docDesc VARCHAR(100),
    @plant VARCHAR(4),
    @sLoc VARCHAR(4),
    @purchasingGroup VARCHAR(6),
    @vendor VARCHAR(6),
	@status VARCHAR(2),
    @dateFrom DATETIME,
    @dateTo DATETIME,
    @currency VARCHAR(3),
    @currentUser VARCHAR(30),
    @currentRegNo VARCHAR(30),
    @userType VARCHAR(1),
	@orderBy VARCHAR(20),
    @currentPage INT,
    @pageSize INT
AS
BEGIN
    DECLARE
        @currentApproverPosition VARCHAR(5),
        @allowedRowCount INT = (SELECT CAST(SYSTEM_VALUE AS INT) FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH'),
        @rowCount INT,
		@oriNoreg AS VARCHAR(8) = @currentRegNo

		DECLARE @CurrenctOrgId INT,
				@currentLevelApproverPosition VARCHAR(5)

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
	--SELECT  @TSQL = 'SELECT * FROM OPENQUERY([DATAMASTER_ORG],''EXEC [hrportal].[dbo].[sp_POA_User] ''''' + @currentRegNo + ''''''')'
	--INSERT INTO @HR_GRANTOR EXEC (@TSQL)

	INSERT INTO @HR_GRANTOR
      EXEC sp_POA_User

	-- Approver modification
	SELECT TOP 1 @currentApproverPosition = POSITION_LEVEL, @CurrenctOrgId = ORG_ID
		FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = @currentRegNo ORDER BY POSITION_LEVEL ASC
	SET @currentLevelApproverPosition = (SELECT LEVEL_ID FROM TB_M_ORG_POSITION WHERE POSITION_LEVEL = @currentApproverPosition)

	--IF (@userType = 'A')
	--BEGIN
		INSERT INTO @HR_GRANTOR
		SELECT DISTINCT 'GPS', 'GPS' + CAST(DENSE_RANK() OVER (ORDER BY WF.NOREG) AS VARCHAR), WF.NOREG, @oriNoreg, GETDATE(), GETDATE(), 'AUTO', GETDATE(), 'GPS', NULL, NULL
		FROM TB_R_WORKFLOW WF 
			INNER JOIN TB_M_ORG_POSITION OP ON OP.POSITION_LEVEL = WF.APPROVER_POSITION AND OP.LEVEL_ID = @currentLevelApproverPosition 
			INNER JOIN TB_R_SYNCH_EMPLOYEE S ON S.NOREG = WF.NOREG AND S.ORG_ID = WF.STRUCTURE_ID AND GETDATE() BETWEEN S.VALID_FROM AND S.VALID_TO
				WHERE WF.STRUCTURE_ID = @CurrenctOrgId
	--END

	-- End approver modification
    -- NOTE: it's called derived table https://msdn.microsoft.com/en-us/library/ms177634.aspx
    SELECT @rowCount = (SELECT MIN(data) FROM (VALUES (@allowedRowCount), (@currentPage * @pageSize)) AS derived(data));

    WITH tmp AS (
        SELECT TOP (@rowCount)
        CASE @orderBy WHEN 'ATTACHMENT|ASC' THEN ROW_NUMBER() OVER (ORDER BY dist.IsHaveAttachment ASC, dist.DocDate DESC, dist.ChangedDate DESC, dist.DocNo ASC)
					  WHEN 'ATTACHMENT|DESC' THEN ROW_NUMBER() OVER (ORDER BY dist.IsHaveAttachment DESC, dist.DocDate DESC, dist.ChangedDate DESC, dist.DocNo ASC)
					  WHEN 'URGENT|ASC' THEN ROW_NUMBER() OVER (ORDER BY dist.UrgentDoc ASC, dist.DocDate DESC, dist.ChangedDate DESC, dist.DocNo ASC)
					  WHEN 'URGENT|DESC' THEN ROW_NUMBER() OVER (ORDER BY dist.UrgentDoc DESC, dist.DocDate DESC, dist.ChangedDate DESC, dist.DocNo ASC)
					  WHEN 'PO|ASC' THEN ROW_NUMBER() OVER (ORDER BY dist.DocNo ASC, dist.DocDate DESC, dist.ChangedDate DESC)
					  WHEN 'PO|DESC' THEN ROW_NUMBER() OVER (ORDER BY dist.DocNo DESC, dist.DocDate DESC, dist.ChangedDate DESC)
					  WHEN 'DESC|ASC' THEN ROW_NUMBER() OVER (ORDER BY dist.DocDesc ASC, dist.DocDate DESC, dist.ChangedDate DESC)
					  WHEN 'DESC|DESC' THEN ROW_NUMBER() OVER (ORDER BY dist.DocDesc DESC, dist.DocDate DESC, dist.ChangedDate DESC)
					  WHEN 'DATE|ASC' THEN ROW_NUMBER() OVER (ORDER BY dist.DocDate ASC, dist.ChangedDate DESC, dist.DocNo ASC)
					  WHEN 'DATE|DESC' THEN ROW_NUMBER() OVER (ORDER BY dist.DocDate DESC, dist.ChangedDate DESC, dist.DocNo ASC)
					  WHEN 'VENDOR|ASC' THEN ROW_NUMBER() OVER (ORDER BY dist.Vendor ASC, dist.DocDate DESC, dist.ChangedDate DESC, dist.DocNo ASC)
					  WHEN 'VENDOR|DESC' THEN ROW_NUMBER() OVER (ORDER BY dist.Vendor DESC, dist.DocDate DESC, dist.ChangedDate DESC, dist.DocNo ASC)
					  WHEN 'CURR|ASC' THEN ROW_NUMBER() OVER (ORDER BY dist.Currency ASC, dist.DocDate DESC, dist.ChangedDate DESC, dist.DocNo ASC)
					  WHEN 'CURR|DESC' THEN ROW_NUMBER() OVER (ORDER BY dist.Currency DESC, dist.DocDate DESC, dist.ChangedDate DESC, dist.DocNo ASC)
					  WHEN 'AMOUNT|ASC' THEN ROW_NUMBER() OVER (ORDER BY dist.Amount ASC, dist.DocDate DESC, dist.ChangedDate DESC, dist.DocNo ASC)
					  WHEN 'AMOUNT|DESC' THEN ROW_NUMBER() OVER (ORDER BY dist.Amount DESC, dist.DocDate DESC, dist.ChangedDate DESC, dist.DocNo ASC)
					  WHEN 'STATUS|ASC' THEN ROW_NUMBER() OVER (ORDER BY dist.Status ASC, dist.DocDate DESC, dist.ChangedDate DESC, dist.DocNo ASC)
					  WHEN 'STATUS|DESC' THEN ROW_NUMBER() OVER (ORDER BY dist.Status DESC, dist.DocDate DESC, dist.ChangedDate DESC, dist.DocNo ASC)
					  WHEN 'PURCH|ASC' THEN ROW_NUMBER() OVER (ORDER BY dist.PurchasingGroup ASC, dist.DocDate DESC, dist.ChangedDate DESC, dist.DocNo ASC)
					  WHEN 'PURCH|DESC' THEN ROW_NUMBER() OVER (ORDER BY dist.PurchasingGroup DESC, dist.DocDate DESC, dist.ChangedDate DESC, dist.DocNo ASC)
					  ELSE ROW_NUMBER() OVER (ORDER BY dist.DocDate DESC, dist.ChangedDate DESC, dist.DocNo ASC)
					END AS DataNo,
        dist.*
        FROM (
            SELECT DISTINCT
            wf.DOCUMENT_NO DocNo,
            poh.PO_DESC DocDesc,
            poh.DOC_DT DocDate,
            poh.VENDOR_CD + CASE WHEN ISNULL(poh.VENDOR_NAME, '') = ''
            THEN '' ELSE ' - ' + poh.VENDOR_NAME END Vendor,
            poh.PO_CURR Currency,
            poh.PO_AMOUNT Amount,
            st.STATUS_DESC Status,
            poh.PURCHASING_GRP_CD PurchasingGroup,
            poh.URGENT_DOC UrgentDoc,
			CASE WHEN EXISTS(SELECT 1 FROM TB_R_ATTACHMENT WHERE DOC_NO = poh.PO_NO) THEN 1 ELSE 0 END AS IsHaveAttachment,
            poh.CREATED_BY CreatedBy,
            poh.CREATED_DT CreatedDate,
            poh.CHANGED_BY ChangedBy,
            poh.CHANGED_DT ChangedDate
            FROM TB_R_WORKFLOW wf
            JOIN TB_R_PO_H poh ON wf.DOCUMENT_NO = poh.PO_NO
			JOIN TB_M_ORG_POSITION op ON op.POSITION_LEVEL = wf.APPROVER_POSITION
            AND wf.IS_APPROVED = 'N'
            AND wf.IS_DISPLAY = 'Y'
            --AND poh.PO_STATUS NOT IN ('48', '49') -- not rejected
			AND poh.PO_STATUS NOT IN ('49') -- not canceled -- Reject Still allowed
            AND wf.INTERVAL_DATE IS NOT NULL
            AND CASE
                    WHEN @userType = 'C' -- Current user
                        AND (
								(
									(wf.APPROVED_BY = @currentRegNo OR wf.APPROVED_BY IN (SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)) 
									AND (poh.PO_NEXT_STATUS = wf.APPROVAL_CD --OR (poh.PO_STATUS = '40' AND wf.APPROVAL_CD = '41' AND wf.APPROVED_BY = @currentRegNo)
									) 
								)
                            --wf.APPROVER_POSITION = @currentApproverPosition
                        OR (dbo.fn_dateadd_workday(wf.APPROVAL_INTERVAL, wf.INTERVAL_DATE) < GETDATE()
                            AND wf.APPROVER_POSITION = @currentApproverPosition
                            AND EXISTS (SELECT 1 FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = wf.DOCUMENT_NO AND (APPROVED_BY = @currentRegNo OR APPROVED_BY IN (SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO))
                                        AND IS_DISPLAY = 'Y' AND IS_APPROVED = 'N')))
                    THEN 1
                    WHEN @userType = 'A' -- All user
                        AND ((wf.APPROVER_POSITION >= @currentApproverPosition) OR (op.LEVEL_ID = @currentLevelApproverPosition))
                        AND EXISTS (SELECT 1 FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = wf.DOCUMENT_NO AND (APPROVED_BY = @currentRegNo OR APPROVED_BY IN (SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO))
                                        AND IS_DISPLAY = 'Y' AND IS_APPROVED = 'N')
                    THEN 1
                ELSE 0
                END = 1
            JOIN TB_M_STATUS st ON poh.PO_STATUS = st.STATUS_CD AND st.DOC_TYPE = 'PO'
            AND ISNULL(poh.PO_NO, '') LIKE '%' + ISNULL(@docNo, '') + '%'
            AND ISNULL(poh.PO_DESC, '') LIKE '%' + ISNULL(@docDesc, '') + '%'
            AND ISNULL(poh.VENDOR_CD, '') LIKE '%' + ISNULL(@vendor, '') + '%'
            AND ISNULL(poh.PO_CURR, '') LIKE '%' + ISNULL(@currency, '') + '%'
            AND ISNULL(poh.PURCHASING_GRP_CD, '') LIKE '%' + ISNULL(@purchasingGroup, '') + '%'
			AND ISNULL(poh.PO_STATUS, '') LIKE '%' + ISNULL(@status, '') + '%'
            AND (ISNULL(poh.CREATED_DT, CAST('1753-1-1' AS DATETIME))
                BETWEEN ISNULL(@dateFrom, CAST('1753-1-1' AS DATETIME)) AND DATEADD(MILLISECOND, 86399998, ISNULL(@dateTo, CAST('9999-12-31' AS DATETIME))))
		) dist ORDER BY DataNo ASC
    ) SELECT * FROM tmp WHERE DataNo BETWEEN (@rowCount - @pageSize + 1) AND @rowCount --ORDER BY DataNo ASC
END