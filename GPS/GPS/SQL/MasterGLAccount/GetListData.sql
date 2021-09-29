
select * from (
	select *, ROW_NUMBER() OVER (ORDER BY CREATED_BY desc) as RowNo
	FROM (
		select distinct 
		 GL_ACCOUNT_DESC,
		 GL_ACCOUNT_CD,
		 PLANT_CD,
		 CREATED_BY,
		 CREATED_DT,
		 CHANGED_BY,
		 CHANGED_DT
		FROM TB_M_GL_ACCOUNT
		WHERE 1=1
		AND (nullif(@glAccountCD,'') is null or GL_ACCOUNT_CD like '%'+@glAccountCD+'%')
		AND (nullif(@glAccountDesc,'') is null or GL_ACCOUNT_DESC like '%'+@glAccountDesc+'%')
		AND (nullif(@plantCd,'') is null or PLANT_CD like '%'+@plantCd+'%')
	)ref
)tb
WHERE 1=1 
AND RowNo between cast(@currentPage as varchar) and Cast(@recordPerpage as varchar)