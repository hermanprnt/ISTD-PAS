﻿
UPDATE A
SET A.SYSTEM_REMARK = @filename
FROM TB_M_SYSTEM A WHERE FUNCTION_ID = 'BH6011' and SYSTEM_CD = 'INTERFACE_FILENAME' 
