CREATE PROCEDURE [dbo].[sp_PurchasingGroup_Delete]
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

        BEGIN TRAN DeletePG

        -- 1. Split paramList into delimited key list
        SELECT No AS Idx, Split INTO #splittedIdList FROM dbo.SplitString(@primaryKeyList, @listDelimiter)
        SELECT @dataCount = COUNT(0) FROM #splittedIdList

        WHILE (@counter < @dataCount)
        BEGIN
            -- 2. Split delimited key into separated key
            DECLARE
                @currentId VARCHAR(200) = (SELECT Split FROM #splittedIdList WHERE Idx = @counter + 1),
                @procChannelCode VARCHAR(4), @purchasingGroupCode VARCHAR(3)
            DECLARE
                @splittedId TABLE ( Idx INT, Split VARCHAR(50) )

            INSERT INTO @splittedId SELECT No, Split FROM dbo.SplitString(@currentId, @itemDelimiter)
            SELECT @procChannelCode = (SELECT Split FROM @splittedId WHERE Idx = 1), @purchasingGroupCode = (SELECT Split FROM @splittedId WHERE Idx = 2)
            DELETE FROM @splittedId

            -- 3. Delete
            DELETE FROM TB_M_COORDINATOR WHERE PROC_CHANNEL_CD = @procChannelCode AND COORDINATOR_CD = @purchasingGroupCode AND COOR_FUNCTION = 'PG'
            DELETE FROM TB_M_COORDINATOR_MAPPING WHERE COORDINATOR_CD = @purchasingGroupCode

            SELECT @counter = @counter + 1
        END

        DROP TABLE #splittedIdList

        COMMIT TRAN DeletePG

        SET @message = 'S|Finish: Delete'
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN DeletePG
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
    END CATCH

    SET NOCOUNT OFF
    SELECT @message AS [Message]
END