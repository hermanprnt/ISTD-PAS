DECLARE @@SQL VARCHAR(MAX)

SET @@SQL = 
	'SELECT ISNULL(MAX(Number), 0) FROM
	(
		SELECT ROW_NUMBER() OVER (ORDER BY MAT_NO ASC) AS Number

		FROM TB_M_SOURCE_LIST
	WHERE 1=1
	'

		IF (ISNULL(@MAT_NO, '') <> '')
			SET @@SQL = @@SQL + ' AND MAT_NO LIKE ''%' + @MAT_NO + '%'''

		IF (ISNULL(@VENDOR_CD, '') <> '')
			SET @@SQL = @@SQL + ' AND VENDOR_CD LIKE ''%' + @VENDOR_CD + '%'''

		IF (ISNULL(@VALID_DT_FROM, '') <> '')
			SET @@SQL = @@SQL + ' AND VALID_DT_FROM >= dbo.fn_date_format(CAST(''' + @VALID_DT_FROM + ''' AS DATE))'
			
		SET @@SQL = @@SQL + ') AS TB'

EXEC (@@SQL)