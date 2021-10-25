﻿UPDATE [BMS_DB].[BMS_DB].[dbo].[TB_R_BUDGET_CONTROL_H] 
	SET NON_SAP_FLAG = CASE WHEN(@FROM_TYPE = 'SAP') THEN 'Y' ELSE NULL END,
		CHANGED_BY = @USER_ID,
		CHANGED_DT = GETDATE()
WHERE (WBS_YEAR = @WBS_YEAR OR WBS_YEAR = '9999') AND @WBS_NO LIKE '%' + WBS_NO + '%'