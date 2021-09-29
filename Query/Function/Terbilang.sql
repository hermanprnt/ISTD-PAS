CREATE FUNCTION [dbo].[Terbilang] (@input BIGINT)
    RETURNS NVARCHAR (MAX)
AS
BEGIN
    DECLARE @output VARCHAR(MAX) = ''

    IF (FLOOR(@input / 1000000000000)) > 0
    BEGIN
        SET @output = @output + dbo.Terbilang(@input / 1000000000000) + ' Trilyun '
        SET @input = @input % 1000000000000
    END

    IF (FLOOR(@input / 1000000000)) > 0
    BEGIN
        SET @output = @output + dbo.Terbilang(@input / 1000000000) + ' Milyar '
        SET @input = @input % 1000000000
    END

    IF (FLOOR(@input / 1000000)) > 0
    BEGIN
        SET @output = @output + dbo.Terbilang(@input / 1000000) + ' Juta '
        SET @input = @input % 1000000
    END

    IF (FLOOR(@input / 1000)) > 0
    BEGIN
        IF(FLOOR(@input / 1000) = 1)
        BEGIN
            SET @output = @output + 'Seribu '
        END
        ELSE
        BEGIN
            SET @output = @output + dbo.Terbilang(@input / 1000) + ' Ribu '
        END
        SET @input = @input % 1000
    END

    IF (FLOOR(@input / 100)) > 0
    BEGIN
        IF(FLOOR(@input / 100) = 1)
        BEGIN
            SET @output = @output + 'Seratus '
        END
        ELSE
        BEGIN
            SET @output = @output + dbo.Terbilang(@input / 100) + ' Ratus '
        END
        SET @input = @input % 100
    END

    IF @input > 10 AND @input < 20
    BEGIN
        IF(@input % 11 = 0)
        BEGIN
            SET @output = @output + 'Sebelas'
        END
        ELSE
        BEGIN
            SET @output = @output + dbo.Terbilang(@input % 10) + ' Belas'
        END

        RETURN RTRIM(LTRIM(@output))
    END

    IF (FLOOR(@input / 10)) > 0
    BEGIN
        IF(FLOOR(@input / 10) = 1)
        BEGIN
            SET @output = @output + 'Sepuluh'
        END
        ELSE
        BEGIN
            SET @output = @output + dbo.Terbilang(@input / 10) + ' Puluh '
        END
        SET @input = @input % 10
    END

    IF (@input > 0)
    BEGIN
        DECLARE @satuan TABLE (Idx INT IDENTITY(0,1), Bilangan VARCHAR(32))
        INSERT @satuan (Bilangan) VALUES ('Nol'),('Satu'),('Dua'),('Tiga'),
                                         ('Empat'),('Lima'),('Enam'),('Tujuh'),
                                         ('Delapan'),('Sembilan')
            
        SELECT @output = @output + Bilangan FROM @satuan WHERE Idx = @input
    END

    RETURN RTRIM(LTRIM(@output))
END