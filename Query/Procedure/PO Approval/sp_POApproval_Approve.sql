USE [PAS_DB_QA]
GO
/****** Object:  StoredProcedure [dbo].[sp_POApproval_Approve]    Script Date: 11/21/2017 9:20:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_POApproval_Approve]
    @approvalMode VARCHAR(3),
    @poNoList VARCHAR(MAX),
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6),
    @currentRegNo VARCHAR(50),
    @currentUser VARCHAR(50),

    @docNo VARCHAR(15),
    @docDesc VARCHAR(100),
    @plant VARCHAR(4),
    @sLoc VARCHAR(4),
    @purchasingGroup VARCHAR(6),
    @vendor VARCHAR(6),
    @statusCd VARCHAR(2),
    @dateFrom DATETIME,
    @dateTo DATETIME,
    @currency VARCHAR(3),
    @userType VARCHAR(1),
    @orderBy VARCHAR(50),
    @currentPage INT,
    @pageSize INT
AS
BEGIN
	--SET @docNo = ''
	IF(ISNULL(@docNo,'')<>'') SET @currentPage = 1 --Handiling jika Approve PO detail [Approve PO detail docNo selalu ke-isi] dan Po ada di posisi page bukan 1
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --//// Procedure Variables.
    DECLARE
        @poNo AS VARCHAR(11),
        @ITEM_NO AS VARCHAR(50),
        @ITEM_LIST AS VARCHAR(MAX),

        @DOC_NEXT_APPROVAL_CD AS VARCHAR(50),
        @DOC_LAST_APPROVAL_CD AS VARCHAR(50),
        @DOC_SUMMARY_APPROVAL_CD AS VARCHAR(50),
        @USER_NEXT_APPROVAL_CD AS VARCHAR(50),
        
                                @oriNoreg AS VARCHAR(8) = @currentRegNo,

        @successCount AS INT = 0,
        @failedCount AS INT = 0;

    -- Temporary log variables
    DECLARE 
        @tmpLog LOG_TEMP,
        @processId BIGINT,
        @message VARCHAR(MAX) = '',
        @actionName VARCHAR(50) = 'Approve POApproval'

    EXEC dbo.sp_PutLog 'I|Start', @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0

    SET @message = 'I|Get Last Process ID. Process.ID : ' + CAST(@processId AS VARCHAR)
    INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
                
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
                
    --//// TODO : Parsing @DOC_ITEM_LIST parameter to get group of document and item.
    --//// Input format : DOC_NO|DOC_TYPE|MODE|;DOC_NO|DOC_TYPE|MODE|;...
    DECLARE @poNoList_ROW_INDEX AS INT, @poNoList_ROW_COUNT AS INT;
    DECLARE @TB_TMP_DOC_LIST AS TABLE
    (
        ROW_INDEX BIGINT IDENTITY(1, 1),
        DOC_NO VARCHAR(11),
        DOC_TYPE VARCHAR(2)
    );

    DECLARE @currentApproverPosition VARCHAR(5),
			@CurrenctOrgId INT,
			@currentLevelApproverPosition VARCHAR(5),
			@currentDivisionId VARCHAR(10)

    SELECT TOP 1 @currentApproverPosition = POSITION_LEVEL, @CurrenctOrgId = ORG_ID, @currentDivisionId = DIVISION_ID
    FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = @currentRegNo ORDER BY POSITION_LEVEL ASC

    SET @currentLevelApproverPosition = (SELECT LEVEL_ID FROM TB_M_ORG_POSITION WHERE POSITION_LEVEL = @currentApproverPosition)
                
    --IF (@userType = 'A')
    --BEGIN
                    INSERT INTO @HR_GRANTOR
                    SELECT DISTINCT 'GPS', 'GPS' + CAST(DENSE_RANK() OVER (ORDER BY WF.NOREG) AS VARCHAR), WF.NOREG, @oriNoreg, GETDATE(), GETDATE(), 'AUTO', GETDATE(), 'GPS', NULL, NULL
                    FROM TB_R_WORKFLOW WF 
                    INNER JOIN TB_M_ORG_POSITION OP ON OP.POSITION_LEVEL = WF.APPROVER_POSITION AND OP.LEVEL_ID = @currentLevelApproverPosition 
                    INNER JOIN TB_R_SYNCH_EMPLOYEE S ON S.NOREG = WF.NOREG AND S.ORG_ID = WF.STRUCTURE_ID AND GETDATE() BETWEEN S.VALID_FROM AND S.VALID_TO
                                    WHERE (
                                            @approvalMode = 'INC' 
                                            AND WF.DOCUMENT_NO IN (
                                                            SELECT Split 
                                                            FROM dbo.SplitString(@poNoList, ',') SS
                                                            WHERE ISNULL(SS.Split, '') <> ''
                                            )
                                            OR (
                                            @approvalMode = 'EXC' 
                                            AND WF.DOCUMENT_NO NOT IN (
                                                            SELECT Split 
                                                            FROM dbo.SplitString(@poNoList, ',') SS
                                                            WHERE ISNULL(SS.Split, '') <> ''
                                                            )
                                            )
                            ) AND WF.STRUCTURE_ID = @CurrenctOrgId
    --END

    INSERT INTO @TB_TMP_DOC_LIST
    SELECT dt.PO_NO, 'PO' FROM 
                (SELECT DISTINCT
                        CASE @orderBy WHEN 'ATTACHMENT|ASC' THEN DENSE_RANK() OVER (ORDER BY (CASE WHEN EXISTS(SELECT 1 FROM TB_R_ATTACHMENT WHERE DOC_NO = poh.PO_NO) THEN 1 ELSE 0 END) ASC, poh.DOC_DT DESC, poh.CHANGED_DT DESC, poh.PO_NO ASC)
                                        WHEN 'ATTACHMENT|DESC' THEN DENSE_RANK() OVER (ORDER BY (CASE WHEN EXISTS(SELECT 1 FROM TB_R_ATTACHMENT WHERE DOC_NO = poh.PO_NO) THEN 1 ELSE 0 END) DESC, poh.DOC_DT DESC, poh.CHANGED_DT DESC, poh.PO_NO ASC)
                                        WHEN 'URGENT|ASC' THEN DENSE_RANK() OVER (ORDER BY poh.URGENT_DOC ASC, poh.DOC_DT DESC, poh.CHANGED_DT DESC, poh.PO_NO ASC)
                                        WHEN 'URGENT|DESC' THEN DENSE_RANK() OVER (ORDER BY poh.URGENT_DOC DESC, poh.DOC_DT DESC, poh.CHANGED_DT DESC, poh.PO_NO ASC)
                                        WHEN 'PO|ASC' THEN DENSE_RANK() OVER (ORDER BY poh.PO_NO ASC, poh.DOC_DT DESC, poh.CHANGED_DT DESC)
                                        WHEN 'PO|DESC' THEN DENSE_RANK() OVER (ORDER BY poh.PO_NO DESC, poh.DOC_DT DESC, poh.CHANGED_DT DESC)
                                        WHEN 'DESC|ASC' THEN DENSE_RANK() OVER (ORDER BY poh.PO_DESC ASC, poh.DOC_DT DESC, poh.CHANGED_DT DESC)
                                        WHEN 'DESC|DESC' THEN DENSE_RANK() OVER (ORDER BY poh.PO_DESC DESC, poh.DOC_DT DESC, poh.CHANGED_DT DESC)
                                        WHEN 'DATE|ASC' THEN DENSE_RANK() OVER (ORDER BY poh.DOC_DT ASC, poh.CHANGED_DT DESC, poh.PO_NO ASC)
                                        WHEN 'DATE|DESC' THEN DENSE_RANK() OVER (ORDER BY poh.DOC_DT DESC, poh.CHANGED_DT DESC, poh.PO_NO ASC)
                                        WHEN 'VENDOR|ASC' THEN DENSE_RANK() OVER (ORDER BY poh.VENDOR_CD ASC, poh.DOC_DT DESC, poh.CHANGED_DT DESC, poh.PO_NO ASC)
                                        WHEN 'VENDOR|DESC' THEN DENSE_RANK() OVER (ORDER BY poh.VENDOR_CD DESC, poh.DOC_DT DESC, poh.CHANGED_DT DESC, poh.PO_NO ASC)
                                        WHEN 'CURR|ASC' THEN DENSE_RANK() OVER (ORDER BY poh.PO_CURR ASC, poh.DOC_DT DESC, poh.CHANGED_DT DESC, poh.PO_NO ASC)
                                        WHEN 'CURR|DESC' THEN DENSE_RANK() OVER (ORDER BY poh.PO_CURR DESC, poh.DOC_DT DESC, poh.CHANGED_DT DESC, poh.PO_NO ASC)
                                        WHEN 'AMOUNT|ASC' THEN DENSE_RANK() OVER (ORDER BY poh.PO_AMOUNT ASC, poh.DOC_DT DESC, poh.CHANGED_DT DESC, poh.PO_NO ASC)
                                        WHEN 'AMOUNT|DESC' THEN DENSE_RANK() OVER (ORDER BY poh.PO_AMOUNT DESC, poh.DOC_DT DESC, poh.CHANGED_DT DESC, poh.PO_NO ASC)
                                        WHEN 'STATUS|ASC' THEN DENSE_RANK() OVER (ORDER BY poh.PO_STATUS ASC, poh.DOC_DT DESC, poh.CHANGED_DT DESC, poh.PO_NO ASC)
                                        WHEN 'STATUS|DESC' THEN DENSE_RANK() OVER (ORDER BY poh.PO_STATUS DESC, poh.DOC_DT DESC, poh.CHANGED_DT DESC, poh.PO_NO ASC)
                                        WHEN 'PURCH|ASC' THEN DENSE_RANK() OVER (ORDER BY poh.PURCHASING_GRP_CD ASC, poh.DOC_DT DESC, poh.CHANGED_DT DESC, poh.PO_NO ASC)
                                        WHEN 'PURCH|DESC' THEN DENSE_RANK() OVER (ORDER BY poh.PURCHASING_GRP_CD DESC, poh.DOC_DT DESC, poh.CHANGED_DT DESC, poh.PO_NO ASC)
                                        ELSE DENSE_RANK() OVER (ORDER BY poh.DOC_DT DESC, poh.CHANGED_DT DESC, poh.PO_NO ASC)
                        END AS DataNo,
                        poh.PO_NO
                                FROM TB_R_WORKFLOW wf
                                JOIN TB_R_PO_H poh ON wf.DOCUMENT_NO = poh.PO_NO
                                JOIN TB_M_ORG_POSITION op ON op.POSITION_LEVEL = wf.APPROVER_POSITION
                                AND wf.IS_APPROVED = 'N'
                                AND wf.IS_DISPLAY = 'Y'
                                AND wf.INTERVAL_DATE IS NOT NULL
                                AND CASE
                                    WHEN @userType = 'C' -- Current user
                                                    AND (((wf.APPROVED_BY = @currentRegNo OR wf.APPROVED_BY IN (SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)) AND poh.PO_NEXT_STATUS = wf.APPROVAL_CD)
                                                                    --wf.APPROVER_POSITION = @currentApproverPosition
                                                    --OR (dbo.fn_dateadd_workday(wf.APPROVAL_INTERVAL, wf.INTERVAL_DATE) < GETDATE()
                                                    --                AND wf.APPROVER_POSITION = @currentApproverPosition
                                                    --                AND EXISTS (SELECT 1 FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = wf.DOCUMENT_NO AND (APPROVED_BY = @currentRegNo OR APPROVED_BY IN (SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)) 
                                                    --                                                                                                AND IS_DISPLAY = 'Y' AND IS_APPROVED = 'N'))
													)
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
                                AND ISNULL(poh.PO_STATUS, '') LIKE '%' + ISNULL(@statusCd, '') + '%'
                                AND (ISNULL(poh.CREATED_DT, CAST('1753-1-1' AS DATETIME))
                                                BETWEEN ISNULL(@dateFrom, CAST('1753-1-1' AS DATETIME)) AND DATEADD(MILLISECOND, 86399998, ISNULL(@dateTo, CAST('9999-12-31' AS DATETIME))))
                ) dt WHERE dt.DataNo >= (((@currentPage-1) * @pageSize) + 1) AND dt.DataNo <= (@currentPage * @pageSize)-- ORDER BY dt.DataNo ASC
                                AND (
										@approvalMode = 'INC' 
										AND dt.PO_NO IN (
														SELECT Split 
														FROM dbo.SplitString(@poNoList, ',') SS
														WHERE ISNULL(SS.Split, '') <> ''
										)
										OR (
										@approvalMode = 'EXC' 
										AND dt.PO_NO NOT IN (
														SELECT Split 
														FROM dbo.SplitString(@poNoList, ',') SS
														WHERE ISNULL(SS.Split, '') <> ''
														)
										)
									)

    DECLARE @poNoListIdx INT = 1, @poNoListCount INT = (SELECT COUNT(ROW_INDEX) FROM @TB_TMP_DOC_LIST)
    WHILE @poNoListIdx <= @poNoListCount
    BEGIN
        BEGIN TRAN ApprovePO
        BEGIN TRY
            SELECT @poNo = DOC_NO FROM @TB_TMP_DOC_LIST WHERE ROW_INDEX = @poNoListIdx

            --//// PRAPPROVAL PROCESS
            -- Check if document approved is available.
            SET @message = 'I|Check Document Availability. Doc.No : '  + @poNo
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            DECLARE @isDocLocked BIT = (SELECT CASE WHEN ISNULL(PROCESS_ID, 0) <> 0 AND PROCESS_ID <> @processId THEN 1 ELSE 0 END FROM TB_R_PO_H WHERE PO_NO = @poNo)
            IF @isDocLocked = 0
            BEGIN
                                                                UPDATE TB_R_PO_H SET PROCESS_ID = @processId WHERE PO_NO = @poNo

                --//// START APPROVE PROCESS.
                SET @message = 'I|Approve PO Started. Doc.No : '  + @poNo
                INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

                -- Lock document.
                SET @message = 'I|Lock Document. Doc.No : '  + @poNo
                INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

                --UPDATE TB_R_PO_H SET PROCESS_ID = @processId WHERE PO_NO = @poNo

                -- Get document items.
                SET @message = 'I|Get Document Items. Doc.No : '  + @poNo
                INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

                --//// Logic Get Document Next Approval Code.
                SELECT TOP 1
                    @DOC_NEXT_APPROVAL_CD = APPROVAL_CD
                FROM TB_R_WORKFLOW
                WHERE
                    DOCUMENT_NO = @poNo
                    AND IS_APPROVED = 'N'
                    AND IS_DISPLAY = 'Y'
                ORDER BY DOCUMENT_SEQ ASC

                --//// Logic Get User Next Approval Code.
                DECLARE @IS_ATTORNEY CHAR(1) = 'N'
                IF(EXISTS (SELECT 1 FROM TB_R_WORKFLOW --Check if noreg exist in workflow 
                                WHERE
                                                DOCUMENT_NO = @poNo
                                                AND APPROVED_BY = @currentRegNo
                                                AND IS_APPROVED = 'N'
                                                AND IS_DISPLAY = 'Y'))
                BEGIN
                                SELECT TOP 1
                                                @USER_NEXT_APPROVAL_CD = APPROVAL_CD
                                FROM TB_R_WORKFLOW
                                WHERE
                                                DOCUMENT_NO = @poNo
                                                AND APPROVED_BY = @currentRegNo
                                                AND IS_APPROVED = 'N'
                                                AND IS_DISPLAY = 'Y'
                                ORDER BY DOCUMENT_SEQ DESC
                END
                ELSE
                BEGIN
                                SELECT TOP 1
                                                @USER_NEXT_APPROVAL_CD = APPROVAL_CD
                                FROM TB_R_WORKFLOW
                                WHERE
                                                DOCUMENT_NO = @poNo
                                                AND IS_APPROVED = 'N'
                                                AND IS_DISPLAY = 'Y'
                                ORDER BY DOCUMENT_SEQ DESC;

                                SET @IS_ATTORNEY = 'Y'
                END

                --//// Logic Get Document Last Approval Code (Document Release).
                SELECT TOP 1 
                    @DOC_LAST_APPROVAL_CD = APPROVAL_CD
                FROM TB_R_WORKFLOW
                WHERE
                    DOCUMENT_NO = @poNo
                    AND IS_APPROVED = 'N'
                    AND IS_DISPLAY = 'Y'
                ORDER BY DOCUMENT_SEQ DESC

                --//// Approve only valid if user is next approver
                --//// or user is one segment with next approver.
                IF 
                    @DOC_NEXT_APPROVAL_CD = @USER_NEXT_APPROVAL_CD
                    OR SUBSTRING(@DOC_NEXT_APPROVAL_CD, 1, 1) = SUBSTRING(@USER_NEXT_APPROVAL_CD, 1, 1)
                BEGIN
                    --//// Update WORKFLOW
                    IF(@IS_ATTORNEY = 'N')
                    BEGIN
                        UPDATE TB_R_WORKFLOW
                        SET
                            APPROVED_DT = GETDATE(),
                            IS_APPROVED = 'Y',
                            IS_REJECTED = 'N',
                            CHANGED_BY = @currentUser,
                            CHANGED_DT = GETDATE()
                        WHERE
                            DOCUMENT_NO = @poNo
                            AND APPROVED_BY = @currentRegNo
                            AND IS_APPROVED = 'N'
                            AND IS_DISPLAY = 'Y'
                            AND APPROVAL_CD = @USER_NEXT_APPROVAL_CD
                    END
                    ELSE
                    BEGIN
                        UPDATE TB_R_WORKFLOW
                        SET
                            APPROVED_BYPASS = @currentRegNo,
                            APPROVED_DT = GETDATE(),
                            IS_APPROVED = 'Y',
                            IS_REJECTED = 'N',
                            CHANGED_BY = @currentUser,
                            CHANGED_DT = GETDATE()
                        WHERE
                            DOCUMENT_NO = @poNo
                            AND IS_APPROVED = 'N'
                            AND IS_DISPLAY = 'Y'
                            AND APPROVAL_CD = @USER_NEXT_APPROVAL_CD
                            AND ISNULL(APPROVED_BYPASS, '') <> @currentRegNo
                    END

                    --//// Update WORKFLOW with BYPASS process.
                    IF SUBSTRING(@DOC_NEXT_APPROVAL_CD, 1, 1) = SUBSTRING(@USER_NEXT_APPROVAL_CD, 1, 1)
                    BEGIN
                        UPDATE TB_R_WORKFLOW
                        SET
                            APPROVED_BYPASS = @currentRegNo,
                            APPROVED_DT = GETDATE(),
                            IS_APPROVED = 'Y',
                            CHANGED_BY = @currentUser,
                            CHANGED_DT = GETDATE()
                        WHERE
                            DOCUMENT_NO = @poNo
                            AND IS_APPROVED = 'N'
                            AND IS_DISPLAY = 'Y'
                            AND APPROVAL_CD <= @USER_NEXT_APPROVAL_CD
                            AND ISNULL(APPROVED_BYPASS, '') <> @currentRegNo
                    END
    
                    SELECT TOP 1
                        @DOC_NEXT_APPROVAL_CD = APPROVAL_CD
                    FROM TB_R_WORKFLOW
                    WHERE
                        DOCUMENT_NO = @poNo
                        AND IS_APPROVED = 'N'
                        AND IS_DISPLAY = 'Y'
                    ORDER BY DOCUMENT_SEQ ASC

                    --Added by FID) Intan Puspitasari - 28012016
                    --Note: Add Checking if Next status is = last approval status then Released
                    UPDATE TB_R_PO_H
                    SET
                        PO_STATUS = (
                            CASE 
                                WHEN ((@USER_NEXT_APPROVAL_CD = @DOC_LAST_APPROVAL_CD) AND SYSTEM_SOURCE <>'SAP') THEN
                                    '43'
                                WHEN ((@USER_NEXT_APPROVAL_CD = @DOC_LAST_APPROVAL_CD) AND SYSTEM_SOURCE = 'SAP') THEN
                                    '44'    
                                ELSE
                                    @USER_NEXT_APPROVAL_CD
                            END
                        ),
                                                                                                PO_NEXT_STATUS = (
                            CASE 
                                WHEN ((@USER_NEXT_APPROVAL_CD = @DOC_LAST_APPROVAL_CD) AND SYSTEM_SOURCE <> 'SAP') THEN
                                    '43'
                                WHEN ((@USER_NEXT_APPROVAL_CD = @DOC_LAST_APPROVAL_CD) AND SYSTEM_SOURCE = 'SAP') THEN
                                    '44'
                                ELSE
                                    @DOC_NEXT_APPROVAL_CD
                            END
                        ),
                        RELEASED_FLAG =
                        (
                            CASE 
                                WHEN @USER_NEXT_APPROVAL_CD = @DOC_LAST_APPROVAL_CD THEN
                                    'Y'
                                ELSE
                                    'N'
                            END
                        ),
                        RELEASED_DT =
                        (
                            CASE 
                                WHEN @USER_NEXT_APPROVAL_CD = @DOC_LAST_APPROVAL_CD THEN
                                    GETDATE()
                                ELSE
                                    NULL
                            END
                        ),
                        CHANGED_BY = @currentUser,
                        CHANGED_DT = GETDATE()
                    WHERE PO_NO = @poNo
                    
                    EXEC sp_BackwardChecking_ApprovePRApproval @poNo, 'PO', @ITEM_NO

                    --//// SEND EMAIL TO VENDOR
                    DECLARE @SEND_MAIL CHAR(1) = 'N',
                                                    @MAIL_CC VARCHAR(MAX) = ''
                    SELECT @SEND_MAIL = CASE WHEN((SYSTEM_SOURCE = 'SAP' AND PO_STATUS = '44')) THEN 'Y' ELSE 'N' END 
                                    FROM TB_R_PO_H WHERE PO_NO = @poNo
                    IF(@SEND_MAIL = 'Y')
                    BEGIN
                        DECLARE @MAIL_VENDOR VARCHAR(MAX) = '', @VENDOR_NAME VARCHAR(MAX) = '', @PO_DESC VARCHAR (100) = '', @PO_AMOUNT VARCHAR (100) = ''
                        SELECT @MAIL_VENDOR = ISNULL(EMAIL_ADDR, ''), @VENDOR_NAME = ISNULL(MV.VENDOR_NAME, '') FROM TB_M_VENDOR MV JOIN TB_R_PO_H POH ON POH.VENDOR_CD = MV.VENDOR_CD AND POH.PO_NO = @poNo
                                                                                                
                        SELECT DISTINCT @MAIL_CC = @MAIL_CC + CASE WHEN @MAIL_CC = '' THEN '' ELSE ';' END + SE.MAIL
                        FROM TB_R_PO_H POH
                                        INNER JOIN TB_R_WORKFLOW WF ON WF.DOCUMENT_NO = POH.PO_NO AND WF.DOCUMENT_SEQ <= 2
                                        INNER JOIN TB_R_SYNCH_EMPLOYEE SE ON SE.NOREG = WF.APPROVED_BY
                        WHERE POH.PO_NO = @poNo
                                                                                                
                        SET @MAIL_CC = (SELECT CASE WHEN @MAIL_CC = '' THEN OTHER_MAIL ELSE @MAIL_CC + ';' + OTHER_MAIL END FROM TB_R_PO_H WHERE PO_NO = @poNo)
						SET @PO_DESC = (SELECT PO_DESC FROM TB_R_PO_H WHERE PO_NO = @poNo)
						SET @PO_AMOUNT = (SELECT PO_AMOUNT FROM TB_R_PO_H WHERE PO_NO = @poNo)

						--Added By Fid.Reggy CC PO Creator
						DECLARE @CREATOR_NOREG VARCHAR(50)
						DECLARE @CREATOR_EMAIL VARCHAR(300)

						SELECT TOP 1 @CREATOR_NOREG = APPROVED_BY
						FROM TB_R_WORKFLOW
						WHERE DOCUMENT_NO = @poNo AND DOCUMENT_SEQ = 1
						
						SELECT TOP 1 @CREATOR_EMAIL = MAIL
						FROM TB_R_SYNCH_EMPLOYEE 
						WHERE NOREG = @CREATOR_NOREG AND GETDATE() BETWEEN VALID_FROM AND VALID_TO 
						ORDER BY POSITION_LEVEL DESC

						SET @MAIL_CC = @MAIL_CC + ';' + @CREATOR_EMAIL

                        IF(@MAIL_VENDOR <> '')
                        BEGIN
                                        DECLARE @STATUS VARCHAR(MAX) = ''
                                        DECLARE @PARAM VARCHAR(MAX) = @VENDOR_NAME + '|' + @poNo + '|' + @PO_DESC + '|' + CONVERT(VARCHAR(MAX), CAST(@PO_AMOUNT AS money), -1) + '|' + CAST(FORMAT(GETDATE(), 'dd/MM/yyyy', 'en-US' ) AS VARCHAR)
                                        EXEC [dbo].[sp_common_sendmail]
                                                        @MAIL_VENDOR,
                                                        @MAIL_CC,
                                                        @functionId,
                                                        '01',
                                                        @PARAM,
                                                        @STATUS OUTPUT

                                        IF(@STATUS <> 'SUCCESS') BEGIN RAISERROR(@STATUS, 16, 1) END
                        END
                    END

					--//// Add By Fid.Reggy Send Email PO Approval
					DECLARE
						@APPROVAL_STATUS_DESC VARCHAR(100) = '', 
						@LAST_STATUS VARCHAR(2) = '',
						@NOREG VARCHAR(50) = '',
						@NAME VARCHAR(100) = '',
						@LINK_PO VARCHAR(MAX) = '',
						@i_numItem AS int = 0,
						@MAIL_AMOUNT_APPROVAL AS MONEY,
						@MAIL_ITEM_DESCRIPTION AS VARCHAR(MAX) = '',
						@SUBJECT VARCHAR(100) = '',
						@BODY VARCHAR(MAX) = '',
						@CREATOR_BODY VARCHAR(MAX) = '',
						@APPROVER_BODY VARCHAR(MAX) = '',
						@BODY_HEADER VARCHAR(MAX) = '',
						@BODY_FOOTER VARCHAR(MAX) = '',
						@APPROVAL_POSITION VARCHAR(5)= '0'
						
					SELECT 
						@LAST_STATUS = CASE WHEN PO_STATUS <> PO_NEXT_STATUS THEN PO_STATUS ELSE NULL END 
					FROM TB_R_PO_H 
					WHERE PO_NO = @poNo
					
					--//If not Last Status then Send Email to Next Approver
					IF(@LAST_STATUS NOT IN ('43', '44') AND ISNULL(@LAST_STATUS, '') <> '')
					BEGIN
						SELECT 
							@MAIL_ITEM_DESCRIPTION = PO_DESC, 
							@MAIL_AMOUNT_APPROVAL = CAST(PO_AMOUNT * PO_EXCHANGE_RATE AS MONEY) 
						FROM TB_R_PO_H
						WHERE PO_NO = @poNo

						SET @BODY = @BODY + '<br/>PO Desc. : ' + ISNULL(@MAIL_ITEM_DESCRIPTION, '') + '';
						SET @BODY = @BODY + '<br/>PO Amount : ' + ISNULL(CONVERT(VARCHAR(MAX), @MAIL_AMOUNT_APPROVAL, -1), '') + '';

						--Approval Email
						SELECT TOP 1 @NOREG = APPROVED_BY, @APPROVAL_POSITION = APPROVER_POSITION
						FROM TB_R_WORKFLOW
						WHERE DOCUMENT_NO = @poNo AND IS_APPROVED = 'N' AND IS_DISPLAY = 'Y'
						ORDER BY DOCUMENT_SEQ ASC

						IF(ISNULL(@NOREG,'')<>'')
						BEGIN
							DECLARE @LEVEL_ID VARCHAR(5)
							select TOP 1 @LEVEL_ID = LEVEL_ID from 
							TB_M_ORG_POSITION where POSITION_LEVEL = @APPROVAL_POSITION

							SELECT @LINK_PO = SYSTEM_VALUE   
							FROM TB_M_SYSTEM 
							WHERE FUNCTION_ID = 'MAIL' AND SYSTEM_CD = 'LINK_POAPPROVAL' 

							SELECT @SUBJECT = SYSTEM_VALUE   
							FROM TB_M_SYSTEM 
							WHERE FUNCTION_ID = 'POMAIL' AND SYSTEM_CD = 'APR_SUB' 

							SELECT @BODY_HEADER = SYSTEM_VALUE   
							FROM TB_M_SYSTEM 
							WHERE FUNCTION_ID = 'POMAIL' AND SYSTEM_CD = 'APR_HEAD' 

							SELECT @BODY_FOOTER = SYSTEM_VALUE   
							FROM TB_M_SYSTEM 
							WHERE FUNCTION_ID = 'POMAIL' AND SYSTEM_CD = 'APR_FOOT'

							IF EXISTS(SELECT 1 FROM TB_M_SYSTEM m_sys WHERE m_sys.FUNCTION_ID = 'XPOLV2' AND SYSTEM_VALUE = @LEVEL_ID)
							BEGIN
								DECLARE @APPROVAL_DH AS TABLE (NO_ID INT IDENTITY(1,1), NOREG VARCHAR(10), PERSONAL_NAME VARCHAR(100))

								INSERT INTO @APPROVAL_DH (NOREG, PERSONAL_NAME)
								SELECT NOREG, PERSONNEL_NAME FROM TB_R_SYNCH_EMPLOYEE A
									WHERE NOREG = @NOREG  AND GETDATE() BETWEEN VALID_FROM AND VALID_TO 
								UNION 
								select NOREG, PERSONNEL_NAME FROM TB_R_SYNCH_EMPLOYEE A
								JOIN TB_M_ORG_POSITION B ON B.POSITION_LEVEL = A.POSITION_LEVEL 
									AND LEVEL_ID = @LEVEL_ID AND DIVISION_ID = @currentDivisionId
									AND GETDATE() BETWEEN VALID_FROM AND VALID_TO
									AND B.POSITION_LEVEL IN (SELECT SYSTEM_CD FROM TB_M_SYSTEM m_sys WHERE m_sys.FUNCTION_ID = 'XPOLV2')
								
								DECLARE @IdxItem INT = 1, @listCount INT = (SELECT COUNT(NO_ID) FROM @APPROVAL_DH)
								WHILE @IdxItem <= @listCount
								BEGIN
									SELECT @NOREG = NOREG, @NAME = PERSONAL_NAME  FROM @APPROVAL_DH WHERE NO_ID = @IdxItem
				
									SET @APPROVER_BODY = REPLACE(ISNULL(@BODY_HEADER, ''), '[NAME]', @NAME) + 
													 '<br/>PO Number : <a href="' + ISNULL(@LINK_PO, '#') + '">' + ISNULL(@poNo, '') + '</a>' +
													 ISNULL(@BODY, '') + 
													 REPLACE(ISNULL(@BODY_FOOTER, ''), '[APR_LINK]', @LINK_PO)

									EXEC [dbo].[sp_announcement_sendmail]
										@NOREG,
										@SUBJECT,
										@APPROVER_BODY,
										@message OUTPUT
						
									IF(@message <> 'SUCCESS')
									BEGIN
										RAISERROR(@message, 16, 1)
									END

									SET @IdxItem = @IdxItem + 1
								END

							END
							ELSE
							BEGIN
								SELECT TOP 1 @NAME = PERSONNEL_NAME
								FROM TB_R_SYNCH_EMPLOYEE 
								WHERE NOREG = @NOREG AND GETDATE() BETWEEN VALID_FROM AND VALID_TO 
								ORDER BY POSITION_LEVEL DESC

								SET @APPROVER_BODY = REPLACE(ISNULL(@BODY_HEADER, ''), '[NAME]', @NAME) + 
													 '<br/>PO Number : <a href="' + ISNULL(@LINK_PO, '#') + '">' + ISNULL(@poNo, '') + '</a>' +
													 ISNULL(@BODY, '') + 
													 REPLACE(ISNULL(@BODY_FOOTER, ''), '[APR_LINK]', @LINK_PO)

								EXEC [dbo].[sp_announcement_sendmail]
									@NOREG,
									@SUBJECT,
									@APPROVER_BODY,
									@message OUTPUT
						
								IF(@message <> 'SUCCESS')
								BEGIN
									RAISERROR(@message, 16, 1)
								END
							END
						END

						--Creator Email
						SELECT TOP 1 @APPROVAL_STATUS_DESC = APPROVAL_DESC
						FROM TB_R_WORKFLOW
						WHERE DOCUMENT_NO = @poNo AND IS_APPROVED = 'Y' AND IS_DISPLAY = 'Y'
						ORDER BY DOCUMENT_SEQ DESC

						SELECT TOP 1 @NOREG = APPROVED_BY
						FROM TB_R_WORKFLOW
						WHERE DOCUMENT_NO = @poNo AND DOCUMENT_SEQ = 1
						
						IF (@NOREG <>'00000000') --Ecatalogue Dummy User 00000000
						BEGIN
							SELECT TOP 1 @NAME = PERSONNEL_NAME
							FROM TB_R_SYNCH_EMPLOYEE 
							WHERE NOREG = @NOREG AND GETDATE() BETWEEN VALID_FROM AND VALID_TO 
							ORDER BY POSITION_LEVEL DESC
						
							SELECT @LINK_PO = SYSTEM_VALUE   
							FROM TB_M_SYSTEM 
							WHERE FUNCTION_ID = 'MAIL' AND SYSTEM_CD = 'LINK_POINQUIRY' 

							SELECT @SUBJECT = SYSTEM_VALUE   
							FROM TB_M_SYSTEM 
							WHERE FUNCTION_ID = 'POMAIL' AND SYSTEM_CD = 'CRE_SUB' 

							SELECT @BODY_HEADER = SYSTEM_VALUE   
							FROM TB_M_SYSTEM 
							WHERE FUNCTION_ID = 'POMAIL' AND SYSTEM_CD = 'CRE_HEAD' 

							SELECT @BODY_FOOTER = SYSTEM_VALUE   
							FROM TB_M_SYSTEM 
							WHERE FUNCTION_ID = 'POMAIL' AND SYSTEM_CD = 'CRE_FOOT'

							SET @CREATOR_BODY = REPLACE(REPLACE(ISNULL(@BODY_HEADER, ''), '[NAME]', @NAME), '[STATUS]', REPLACE(ISNULL(@APPROVAL_STATUS_DESC, ''), 'PO ', '')) + 
												'<br/>PO Number : <a href="' + ISNULL(@LINK_PO, '#') + '">' + ISNULL(@poNo, '') + '</a>' +
												ISNULL(@BODY, '') + 
												REPLACE(ISNULL(@BODY_FOOTER, ''), '[CRE_LINK]', @LINK_PO)
						
							EXEC [dbo].[sp_announcement_sendmail]
								@NOREG,
								@SUBJECT,
								@CREATOR_BODY,
								@message OUTPUT
						
							IF(@message <> 'SUCCESS')
							BEGIN
								RAISERROR(@message, 16, 1)
							END
						END --Ecatalogue Dummy User 00000000

					END

                    --//// FINISH APPROVE PROCESS.
                    SET @message = 'I|Approve PO Finished. Doc.No : '  + @poNo
                    INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 2, @currentUser)

                    SET @successCount = @successCount + 1
                END
                ELSE
                BEGIN
                    SET @message = 'W|Current user ' + @currentUser + ' was neither next approver nor same segment with next approver. Doc.No : '  + @poNo
                    INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
                    
                    SET @failedCount = @failedCount + 1
                END
            END
            ELSE
            BEGIN
                DECLARE @proc_id BIGINT
                SELECT @proc_id = PROCESS_ID FROM TB_R_PO_H WHERE PO_NO = @poNo

                -- Document approved is unavailable.
                SET @message = 'W|Approve PO Finished with Error. Document being used with process id ' + CAST(@proc_id AS VARCHAR) + '. Doc.No : '  + @poNo
                INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'WRN', 'WRN', @message, @moduleId, @actionName, @functionId, 3, @currentUser)

                SET @failedCount = @failedCount + 1
            END

            UPDATE TB_R_PO_H SET PROCESS_ID = NULL WHERE PO_NO = @poNo AND PROCESS_ID = @processId

            COMMIT TRAN ApprovePO
        END TRY
        BEGIN CATCH                
            ROLLBACK TRAN ApprovePO

            --Get the details of the error
            --that invoked the CATCH block
            SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)

            SET @failedCount = @failedCount + 1
        END CATCH

        SET @poNoListIdx = @poNoListIdx + 1
    END

    EXEC SP_PUTLOG_TEMP @tmpLog

    SELECT 'Approve' [ExecAction], @poNoListCount DocCount, @successCount Success, @failedCount Fail, @processId ProcessId, @message [Message]
END