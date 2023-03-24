-- ===================================================================
-- Author		: FID)Intan Puspitasari
-- Create date	: 19/04/2015
-- Description	: Select Routine Header Data By retrieved search criteria 
-- ===================================================================
CREATE PROCEDURE [dbo].[sp_routineinquiry_getList] 
		@ROUTINE_NO VARCHAR(MAX), 
		@DESCRIPTION VARCHAR(MAX),
		@PR_COORDINATOR VARCHAR(MAX),
		@DIVISION_CD VARCHAR(MAX), 
		@SCH_TYPE VARCHAR(1),
		@VALID_DATEFROM VARCHAR(MAX), 
		@VALID_DATETO VARCHAR(MAX), 
		@VENDOR_CD VARCHAR(MAX), 
		@PLANT_CD VARCHAR(MAX), 
		@SLOC_CD VARCHAR(MAX), 
		@WBS_NO VARCHAR(MAX), 
		@CREATED_BY VARCHAR(MAX),
		@Start INT, 
		@Length INT
AS
BEGIN
DECLARE @SQL_QUERY VARCHAR(MAX),
		@LIMIT VARCHAR(10)

--TO DO : SELECT @LIMIT = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SELECTED_DATA'
SELECT @LIMIT = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH'

--TO DO : Adjust joined table to get Division Name 
SET @SQL_QUERY = 
'SELECT * FROM (
SELECT DISTINCT TOP ' + @LIMIT + '
	DENSE_RANK() OVER (ORDER BY RPH.CREATED_DT DESC, RPH.CHANGED_DT DESC) AS NUMBER,
	RPH.ROUTINE_NO,
	RPH.PR_DESC,
	RPH.SCH_TYPE_DESC,
	CASE WHEN (RPH.SCH_TYPE = ''D'') THEN ''-'' ELSE RPH.SCH_VALUE END AS SCH_VALUE,
	[dbo].[fn_date_format](RPH.VALID_FROM) AS VALID_FROM,
	dbo.[fn_date_format](RPH.VALID_TO) AS VALID_TO,
	MS.SYSTEM_VALUE AS ACTIVE_FLAG,
	RPH.PR_COORDINATOR,
	RPH.PLANT_CD,
	RPH.SLOC_CD,
	RPH.DIVISION_NAME,
	RPH.CREATED_BY,
	dbo.[fn_date_format](RPH.CREATED_DT) AS CREATED_DT,
	RPH.CREATED_DT AS ORI_CREATED_DT,
	RPH.CHANGED_BY,
	dbo.[fn_date_format](RPH.CHANGED_DT) AS CHANGED_DT,
	RPH.CHANGED_DT AS ORI_CHANGED_DT
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
	OR (isnull(''' + ISNULL(@CREATED_BY,'') + ''', '''') = '''')))
ORDER BY RPH.CREATED_DT DESC, RPH.CHANGED_DT DESC
	)TBL1 WHERE number >= ' + CONVERT(VARCHAR(MAX),@Start) + ' AND number <= ' + CONVERT(VARCHAR(MAX),@Length)
--+ 'ORDER BY CREATED_DT DESC'
EXEC (@SQL_QUERY)
END


