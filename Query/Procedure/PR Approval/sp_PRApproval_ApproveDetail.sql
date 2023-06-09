USE [PAS_DB_QA]
GO
/****** Object:  StoredProcedure [dbo].[sp_PRApproval_ApproveDetail]    Script Date: 10/6/2017 9:52:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_PRApproval_ApproveDetail]
    -- Add the parameters for the stored procedure here
    @DOC_ITEM_LIST AS VARCHAR(MAX),
    @REG_NO AS VARCHAR(50),
	@PROCESS_ID BIGINT,
	@APPROVE_TYPE VARCHAR(7), --ITEM/HEADER
	@typeUser VARCHAR(20), --user type param on search criteria CURRENT_USER/ALL_USER
	@USER_ID VARCHAR(20),
	@MESSAGE VARCHAR(MAX) OUTPUT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    --SET NOCOUNT ON;

    -- Procedure Variables.
    DECLARE
        @MODE AS VARCHAR(3),
        @DOC_NO AS VARCHAR(11),
        @DOC_TYPE AS VARCHAR(2),
        @ITEM_NO AS VARCHAR(50),
        @ITEM_LIST AS VARCHAR(MAX),
		@DOC_NEXT_APPROVAL_CD AS VARCHAR(50),
        @DOC_LAST_APPROVAL_CD AS VARCHAR(50),
        @DOC_SUMMARY_APPROVAL_CD AS VARCHAR(50),
		@USER_NAME AS VARCHAR(20)= @REG_NO,
		@NEXT_PERSONNEL_NAME VARCHAR(100),
		@ITEM_DESCRIPTION AS VARCHAR(MAX),
		@LINK_PR_APPROVAL VARCHAR(100),
		@MAIL_HAS_ALREADY_SENT bit = 0,
		@AMOUNT_APPROVAL AS MONEY,
        @USER_NEXT_APPROVAL_CD AS VARCHAR(50),
		@USER_LAST_APPROVAL_CD AS VARCHAR(50)
    DECLARE
		@TOTAL_SUCCESS AS INT = 0,
        @TOTAL_FAIL AS INT = 0,
		@POSITION_LEVEL INT,
		@ORG_ID INT,
		@ORG_TITLE VARCHAR(40),
		@PERSONNEL_NAME VARCHAR(50)

    -- Temporary log variables
    DECLARE 
        @TB_TMP_LOG LOG_TEMP,
		@MESSAGE_ID VARCHAR(12) = '',
        @MODULE_ID VARCHAR(3) = '2',
        @MODULE_DESC VARCHAR(50) = 'Approve Detail',
        @FUNCTION_ID VARCHAR(6) = '203001'

    EXEC dbo.sp_PutLog 'Start', @USER_NAME, @MODULE_DESC, @PROCESS_ID OUTPUT, 'INF', 'INF', @MODULE_ID, @FUNCTION_ID, 0

    SET @MESSAGE_ID = 'INF00004';
    SET @MESSAGE = 'Approve Item for Document Number ' + SUBSTRING(@DOC_ITEM_LIST, 1, charindex('|', @DOC_ITEM_LIST)-1) + ' Started ';
    INSERT INTO @TB_TMP_LOG 
    SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '1', @USER_NAME

	SELECT TOP 1 @POSITION_LEVEL = POSITION_LEVEL, @ORG_ID = ORG_ID, @ORG_TITLE = ORG_TITLE, @PERSONNEL_NAME = PERSONNEL_NAME
		   FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = @REG_NO AND GETDATE() BETWEEN VALID_FROM AND VALID_TO ORDER BY POSITION_LEVEL DESC

    -- parsing delimiter : ',' 
    -- In format : [ITEM_INDEX : 1, ITEM_NO : ITEM_1], [ITEM_INDEX : 2, ITEM_NO : ITEM_2]
    -- item no list is filtered by related document.
    DECLARE @COUNTER AS INT;
    DECLARE @TB_TMP_ITEM AS TABLE
    (
        ROW_INDEX BIGINT IDENTITY(1, 1),
        ITEM_NO VARCHAR(50),
		NOREG VARCHAR(20)
    );

	DECLARE @TB_TMP_ITEM_STATUS AS TABLE
	(
		STATUS_CD VARCHAR(20),
		STATUS_DESC VARCHAR(20),
		SEGMENTATION_CD CHAR(2)
	);
	INSERT INTO @TB_TMP_ITEM_STATUS
	SELECT DISTINCT A.STATUS_CD, A.STATUS_DESC, A.SEGMENTATION_CD
	FROM TB_M_STATUS A 
		JOIN TB_R_SYNCH_EMPLOYEE B ON B.NOREG = @REG_NO
		JOIN TB_M_ORG_POSITION OP1 ON OP1.POSITION_LEVEL = A.POSITION_ID
		JOIN TB_M_ORG_POSITION OP2 ON OP2.POSITION_LEVEL = B.POSITION_LEVEL
	WHERE A.DOC_TYPE = 'PR' AND OP1.LEVEL_ID = OP2.LEVEL_ID

	DECLARE @TB_TMP_STATUS AS TABLE
    (
        STATUS_CD VARCHAR(2),
        STATUS_DESC VARCHAR(30)
    );
    INSERT INTO @TB_TMP_STATUS
    SELECT STATUS_CD, STATUS_DESC
    FROM TB_M_STATUS
    WHERE TB_M_STATUS.DOC_TYPE = 'PR'
    AND (SEGMENTATION_CD <> 9 OR STATUS_CD = '99')
	
	--Remove symbol ';' in the end of param
	IF (CHARINDEX(';', @DOC_ITEM_LIST) > 0 )
	BEGIN
		SET @DOC_ITEM_LIST = SUBSTRING(@DOC_ITEM_LIST, 1, CHARINDEX(';', @DOC_ITEM_LIST)-1)
	END

    -- Set DOC_NO
    SELECT @DOC_NO = Split FROM dbo.SplitString(@DOC_ITEM_LIST, '|')
    WHERE ISNULL(Split, '') <> '' AND [No] = 1;

    -- Set DOC_TYPE
    SELECT @DOC_TYPE = Split FROM dbo.SplitString(@DOC_ITEM_LIST, '|')
    WHERE ISNULL(Split, '') <> '' AND [No] = 2;

    -- Set MODE
    SELECT @MODE = Split FROM dbo.SplitString(@DOC_ITEM_LIST, '|')
    WHERE ISNULL(Split, '') <> '' AND [No] = 3;

    -- Set ITEM_LIST
    SELECT @ITEM_LIST = CASE WHEN(ISNULL(Split, '') <> '' AND (SUBSTRING(Split, LEN(Split), LEN(Split)) = ',')) THEN SUBSTRING(Split, 1, LEN(Split)-1) ELSE Split END 
	FROM dbo.SplitString(@DOC_ITEM_LIST, '|')
    WHERE [No] = 4;

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
	--DECLARE @TSQL VARCHAR(MAX)
	--SELECT  @TSQL = 'SELECT * FROM OPENQUERY([HRLINK],''EXEC [hrportal].[dbo].[sp_POA_User] ''''' + @REG_NO + ''''''')'
	
	--INSERT INTO @HR_GRANTOR EXEC (@TSQL) 

	INSERT INTO @HR_GRANTOR
      EXEC sp_POA_User

	DECLARE @currentApproverPosition VARCHAR(5)
	DECLARE @CurrenctOrgId INT,
			@currentLevelApproverPosition VARCHAR(5)

	-- Approver modification
	SELECT TOP 1 @currentApproverPosition = POSITION_LEVEL, @CurrenctOrgId = ORG_ID
		FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = @REG_NO ORDER BY POSITION_LEVEL ASC
	SET @currentLevelApproverPosition = (SELECT LEVEL_ID FROM TB_M_ORG_POSITION WHERE POSITION_LEVEL = @currentApproverPosition)

	INSERT INTO @HR_GRANTOR
	SELECT DISTINCT 'GPS', 'GPS' + CAST(DENSE_RANK() OVER (ORDER BY WF.NOREG) AS VARCHAR), WF.NOREG, @REG_NO, GETDATE(), GETDATE(), 'AUTO', GETDATE(), 'GPS', NULL, NULL
	FROM TB_R_WORKFLOW WF 
		INNER JOIN TB_M_ORG_POSITION OP ON OP.POSITION_LEVEL = WF.APPROVER_POSITION AND OP.LEVEL_ID = @currentLevelApproverPosition 
		INNER JOIN TB_R_SYNCH_EMPLOYEE S ON S.NOREG = WF.NOREG AND S.ORG_ID = WF.STRUCTURE_ID AND GETDATE() BETWEEN S.VALID_FROM AND S.VALID_TO
			WHERE WF.STRUCTURE_ID = @CurrenctOrgId

    -- Parsing ITEM phase.
    DELETE FROM @TB_TMP_ITEM WHERE NOREG = @REG_NO;
    INSERT INTO @TB_TMP_ITEM
    SELECT DISTINCT PRI.PR_ITEM_NO, @REG_NO
    FROM TB_R_PR_ITEM PRI
            JOIN TB_R_PR_H PRH ON PRH.PR_NO = PRI.PR_NO
            JOIN TB_R_WORKFLOW W ON W.DOCUMENT_NO = PRI.PR_NO AND W.ITEM_NO = PRI.PR_ITEM_NO
			JOIN TB_M_STATUS MS ON MS.STATUS_CD = PRI.PR_NEXT_STATUS AND PRI.PR_NEXT_STATUS <> '10'
            JOIN @TB_TMP_STATUS S ON S.STATUS_CD = PRI.PR_STATUS
			JOIN @TB_TMP_ITEM_STATUS ITS ON 1=1
            JOIN TB_M_SYSTEM C ON C.FUNCTION_ID = '20021' AND PRI.ASSET_CATEGORY = SUBSTRING(C.SYSTEM_CD, 4, 5)
        AND
            (PRI.PR_NO = @DOC_NO OR NULLIF(@DOC_NO, '') IS NULL)
            --AND W.IS_APPROVED = 'N' 
            AND W.IS_DISPLAY = 'Y'
            AND W.INTERVAL_DATE IS NOT NULL
            AND (
					(@typeUser = 'CURRENT_USER' AND W.IS_APPROVED = 'N' AND ((W.APPROVED_BY = @REG_NO OR W.APPROVED_BY IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)) AND PRI.PR_NEXT_STATUS = W.APPROVAL_CD))
					OR (@POSITION_LEVEL = 55 AND @typeUser = 'CURRENT_USER' AND W.APPROVAL_CD = '20' AND PRI.PR_NEXT_STATUS = W.APPROVAL_CD
						AND (SELECT TOP 1 SECTION_ID FROM TB_R_SYNCH_EMPLOYEE WHERE (NOREG = @REG_NO OR NOREG IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)) AND GETDATE() BETWEEN VALID_FROM AND VALID_TO) IN (SELECT SE1.SECTION_ID FROM TB_R_SYNCH_EMPLOYEE SE1
								JOIN TB_R_WORKFLOW W1 ON W1.DOCUMENT_NO = W.DOCUMENT_NO AND W1.APPROVAL_CD = '21' AND W1.NOREG = SE1.NOREG) AND W.IS_APPROVED = 'N')
					OR ((W.APPROVED_BY = @REG_NO OR W.APPROVED_BY IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)) AND dbo.fn_dateadd_workday(-(W.APPROVAL_INTERVAL), W.INTERVAL_DATE) <= GETDATE()
						AND SUBSTRING(W.APPROVAL_CD, 1, 1) = (SELECT TOP 1 SUBSTRING(SW.APPROVAL_CD, 1, 1) FROM TB_R_WORKFLOW SW WHERE SW.DOCUMENT_NO = W.DOCUMENT_NO AND SW.IS_APPROVED = 'Y' AND SW.IS_DISPLAY = 'Y' AND SW.ITEM_NO = PRI.PR_ITEM_NO ORDER BY APPROVAL_CD DESC) 
						AND W.IS_APPROVED = 'N')
					OR (@typeUser = 'CURRENT_USER' AND W.IS_APPROVED = 'N' AND (W.APPROVAL_CD = '30' AND PRI.PR_NEXT_STATUS = W.APPROVAL_CD 
						AND (SELECT TOP 1 SECTION_ID FROM TB_R_SYNCH_EMPLOYEE WHERE (NOREG = @REG_NO OR NOREG IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)) AND GETDATE() BETWEEN VALID_FROM AND VALID_TO) IN (SELECT SE1.SECTION_ID FROM TB_R_SYNCH_EMPLOYEE SE1
							JOIN TB_R_WORKFLOW W1 ON W1.DOCUMENT_NO = W.DOCUMENT_NO AND W1.APPROVAL_CD = '30' AND W1.NOREG = SE1.NOREG)))
					OR (@typeUser = 'ALL_USER')
				)
			AND (
					(@typeUser = 'ALL_USER' AND W.APPROVAL_CD <= ITS.STATUS_CD AND MS.SEGMENTATION_CD = ITS.SEGMENTATION_CD   
						AND EXISTS (SELECT 1 FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = W.DOCUMENT_NO AND ITEM_NO = W.ITEM_NO AND (APPROVED_BY = @REG_NO OR APPROVED_BY IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO))
						AND IS_DISPLAY = 'Y' AND (IS_APPROVED = 'N' OR (IS_APPROVED = 'Y' AND APPROVED_BYPASS IS NOT NULL)))
						AND (SELECT TOP 1 SUBSTRING(APPROVAL_CD, 1, 1) FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = W.DOCUMENT_NO AND ITEM_NO = W.ITEM_NO AND (APPROVED_BY = @REG_NO OR APPROVED_BY IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO))
							AND IS_DISPLAY = 'Y' AND (IS_APPROVED = 'N' OR (IS_APPROVED = 'Y' AND APPROVED_BYPASS IS NOT NULL)) ORDER BY APPROVAL_CD ASC) 
							= SUBSTRING(PRI.PR_NEXT_STATUS, 1, 1) AND CAST(W.APPROVAL_CD AS INT) >= CAST(PRI.PR_NEXT_STATUS AS INT)
					)
					OR (@typeUser = 'ALL_USER' AND (@POSITION_LEVEL = '55' AND W.APPROVAL_CD = '20' AND PRI.PR_NEXT_STATUS = W.APPROVAL_CD
								AND (SELECT TOP 1 SECTION_ID FROM TB_R_SYNCH_EMPLOYEE WHERE (NOREG = @REG_NO OR NOREG IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)) AND GETDATE() BETWEEN VALID_FROM AND VALID_TO) IN (SELECT SE1.SECTION_ID FROM TB_R_SYNCH_EMPLOYEE SE1
										JOIN TB_R_WORKFLOW W1 ON W1.DOCUMENT_NO = W.DOCUMENT_NO AND W1.APPROVAL_CD = '21' AND W1.NOREG = SE1.NOREG)))
					OR (@typeUser = 'ALL_USER' 
						AND 
							((W.APPROVED_BY = @REG_NO OR W.APPROVED_BY IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)) AND dbo.fn_dateadd_workday(-(W.APPROVAL_INTERVAL), W.INTERVAL_DATE) <= GETDATE()
								AND (SELECT TOP 1 SUBSTRING(APPROVAL_CD, 1, 1) FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = W.DOCUMENT_NO AND (APPROVED_BY = @REG_NO OR APPROVED_BY IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO))
									AND IS_DISPLAY = 'Y' AND IS_APPROVED = 'N' AND ITEM_NO = PRI.PR_ITEM_NO ORDER BY APPROVAL_CD ASC) 
									= SUBSTRING(PRI.PR_NEXT_STATUS, 1, 1) AND CAST(W.APPROVAL_CD AS INT) >= CAST(PRI.PR_NEXT_STATUS AS INT)
							)
						)
					OR @typeUser = 'CURRENT_USER'
			)
            AND (1 = 1 OR (PRH.URGENT_DOC = 'Y' AND W.APPROVAL_CD >= PRI.PR_NEXT_STATUS))
    WHERE (@MODE = 'INC' AND PRI.PR_ITEM_NO IN 
			(
				SELECT CASE WHEN (ISNULL(@ITEM_LIST, '') = '') THEN '' ELSE Split END 
                FROM dbo.SplitString(@ITEM_LIST, ',')
			))
        OR (@MODE = 'EXC' AND PRI.PR_ITEM_NO NOT IN 
			(
				SELECT CASE WHEN (ISNULL(@ITEM_LIST, '') = '') THEN '' ELSE Split END 
                FROM dbo.SplitString(@ITEM_LIST, ',')
			))

    SET @COUNTER = 1;
	SELECT @ITEM_NO = ITEM_NO FROM @TB_TMP_ITEM WHERE ROW_INDEX = @COUNTER AND NOREG = @REG_NO
    WHILE (ISNULL(@ITEM_NO, '') <> '')
    BEGIN            
        BEGIN TRANSACTION;
        BEGIN TRY
            -- PRAPPROVAL PROCESS
            -- Check if document approved is available.
            SET @MESSAGE_ID = 'INF00005';
            SET @MESSAGE = 'Check Document Availability. Doc.No : '  + @DOC_NO;
            INSERT INTO @TB_TMP_LOG 
            SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '1', @USER_NAME

            DECLARE @IS_DOC_LOCKED_BY_OTHER BIT = (SELECT CASE WHEN ISNULL(PROCESS_ID, 0) <> 0 AND PROCESS_ID <> @PROCESS_ID THEN 1 ELSE 0 END FROM TB_R_PR_H WHERE PR_NO = @DOC_NO)
            
            IF @IS_DOC_LOCKED_BY_OTHER = 0 -- is locked by other == false
            BEGIN
				--Note: Add completion checking, Cannot Release if completion is N
				DECLARE @IS_COMPLETE CHAR(1), @IS_URGENT CHAR(1)
				SELECT TOP 1 @IS_COMPLETE = PRI.COMPLETION, @IS_URGENT = PRH.URGENT_DOC  
					FROM TB_R_PR_ITEM PRI JOIN TB_R_PR_H PRH 
					ON PRI.PR_NO = PRH.PR_NO AND PRI.PR_NO = @DOC_NO AND PRI.PR_ITEM_NO = @ITEM_NO

				IF(@COUNTER = 1)
				BEGIN
					-- Lock document.
					SET @MESSAGE_ID = 'INF00007';
					SET @MESSAGE = 'Lock Document Number ' + @DOC_NO;
					INSERT INTO @TB_TMP_LOG 
					SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '1', @USER_NAME
                    
					UPDATE TB_R_PR_H SET PROCESS_ID = @PROCESS_ID WHERE PR_NO = @DOC_NO;
				END

				-- START APPROVE PROCESS.
				SET @MESSAGE_ID = 'INF00006';
				SET @MESSAGE = 'Approve PR ' + @DOC_NO + ' and Item No ' + @ITEM_NO +' Started.';
				INSERT INTO @TB_TMP_LOG 
				SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '1', @USER_NAME
                        
				-- Get document items.
				SET @MESSAGE_ID = 'INF00008';
				SET @MESSAGE = 'Get Document Items. Doc.No : '  + @DOC_NO;
				INSERT INTO @TB_TMP_LOG 
				SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '1', @USER_NAME
				

				-- Logic Get Document Next Approval Code.
				SELECT TOP 1
					@DOC_NEXT_APPROVAL_CD = APPROVAL_CD
				FROM TB_R_WORKFLOW
				WHERE
					DOCUMENT_NO = @DOC_NO
					AND ITEM_NO = @ITEM_NO
					AND IS_APPROVED = 'N'
					AND IS_DISPLAY = 'Y'
				ORDER BY DOCUMENT_SEQ ASC;

				-- Logic Get User Next Approval Code.
				DECLARE @IS_STAFF CHAR(1) = 'N'
				DECLARE @IS_BYPASS_FD CHAR(1) = 'N'
				DECLARE @IS_ATTORNEY CHAR(1) = 'N'
				DECLARE @IS_BYPASS_COORDINATOR CHAR(1) = 'N'
				IF(EXISTS (SELECT 1 FROM TB_R_WORKFLOW
					WHERE
						DOCUMENT_NO = @DOC_NO
						AND ITEM_NO = @ITEM_NO
						AND APPROVED_BY = @REG_NO
						AND IS_APPROVED = 'N'
						AND IS_DISPLAY = 'Y'))
				BEGIN
					SELECT TOP 1
						@USER_NEXT_APPROVAL_CD = APPROVAL_CD
					FROM TB_R_WORKFLOW
					WHERE
						DOCUMENT_NO = @DOC_NO
						AND ITEM_NO = @ITEM_NO
						AND APPROVED_BY = @REG_NO
						AND IS_APPROVED = 'N'
						AND IS_DISPLAY = 'Y'
					ORDER BY DOCUMENT_SEQ ASC;
				END
				ELSE
				BEGIN
					--Check if (abnormal case) Dph already bypass until coordinator, but want to bypass SH Coordinator(SH Division <> SH Coordinator)
					SET @USER_NEXT_APPROVAL_CD = ''
					SELECT TOP 1
						@USER_NEXT_APPROVAL_CD = APPROVAL_CD
					FROM TB_R_WORKFLOW W
						 JOIN TB_R_PR_ITEM PRI ON W.DOCUMENT_NO = PRI.PR_NO AND W.ITEM_NO = PRI.PR_ITEM_NO 
					WHERE
						W.DOCUMENT_NO = @DOC_NO
						AND W.ITEM_NO = @ITEM_NO
						AND W.APPROVED_BY = @REG_NO
						AND W.IS_APPROVED = 'Y'
						AND W.APPROVED_BYPASS IS NOT NULL
						AND W.IS_DISPLAY = 'Y'
						AND SUBSTRING(PRI.PR_NEXT_STATUS, 1, 1) = SUBSTRING(W.APPROVAL_CD, 1, 1)
					ORDER BY DOCUMENT_SEQ ASC;

					IF(@USER_NEXT_APPROVAL_CD IS NOT NULL AND @USER_NEXT_APPROVAL_CD <> '')
					BEGIN
						SET @IS_BYPASS_COORDINATOR = 'Y'
					END
					ELSE
					BEGIN
						--Check if next status is FD_Check(For bypass FD Check different user)
						SELECT TOP 1
							@USER_NEXT_APPROVAL_CD = APPROVAL_CD
						FROM TB_R_WORKFLOW
						WHERE
							DOCUMENT_NO = @DOC_NO
							AND ITEM_NO = @ITEM_NO
							AND IS_APPROVED = 'N'
							AND IS_DISPLAY = 'Y'
						ORDER BY DOCUMENT_SEQ ASC;


						IF(@USER_NEXT_APPROVAL_CD = '20')
						BEGIN
							SET @IS_STAFF = 'Y'
						END
						ELSE IF(@USER_NEXT_APPROVAL_CD = '30')
						BEGIN
							SET @IS_BYPASS_FD = 'Y'
						END
						ELSE
						BEGIN
							SET @IS_ATTORNEY = 'Y'
						END
					END
				END      

				-- Approve only valid if user is next approver
				-- or user is one segment with next approver.
				IF 
					@DOC_NEXT_APPROVAL_CD = @USER_NEXT_APPROVAL_CD
					OR SUBSTRING(@DOC_NEXT_APPROVAL_CD, 1, 1) = SUBSTRING(@USER_NEXT_APPROVAL_CD, 1, 1)
					OR @IS_BYPASS_FD = 'Y'
				BEGIN
					-- Logic Get Document Last Approval Code (Document Release).
					SELECT TOP 1 
						@DOC_LAST_APPROVAL_CD = APPROVAL_CD
					FROM TB_R_WORKFLOW
					WHERE
						DOCUMENT_NO = @DOC_NO
						AND ITEM_NO = @ITEM_NO
						AND IS_APPROVED = 'N'
						AND IS_DISPLAY = 'Y'
					ORDER BY DOCUMENT_SEQ DESC  

					IF((@IS_COMPLETE = 'Y') OR (@IS_COMPLETE = 'N' AND @IS_URGENT = 'Y') OR (@DOC_LAST_APPROVAL_CD <> @USER_NEXT_APPROVAL_CD))
					BEGIN
						-- Update WORKFLOW
						IF(@IS_BYPASS_FD = 'N' AND @IS_ATTORNEY = 'N')
						BEGIN
							UPDATE TB_R_WORKFLOW
							SET
								APPROVED_BY = CASE WHEN(APPROVED_BY <> @REG_NO) THEN @REG_NO ELSE APPROVED_BY END, --fill approved data, for status_cd = 20 (checked by staff)
								APPROVER_NAME = CASE WHEN(APPROVER_NAME <> @PERSONNEL_NAME) THEN @PERSONNEL_NAME ELSE APPROVER_NAME END,
								NOREG = CASE WHEN(NOREG <> @REG_NO) THEN @REG_NO ELSE NOREG END,
								STRUCTURE_ID = CASE WHEN(NOREG <> @ORG_ID) THEN @ORG_ID ELSE STRUCTURE_ID END,
								STRUCTURE_NAME = CASE WHEN(NOREG <> @ORG_TITLE) THEN @ORG_TITLE ELSE STRUCTURE_NAME END,
								APPROVED_DT = GETDATE(),
								IS_APPROVED = 'Y',
								IS_REJECTED = 'N',
								CHANGED_BY = @USER_NAME,
								CHANGED_DT = GETDATE()
							WHERE
								DOCUMENT_NO = @DOC_NO
								AND ITEM_NO = @ITEM_NO
								--AND APPROVED_BY = CASE WHEN (@POSITION_LEVEL = '55' AND @IS_STAFF = 'Y') THEN '-' ELSE @REG_NO END
								AND IS_APPROVED = 'N'
								AND IS_DISPLAY = 'Y'
								AND APPROVAL_CD = @USER_NEXT_APPROVAL_CD;

							-- Update WORKFLOW with BYPASS process.
							IF SUBSTRING(@DOC_NEXT_APPROVAL_CD, 1, 1) = SUBSTRING(@USER_NEXT_APPROVAL_CD, 1, 1)
							BEGIN
								UPDATE TB_R_WORKFLOW
								SET
									APPROVED_BYPASS = @REG_NO,
									APPROVED_DT = GETDATE(),
									IS_APPROVED = 'Y',
									IS_REJECTED = 'N',
									CHANGED_BY = @USER_NAME,
									CHANGED_DT = GETDATE()
								WHERE
									DOCUMENT_NO = @DOC_NO
									AND ITEM_NO = @ITEM_NO
									AND IS_APPROVED = 'N'
									AND IS_DISPLAY = 'Y'
									AND APPROVAL_CD < @USER_NEXT_APPROVAL_CD;
							END

						END
						ELSE --if bypass by fd different user
						BEGIN
							IF(@IS_BYPASS_COORDINATOR = 'Y')
							BEGIN
								UPDATE TB_R_WORKFLOW
									SET
										APPROVED_BYPASS = @REG_NO,
										APPROVED_DT = GETDATE(),
										IS_APPROVED = 'Y',
										IS_REJECTED = 'N',
										CHANGED_BY = @USER_NAME,
										CHANGED_DT = GETDATE()
									WHERE
										DOCUMENT_NO = @DOC_NO
										AND ITEM_NO = @ITEM_NO
										AND IS_APPROVED = 'N'
										AND IS_DISPLAY = 'Y'
										AND APPROVAL_CD < @USER_NEXT_APPROVAL_CD
										AND SUBSTRING(APPROVAL_CD, 1, 1) = SUBSTRING(@USER_NEXT_APPROVAL_CD, 1, 1);
							END
							ELSE
							BEGIN
								UPDATE TB_R_WORKFLOW
									SET
										APPROVED_BYPASS = @REG_NO,
										APPROVED_DT = GETDATE(),
										IS_APPROVED = 'Y',
										IS_REJECTED = 'N',
										CHANGED_BY = @USER_NAME,
										CHANGED_DT = GETDATE()
									WHERE
										DOCUMENT_NO = @DOC_NO
										AND ITEM_NO = @ITEM_NO
										AND IS_APPROVED = 'N'
										AND IS_DISPLAY = 'Y'
										AND APPROVAL_CD = @USER_NEXT_APPROVAL_CD;
							END
						END

						BEGIN ---COMPARE NEXT User Level id with Current User Level Id, if same then BYPASS next Approval 20170829
							DECLARE @Next_Following_LevelId int, 
								@Next_LevelId int,
								@USER_NEXT_FOLLOWING_APPROVAL_CD AS VARCHAR(50)

							select TOP 1 @Next_LevelId = MOP.LEVEL_ID 
							from TB_R_WORKFLOW WF
							INNER JOIN TB_R_SYNCH_EMPLOYEE SYNC ON SYNC.NOREG = WF.NOREG AND CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO
							INNER JOIN TB_M_ORG_POSITION MOP ON MOP.POSITION_LEVEL = SYNC.POSITION_LEVEL
							where DOCUMENT_NO =@DOC_NO AND ITEM_NO = @ITEM_NO AND APPROVAL_CD = @USER_NEXT_APPROVAL_CD

							SELECT TOP 1 @Next_Following_LevelId = MOP.LEVEL_ID, @USER_NEXT_FOLLOWING_APPROVAL_CD = WF.APPROVAL_CD
								FROM TB_R_WORKFLOW WF
								INNER JOIN TB_R_SYNCH_EMPLOYEE SYNC ON SYNC.NOREG = WF.NOREG AND CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO
								INNER JOIN TB_M_ORG_POSITION MOP ON MOP.POSITION_LEVEL = SYNC.POSITION_LEVEL
										AND IS_DISPLAY = 'Y' AND IS_APPROVED = 'N' AND APPROVED_BY <> '-' 
								WHERE DOCUMENT_NO =@DOC_NO AND ITEM_NO = @ITEM_NO  AND WF.APPROVAL_CD <> @USER_NEXT_APPROVAL_CD 
										AND SUBSTRING(WF.APPROVAL_CD, 1, 1) = SUBSTRING(@USER_NEXT_APPROVAL_CD, 1, 1)
							ORDER BY APPROVAL_CD ASC

							IF(@Next_LevelId = @Next_Following_LevelId AND @Next_Following_LevelId IS NOT NULL)
							BEGIN
								UPDATE TB_R_WORKFLOW
								SET
									APPROVED_BYPASS = @REG_NO,
									APPROVED_DT = GETDATE(),
									IS_APPROVED = 'Y',
									IS_REJECTED = 'N',
									CHANGED_BY = @USER_NAME,
									CHANGED_DT = GETDATE()
								WHERE
									DOCUMENT_NO = @DOC_NO
									AND ITEM_NO = @ITEM_NO
									AND IS_APPROVED = 'N'
									AND IS_DISPLAY = 'Y'
									AND APPROVAL_CD = @USER_NEXT_FOLLOWING_APPROVAL_CD;
							END
						END---COMPARE NEXT User Level id with Current User Level Id, if same then BYPASS next Approval 20170829

						-- Note : not using sp_backward checking again, replace with below code
						SELECT @USER_LAST_APPROVAL_CD = APPROVAL_CD
						FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @DOC_NO AND ITEM_NO = @ITEM_NO AND IS_APPROVED = 'N' AND IS_DISPLAY = 'Y' AND (APPROVED_BY = @REG_NO OR APPROVED_BY IN (SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO))
						IF EXISTS (SELECT 1 FROM TB_R_WORKFLOW W1 WHERE W1.DOCUMENT_NO = @DOC_NO AND W1.IS_APPROVED = 'N' AND W1.IS_DISPLAY = 'Y' AND 
									((@USER_LAST_APPROVAL_CD <> '21' AND SUBSTRING(W1.APPROVAL_CD, 1, 1) = SUBSTRING(@USER_LAST_APPROVAL_CD, 1, 1) AND W1.APPROVAL_CD < @USER_LAST_APPROVAL_CD AND 
										W1.ITEM_NO = @ITEM_NO AND W1.APPROVED_BY <> '-' AND W1.NOREG IN (SELECT NOREG FROM TB_R_WORKFLOW W2 WHERE W1.DOCUMENT_NO = W2.DOCUMENT_NO AND W2.APPROVED_BY <> '-' AND
										W1.ITEM_NO = W2.ITEM_NO AND SUBSTRING(W2.APPROVAL_CD, 1, 1) = SUBSTRING(@USER_NEXT_APPROVAL_CD, 1, 1) AND W2.APPROVAL_CD < @USER_NEXT_APPROVAL_CD
										))
									  OR @USER_LAST_APPROVAL_CD = '21'
									))
							AND (@USER_NEXT_APPROVAL_CD <> @USER_LAST_APPROVAL_CD)
						BEGIN
							--For bypass check bypass if approved by SH
							IF(@USER_LAST_APPROVAL_CD = '21')
							BEGIN
								UPDATE TB_R_WORKFLOW
								SET
									APPROVED_BYPASS = @REG_NO,
									APPROVED_DT = GETDATE(),
									IS_APPROVED = 'Y',
									IS_REJECTED = 'N',
									CHANGED_BY = @USER_NAME,
									CHANGED_DT = GETDATE()
								WHERE
									DOCUMENT_NO = @DOC_NO
									AND ITEM_NO = @ITEM_NO
									AND IS_APPROVED = 'N'
									AND IS_DISPLAY = 'Y'
									AND APPROVAL_CD <= @USER_LAST_APPROVAL_CD
									AND SUBSTRING(APPROVAL_CD, 1, 1) = SUBSTRING(@USER_LAST_APPROVAL_CD, 1, 1)
							END
							ELSE
							BEGIN
								--UPDATE TB_R_WORKFLOW
								--SET
								--	APPROVED_BYPASS = @REG_NO,
								--	APPROVED_DT = GETDATE(),
								--	IS_APPROVED = 'Y',
								--	IS_REJECTED = 'N',
								--	CHANGED_BY = @USER_NAME,
								--	CHANGED_DT = GETDATE()
								--WHERE
								--	DOCUMENT_NO = @DOC_NO
								--	AND ITEM_NO = @ITEM_NO
								--	AND IS_APPROVED = 'N'
								--	AND IS_DISPLAY = 'Y'
								--	AND APPROVAL_CD <= @USER_LAST_APPROVAL_CD;
								DECLARE @USER_NEXT_SEGMENTATION_CD CHAR(1)
								select @USER_NEXT_SEGMENTATION_CD = SEGMENTATION_CD from TB_M_STATUS WHERE DOC_TYPE='PR' AND STATUS_CD = @USER_NEXT_APPROVAL_CD
								DECLARE @USER_BYPASS_APPROVAL TABLE
								(
									SEGMENTATION_CD CHAR(1),
									STATUS_CD CHAR(2)
								)

								INSERT INTO @USER_BYPASS_APPROVAL
								SELECT MS.SEGMENTATION_CD, MS.STATUS_CD 
									FROM TB_M_STATUS MS
									INNER JOIN TB_R_WORKFLOW WF ON WF.APPROVAL_CD=MS.STATUS_CD AND WF.DOCUMENT_NO = @DOC_NO 
									AND WF.ITEM_NO = @ITEM_NO	AND WF.IS_APPROVED = 'N'	AND WF.IS_DISPLAY = 'Y'
									 WHERE MS.DOC_TYPE='PR' AND MS.STATUS_CD <= @USER_LAST_APPROVAL_CD
										AND NOT(MS.STATUS_CD > @USER_NEXT_APPROVAL_CD AND MS.SEGMENTATION_CD =@USER_NEXT_SEGMENTATION_CD)

								UPDATE TB_R_WORKFLOW
								SET
									APPROVED_BYPASS = @REG_NO,
									APPROVED_DT = GETDATE(),
									IS_APPROVED = 'Y',
									IS_REJECTED = 'N',
									CHANGED_BY = @USER_NAME,
									CHANGED_DT = GETDATE()
								WHERE
									DOCUMENT_NO = @DOC_NO
									AND ITEM_NO = @ITEM_NO
									AND IS_APPROVED = 'N'
									AND IS_DISPLAY = 'Y'
									AND APPROVAL_CD <= @USER_LAST_APPROVAL_CD
									AND APPROVAL_CD IN (SELECT STATUS_CD FROM @USER_BYPASS_APPROVAL);
									--AND SUBSTRING(APPROVAL_CD, 1, 1) <> SUBSTRING(@USER_NEXT_APPROVAL_CD, 1, 1);
							END
						END
						ELSE IF(@USER_NEXT_APPROVAL_CD <> @USER_LAST_APPROVAL_CD)
						BEGIN
							UPDATE TB_R_WORKFLOW
							SET
								APPROVED_BYPASS = @REG_NO,
								APPROVED_DT = GETDATE(),
								IS_APPROVED = 'Y',
								IS_REJECTED = 'N',
								CHANGED_BY = @USER_NAME,
								CHANGED_DT = GETDATE()
							WHERE
								DOCUMENT_NO = @DOC_NO
								AND ITEM_NO = @ITEM_NO
								AND IS_APPROVED = 'N'
								AND IS_DISPLAY = 'Y'
								AND APPROVAL_CD = @USER_LAST_APPROVAL_CD;
						END
	
						SELECT TOP 1
							@DOC_NEXT_APPROVAL_CD = APPROVAL_CD
						FROM TB_R_WORKFLOW
						WHERE
							DOCUMENT_NO = @DOC_NO
							AND ITEM_NO = @ITEM_NO
							AND IS_APPROVED = 'N'
							AND IS_DISPLAY = 'Y'
						ORDER BY DOCUMENT_SEQ ASC;

						--Note : if segment 1 (division) & segment 2 (coord) has same organization but different SH, and already bypass by DpH, 
						--so PR_STATUS must be max status cd on segement 1
						IF EXISTS(SELECT 1 FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @DOC_NO AND APPROVAL_CD <
										(SELECT TOP 1 APPROVAL_CD FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @DOC_NO	AND ITEM_NO = @ITEM_NO	AND IS_DISPLAY = 'Y' AND IS_APPROVED = 'N'	ORDER BY DOCUMENT_SEQ ASC)
								  AND IS_APPROVED = 'Y' AND IS_DISPLAY = 'Y')
						BEGIN
								SELECT TOP 1
									@USER_NEXT_APPROVAL_CD = APPROVAL_CD
								FROM TB_R_WORKFLOW
								WHERE
									DOCUMENT_NO = @DOC_NO
									AND APPROVAL_CD <
										(SELECT TOP 1 APPROVAL_CD 
											FROM TB_R_WORKFLOW
											WHERE DOCUMENT_NO = @DOC_NO
												AND ITEM_NO = @ITEM_NO
												AND IS_DISPLAY = 'Y'
												AND IS_APPROVED = 'N'
										ORDER BY DOCUMENT_SEQ ASC)
									AND IS_APPROVED = 'Y'
									AND IS_DISPLAY = 'Y'
								ORDER BY DOCUMENT_SEQ DESC;
						END ELSE BEGIN
							SET @USER_NEXT_APPROVAL_CD = @DOC_LAST_APPROVAL_CD
						END

						-- Update DOCUMENT DETAIL
						UPDATE TB_R_PR_ITEM
						SET
							PR_STATUS = (
								CASE 
									WHEN @USER_NEXT_APPROVAL_CD = @DOC_LAST_APPROVAL_CD THEN
										'14'
									ELSE
										@USER_NEXT_APPROVAL_CD
								END
							),
							PR_NEXT_STATUS = (
								CASE 
									WHEN @USER_NEXT_APPROVAL_CD = @DOC_LAST_APPROVAL_CD THEN
										'14'
									ELSE
										@DOC_NEXT_APPROVAL_CD
								END
							),
							IS_REJECTED = 'N',
							RELEASE_FLAG =
							(
								CASE 
									WHEN @USER_NEXT_APPROVAL_CD = @DOC_LAST_APPROVAL_CD THEN
										'Y'
									ELSE
										'N'
								END
							),
							/*OPEN_QTY =
							(
								CASE WHEN @USER_NEXT_APPROVAL_CD = @DOC_LAST_APPROVAL_CD 
									THEN PR_QTY - USED_QTY
									ELSE OPEN_QTY END
							),*/ --Why update OPEN_QTY when released?
							CHANGED_BY = @USER_NAME,
							CHANGED_DT = GETDATE()
						WHERE
							PR_NO = @DOC_NO
							AND PR_ITEM_NO = @ITEM_NO;

						DECLARE @CHECK_NEXT_APPROVAL VARCHAR(8)
						SELECT TOP 1 @CHECK_NEXT_APPROVAL = NOREG 
								FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @DOC_NO AND ITEM_NO = @ITEM_NO 
										AND IS_DISPLAY = 'Y' AND IS_APPROVED = 'N' AND APPROVED_BY <> '-' ORDER BY APPROVAL_CD ASC

						IF(@USER_NEXT_APPROVAL_CD = @DOC_LAST_APPROVAL_CD OR @CHECK_NEXT_APPROVAL IS NULL)
						BEGIN
							SET @DOC_LAST_APPROVAL_CD = '14'
						END

						-- Summary of DOCUMENT DETAIL
						-- Outstanding Status for document in TB_M_STATUS is 91.
						-- Released Status for document in TB_M_STATUS is 92.
						-- Alse check if the PR was routine type, the approval
						-- only released the document at the last month of fiscal year.
						-- otherwise the document would holded as oustanding.
						IF EXISTS (
							SELECT PR_NO
							FROM TB_R_PR_ITEM
							WHERE
								PR_NO = @DOC_NO
								AND PR_STATUS <> @DOC_LAST_APPROVAL_CD)
						BEGIN
							SET @DOC_SUMMARY_APPROVAL_CD = 91;
						END
						ELSE IF (
									SELECT PRH.PR_TYPE
									FROM TB_R_PR_H PRH
									WHERE PRH.PR_NO = @DOC_NO
								) = 'RT'
								AND DATEPART(MONTH, GETDATE()) < 4
						BEGIN
							SET @DOC_SUMMARY_APPROVAL_CD = 91;
						END
						ELSE
						BEGIN
							SET @DOC_SUMMARY_APPROVAL_CD = 92;
						END

						-- Update DOCUMENT HEADER
						-- Update document header occur after update document detail because
						-- document header update based on summary of document detail value.
						UPDATE TB_R_PR_H
						SET
							PR_STATUS = @DOC_SUMMARY_APPROVAL_CD,
							RELEASED_FLAG = 
							(
								CASE 
									WHEN @DOC_SUMMARY_APPROVAL_CD = 92 THEN
										'Y'
									ELSE
										'N'
								END
							),
							CHANGED_BY = @USER_NAME,
							CHANGED_DT = GETDATE()
						WHERE
							PR_NO = @DOC_NO;

						--EXEC sp_BackwardChecking_ApprovePRApproval @DOC_NO, @DOC_TYPE, @ITEM_NO;

						--Create Asset
						DECLARE @WBS_NO VARCHAR(30) = '', @ASSET VARCHAR(5) = ''
						SELECT @WBS_NO = WBS_NO, @ASSET = ASSET_CATEGORY FROM TB_R_PR_ITEM WHERE PR_NO = @DOC_NO AND PR_ITEM_NO = @ITEM_NO
						IF((ISNULL(@WBS_NO, '') <> '' AND ISNULL(@WBS_NO, 'X') <> 'X') AND (@ASSET = 'MA' OR @ASSET = 'MT' OR @ASSET = 'SA'))
						BEGIN
							--TO DO : Create Asset
							SET @WBS_NO = '' --delete this code if create asset is ready
						END

						--Announcement
						DECLARE @MESSAGE_ANN VARCHAR(MAX) = ''
						IF(@DOC_LAST_APPROVAL_CD = '14')
						BEGIN
							DECLARE @PIC VARCHAR(MAX) = '', @ITEM_CLASS CHAR(1) = ''
							SELECT @PIC = CASE WHEN(ISNULL(@PIC, '') = '') THEN @PIC ELSE @PIC + ';' END + APPROVED_BY FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @DOC_NO AND ITEM_NO = @ITEM_NO AND IS_DISPLAY = 'Y' AND APPROVED_BY <> '-'
							SET @MESSAGE_ANN = 'PR No ' + @DOC_NO + ' has been released'

							--INSERT INTO [dbo].[TB_R_ANNOUNCEMENT]
							--		([PROCESS_ID]
							--		,[MSG_TYPE]
							--		,[TARGET_RECIPIENT]
							--		,[MSG_CONTENT]
							--		,[MSG_ATTACHMENT]
							--		,[CREATED_BY]
							--		,[CREATED_DT]
							--		,[CHANGED_BY]
							--		,[CHANGED_DT])
							--	VALUES
							--		(@PROCESS_ID
							--		,'INF'
							--		,@PIC --all pic
							--		,@MESSAGE_ANN
							--		,NULL
							--		,@USER_ID
							--		,GETDATE()
							--		,NULL
							--		,NULL)

							SELECT @WBS_NO = WBS_NO, @ITEM_CLASS = ITEM_CLASS FROM TB_R_PR_ITEM WHERE PR_NO = @DOC_NO AND PR_ITEM_NO = @ITEM_NO
							IF((ISNULL(@WBS_NO, '') = '' OR ISNULL(@WBS_NO, 'X') = 'X') AND @ITEM_CLASS = 'M')
							BEGIN
									SET @MESSAGE_ANN = @MESSAGE_ANN + '</p><p>WBS No for Document No ' + @DOC_NO + ' and Item No ' + @ITEM_NO + ' still empty. Please fill WBS No.' 
							END		
						END
						ELSE
						BEGIN
							DECLARE @NEXT_APPROVER VARCHAR(8),
									@CURRENT_APPROVER VARCHAR(100)
							SELECT TOP 1 @NEXT_APPROVER = NOREG 
								FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @DOC_NO AND ITEM_NO = @ITEM_NO 
										AND IS_DISPLAY = 'Y' AND IS_APPROVED = 'N' AND APPROVED_BY <> '-' ORDER BY APPROVAL_CD ASC
							SELECT TOP 1 @CURRENT_APPROVER = PERSONNEL_NAME
								FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = @REG_NO
							SET @PIC = @REG_NO + ';' + @NEXT_APPROVER
							SET @MESSAGE_ANN = 'PR No ' + @DOC_NO + ' has been approved by ' + @CURRENT_APPROVER

							--INSERT INTO [dbo].[TB_R_ANNOUNCEMENT]
							--		([PROCESS_ID]
							--		,[MSG_TYPE]
							--		,[TARGET_RECIPIENT]
							--		,[MSG_CONTENT]
							--		,[MSG_ATTACHMENT]
							--		,[CREATED_BY]
							--		,[CREATED_DT]
							--		,[CHANGED_BY]
							--		,[CHANGED_DT])
							--	VALUES
							--		(@PROCESS_ID
							--		,'INF'
							--		,@PIC
							--		,@MESSAGE_ANN
							--		,NULL
							--		,@USER_ID
							--		,GETDATE()
							--		,NULL
							--		,NULL)
						END

						SELECT TOP 1 @AMOUNT_APPROVAL = PRI.LOCAL_AMOUNT, @ITEM_DESCRIPTION = PRI.MAT_DESC
						FROM TB_R_PR_ITEM PRI
						JOIN TB_R_PR_H PRH ON PRH.PR_NO = PRI.PR_NO
						WHERE PRI.PR_NO = @DOC_NO AND PR_ITEM_NO = @ITEM_NO

						SELECT @LINK_PR_APPROVAL = SYSTEM_VALUE   
						FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'MAIL' AND SYSTEM_CD = 'LINK_PRAPPROVAL' 

						SELECT TOP 1 @NEXT_PERSONNEL_NAME = PERSONNEL_NAME
							FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = @NEXT_APPROVER AND GETDATE() BETWEEN VALID_FROM AND VALID_TO 
						ORDER BY POSITION_LEVEL DESC

						--Note : Uncomment this if sp_send_email ready to execute
						--DECLARE @SUBJECT VARCHAR(100) = 'PR No ' + @DOC_NO + ' Item ' + @ITEM_NO + ' Approval ' + CAST(GETDATE() AS VARCHAR)
						DECLARE @SUBJECT VARCHAR(100) = '[PAS] PR Approval Notification'
						--DECLARE @BODY VARCHAR(MAX) = '<p>' + @MESSAGE_ANN + '</p>'
						DECLARE @BODY VARCHAR(MAX) = '<br/>PR No : <a href="'+@LINK_PR_APPROVAL+'">' + @DOC_NO + '</a><br/>';
						SET @BODY = @BODY + '<table  style = "border: 1px solid black;border-collapse: collapse; width: 800px">';
						SET @BODY = @BODY + '	<tr style = "border: 1px solid black;">';
						SET @BODY = @BODY + '		<th style = "border: 1px solid black;text-align: left;font-weight: normal;width: 100px;">PR Item No</th>';
						SET @BODY = @BODY + '		<th style = "border: 1px solid black;text-align: left;font-weight: normal;">Description</th>';
						SET @BODY = @BODY + '		<th style = "border: 1px solid black;text-align: center;font-weight: normal;width: 200px;">Amount</th>';
						SET @BODY = @BODY + '	</tr>';

						declare @i_numItem AS int = 0
						DECLARE db_cursor CURSOR FOR  
						select DISTINCT item.PR_ITEM_NO, item.MAT_DESC, item.LOCAL_AMOUNT 
						from TB_R_PR_H h
						INNER JOIN TB_R_PR_ITEM item ON item.PR_NO = h.PR_NO
						INNER JOIN tb_r_workflow wflow ON wflow.DOCUMENT_NO = item.PR_NO AND wflow.ITEM_NO = item.PR_ITEM_NO and wflow.NOREG = @REG_NO
						INNER JOIN tb_r_workflow wflow2 ON wflow2.DOCUMENT_NO = item.PR_NO AND wflow2.ITEM_NO = item.PR_ITEM_NO and wflow2.NOREG = @NEXT_APPROVER
						where h.PR_NO = @DOC_NO  AND wflow.IS_DISPLAY = 'Y'-- AND wflow.IS_APPROVED = 'Y' AND wflow.APPROVED_DT IS NOT NULL
							AND wflow2.IS_DISPLAY = 'Y' AND wflow2.IS_APPROVED = 'N' OR (wflow2.IS_REJECTED ='Y' AND wflow2.APPROVED_DT IS NULL)
							AND item.PR_ITEM_NO like (CASE WHEN @APPROVE_TYPE = 'HEADER' THEN '%%' ELSE @ITEM_NO END)
							AND item.PR_ITEM_NO in (Select ITEM_NO from @TB_TMP_ITEM)

						OPEN db_cursor   
						FETCH NEXT FROM db_cursor INTO @ITEM_NO, @ITEM_DESCRIPTION, @AMOUNT_APPROVAL

						WHILE @@FETCH_STATUS = 0   
						BEGIN   
							SET @BODY = @BODY + '	<tr style = "border: 1px solid black;">';
							SET @BODY = @BODY + '		<th style = "border: 1px solid black;text-align: left;font-weight: normal;width: 100px;">' + @ITEM_NO + '</th>';
							SET @BODY = @BODY + '		<th style = "border: 1px solid black;text-align: left;font-weight: normal;">' + @ITEM_DESCRIPTION + '</th>';
							SET @BODY = @BODY + '		<th style = "border: 1px solid black;text-align: right;font-weight: normal;width: 200px;">' + convert(varchar, cast(@AMOUNT_APPROVAL as money), 1) + '</th>';
							SET @BODY = @BODY + '	</tr>';

							SET @i_numItem = @i_numItem + 1
							FETCH NEXT FROM db_cursor INTO @ITEM_NO, @ITEM_DESCRIPTION, @AMOUNT_APPROVAL 
						END 

						SET @BODY = @BODY + '</table></p>';
						SET @BODY = @BODY + '<br/><a href="'+@LINK_PR_APPROVAL+'">[Go To PR Approval]</a> Click this link to display all PR Approval on PAS.';
						SET @BODY = @BODY + '<p>Best Regards,</p>PAS Admin<br/>';

						DECLARE @BODYHEADER VARCHAR(MAX) = '<p>Dear '+@NEXT_PERSONNEL_NAME+', <br/><br/>You have '+CAST(@i_numItem AS VARCHAR)+' worklist to be approved.'; 
						SET @BODY =  @BODYHEADER + @BODY;

						CLOSE db_cursor   
						DEALLOCATE db_cursor

						IF(@MAIL_HAS_ALREADY_SENT=0) BEGIN
							IF(@DOC_LAST_APPROVAL_CD = '14')
							BEGIN
								SET @MESSAGE_ANN = @MESSAGE_ANN + '<br/>'
								EXEC [dbo].[sp_announcement_sendmail]
	  									@REG_NO,
										@SUBJECT,
										@MESSAGE_ANN,
										@MESSAGE OUTPUT
							END
							ELSE
							BEGIN
								EXEC [dbo].[sp_announcement_sendmail]
	  									@NEXT_APPROVER,
										@SUBJECT,
										@BODY,
										@MESSAGE OUTPUT
							END
							SET @MAIL_HAS_ALREADY_SENT = 1
						END ELSE BEGIN
							SET @MESSAGE = 'SUCCESS'
						END

						IF(@MESSAGE <> 'SUCCESS')
						BEGIN
							RAISERROR(@MESSAGE, 16, 1)
						END

						-- FINISH APPROVE PROCESS.                
						SET @MESSAGE_ID = 'INF00009';
						SET @MESSAGE = 'Approve ' + @DOC_TYPE + ' Finished. Doc.No : '  + @DOC_NO;
						INSERT INTO @TB_TMP_LOG 
						SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '2', @USER_NAME

						SET @TOTAL_SUCCESS = @TOTAL_SUCCESS + 1;
					END
					ELSE 
					BEGIN
						-- Document is not completed
						SET @MESSAGE = 'Document ' + @DOC_NO + ' Item No ' + @ITEM_NO + ' is not completed yet. Cannot be released.';
						RAISERROR(@MESSAGE, 16, 1)
					END
				END
				ELSE
				BEGIN
					SET @MESSAGE = 'Current user ' + @USER_NAME + ' was not next approver. Doc.No : '  + @DOC_NO;
					RAISERROR(@MESSAGE, 16, 1)
				END 
            END
            ELSE
            BEGIN
                -- Document approved is unavailable.
                SET @MESSAGE = 'Document still being used by other user';
                RAISERROR(@MESSAGE, 16, 1)
            END

            UPDATE TB_R_PR_H SET PROCESS_ID = NULL WHERE PR_NO = @DOC_NO

			SET @MESSAGE_ID = 'INF00017';
            SET @MESSAGE = 'Approve PR ' + @DOC_NO + ' and Item No ' + @ITEM_NO + ' Success.';
            INSERT INTO @TB_TMP_LOG 
            SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '2', @USER_NAME
            COMMIT
        END TRY
        BEGIN CATCH      
			--Get the details of the error
            --that invoked the CATCH block
            SET @MESSAGE_ID = 'ERR00017';
            SET @MESSAGE = 'Approve PR ' + @DOC_NO + ' and Item No ' + @ITEM_NO + ' Failed. Message : ' + ERROR_MESSAGE() + '.';
            ROLLBACK
			INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'ERR', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '3', @USER_NAME
                
            SET @TOTAL_FAIL = @TOTAL_FAIL + 1;
        END CATCH;    
        -- END PRAPPROVAL PROCESS

		SET @COUNTER = @COUNTER + 1
		SET @ITEM_NO = NULL
        SELECT @ITEM_NO = ITEM_NO FROM @TB_TMP_ITEM WHERE ROW_INDEX = @COUNTER AND NOREG = @REG_NO
    END

	IF(@TOTAL_FAIL = 0 AND (@COUNTER-1) > 0)
	BEGIN
		SET @MESSAGE_ID = 'INF00004';
		SET @MESSAGE = 'Approve Item for Document Number ' + @DOC_NO + ' Ended Successfully';
		INSERT INTO @TB_TMP_LOG 
		SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '2', @USER_NAME
	END
	ELSE
	BEGIN
		SET @MESSAGE_ID = 'INF00005';
		SET @MESSAGE = 'Approve Item for Document Number ' + @DOC_NO + ' Ended with Error';
		INSERT INTO @TB_TMP_LOG 
		SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '3', @USER_NAME
	END

    -- Release temporary log.
    EXEC SP_PUTLOG_TEMP @TB_TMP_LOG;
    
	SET @MESSAGE = CAST((@COUNTER-1) AS VARCHAR(5)) + '|' + CAST(@TOTAL_SUCCESS AS VARCHAR(5)) + '|' + CAST(@TOTAL_FAIL AS VARCHAR(5))
    
	IF(@APPROVE_TYPE <> 'HEADER')
	BEGIN
		SELECT @PROCESS_ID PROCESS_ID, 'APPROVE' AS 'ACTION', 1 AS 'DOC_COUNT', (@COUNTER-1) AS 'ITEM_COUNT', @TOTAL_SUCCESS AS 'SUCCESS', @TOTAL_FAIL AS 'FAIL', @PROCESS_ID AS 'MESSAGE';
	END
END