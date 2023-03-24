SELECT * FROM (
	SELECT DISTINCT
		   DENSE_RANK() OVER (ORDER BY mc.WBS_NO ASC) AS Number,
			mc.WBS_NO,
			mc.WBS_NAME,
			mc.WBS_YEAR,
			mc.DIVISION_ID,
			emp.DIVISION_NAME as 'DIVISION_DESC',
			PROJECT_NO as 'WBS_TYPE',        /*PROJECT_NO*/
			mc.CREATED_BY,
			[dbo].[fn_date_format](mc.CREATED_DT) AS 'CREATED_DT',
			mc.CHANGED_BY,
			[dbo].[fn_date_format](mc.CHANGED_DT) as 'CHANGED_DT'
	FROM TB_R_WBS mc
	JOIN TB_R_SYNCH_EMPLOYEE emp on mc.DIVISION_ID = emp.DIVISION_ID
		WHERE ((mc.WBS_NO  LIKE '%' + @WBS_NO + '%'
		  AND isnull(@WBS_NO, '') <> ''
		  OR (isnull(@WBS_NO, '') = '')))
		AND ((mc.WBS_YEAR = @WBS_YEAR
		  AND isnull(@WBS_YEAR, '') <> ''
		  OR (isnull(@WBS_YEAR, '') = '')))
		AND ((mc.DIVISION_ID = @DIVISION_ID
			AND isnull(@DIVISION_ID, '') <> ''
			OR (isnull(@DIVISION_ID, '') = '')))
		AND ((mc.WBS_NAME LIKE '%' + @WBS_NAME + '%'
			AND isnull(@WBS_NAME, '') <> ''
			OR (isnull(@WBS_NAME, '') = '')))
) tbl WHERE tbl.Number >= @Start AND tbl.Number <= @Length