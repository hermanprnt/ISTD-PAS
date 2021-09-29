SELECT COUNT(1)
FROM TB_M_SYSTEM A	 
WHERE (A.SYSTEM_CD like '%' + @Code + '%')
	  AND (A.SYSTEM_VALUE like '%' + @Value + '%')	 