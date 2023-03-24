IF (@Flag = '0') --ADD & COPY
BEGIN
	if not exists(select 1 from TB_M_PROC_USAGE where PROC_USAGE_CD = @ProcUsage)
		select 'Error|Proc Usage not found in System Master'	
    else
	begin
		if exists(select 1 from TB_M_GENTANI_TYPE 
		          WHERE PROC_USAGE_CD = @ProcUsage AND GENTANI_HEADER_TYPE = @HeaderType AND MODEL = @Model 
				  )
        begin
			select 'Error|Data is duplicate. Please check mandatory field *)'
		end
		else
		begin
			INSERT INTO TB_M_GENTANI_TYPE
			       ([PROC_USAGE_CD]
				   ,[MODEL]
				   ,[GENTANI_HEADER_TYPE]
				   ,[DESCRIPTION]
				   ,[CREATED_BY]
				   ,[CREATED_DT]
				   ,[CHANGED_BY]
				   ,[CHANGED_DT])
			SELECT @ProcUsage,
				   @Model,
				   @HeaderType,
				   @Desc,				 
				   @UserName,
				   GETDATE(),
				   NULL,
				   NULL

        select 'True|Save Successfully'
		end		
     end	 		   	
END
ELSE --EDIT
BEGIN
	UPDATE TB_M_GENTANI_TYPE 
	SET GENTANI_HEADER_TYPE = @HeaderType,
	    MODEL = @Model,
	    DESCRIPTION = @Desc,
		CHANGED_BY = @UserName,
		CHANGED_DT = GETDATE()
    WHERE PROC_USAGE_CD = @ProcUsage AND
		  GENTANI_HEADER_TYPE = @HeaderTypehidden 		 

    select 'True|Save Successfully'
END
