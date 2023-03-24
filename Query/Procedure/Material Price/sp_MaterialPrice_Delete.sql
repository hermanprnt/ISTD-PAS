CREATE PROCEDURE [dbo].[sp_MaterialPrice_Delete]
    @primaryKeyList VARCHAR(MAX)
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX),
        @listDelimiter CHAR(1) = ',',
        @itemDelimiter CHAR(1) = ';',
        @dataCount INT, @counter INT = 0

    SET NOCOUNT ON
    BEGIN TRY
    
        BEGIN TRAN DeleteMP
        
        -- 1. Split paramList into delimited key list
        SELECT No AS Idx, Split INTO #splittedIdList FROM dbo.SplitString(@primaryKeyList, @listDelimiter)
        SELECT @dataCount = COUNT(0) FROM #splittedIdList
        
        WHILE (@counter < @dataCount)
        BEGIN
            -- 2. Split delimited key into separated key
            DECLARE
                @currentId VARCHAR(200) = (SELECT Split FROM #splittedIdList WHERE Idx = @counter + 1),
                @matNo VARCHAR(23), @vendor VARCHAR(6), @warpBuyer VARCHAR(5), @sourceType VARCHAR(1), @prodPurpose VARCHAR(5),
                @partColor VARCHAR(2), @packingType VARCHAR(1), @validFrom VARCHAR(10)
            DECLARE
                @splittedId TABLE ( Idx INT, Split VARCHAR(50) )
                
            INSERT INTO @splittedId SELECT No, Split FROM dbo.SplitString(@currentId, @itemDelimiter)
            SELECT
                @matNo = (SELECT Split FROM @splittedId WHERE Idx = 1),
                @vendor = (SELECT Split FROM @splittedId WHERE Idx = 2),
                @warpBuyer = (SELECT Split FROM @splittedId WHERE Idx = 3),
                @sourceType = (SELECT Split FROM @splittedId WHERE Idx = 4),
                @prodPurpose = (SELECT Split FROM @splittedId WHERE Idx = 5),
                @partColor = (SELECT Split FROM @splittedId WHERE Idx = 6),
                @packingType = (SELECT Split FROM @splittedId WHERE Idx = 7),
                @validFrom = (SELECT Split FROM @splittedId WHERE Idx = 8)
            DELETE FROM @splittedId
                
            -- 3. Delete
            DELETE FROM TB_M_MATERIAL_PRICE
                WHERE MAT_NO = @matNo AND VENDOR_CD = @vendor AND WARP_BUYER_CD = @warpBuyer
                    AND SOURCE_TYPE = @sourceType AND PRODUCTION_PURPOSE = @prodPurpose
                    AND PART_COLOR_SFX = @partColor AND PACKING_TYPE = @packingType
                    AND (YEAR(VALID_DT_FROM) = CAST(RIGHT(@validFrom, 4) AS INT)
                        AND MONTH(VALID_DT_FROM) = CAST(SUBSTRING(@validFrom, 4, 2) AS INT)
                        AND DAY(VALID_DT_FROM) = CAST(LEFT(@validFrom, 2) AS INT))
                    
            SELECT @counter = @counter + 1
        END
        
        DROP TABLE #splittedIdList
        
        COMMIT TRAN DeleteMP
        
        SET @message = 'S|Finish: Delete'
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN DeleteMP
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
    END CATCH
    
    SET NOCOUNT OFF
    SELECT @message AS [Message]
END
