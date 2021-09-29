
WITH getData AS
		(
		SELECT ROW_NUMBER() OVER(ORDER BY A.CREATED_DT) AS NUMBER,			 
			  A.PROC_USAGE_CD,
			   A.GENTANI_HEADER_TYPE,
			   A.GENTANI_HEADER_CD,	  
			   A.MODEL,
			   A.TRANSMISSION,
			   A.ENGINE,
			   A.DE,
			   A.PROD_SFX,
			   A.COLOR,		  		  
			   CONVERT(varchar(10),A.VALID_DT_FR,102) VALID_DT_FR,	
			   CONVERT(varchar(10),A.VALID_DT_TO,102) VALID_DT_TO,
			   A.CREATED_BY,			  
			   CONVERT(varchar(10),A.CREATED_DT,102) CREATED_DT,
			   A.CHANGED_BY,			  
			   CONVERT(varchar(10),A.CHANGED_DT,102) CHANGED_DT
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
		)
SELECT *
FROM getData
WHERE NUMBER >= @Start AND NUMBER <= @Length