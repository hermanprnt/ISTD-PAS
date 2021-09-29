DECLARE @@sqlstate varchar(max);
DECLARE @@CERTIFICATE_ID  varchar(50);

SET @@sqlstate = '';
SET @@CERTIFICATE_ID = @CERTIFICATE_ID;


SET @@sqlstate = @@sqlstate + '
	SELECT 
	 top 1
		[INVOICE_ID]
      ,[INVOICE_NO]
      ,[INVOICE_DATE]
      ,[TAX_INVOICE_NO]
      ,[CURRENCY]
      ,[TURN_OVER]
      ,[TAX_BASE]
      ,[CALCULATE_TAX]
      ,[CHECKBOX_STAMP]
      ,[TOTAL_AMOUNT]
      ,[STATUS]
      ,[PAYMENT_PLAN_DATE]
      ,[PAYMENT_ACTUAL_DATE]
      ,[NOTICE_BY]
      ,[NOTICE_REMARK]
      ,[NOTICE_DATE]
      ,[CERTIFICATE_ID]
      ,[RECEIVED_STATUS]
      ,[RECEIVED_DT]
      ,[TAX_INVOICE_AMOUNT]
	,inv.SUPPLIER_CD
	,SUPPLIER_NAME
	FROM TB_R_INVOICE inv
		left join TB_M_SUPPLIER s on s.SUPPLIER_CD = inv.SUPPLIER_CD
	where 1=1
	and STATUS = ''CREATED'' or STATUS = ''REJECTED'' 
		';

IF(@@CERTIFICATE_ID <> '')
BEGIN
	SET @@sqlstate = @@sqlstate + '
	and CERTIFICATE_ID = ''' + @@CERTIFICATE_ID + ''' ';
END

print(@@sqlstate);

execute(@@sqlstate);
