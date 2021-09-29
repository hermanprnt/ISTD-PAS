SELECT COUNT(1)
FROM TB_R_QUOTA 
WHERE CONSUME_MONTH LIKE cast(year(getdate()) as varchar(4)) + '%' AND 
      CONSUME_MONTH LIKE + '%' + cast(MONTH(getdate()) as varchar(2)) 
		      AND ((DIVISION_ID = @DIVISION_ID) OR (@DIVISION_ID = '0'))
	          AND (QUOTA_TYPE like '%' + @TYPE + '%' OR TYPE_DESCRIPTION like '%' + @TYPE + '%' )
			  AND (ORDER_COORD like '%' + @ORD_COORD + '%' OR ORDER_COORD_NAME like '%' + @ORD_COORD + '%' )
			  AND (WBS_NO like '%' + @WBS_NO + '%')	 