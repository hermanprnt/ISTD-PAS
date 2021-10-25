﻿SELECT
    ROW_NUMBER() OVER(ORDER BY SYSTEM_TYPE, SYSTEM_CD) [No],
    SYSTEM_CD [Name], SYSTEM_VALUE_TXT [Value]
FROM dbo.TB_M_SYSTEM WHERE SYSTEM_TYPE = @SystemType AND SYSTEM_CD LIKE @SystemCd