SELECT COUNT(1)
FROM tb_m_material_NONPART A	 
WHERE (A.MAT_DESC like '%' + @MatNo + '%') OR
      (A.MAT_NO like '%' + @MatNo + '%')
	 	