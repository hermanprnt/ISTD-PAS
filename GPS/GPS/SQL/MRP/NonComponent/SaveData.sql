IF (@Flag = '0') --ADD & COPY
BEGIN
	if not exists(select 1 from TB_M_PROC_USAGE where PROC_USAGE_CD = @ProcUsage)
		select 'Error|Proc Usage not found in System Master'	
	else if not exists(select 1 from TB_M_GENTANI_TYPE where GENTANI_HEADER_TYPE = @HeaderType)
		select 'Error|Header Type not found in System Master'
    else if not exists(select 1 from TB_M_GENTANI_HEADER where GENTANI_HEADER_CD = @HeaderCd)
		select 'Error|Header Code not found in System Master'
	else if not exists(select 1 from TB_M_MATERIAL where MAT_NO = @MatNo)
		select 'Error|Material Number not found in System Master'
    else if not exists(select 1 from TB_M_SLOC where SLOC_CD = @Storage)
		select 'Error|Storage Location not found in System Master'
	else
	begin
		if exists(select 1 from TB_M_NON_COMPONENT_PART_LIST 
		          WHERE PROC_USAGE_CD = @ProcUsage AND
						GENTANI_HEADER_TYPE = @HeaderType AND
						GENTANI_HEADER_CD = @HeaderCd AND
						MAT_NO = @MatNo AND
						VALID_DT_FR = @ValidFrom)
        begin
			select 'Error|Data is duplicate. Please check mandatory field *)'
		end
		else
		begin
			INSERT INTO TB_M_NON_COMPONENT_PART_LIST
				   ([PROC_USAGE_CD]
				   ,[GENTANI_HEADER_TYPE]
				   ,[GENTANI_HEADER_CD]
				   ,[MAT_NO]
				   ,[USAGE_QTY]
				   ,[PLANT_CD]
				   ,[STORAGE_LOCATION]
				   ,[VALID_DT_FR]
				   ,[VALID_DT_TO]
				   ,[CREATED_BY]
				   ,[CREATED_DT]
				   ,[CHANGED_BY]
				   ,[CHANGED_DT])
			SELECT @ProcUsage,
				   @HeaderType,
				   @HeaderCd,
				   @MatNo,
				   @UsageQty,
				   @Uom,
				   @PlantCd,
				   @Storage,
				   @ValidFrom,
				   @ValidTo,
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
	UPDATE TB_M_NON_COMPONENT_PART_LIST 
	SET USAGE_QTY = @UsageQty,
		PLANT_CD = @PlantCd,
		STORAGE_LOCATION = @Storage,
	    VALID_DT_TO = @ValidTo,
		CHANGED_BY = @UserName,
		CHANGED_DT = GETDATE()
    WHERE PROC_USAGE_CD = @ProcUsage AND
		  GENTANI_HEADER_TYPE = @HeaderType AND
		  GENTANI_HEADER_CD = @HeaderCd AND
		  MAT_NO = @MatNo AND
		  VALID_DT_FR = @ValidFrom

    select 'True|Save Successfully'
END
