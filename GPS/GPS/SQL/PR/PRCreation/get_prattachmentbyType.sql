SELECT 
	FILE_PATH,
	FILE_EXTENSION,
	[FILE_NAME_ORI],
	SEQ_NO as FILE_SEQ_NO,
	NEW_FLAG
FROM 
	TB_T_ATTACHMENT
WHERE
	CREATED_BY = @USER_ID
AND DOC_NO = @PR_NO
AND DOC_TYPE = @TYPE
AND DELETE_FLAG IS NULL