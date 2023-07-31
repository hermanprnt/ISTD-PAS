SELECT DISTINCT gr.MAT_DOC_NO ReceivingNo,
poh.VENDOR_NAME VendorName,
gra.ATTACHMENT_DOC_FILE_NM AttachmentFilename,
gra.OTHER_ATTACHMENT_DOC_FILE_NM OtherAttachmentFilename,
ISNULL(replace(convert(varchar(8), gra.CHANGED_DT, 112)+convert(varchar(8), gra.CHANGED_DT, 114), ':',''), '') ChangeDtParam
FROM TB_R_GR_IR gr
JOIN TB_R_PO_H poh ON gr.PO_NO = poh.PO_NO
LEFT JOIN TB_R_GR_IR_ATTACHMENT gra ON gr.MAT_DOC_NO = gra.MAT_DOC_NO
WHERE gr.MAT_DOC_NO = @ReceivingNo AND COMPONENT_PRICE_CD = 'PB00'