﻿SELECT PROCESS_ID
	,ROW_NO
	,DOCUMENT_NO
	,DOCUMENT_LINE_ITEM_NO
	,FUND_DOCUMENT_DOC_NO
	,FUND_DOCUMENT_DOC_LINE_ITEM
	,MESSAGE_TYPE
	,MESSAGE_ID
	,MESSAGE_NO
	,MESSAGE_MESSAGE
	,PROCESSED_BY
	,PROCESSED_DT
FROM TB_H_FUND_COMMITMENT_RESPONSE
WHERE PROCESS_ID = @ProcessId