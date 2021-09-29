-- ===================================================================
-- Author		: FID) Intan Puspitasari
-- Create date	: 04/05/2016
-- Description	: Select PR Asset data by given search criteria 
-- ===================================================================
ALTER PROCEDURE [dbo].[sp_asset_getList] 
		@PR_NO VARCHAR(MAX), 
		@PR_STATUS VARCHAR(2),
		@ITEM_NO VARCHAR(MAX),
		@ASSET_NO VARCHAR(MAX),
		@ASSET_CATEGORY VARCHAR(MAX),
		@SUBASSET_NO VARCHAR(MAX),
		@ASSET_CLASS VARCHAR(MAX),
		@REGISTER_DT_FROM VARCHAR(MAX),
		@REGISTER_DT_TO VARCHAR(MAX),
		@Start INT, 
		@Length INT
AS
BEGIN
DECLARE @SQL_QUERY VARCHAR(MAX),
		@LIMIT VARCHAR(10)

SELECT @LIMIT = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH'

SET @SQL_QUERY = 
'SELECT * FROM (
SELECT DISTINCT TOP ' + @LIMIT + '
	DENSE_RANK() OVER (ORDER BY A.REGISTRATION_DT DESC, A.PR_NO ASC, A.PR_ITEM_NO ASC, A.SEQ_NO ASC) AS NUMBER
	,A.PR_NO
	,A.PR_ITEM_NO AS ITEM_NO
    ,A.SEQ_NO
    ,PRH.PR_DESC AS DESCRIPTION
    ,[dbo].[fn_date_format] (A.REGISTRATION_DT) AS REGISTRATION_DATE
	,A.REGISTRATION_DT
    ,A.ASSET_CLASS
    ,A.ASSET_LOCATION
    ,A.ASSET_NO
    ,A.SUB_ASSET_NO AS SUBASSET_NO
    ,A.SERIAL_NO
    ,A.CREATED_BY
    ,[dbo].[fn_date_format] (A.CREATED_DT) AS CREATED_DT
    ,A.CHANGED_BY
    ,[dbo].[fn_date_format] (A.CHANGED_DT) AS CHANGED_DT
FROM TB_R_ASSET A JOIN TB_R_PR_H PRH ON A.PR_NO = PRH.PR_NO
WHERE
	((A.PR_NO LIKE ''%' + ISNULL(@PR_NO,'') + '%'' 
	AND isnull(''' + ISNULL(@PR_NO,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@PR_NO,'') + ''', '''') = '''')))
AND ((PRH.PR_STATUS = ''' + ISNULL(@PR_STATUS,'') + '''
	AND isnull(''' + ISNULL(@PR_STATUS,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@PR_STATUS,'') + ''', '''') = '''')))
AND ((A.PR_ITEM_NO LIKE ''%' + ISNULL(@ITEM_NO,'') + '%''
	AND isnull(''' + ISNULL(@ITEM_NO,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@ITEM_NO,'') + ''', '''') = '''')))
AND ((A.ASSET_NO LIKE ''%' + ISNULL(@ASSET_NO,'') + '%''
	AND isnull(''' + ISNULL(@ASSET_NO,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@ASSET_NO,'') + ''', '''') = '''')))
AND ((A.ASSET_CATEGORY = ''' + ISNULL(@ASSET_CATEGORY,'') + '''
	AND isnull(''' + ISNULL(@ASSET_CATEGORY,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@ASSET_CATEGORY,'') + ''', '''') = '''')))
AND ((A.SUB_ASSET_NO LIKE ''%' + ISNULL(@SUBASSET_NO,'') + '%''
	AND isnull(''' + ISNULL(@SUBASSET_NO,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@SUBASSET_NO,'') + ''', '''') = '''')))
AND ((A.ASSET_CLASS = ''' + ISNULL(@ASSET_CLASS,'') + '''
	AND isnull(''' + ISNULL(@ASSET_CLASS,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@ASSET_CLASS,'') + ''', '''') = '''')))
AND ((A.REGISTRATION_DT >= ''' + ISNULL(@REGISTER_DT_FROM,'') + '''
	AND isnull(''' + ISNULL(@REGISTER_DT_FROM,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@REGISTER_DT_FROM,'') + ''', '''') = '''')))
AND ((A.REGISTRATION_DT <= ''' + ISNULL(@REGISTER_DT_TO,'') + '''
	AND isnull(''' + ISNULL(@REGISTER_DT_TO,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@REGISTER_DT_TO,'') + ''', '''') = '''')))
ORDER BY A.REGISTRATION_DT DESC, A.PR_NO ASC, A.PR_ITEM_NO ASC, A.SEQ_NO ASC
	)TBL1 WHERE number >= ' + CONVERT(VARCHAR(MAX),@Start) + ' AND number <= ' + CONVERT(VARCHAR(MAX),@Length)
--+ 'ORDER BY DOC_DT DESC'
EXEC (@SQL_QUERY)
END