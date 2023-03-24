SELECT DISTINCT 
	COUNT(*)
FROM TB_M_MATERIAL A
WHERE
((MAT_NO LIKE @MAT_NO + '%'
	AND isnull(@MAT_NO, '') <> ''
	OR (isnull(@MAT_NO, '') = '')))
AND ((MAT_DESC LIKE '%' +   @MAT_DESC  + '%'
	AND isnull(@MAT_DESC, '') <> ''
	OR (isnull(@MAT_DESC, '') = '')))
AND ((CAR_FAMILY_CD LIKE '%' +   @CAR  + '%'
	AND isnull(@CAR, '') <> ''
	OR (isnull(@CAR, '') = '')))
AND ((MAT_TYPE_CD LIKE '%' +   @TYPE  + '%'
	AND isnull(@TYPE, '') <> ''
	OR (isnull(@TYPE, '') = '')))
AND ((MAT_GRP_CD LIKE '%' +   @GRP  + '%'
	AND isnull(@GRP, '') <> ''
	OR (isnull(@GRP, '') = '')))
AND ((VALUATION_CLASS LIKE '%' +   @VALUATION  + '%'
	AND isnull(@VALUATION, '') <> ''
	OR (isnull(@VALUATION, '') = '')))
AND QUOTA_FLAG = 'Y' 