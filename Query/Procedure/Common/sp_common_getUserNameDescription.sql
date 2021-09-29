-- =============================================
-- Author      : arkamaya.rahmat
-- Create date : 06.02.2015
-- Description : Get user description from HR database
-- =============================================
ALTER PROCEDURE [dbo].[sp_common_getUserNameDescription] @NOREG VARCHAR(10)
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @HR_CONNECTION VARCHAR(30) = '[SANBOX-SQL\SANDBOXSQL]',
			@SQL_QUERY VARCHAR(MAX)
	

	SET @SQL_QUERY = '
		SELECT 
			NOREG, 
			PERSONNEL_NAME, 
			MAIL
		FROM TB_R_SYNCH_EMPLOYEE
				WHERE GETDATE() BETWEEN VALID_FROM AND VALID_TO AND NOREG = ''' + @NOREG + ''';
	'

	--SET @SQL_QUERY = '
	--	SELECT 
	--		NOREG, 
	--		USERNAME,
	--		PERSONNEL_NAME, 
	--		MAIL
	--	FROM OPENQUERY ([SANBOX-SQL\SANDBOXSQL], ''SELECT NOREG, 
	--													USERNAME,
	--													PERSONNEL_NAME, 
	--													MAIL
	--												FROM [DATAMASTER].[dbo].[vw_Organization] 
	--													WHERE GETDATE() BETWEEN VALID_FROM AND VALID_TO AND NOREG = ''''' + @NOREG + ''''''');
	--'

	EXEC(@SQL_QUERY)
END