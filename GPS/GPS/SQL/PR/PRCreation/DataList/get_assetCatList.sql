﻿SELECT SYSTEM_VALUE AS ASSET_CATEGORY_DESC,
	   REPLACE(SYSTEM_CD, 'AC_', '')  AS ASSET_CATEGORY_CD
FROM TB_M_SYSTEM 
	WHERE FUNCTION_ID = '20021' AND SYSTEM_CD LIKE 'AC_%'