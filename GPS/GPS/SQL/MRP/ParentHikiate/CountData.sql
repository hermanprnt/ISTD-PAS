﻿SELECT COUNT(1)
FROM TB_M_PARENT_GENTANI_HEADER_HIKIATE A	left join TB_M_GENTANI_HEADER C on  
		C.PROC_USAGE_CD=A.PROC_USAGE_CD AND C.GENTANI_HEADER_TYPE=A.GENTANI_HEADER_TYPE AND C.GENTANI_HEADER_CD=A.GENTANI_HEADER_CD AND C.MODEL=A.MODEL
WHERE ((A.PARENT_CD = @ParentCd) OR (@ParentCd = 'x'))
		AND ((A.PROC_USAGE_CD = @ProcUsage) OR (@ProcUsage = 'x'))
		AND (@HeaderType is null or @HeaderType ='' or (A.GENTANI_HEADER_TYPE like '%' + @HeaderType + '%'))
		AND (@HeaderCd is null or @HeaderCd ='' or (A.GENTANI_HEADER_CD like '%' + @HeaderCd + '%')	)		  
		AND (@ValidDt is null or @ValidDt ='' or (@ValidDt BETWEEN A.VALID_DT_FR AND A.VALID_DT_TO) )
		AND (@Model is null or @Model ='' or(A.MODEL like '%' + @Model + '%')	)
		AND (@Engine is null or @Engine ='' or (ENGINE like '%' + @Engine + '%'))
		AND (@Transmission is null or @Transmission ='' or (TRANSMISSION like '%' + @Transmission + '%') )
		AND (@DE is null or @DE ='' or (DE like '%' + @DE + '%')	)
		AND (@ProdSfx is null or @ProdSfx ='' or (PROD_SFX like '%' + @ProdSfx + '%'))
		AND (@Color is null or @Color ='' or (COLOR like '%' + @Color + '%') )