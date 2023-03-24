
	WITH getData AS
			(
			SELECT ROW_NUMBER() OVER(ORDER BY A.MAT_NO DESC) AS NUMBER,
				   C.PROC_USAGE_CD,
				   C.GENTANI_HEADER_TYPE,
				   C.GENTANI_HEADER_CD,
				   C.MODEL AS MODEL,
				   C.TRANSMISSION AS TRANSMISSION,
				   C.ENGINE AS ENGINE,
				   C.DE AS DE,
				   C.PROD_SFX AS PROD_SFX,
				   C.COLOR AS COLOR,		
				   A.MAT_NO  AS MAT_NO,
				   B.MAT_DESC,
				   B.BASE_UOM,
				   A.USAGE_QTY,
				   A.PLANT_CD,
				   A.STORAGE_LOCATION,			  
				   CONVERT(varchar(10),A.VALID_DT_FR,102) VALID_DT_FR,	
				   CONVERT(varchar(10),A.VALID_DT_TO,102) VALID_DT_TO,
				   A.CREATED_BY,			  
				   CONVERT(varchar(10),A.CREATED_DT,102) CREATED_DT,
				   A.CHANGED_BY,			  
				   CONVERT(varchar(10),A.CHANGED_DT,102) CHANGED_DT
			FROM TB_M_GENTANI_HEADER C  left JOIN TB_M_NON_COMPONENT_PART_LIST A 
			ON C.PROC_USAGE_CD=A.PROC_USAGE_CD AND C.GENTANI_HEADER_TYPE=A.GENTANI_HEADER_TYPE AND C.GENTANI_HEADER_CD=A.GENTANI_HEADER_CD  AND C.MODEL = A.MODEL
			LEFT join TB_M_MATERIAL_NONPART B 
			ON A.MAT_NO=B.MAT_NO   
			WHERE ((C.PROC_USAGE_CD = @ProcUsage) OR (@ProcUsage = 'x'))
				  AND (@HeaderType='' or @HeaderType is null or(C.GENTANI_HEADER_TYPE like '%' + @HeaderType + '%'))
				  AND (@HeaderCd='' or @HeaderCd is null or(C.GENTANI_HEADER_CD like '%' + @HeaderCd + '%'))
				  AND (@ValidDt='' or @ValidDt is null or(@ValidDt BETWEEN C.VALID_DT_FR AND C.VALID_DT_TO)) 
				  AND (A.MAT_NO=@MatNo OR A.MAT_NO IS NULL)
			)
	SELECT *
	FROM getData
	WHERE (NUMBER >= @Start AND NUMBER <= @Length)
	AND (@Model is null or @Model ='' or(MODEL like '%' + @Model + '%')	)
	AND (@Engine is null or @Engine ='' or (ENGINE like '%' + @Engine + '%'))
	AND (@Transmission is null or @Transmission ='' or (TRANSMISSION like '%' + @Transmission + '%') )
	AND (@DE is null or @DE ='' or (DE like '%' + @DE + '%')	)
	AND (@ProdSfx is null or @ProdSfx ='' or (PROD_SFX like '%' + @ProdSfx + '%'))
	AND (@Color is null or @Color ='' or (COLOR like '%' + @Color + '%') )
