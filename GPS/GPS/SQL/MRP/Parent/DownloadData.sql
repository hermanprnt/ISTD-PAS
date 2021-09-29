SELECT 	A.PARENT_CD,
		A.PARENT_TYPE,		
		A.CREATED_BY,			  
		CONVERT(varchar(10),A.CREATED_DT,102) CREATED_DT,
		A.CHANGED_BY,			  
		CONVERT(varchar(10),A.CHANGED_DT,102) CHANGED_DT
FROM TB_M_PARENT A	 
WHERE (A.PARENT_CD like '%' + @ParentCode + '%')
	  AND (A.PARENT_TYPE like '%' + @ParentType + '%')		