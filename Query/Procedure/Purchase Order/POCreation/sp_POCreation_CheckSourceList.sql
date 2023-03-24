CREATE PROCEDURE [dbo].[sp_POCreation_CheckSourceList]
    @matNo VARCHAR(23),
    @vendor VARCHAR(6),
    @plant VARCHAR(4),
    @purchasingGroup VARCHAR(3)
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        DECLARE
            @message VARCHAR(MAX),
            @procChannel VARCHAR(4) = (SELECT PROC_CHANNEL_CD FROM TB_M_COORDINATOR WHERE COORDINATOR_CD = @purchasingGroup)

        IF (NOT EXISTS(
            SELECT MAT_NO FROM TB_M_SOURCE_LIST WHERE VENDOR_CD = ISNULL(@vendor, '') AND PROC_CHANNEL_CD = ISNULL(@procChannel, '')
                AND YEAR(VALID_DT_TO) = 9999 AND PLANT_CD = ISNULL(@plant, '') AND MAT_NO = ISNULL(@matNo, '')))
        BEGIN
            SET @message = 'Material ' + @matNo + ' is not registered in Source List with Vendor ' + @vendor + ', Procurement Channel ' + @procChannel + ' and Plant ' + @plant
            RAISERROR(@message, 16, 1)
        END

        SET @message = 'S|Material exists'
    END TRY
    BEGIN CATCH
        SET @message = 'W|' + ERROR_MESSAGE()
    END CATCH

    SET NOCOUNT OFF
    SELECT @message [Message]
END