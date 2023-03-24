if (@ValidTo <> '9999-12-31')
  select 'Error|Only active Cost Center can be deleted'
else
begin
 DELETE FROM TB_M_COST_CENTER
 WHERE COST_CENTER_CD = @CostCenterCode AND VALID_DT_FROM = @ValidFrom

 update TB_M_COST_CENTER 
 set VALID_DT_TO = '9999-12-31',
     CHANGED_BY = @UId,
	 CHANGED_DT = GETDATE()
  where COST_CENTER_CD = @CostCenterCode and 
        VALID_DT_TO = cast(cast(@ValidFrom as datetime) - 1 as date)
 
  select 'True|Delete successfully'
end