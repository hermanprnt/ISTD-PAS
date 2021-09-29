UPDATE TB_T_PR_SUBITEM
	SET DELETE_FLAG = 'Y',
	    NEW_AMOUNT = 0,
		NEW_LOCAL_AMOUNT = 0
	WHERE PROCESS_ID = @PROCESS_ID
	AND ITEM_NO NOT IN (SELECT ITEM_NO FROM TB_T_PR_ITEM WHERE PROCESS_ID = @PROCESS_ID)

SELECT A.[PROCESS_ID]
      ,A.[ITEM_NO]
      ,A.[ITEM_TYPE]
	  ,A.[ITEM_CLASS]
      ,A.[IS_PARENT]
      ,A.[PROCUREMENT_PURPOSE]
      ,CASE WHEN(A.[MAT_NO] <> 'X') THEN A.[MAT_NO] ELSE '' END AS MAT_NUMBER
      ,A.[MAT_DESC]
      ,A.[COST_CENTER_CD] AS COST_CENTER
      ,A.[WBS_NO]
	  ,A.[WBS_NAME]
      ,A.[GL_ACCOUNT] AS GL_ACCOUNT_CD
      ,A.[VALUATION_CLASS]
      ,A.[VALUATION_CLASS_DESC]
      ,A.[SOURCE_TYPE]
      ,A.[PACKING_TYPE]
      ,A.[PART_COLOR_SFX]
      ,A.[SPECIAL_PROC_TYPE]
      ,A.[CAR_FAMILY_CD]
      ,A.[MAT_TYPE_CD]
      ,A.[MAT_GRP_CD]
      ,A.[NEW_ITEM_QTY] AS QTY
      ,A.[ITEM_UOM] AS UOM
	  ,B.[CALC_VALUE]
      ,A.[ORI_CURR_CD] AS CURR
      ,A.[NEW_PRICE_PER_UOM] AS PRICE_PER_UOM
      ,A.[NEW_AMOUNT] AS AMOUNT
      ,A.[LOCAL_CURR_CD]
      ,A.[EXCHANGE_RATE]
      ,A.[NEW_LOCAL_AMOUNT] AS LOCAL_AMOUNT
      ,[dbo].[fn_date_format](A.[DELIVERY_PLAN_DT]) AS DELIVERY_DATE_ITEM
      ,A.[VENDOR_CD]
      ,A.[VENDOR_NAME]
      ,A.[QUOTA_FLAG]
	  ,A.[ASSET_CATEGORY] AS ASSET_CATEGORY_CD
	  ,C.[SYSTEM_VALUE] AS ASSET_CATEGORY_DESC
	  ,A.[ASSET_CLASS]
	  ,A.[ASSET_LOCATION]
	  ,A.[ASSET_NO]
	  ,D.[MAT_NO] AS PRICE_EXIST
	  ,CASE WHEN((G.PROCESS_ID <> @PROCESS_ID) AND G.PROCESS_ID IS NOT NULL) THEN G.[USER_NAME] ELSE NULL END AS LOCKED_BY
	  ,CASE WHEN(F.PR_STATUS = '14') THEN A.[OPEN_QTY] ELSE 1 END AS OPEN_QTY
	  ,A.[USED_QTY]
FROM [dbo].[TB_T_PR_ITEM] A
	LEFT JOIN TB_M_SYSTEM C
		ON C.FUNCTION_ID = '20021' AND C.SYSTEM_CD LIKE '%' + A.[ASSET_CATEGORY]
	LEFT JOIN TB_M_UNIT_OF_MEASURE B
		ON A.ITEM_UOM = B.UNIT_OF_MEASURE_CD
	LEFT JOIN TB_M_MATERIAL_PRICE D 
		ON A.MAT_NO = D.MAT_NO AND GETDATE() BETWEEN D.VALID_DT_FROM AND D.VALID_DT_TO
	LEFT JOIN TB_R_PR_H E
		ON A.PROCESS_ID = E.PROCESS_ID
	LEFT JOIN TB_R_PR_ITEM F 
		ON E.PR_NO = F.PR_NO AND F.PR_ITEM_NO = A.ITEM_NO
	LEFT JOIN TB_T_LOCK G
		ON F.PROCESS_ID = G.PROCESS_ID
	WHERE A.PROCESS_ID = @PROCESS_ID
	AND ISNULL(A.DELETE_FLAG, 'N') <> 'Y'
	ORDER BY A.ITEM_NO