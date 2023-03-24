SELECT * FROM (
	SELECT DISTINCT
		   DENSE_RANK() OVER (ORDER BY mc.WBS_NO ASC) AS Number,
			mc.WBS_NO,
			mc.WBS_NAME,
			mc.WBS_YEAR,
			mc.DIVISION_ID,
		 	emp.DIVISION_NAME as 'DIVISION_DESC',
			mc.PROJECT_NO as 'WBS_TYPE',        /*PROJECT_NO*/
			mc.CREATED_BY,
			mc.CREATED_DT,
			mc.CHANGED_BY,
			mc.CHANGED_DT
	FROM TB_R_WBS mc
	JOIN TB_R_SYNCH_EMPLOYEE emp on emp.DIVISION_ID = mc.DIVISION_ID
		WHERE ((mc.WBS_NO  LIKE '%' + @WBS_NO + '%'
		  AND isnull(@WBS_NO, '') <> ''
		  OR (isnull(@WBS_NO, '') = '')))
		AND ((mc.WBS_YEAR LIKE '%' + @WBS_YEAR + '%'
		  AND isnull(@WBS_YEAR, '') <> ''
		  OR (isnull(@WBS_YEAR, '') = '')))
		AND ((mc.WBS_NAME LIKE '%' + @WBS_NAME + '%'
			AND isnull(@WBS_NAME, '') <> ''
			OR (isnull(@WBS_NAME, '') = '')))
) tbl WHERE tbl.Number >= @Start AND tbl.Number <= @Length