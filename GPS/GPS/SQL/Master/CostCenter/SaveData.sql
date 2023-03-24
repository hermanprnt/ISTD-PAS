declare @@ValidFrom_db as date
IF(@Flag = '0')
BEGIN
	if not exists(select 1 from TB_M_COST_CENTER where COST_CENTER_CD = @CostCenterCode)
	begin --Begin Insert
         INSERT INTO dbo.TB_M_COST_CENTER
        ( COST_CENTER_CD ,
          COST_CENTER_DESC ,
		  DIVISION_ID,
		  RESP_PERSON,
          VALID_DT_FROM ,
          VALID_DT_TO ,
          CREATED_BY ,
          CREATED_DT ,
          CHANGED_BY ,
          CHANGED_DT
        )
    VALUES  ( @CostCenterCode,
              @Description,
			  @Division,
			  @RespPerson,
              @ValidFrom,
              '9999-12-31',
              @UId,
              GETDATE(),
              NULL,
              NULL
            )
         
		 select 'True|Save Successfully'
    end
    else
    begin
		select @@ValidFrom_db = VALID_DT_FROM from TB_M_COST_CENTER where COST_CENTER_CD = @CostCenterCode
		if(@@ValidFrom_db < cast(@ValidFrom as date))
		begin
			 if(cast(DATEADD(DAY, -1, CAST(@ValidFrom AS DATE)) as date) < @@ValidFrom_db)
				select 'Error|Fail to add Cost Center, because duplicate entries.'
			 else
			 begin
				update TB_M_COST_CENTER 
				set VALID_DT_TO = DATEADD(DAY, -1, CAST(@ValidFrom AS DATE)),
				    CHANGED_BY = @UId,
                    CHANGED_DT = GETDATE()
				where VALID_DT_TO = '9999-12-31' and COST_CENTER_CD = @CostCenterCode

				INSERT INTO dbo.TB_M_COST_CENTER
					( COST_CENTER_CD ,
					  COST_CENTER_DESC ,
					  DIVISION_ID,
					  RESP_PERSON,
					  VALID_DT_FROM ,
					  VALID_DT_TO ,
					  CREATED_BY ,
					  CREATED_DT ,
					  CHANGED_BY ,
					  CHANGED_DT
					)
				VALUES  ( @CostCenterCode,
						  @Description,
						  @Division,
						  @RespPerson,
						  cast(@ValidFrom as date),
						  '9999-12-31',
						  @UId,
						  GETDATE(),
						  NULL,
						  NULL
						)

                select 'True|Save Successfully'
			 end
		end
		else
		begin
			select 'Error|Fail to add Cost Center, because duplicate entries.'
		end
	end
END
ELSE
BEGIN
    --Begin Edit
    UPDATE dbo.TB_M_COST_CENTER
    SET COST_CENTER_DESC = @Description,
	    DIVISION_ID = @Division,
		RESP_PERSON = @RespPerson,
        VALID_DT_FROM = @ValidFrom,
        VALID_DT_TO = @ValidTo,
        CHANGED_BY = @UId,
        CHANGED_DT = GETDATE()
    WHERE COST_CENTER_CD = @CostCenterCode

	select 'True|Save Successfully'
END