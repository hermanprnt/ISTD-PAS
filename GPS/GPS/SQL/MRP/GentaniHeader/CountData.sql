﻿SELECT COUNT(1)
FROM TB_M_GENTANI_HEADER A	 
WHERE ((A.PROC_USAGE_CD = @ProcUsage) OR (@ProcUsage = 'x'))
			  AND (A.GENTANI_HEADER_TYPE like '%' + @HeaderType + '%')
			  AND (A.GENTANI_HEADER_CD like '%' + @HeaderCd + '%')	
			  AND (@Model is null or @Model ='' or(A.MODEL like '%' + @Model + '%')	)
			  AND (@Engine is null or @Engine ='' or (A.ENGINE like '%' + @Engine + '%'))
			  AND (@Transmission is null or @Transmission ='' or (A.TRANSMISSION like '%' + @Transmission + '%') )
			  AND (@DE is null or @DE ='' or (A.DE like '%' + @DE + '%')	)
			  AND (@ProdSfx is null or @ProdSfx ='' or (A.PROD_SFX like '%' + @ProdSfx + '%'))
			  AND (@Color is null or @Color ='' or (A.COLOR like '%' + @Color + '%') )
			  AND (@ValidDt='' or @ValidDt is null or(@ValidDt BETWEEN A.VALID_DT_FR AND A.VALID_DT_TO)) 