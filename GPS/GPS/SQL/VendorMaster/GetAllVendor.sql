﻿DECLARE @@SQL VARCHAR(MAX)

SET @@SQL = 'SELECT * FROM
(
	SELECT ROW_NUMBER() OVER (ORDER BY VENDOR_CD ASC) AS Number,
		  VENDOR_CD
		  ,VENDOR_NAME

	FROM TB_M_VENDOR
	WHERE 1=1
	'
	
	IF (ISNULL(@Param, '') <> '')
		SET @@SQL = @@SQL + ' AND (VENDOR_CD LIKE ''%' + @Param + '%'' OR VENDOR_NAME LIKE ''%' + @Param + '%'')'
				
	SET @@SQL = @@SQL + ' ) TB WHERE Number BETWEEN ' + CAST(@Start AS VARCHAR) + ' AND ' + CAST(@End AS VARCHAR)

EXEC (@@SQL)