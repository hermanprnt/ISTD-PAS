CREATE PROCEDURE [dbo].[sp_PurchasingGroup_Save]
    @editMode VARCHAR(1), @currentUser VARCHAR(50), @procChannelCode VARCHAR(4), @code VARCHAR(3), @description VARCHAR(30)
AS
BEGIN
    DECLARE @message VARCHAR(MAX)

    SET NOCOUNT ON
    BEGIN TRY
    
        BEGIN TRAN SavePG
        
        IF (@editMode = 'A')
        BEGIN
            DECLARE @isExist BIT = (
                SELECT CASE WHEN COUNT(0) > 0 THEN 1 ELSE 0 END FROM TB_M_COORDINATOR
                WHERE PROC_CHANNEL_CD = @procChannelCode AND COORDINATOR_CD = @code AND COOR_FUNCTION = 'PG')
        
            IF @isExist = 1
            BEGIN
                SET @message = 'Purchasing Group with Proc Channel ' + @procChannelCode + ' and Code ' + @code + ' is exist.'
                RAISERROR (@message, 16, 1)
            END
            ELSE
            BEGIN
                INSERT INTO TB_M_COORDINATOR VALUES (@code, @description, @procChannelCode, 'PG', @currentUser, GETDATE(), NULL, NULL)
            END
        END
        ELSE
        BEGIN
            UPDATE TB_M_COORDINATOR
            SET
                COORDINATOR_DESC = @description,
                CHANGED_BY = @currentUser,
                CHANGED_DT = GETDATE()
            WHERE PROC_CHANNEL_CD = @procChannelCode
            AND COORDINATOR_CD = @code
            AND COOR_FUNCTION = 'PG'
        END
        
        COMMIT TRAN SavePG
        
        SET @message = 'S|Finish: ' + CASE @editMode WHEN 'A' THEN 'Add' ELSE 'Edit' END
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN SavePG
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
    END CATCH
    
    SET NOCOUNT OFF
    SELECT @message AS [Message]
END