﻿--exec [10.16.20.231].[NEW_BMS_DB].[dbo].[sp_BudgetControlGetDataHeader] @DIVISION, @WBS_NO, @WBS_YEAR, @Start, @End

DECLARE @@DB_CONNECTION VARCHAR(30),
        @@SQL_QUERY VARCHAR(MAX),
		@@DIV_PARAMETER VARCHAR(10)

            
SELECT @@DB_CONNECTION =  SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'BudgetControl'
SELECT TOP(1) @@DIV_PARAMETER = ISNULL(dbo.fn_DIV_GPS_BMS(@DIVISION), '')

SET @@SQL_QUERY = '
		EXEC ' + @@DB_CONNECTION + '.[BMS_DB].[dbo].[sp_BudgetControlGetDataHeader] ' + @@DIV_PARAMETER + ', '''+@WBS_NO+''', ''' + @WBS_YEAR + ''', '+CAST(@Start AS VARCHAR)+', '+CAST(@End AS VARCHAR)+'
	'
EXEC(@@SQL_QUERY)