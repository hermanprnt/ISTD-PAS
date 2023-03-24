ALTER PROCEDURE [dbo].[sp_POCreation_AddAttachmentTemp]
    @currentUser VARCHAR(50),
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(5),
    @docNo VARCHAR(11),
    @docType VARCHAR(5),
    @tempFilename VARCHAR(MAX),
    @oriFilename VARCHAR(MAX),
    @fileExt VARCHAR(5),
    @fileSize BIGINT
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = 'sp_POCreation_AddAttachmentTemp',
        @tmpLog LOG_TEMP
        
    BEGIN TRY
        SET NOCOUNT ON
        
        EXEC dbo.sp_PutLog 'I|Start', @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0
    
        BEGIN TRAN AddAttachmentTemp
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'Insert upload file info to TB_T_ATTACHMENT: begin', @moduleId, @actionName, @functionId, 1, @currentUser)
        
		--UPDATE TB_T_ATTACHMENT SET DELETE_FLAG = 'Y', CHANGED_DT = GETDATE(), CHANGED_BY = @currentUser WHERE PROCESS_ID = @processId AND DOC_NO = @docNo AND DOC_TYPE = @docType

        INSERT INTO TB_T_ATTACHMENT VALUES (@processId, (SELECT ISNULL(MAX(SEQ_NO), 0) + 1 FROM TB_T_ATTACHMENT WHERE PROCESS_ID = @processId), @docNo, @docType,
            @tempFilename, @oriFilename, @fileExt, @fileSize, 'N', 'Y', @currentUser, GETDATE(), NULL, NULL)
        
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'Insert upload file info to TB_T_ATTACHMENT: end', @moduleId, @actionName, @functionId, 1, @currentUser)
        COMMIT TRAN AddAttachmentTemp
        
        SET @message = 'S|Finish'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN AddAttachmentTemp
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ' - ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
    END CATCH
    
    EXEC sp_PutLog_Temp @tmpLog
    SET NOCOUNT OFF
    SELECT @message
END