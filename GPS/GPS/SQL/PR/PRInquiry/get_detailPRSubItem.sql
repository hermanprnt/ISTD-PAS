﻿DECLARE @@ITEM_NO VARCHAR(8)

SELECT @@ITEM_NO = REPLICATE('0', 5-LEN(@PR_ITEM_NO)) + @PR_ITEM_NO
SELECT DISTINCT
	  CAST(CAST(A.[PR_SUBITEM_NO] AS INT) AS VARCHAR) AS SUBITEM_NO
	  ,CAST(CAST(A.PR_ITEM_NO AS INT) AS VARCHAR) AS ITEM_NO
      ,A.[MAT_DESC] AS SUBITEM_MAT_DESC
      ,A.[COST_CENTER_CD] AS SUBITEM_COST_CENTER
	  ,C.[COST_CENTER_DESC] AS SUBITEM_COST_CENTER_DESC
      ,A.[WBS_NO] AS SUBITEM_WBS_NO
      ,A.[GL_ACCOUNT] AS SUBITEM_GL_ACCOUNT
	  ,B.[GL_ACCOUNT_DESC] AS SUBITEM_GL_ACCOUNT_DESC
      ,A.[SUBITEM_QTY] AS SUBITEM_QTY
      ,A.[SUBITEM_UOM]
      ,A.[PRICE_PER_UOM] AS PRICE_PER_UOM
      ,A.[ORI_AMOUNT] AS SUBITEM_AMOUNT
	  ,A.[LOCAL_AMOUNT] AS SUBITEM_LOCAL_AMOUNT
FROM TB_R_PR_SUBITEM A
LEFT JOIN TB_M_GL_ACCOUNT B
	ON A.GL_ACCOUNT = B.GL_ACCOUNT_CD
LEFT JOIN TB_M_COST_CENTER C
	ON A.COST_CENTER_CD = C.COST_CENTER_CD
WHERE A.PR_ITEM_NO = @@ITEM_NO AND PR_NO = @PR_NO
ORDER BY CAST(CAST(A.[PR_SUBITEM_NO] AS INT) AS VARCHAR)