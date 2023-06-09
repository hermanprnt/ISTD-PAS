USE [PAS_DB_QA]
GO
/****** Object:  StoredProcedure [dbo].[sp_SOPFileInquiry_SubmitSOP]    Script Date: 12/19/2017 10:12:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_SOPFileInquiry_DeleteSOP]
	@DOCID int,
	@currentUser VARCHAR(50)
AS
BEGIN
	BEGIN TRY
		DECLARE 
        @tmpLog LOG_TEMP,
        @processId BIGINT,
        @message VARCHAR(MAX) = '',
		@moduleId VARCHAR(3) = '7',
		@functionId VARCHAR(6) = '701002',
        @actionName VARCHAR(50) = 'Delete SOP',
		@fileName VARCHAR(MAX) = ''

		EXEC dbo.sp_PutLog 'I|Delete SOP Start', @currentUser, @actionName, @processId OUTPUT, 'START', 'INF', @moduleId, @functionId, 0

		BEGIN TRAN

		SELECT @fileName = FILE_NAME FROM TB_M_SOP_DOCUMENT WHERE DOCUMENT_ID = @DOCID
		SET @message = 'I|File name : ' + @fileName
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
		
		DELETE FROM TB_M_SOP_DOCUMENT WHERE DOCUMENT_ID = @DOCID

		SET @message = 'I|Delete SOP Finished'
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'END', 'INF', @message, @moduleId, @actionName, @functionId, 2, @currentUser)

		SET @message = 'S|'

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN

		SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)

	END CATCH

	EXEC SP_PUTLOG_TEMP @tmpLog

	SELECT @message
END