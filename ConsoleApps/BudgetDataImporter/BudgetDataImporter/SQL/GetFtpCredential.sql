﻿SELECT
	(SELECT SYSTEM_VALUE_TXT FROM dbo.TB_M_SYSTEM WHERE SYSTEM_TYPE = 'BUDGET_CONTROL' AND SYSTEM_CD = 'FTP_URL_OUT') + ';' +
	(SELECT SYSTEM_VALUE_TXT FROM dbo.TB_M_SYSTEM WHERE SYSTEM_TYPE = 'BUDGET_CONTROL' AND SYSTEM_CD = 'FTP_URL_ARC') + ';' +
    (SELECT SYSTEM_VALUE_TXT FROM dbo.TB_M_SYSTEM WHERE SYSTEM_TYPE = 'BUDGET_CONTROL' AND SYSTEM_CD = 'FTP_UNAME') + ';' +
    (SELECT SYSTEM_VALUE_TXT FROM dbo.TB_M_SYSTEM WHERE SYSTEM_TYPE = 'BUDGET_CONTROL' AND SYSTEM_CD = 'FTP_PASSW') 