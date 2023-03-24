﻿SELECT * FROM (
SELECT DISTINCT
	DENSE_RANK() OVER (ORDER BY RPI.ITEM_NO ASC) AS number, 
	RPI.ROUTINE_NO,
	RPI.ITEM_NO,
	RPI.IS_PARENT,
	RPI.ITEM_CLASS,
	RPI.VALUATION_CLASS,
	RPI.MAT_NO,
	RPI.MAT_DESC,
	RPI.PR_QTY AS QTY,
	RPI.UNIT_OF_MEASURE_CD AS UOM,
	RPI.ORI_CURR_CD AS CURR,
	RPI.PRICE_PER_UOM AS PRICE,
	RPI.ORI_AMOUNT AS AMOUNT,
	RPI.WBS_NO,
	RPI.GL_ACCOUNT AS GL_ACCOUNT_CD,
	RPI.VENDOR_NAME
FROM TB_M_ROUTINE_PR_ITEM RPI
WHERE RPI.ROUTINE_NO = @ROUTINE_NO) TBL1
WHERE number >= @start AND number <= @length