﻿--SELECT PURCHASING_GRP_CD,
--	   PURCHASING_GRP_DESC
--FROM TB_M_PURCHASING_GRP

SELECT [COORDINATOR_CD] AS PURCHASING_GRP_CD
      ,[COORDINATOR_DESC] AS PURCHASING_GRP_DESC
  FROM [dbo].[TB_M_COORDINATOR]
  WHERE COOR_FUNCTION='PG'