DECLARE @@SQL_QUERY VARCHAR(MAX),
		@@LIMIT VARCHAR(MAX)

SELECT @@LIMIT = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH'

SET @@SQL_QUERY = 

'SELECT TOP ' + @@LIMIT + '
	ISNULL(COUNT(DISTINCT RPH.ROUTINE_NO), 0)
FROM TB_M_ROUTINE_PR_H RPH
	JOIN TB_M_ROUTINE_PR_ITEM RPI ON RPH.ROUTINE_NO = RPI.ROUTINE_NO
	JOIN TB_M_COORDINATOR MC ON RPH.PR_COORDINATOR = MC.COORDINATOR_CD
	LEFT JOIN TB_M_VENDOR MV ON RPI.VENDOR_CD = MV.VENDOR_CD
	LEFT JOIN TB_M_SYSTEM MS ON MS.FUNCTION_ID = ''113001'' AND MS.SYSTEM_CD = RPH.ACTIVE_FLAG 
WHERE
	((RPH.ROUTINE_NO LIKE ''%' + ISNULL(@ROUTINE_NO,'') + '%'' 
	AND isnull(''' + ISNULL(@ROUTINE_NO,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@ROUTINE_NO,'') + ''', '''') = '''')))
AND ((RPH.PR_DESC LIKE ''%' + ISNULL(@DESCRIPTION,'') + '%'' 
	AND isnull(''' + ISNULL(@DESCRIPTION,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@DESCRIPTION,'') + ''', '''') = '''')))
AND ((RPH.PR_COORDINATOR = ''' + ISNULL(@PR_COORDINATOR,'') + ''' 
	AND isnull(''' + ISNULL(@PR_COORDINATOR,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@PR_COORDINATOR,'') + ''', '''') = '''')))
AND ((RPH.DIVISION_ID = ''' + ISNULL(@DIVISION_CD,'') + ''' 
	AND isnull(''' + ISNULL(@DIVISION_CD,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@DIVISION_CD,'') + ''', '''') = '''')))
AND ((RPH.SCH_TYPE = ''' + ISNULL(@SCH_TYPE,'') + ''' 
	AND isnull(''' + ISNULL(@SCH_TYPE,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@SCH_TYPE,'') + ''', '''') = '''')))
AND ((RPH.VALID_FROM >= ''' + ISNULL(@VALID_DATEFROM,'') + '''
	AND isnull(''' + ISNULL(@VALID_DATEFROM,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@VALID_DATEFROM,'') + ''', '''') = '''')))
AND ((RPH.VALID_TO <= ''' + ISNULL(@VALID_DATETO,'') + '''
	AND isnull(''' + ISNULL(@VALID_DATETO,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@VALID_DATETO,'') + ''', '''') = '''')))
AND (((RPI.VENDOR_CD LIKE ''%' + ISNULL(@VENDOR_CD,'') + '%''
	AND isnull(''' + ISNULL(@VENDOR_CD,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@VENDOR_CD,'') + ''', '''') = '''')))
OR ((MV.VENDOR_NAME LIKE ''%' + ISNULL(@VENDOR_CD,'') + '%''
	AND isnull(''' + ISNULL(@VENDOR_CD,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@VENDOR_CD,'') + ''', '''') = ''''))))
AND ((RPH.PLANT_CD = ''' + ISNULL(@PLANT_CD,'') + ''' 
	AND isnull(''' + ISNULL(@PLANT_CD,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@PLANT_CD,'') + ''', '''') = '''')))
AND ((RPH.SLOC_CD = ''' + ISNULL(@SLOC_CD,'') + ''' 
	AND isnull(''' + ISNULL(@SLOC_CD,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@SLOC_CD,'') + ''', '''') = '''')))
AND ((RPI.WBS_NO LIKE ''%' + ISNULL(@WBS_NO,'') + '%''
	AND isnull(''' + ISNULL(@WBS_NO,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@WBS_NO,'') + ''', '''') = '''')))
AND ((RPH.CREATED_BY LIKE ''%' + ISNULL(@CREATED_BY,'') + '%''
	AND isnull(''' + ISNULL(@CREATED_BY,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@CREATED_BY,'') + ''', '''') = '''')))'

EXEC (@@SQL_QUERY)