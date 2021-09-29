



with tmp AS (
	select 
		ROW_NUMBER() OVER (ORDER BY A.PR_NO DESC) Data_No
	
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
) SELECT count(*) FROM tmp 