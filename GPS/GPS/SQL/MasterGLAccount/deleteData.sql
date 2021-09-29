insert into TB_H_GL_ACCOUNT
	select GL_ACCOUNT_CD, GL_ACCOUNT_DESC, PLANT_CD, @userName, getdate() from TB_M_GL_ACCOUNT where GL_ACCOUNT_CD = @glAccountCode ;

Delete FROM TB_M_GL_ACCOUNT
Where GL_ACCOUNT_CD = @glAccountCode;

select 'True|Delete Successfully'