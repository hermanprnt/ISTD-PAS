DELETE FROM TB_M_QUOTA
WHERE DIVISION_ID =  @DivisionID and QUOTA_TYPE = @QuotaType

select 'True|Delete successfully'

