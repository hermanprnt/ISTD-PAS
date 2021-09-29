SELECT COUNT(1)
		FROM TB_M_GENTANI_HEADER C  left JOIN TB_M_NON_COMPONENT_PART_LIST A 
		ON C.PROC_USAGE_CD=A.PROC_USAGE_CD AND C.GENTANI_HEADER_TYPE=A.GENTANI_HEADER_TYPE AND C.GENTANI_HEADER_CD=A.GENTANI_HEADER_CD  AND C.MODEL = A.MODEL
		LEFT join TB_M_MATERIAL_NONPART B 
		ON A.MAT_NO=B.MAT_NO   
		WHERE ((C.PROC_USAGE_CD = @ProcUsage) OR (@ProcUsage = 'x'))
				AND (@HeaderType='' or @HeaderType is null or(C.GENTANI_HEADER_TYPE like '%' + @HeaderType + '%'))
				AND (@HeaderCd='' or @HeaderCd is null or(C.GENTANI_HEADER_CD like '%' + @HeaderCd + '%'))
				AND (@ValidDt='' or @ValidDt is null or(@ValidDt BETWEEN C.VALID_DT_FR AND C.VALID_DT_TO)) 
				AND (A.MAT_NO=@MatNo OR A.MAT_NO IS NULL)
				AND (@Model is null or @Model ='' or(C.MODEL like '%' + @Model + '%')	)
				AND (@Engine is null or @Engine ='' or (C.ENGINE like '%' + @Engine + '%'))
				AND (@Transmission is null or @Transmission ='' or (C.TRANSMISSION like '%' + @Transmission + '%') )
				AND (@DE is null or @DE ='' or (C.DE like '%' + @DE + '%')	)
				AND (@ProdSfx is null or @ProdSfx ='' or (C.PROD_SFX like '%' + @ProdSfx + '%'))
				AND (@Color is null or @Color ='' or (C.COLOR like '%' + @Color + '%') )