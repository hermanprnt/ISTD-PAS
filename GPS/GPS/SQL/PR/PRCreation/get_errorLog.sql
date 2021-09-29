﻿SELECT TOP 1 
		MESSAGE_ID,
		MESSAGE_CONTENT,
		LOCATION
FROM TB_R_LOG_D 
WHERE PROCESS_ID = @PROCESS_ID 
	  AND MESSAGE_TYPE = 'ERR'
ORDER BY CREATED_DT DESC, SEQ_NO DESC