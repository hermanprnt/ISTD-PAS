-- =============================================
-- Author	  :	FID) Intan Puspitasari
-- Create date: 21.03.2016
-- Description:	Send Email For User & Admin Notification 
-- =============================================
ALTER PROCEDURE [dbo].[sp_announcement_sendmail]
	@NOREG VARCHAR(MAX),
	@SUBJECT VARCHAR(200),
	@BODY VARCHAR(MAX),
	@STATUS VARCHAR(MAX) OUTPUT
AS
BEGIN
	DECLARE @MAIL_TO VARCHAR(MAX) = '',
			@MAIL_CC VARCHAR(MAX) = '',
			@MAIL_PROFILER VARCHAR(100) = '',

			@PIC VARCHAR(MAX) = ''

	BEGIN TRY
		SET @BODY = '<html><body>' + @BODY
		SET @NOREG = REPLACE(@NOREG, ';', ',')

		SELECT @MAIL_TO = CASE WHEN(ISNULL(@MAIL_TO, '') = '') THEN '' ELSE @MAIL_TO + ';' END + MAIL,
			   @PIC = CASE WHEN(ISNULL(@PIC, '') = '') THEN '' ELSE @MAIL_TO + ', ' END + PERSONNEL_NAME
			FROM TB_R_SYNCH_EMPLOYEE WHERE @NOREG LIKE '%'+NOREG +'%' AND GETDATE() BETWEEN VALID_FROM AND VALID_TO

		--Note : Eliminate duplicate email because of duplicate data in TB_R_SYNCH_EMPLOYEE
		DECLARE @MAIL_TO_DISTINCT VARCHAR(MAX) = ''
		SELECT @MAIL_TO_DISTINCT = CASE WHEN(ISNULL(@MAIL_TO_DISTINCT, '') = '') THEN '' ELSE @MAIL_TO_DISTINCT + ';' END + data.MAIL
		FROM ( 
			SELECT DISTINCT Split as MAIL
			FROM [dbo].[SplitString](@MAIL_TO, ';')
		) data

		SELECT @MAIL_CC = SYSTEM_VALUE 
			FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'MAIL' AND SYSTEM_CD = 'ADMIN_MAIL'

		SELECT @MAIL_PROFILER = SYSTEM_VALUE 
			FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'MAIL' AND SYSTEM_CD = 'MAIL_PROFILER'
		IF(ISNULL(@MAIL_PROFILER, '') = '')
		BEGIN
			RAISERROR('Mail Profiler Not Set Yet', 16, 1)
		END

		IF((ISNULL(@MAIL_TO, '') = '') OR (ISNULL(@MAIL_TO_DISTINCT, '') = ''))
		BEGIN
			--Note : Eliminate duplicate PIC Name because of duplicate data in TB_R_SYNCH_EMPLOYEE
			DECLARE @PIC_DISTINCT VARCHAR(MAX) = ''
			SELECT @PIC_DISTINCT = CASE WHEN(ISNULL(@PIC_DISTINCT, '') = '') THEN '' ELSE @PIC_DISTINCT + ', ' END + data.PIC
			FROM ( 
				SELECT DISTINCT Split as PIC
				FROM [dbo].[SplitString](@PIC, ', ')
			) data

			SET @MAIL_TO = @MAIL_CC
			SET @MAIL_CC = ''
			SET @BODY = @BODY + '&nbsp;<p><b>Email PIC not set yet. Document PIC : ' + @PIC + ' </b></p>'
		END
		SET @BODY = @BODY + '</body></html>'

		EXEC msdb.dbo.sp_send_dbmail
			 @profile_name = @MAIL_PROFILER,
			 @recipients = @MAIL_TO_DISTINCT,
			 @blind_copy_recipients = @MAIL_CC,
			 @subject = @SUBJECT,
			 @body_format = 'HTML',
			 @body = @BODY

		SET @STATUS = 'SUCCESS'
	END TRY
	BEGIN CATCH
		SELECT @STATUS = ERROR_MESSAGE()
	END CATCH
END
