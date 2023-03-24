SELECT COUNT(1) from
(SELECT DISTINCT mc.*
	FROM TB_R_WBS mc
	JOIN TB_R_SYNCH_EMPLOYEE emp on emp.DIVISION_ID = mc.DIVISION_ID
		WHERE ((mc.WBS_NO  LIKE '%' + @WBS_NO + '%'
		  AND isnull(@WBS_NO, '') <> ''
		  OR (isnull(@WBS_NO, '') = '')))
		AND ((mc.WBS_YEAR = @WBS_YEAR 
		  AND isnull(@WBS_YEAR, '') <> ''
		  OR (isnull(@WBS_YEAR, '') = '')))
		AND ((mc.DIVISION_ID  = @DIVISION_ID
			AND isnull(@DIVISION_ID, '') <> ''
			OR (isnull(@DIVISION_ID, '') = '')))
		AND ((mc.WBS_NAME LIKE '%' + @WBS_NAME + '%'
			AND isnull(@WBS_NAME, '') <> ''
			OR (isnull(@WBS_NAME, '') = '')))
)a