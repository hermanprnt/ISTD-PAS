USE [NCP_QA]
GO
/****** Object:  StoredProcedure [dbo].[sp_common_getListDivision]    Script Date: 11/27/2015 1:28:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author      : arkamaya.rahmat
-- Create date : 03.03.2015
-- Description : Get list all division from HR database
-- =============================================
ALTER PROCEDURE [dbo].[sp_common_getListDivision] @NOREG VARCHAR(10) = ''
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @HR_CONNECTION VARCHAR(30) = '[SANBOX-SQL\SANDBOXSQL]',
		@SQL_QUERY VARCHAR(MAX),
		@PARAM VARCHAR(MAX) = CASE WHEN @NOREG <> '' THEN 'AND NOREG = ''' + @NOREG + '''' ELSE '' END;
		
		SET @SQL_QUERY = '
		SELECT DISTINCT 
			CAST(DIVISION_ID AS INT) AS DIVISION_ID, DIVISION_NAME
			FROM TB_R_SYNCH_EMPLOYEE WHERE GETDATE() BETWEEN VALID_FROM 
										AND VALID_TO ' + @PARAM + '
											AND DIVISION_ID IS NOT NULL
											AND DIVISION_NAME IS NOT NULL
          ORDER BY DIVISION_NAME
	'

	--SET @SQL_QUERY = '
	--	SELECT * 
	--		--CAST(DIVISION_ID AS INT) AS DIVISION_ID, DIVISION_NAME
	--		FROM OPENQUERY (' + @HR_CONNECTION + ', ''SELECT *--DISTINCT DIVISION_ID, DIVISION_NAME
	--													FROM [DATAMASTER].[dbo].[vw_Organization] 
	--														WHERE GETDATE() BETWEEN VALID_FROM 
	--															AND VALID_TO ' + @PARAM + '
	--																AND DIVISION_ID IS NOT NULL'')
	--'
	
	EXEC(@SQL_QUERY)
END







