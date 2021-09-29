CREATE PROCEDURE sp_PRApproval_PostNotice
    @docNo VARCHAR(11),
    @docType VARCHAR(2),
    @noticeFromUser VARCHAR(MAX),
    @noticeFromAlias VARCHAR(MAX),
    @noticeToUser VARCHAR(MAX),
    @noticeToAlias VARCHAR(MAX),
    @noticeMessage VARCHAR(MAX),
    @noticeImportance VARCHAR(MAX),
    @username VARCHAR(50)
AS
BEGIN
    DECLARE @SEQ_NO AS INT,
			@docDate VARCHAR(50)
    
	IF(@docType = 'PR')
	BEGIN
		SELECT @docDate = DOC_DT FROM TB_R_PR_H WHERE PR_NO = @docNo
	END
	ELSE
	BEGIN
		SELECT @docDate = DOC_DT FROM TB_R_PO_H WHERE PO_NO = @docNo
	END

    SELECT @SEQ_NO = MAX(SEQ_NO) + 1
    FROM TB_R_NOTICE
    WHERE DOC_NO = @docNo
    
    SET @SEQ_NO = ISNULL(@SEQ_NO, 1)
    
    INSERT INTO [dbo].[TB_R_NOTICE]
		([DOC_NO]
        ,[SEQ_NO]
        ,[NOTICE_FROM_USER]
        ,[NOTICE_FROM_ALIAS]
        ,[NOTICE_TO_USER]
        ,[NOTICE_TO_ALIAS]
        ,[NOTICE_MESSAGE]
        ,[NOTICE_IMPORTANCE]
        ,[IS_REPLIED]
        ,[REPLY_FOR]
        ,[SEEN_BY]
        ,[CREATED_BY]
        ,[CREATED_DT]
        ,[CHANGED_BY]
        ,[CHANGED_DT]
        ,[DOC_TYPE]
        ,[DOC_DATE])
    VALUES
        (@docNo
        ,@SEQ_NO
        ,@noticeFromUser
        ,@noticeFromAlias
        ,@noticeToUser
        ,@noticeToAlias
        ,@noticeMessage
        ,@noticeImportance
        ,NULL
        ,NULL
        ,NULL
        ,@username
        ,GETDATE()
        ,NULL
        ,NULL
        ,@docType
        ,@docDate)

	
	--Added By : FID) Intan Puspitasari
	--Added Dt : 13/06/2016
	--Send email notice

	DECLARE @mailProfiler VARCHAR(MAX) = '',
			@mailTo VARCHAR(MAX) = '',
			@mailCc VARCHAR(MAX) = '',
			@mailSubject VARCHAR(MAX) = 'Notice Doc. No ' + @docNo + ' ' + CAST(GETDATE() AS VARCHAR),
			@mailImportance VARCHAR(10) = CASE WHEN(@noticeImportance = 'H') THEN 'HIGH'
											   WHEN(@noticeImportance = 'N') THEN 'NORMAL'
											   ELSE 'LOW' END

	SELECT @mailProfiler = SYSTEM_VALUE 
		FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'MAIL' AND SYSTEM_CD = 'MAIL_PROFILER'
	IF(ISNULL(@mailProfiler, '') = '')
	BEGIN
		RAISERROR('Mail Profiler Not Set Yet', 16, 1)
	END

	SELECT @mailTo = CASE WHEN(ISNULL(@mailTo, '') = '') THEN '' ELSE @mailTo + ';' END + MAIL
			FROM TB_R_SYNCH_EMPLOYEE WHERE @noticeToUser LIKE '%'+NOREG +'%' AND GETDATE() BETWEEN VALID_FROM AND VALID_TO
	SELECT TOP 1 @mailCc = MAIL FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = @noticeFromUser AND GETDATE() BETWEEN VALID_FROM AND VALID_TO

	SET @noticeMessage = @noticeMessage + '<br>'
	EXEC msdb.dbo.sp_send_dbmail
			 @profile_name = @mailProfiler,
			 @recipients = @mailTo,
			 @copy_recipients = @mailCc,
			 @subject = @mailSubject,
			 @body_format = 'HTML',
			 @body = @noticeMessage,
			 @IMPORTANCE = @mailImportance
END