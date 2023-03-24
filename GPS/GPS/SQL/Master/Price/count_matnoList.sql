SELECT 
	COUNT(1)
FROM (
	SELECT
		A.MAT_NO AS MaterialNo,
		A.MAT_DESC AS MaterialDesc
	FROM TB_M_MATERIAL_PART A
	WHERE
	((A.MAT_NO LIKE '%' + @MAT_NO + '%'
		AND isnull(@MAT_NO, '') <> ''
		OR (isnull(@MAT_NO, '') = '')))
	AND ((A.MAT_DESC LIKE '%' +   @MAT_DESC  + '%'
		AND isnull(@MAT_DESC, '') <> ''
		OR (isnull(@MAT_DESC, '') = '')))
	UNION ALL 
	SELECT
		A.MAT_NO AS MaterialNo,
		A.MAT_DESC AS MaterialDesc
	FROM TB_M_MATERIAL_NONPART A
	WHERE
	((A.MAT_NO LIKE '%' + @MAT_NO + '%'
		AND isnull(@MAT_NO, '') <> ''
		OR (isnull(@MAT_NO, '') = '')))
	AND ((A.MAT_DESC LIKE '%' +   @MAT_DESC  + '%'
		AND isnull(@MAT_DESC, '') <> ''
		OR (isnull(@MAT_DESC, '') = '')))
)UD