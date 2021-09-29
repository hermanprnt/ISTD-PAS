WITH getData AS
		(
		SELECT ROW_NUMBER() OVER(ORDER BY A.MAT_NO) AS NUMBER,			  
			   A.MAT_NO,
			   A.MAT_DESC
		FROM tb_m_material_NONPART A	 
		WHERE (A.MAT_DESC like '%' + @MatNo + '%')	OR
              (A.MAT_NO like '%' + @MatNo + '%')		 
		)
SELECT *
FROM getData
WHERE NUMBER >= @Start AND NUMBER <= @Length