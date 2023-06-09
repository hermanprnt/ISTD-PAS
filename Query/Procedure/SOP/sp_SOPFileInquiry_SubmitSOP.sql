USE [PAS_DB_QA]
GO
/****** Object:  StoredProcedure [dbo].[sp_WallAnnouncement_SubmitData]    Script Date: 12/18/2017 6:02:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_SOPFileInquiry_SubmitSOP]
	@DOC_TYPE VARCHAR(20),
	@FILE_NAME VARCHAR(MAX),
	@FILE_NAME_ORI VARCHAR(MAX),
	@FILE_DESC VARCHAR(MAX),
	@FILE_EXTENSION VARCHAR(10),
	@FILE_SIZE int,
	@currentUser VARCHAR(50)
AS
BEGIN
	BEGIN TRY
		DECLARE 
        @tmpLog LOG_TEMP,
        @processId BIGINT,
        @message VARCHAR(MAX) = '',
		@moduleId VARCHAR(3) = '7',
		@functionId VARCHAR(6) = '701001',
        @actionName VARCHAR(50) = 'Submit SOP'

		EXEC dbo.sp_PutLog 'I|Submit SOP Start', @currentUser, @actionName, @processId OUTPUT, 'START', 'INF', @moduleId, @functionId, 0

		BEGIN TRAN

		SET @message = 'I|Ori File Name : ' + @FILE_NAME_ORI
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

		SET @message = 'I|Alias File Name : '+@FILE_NAME
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
		
		INSERT INTO TB_M_SOP_DOCUMENT ([DOC_TYPE], [FILE_NAME], [FILE_NAME_ORI], [FILE_DESC], [FILE_EXTENSION], [FILE_SIZE], [CREATED_BY], [CREATED_DT])
		VALUES
		(@DOC_TYPE, @FILE_NAME, @FILE_NAME_ORI, @FILE_DESC, @FILE_EXTENSION, @FILE_SIZE, @currentUser, Getdate())

		SET @message = 'I|Submit SOP Finished'
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