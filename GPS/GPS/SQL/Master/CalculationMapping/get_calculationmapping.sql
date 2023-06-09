﻿SELECT * FROM (
	SELECT DISTINCT DENSE_RANK() OVER (ORDER BY A.CREATED_DT DESC) AS Number,
	   A.CALCULATION_SCHEME_CD,
	   A.STATUS,
	   CASE WHEN ISNULL(A.CALCULATION_SCHEME_DESC, '') = '' THEN '<no description>' ELSE A.CALCULATION_SCHEME_DESC END AS CALCULATION_SCHEME_DESC
	FROM TB_M_CALCULATION_SCHEME A
		LEFT JOIN TB_M_CALCULATION_MAPPING B
		ON A.CALCULATION_SCHEME_CD = B.CALCULATION_SCHEME_CD
	WHERE ((A.CALCULATION_SCHEME_CD LIKE '%' + @CALCULATION_SCHEME_CD + '%'
		  AND isnull(@CALCULATION_SCHEME_CD, '') <> ''
		  OR (isnull(@CALCULATION_SCHEME_CD, '') = '')))
	AND ((A.CALCULATION_SCHEME_DESC LIKE '%' + @CALCULATION_SCHEME_DESC + '%'
		AND isnull(@CALCULATION_SCHEME_DESC, '') <> ''
		OR (isnull(@CALCULATION_SCHEME_DESC, '') = '')))
	AND (((B.COMP_PRICE_CD LIKE '%' + @COMP_PRICE_CD + '%'
		AND isnull(@COMP_PRICE_CD, '') <> ''
		OR (isnull(@COMP_PRICE_CD, '') = '')))
	OR ((B.COMP_PRICE_TEXT LIKE '%' + @COMP_PRICE_CD + '%'
		AND isnull(@COMP_PRICE_CD, '') <> ''
		OR (isnull(@COMP_PRICE_CD, '') = ''))))
	AND ((B.INVENTORY_FLAG = @INVENTORY_FLAG
		AND isnull(@INVENTORY_FLAG, '') <> ''
		OR (isnull(@INVENTORY_FLAG, '') = '')))
	AND ((B.ACCRUAL_FLAG_TYPE = @ACCRUAL_FLAG_TYPE
		AND isnull(@ACCRUAL_FLAG_TYPE, '') <> ''
		OR (isnull(@ACCRUAL_FLAG_TYPE, '') = '')))
	AND ((B.CONDITION_RULE = @CONDITION_RULE
		AND isnull(@CONDITION_RULE, '') <> ''
		OR (isnull(@CONDITION_RULE, '') = '')))
)data WHERE data.Number >= @Start AND data.Number <= @Length