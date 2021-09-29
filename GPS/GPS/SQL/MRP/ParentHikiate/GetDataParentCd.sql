WITH getData AS
		(
		SELECT ROW_NUMBER() OVER(ORDER BY A.PARENT_CD) AS NUMBER,			  
			   A.PARENT_CD,
			   A.PARENT_TYPE
		FROM TB_M_PARENT A	 
		WHERE (A.PARENT_CD like '%' + @ParentCd + '%')	OR
              (A.PARENT_TYPE like '%' + @ParentCd + '%')		 
		)
SELECT *
FROM getData
WHERE NUMBER >= @Start AND NUMBER <= @Length