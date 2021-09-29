CREATE PROCEDURE [dbo].[sp_PurchasingGroup_DeleteUserMap]
    @purchasingGroup VARCHAR(6),
    @regNoList VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @message VARCHAR(MAX)

    BEGIN TRY
        BEGIN TRAN DeleteUserMap

        DECLARE @dataCount INT, @counter INT = 1
        DECLARE @splittedRegNoList TABLE (Idx INT, Split VARCHAR(MAX))
        INSERT INTO @splittedRegNoList
        SELECT [No], Split FROM dbo.SplitString(@regNoList, ';')
        SELECT @dataCount = COUNT(0) FROM @splittedRegNoList

        WHILE @counter <= @dataCount
        BEGIN
            DECLARE @currentId VARCHAR(MAX) = (SELECT Split FROM @splittedRegNoList WHERE Idx = @counter)
            DELETE FROM TB_M_COORDINATOR_MAPPING WHERE COORDINATOR_CD = @purchasingGroup AND NOREG = @currentId

            SET @counter = @counter + 1
        END

        COMMIT TRAN DeleteUserMap

        SET @message = 'S|Finish'
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN DeleteUserMap
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
    END CATCH

    SELECT @message [Message]
    SET NOCOUNT OFF
END