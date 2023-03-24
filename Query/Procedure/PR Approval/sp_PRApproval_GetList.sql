USE [PAS_DB_QA]
GO
/****** Object:  StoredProcedure [dbo].[sp_PRApproval_GetList]    Script Date: 7/4/2017 5:42:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Modified by : FID) Intan Puspitasari
-- Modified dt : 08-12-2015
-- Description : Change with new search param and remove union query
ALTER PROCEDURE [dbo].[sp_PRApproval_GetList]
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
    
    @regNo VARCHAR(50),
	@orderBy VARCHAR(20),
    @pageIndex INT,
    @pageSize INT
AS
BEGIN
	-- Created By   : alira.salman
    -- Created Date : 26.02.2015
    -- Description  : Get PRApproval module data (union of TB_R_PO_H and TB_R_PR_H).
    
    DECLARE
        @MAX_RECORD AS BIGINT,
		@POSITION_LEVEL INT
    
	SELECT TOP 1 @POSITION_LEVEL = POSITION_LEVEL FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = @regNo AND GETDATE() BETWEEN VALID_FROM AND VALID_TO
    SELECT @MAX_RECORD = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH';
    --SELECT @MAX_RECORD = MIN(ROWMIN) FROM (VALUES (@MAX_RECORD), (@pageIndex * @pageSize)) B(ROWMIN);
    
	

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
	DECLARE @currentApproverPosition VARCHAR(5)
		DECLARE @CurrenctOrgId INT,
				@currentLevelApproverPosition VARCHAR(5)
	SELECT  @TSQL = 'SELECT * FROM OPENQUERY([HRLINK],''EXEC [hrportal].[dbo].[sp_POA_User] ''''' + @regNo + ''''''')'
	
	INSERT INTO @HR_GRANTOR EXEC (@TSQL) 

		-- Approver modification
	SELECT TOP 1 @currentApproverPosition = POSITION_LEVEL, @CurrenctOrgId = ORG_ID
		FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = @regNo ORDER BY POSITION_LEVEL ASC
	SET @currentLevelApproverPosition = (SELECT LEVEL_ID FROM TB_M_ORG_POSITION WHERE POSITION_LEVEL = @currentApproverPosition)

	--IF (@userType = 'A')
	--BEGIN
		INSERT INTO @HR_GRANTOR
		SELECT DISTINCT 'GPS', 'GPS' + CAST(DENSE_RANK() OVER (ORDER BY WF.NOREG) AS VARCHAR), WF.NOREG, @regNo, GETDATE(), GETDATE(), 'AUTO', GETDATE(), 'GPS', NULL, NULL
		FROM TB_R_WORKFLOW WF 
			INNER JOIN TB_M_ORG_POSITION OP ON OP.POSITION_LEVEL = WF.APPROVER_POSITION AND OP.LEVEL_ID = @currentLevelApproverPosition 
			INNER JOIN TB_R_SYNCH_EMPLOYEE S ON S.NOREG = WF.NOREG AND S.ORG_ID = WF.STRUCTURE_ID AND GETDATE() BETWEEN S.VALID_FROM AND S.VALID_TO
				WHERE WF.STRUCTURE_ID = @CurrenctOrgId
	--END

    SELECT TOP (@pageSize) 
		PRAPPROVAL_ORDERED.*
    FROM
    (
        SELECT TOP (@MAX_RECORD) 
		CASE @orderBy WHEN 'DOC_NO|ASC' THEN ROW_NUMBER() OVER (ORDER BY PRAPPROVAL_UNORDERED.DOC_NO ASC, PRAPPROVAL_UNORDERED.DOC_DT DESC, PRAPPROVAL_UNORDERED.CHANGED_DT DESC)
					  WHEN 'DOC_NO|DESC' THEN ROW_NUMBER() OVER (ORDER BY PRAPPROVAL_UNORDERED.DOC_NO DESC, PRAPPROVAL_UNORDERED.DOC_DT DESC, PRAPPROVAL_UNORDERED.CHANGED_DT DESC)
					  WHEN 'DOC_DESC|ASC' THEN ROW_NUMBER() OVER (ORDER BY PRAPPROVAL_UNORDERED.DOC_DESC ASC, PRAPPROVAL_UNORDERED.DOC_DT DESC, PRAPPROVAL_UNORDERED.CHANGED_DT DESC, PRAPPROVAL_UNORDERED.DOC_NO ASC)
					  WHEN 'DOC_DESC|DESC' THEN ROW_NUMBER() OVER (ORDER BY PRAPPROVAL_UNORDERED.DOC_DESC DESC, PRAPPROVAL_UNORDERED.DOC_DT DESC, PRAPPROVAL_UNORDERED.CHANGED_DT DESC, PRAPPROVAL_UNORDERED.DOC_NO ASC)
					  WHEN 'DOC_DT|ASC' THEN ROW_NUMBER() OVER (ORDER BY PRAPPROVAL_UNORDERED.DOC_DT ASC, PRAPPROVAL_UNORDERED.CHANGED_DT DESC, PRAPPROVAL_UNORDERED.DOC_NO ASC)
					  WHEN 'DOC_DT|DESC' THEN ROW_NUMBER() OVER (ORDER BY PRAPPROVAL_UNORDERED.DOC_DT DESC,PRAPPROVAL_UNORDERED.CHANGED_DT DESC, PRAPPROVAL_UNORDERED.DOC_NO ASC)
					  WHEN 'CURR|ASC' THEN ROW_NUMBER() OVER (ORDER BY PRAPPROVAL_UNORDERED.CURR ASC, PRAPPROVAL_UNORDERED.DOC_DT DESC, PRAPPROVAL_UNORDERED.CHANGED_DT DESC, PRAPPROVAL_UNORDERED.DOC_NO ASC)
					  WHEN 'CURR|DESC' THEN ROW_NUMBER() OVER (ORDER BY PRAPPROVAL_UNORDERED.CURR DESC, PRAPPROVAL_UNORDERED.DOC_DT DESC, PRAPPROVAL_UNORDERED.CHANGED_DT DESC, PRAPPROVAL_UNORDERED.DOC_NO ASC)
					  WHEN 'AMOUNT|ASC' THEN ROW_NUMBER() OVER (ORDER BY PRAPPROVAL_UNORDERED.AMOUNT ASC, PRAPPROVAL_UNORDERED.DOC_DT DESC, PRAPPROVAL_UNORDERED.CHANGED_DT DESC, PRAPPROVAL_UNORDERED.DOC_NO ASC)
					  WHEN 'AMOUNT|DESC' THEN ROW_NUMBER() OVER (ORDER BY PRAPPROVAL_UNORDERED.AMOUNT DESC, PRAPPROVAL_UNORDERED.DOC_DT DESC, PRAPPROVAL_UNORDERED.CHANGED_DT DESC, PRAPPROVAL_UNORDERED.DOC_NO ASC)
					  WHEN 'STATUS_CD|ASC' THEN ROW_NUMBER() OVER (ORDER BY PRAPPROVAL_UNORDERED.STATUS_CD ASC, PRAPPROVAL_UNORDERED.DOC_DT DESC, PRAPPROVAL_UNORDERED.CHANGED_DT DESC, PRAPPROVAL_UNORDERED.DOC_NO ASC)
					  WHEN 'STATUS_CD|DESC' THEN ROW_NUMBER() OVER (ORDER BY PRAPPROVAL_UNORDERED.STATUS_CD DESC, PRAPPROVAL_UNORDERED.DOC_DT DESC, PRAPPROVAL_UNORDERED.CHANGED_DT DESC, PRAPPROVAL_UNORDERED.DOC_NO ASC)
					  WHEN 'PR_COORDINATOR|ASC' THEN ROW_NUMBER() OVER (ORDER BY PRAPPROVAL_UNORDERED.PR_COORDINATOR ASC, PRAPPROVAL_UNORDERED.DOC_DT DESC, PRAPPROVAL_UNORDERED.CHANGED_DT DESC, PRAPPROVAL_UNORDERED.DOC_NO ASC)
					  WHEN 'PR_COORDINATOR|DESC' THEN ROW_NUMBER() OVER (ORDER BY PRAPPROVAL_UNORDERED.PR_COORDINATOR DESC, PRAPPROVAL_UNORDERED.DOC_DT DESC, PRAPPROVAL_UNORDERED.CHANGED_DT DESC, PRAPPROVAL_UNORDERED.DOC_NO ASC)
					  WHEN 'DIVISION|ASC' THEN ROW_NUMBER() OVER (ORDER BY PRAPPROVAL_UNORDERED.DIVISION_NAME ASC, PRAPPROVAL_UNORDERED.DOC_DT DESC, PRAPPROVAL_UNORDERED.CHANGED_DT DESC, PRAPPROVAL_UNORDERED.DOC_NO ASC)
					  WHEN 'DIVISION|DESC' THEN ROW_NUMBER() OVER (ORDER BY PRAPPROVAL_UNORDERED.DIVISION_NAME DESC, PRAPPROVAL_UNORDERED.DOC_DT DESC, PRAPPROVAL_UNORDERED.CHANGED_DT DESC, PRAPPROVAL_UNORDERED.DOC_NO ASC)
					  ELSE ROW_NUMBER() OVER (ORDER BY PRAPPROVAL_UNORDERED.DOC_NO DESC, PRAPPROVAL_UNORDERED.DOC_DT DESC, PRAPPROVAL_UNORDERED.CHANGED_DT DESC)
					END AS 'NUMBER', 
		PRAPPROVAL_UNORDERED.*
        FROM
        (
            SELECT DISTINCT
                PRH.PR_NO AS 'DOC_NO',
                PRH.PR_DESC AS 'DOC_DESC',
                'PR' AS 'DOC_TYPE',
                CAST(PRH.DIVISION_ID AS VARCHAR) AS 'DIVISION_ID',
                --PRH.LOCAL_CURR_CD AS 'CURR',
				(select
    distinct 
        stuff((
                select DISTINCT ',' + PRI.ORI_CURR_CD
                from TB_R_PR_ITEM PRI
                where PRI.PR_NO = W.DOCUMENT_NO
                --order by u.PART_NO
                for xml path('')
        ),1,1,'') as partlist
    from TB_R_PR_ITEM
    group by ORI_CURR_CD) AS 'CURR',
                (
                    SELECT SUM(PRI_I.ORI_AMOUNT)
                    FROM TB_R_PR_ITEM PRI_I
                    WHERE PRI_I.PR_NO = W.DOCUMENT_NO
                ) AS 'AMOUNT',
				PRH.PR_COORDINATOR,
				PRH.DIVISION_NAME,
				PRH.PLANT_CD,
				PRH.SLOC_CD,
                PRH.PR_STATUS AS 'STATUS_CD',
                S.STATUS_DESC AS 'STATUS_DESC',
                PRH.DOC_DT AS 'DOC_DT',
                PRH.URGENT_DOC AS 'URGENT_DOC',
				PRH.CREATED_BY AS CREATED_BY,
				[dbo].[fn_date_format] (PRH.CREATED_DT) AS CREATED_DT,
				PRH.CHANGED_BY AS CHANGED_BY,
				[dbo].[fn_date_format] (PRH.CHANGED_DT) AS CHANGED_DT
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
						--OR ((W.APPROVED_BY = @regNo OR W.APPROVED_BY IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)) AND dbo.fn_dateadd_workday(-(W.APPROVAL_INTERVAL)+1, W.INTERVAL_DATE) <= GETDATE()
						--	AND SUBSTRING(W.APPROVAL_CD, 1, 1) = (SELECT TOP 1 SUBSTRING(SW.APPROVAL_CD, 1, 1) FROM TB_R_WORKFLOW SW WHERE SW.DOCUMENT_NO = W.DOCUMENT_NO AND SW.IS_APPROVED = 'Y' AND IS_DISPLAY = 'Y' ORDER BY APPROVAL_CD DESC) 
						--	AND W.IS_APPROVED = 'N')
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
							--****replace bellow condition with this condition in case ALL_USER given error query 'select sub query return more then one'****--
							--AND exists (SELECT 1 FROM TB_R_SYNCH_EMPLOYEE WHERE (NOREG = @regNo OR NOREG IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)) 
							--		AND GETDATE() BETWEEN VALID_FROM AND VALID_TO AND  SECTION_ID IN (SELECT SE1.SECTION_ID FROM TB_R_SYNCH_EMPLOYEE SE1
							--	 JOIN TB_R_WORKFLOW W1 ON W1.DOCUMENT_NO = W.DOCUMENT_NO AND W1.APPROVAL_CD = '21' AND W1.NOREG = SE1.NOREG))
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
    ) AS PRAPPROVAL_ORDERED
	WHERE PRAPPROVAL_ORDERED.NUMBER >= (((@pageIndex - 1) * @pageSize) + 1)
	ORDER BY PRAPPROVAL_ORDERED.NUMBER ASC
    ;
END
