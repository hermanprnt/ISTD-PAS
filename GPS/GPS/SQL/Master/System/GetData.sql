WITH getData AS
		(
		SELECT ROW_NUMBER() OVER(ORDER BY A.CREATED_DT) AS NUMBER,			 
			   A.FUNCTION_ID as FunctionId,
			   A.SYSTEM_CD as Code,	
			   A.SYSTEM_VALUE as Value,	
			   A.SYSTEM_REMARK as Remark,		   
			   A.CREATED_BY as CreatedBy,			  
			   CONVERT(varchar(10),A.CREATED_DT,104) CreatedDate,
			   --A.CREATED_DT as CreatedDate,
			    A.CHANGED_BY as ChangedBy,		  
			   CONVERT(varchar(10),A.CHANGED_DT,104) ChangedDate
			   --A.CHANGED_DT as ChangedDate
		FROM TB_M_SYSTEM A	 
		WHERE (A.SYSTEM_CD like '%' + @Code + '%') AND
	          (A.SYSTEM_VALUE like '%' + @Value + '%')			
		)
SELECT *
FROM getData
WHERE NUMBER >= @Start AND NUMBER <= @Length