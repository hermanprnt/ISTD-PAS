﻿DECLARE @@DB_CONNECTION VARCHAR(30),
        @@SQL_QUERY VARCHAR(MAX),
		@@DIV_PARAMETER VARCHAR(10)
		,@@DB_SCHEMA VARCHAR(30)

            
SELECT @@DB_CONNECTION =  SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'BudgetControl'
SELECT @@DIV_PARAMETER = ISNULL(dbo.fn_DIV_GPS_BMS(@DIVISION), '')
SELECT @@DB_SCHEMA =  SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'BudgetControlSchema'

SET @@SQL_QUERY = '
		EXEC ' + @@DB_CONNECTION + '.' + @@DB_SCHEMA + '.[dbo].[sp_BudgetControlCountDataHeader] ' + @@DIV_PARAMETER + ', '''+@WBS_NO+''', ''' + @WBS_YEAR + ''''
EXEC(@@SQL_QUERY)
