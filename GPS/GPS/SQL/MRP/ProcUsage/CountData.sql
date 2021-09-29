SELECT COUNT(1)
FROM TB_M_PROC_USAGE A	 
WHERE (A.PROC_USAGE_CD like '%' + @ProcUsage + '%')
	  AND (A.DESCRIPTION like '%' + @Desc + '%')	 
	 	