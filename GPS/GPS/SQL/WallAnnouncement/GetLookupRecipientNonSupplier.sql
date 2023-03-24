select DISTINCT a.REG_NO AS VALUE, '['+a.username+'] - '+ isnull(a.FIRST_NAME,'')+' '+isnull(a.LAST_NAME, '') as Name from 
	tb_m_user a
	JOIN TB_M_USER_APPLICATION b ON b.USERNAME = a.USERNAME AND b.APPLICATION IN ('GPS', 'ECat')
	where(IN_ACTIVE_DIRECTORY = 1 AND COMPANY = '1000') OR COMPANY = '1000' OR COMPANY = 'TMMIN'
ORDER BY '['+a.username+'] - '+ isnull(a.FIRST_NAME,'')+' '+isnull(a.LAST_NAME, '')