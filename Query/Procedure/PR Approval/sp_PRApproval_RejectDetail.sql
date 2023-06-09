
/****** Object:  StoredProcedure [dbo].[sp_PRApproval_RejectDetail]    Script Date: 10/6/2017 10:34:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		alira.salman
-- Create date: 27.03.2015
-- Description:	Reject PRApproval Detail

-- Modified by	: FID)Intan Puspitasari
-- Modified dt	: 15-12-2015
-- Description	: Change SP for PR Approval Only
-- =============================================
ALTER PROCEDURE [dbo].[sp_PRApproval_RejectDetail]
	-- Add the parameters for the stored procedure here
	@DOC_ITEM_LIST AS VARCHAR(MAX),
	@USER_NAME AS VARCHAR(20),
    @REG_NO AS VARCHAR(50),
	@PROCESS_ID BIGINT,
	@REJECT_TYPE VARCHAR(7), --ITEM/HEADER,
	@typeUser VARCHAR(20), --user type param on search criteria CURRENT_USER/ALL_USER
	@MESSAGE VARCHAR(MAX) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--//// Procedure Variables.
	DECLARE
		@MODE AS VARCHAR(3),
		@DOC_NO AS VARCHAR(11),
		@DOC_TYPE AS VARCHAR(2),
		@ITEM_NO AS VARCHAR(50),
		@ITEM_LIST AS VARCHAR(MAX),
		@DOC_APPROVAL_CD AS VARCHAR(50),
		@DOC_NEXT_APPROVAL_CD AS VARCHAR(50),
		@DOC_LAST_APPROVAL_CD AS VARCHAR(50),
		@DOC_SUMMARY_APPROVAL_CD AS VARCHAR(50),
		@USER_NEXT_APPROVAL_CD AS VARCHAR(50),
		@USER_DOC_SEQ AS INT,
		@POSITION_LEVEL INT,
		@ORG_ID INT,
		@ORG_TITLE VARCHAR(40),
		@PERSONNEL_NAME VARCHAR(50),
		@TOTAL_SUCCESS AS INT = 0,
		@TOTAL_FAIL AS INT = 0,
		@TB_TMP_LOG LOG_TEMP,
		@MESSAGE_ID VARCHAR(12) = '',
		@MODULE_ID VARCHAR(3) = '2',
		@MODULE_DESC VARCHAR(50) = 'Reject PRApproval Detail',
		@FUNCTION_ID VARCHAR(6) = '203003',
		@LINK_PR_APPROVAL VARCHAR(100),
		@NEXT_PERSONNEL_NAME VARCHAR(100),
		@ITEM_DESCRIPTION AS VARCHAR(MAX),
		@AMOUNT_APPROVAL AS MONEY,
		@STATUS VARCHAR(10) = 'SUCCESS'

	BEGIN TRY
		EXEC dbo.sp_PutLog 'Start', @USER_NAME, @MODULE_DESC, @PROCESS_ID OUTPUT, 'INF', 'INF', @MODULE_ID, @FUNCTION_ID, 0

		SET @MESSAGE_ID = 'INF00005';
		SET @MESSAGE = 'Get Last Process ID. Process.ID : ' + CAST(@PROCESS_ID AS VARCHAR);
		INSERT INTO @TB_TMP_LOG 
		SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '1', @USER_NAME

		SET @MESSAGE_ID = 'INF00004';
		SET @MESSAGE = 'Reject Item for Document Number ' + SUBSTRING(@DOC_ITEM_LIST, 1, charindex('|', @DOC_ITEM_LIST)-1) + ' Started ';
		INSERT INTO @TB_TMP_LOG 
		SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '1', @USER_NAME

		SELECT TOP 1 @POSITION_LEVEL = POSITION_LEVEL, @ORG_ID = ORG_ID, @ORG_TITLE = ORG_TITLE, @PERSONNEL_NAME = PERSONNEL_NAME
			   FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = @REG_NO ORDER BY POSITION_LEVEL DESC

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
		DECLARE @TSQL VARCHAR(MAX)
		SELECT  @TSQL = 'SELECT * FROM OPENQUERY([HRLINK],''EXEC [hrportal].[dbo].[sp_POA_User] ''''' + @REG_NO + ''''''')'
	
		INSERT INTO @HR_GRANTOR EXEC (@TSQL) 

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


	END TRY
	BEGIN CATCH      
		--Remove symbol ';' in the end of param
		IF (CHARINDEX(';', @DOC_ITEM_LIST) > 0 )
		BEGIN
			SET @DOC_ITEM_LIST = SUBSTRING(@DOC_ITEM_LIST, 1, CHARINDEX(';', @DOC_ITEM_LIST)-1)
		END

		-- Set DOC_NO
		SELECT @DOC_NO = Split FROM dbo.SplitString(@DOC_ITEM_LIST, '|')
		WHERE ISNULL(Split, '') <> '' AND [No] = 1;

		SET @MESSAGE_ID = 'ERR00017';
		SET @MESSAGE = 'Reject PR ' + @DOC_NO + ' Failed at line : '+CONVERT(VARCHAR,ERROR_LINE())+'. Message : ' + ERROR_MESSAGE() + '.';
		INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'ERR', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '3', @USER_NAME
                
		SET @STATUS = 'FAILED'
	END CATCH;  

	IF (@STATUS = 'SUCCESS')
	BEGIN
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
							AND EXISTS (SELECT 1 FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = W.DOCUMENT_NO AND (APPROVED_BY = @REG_NO OR APPROVED_BY IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO))
							AND IS_DISPLAY = 'Y' AND (IS_APPROVED = 'N' OR (IS_APPROVED = 'Y' AND APPROVED_BYPASS IS NOT NULL)))
							AND (SELECT TOP 1 SUBSTRING(APPROVAL_CD, 1, 1) FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = W.DOCUMENT_NO AND (APPROVED_BY = @REG_NO OR APPROVED_BY IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO))
								AND IS_DISPLAY = 'Y' AND (IS_APPROVED = 'N' OR (IS_APPROVED = 'Y' AND APPROVED_BYPASS IS NOT NULL)) ORDER BY APPROVAL_CD ASC) 
								= SUBSTRING(PRI.PR_NEXT_STATUS, 1, 1)
						)
						OR (@typeUser = 'ALL_USER' AND (@POSITION_LEVEL = '55' AND W.APPROVAL_CD = '20' AND PRI.PR_NEXT_STATUS = W.APPROVAL_CD
									AND (SELECT TOP 1 SECTION_ID FROM TB_R_SYNCH_EMPLOYEE WHERE (NOREG = @REG_NO OR NOREG IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)) AND GETDATE() BETWEEN VALID_FROM AND VALID_TO) IN (SELECT SE1.SECTION_ID FROM TB_R_SYNCH_EMPLOYEE SE1
											JOIN TB_R_WORKFLOW W1 ON W1.DOCUMENT_NO = W.DOCUMENT_NO AND W1.APPROVAL_CD = '21' AND W1.NOREG = SE1.NOREG)))
						OR (@typeUser = 'ALL_USER' 
							AND 
								((W.APPROVED_BY = @REG_NO OR W.APPROVED_BY IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)) AND dbo.fn_dateadd_workday(-(W.APPROVAL_INTERVAL), W.INTERVAL_DATE) <= GETDATE()
									AND (SELECT TOP 1 SUBSTRING(APPROVAL_CD, 1, 1) FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = W.DOCUMENT_NO AND (APPROVED_BY = @REG_NO OR APPROVED_BY IN(SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO))
										AND IS_DISPLAY = 'Y' AND IS_APPROVED = 'N' AND ITEM_NO = PRI.PR_ITEM_NO ORDER BY APPROVAL_CD ASC) 
										= SUBSTRING(PRI.PR_NEXT_STATUS, 1, 1)
								)
							)
						OR @typeUser = 'CURRENT_USER'
				)
				AND (1 = 1 OR (PRH.URGENT_DOC = 'Y' AND W.APPROVAL_CD >= PRI.PR_NEXT_STATUS))
		WHERE (@MODE = 'INC' AND PRI.PR_ITEM_NO IN (SELECT Split 
					FROM dbo.SplitString(@ITEM_LIST, ',') SS
					WHERE ISNULL(SS.Split, '') <> '')
					AND PRI.PR_NO = @DOC_NO)
			OR (@MODE = 'EXC' AND PRI.PR_ITEM_NO NOT IN (SELECT Split 
					FROM dbo.SplitString(@ITEM_LIST, ',') SS
					WHERE ISNULL(SS.Split, '') <> '')
					AND PRI.PR_NO = @DOC_NO)	

		SET @COUNTER = 1;
		SELECT @ITEM_NO = ITEM_NO FROM @TB_TMP_ITEM WHERE ROW_INDEX = @COUNTER AND NOREG = @REG_NO
	END

	SELECT @LINK_PR_APPROVAL = SYSTEM_VALUE   
	FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'MAIL' AND SYSTEM_CD = 'LINK_PRAPPROVAL'
	--Note : Uncomment this if sp_send_email ready to execute
	DECLARE @SUBJECT VARCHAR(100) = '[PAS] PR Rejection Notification'
	DECLARE @BODY VARCHAR(MAX) = '<br/>PR No : <a href="'+@LINK_PR_APPROVAL+'">' + @DOC_NO + '</a><br/>';
	SET @BODY = @BODY + '<table  style = "border: 1px solid black;border-collapse: collapse; width: 800px">';
	SET @BODY = @BODY + '	<tr style = "border: 1px solid black;">';
	SET @BODY = @BODY + '		<th style = "border: 1px solid black;text-align: left;font-weight: normal;width: 100px;">PR Item No</th>';
	SET @BODY = @BODY + '		<th style = "border: 1px solid black;text-align: left;font-weight: normal;">Description</th>';
	SET @BODY = @BODY + '		<th style = "border: 1px solid black;text-align: center;font-weight: normal;width: 200px;">Amount</th>';
	SET @BODY = @BODY + '	</tr>';

    WHILE (ISNULL(@ITEM_NO, '') <> '')
    BEGIN            
        BEGIN TRANSACTION;
        BEGIN TRY
				--//// PRAPPROVAL PROCESS
				-- Check if document approved is available.
				SET @MESSAGE_ID = 'INF00005';
				SET @MESSAGE = 'Check Document Availability. Doc.No : '  + @DOC_NO;
				INSERT INTO @TB_TMP_LOG 
				SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '1', @USER_NAME

				DECLARE @IS_DOC_LOCKED_BY_OTHER BIT = (SELECT CASE WHEN ISNULL(PROCESS_ID, 0) <> 0 AND PROCESS_ID <> @PROCESS_ID THEN 1 ELSE 0 END FROM TB_R_PR_H WHERE PR_NO = @DOC_NO)
            
				IF ISNULL(@IS_DOC_LOCKED_BY_OTHER, 0) = 0
				BEGIN
					IF(@COUNTER = 1)
					BEGIN
						-- Lock document.
						SET @MESSAGE_ID = 'INF00007';
						SET @MESSAGE = 'Lock Document Number ' + @DOC_NO;
						INSERT INTO @TB_TMP_LOG 
						SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '1', @USER_NAME
                    
						UPDATE TB_R_PR_H SET PROCESS_ID = @PROCESS_ID WHERE PR_NO = @DOC_NO;

					END

					-- START REJECT PROCESS.
					SET @MESSAGE_ID = 'INF00006';
					SET @MESSAGE = 'Reject PR ' + @DOC_NO + ' and Item No ' + @ITEM_NO +' Started.';
					INSERT INTO @TB_TMP_LOG 
					SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '1', @USER_NAME
                	
					-- Get document items.
					SET @MESSAGE_ID = 'INF00008';
					SET @MESSAGE = 'Get Document Items. Doc.No : '  + @DOC_NO;
					INSERT INTO @TB_TMP_LOG 
					SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '1', @USER_NAME
					
					-- Logic Get Document Current Approval Code.
					SELECT TOP 1 @DOC_APPROVAL_CD = APPROVAL_CD
					FROM TB_R_WORKFLOW wf
					WHERE
						DOCUMENT_NO = @DOC_NO
						AND ITEM_NO = @ITEM_NO
						AND IS_APPROVED = 'Y'
						AND IS_DISPLAY = 'Y' and not exists (select 1 from TB_R_WORKFLOW wf2 where WF2.DOCUMENT_NO = WF.DOCUMENT_NO and  WF2.ITEM_NO = WF.ITEM_NO and wf2.IS_APPROVED = 'N' AND wf2.DOCUMENT_SEQ < Wf.DOCUMENT_SEQ)
					ORDER BY DOCUMENT_SEQ DESC

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
					IF(EXISTS (SELECT 1 FROM TB_R_WORKFLOW
						WHERE
							DOCUMENT_NO = @DOC_NO
							AND ITEM_NO = @ITEM_NO
							AND APPROVED_BY = @REG_NO
							AND IS_APPROVED = 'N'
							AND IS_DISPLAY = 'Y'))
					BEGIN
						SELECT TOP 1
							@USER_NEXT_APPROVAL_CD = APPROVAL_CD,
							@USER_DOC_SEQ = DOCUMENT_SEQ
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
						SELECT TOP 1
						@USER_NEXT_APPROVAL_CD = APPROVAL_CD
						FROM TB_R_WORKFLOW
						WHERE
							DOCUMENT_NO = @DOC_NO
							AND ITEM_NO = @ITEM_NO
							AND IS_APPROVED = 'N'
							AND IS_DISPLAY = 'Y'
						ORDER BY DOCUMENT_SEQ ASC;

						--Check if next status is FD_Check(For bypass FD Check different user)
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
					
					-- Logic Get Document Last Approval Code (Document Release).
					SELECT 
						@DOC_LAST_APPROVAL_CD = MAX(STATUS_CD)
					FROM TB_M_STATUS
					WHERE
						DOC_TYPE = @DOC_TYPE
						AND SEGMENTATION_CD <> '9'
					GROUP BY SEGMENTATION_CD, STATUS_CD
					ORDER BY SEGMENTATION_CD ASC, STATUS_CD ASC;

					-- Approve only valid if user is next approver
					IF (@DOC_NEXT_APPROVAL_CD = @USER_NEXT_APPROVAL_CD)
					BEGIN
						IF(@IS_BYPASS_FD = 'N' AND @IS_ATTORNEY = 'N')
						BEGIN
							-- Update WORKFLOW
							UPDATE TB_R_WORKFLOW
							SET
								APPROVED_BY = CASE WHEN(APPROVED_BY <> @REG_NO) THEN @REG_NO ELSE APPROVED_BY END, --fill approved data, for status_cd = 20 (checked by staff)
								APPROVER_NAME = CASE WHEN(APPROVER_NAME <> @PERSONNEL_NAME) THEN @PERSONNEL_NAME ELSE APPROVER_NAME END,
								NOREG = CASE WHEN(NOREG <> @REG_NO) THEN @REG_NO ELSE NOREG END,
								STRUCTURE_ID = CASE WHEN(NOREG <> @ORG_ID) THEN @ORG_ID ELSE STRUCTURE_ID END,
								STRUCTURE_NAME = CASE WHEN(NOREG <> @ORG_TITLE) THEN @ORG_TITLE ELSE STRUCTURE_NAME END,
								APPROVED_DT = GETDATE(),
								IS_REJECTED = 'Y',
								CHANGED_BY = @USER_NAME,
								CHANGED_DT = GETDATE()
							WHERE
								DOCUMENT_NO = @DOC_NO
								AND ITEM_NO = @ITEM_NO
								--AND APPROVED_BY = CASE WHEN (@POSITION_LEVEL = '55' AND @IS_STAFF = 'Y') THEN '-' ELSE @REG_NO END
								AND IS_APPROVED = 'N'
								AND IS_DISPLAY = 'Y'
								AND APPROVAL_CD = @USER_NEXT_APPROVAL_CD;
						END
						ELSE --if bypass by fd different user
						BEGIN
							UPDATE TB_R_WORKFLOW
								SET
									APPROVED_BYPASS = @REG_NO,
									APPROVED_DT = GETDATE(),
									IS_REJECTED = 'Y',
									CHANGED_BY = @USER_NAME,
									CHANGED_DT = GETDATE()
								WHERE
									DOCUMENT_NO = @DOC_NO
									AND ITEM_NO = @ITEM_NO
									AND IS_APPROVED = 'N'
									AND IS_DISPLAY = 'Y'
									AND APPROVAL_CD = @USER_NEXT_APPROVAL_CD;
						END

						-- Update WORKFLOW for RIGHT BEFORE next approver.
						UPDATE TB_R_WORKFLOW
						SET
							APPROVED_DT = GETDATE(),
							APPROVED_BYPASS = NULL,
							IS_APPROVED = 'N',
							IS_REJECTED = 'N',
							CHANGED_BY = @USER_NAME,
							CHANGED_DT = GETDATE()
						WHERE
							DOCUMENT_NO = @DOC_NO
							AND ITEM_NO = @ITEM_NO
							AND IS_DISPLAY = 'Y'
							AND APPROVAL_CD = @DOC_APPROVAL_CD;
						
						SELECT TOP 1
							@DOC_NEXT_APPROVAL_CD = APPROVAL_CD
						FROM TB_R_WORKFLOW
						WHERE
							DOCUMENT_NO = @DOC_NO
							AND ITEM_NO = @ITEM_NO
							AND IS_APPROVED = 'Y'
							AND IS_DISPLAY = 'Y'
							--AND APPROVED_BYPASS IS NULL --Remark to make workflow position move only one bellow (20170829)
						ORDER BY DOCUMENT_SEQ DESC;

						--Update approval below current rejected document
						--Reset approval flag into N for the latest approved workflow	
						UPDATE TB_R_WORKFLOW
						SET
							IS_APPROVED = 'N'
						WHERE 
							DOCUMENT_NO = @DOC_NO
							AND ITEM_NO = @ITEM_NO
							AND IS_APPROVED = 'Y'
							AND CAST(APPROVAL_CD AS INT) > CAST(@DOC_NEXT_APPROVAL_CD AS INT)

						SELECT TOP 1
							@DOC_NEXT_APPROVAL_CD = APPROVAL_CD
						FROM TB_R_WORKFLOW
						WHERE
							DOCUMENT_NO = @DOC_NO
							AND ITEM_NO = @ITEM_NO
							AND IS_APPROVED = 'N'
							AND IS_DISPLAY = 'Y'
						ORDER BY DOCUMENT_SEQ ASC;

						-- Update DOCUMENT DETAIL
						-- Rejected Status for PR document in TB_M_STATUS is 99.
						UPDATE TB_R_PR_ITEM
						SET
							PR_STATUS = 99,
							PR_NEXT_STATUS = @DOC_NEXT_APPROVAL_CD,
							IS_REJECTED = 'Y',
							CHANGED_BY = @USER_NAME,
							CHANGED_DT = GETDATE()
						WHERE
							PR_NO = @DOC_NO
							AND PR_ITEM_NO = @ITEM_NO;


						-- Summary of DOCUMENT DETAIL
						SET @DOC_SUMMARY_APPROVAL_CD = 93;

						-- Update DOCUMENT HEADER
						-- Update document header occur after update document detail because
						-- document header update based on summary of document detail value.
						IF(NOT EXISTS(SELECT 1 FROM TB_R_PR_ITEM WHERE PR_NO = @DOC_NO AND PR_STATUS <> 99))
						BEGIN
							UPDATE TB_R_PR_H
							SET
								PR_STATUS = @DOC_SUMMARY_APPROVAL_CD,
								CHANGED_BY = @USER_NAME,
								CHANGED_DT = GETDATE()
							WHERE
								PR_NO = @DOC_NO;
						END

						-- Create announcement
						DECLARE @NEXT_APPROVER VARCHAR(8),
								@CURRENT_APPROVER VARCHAR(100)
						SELECT TOP 1 @NEXT_APPROVER = NOREG 
							FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @DOC_NO AND ITEM_NO = @ITEM_NO AND APPROVAL_CD = @DOC_NEXT_APPROVAL_CD
						SELECT TOP 1 @CURRENT_APPROVER = PERSONNEL_NAME
							FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = @REG_NO
						DECLARE @PIC VARCHAR(100) = @REG_NO + ';' + @NEXT_APPROVER
						DECLARE @MESSAGE_ANN VARCHAR(MAX) = 'PR No ' + @DOC_NO + ' has been rejected by ' + @CURRENT_APPROVER

						INSERT INTO [dbo].[TB_R_ANNOUNCEMENT]
									([PROCESS_ID]
									,[MSG_TYPE]
									,[TARGET_RECIPIENT]
									,[MSG_CONTENT]
									,[MSG_ATTACHMENT]
									,[CREATED_BY]
									,[CREATED_DT]
									,[CHANGED_BY]
									,[CHANGED_DT])
								VALUES
									(@PROCESS_ID
									,'INF'
									,@PIC
									,@MESSAGE_ANN
									,NULL
									,@USER_NAME
									,GETDATE()
									,NULL
									,NULL)

						--Note : Uncomment this if sp_send_email ready to execute
						--DECLARE @SUBJECT VARCHAR(100) = 'PR No ' + @DOC_NO + ' Item ' + @ITEM_NO + ' Rejection ' + CAST(GETDATE() AS VARCHAR)
						--DECLARE @BODY VARCHAR(MAX) = '<p>' + @MESSAGE_ANN + '</p>'
						--EXEC [dbo].[sp_announcement_sendmail]
	  			--				@PIC,
						--		@SUBJECT,
						--		@BODY,
						--		@MESSAGE OUTPUT
						--IF(@MESSAGE <> 'SUCCESS')
						--BEGIN
						--	RAISERROR(@MESSAGE, 16, 1)
						--END
						SELECT @ITEM_DESCRIPTION = MAT_DESC, @AMOUNT_APPROVAL = PRI.LOCAL_AMOUNT
						FROM TB_R_PR_ITEM PRI
						JOIN TB_R_PR_H PRH ON PRH.PR_NO = PRI.PR_NO
						WHERE PRI.PR_NO = @DOC_NO AND PRI.PR_ITEM_NO = @ITEM_NO

						SET @BODY = @BODY + '	<tr style = "border: 1px solid black;">';
						SET @BODY = @BODY + '		<th style = "border: 1px solid black;text-align: left;font-weight: normal;width: 100px;">' + @ITEM_NO + '</th>';
						SET @BODY = @BODY + '		<th style = "border: 1px solid black;text-align: left;font-weight: normal;">' + @ITEM_DESCRIPTION + '</th>';
						SET @BODY = @BODY + '		<th style = "border: 1px solid black;text-align: right;font-weight: normal;width: 200px;">' + convert(varchar, cast(@AMOUNT_APPROVAL as money), 1) + '</th>';
						SET @BODY = @BODY + '	</tr>';

						--//// FINISH APPROVE PROCESS.				
						SET @MESSAGE_ID = 'INF00009';
						SET @MESSAGE= 'Reject ' + @DOC_TYPE + ' Finished. Doc.No : '  + @DOC_NO;
						INSERT INTO @TB_TMP_LOG 
						SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '2', @USER_NAME
					
						SET @TOTAL_SUCCESS = @TOTAL_SUCCESS + 1;
					END
					ELSE
					BEGIN
						SET @MESSAGE = 'Cannot rejected item. Current user ' + @USER_NAME + ' was not next approver. Doc.No : '  + @DOC_NO;
						RAISERROR(@MESSAGE, 16, 1)
					END								
				END
				ELSE
				BEGIN
					-- Document approved is unavailable.
					SET @MESSAGE = 'Document still being used by other user';
					RAISERROR(@MESSAGE, 16, 1)
				END

				UPDATE TB_R_PR_H SET PROCESS_ID = NULL WHERE PR_NO = @DOC_NO;

				COMMIT;
			END TRY
			BEGIN CATCH      
				--Get the details of the error
				--that invoked the CATCH block
				SET @MESSAGE_ID = 'ERR00017';
				SET @MESSAGE = 'Reject PR ' + @DOC_NO + ' and Item No ' + @ITEM_NO + ' Failed. Message : ' + ERROR_MESSAGE() +  ' Line : ' + CONVERT(VARCHAR,ERROR_LINE())+ '.';
				ROLLBACK
				INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'ERR', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '3', @USER_NAME
                
				SET @TOTAL_FAIL = @TOTAL_FAIL + 1;
			END CATCH;    
        -- END PRAPPROVAL PROCESS

		SET @COUNTER = @COUNTER + 1
		SET @ITEM_NO = NULL
        SELECT @ITEM_NO = ITEM_NO FROM @TB_TMP_ITEM WHERE ROW_INDEX = @COUNTER AND NOREG = @REG_NO
    END

	--sEND MAIL
	IF((@COUNTER-1) > 0)
	BEGIN
		SET @MESSAGE_ID = 'INF00010';
		SET @MESSAGE = 'Send Mail Reject Item for Document Number ' + SUBSTRING(@DOC_ITEM_LIST, 1, charindex('|', @DOC_ITEM_LIST)-1) + ' Started ';
		INSERT INTO @TB_TMP_LOG 
		SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '1', @USER_NAME

		SELECT TOP 1 @NEXT_PERSONNEL_NAME = PERSONNEL_NAME
				FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = @NEXT_APPROVER AND GETDATE() BETWEEN VALID_FROM AND VALID_TO 
			ORDER BY POSITION_LEVEL DESC

		SET @BODY = @BODY + '</table></p>';
		SET @BODY = @BODY + '<p>Best Regards,</p>PAS Admin<br/>';

		DECLARE @BODYHEADER VARCHAR(MAX) = '<p>Dear '+@NEXT_PERSONNEL_NAME+', <br/><br/>You have '+CAST((@COUNTER-1) AS VARCHAR)+' document ' + (case when (@COUNTER-1)>1 THEN 'has' else 'have' end) +' been rejected by '+@CURRENT_APPROVER+'.'; 
		SET @BODY =  @BODYHEADER + @BODY;

		EXEC [dbo].[sp_announcement_sendmail]
	  				@PIC,
					@SUBJECT,
					@BODY,
					@MESSAGE OUTPUT

		IF(@MESSAGE = 'SUCCESS')
		BEGIN
			SET @MESSAGE_ID = 'INF00012';
			SET @MESSAGE = 'Send Mail Reject Item for Document Number ' + @DOC_NO + ' Ended Successfully';
			INSERT INTO @TB_TMP_LOG 
			SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '2', @USER_NAME
		END
		ELSE
		BEGIN
			SET @MESSAGE_ID = 'INF00011';
			SET @MESSAGE ='Mail Error Message :' + @MESSAGE ;
			INSERT INTO @TB_TMP_LOG 
			SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '1', @USER_NAME

			SET @MESSAGE_ID = 'INF00012';
			SET @MESSAGE ='Send Mail Reject Item for Document Number ' + @DOC_NO + ' Ended with Error';
			INSERT INTO @TB_TMP_LOG 
			SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '3', @USER_NAME
		END
	END


	IF(@STATUS = 'FAILED')
	BEGIN
		SET @MESSAGE_ID = 'INF00005';
		SET @MESSAGE = 'Reject Item for Document Number ' + @DOC_NO + ' Ended with Error';
		INSERT INTO @TB_TMP_LOG 
		SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '3', @USER_NAME
	END
	ELSE
	BEGIN
		IF(@TOTAL_FAIL = 0 AND (@COUNTER-1) > 0)
		BEGIN
			SET @MESSAGE_ID = 'INF00004';
			SET @MESSAGE = 'Reject Item for Document Number ' + @DOC_NO + ' Ended Successfully';
			INSERT INTO @TB_TMP_LOG 
			SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '2', @USER_NAME
		END
		ELSE
		BEGIN
			SET @MESSAGE_ID = 'INF00005';
			SET @MESSAGE = 'Reject Item for Document Number ' + @DOC_NO + ' Ended with Error';
			INSERT INTO @TB_TMP_LOG 
			SELECT @PROCESS_ID, GETDATE(), @MESSAGE_ID, 'INF', @MESSAGE, @MODULE_ID, @MODULE_DESC, @FUNCTION_ID, '3', @USER_NAME
		END
	END

	-- Release temporary log.
	EXEC SP_PUTLOG_TEMP @TB_TMP_LOG;
    
	SET @MESSAGE = CAST((@COUNTER-1) AS VARCHAR(5)) + '|' + CAST(@TOTAL_SUCCESS AS VARCHAR(5)) + '|' + CAST(@TOTAL_FAIL AS VARCHAR(5))
    
	IF(@REJECT_TYPE <> 'HEADER')
	BEGIN
		SELECT 'REJECT' AS 'ACTION', 1 AS 'DOC_COUNT', (@COUNTER-1) AS 'ITEM_COUNT', @TOTAL_SUCCESS AS 'SUCCESS', @TOTAL_FAIL AS 'FAIL';
	END
END
