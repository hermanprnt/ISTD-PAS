IF(@Param = '') --IF Query called from screen Vendor Master
BEGIN
	SELECT * FROM (
		SELECT  ROW_NUMBER() OVER (ORDER BY [ASSET_NO] DESC) AS Number
				  ,[ASSET_NO]
				  ,[SUB_ASSET_NO]
				  ,[ASSET_CATEGORY]
				  ,[CLASS_ID]
				  ,[LOCATION_ID]
				  ,[ASSET_DESC]
				  ,[CREATED_BY]
				  ,CONVERT(VARCHAR(10),[CREATED_DATE],23) AS [CREATED_DATE]
				  
			  FROM [FAMS_DB].[FAMS_DB].[dbo].[GET_LIST_ASSET]
			WHERE ((DIVISION_ID_HR LIKE '%' + ISNULL(@DIVISION_PARAM, '') + '%'
					AND isnull(@DIVISION_PARAM, '') <> ''
					OR (isnull(@DIVISION_PARAM, '') = '')))
	) tbl WHERE tbl.Number >= @Start AND tbl.Number <= @Length

END
ELSE --if Query Called from other controller (ex: for retrieve dropdown data)
BEGIN
		SELECT * FROM (
		SELECT  ROW_NUMBER() OVER (ORDER BY [ASSET_NO] DESC) AS Number
				  ,[ASSET_NO]
				  ,[SUB_ASSET_NO]
				  ,[ASSET_CATEGORY]
				  ,[CLASS_ID]
				  ,[LOCATION_ID]
				  ,[ASSET_DESC]
				  ,[CREATED_BY]
				  ,CONVERT(VARCHAR(10),[CREATED_DATE],23) AS [CREATED_DATE]
			  FROM [FAMS_DB].[FAMS_DB].[dbo].[GET_LIST_ASSET]
			WHERE (((ASSET_NO LIKE '%' + ISNULL(@Param, '') + '%'
					AND isnull(@Param, '') <> ''
					OR (isnull(@Param, '') = '')))
				AND ((DIVISION_ID_HR LIKE '%' + ISNULL(@DIVISION_PARAM, '') + '%'
					AND isnull(@DIVISION_PARAM, '') <> ''
					OR (isnull(@DIVISION_PARAM, '') = '')))
			)
	) tbl WHERE tbl.Number >= @Start AND tbl.Number <= @Length

END