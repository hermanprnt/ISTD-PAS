CREATE FUNCTION [dbo].[GetNextDocNumbering](@numberingPrefix VARCHAR(2), @numberingVariant VARCHAR(2))
    RETURNS NVARCHAR (MAX)
AS
BEGIN
    DECLARE
        @paddedChar VARCHAR(8),
        @currentCounter INT,
        @isMaximum BIT,
        @maxNo INT,
        @generatedNo VARCHAR(10),
        @maxGeneratedNo VARCHAR(10),
        @message VARCHAR(MAX)

    SELECT
        @paddedChar = MINIMUM_RANGE,
        @currentCounter = CASE WHEN CAST(MINIMUM_RANGE AS INT) <= CAST(CURRENT_NUMBER AS INT) THEN CAST(CURRENT_NUMBER AS INT) + 1 ELSE CAST(MINIMUM_RANGE AS INT) + 1 END, 
        @isMaximum = CASE WHEN (CASE WHEN CAST(MINIMUM_RANGE AS INT) <= CAST(CURRENT_NUMBER AS INT) THEN CAST(CURRENT_NUMBER AS INT) + 1 ELSE CAST(MINIMUM_RANGE AS INT) + 1 END) > MAXIMUM_RANGE THEN 1 ELSE 0 END,
        @maxNo = MAXIMUM_RANGE FROM TB_M_DOC_NUMBERING WHERE NUMBERING_PREFIX = @numberingPrefix AND VARIANT = @numberingVariant

    SELECT
        @generatedNo = STUFF(@paddedChar, LEN(@paddedChar)-LEN(@currentCounter)+1, LEN(@paddedChar), @currentCounter),
        @maxGeneratedNo = STUFF(@paddedChar, LEN(@paddedChar)-LEN(@maxNo)+1, LEN(@paddedChar), @maxNo)

    SELECT @message = @generatedNo + '|' + CASE WHEN @isMaximum = 1 THEN 'E|No: ' + @generatedNo + ' is exceeding maximum number: ' + @maxGeneratedNo + '.' ELSE 'S|Success.' END
    RETURN @message
END