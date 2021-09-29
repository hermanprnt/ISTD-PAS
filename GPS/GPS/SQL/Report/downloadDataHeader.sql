
select 
			A.PR_NO	
	,	b.PR_ITEM_NO
	,	c.PR_SUBITEM_NO
	,	a.DOC_DT as PR_DOC_DT
	,	a.PLANT_CD
	,	a.SLOC_CD
	,	b.MAT_NO
	,	b.MAT_DESC
	,	b.PR_QTY
	,	b.UNIT_OF_MEASURE_CD
	,	b.ORI_AMOUNT as PR_ORI_AMOUNT
	,	b.ORI_CURR_CD
	,	b.BUDGET_REF
	,	a.CREATED_BY
	,	d.PO_NO
	,	e.PO_ITEM_NO
	,	f.PO_SUBITEM_NO	
	,	d.PURCHASING_GRP_CD
	,	d.DOC_DT as PO_DOC_DT
	,	d.PO_CURR
	,	e.PO_QTY_ORI
	, 	e.UOM
	,	e.ORI_AMOUNT as PO_ORI_AMOUNT
	,	d.VENDOR_CD
	,	d.VENDOR_NAME
	,	g.MAT_DOC_NO
	,	g.MAT_DOC_ITEM_NO
	,	g.PO_SUBITEM_NO as GR_PO_SUBITEM_NO
	, 	g.DOCUMENT_DT
	,	g.GR_IR_AMOUNT
	,	h.INVOICE_NO as InvoiceNo
	,	h.INVOICE_DATE as InvoiceDate
	,	h.TOTAL_AMOUNT as InvoiceAmount
	,	h.CURRENCY as InvoiceCurrency
	,	null as ClearingNo
	,	null as ClearingDate	
	from 
	TB_R_PR_H A 
	inner join TB_R_PR_ITEM B on A.PR_NO=B.PR_NO
	left join TB_R_PR_SUBITEM C on A.PR_NO = c.PR_NO
	left join TB_R_PO_H D on b.PO_NO=d.PO_NO
	left join TB_R_PO_ITEM e on d.PO_NO=e.PO_NO
	left join TB_R_PO_SUBITEM f on d.PO_NO=f.PO_NO
	left join TB_R_GR_IR g on d.PO_NO = g.PO_NO
	left join TB_R_INVOICE_INFO h on h.GR_NUMBER = g.MAT_DOC_NO
	where 1=1 
	AND ISNULL(A.PR_NO, '') LIKE '%' + ISNULL(@PR_NO, '') + '%' 
	AND ISNULL(D.VENDOR_CD, '') LIKE '%' + ISNULL(@VENDOR, '') + '%' 
	AND ISNULL(A.CREATED_BY, '') LIKE '%' + ISNULL(@CREATED_BY, '') + '%' 
	AND ISNULL(d.PO_NO, '') LIKE '%' + ISNULL(@PO_NO, '') + '%' 
	AND ISNULL(g.MAT_DOC_NO, '') LIKE '%' + ISNULL(@GR_NO, '') + '%' 
	AND a.DOC_DT BETWEEN convert(date,@PR_DATE_FROM) AND convert(date, @PR_DATE_TO)			
	--AND d.DOC_DT BETWEEN convert(date,@PO_DT) AND convert(date, @PO_DT_TO)
	--AND h.INVOICE_DATE BETWEEN convert(date,@INV_DT) AND convert(date, @INV_DT_TO)	
	--AND g.DOCUMENT_DT BETWEEN convert(date,@GR_DATE) AND convert(date, @GR_DATE_TO)	
	AND ISNULL(g.MAT_DOC_NO, '') LIKE '%' + ISNULL(@GR_NO, '') + '%' 
	AND ISNULL(h.INVOICE_NO, '') LIKE '%' + ISNULL(@INV_NO, '') + '%' 
	AND ISNULL(d.PURCHASING_GRP_CD, '') LIKE '%' + ISNULL(@PCS_GRP, '') + '%' 
	AND ISNULL(A.DIVISION_ID, '') = ''+ ISNULL(@DIVISION_ID, '') +'' 
	AND ISNULL(b.WBS_NO, '') LIKE '%' + ISNULL(@WBS_NO, '') + '%' 