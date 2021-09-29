SELECT COUNT(DISTINCT VALUATION_CLASS) FROM TB_M_VALUATION_CLASS
WHERE
(((VALUATION_CLASS LIKE '%' + @PARAM + '%'
	AND isnull(@PARAM, '') <> ''
	OR (isnull(@PARAM, '') = '')))
OR ((VALUATION_CLASS_DESC LIKE '%' + @PARAM  + '%'
	AND isnull(@PARAM, '') <> ''
	OR (isnull(@PARAM, '') = ''))))
