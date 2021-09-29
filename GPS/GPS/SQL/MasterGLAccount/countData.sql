select count(1) 
from (
select * from TB_M_GL_ACCOUNT
where 1=1 
AND (nullif(@glAccountCD,'') is null or GL_ACCOUNT_CD like '%'+@glAccountCD+'%')
AND (nullif(@glAccountDesc,'') is null or GL_ACCOUNT_DESC like '%'+@glAccountDesc+'%')
AND (nullif(@plantCd,'') is null or PLANT_CD like '%'+@plantCd+'%')
)ref