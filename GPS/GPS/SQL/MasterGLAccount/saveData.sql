
if @glAccountCd is null or len(@glAccountCd)<1 
begin 
	select 'Error|GL Account Code should be not null'
	return
end

if (@flag = 'ADD')
 begin 
	if not exists(select 1 from TB_M_GL_ACCOUNT where GL_ACCOUNT_CD = @glAccountCd)
	begin
		INSERT INTO TB_M_GL_ACCOUNT
		(
			GL_ACCOUNT_CD,
			GL_ACCOUNT_DESC,
			PLANT_CD,
			CREATED_BY,
			CREATED_DT
		)
		VALUES
		(
			@glAccountCd,
			@glAccountDesc,
			@plaantCD,
			@getuser,
			GETDATE()
		)


		select 'True|succesfully'

	end
	else 
	begin
		select 'Error|Fail to add GL Account , because duplicate enntries with GL Account Code = '+ @glAccountCd
	end
 end
