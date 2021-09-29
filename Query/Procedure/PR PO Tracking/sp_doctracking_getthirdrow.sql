-- ===================================================================
-- Author		: FID) Intan Puspitasari
-- Create date	: 13/07/2015
-- Description	: Get third row of document tracking list grid
-- ===================================================================
CREATE PROCEDURE [dbo].[sp_doctracking_getthirdrow] 
		@DOC_TYPE VARCHAR(10),
		@DOC_NO VARCHAR(MAX),
		@DOC_ITEM_NO VARCHAR(MAX)
AS
BEGIN
	IF(@DOC_TYPE = 'PR')
	BEGIN
		SELECT DISTINCT
			poh.PO_NO,
			poi.PO_ITEM_NO,
			poh.PO_NO + '_' + CAST((CAST(poi.PO_ITEM_NO AS INT)) AS VARCHAR) AS DOC_NO,
			@DOC_NO AS REFERENCE_DOC_NO,
			@DOC_ITEM_NO AS DOC_ITEM_NO,
			'PR' AS DOC_TYPE,
			poh.PO_DESC AS DOC_DESC,
			dbo.fn_date_format(poh.DOC_DT) AS DOC_DATE,
			ms.STATUS_DESC AS DOC_STATUS,
			dw.DOCUMENT_NO,
			dw.PIC_REGISTERED AS REGISTERED_BY,
			dbo.fn_date_format(dw.ACTUAL_REGISTERED) AS REGISTERED_DT,
			dw.PIC_SH AS ORG_SH_BY, 
			dbo.fn_date_format(dw.ACTUAL_SH) AS ORG_SH_DT,
			dw.PIC_DPH AS ORG_DPH_BY, 
			dbo.fn_date_format(dw.ACTUAL_DPH) AS ORG_DPH_DT,
			dw.PIC_DH AS ORG_DH_BY, 
			dbo.fn_date_format(dw.ACTUAL_DH) AS ORG_DH_DT
		from TB_R_PO_H poh 
			JOIN TB_M_STATUS ms ON poh.PO_STATUS = ms.STATUS_CD
			JOIN TB_R_PO_ITEM poi ON poh.PO_NO = poi.PO_NO AND poi.PR_NO = @DOC_NO AND poi.PR_ITEM_NO = @DOC_ITEM_NO
			LEFT JOIN
		(
			select DOCUMENT_NO, poi.PO_NO, poi.PO_ITEM_NO, col, value
			from TB_R_WORKFLOW rw JOIN TB_R_PO_H poh ON poh.PO_NO = rw.DOCUMENT_NO AND poh.PO_STATUS <> '47' AND poh.PO_STATUS <> '49'
								  JOIN TB_R_PO_ITEM poi ON poh.PO_NO = poi.PO_NO AND poi.PR_NO = @DOC_NO AND poi.PR_ITEM_NO = @DOC_ITEM_NO
			cross apply
			(
			--REGISTERED
			select 'PIC_REGISTERED', APPROVER_NAME WHERE DOCUMENT_NO = poh.PO_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '40' union all
			select 'ACTUAL_REGISTERED', CASE WHEN(IS_APPROVED <> 'Y') THEN NULL ELSE CONVERT(VARCHAR, APPROVED_DT) END WHERE DOCUMENT_NO = poh.PO_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '40' union all
			--SH
			select 'PIC_SH', APPROVER_NAME WHERE DOCUMENT_NO = poh.PO_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD ='41' union all
			select 'ACTUAL_SH', CASE WHEN(IS_APPROVED <> 'Y') THEN NULL ELSE CONVERT(VARCHAR, APPROVED_DT) END WHERE DOCUMENT_NO = poh.PO_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '41' union all
			--DpH
			select 'PIC_DPH', APPROVER_NAME WHERE DOCUMENT_NO = poh.PO_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '42' union all
			select 'ACTUAL_DPH', CASE WHEN(IS_APPROVED <> 'Y') THEN NULL ELSE CONVERT(VARCHAR, APPROVED_DT) END WHERE DOCUMENT_NO = poh.PO_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '42' union all
			--DH
			select 'PIC_DH', APPROVER_NAME WHERE DOCUMENT_NO = poh.PO_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '43' union all
			select 'ACTUAL_DH', CASE WHEN(IS_APPROVED <> 'Y') THEN NULL ELSE CONVERT(VARCHAR, APPROVED_DT) END WHERE DOCUMENT_NO = poh.PO_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '43'
			) c (col, value) 
		) x
		pivot 
		(
			max(value)
			for col in (PIC_REGISTERED, ACTUAL_REGISTERED, 
						PIC_SH, ACTUAL_SH,
						PIC_DPH, ACTUAL_DPH,
						PIC_DH, ACTUAL_DH)
		) dw ON poh.PO_NO = dw.DOCUMENT_NO 
			 ORDER BY poh.PO_NO, poi.PO_ITEM_NO ASC
	END
	ELSE --PO
	BEGIN
		SELECT DISTINCT
			@DOC_NO AS REFERENCE_DOC_NO,
			@DOC_ITEM_NO AS DOC_ITEM_NO,
			gi.MAT_DOC_NO AS DOC_NO,
			gi.HEADER_TEXT AS DOC_DESC,
			'PO' AS DOC_TYPE,
			dbo.fn_date_format(gi.DOCUMENT_DT) AS DOC_DATE,
			ms.STATUS_DESC AS DOC_STATUS
		FROM TB_R_GR_IR gi JOIN TB_M_STATUS ms ON gi.STATUS_CD = ms.STATUS_CD 
		WHERE gi.PO_NO = @DOC_NO AND gi.PO_ITEM = @DOC_ITEM_NO AND gi.CONDITION_CATEGORY = 'H'
	END
END