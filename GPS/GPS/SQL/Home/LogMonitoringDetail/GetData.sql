SELECT * FROM (
SELECT SEQ_NO AS SeqNo,
	   CREATED_DT AS CreatedDt,
	   MESSAGE_TYPE AS MessageType,
	   LOCATION AS Location,
	   MESSAGE_CONTENT AS MessageContent
FROM TB_R_LOG_D
	WHERE PROCESS_ID = @ProcessId
)tbl WHERE tbl.SeqNo >= @Start AND tbl.SeqNo <= @Length