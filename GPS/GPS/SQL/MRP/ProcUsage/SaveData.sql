IF (@Flag = '0') --ADD & COPY
BEGIN
	if exists(select 1 from TB_M_PROC_USAGE 
		      WHERE PROC_USAGE_CD = @ProcUsage 
		     )
        begin
			select 'Error|Data is duplicate. Please check mandatory field *)'
		end
		else
		begin
			INSERT INTO TB_M_PROC_USAGE
				   ([PROC_USAGE_CD]
				   ,[DESCRIPTION]
				   ,[CREATED_BY]
				   ,[CREATED_DT]
				   ,[CHANGED_BY]
				   ,[CHANGED_DT])
			SELECT @ProcUsage,
				   @Desc,			  				 
				   @UserName,
				   GETDATE(),
				   NULL,
				   NULL

        select 'True|Save Successfully'
		end			 		   	
END
ELSE --EDIT
BEGIN
	UPDATE TB_M_PROC_USAGE 
	SET PROC_USAGE_CD = @ProcUsage,
	    DESCRIPTION = @Desc,
		CHANGED_BY = @UserName,
		CHANGED_DT = GETDATE()
    WHERE PROC_USAGE_CD = @ProcUsageHide
		 
    select 'True|Save Successfully'
END
