SELECT COUNT(1)
FROM TB_M_PARENT A	 
WHERE (A.PARENT_CD like '%' + @ParentCode + '%')
	  AND (A.PARENT_TYPE like '%' + @ParentType + '%')	 
	 	