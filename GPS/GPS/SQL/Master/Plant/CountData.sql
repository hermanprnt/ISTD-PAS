SELECT 
	COUNT(1)
FROM TB_M_PLANT
WHERE ((PLANT_CD LIKE '%' + ISNULL(@PlantCd, '') + '%'
			AND isnull(@PlantCd, '') <> ''
			OR (isnull(@PlantCd, '') = '')))
	AND ((PLANT_NAME LIKE '%' + ISNULL(@PlantName, '') + '%'
			AND isnull(@PlantName, '') <> ''
			OR (isnull(@PlantName, '') = '')))