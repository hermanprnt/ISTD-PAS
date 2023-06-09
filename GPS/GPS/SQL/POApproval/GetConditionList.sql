﻿SELECT * FROM (
SELECT ROW_NUMBER() OVER (ORDER BY A.PR_ITEM_NO ASC) AS NUMBER,
	   A.PO_NO DOC_NO, 
	   A.PO_ITEM_NO DOC_ITEM_NO,
       A.PR_NO,
       A.PR_ITEM_NO ITEM_NO,
	   A.MAT_NO, 
	   A.MAT_DESC, 
	   B.COMP_PRICE_CD,
	   C.COMP_PRICE_DESC,
	   D.SYSTEM_REMARK CONDITION_TYPE,
	   B.QTY_PER_UOM QTY,
	   COMP_PRICE_RATE EXCHANGE_RATE,
	   B.PRICE_AMT AMOUNT,
	   B.COMP_TYPE
	FROM TB_R_PO_ITEM A 
		JOIN TB_R_PO_CONDITION B ON A.PO_NO = B.PO_NO AND A.PO_ITEM_NO = B.PO_ITEM_NO
		JOIN TB_M_COMP_PRICE C ON B.COMP_PRICE_CD = C.COMP_PRICE_CD
		JOIN TB_M_SYSTEM D ON B.CALCULATION_TYPE = D.SYSTEM_VALUE AND D.FUNCTION_ID = '114001' AND D.SYSTEM_CD LIKE 'CALCULATION_TYPE_%'
		AND A.PO_NO = @DOC_NO
) A WHERE A.NUMBER >= (((@pageIndex - 1) * @pageSize) + 1)