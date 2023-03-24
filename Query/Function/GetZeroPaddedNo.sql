CREATE FUNCTION [dbo].[GetZeroPaddedNo](@maxLength INT, @docNoCounter VARCHAR(50))
    RETURNS NVARCHAR (50)
AS
BEGIN
    DECLARE @counter INT = 0, @paddedChar VARCHAR(50) = ''
    WHILE @counter < @maxLength AND @counter < 50
    BEGIN SELECT @paddedChar = @paddedChar + '0', @counter = @counter + 1 END

    RETURN STUFF(@paddedChar, LEN(@paddedChar)-LEN(@docNoCounter)+1, LEN(@paddedChar), @docNoCounter)
END