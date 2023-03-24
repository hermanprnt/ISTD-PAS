IF(@Param = '') --IF Query called from screen Vendor Master
BEGIN
	DECLARE @@WbsParamSystem VARCHAR (10) = (SELECT TOP 1 ISNULL(SYSTEM_VALUE,'') FROM TB_M_SYSTEM WHERE FUNCTION_ID='ASSET' AND SYSTEM_CD='WBS_PARAM')
	IF @wbsno LIKE CONCAT(@@WbsParamSystem,'%')
	BEGIN
	SELECT COUNT(*) FROM (
			 SELECT ASSET_NO
			,SUB_ASSET_NO
			,ASSET_CATEGORY
			,CLASS_ID
			,LOCATION_ID
			,ASSET_DESC
			,DIVISION_ID_HR
			,COST_CENTER
			,CREATED_DATE 
			,WBS_NO
			FROM [FAMS_DB_SAPAHANA].[FAMS_DB_SAPHANA].[dbo].[VIEW_PAS_GET_LIST_ASSET]
			WHERE ((DIVISION_ID_HR LIKE '%' + ISNULL(@DIVISION_PARAM, '') + '%'
					AND ASSET_CATEGORY NOT LIKE '%AU%'
					AND isnull(@DIVISION_PARAM, '') <> ''
					OR (isnull(@DIVISION_PARAM, '') = '')))
				/* FID.Ridwan: 20220712*/
				AND WBS_NO = ISNULL(@wbsno, '') 
		  UNION
		  SELECT ASSET_NO
			,SUB_ASSET_NO
			,ASSET_CATEGORY
			,CLASS_ID
			,LOCATION_ID
			,ASSET_DESC
			,DIVISION_ID_HR
			,COST_CENTER
			,CREATED_DATE 
			,WBS_NO
			FROM [FAMS_DB_SAPAHANA].[FAMS_DB_SAPHANA].[dbo].[VIEW_PAS_GET_LIST_ASSET]
			WHERE ((DIVISION_ID_HR LIKE '%' + ISNULL(@DIVISION_PARAM, '') + '%'
					AND ASSET_CATEGORY LIKE '%AU%'
					AND isnull(@DIVISION_PARAM, '') <> ''
					OR (isnull(@DIVISION_PARAM, '') = '')))
				/* FID.Ridwan: 20220712*/
				AND LEFT(WBS_NO,8) = ISNULL(LEFT(@wbsno,8), '')
	) tbl 
	END
	ELSE
	BEGIN
		
		  SELECT  COUNT(*)	  
			  FROM [FAMS_DB_SAPAHANA].[FAMS_DB_SAPHANA].[dbo].[VIEW_PAS_GET_LIST_ASSET]
			WHERE ((DIVISION_ID_HR LIKE '%' + ISNULL(@DIVISION_PARAM, '') + '%'
					AND ASSET_CATEGORY LIKE '%AU%'
					AND isnull(@DIVISION_PARAM, '') <> ''
					OR (isnull(@DIVISION_PARAM, '') = '')))
				/* FID.Ridwan: 20220712*/
				AND LEFT(WBS_NO,8) = ISNULL(LEFT(@wbsno,8), '')
	END

END
ELSE --if Query Called from other controller (ex: for retrieve dropdown data)
BEGIN
		SELECT COUNT(*)
			 FROM [FAMS_DB_SAPAHANA].[FAMS_DB_SAPHANA].[dbo].[VIEW_PAS_GET_LIST_ASSET]
			WHERE (((ASSET_NO LIKE '%' + ISNULL(@Param, '') + '%'
					AND isnull(@Param, '') <> ''
					OR (isnull(@Param, '') = '')))
				AND ((DIVISION_ID_HR LIKE '%' + ISNULL(@DIVISION_PARAM, '') + '%'
					AND isnull(@DIVISION_PARAM, '') <> ''
					OR (isnull(@DIVISION_PARAM, '') = '')))
				/* FID.Ridwan: 20220712*/
				AND (ISNULL(@wbsno, '') = '' OR WBS_NO = ISNULL(@wbsno, '') )
			)

END


