DECLARE @@SQL VARCHAR(MAX)

SET @@SQL = 
	'SELECT ISNULL(MAX(Number), 0) FROM
	(
		SELECT ROW_NUMBER() OVER (ORDER BY VENDOR_CD ASC) AS Number
		FROM TB_M_VENDOR
		WHERE 1=1
	'
		IF (ISNULL(@Param, '') <> '')
		SET @@SQL = @@SQL + ' AND VENDOR_CD LIKE ''%' + @Param + '%'''
				
		SET @@SQL = @@SQL + ') AS TB'

EXEC (@@SQL)