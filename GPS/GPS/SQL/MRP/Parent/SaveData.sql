IF (@Flag = '0') --ADD & COPY
BEGIN
	if exists(select 1 from TB_M_PARENT 
		      WHERE PARENT_CD = @ParentCode AND PARENT_TYPE = @ParentType 
		     )
        begin
			select 'Error|Data is duplicate. Please check mandatory field *)'
		end
		else
		begin
			INSERT INTO TB_M_PARENT
				   ([PARENT_CD]
				   ,[PARENT_TYPE]
				   ,[CREATED_BY]
				   ,[CREATED_DT]
				   ,[CHANGED_BY]
				   ,[CHANGED_DT])
			SELECT @ParentCode,
				   @ParentType,			  				 
				   @UserName,
				   GETDATE(),
				   NULL,
				   NULL

        select 'True|Save Successfully'
		end			 		   	
END
ELSE --EDIT
BEGIN
	UPDATE TB_M_PARENT 
	SET PARENT_CD = @ParentCode,
	    PARENT_TYPE = @ParentType,
		CHANGED_BY = @UserName,
		CHANGED_DT = GETDATE()
    WHERE PARENT_CD = @ParentCodeHide AND PARENT_TYPE = @ParentTypeHide
		 
    select 'True|Save Successfully'
END
