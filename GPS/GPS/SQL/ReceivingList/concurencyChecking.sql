IF ((SELECT ISNULL(replace(convert(varchar(8), CHANGED_DT, 112)+convert(varchar(8), CHANGED_DT, 114), ':',''), '')
FROM TB_R_GR_IR_ATTACHMENT WHERE MAT_DOC_NO = @ReceivingNo) <> @ChangeDtParam)
BEGIN
	SELECT 1
END ELSE
BEGIN
	SELECT 0
END