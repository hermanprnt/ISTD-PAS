CREATE PROCEDURE [dbo].[sp_POInquiry_UpdateLastDownloadingUser]
    @currentUser VARCHAR(50),
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6),
	@PoNo VARCHAR(11)
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = 'sp_POInquiry_UpdateLastDownloadingUser',
        @tmpLog LOG_TEMP

    BEGIN TRY
        SET @message = 'I|Start'
        EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0

        BEGIN TRAN LastDownloading

        UPDATE TB_R_PO_H SET DOWNLOAD_BY = @currentUser, DOWNLOAD_DT = GETDATE() WHERE PO_NO = @PoNo

        COMMIT TRAN LastDownloading

        SET @message = 'S|Finish'
        EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @processId OUTPUT, 'SUC', 'SUC', @moduleId, @functionId, 2
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN LastDownloading
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
    END CATCH

    EXEC sp_PutLog_Temp @tmpLog
    SET NOCOUNT OFF
    SELECT @message [Message]
END