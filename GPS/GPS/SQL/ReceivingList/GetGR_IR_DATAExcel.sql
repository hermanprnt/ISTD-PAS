DECLARE @@sqlstate varchar(max) = '';

SET @@sqlstate = @@sqlstate + '
	select 
		gr.PO_NO
		,gr.PO_ITEM
		,gr.MAT_DOC_NO
		,gr.GR_IR_AMOUNT
		,gr.VENDOR_CD
		,gr.MATERIAL_DESCRIPTION
		,gr.UNIT_OF_MEASURE_CD
		,gr.CANCEL_STATUS
		,gr.PO_DT
		,gr.STATUS_CD
		,gr.CREATED_BY
	from 
		TB_R_GR_IR gr
	where 1=1 ';

IF(@PO_NO <> '')
BEGIN
	SET @@sqlstate = @@sqlstate + '
	and gr.PO_NO like ''%'+ @PO_NO + '%'' ';
END

IF(@SUPPLIER <> '')
BEGIN
	SET @@sqlstate = @@sqlstate + '
	and gr.VENDOR_CD in ('+@SUPPLIER+') ';
END

IF(@STATUS <> '')
BEGIN
	SET @@sqlstate = @@sqlstate + '
	and gr.STATUS_CD in ('+@STATUS+') ';
END

IF(@PO_DT_FROM <> '')
BEGIN
	SET @@sqlstate = @@sqlstate + '
	and CAST(gr.PO_DT as DATE) >= CAST(CONVERT(datetime, ''' + @PO_DT_FROM + ''' , 104) as DATE)';
END

IF(@PO_DT_TO <> '')
BEGIN
	SET @@sqlstate = @@sqlstate + '
	and CAST(gr.PO_DT as DATE) <= CAST(CONVERT(datetime, ''' + @PO_DT_TO + ''' , 104) as DATE)';
END

print(@@sqlstate);

execute(@@sqlstate);
