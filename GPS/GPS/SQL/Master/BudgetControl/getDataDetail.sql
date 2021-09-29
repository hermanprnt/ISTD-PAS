﻿--exec [10.16.20.231].[NEW_BMS_DB].[dbo].[sp_BudgetControlGetDataDetail]  @WBS_NO,@ACTION_TYPE, @Start, @End

DECLARE @@DB_CONNECTION VARCHAR(30),
        @@SQL_QUERY VARCHAR(MAX),
		@@DIV_PARAMETER VARCHAR(10)

            
SELECT @@DB_CONNECTION =  SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'BudgetControl'

SET @@SQL_QUERY = '
		EXEC ' + @@DB_CONNECTION + '.[BMS_DB].[dbo].[sp_BudgetControlGetDataDetail] '''+@WBS_NO+''', ' + @ACTION_TYPE + ', '+CAST(@Start AS VARCHAR)+', '+CAST(@End AS VARCHAR)+'
	'
EXEC(@@SQL_QUERY)


