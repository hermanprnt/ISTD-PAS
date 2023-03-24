-- ===================================================================
-- Author		: FID) Intan Puspitasari
-- Create date	: 30/06/2015
-- Description	: Get document tracking list 
-- ===================================================================
CREATE PROCEDURE [dbo].[sp_doctracking_getheader] 
		@DOC_TYPE VARCHAR(10),
		@DOC_STATUS VARCHAR(5),
		@DOC_DATE_FROM VARCHAR(MAX),
		@DOC_DATE_TO VARCHAR(MAX),
		@DOC_DESC VARCHAR(MAX),
		@DOC_NO VARCHAR(MAX),
		@REGISTERED_BY VARCHAR(MAX),
		@Start INT, 
		@Length INT
AS
BEGIN
	DECLARE @LIMIT INT

	--TO DO : SELECT @LIMIT = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SELECTED_DATA'
	SELECT @LIMIT = CAST(ISNULL(SYSTEM_VALUE, '0') AS INT)  FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH'

	IF(@DOC_TYPE = 'PR')
	BEGIN
		SELECT * FROM (
			SELECT TOP (@LIMIT)
				   ROW_NUMBER() OVER (ORDER BY prh.DOC_DT DESC, prh.CREATED_DT DESC) AS Number,
				   '' AS REFERENCE_DOC_NO,
				   prh.PR_NO AS DOC_NO,
				   'PR' AS DOC_TYPE,
				   prh.PR_DESC AS DOC_DESC,
				   dbo.fn_date_format(prh.DOC_DT) AS DOC_DATE,
				   ms.STATUS_DESC AS DOC_STATUS
			FROM TB_R_PR_H prh JOIN TB_M_STATUS ms ON prh.PR_STATUS = ms.STATUS_CD
			WHERE ((prh.PR_STATUS = ISNULL(@DOC_STATUS, '')
						AND isnull(@DOC_STATUS, '') <> ''''
						OR (isnull(@DOC_STATUS, '') = '')))
				  AND ((prh.DOC_DT >= ISNULL(@DOC_DATE_FROM,'')
						AND isnull(@DOC_DATE_FROM, '') <> ''
						OR (isnull(@DOC_DATE_FROM, '') = '')))
				  AND ((prh.DOC_DT <= ISNULL(@DOC_DATE_TO,'')
						AND isnull(@DOC_DATE_TO, '') <> ''
						OR (isnull(@DOC_DATE_TO, '') = '')))
				  AND ((prh.PR_DESC LIKE '%' + ISNULL(@DOC_DESC,'') + '%'
						AND isnull(@DOC_DESC, '') <> ''
						OR (isnull(@DOC_DESC, '') = '')))
				  AND ((prh.PR_NO LIKE '%' + ISNULL(@DOC_NO,'') + '%'
						AND isnull(@DOC_NO, '') <> ''
						OR (isnull(@DOC_NO, '') = '')))
				  AND ((prh.CREATED_BY LIKE '%' + ISNULL(@REGISTERED_BY,'') + '%'
						AND isnull(@REGISTERED_BY, '') <> ''
						OR (isnull(@REGISTERED_BY, '') = '')))
				  AND prh.PR_STATUS <> '94' AND prh.PR_STATUS <> '95' AND prh.PR_STATUS <> '00'
			)dt WHERE Number >= @Start AND Number <= @Length
	END
	ELSE --PO
	BEGIN
		SELECT * FROM (
			SELECT DISTINCT TOP(@LIMIT)
				ROW_NUMBER() OVER (ORDER BY poh.DOC_DT DESC, poh.CREATED_DT DESC) AS Number,
				'' AS REFERENCE_DOC_NO,
				poh.PO_NO AS DOC_NO, PIC_REGISTERED, 
				'PO' AS DOC_TYPE,
				poh.PO_DESC AS DOC_DESC,
				dbo.fn_date_format(poh.DOC_DT) AS DOC_DATE,
				ms.STATUS_DESC AS DOC_STATUS,
				dw.PIC_REGISTERED AS REGISTERED_BY,
				ISNULL(dbo.fn_date_format(dw.ACTUAL_REGISTERED), '-') AS REGISTERED_DT,
				dw.PIC_SH AS ORG_SH_BY, 
				ISNULL(dbo.fn_date_format(dw.ACTUAL_SH), '-') AS ORG_SH_DT,
				dw.PIC_DPH AS ORG_DPH_BY, 
				ISNULL(dbo.fn_date_format(dw.ACTUAL_DPH), '-') AS ORG_DPH_DT,
				dw.PIC_DH AS ORG_DH_BY, 
				ISNULL(dbo.fn_date_format(dw.ACTUAL_DH), '-') AS ORG_DH_DT
			from 
			(
				select DOCUMENT_NO, col, value
				from TB_R_WORKFLOW rw JOIN TB_R_PO_H poh ON poh.PO_NO = rw.DOCUMENT_NO AND poh.PO_STATUS <> '47' AND poh.PO_STATUS <> '49'
				cross apply
				(
				--REGISTERED
				select 'PIC_REGISTERED', APPROVER_NAME WHERE DOCUMENT_NO = poh.PO_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '40' union all
				select 'ACTUAL_REGISTERED', CASE WHEN(IS_APPROVED <> 'Y') THEN NULL ELSE CONVERT(VARCHAR, APPROVED_DT) END WHERE DOCUMENT_NO = poh.PO_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '40' union all
				--SH
				select 'PIC_SH', APPROVER_NAME WHERE DOCUMENT_NO = poh.PO_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '41' union all
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
			) dw JOIN TB_R_PO_H poh ON poh.PO_NO = dw.DOCUMENT_NO
				 JOIN TB_M_STATUS ms ON poh.PO_STATUS = ms.STATUS_CD
			WHERE poh.PO_STATUS <> '47' AND poh.PO_STATUS <> '49'
				  AND ((poh.PO_STATUS = ISNULL(@DOC_STATUS, '')
						AND isnull(@DOC_STATUS, '') <> ''''
						OR (isnull(@DOC_STATUS, '') = '')))
				  AND ((poh.DOC_DT >= ISNULL(@DOC_DATE_FROM,'')
						AND isnull(@DOC_DATE_FROM, '') <> ''
						OR (isnull(@DOC_DATE_FROM, '') = '')))
				  AND ((poh.DOC_DT <= ISNULL(@DOC_DATE_TO,'')
						AND isnull(@DOC_DATE_TO, '') <> ''
						OR (isnull(@DOC_DATE_TO, '') = '')))
				  AND ((poh.PO_DESC LIKE '%' + ISNULL(@DOC_DESC,'') + '%'
						AND isnull(@DOC_DESC, '') <> ''
						OR (isnull(@DOC_DESC, '') = '')))
				  AND ((poh.PO_NO LIKE '%' + ISNULL(@DOC_NO,'') + '%'
						AND isnull(@DOC_NO, '') <> ''
						OR (isnull(@DOC_NO, '') = '')))
				  AND ((poh.CREATED_BY LIKE '%' + ISNULL(@REGISTERED_BY,'') + '%'
						AND isnull(@REGISTERED_BY, '') <> ''
						OR (isnull(@REGISTERED_BY, '') = '')))
		)dt WHERE Number >= @Start AND Number <= @Length
	END
END