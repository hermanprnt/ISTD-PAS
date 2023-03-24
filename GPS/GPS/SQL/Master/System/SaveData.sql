IF (@Flag = '0') --ADD 
BEGIN
	if exists(select 1 from TB_M_SYSTEM 
		      WHERE FUNCTION_ID = @FunctionId AND SYSTEM_CD = @Code 
		     )
        begin
			select 'Error|Data is duplicate. Please check mandatory field'
		end
		else
		begin
			INSERT INTO TB_M_SYSTEM
				   ([FUNCTION_ID]
				   ,[SYSTEM_CD]
				   ,[SYSTEM_VALUE]
				   ,[CREATED_BY]
				   ,[CREATED_DT]
				   ,[CHANGED_BY]
				   ,[CHANGED_DT]
				   ,[SYSTEM_REMARK])
			SELECT @FunctionId,
				   @Code ,
				   @Value,			  				 
				   @UserName,
				   GETDATE(),
				   NULL,
				   NULL,
				   @Remark

        select 'True|Save Successfully'
		end			 		   	
END
ELSE --EDIT
BEGIN
	UPDATE TB_M_SYSTEM 
	SET SYSTEM_VALUE = @Value,
	    SYSTEM_REMARK = @Remark,
		CHANGED_BY = @UserName,
		CHANGED_DT = GETDATE()
    WHERE FUNCTION_ID = @FunctionId AND SYSTEM_CD = @Code
		 
    select 'True|Save Successfully'
END
