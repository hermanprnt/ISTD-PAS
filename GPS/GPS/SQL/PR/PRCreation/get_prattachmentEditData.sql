SELECT 
	FILE_PATH,
	FILE_EXTENSION,
	[FILE_NAME_ORI],
	SEQ_NO as FILE_SEQ_NO,
	DOC_TYPE,
	FILE_SIZE
FROM 
	TB_T_ATTACHMENT
WHERE
	PROCESS_ID = @PROCESS_ID
AND DOC_NO = @PR_NO
AND  ISNULL(DELETE_FLAG, 'N') = 'N'