DECLARE @@VAL INT ;
DECLARE @@ITEM INT;
DECLARE @@PO VARCHAR(20);


update 
	TB_R_GR_IR_FROM_SAP
set 
	GR_STATUS = 'CANCEL',
	CANCEL_DOC_NO = @CANCEL_DOC_NO,
	UPDATED_BY = @UPDATED_BY,
	UPDATED_DT = getdate()
where 
	1=1
and 
	MATDOC_NUMBER = @REF_DOC



