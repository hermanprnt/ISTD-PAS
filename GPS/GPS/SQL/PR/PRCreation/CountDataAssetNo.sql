IF(@Param = '')
BEGIN
	SELECT COUNT(1)
	FROM [FAMS_DB].[FAMS_DB].[dbo].[GET_LIST_ASSET]
		WHERE ((DIVISION_ID_HR LIKE '%' + ISNULL(@DIVISION_PARAM, '') + '%'
					AND isnull(@DIVISION_PARAM, '') <> ''
					OR (isnull(@DIVISION_PARAM, '') = '')))
				/* FID.Ridwan: 20220712*/
				AND (ISNULL(@wbsno, '') = '' OR WBS_NO = ISNULL(@wbsno, '') )
END
ELSE
BEGIN
	SELECT COUNT(1)
	FROM [FAMS_DB].[FAMS_DB].[dbo].[GET_LIST_ASSET]
		WHERE (((ASSET_NO LIKE '%' + ISNULL(@Param, '') + '%'
					AND isnull(@Param, '') <> ''
					OR (isnull(@Param, '') = '')))
				AND ((DIVISION_ID_HR LIKE '%' + ISNULL(@DIVISION_PARAM, '') + '%'
					AND isnull(@DIVISION_PARAM, '') <> ''
					OR (isnull(@DIVISION_PARAM, '') = '')))
					)
				/* FID.Ridwan: 20220712*/
				AND (ISNULL(@wbsno, '') = '' OR WBS_NO = ISNULL(@wbsno, '') )
END