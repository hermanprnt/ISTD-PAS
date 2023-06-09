ALTER PROCEDURE [dbo].sp_prcreation_datalist_getWBSList 
	@PR_COORDINATOR varchar(20),
	@PR_TYPE varchar(5),
	@WBS_PARAM varchar(MAX),
	@DIVISION_ID int,
	@REGNO VARCHAR(30),
	@start int,
	@length int
AS
BEGIN
	DECLARE @TRAVEL_LS VARCHAR(MAX),
			@TRAVEL_DB VARCHAR(MAX),
			@SQL_STRING VARCHAR(MAX)

	SELECT @TRAVEL_LS = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'LINKS' AND SYSTEM_CD ='LINKED_SERVERS_TRAVEL'
	SELECT @TRAVEL_DB = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'LINKS' AND SYSTEM_CD ='LINKED_DB_TRAVEL'

	DECLARE @TRAVEL_LINK_SERVER AS TABLE (WBS_NUMBER VARCHAR(30))

	SET @SQL_STRING =  'SELECT DISTINCT [WBS_NUMBER]
							FROM '+@TRAVEL_LS+'.'+@TRAVEL_DB+'.[dbo].[TB_M_WBS_NO] WHERE 1 = 1'
	
	INSERT INTO @TRAVEL_LINK_SERVER
	EXEC (@SQL_STRING)


	IF(ISNULL(@PR_COORDINATOR, '') = 'AD-TRV')
	BEGIN
		IF EXISTS(SELECT 1 FROM TB_M_COORDINATOR_MAPPING WHERE COORDINATOR_CD = 'AD-TRV' AND NOREG = @REGNO)
		BEGIN
			SELECT * FROM (
				SELECT DISTINCT 
					   DENSE_RANK() OVER (ORDER BY A.WBS_NO ASC) AS number,
					   A.WBS_NO, 
					   A.WBS_NAME 
					FROM TB_R_WBS A 
					JOIN @TRAVEL_LINK_SERVER B ON B.WBS_NUMBER = A.WBS_NO
				WHERE ISNULL(PROJECT_NO,'') = 'TRAVEL' AND WBS_YEAR = LEFT(CONVERT(varchar, GetDate(),112),4) 
					AND ((( A.WBS_NO LIKE '%' + @WBS_PARAM + '%' AND isnull(@WBS_PARAM, '') <> ''
					OR (isnull(@WBS_PARAM, '') = '')))
				    OR (( A.WBS_NAME LIKE '%' + @WBS_PARAM + '%' AND isnull(@WBS_PARAM, '') <> ''
					OR (isnull(@WBS_PARAM, '') = ''))))
			)data WHERE data.number >= @start AND data.number <= @length
		END
		ELSE
		BEGIN
			-- Tampilkan structure data nya dengan data null
			SELECT * FROM (
				SELECT DISTINCT 
					   DENSE_RANK() OVER (ORDER BY A.WBS_NO ASC) AS number,
					   A.WBS_NO, 
					   A.WBS_NAME 
				FROM TB_R_WBS A
				WHERE 1 = 0
			)data WHERE data.number >= @start AND data.number <= @length
		END
	END
	ELSE
	BEGIN
		IF(ISNULL(@PR_COORDINATOR, '') = '' OR ISNULL(@PR_TYPE, '') <> 'RR')
		BEGIN
			SELECT * FROM (
				SELECT DISTINCT 
					   DENSE_RANK() OVER (ORDER BY A.WBS_NO ASC) AS number,
					   A.WBS_NO, 
					   A.WBS_NAME 
					FROM TB_R_WBS A JOIN TB_M_SYSTEM B 
				ON B.SYSTEM_VALUE = A.WBS_YEAR AND B.SYSTEM_CD = 'FI_YEAR'
				AND ((( A.WBS_NO LIKE '%' + @WBS_PARAM + '%'
					AND isnull(@WBS_PARAM, '') <> ''
					OR (isnull(@WBS_PARAM, '') = '')))
				OR (( A.WBS_NAME LIKE '%' + @WBS_PARAM + '%'
					AND isnull(@WBS_PARAM, '') <> ''
					OR (isnull(@WBS_PARAM, '') = ''))))
				WHERE A.DIVISION_ID = CASE WHEN @DIVISION_ID = 0 AND @PR_TYPE = 'RR' THEN 14 ELSE @DIVISION_ID END
					AND ISNULL(PROJECT_NO,'') <> 'TRAVEL'
			)data WHERE data.number >= @start AND data.number <= @length
		END
		ELSE
		BEGIN
			SELECT * FROM (
				SELECT DISTINCT 
					   DENSE_RANK() OVER (ORDER BY A.WBS_NO ASC) AS number,
					   A.WBS_NO, 
					   C.WBS_NAME 
					FROM TB_R_QUOTA A
				JOIN TB_R_WBS C 
					ON A.WBS_NO = C.WBS_NO
					AND ((( A.WBS_NO LIKE '%' + @WBS_PARAM + '%'
						AND isnull(@WBS_PARAM, '') <> ''
						OR (isnull(@WBS_PARAM, '') = '')))
					OR (( C.WBS_NAME LIKE '%' + @WBS_PARAM + '%'
						AND isnull(@WBS_PARAM, '') <> ''
						OR (isnull(@WBS_PARAM, '') = ''))))
					WHERE A.CONSUME_MONTH = LEFT(CONVERT(varchar, GetDate(),112),6) AND A.ORDER_COORD = @PR_COORDINATOR 
						AND ISNULL(PROJECT_NO,'') <> 'TRAVEL'
			)data WHERE data.number >= @start AND data.number <= @length
		END
	END
END



