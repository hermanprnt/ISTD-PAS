﻿SELECT 
	VENDOR_CD,
	VENDOR_NAME,
	VENDOR_CD + ' - ' + VENDOR_NAME AS 'VENDOR_DESC'
FROM TB_M_VENDOR 
ORDER BY VENDOR_NAME