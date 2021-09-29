IF (@Flag = '0') --ADD 
BEGIN
	if exists(select 1 from TB_M_QUOTA 
		      WHERE DIVISION_ID = @DivisionId and QUOTA_TYPE = @QuotaType
		     )
        begin
			select 'Error|Data is duplicate. Please check mandatory field'
		end
		else
		begin
			INSERT INTO TB_M_QUOTA
				   ([DIVISION_ID]
				   ,[DIVISION_NAME]
				   ,[WBS_NO]
				   ,[QUOTA_TYPE]
				   ,[TYPE_DESCRIPTION]
				   ,[ORDER_COORD]
				   ,[ORDER_COORD_NAME]
				   ,[QUOTA_AMOUNT]
				   ,[QUOTA_AMOUNT_TOL]
				   ,[CREATED_BY]
				   ,[CREATED_DT]
				   ,[CHANGED_BY]
				   ,[CHANGED_DT])
			SELECT @DivisionId,
				   @DivisionName,
				   @WBS,
				   @QuotaType,
				   @TypeDescription,
				   @OrderCoord,
				   @OrderCoordName,
				   @Ammount,
				   @AmmountTol,			  				 
				   @UserId,
				   GETDATE(),
				   NULL,
				   NULL

        select 'True|Save Successfully'
		end			 		   	
END
ELSE --EDIT
BEGIN
	UPDATE TB_M_QUOTA 
	SET ORDER_COORD = @OrderCoord,
	    ORDER_COORD_NAME = @OrderCoordName, 
	    QUOTA_AMOUNT = @Ammount,
	    QUOTA_AMOUNT_TOL = @AmmountTol,
		CHANGED_BY = @UserId,
		CHANGED_DT = GETDATE()
    WHERE DIVISION_ID = @DivisionId and QUOTA_TYPE = @QuotaType
		 
    select 'True|Save Successfully'
END
