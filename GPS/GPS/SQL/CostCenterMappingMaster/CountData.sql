DECLARE @@SQL VARCHAR(MAX)

SET @@SQL = 
	'SELECT ISNULL(MAX(Number), 0) FROM
	(
		SELECT ROW_NUMBER() OVER (ORDER BY COST_CENTER_GRP_CD ASC) AS Number
		FROM TB_M_COST_CENTER_GRP
		WHERE 1=1
		
	'
		IF (ISNULL(@COST_CENTER_GRP_CD, '') <> '')
			SET @@SQL = @@SQL + ' AND COST_CENTER_GRP_CD = ''' + @COST_CENTER_GRP_CD + ''''

		IF (ISNULL(@COST_CENTER_GRP_DESC, '') <> '')
			SET @@SQL = @@SQL + ' AND COST_CENTER_GRP_DESC LIKE ''%' + @COST_CENTER_GRP_DESC + '%'''

		IF (ISNULL(@DIVISION_CD, '') <> '')
			SET @@SQL = @@SQL + ' AND DIVISION_CD = ''' + @DIVISION_CD + ''''
		
		SET @@SQL = @@SQL + ') AS TB'

EXEC (@@SQL)