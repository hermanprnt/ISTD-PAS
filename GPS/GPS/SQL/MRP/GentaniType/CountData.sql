SELECT COUNT(1)
FROM TB_M_GENTANI_TYPE A	 
WHERE ((A.PROC_USAGE_CD = @ProcUsage) OR (@ProcUsage = 'x'))
	  AND (A.GENTANI_HEADER_TYPE like '%' + @HeaderType + '%')
	  AND (A.MODEL like '%' + @Model + '%')
	  	