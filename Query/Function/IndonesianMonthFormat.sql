CREATE FUNCTION [dbo].[IndonesianMonthFormat] (@date VARCHAR(11))
RETURNS VARCHAR(18)
AS
BEGIN
	DECLARE @RESULT_MONTH VARCHAR(11)

	SET @RESULT_MONTH = (SELECT
		CASE MONTH(CAST(@date AS DATE))
			WHEN 1 THEN REPLACE(@date, 'Jan', 'Januari')
			WHEN 2 THEN REPLACE(@date, 'Feb', 'Februari')
			WHEN 3 THEN REPLACE(@date, 'Mar', 'Maret')
			WHEN 4 THEN REPLACE(@date, 'Apr', 'April')
			WHEN 5 THEN REPLACE(@date, 'May', 'Mei')
			WHEN 6 THEN REPLACE(@date, 'Jun', 'Juni')
			WHEN 7 THEN REPLACE(@date, 'Jul', 'Juli')
			WHEN 8 THEN REPLACE(@date, 'Aug', 'Agustus')
			WHEN 9 THEN REPLACE(@date, 'Sep', 'September')
			WHEN 10 THEN REPLACE(@date, 'Oct', 'Oktober')
			WHEN 11 THEN REPLACE(@date, 'Nov', 'Nopember')
			WHEN 12 THEN REPLACE(@date, 'Dec', 'Desember')
			ELSE REPLACE(@date, 'Jan', 'Januari')
		END
	)

	RETURN @RESULT_MONTH
END

GO


