SELECT * FROM (
SELECT DISTINCT 
	DENSE_RANK() OVER (ORDER BY VALUATION_CLASS ASC) AS number, 
	ITEM_CLASS,
	ITEM_TYPE,
	VALUATION_CLASS, 
	VALUATION_CLASS_DESC,
	AREA_DESC
FROM TB_M_VALUATION_CLASS
WHERE
(((VALUATION_CLASS LIKE '%' +  @PARAM + '%'
	AND isnull(@PARAM, '') <> ''
	OR (isnull(@PARAM, '') = '')))
OR ((VALUATION_CLASS_DESC LIKE '%' + @PARAM  + '%'
	AND isnull(@PARAM, '') <> ''
	OR (isnull(@PARAM, '') = ''))))
) tbl1
WHERE number >= @start AND number <= @length