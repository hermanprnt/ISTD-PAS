DECLARE @@SQL VARCHAR(MAX)

SET @@SQL = 'SELECT * FROM
(
SELECT ROW_NUMBER() OVER (ORDER BY MAT_NO ASC, VALID_DT_FROM ASC) AS Number,
	MAT_NO AS MAT_NO,
	VENDOR_CD AS VENDOR_CD,
	dbo.fn_date_format(VALID_DT_FROM) AS VALID_DT_FROM,
	dbo.fn_date_format(VALID_DT_TO) AS VALID_DT_TO,
	CREATED_BY AS CREATED_BY,
	dbo.fn_date_format(CREATED_DT) AS CREATED_DT,
	CHANGED_BY AS CHANGED_BY,
	dbo.fn_date_format(CHANGED_DT) AS CHANGED_DT

	FROM TB_M_SOURCE_LIST
	WHERE 1=1
	'
	IF (ISNULL(@MAT_NO, '') <> '')
		SET @@SQL = @@SQL + ' AND MAT_NO LIKE ''%' + @MAT_NO + '%'''

	IF (ISNULL(@VENDOR_CD, '') <> '')
		SET @@SQL = @@SQL + ' AND VENDOR_CD LIKE ''%' + @VENDOR_CD + '%'''

	IF (ISNULL(@VALID_DT_FROM, '') <> '')
		SET @@SQL = @@SQL + ' AND VALID_DT_FROM >= dbo.fn_date_format(CAST(''' + @VALID_DT_FROM + ''' AS DATE))'

	SET @@SQL = @@SQL + ' ) TB WHERE Number BETWEEN ' + CAST(@Start AS VARCHAR) + ' AND ' + CAST(@End AS VARCHAR)

EXEC (@@SQL)