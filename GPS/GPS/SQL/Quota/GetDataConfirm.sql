select a.DOC_NO,a.SEQ_NO,a.DIVISION_ID,a.DT_MONTH,a.DST_TYPE,a.QUOTA_MONTH,a.QUOTA_TYPE,a.AMOUNT,a.CONFIRM_FLAG, b.TYPE_DESCRIPTION, a.QUOTA_MONTH as QUOTA_MONTH2
from TB_R_QUOTA_CONSUME a 
inner join TB_M_QUOTA b on a.DIVISION_ID = b.DIVISION_ID and a.DST_TYPE = b.QUOTA_TYPE
where a.DOC_NO = @Doc_No and
      a.CONFIRM_FLAG = @Confirm_Flag and
	  a.DT_MONTH = @ConsumeMonth and
	  a.DST_TYPE = @QuotaType and
	  a.DIVISION_ID = @DivisionID