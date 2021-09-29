-- Created By   : alira.salman
-- Created Date : 12.03.2015
-- Description  : Get Detail Status (TB_M_STATUS).
-- SEGMENTATION_CD 9 is for Document Status.

SELECT *
FROM TB_M_STATUS
WHERE
	DOC_TYPE IN ('PR', 'PO')
	AND SEGMENTATION_CD <> 9
ORDER BY STATUS_CD