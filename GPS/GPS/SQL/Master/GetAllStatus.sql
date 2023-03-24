-- Created By   : alira.salman
-- Created Date : 03.03.2015
-- Description  : Get Status module data (TB_M_STATUS).

SELECT *
FROM TB_M_STATUS
WHERE
	DOC_TYPE IN ('PR', 'PO')
ORDER BY STATUS_CD