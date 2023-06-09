﻿SELECT SEQ_NO AS SeqNo,
	   MESSAGE_TYPE AS MessageType,
	   LOCATION AS Location,
	   MESSAGE_CONTENT AS MessageContent,
	   CREATED_BY AS CreatedBy,
	   CREATED_DT AS CreatedDt,
	   CHANGED_BY AS ChangedBy,
	   CHANGED_DT AS ChangedDt
FROM TB_R_LOG_D WHERE PROCESS_ID = @ProcessId
	ORDER BY SEQ_NO ASC