CREATE PROCEDURE [dbo].[sp_Material_MoveUploadTemp]
    @processId BIGINT
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX),
        @dataCount INT, @counter INT = 0

    SET NOCOUNT ON
    BEGIN TRY
    
        BEGIN TRAN MoveUploadMaterial
        
        SELECT ROW_NUMBER() OVER (ORDER BY PROCESS_ID ASC, SEQ_NO ASC) DataNo, * INTO #tmp
        FROM TB_T_MATERIAL_TEMP WHERE PROCESS_ID = @processId
        
        SELECT @dataCount = COUNT(0) FROM #tmp
        
        WHILE (@counter < @dataCount)
        BEGIN
            DECLARE @seqNo INT = (SELECT @counter + 1)
            IF (SELECT CLASS FROM #tmp WHERE DataNo = @seqNo) = 'P'
            BEGIN
                INSERT INTO TB_M_MATERIAL_PART
                SELECT
                    MAT_NO, MAT_DESC, UOM, CAR_FAMILY_CD, MAT_TYPE_CD, MAT_GRP_CD,
                    MRP_TYPE, RE_ORDER_VALUE, RE_ORDER_METHOD, STD_DELIVERY_TIME,
                    AVG_DAILY_CONSUMPTION, MIN_STOCK, MAX_STOCK, PCS_PER_KANBAN,
                    MRP_FLAG, VALUATION_CLASS, STOCK_FLAG, ASSET_FLAG, QUOTA_FLAG,
                    CONSIGNMENT_CD, 'N', CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT,
                    PROC_USAGE_CD, 0
                FROM #tmp WHERE DataNo = @seqNo
            END
            ELSE
            BEGIN
                INSERT INTO TB_M_MATERIAL_NONPART
                SELECT
                    MAT_NO, MAT_DESC, UOM, MRP_TYPE, RE_ORDER_VALUE, RE_ORDER_METHOD,
                    STD_DELIVERY_TIME, AVG_DAILY_CONSUMPTION, MIN_STOCK, MAX_STOCK,
                    PROC_USAGE_CD, 0, PCS_PER_KANBAN, MRP_FLAG, VALUATION_CLASS, STOCK_FLAG,
                    ASSET_FLAG, QUOTA_FLAG, CONSIGNMENT_CD, 'N', CREATED_BY, CREATED_DT,
                    CHANGED_BY, CHANGED_DT
                FROM #tmp WHERE DataNo = @seqNo
            END
            
            SELECT @counter = @counter + 1
        END
        
        DROP TABLE #tmp
        
        COMMIT TRAN MoveUploadMaterial
        
        SET @message = 'S|Finish: Move Upload'
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN MoveUploadMaterial
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
    END CATCH
    
    SET NOCOUNT OFF
    SELECT @message [Message]
END