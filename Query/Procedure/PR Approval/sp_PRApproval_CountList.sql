﻿-- Modified by : FID) Intan Puspitasari
-- Modified dt : 08-12-2015
-- Description : Change with new search param and remove union query
ALTER PROCEDURE [dbo].[sp_PRApproval_CountList]
    @docNo VARCHAR(11),
	@docType VARCHAR(5),
	@docDesc VARCHAR(100),
	@dateFrom DATETIME,
    @dateTo DATETIME,
	@prCoordinator VARCHAR(20),
	@plantCd VARCHAR(5),
	@slocCd VARCHAR(5),
    @divisionId VARCHAR(5),
	@typeUser VARCHAR(20), --user type param on search criteria CURRENT_USER/ALL_USER
    @regNo VARCHAR(50)
AS
BEGIN
    -- Created By   : alira.salman
    -- Created Date : 26.02.2015
    -- Description  : Count PRApproval module data (union of TB_R_PO_H and TB_R_PR_H).
    
    DECLARE
        @MAX_RECORD AS BIGINT,
        @TOTAL_RECORD AS BIGINT,
		@POSITION_LEVEL INT
    
	SELECT TOP 1 @POSITION_LEVEL = POSITION_LEVEL FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = @regNo AND GETDATE() BETWEEN VALID_FROM AND VALID_TO
    SELECT @MAX_RECORD = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH';
    
    DECLARE @TB_TMP_STATUS AS TABLE
    (
        STATUS_CD VARCHAR(20),
        STATUS_DESC VARCHAR(20),
		SEGMENTATION_CD CHAR(2)
    );
    INSERT INTO @TB_TMP_STATUS
    SELECT A.STATUS_CD, A.STATUS_DESC, A.SEGMENTATION_CD
    FROM TB_M_STATUS A WHERE A.DOC_TYPE = 'DOC'

	DECLARE @TB_TMP_ITEM_STATUS AS TABLE
	(
		STATUS_CD VARCHAR(20),
		STATUS_DESC VARCHAR(20),
		SEGMENTATION_CD CHAR(2)
	);
	INSERT INTO @TB_TMP_ITEM_STATUS
	SELECT DISTINCT A.STATUS_CD, A.STATUS_DESC, A.SEGMENTATION_CD
	FROM TB_M_STATUS A 
		JOIN TB_R_SYNCH_EMPLOYEE B ON B.NOREG = @regNo
		JOIN TB_M_ORG_POSITION OP1 ON OP1.POSITION_LEVEL = A.POSITION_ID
		JOIN TB_M_ORG_POSITION OP2 ON OP2.POSITION_LEVEL = B.POSITION_LEVEL
	WHERE A.DOC_TYPE = 'PR' AND OP1.LEVEL_ID = OP2.LEVEL_ID

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
	SELECT  @TSQL = 'SELECT * FROM OPENQUERY([HRLINK],''EXEC [hrportal].[dbo].[sp_POA_User] ''''' + @regNo + ''''''')'
	
	INSERT INTO @HR_GRANTOR EXEC (@TSQL) 

    SELECT @TOTAL_RECORD = COUNT(DOC_NO)
    FROM
    (
        SELECT DISTINCT TOP (@MAX_RECORD) PRH.PR_NO AS 'DOC_NO'
        FROM TB_R_PR_H PRH
			JOIN TB_R_PR_ITEM PRI ON PRI.PR_NO = PRH.PR_NO --AND PRI.IS_REJECTED = 'N'    
			JOIN TB_R_WORKFLOW W ON W.DOCUMENT_NO = PRH.PR_NO AND W.ITEM_NO = PRI.PR_ITEM_NO
			JOIN TB_M_STATUS MS ON MS.STATUS_CD = PRI.PR_NEXT_STATUS AND PRI.PR_NEXT_STATUS <> '10'
			JOIN @TB_TMP_ITEM_STATUS ITS ON 1=1
            JOIN @TB_TMP_STATUS S ON S.STATUS_CD = PRH.PR_STATUS
        WHERE
			((PRH.PR_NO LIKE '%' + ISNULL(@docNo, '') + '%'
				AND isnull(@docNo, '') <> ''
				OR (isnull(@docNo, '') = '')))
			AND ((PRH.PR_DESC LIKE '%' + ISNULL(@docDesc, '') + '%'
				AND isnull(@docDesc, '') <> ''
				OR (isnull(@docDesc, '') = '')))
			AND ((PRH.PR_COORDINATOR = ISNULL(@prCoordinator, '')
				AND isnull(@prCoordinator, '') <> ''
				OR (isnull(@prCoordinator, '') = '')))
			AND ((PRH.PLANT_CD = ISNULL(@plantCd, '')
				AND isnull(@plantCd, '') <> ''
				OR (isnull(@plantCd, '') = '')))
			AND ((PRH.SLOC_CD = ISNULL(@slocCd, '')
				AND isnull(@slocCd, '') <> ''
				OR (isnull(@slocCd, '') = '')))
            AND (CAST(PRH.DIVISION_ID AS INT) = @divisionId OR @divisionId IS NULL)
            AND (
                ISNULL(PRH.DOC_DT, CAST('1753-1-1' AS DATE)) >= '' + CAST(ISNULL(CAST(@dateFrom AS DATE), CAST('1753-1-1' AS DATE)) AS VARCHAR) + ''
                AND ISNULL(PRH.DOC_DT, CAST('9999-12-31' AS DATE)) <= '' + CAST(ISNULL(CAST(@dateTo AS DATE), CAST('9999-12-31' AS DATE)) AS VARCHAR) + ''
            )
			--AND W.IS_APPROVED = 'N' 
            AND W.IS_DISPLAY = 'Y'
            AND W.INTERVAL_DATE IS NOT NULL
            AND (
					(@typeUser = 'CURRENT_USER' AND W.IS_APPROVED = 'N' AND  ((W.APPROVED_BY = @regNo OR W.APPROVED_BY IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)) AND PRI.PR_NEXT_STATUS = W.APPROVAL_CD))
					OR (@POSITION_LEVEL = 55 AND @typeUser = 'CURRENT_USER' AND W.APPROVAL_CD = '20' AND PRI.PR_NEXT_STATUS = W.APPROVAL_CD
						AND (SELECT TOP 1 SECTION_ID FROM TB_R_SYNCH_EMPLOYEE WHERE (NOREG = @regNo OR NOREG IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)) AND GETDATE() BETWEEN VALID_FROM AND VALID_TO) IN (SELECT SE1.SECTION_ID FROM TB_R_SYNCH_EMPLOYEE SE1
								JOIN TB_R_WORKFLOW W1 ON W1.DOCUMENT_NO = W.DOCUMENT_NO AND W1.APPROVAL_CD = '21' AND W1.NOREG = SE1.NOREG) AND W.IS_APPROVED = 'N')
					OR ((W.APPROVED_BY = @regNo OR W.APPROVED_BY IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)) AND dbo.fn_dateadd_workday(-(W.APPROVAL_INTERVAL)+1, W.INTERVAL_DATE) <= GETDATE()
						AND SUBSTRING(W.APPROVAL_CD, 1, 1) = (SELECT TOP 1 SUBSTRING(SW.APPROVAL_CD, 1, 1) FROM TB_R_WORKFLOW SW WHERE SW.DOCUMENT_NO = W.DOCUMENT_NO AND SW.IS_APPROVED = 'Y' AND IS_DISPLAY = 'Y' ORDER BY APPROVAL_CD DESC) 
						AND W.IS_APPROVED = 'N')
					OR (@typeUser = 'CURRENT_USER' AND (W.APPROVAL_CD = '30' AND PRI.PR_NEXT_STATUS = W.APPROVAL_CD AND W.IS_APPROVED = 'N'
						AND (SELECT TOP 1 SECTION_ID FROM TB_R_SYNCH_EMPLOYEE WHERE (NOREG = @regNo OR NOREG IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)) AND GETDATE() BETWEEN VALID_FROM AND VALID_TO) IN (SELECT SE1.SECTION_ID FROM TB_R_SYNCH_EMPLOYEE SE1
								JOIN TB_R_WORKFLOW W1 ON W1.DOCUMENT_NO = W.DOCUMENT_NO AND W1.APPROVAL_CD = '30' AND W1.NOREG = SE1.NOREG)))
					OR (@typeUser = 'ALL_USER')
				)
			AND (
					(@typeUser = 'ALL_USER' AND W.APPROVAL_CD <= ITS.STATUS_CD AND MS.SEGMENTATION_CD = ITS.SEGMENTATION_CD   
						AND EXISTS (SELECT 1 FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = W.DOCUMENT_NO AND ITEM_NO = W.ITEM_NO AND (APPROVED_BY = @regNo OR APPROVED_BY IN (SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO))
							AND IS_DISPLAY = 'Y' AND (IS_APPROVED = 'N' OR (IS_APPROVED = 'Y' AND APPROVED_BYPASS IS NOT NULL)))
						AND (SELECT TOP 1 SUBSTRING(APPROVAL_CD, 1, 1) FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = W.DOCUMENT_NO AND ITEM_NO = W.ITEM_NO AND (APPROVED_BY = @regNo OR APPROVED_BY IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO))
							AND IS_DISPLAY = 'Y' AND (IS_APPROVED = 'N' OR (IS_APPROVED = 'Y' AND APPROVED_BYPASS IS NOT NULL)) ORDER BY APPROVAL_CD ASC) 
							= SUBSTRING(PRI.PR_NEXT_STATUS, 1, 1) AND CAST(W.APPROVAL_CD AS INT) >= CAST(PRI.PR_NEXT_STATUS AS INT)
					)
					OR (@typeUser = 'ALL_USER' AND (@POSITION_LEVEL = 55 AND W.APPROVAL_CD = '20' AND PRI.PR_NEXT_STATUS = W.APPROVAL_CD AND W.APPROVED_BY = '-'
						AND (SELECT SECTION_ID FROM TB_R_SYNCH_EMPLOYEE WHERE (NOREG = @regNo OR NOREG IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)) AND GETDATE() BETWEEN VALID_FROM AND VALID_TO) IN (SELECT SE1.SECTION_ID FROM TB_R_SYNCH_EMPLOYEE SE1
								JOIN TB_R_WORKFLOW W1 ON W1.DOCUMENT_NO = W.DOCUMENT_NO AND W1.APPROVAL_CD = '21' AND W1.NOREG = SE1.NOREG)))
					OR (@typeUser = 'ALL_USER' 
						AND 
							((W.APPROVED_BY = @regNo OR W.APPROVED_BY IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)) AND dbo.fn_dateadd_workday(-(W.APPROVAL_INTERVAL), W.INTERVAL_DATE) <= GETDATE()
								AND (SELECT TOP 1 SUBSTRING(APPROVAL_CD, 1, 1) FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = W.DOCUMENT_NO AND (APPROVED_BY = @regNo OR APPROVED_BY IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO))
									AND IS_DISPLAY = 'Y' AND IS_APPROVED = 'N'  AND ITEM_NO = PRI.PR_ITEM_NO ORDER BY APPROVAL_CD ASC) 
									= SUBSTRING(PRI.PR_NEXT_STATUS, 1, 1) AND CAST(W.APPROVAL_CD AS INT) >= CAST(PRI.PR_NEXT_STATUS AS INT)
							)
						)
					OR @typeUser = 'CURRENT_USER'
				)
            AND (1 = 1 OR (PRH.URGENT_DOC = 'Y' AND W.APPROVAL_CD >= PRI.PR_NEXT_STATUS))
    ) AS PRAPPROVAL_UNORDERED
    ;
    
    SELECT @MAX_RECORD = MIN(ROWMIN) FROM (VALUES (@MAX_RECORD), (@TOTAL_RECORD)) B(ROWMIN);
    SELECT @MAX_RECORD;
END