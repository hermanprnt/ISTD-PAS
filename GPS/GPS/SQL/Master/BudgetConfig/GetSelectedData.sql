﻿SELECT DISTINCT
	WBS_NO,
    WBS_NAME,
	WBS_YEAR,
	PROJECT_NO as 'WBS_TYPE',
	wbs.DIVISION_ID, 
	emp.DIVISION_NAME as 'DIVISION_DESC'
FROM TB_R_WBS wbs
JOIN TB_R_SYNCH_EMPLOYEE emp on wbs.DIVISION_ID = emp.DIVISION_ID
WHERE WBS_NO = @WbsNo