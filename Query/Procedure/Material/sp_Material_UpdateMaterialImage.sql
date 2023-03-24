CREATE PROCEDURE [dbo].[sp_Material_UpdateMaterialImage]
    @currentUser VARCHAR(50),
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6),
    @matNo VARCHAR(50),
    @fileName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON
    DECLARE
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = 'sp_Material_UpdateMaterialImage',
        @tmpLog LOG_TEMP

    BEGIN TRY
        SET @message = 'I|Start'
        EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0

        BEGIN TRAN UpdateImage

        DECLARE @desc VARCHAR(200)
        SELECT TOP 1 @desc = MAT_DESC FROM (
            SELECT MAT_NO, MAT_DESC FROM TB_M_MATERIAL_PART WHERE MAT_NO = @matNo
            UNION SELECT MAT_NO, MAT_DESC FROM TB_M_MATERIAL_NONPART WHERE MAT_NO = @matNo
        ) mat

        IF (EXISTS(SELECT MAT_NO FROM TB_M_MATERIAL_IMAGE WHERE MAT_NO = @matNo))
        BEGIN
            UPDATE TB_M_MATERIAL_IMAGE SET IMG_URL = @fileName WHERE MAT_NO = @matNo
        END
        ELSE
        BEGIN
            INSERT INTO TB_M_MATERIAL_IMAGE VALUES (@matNo, 1, @fileName, @desc, 1, 1)
        END

        COMMIT TRAN UpdateImage

        SET @message = 'S|Finish'
        EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @processId OUTPUT, 'SUC', 'SUC', @moduleId, @functionId, 2
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN UpdateImage
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
    END CATCH

    EXEC sp_PutLog_Temp @tmpLog
    SET NOCOUNT OFF
    SELECT @message [Message]
END