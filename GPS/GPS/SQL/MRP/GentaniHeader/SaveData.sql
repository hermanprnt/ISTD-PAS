IF (@Flag = '0') --ADD & COPY
BEGIN
	if not exists(select 1 from TB_M_PROC_USAGE where PROC_USAGE_CD = @ProcUsage)
		select 'Error|Proc Usage not found in System Master'	
	else if not exists(select 1 from TB_M_GENTANI_TYPE where GENTANI_HEADER_TYPE = @HeaderType)
		select 'Error|Header Type not found in System Master'
    else
	begin
		if exists(select 1 from TB_M_GENTANI_HEADER 
		          WHERE PROC_USAGE_CD = @ProcUsage AND
						GENTANI_HEADER_TYPE = @HeaderType AND
						GENTANI_HEADER_CD = @HeaderCd AND						
						VALID_DT_FR = @ValidFrom)
        begin
			select 'Error|Data is duplicate. Please check mandatory field *)'
		end
		else
		begin

			INSERT INTO [dbo].[TB_M_GENTANI_HEADER]
					   ([PROC_USAGE_CD]
					   ,[GENTANI_HEADER_TYPE]
					   ,[GENTANI_HEADER_CD]
					   ,[VALID_DT_FR]
					   ,[VALID_DT_TO]
					   ,[MODEL]
					   ,[TRANSMISSION]
					   ,[ENGINE]
					   ,[DE]
					   ,[PROD_SFX]
					   ,[COLOR]
					   ,[CREATED_BY]
					   ,[CREATED_DT]
					   ,[CHANGED_BY]
					   ,[CHANGED_DT])
				 VALUES
					   (@ProcUsage
					   ,@HeaderType
					   ,@HeaderCd
					   ,@ValidFrom
					   ,@ValidTo
					   ,@Model
					   ,@Transmission
					   ,@Engine
					   ,@DE
					   ,@ProdSfx
					   ,@Color
					   ,@UserName,
					   GETDATE(),
					   NULL,
					   NULL)
        select 'True|Save Successfully'
		end		
     end	 		   	
END
ELSE --EDIT
BEGIN
	UPDATE TB_M_GENTANI_HEADER 
	SET GENTANI_HEADER_CD = @HeaderCd,
	    VALID_DT_TO = @ValidTo
		,MODEL=@Model
		,TRANSMISSION=@Transmission
		,ENGINE=@Engine
		,DE=@DE
		,[PROD_SFX]=@ProdSfx
		,COLOR=@Color
		,CHANGED_BY = @UserName,
		CHANGED_DT = GETDATE()
    WHERE PROC_USAGE_CD = @ProcUsage AND
		  GENTANI_HEADER_TYPE = @HeaderType AND
		  GENTANI_HEADER_CD = @HeaderCd_hidden AND		  
		  VALID_DT_FR = @ValidFrom

    select 'True|Save Successfully'
END
