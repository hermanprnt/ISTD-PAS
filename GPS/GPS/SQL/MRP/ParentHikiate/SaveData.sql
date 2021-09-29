IF (@Flag = '0') --ADD & COPY
BEGIN
	if not exists(select 1 from TB_M_PROC_USAGE where PROC_USAGE_CD = @ProcUsage)
		select 'Error|Proc Usage not found in System Master'	
	else if not exists(select 1 from TB_M_GENTANI_TYPE where GENTANI_HEADER_TYPE = @HeaderType)
		select 'Error|Header Type not found in System Master'
    else if not exists(select 1 from TB_M_GENTANI_HEADER where GENTANI_HEADER_CD = @HeaderCd)
		select 'Error|Header Code not found in System Master'
	else if not exists(select 1 from TB_M_PARENT where PARENT_CD = @ParentCode)
		select 'Error|Parent Code not found in System Master'   
	else
	begin
		if exists(select 1 from TB_M_PARENT_GENTANI_HEADER_HIKIATE 
		          WHERE PARENT_CD = @ParentCode AND
				        PROC_USAGE_CD = @ProcUsage AND
						GENTANI_HEADER_TYPE = @HeaderType AND
						GENTANI_HEADER_CD = @HeaderCd AND						
						VALID_DT_FR = @ValidFrom)
        begin
			select 'Error|Data is duplicate. Please check mandatory field *)'
		end
		else
		begin
			INSERT INTO TB_M_PARENT_GENTANI_HEADER_HIKIATE
				   ([PARENT_CD]
				   ,[PROC_USAGE_CD]
				   ,[GENTANI_HEADER_TYPE]
				   ,[GENTANI_HEADER_CD]
				   ,[VALID_DT_FR]
				   ,[VALID_DT_TO]
				   ,[MULTIPLY_USAGE]
				   ,[CREATED_BY]
				   ,[CREATED_DT]
				   ,[CHANGED_BY]
				   ,[CHANGED_DT])
			SELECT @ParentCode,
			       @ProcUsage,
				   @HeaderType,
				   @HeaderCd,				  				  
				   @ValidFrom,
				   @ValidTo,
				   @UsageQty,
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
	UPDATE TB_M_PARENT_GENTANI_HEADER_HIKIATE 
	SET MULTIPLY_USAGE = @UsageQty,		
	    VALID_DT_TO = @ValidTo,
		CHANGED_BY = @UserName,
		CHANGED_DT = GETDATE()
    WHERE PARENT_CD = @ParentCode AND
	      PROC_USAGE_CD = @ProcUsage AND
		  GENTANI_HEADER_TYPE = @HeaderType AND
		  GENTANI_HEADER_CD = @HeaderCd AND		  
		  VALID_DT_FR = @ValidFrom

    select 'True|Save Successfully'
END
