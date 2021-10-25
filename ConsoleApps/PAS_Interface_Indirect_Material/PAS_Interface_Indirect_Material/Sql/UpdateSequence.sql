﻿DECLARE @@OLD_SEQ INT;

SELECT @@OLD_SEQ = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'BH6011' and SYSTEM_CD = 'SEQ_INTERFACE_FILE' 

UPDATE A
SET A.SYSTEM_VALUE = @@OLD_SEQ + 1
FROM TB_M_SYSTEM A WHERE FUNCTION_ID = 'BH6011' and SYSTEM_CD = 'SEQ_INTERFACE_FILE' 

UPDATE TB 
SET TB.STATUS_CD = '61' 
FROM TB_R_GR_IR TB WHERE MAT_DOC_NO IN (
SELECT DISTINCT MAT_DOC_NO
FROM TB_R_JOURNAL A
WHERE MOV_TYPE IN (
		'101'
		,'102'
		)
	AND DOC_TP = 'GR'
	AND POSTING_CD = 'N'
	)

UPDATE A SET A.POSTING_CD = 'Y'
FROM TB_R_JOURNAL A
WHERE MOV_TYPE IN (
		'101'
		,'102'
		)
	AND DOC_TP = 'GR'
	AND POSTING_CD = 'N'