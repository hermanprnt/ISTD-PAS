WITH getData AS
		(
		SELECT ROW_NUMBER() OVER(ORDER BY A.CREATED_DT) AS NUMBER,			 
			   A.PROC_USAGE_CD,
			   A.GENTANI_HEADER_TYPE,
			   A.MODEL,
			   A.DESCRIPTION,
			   A.CREATED_BY,			  
			   CONVERT(varchar(10),A.CREATED_DT,102) CREATED_DT,
			   A.CHANGED_BY,			  
			   CONVERT(varchar(10),A.CHANGED_DT,102) CHANGED_DT
		FROM TB_M_GENTANI_TYPE A	 
		WHERE ((A.PROC_USAGE_CD = @ProcUsage) OR (@ProcUsage = 'x'))
			  AND (A.GENTANI_HEADER_TYPE like '%' + @HeaderType + '%')	
			  AND (A.MODEL like '%' + @Model + '%')			 
		)
SELECT *
FROM getData
WHERE NUMBER >= @Start AND NUMBER <= @Length