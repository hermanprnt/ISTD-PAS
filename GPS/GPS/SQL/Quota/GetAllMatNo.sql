SELECT * FROM(
SELECT DISTINCT 
	DENSE_RANK() OVER (ORDER BY MAT_NO ASC) AS number, 
	MAT_NO AS MAT_NO,
	MAT_DESC AS MAT_DESC,
	ISNULL(CAR_FAMILY_CD,'') as CAR_FAMILY_CD,
	--CAR_FAMILY_CD as CAR_FAMILY_DESC,
	ISNULL(MAT_TYPE_CD,'') as MAT_TYPE_CD,
	--MAT_TYPE_CD as MAT_TYPE_DESC,
	ISNULL(MAT_GRP_CD,'') as MAT_GRP_CD,
	--MAT_GRP_CD as MAT_GRP_DESC,
	ISNULL(UOM,'') as UOM,
	--UOM as UOM_DESC,
	ISNULL(VALUATION_CLASS,'') as VALUATION_CLASS
FROM TB_M_MATERIAL 
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
) TBL1
WHERE number >= @start AND number <= @length