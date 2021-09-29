-- Created By   : alira.salman
-- Created Date : 12.03.2015
-- Description  : Get Document Status (TB_M_STATUS).

SELECT *
FROM TB_M_STATUS
WHERE
	DOC_TYPE IN ('DOC')
ORDER BY STATUS_CD