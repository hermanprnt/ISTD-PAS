USE [PAS_DB_QA]
GO
/****** Object:  StoredProcedure [dbo].[sp_POApproval_Reject]    Script Date: 10/19/2017 3:26:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_POApproval_Reject]
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
        @poNo VARCHAR(11),
        @ITEM_NO AS VARCHAR(50),
        @ITEM_LIST AS VARCHAR(MAX),

        @DOC_APPROVAL_CD AS VARCHAR(50),
        @DOC_NEXT_APPROVAL_CD AS VARCHAR(50),
        @DOC_LAST_APPROVAL_CD AS VARCHAR(50),
        @DOC_SUMMARY_APPROVAL_CD AS VARCHAR(50),
        @USER_NEXT_APPROVAL_CD AS VARCHAR(50),
        @USER_DOC_SEQ AS INT,
        
        @successCount INT = 0,
        @failedCount INT = 0

    -- Temporary log variables
    DECLARE 
        @tmpLog LOG_TEMP,
        @processId BIGINT,
        @message VARCHAR(200) = '',
        @actionName VARCHAR(50) = 'Reject POApproval'

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
	SELECT  @TSQL = 'SELECT * FROM OPENQUERY([HRLINK],''EXEC [hrportal].[dbo].[sp_POA_User] ''''' + @currentRegNo + ''''''')'
	
	INSERT INTO @HR_GRANTOR EXEC (@TSQL)

    --//// TODO : Parsing @DOC_ITEM_LIST parameter to get group of document and item.
    --//// Input format : DOC_NO|DOC_TYPE|MODE|;DOC_NO|DOC_TYPE|MODE|;...
    DECLARE @DOC_LIST_ROW_INDEX INT, @DOC_LIST_ROW_COUNT INT
    DECLARE @TB_TMP_DOC_LIST TABLE
    (
        ROW_INDEX BIGINT IDENTITY(1, 1),
        DOC_NO VARCHAR(11),
        DOC_TYPE VARCHAR(2)
    );

    DECLARE @currentApproverPosition VARCHAR(5) =
        (SELECT TOP 1 POSITION_LEVEL FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = @currentRegNo ORDER BY POSITION_LEVEL ASC)

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
		AND wf.IS_APPROVED = 'N'
		AND wf.IS_DISPLAY = 'Y'
		AND wf.INTERVAL_DATE IS NOT NULL
		AND CASE
				WHEN @userType = 'C' -- Current user
					AND (((wf.APPROVED_BY = @currentRegNo OR wf.APPROVED_BY IN (SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)) AND poh.PO_NEXT_STATUS = wf.APPROVAL_CD)
						--wf.APPROVER_POSITION = @currentApproverPosition
					OR (dbo.fn_dateadd_workday(wf.APPROVAL_INTERVAL, wf.INTERVAL_DATE) < GETDATE()
						AND wf.APPROVER_POSITION = @currentApproverPosition
						AND EXISTS (SELECT 1 FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = wf.DOCUMENT_NO AND (APPROVED_BY = @currentRegNo OR APPROVED_BY IN (SELECT DISTINCT GRANTOR FROM @HR_GRANTOR WHERE CONVERT(DATE, GETDATE()) BETWEEN VALID_FROM AND VALID_TO)) 
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
		AND ISNULL(poh.PO_DESC, '') LIKE '%' + ISNULL(@docDesc, '') + '%'
		AND ISNULL(poh.VENDOR_CD, '') LIKE '%' + ISNULL(@vendor, '') + '%'
		AND ISNULL(poh.PO_CURR, '') LIKE '%' + ISNULL(@currency, '') + '%'
		AND ISNULL(poh.PURCHASING_GRP_CD, '') LIKE '%' + ISNULL(@purchasingGroup, '') + '%'
		AND ISNULL(poh.PO_STATUS, '') LIKE '%' + ISNULL(@statusCd, '') + '%'
		AND (ISNULL(poh.CREATED_DT, CAST('1753-1-1' AS DATETIME))
			BETWEEN ISNULL(@dateFrom, CAST('1753-1-1' AS DATETIME)) AND DATEADD(MILLISECOND, 86399998, ISNULL(@dateTo, CAST('9999-12-31' AS DATETIME))))
		WHERE
		(
			@approvalMode = 'INC' 
			AND poh.PO_NO IN (
				SELECT Split 
				FROM dbo.SplitString(@poNoList, ',') SS
				WHERE ISNULL(SS.Split, '') <> ''
			)
			OR (
			@approvalMode = 'EXC' 
			AND poh.PO_NO NOT IN (
				SELECT Split 
				FROM dbo.SplitString(@poNoList, ',') SS
				WHERE ISNULL(SS.Split, '') <> ''
				)
			)
		) 
	) dt WHERE dt.DataNo >= (((@currentPage-1) * @pageSize) + 1) AND dt.DataNo <= (@currentPage * @pageSize) ORDER BY dt.DataNo ASC
    
    DECLARE @poNoListIdx INT = 1, @poNoListCount INT = (SELECT COUNT(ROW_INDEX) FROM @TB_TMP_DOC_LIST)
    WHILE @poNoListIdx <= @poNoListCount
    BEGIN
        BEGIN TRAN RejectPO
        BEGIN TRY
            SELECT @poNo = DOC_NO FROM @TB_TMP_DOC_LIST WHERE ROW_INDEX = @poNoListIdx

            --//// PRAPPROVAL PROCESS
            -- Check if document approved is available.
            SET @message = 'I|Check Document Availability. Doc.No : '  + @poNo
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            DECLARE @isDocLocked BIT = (SELECT CASE WHEN ISNULL(PROCESS_ID, 0) <> 0 AND PROCESS_ID <> @processId THEN 1 ELSE 0 END FROM TB_R_PO_H WHERE PO_NO = @poNo)
            IF @isDocLocked = 0
            BEGIN
                --//// START REJECT PROCESS.
                SET @message = 'I|Reject PO Started. Doc.No : '  + @poNo
                INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

                -- Lock document.
                SET @message = 'I|Lock Document. Doc.No : '  + @poNo
                INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

                UPDATE TB_R_PO_H SET PROCESS_ID = @processId WHERE PO_NO = @poNo

                -- Get document items.
                SET @message = 'I|Get Document Items. Doc.No : '  + @poNo
                INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

                --//// Logic Get Document Current Approval Code.
                SELECT TOP 1 @DOC_APPROVAL_CD = APPROVAL_CD
                FROM TB_R_WORKFLOW
                WHERE
                    DOCUMENT_NO = @poNo
                    AND IS_APPROVED = 'Y'
                    AND IS_DISPLAY = 'Y'
                ORDER BY DOCUMENT_SEQ DESC

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

                --//// Reject only valid if user is next approver.
                IF 
                    @DOC_NEXT_APPROVAL_CD = @USER_NEXT_APPROVAL_CD
                BEGIN
                    --//// Update WORKFLOW
					IF(@IS_ATTORNEY = 'N')
					BEGIN
						UPDATE TB_R_WORKFLOW
						SET
							APPROVED_DT = GETDATE(),
							IS_REJECTED = 'Y',
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
							APPROVED_BYPASS = GETDATE(),
							IS_REJECTED = 'Y',
							CHANGED_BY = @currentUser,
							CHANGED_DT = GETDATE()
						WHERE
							DOCUMENT_NO = @poNo
							AND IS_APPROVED = 'N'
							AND IS_DISPLAY = 'Y'
							AND APPROVAL_CD = @USER_NEXT_APPROVAL_CD
					END

                    --//// Update WORKFLOW for RIGHT BEFORE next approver.
                    UPDATE TB_R_WORKFLOW
                    SET
                        APPROVED_DT = GETDATE(),
                        APPROVED_BYPASS = NULL,
                        IS_APPROVED = 'N',
                        IS_REJECTED = 'N',
                        CHANGED_BY = @currentUser,
                        CHANGED_DT = GETDATE()
                    WHERE
                        DOCUMENT_NO = @poNo
                        AND IS_DISPLAY = 'Y'
                        AND APPROVAL_CD = @DOC_APPROVAL_CD

                    SELECT TOP 1
                        @DOC_NEXT_APPROVAL_CD = APPROVAL_CD
                    FROM TB_R_WORKFLOW
                    WHERE
                        DOCUMENT_NO = @poNo
                        AND IS_APPROVED = 'N'
                        AND IS_DISPLAY = 'Y'
                    ORDER BY DOCUMENT_SEQ ASC

                    UPDATE TB_R_PO_H
                    SET
                        PO_STATUS = '48',
						--PO_NEXT_STATUS = '43',
						PO_NEXT_STATUS = @DOC_NEXT_APPROVAL_CD,
                        CHANGED_BY = @currentUser,
                        CHANGED_DT = GETDATE()
                    WHERE
                        PO_NO = @poNo

					--//// Send Email PO Approval
					DECLARE
						@STATUS_DESC VARCHAR(100) = '',
						@NOREG VARCHAR(50) = '',
						@NOREG_CRE VARCHAR(50) = '',
						@NAME VARCHAR(100) = '',
						@LINK_PO VARCHAR(MAX) = '',
						@SUBJECT VARCHAR(100) = '',
						@BODY VARCHAR(MAX) = '',
						@MAIL_AMOUNT_APPROVAL AS MONEY,
						@MAIL_ITEM_DESCRIPTION AS VARCHAR(MAX) = '',
						@CREATOR_BODY VARCHAR(MAX) = '',
						@APPROVER_BODY VARCHAR(MAX) = '',
						@BODY_HEADER VARCHAR(MAX) = '',
						@BODY_FOOTER VARCHAR(MAX) = '',
						@REJECT_INFO VARCHAR(MAX) = ''
					
					--Creator Email
					select @STATUS_DESC  = STATUS_DESC from TB_M_STATUS 
						WHERE STATUS_CD ='93' AND DOC_TYPE = 'DOC'

					SELECT TOP 1 @NOREG_CRE = APPROVED_BY
					FROM TB_R_WORKFLOW
					WHERE DOCUMENT_NO = @poNo AND DOCUMENT_SEQ = 1
						
					IF (@NOREG <>'00000000') --Ecatalogue Dummy User 00000000
					BEGIN
						SELECT TOP 1 @NAME = PERSONNEL_NAME
						FROM TB_R_SYNCH_EMPLOYEE 
						WHERE NOREG = @NOREG_CRE AND GETDATE() BETWEEN VALID_FROM AND VALID_TO 
						ORDER BY POSITION_LEVEL DESC
						
						SELECT @LINK_PO = SYSTEM_VALUE   
						FROM TB_M_SYSTEM 
						WHERE FUNCTION_ID = 'MAIL' AND SYSTEM_CD = 'LINK_POINQUIRY' 

						SELECT @SUBJECT = SYSTEM_VALUE   
						FROM TB_M_SYSTEM 
						WHERE FUNCTION_ID = 'POMAIL' AND SYSTEM_CD = 'CRE_SUB_RE' 

						SELECT @BODY_HEADER = SYSTEM_VALUE   
						FROM TB_M_SYSTEM 
						WHERE FUNCTION_ID = 'POMAIL' AND SYSTEM_CD = 'CRE_HEAD' 

						SELECT @BODY_FOOTER = SYSTEM_VALUE   
						FROM TB_M_SYSTEM 
						WHERE FUNCTION_ID = 'POMAIL' AND SYSTEM_CD = 'CRE_FOOT'

						SET @message = 'I|Send mail to : '  + @NAME
						INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 2, @currentUser)


						SET @CREATOR_BODY = REPLACE(REPLACE(ISNULL(@BODY_HEADER, ''), '[NAME]', @NAME), '[STATUS]', REPLACE(ISNULL(@STATUS_DESC, ''), 'PO ', '')) + 
											'<br/>PO Number : <a href="' + ISNULL(@LINK_PO, '#') + '">' + ISNULL(@poNo, '') + '</a> ([REJECT_INFO])'+
											ISNULL(@BODY, '') + 
											REPLACE(ISNULL(@BODY_FOOTER, ''), '[CRE_LINK]', @LINK_PO)
						
						SET @NAME = ''
						SELECT TOP 1 @NAME = PERSONNEL_NAME
							FROM TB_R_SYNCH_EMPLOYEE 
							WHERE NOREG = @currentRegNo AND GETDATE() BETWEEN VALID_FROM AND VALID_TO 
							ORDER BY POSITION_LEVEL DESC

						SET @REJECT_INFO = @STATUS_DESC + ' by ' + @NAME

						SET @CREATOR_BODY = REPLACE(@CREATOR_BODY, '[REJECT_INFO]', ISNULL(@REJECT_INFO,''))
						
						EXEC [dbo].[sp_announcement_sendmail]
							@NOREG_CRE,
							@SUBJECT,
							@CREATOR_BODY,
							@message OUTPUT
						
						IF(@message <> 'SUCCESS')
						BEGIN
							RAISERROR(@message, 16, 1)
						END
					END --Ecatalogue Dummy User 00000000


					--//If Send Email to lower Approver
					BEGIN
						SELECT 
							@MAIL_ITEM_DESCRIPTION = PO_DESC, 
							@MAIL_AMOUNT_APPROVAL = CAST(PO_AMOUNT * PO_EXCHANGE_RATE AS MONEY) 
						FROM TB_R_PO_H
						WHERE PO_NO = @poNo

						SET @BODY = @BODY + '<br/>PO Desc. : ' + ISNULL(@MAIL_ITEM_DESCRIPTION, '') + '';
						SET @BODY = @BODY + '<br/>PO Amount : ' + ISNULL(CONVERT(VARCHAR(MAX), @MAIL_AMOUNT_APPROVAL, -1), '') + '';
						SET @BODY = @BODY + '<br/>Status : ' + ISNULL( @REJECT_INFO, '') + '';

						--Approval Email
						SELECT TOP 1 @NOREG = APPROVED_BY
						FROM TB_R_WORKFLOW
						WHERE DOCUMENT_NO = @poNo AND IS_APPROVED = 'N' AND IS_DISPLAY = 'Y'
						ORDER BY DOCUMENT_SEQ ASC

						IF(ISNULL(@NOREG,'')<>'' AND ISNULL(@NOREG,'')<>ISNULL(@NOREG_CRE,''))
						BEGIN
							SELECT TOP 1 @NAME = PERSONNEL_NAME
							FROM TB_R_SYNCH_EMPLOYEE 
							WHERE NOREG = @NOREG AND GETDATE() BETWEEN VALID_FROM AND VALID_TO 
							ORDER BY POSITION_LEVEL DESC

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

                    --//// FINISH APPROVE PROCESS.
                    SET @message = 'I|Reject PO Finished. Doc.No : '  + @poNo
                    INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
                    
                    SET @successCount = @successCount + 1;
                END
                ELSE
                BEGIN
                    SET @message = 'W|Current user ' + @currentUser + ' was not next approver. Doc.No : '  + @poNo
                    INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 2, @currentUser)

                    SET @failedCount = @failedCount + 1;
                END
            END
            ELSE
            BEGIN
                -- Document approved is unavailable.
                SET @message = 'W|Reject PO Finished with Error. Message : Document being used. Doc.No : '  + @poNo
                INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'WRN', 'WRN', @message, @moduleId, @actionName, @functionId, 3, @currentUser)

                SET @failedCount = @failedCount + 1;
            END
                
            UPDATE TB_R_PO_H SET PROCESS_ID = NULL WHERE PO_NO = @poNo

            COMMIT TRAN RejectPO
        END TRY
        BEGIN CATCH
            ROLLBACK TRAN RejectPO

            --Get the details of the error
            --that invoked the CATCH block
            SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)

            SET @failedCount = @failedCount + 1;
        END CATCH
        --//// END PRAPPROVAL PROCESS

        SET @poNoListIdx = @poNoListIdx + 1
    END

    -- Release temporary log.
    EXEC SP_PUTLOG_TEMP @tmpLog

    SELECT 'Reject' [ExecAction], @poNoListCount DocCount, @successCount Success, @failedCount Fail, @processId ProcessId, @message [Message]
END
