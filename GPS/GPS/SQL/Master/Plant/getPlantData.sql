SELECT * FROM (
	SELECT 
		ROW_NUMBER() OVER(ORDER BY PLANT_CD ASC) AS Number,
		PLANT_CD, 
		PLANT_NAME, 
		CREATED_BY, 
		dbo.fn_date_format(CREATED_DT) AS CREATED_DT,
		CHANGED_BY,
		dbo.fn_date_format(CHANGED_DT) AS CHANGED_DT
	FROM TB_M_PLANT
	WHERE ((PLANT_CD LIKE '%' + ISNULL(@PlantCd, '') + '%'
				AND isnull(@PlantCd, '') <> ''
				OR (isnull(@PlantCd, '') = '')))
	  AND ((PLANT_NAME LIKE '%' + ISNULL(@PlantName, '') + '%'
				AND isnull(@PlantName, '') <> ''
				OR (isnull(@PlantName, '') = '')))
) tbl WHERE tbl.Number >= @Start AND tbl.Number <= @Length