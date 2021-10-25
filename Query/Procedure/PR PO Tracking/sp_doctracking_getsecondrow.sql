﻿-- ===================================================================
-- Author		: FID) Intan Puspitasari
-- Create date	: 30/06/2015
-- Description	: Get second row of document tracking list grid
-- ===================================================================
CREATE PROCEDURE [dbo].[sp_doctracking_getsecondrow] 
		@DOC_TYPE VARCHAR(10),
		@DOC_NO VARCHAR(MAX)
AS
BEGIN
	IF(@DOC_TYPE = 'PR')
	BEGIN
		SELECT DISTINCT
			'-' AS REFERENCE_DOC_NO,
			CASE WHEN (SELECT COUNT(1) FROM TB_R_PO_ITEM WHERE PR_NO = @DOC_NO AND PR_ITEM_NO = ITEM_NO) > 0 THEN 'Y' ELSE 'N' END AS IS_HAVE_CHILD,
			DOCUMENT_NO AS DOC_NO,
			ITEM_NO AS DOC_ITEM_NO, 
			'PR' AS DOC_TYPE,
			pri.MAT_DESC AS DOC_DESC,
			'' AS DOC_DATE,
			ms.STATUS_DESC AS DOC_STATUS,
			dw.REGISTERED_BY,
			dbo.fn_date_format(dw.REGISTERED_DT) AS REGISTERED_DT,
			dw.ORG_SH_BY, 
			dbo.fn_date_format(dw.ORG_SH_DT) AS ORG_SH_DT,
			dw.ORG_DPH_BY, 
			dbo.fn_date_format(dw.ORG_DPH_DT) AS ORG_DPH_DT,
			dw.ORG_DH_BY, 
			dbo.fn_date_format(dw.ORG_DH_DT) AS ORG_DH_DT,
			dw.COOR_STAFF_BY, 
			dbo.fn_date_format(dw.COOR_STAFF_DT) AS COOR_STAFF_DT,
			dw.COOR_SH_BY, 
			dbo.fn_date_format(dw.COOR_SH_DT) AS COOR_SH_DT,
			dw.COOR_DPH_BY, 
			dbo.fn_date_format(dw.COOR_DPH_DT) AS COOR_DPH_DT,
			dw.COOR_DH_BY, 
			dbo.fn_date_format(dw.COOR_DH_DT) AS COOR_DH_DT,
			dw.FD_STAFF_BY,
			dbo.fn_date_format(dw.FD_STAFF_DT) AS FD_STAFF_DT,
			'' AS FD_SH_BY, 
			'-' AS FD_SH_DT
		from 
		(
			select DOCUMENT_NO, ITEM_NO, col, value
			from TB_R_WORKFLOW rw JOIN TB_R_PR_ITEM pri ON pri.PR_NO = rw.DOCUMENT_NO AND pri.PR_NO = @DOC_NO AND pri.PR_ITEM_NO = rw.ITEM_NO
			cross apply
			(
			--REGISTERED
			select 'REGISTERED_BY', APPROVER_NAME WHERE DOCUMENT_NO = pri.PR_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '10' union all
			select 'REGISTERED_DT', CASE WHEN(IS_APPROVED <> 'Y') THEN NULL ELSE CONVERT(VARCHAR, APPROVED_DT) END WHERE DOCUMENT_NO = pri.PR_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '10' union all
			--ORG SH
			select 'ORG_SH_BY', APPROVER_NAME WHERE DOCUMENT_NO = pri.PR_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '11' union all
			select 'ORG_SH_DT', CASE WHEN(IS_APPROVED <> 'Y') THEN NULL ELSE CONVERT(VARCHAR, APPROVED_DT) END WHERE DOCUMENT_NO = pri.PR_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '11' union all
			--ORG DpH
			select 'ORG_DPH_BY', APPROVER_NAME WHERE DOCUMENT_NO = pri.PR_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '12' union all
			select 'ORG_DPH_DT', CASE WHEN(IS_APPROVED <> 'Y') THEN NULL ELSE CONVERT(VARCHAR, APPROVED_DT) END WHERE DOCUMENT_NO = pri.PR_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '12' union all
			--ORG DH
			select 'ORG_DH_BY', APPROVER_NAME WHERE DOCUMENT_NO = pri.PR_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '13' union all
			select 'ORG_SH_DT', CASE WHEN(IS_APPROVED <> 'Y') THEN NULL ELSE CONVERT(VARCHAR, APPROVED_DT) END WHERE DOCUMENT_NO = pri.PR_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '13' union all
			--COOR Staff
			select 'COOR_STAFF_BY', APPROVER_NAME WHERE DOCUMENT_NO = pri.PR_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '20' union all
			select 'COOR_STAFF_DT', CASE WHEN(IS_APPROVED <> 'Y') THEN NULL ELSE CONVERT(VARCHAR, APPROVED_DT) END WHERE DOCUMENT_NO = pri.PR_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '20' union all
			--COOR SH
			select 'COOR_SH_BY', APPROVER_NAME WHERE DOCUMENT_NO = pri.PR_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '21' union all
			select 'COOR_SH_DT', CASE WHEN(IS_APPROVED <> 'Y') THEN NULL ELSE CONVERT(VARCHAR, APPROVED_DT) END WHERE DOCUMENT_NO = pri.PR_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '21' union all
			--COOR DPH
			select 'COOR_DPH_BY', APPROVER_NAME WHERE DOCUMENT_NO = pri.PR_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '22' union all
			select 'COOR_DPH_DT', CASE WHEN(IS_APPROVED <> 'Y') THEN NULL ELSE CONVERT(VARCHAR, APPROVED_DT) END WHERE DOCUMENT_NO = pri.PR_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '22' union all
			--COOR DH
			select 'COOR_DH_BY', APPROVER_NAME WHERE DOCUMENT_NO = pri.PR_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '23' union all
			select 'COOR_DH_DT', CASE WHEN(IS_APPROVED <> 'Y') THEN NULL ELSE CONVERT(VARCHAR, APPROVED_DT) END WHERE DOCUMENT_NO = pri.PR_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '23' union all
			--FD SH
			select 'FD_STAFF_BY', APPROVER_NAME WHERE DOCUMENT_NO = pri.PR_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '30' union all
			select 'FD_STAFF_DT', CASE WHEN(IS_APPROVED <> 'Y') THEN NULL ELSE CONVERT(VARCHAR, APPROVED_DT) END WHERE DOCUMENT_NO = pri.PR_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = '30'
			) c (col, value) 
		) x
		pivot 
		(
			max(value)
			for col in (REGISTERED_BY, REGISTERED_DT, 
						ORG_SH_BY, ORG_SH_DT,
						ORG_DPH_BY, ORG_DPH_DT,
						ORG_DH_BY, ORG_DH_DT,
						COOR_STAFF_BY, COOR_STAFF_DT,
						COOR_SH_BY, COOR_SH_DT,
						COOR_DPH_BY, COOR_DPH_DT,
						COOR_DH_BY, COOR_DH_DT,
						FD_STAFF_BY, FD_STAFF_DT)
		) dw JOIN TB_R_PR_ITEM pri ON pri.PR_NO = dw.DOCUMENT_NO AND pri.PR_ITEM_NO = dw.ITEM_NO
				JOIN TB_M_STATUS ms ON pri.PR_STATUS = ms.STATUS_CD
		WHERE pri.PR_NO = @DOC_NO order by ITEM_NO ASC
	END
	ELSE --PO
	BEGIN
		SELECT DISTINCT
			CASE WHEN(ISNULL(poi.PR_NO, '') = '') THEN '-' ELSE poi.PR_NO + '_' + CAST((CAST(poi.PR_ITEM_NO AS INT)) AS VARCHAR) END AS REFERENCE_DOC_NO,
			CASE WHEN (SELECT COUNT(1) FROM TB_R_GR_IR WHERE PO_NO = @DOC_NO AND PO_ITEM = poi.PO_ITEM_NO AND CONDITION_CATEGORY = 'H') > 0 THEN 'Y' ELSE 'N' END AS IS_HAVE_CHILD,
			poi.PO_NO AS DOC_NO,
			'PO' AS DOC_TYPE,
			poi.PO_ITEM_NO AS DOC_ITEM_NO,
			poi.MAT_DESC AS DOC_DESC
		FROM TB_R_PO_ITEM poi WHERE poi.PO_NO = @DOC_NO ORDER BY poi.PO_ITEM_NO ASC
	END
END