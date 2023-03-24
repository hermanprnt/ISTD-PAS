CREATE FUNCTION [dbo].[TitleCase] (@input VARCHAR(4000))
    RETURNS VARCHAR(4000)
AS
BEGIN
    DECLARE @idx INT
    DECLARE @currentChar CHAR(1)
    DECLARE @output VARCHAR(255)
    
    SELECT
        @output = LOWER(@input),
        @idx = 2,
        @output = STUFF(@output, 1, 1, UPPER(SUBSTRING(@input, 1, 1)))
    
    WHILE @idx <= LEN(@input)
    BEGIN
        SET @currentChar = SUBSTRING(@input, @idx, 1)
        IF @currentChar IN (' ', ';', ':', '!', '?', ',', '.', '_', '-', '/', '&','''','(')
        IF @idx + 1 <= LEN(@input)
        BEGIN
            IF @currentChar != '''' OR UPPER(SUBSTRING(@input, @idx + 1, 1)) != 'S'
            SET @output = STUFF(@output, @idx + 1, 1,UPPER(SUBSTRING(@input, @idx + 1, 1)))
        END
        SET @idx = @idx + 1
    END
    
    RETURN ISNULL(@output, '')
END