WITH getData AS
		(
		SELECT ROW_NUMBER() OVER(ORDER BY A.CREATED_DT) AS NUMBER,
			   A.PARENT_CD,	
			   A.PROC_USAGE_CD,
			   A.GENTANI_HEADER_TYPE,
			   A.GENTANI_HEADER_CD,			  
			   A.MULTIPLY_USAGE,	
			   C.MODEL AS MODEL,
				C.TRANSMISSION AS TRANSMISSION,
				C.ENGINE AS ENGINE,
				C.DE AS DE,
				C.PROD_SFX AS PROD_SFX,
				C.COLOR AS COLOR,		  		  
			   CONVERT(varchar(10),A.VALID_DT_FR,102) VALID_DT_FR,	
			   CONVERT(varchar(10),A.VALID_DT_TO,102) VALID_DT_TO,
			   A.CREATED_BY,			  
			   CONVERT(varchar(10),A.CREATED_DT,102) CREATED_DT,
			   A.CHANGED_BY,			  
			   CONVERT(varchar(10),A.CHANGED_DT,102) CHANGED_DT
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
		)
SELECT *
FROM getData
WHERE NUMBER >= @Start AND NUMBER <= @Length