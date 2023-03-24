CREATE PROCEDURE [dbo].[sp_Material_InsertUploadTemp]
    @currentUser VARCHAR(50),
    @processId BIGINT,
    @class VARCHAR(1),
    @materialNo VARCHAR(46),
    @materialDesc VARCHAR(100),
    @materialTypeCode VARCHAR(8),
    @materialGroupCode VARCHAR(18),
    @uom VARCHAR(6),
    @valuationClass VARCHAR(8),
    @mrpType VARCHAR(4),
    @carFamilyCode VARCHAR(8),
    @consignmentCode VARCHAR(1),
    @procUsageCode VARCHAR(5),
    @reorderValue VARCHAR(25),
    @reorderMethod VARCHAR(4),
    @standardDelivTime VARCHAR(11),
    @avgDailyConsump VARCHAR(10),
    @minStock VARCHAR(10),
    @maxStock VARCHAR(10),
    @pcsPerKanban VARCHAR(10),
    @mrpFlag VARCHAR(5),
    @stockFlag VARCHAR(5),
    @assetFlag VARCHAR(5),
    @quotaFlag VARCHAR(5)
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX)

    SET NOCOUNT ON
    BEGIN TRY
    
        BEGIN TRAN UploadMaterial
        
        INSERT INTO TB_T_MATERIAL_TEMP VALUES (
            @processId,
            @class,
            @materialNo,
            @materialDesc,
            @uom,
            @carFamilyCode,
            @materialTypeCode,
            @materialGroupCode,
            @mrpType,
            @reorderValue,
            @reorderMethod,
            @standardDelivTime,
            @avgDailyConsump,
            @minStock,
            @maxStock,
            @pcsPerKanban,
            @stockFlag,
            @mrpFlag,
            @assetFlag,
            @quotaFlag,
            @valuationClass,
            @procUsageCode,
            @consignmentCode,
            @currentUser,
            GETDATE(),
            NULL,
            NULL
        )
        
        COMMIT TRAN UploadMaterial
        
        SET @message = 'S|Finish: Upload'
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN UploadMaterial
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
    END CATCH
    
    SET NOCOUNT OFF
    SELECT @message [Message]
END