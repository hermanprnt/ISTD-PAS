﻿--SELECT PURCHASING_GRP_CD AS FD_GROUP_CD,
--	   PURCHASING_GRP_DESC AS FD_GROUP_DESC
--FROM TB_M_PURCHASING_GRP

SELECT [COORDINATOR_CD] AS PR_COORDINATOR_CD
      ,[COORDINATOR_DESC] AS PR_COORDINATOR_DESC
  FROM [dbo].[TB_M_COORDINATOR]
  WHERE COOR_FUNCTION='CH'