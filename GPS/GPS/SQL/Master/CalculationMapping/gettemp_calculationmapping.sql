﻿IF(@SETGET = 1)
BEGIN
	INSERT INTO [dbo].[TB_T_CALCULATION_MAPPING]
			   ([PROCESS_ID]
			   ,[COMP_PRICE_CD]
			   ,[ITEM_STATUS]
			   ,[SEQ_NO]
			   ,[COMP_PRICE_TEXT]
			   ,[BASE_VALUE_FROM]
			   ,[BASE_VALUE_TO]
			   ,[INVENTORY_FLAG]
			   ,[QTY_PER_UOM]
			   ,[CALCULATION_TYPE]
			   ,[PLUS_MINUS_FLAG]
			   ,[CONDITION_CATEGORY]
			   ,[ACCRUAL_FLAG_TYPE]
			   ,[CONDITION_RULE]
			   ,[CREATED_BY]
			   ,[CREATED_DT]
			   ,[CHANGED_BY]
			   ,[CHANGED_DT])
	SELECT @PROCESS_ID,
		   COMP_PRICE_CD,
		   ITEM_STATUS,
		   SEQ_NO,
		   COMP_PRICE_TEXT,
		   BASE_VALUE_FROM,
		   BASE_VALUE_TO,
		   INVENTORY_FLAG,
		   QTY_PER_UOM,
		   CALCULATION_TYPE,
		   PLUS_MINUS_FLAG,
		   CONDITION_CATEGORY,
		   ACCRUAL_FLAG_TYPE,
		   CONDITION_RULE,
		   CREATED_BY,
		   CREATED_DT,
		   CHANGED_BY,
		   CHANGED_DT
	FROM TB_M_CALCULATION_MAPPING
		WHERE CALCULATION_SCHEME_CD = @CALCULATION_SCHEME_CD
END

SELECT A.[PROCESS_ID]
        ,A.[COMP_PRICE_CD]
        ,A.[ITEM_STATUS]
        ,ROW_NUMBER() OVER (ORDER BY A.SEQ_NO ASC) AS SEQ_NO
        ,A.[COMP_PRICE_TEXT]
        ,A.[BASE_VALUE_FROM]
        ,A.[BASE_VALUE_TO]
        ,A.[INVENTORY_FLAG]
        ,A.[QTY_PER_UOM]
        ,A.[CALCULATION_TYPE]
        ,A.[PLUS_MINUS_FLAG]
		,C.[SYSTEM_REMARK] AS PLUS_MINUS_SIGN
		,A.[CONDITION_CATEGORY] AS CONDITION_CATEGORY_CD
        ,CASE WHEN (A.[CONDITION_CATEGORY] = 'H') THEN 'Base Value' ELSE 'Additional Value' END AS CONDITION_CATEGORY
        ,A.[ACCRUAL_FLAG_TYPE]
        ,A.[CONDITION_RULE]
        ,A.[CREATED_BY]
        ,A.[CREATED_DT]
        ,A.[CHANGED_BY]
        ,A.[CHANGED_DT]
		,B.[SYSTEM_REMARK] AS CALCULATION_TYPE_DESC
FROM TB_T_CALCULATION_MAPPING A
	 INNER JOIN TB_M_SYSTEM B 
ON A.PROCESS_ID = @PROCESS_ID
   AND A.CALCULATION_TYPE = B.SYSTEM_VALUE AND B.FUNCTION_ID = '114001' AND B.SYSTEM_CD LIKE 'CALCULATION_TYPE_%'
	 INNER JOIN TB_M_SYSTEM C
ON A.PLUS_MINUS_FLAG = C.SYSTEM_VALUE AND C.FUNCTION_ID = '114001' AND C.SYSTEM_CD LIKE 'PLUS_MINUS_FLAG_%'
   AND A.DELETE_FLAG IS NULL
		ORDER BY A.SEQ_NO