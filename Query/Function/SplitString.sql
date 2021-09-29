ALTER FUNCTION [dbo].[SplitString]
(
    @dataString VARCHAR(MAX),
    @separator CHAR(1) = '|'
)
RETURNS @splittedString TABLE 
(
	No INT IDENTITY(1,1),
	Split NVARCHAR(MAX)
)
AS
BEGIN
    DECLARE @counter INT = 1
    WHILE(CHARINDEX(@separator, @dataString) > 0)
    BEGIN
        INSERT INTO @splittedString VALUES (LTRIM(RTRIM(SUBSTRING(@dataString, 1, CHARINDEX(@separator, @dataString) - 1))))
        SELECT
            @dataString = Substring(@dataString, CHARINDEX(@separator, @dataString) + 1, LEN(@dataString)),
            @counter = @counter + 1
    END
    INSERT INTO @splittedString VALUES (LTRIM(RTRIM(@dataString)))
    RETURN
END