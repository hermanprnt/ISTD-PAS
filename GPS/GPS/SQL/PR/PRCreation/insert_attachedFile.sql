DECLARE @@SEQ INT

BEGIN TRY
	SELECT @@SEQ = ISNULL(MAX(SEQ_NO), 0) + 1 FROM TB_T_ATTACHMENT WHERE DOC_NO = @PR_NO
	INSERT INTO [dbo].[TB_T_ATTACHMENT]
			   ([DOC_NO]
			   ,[SEQ_NO]
			   ,[DOC_TYPE]
			   ,[FILE_PATH]
			   ,[FILE_NAME_ORI]
			   ,[FILE_EXTENSION]
			   ,[FILE_SIZE]
			   ,[NEW_FLAG]
			   ,[PROCESS_ID]
			   ,[CREATED_BY]
			   ,[CREATED_DT])
		 VALUES
			   (@PR_NO
			   ,@@SEQ
			   ,@DOC_TYPE
			   ,@FILE_PATH
			   ,@FILE_PATH_ORI
			   ,@FILE_EXTENSION
			   ,@FILE_SIZE
			   ,'Y'
			   ,@PROCESS_ID
			   ,@USERID
			   ,GETDATE())

	-- Note : Prevent other attachment besides quotation to have more than 1 file
	IF(@DOC_TYPE <> 'QUOT')
	BEGIN
		UPDATE TB_T_ATTACHMENT SET DELETE_FLAG = 'Y' WHERE DOC_TYPE = @DOC_TYPE AND SEQ_NO <> @@SEQ AND PROCESS_ID = @PROCESS_ID
	END

	SELECT 'SUCCESS'
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
END CATCH