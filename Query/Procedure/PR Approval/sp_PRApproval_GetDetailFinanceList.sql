USE [PAS_DB]
GO
/****** Object:  StoredProcedure [dbo].[sp_PRApproval_GetDetailFinanceList]    Script Date: 3/8/2021 8:52:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_PRApproval_GetDetailFinanceList]
		@PR_NO varchar(11)='5000041131',
		@start bigint=1,
		@length bigint=10
AS
BEGIN
DECLARE @@STATUS_SH CHAR(2),
		@@STATUS_DPH CHAR(2),
		@@STATUS_DH CHAR(2),
		@@STATUS_LAST_COORD CHAR(2),
		@@APPROVED_LAST_COORD VARCHAR(20),
		@@DOC_NO VARCHAR(MAX)



SET @@DOC_NO = @PR_NO

DECLARE @@STATUS TABLE(
			SEQ INT,
			STATUS_CD CHAR(2)
		)

INSERT INTO @@STATUS
	SELECT ROW_NUMBER() OVER (ORDER BY STATUS_CD) AS SEQ,
		   STATUS_CD FROM TB_M_STATUS WHERE SEGMENTATION_CD = 3

SELECT TOP 1 @@STATUS_LAST_COORD = STATUS_CD, @@APPROVED_LAST_COORD = APPROVED_BY FROM TB_R_WORKFLOW W JOIN 
		   TB_M_STATUS S ON W.APPROVAL_CD = S.STATUS_CD AND S.SEGMENTATION_CD = 2 AND W.DOCUMENT_NO = @@DOC_NO
		   AND IS_DISPLAY = 'Y' ORDER BY W.ITEM_NO, W.DOCUMENT_SEQ DESC


IF EXISTS (SELECT TOP 1 1 FROM TB_R_WORKFLOW W JOIN TB_M_STATUS S ON W.APPROVAL_CD = S.STATUS_CD AND S.SEGMENTATION_CD = 1 AND W.DOCUMENT_NO = @@DOC_NO 
		   AND IS_DISPLAY = 'Y' AND APPROVED_BY = @@APPROVED_LAST_COORD AND STATUS_CD = 12 ORDER BY W.ITEM_NO, W.DOCUMENT_SEQ DESC)
BEGIN
	SELECT TOP 1 @@STATUS_LAST_COORD = STATUS_CD, @@APPROVED_LAST_COORD = APPROVED_BY FROM TB_R_WORKFLOW W JOIN 
		   TB_M_STATUS S ON W.APPROVAL_CD = S.STATUS_CD AND S.SEGMENTATION_CD = 1 AND W.DOCUMENT_NO = @@DOC_NO 
		   AND IS_DISPLAY = 'Y' ORDER BY W.ITEM_NO, W.DOCUMENT_SEQ DESC
END

SELECT @@STATUS_SH = STATUS_CD FROM @@STATUS WHERE SEQ = 1
SELECT @@STATUS_DPH = STATUS_CD FROM @@STATUS WHERE SEQ = 2
SELECT @@STATUS_DH = STATUS_CD FROM @@STATUS WHERE SEQ = 3

SELECT*FROM(
SELECT ROW_NUMBER() OVER (ORDER BY TBL.ITEM_NO ASC) AS NUMBER,
	CAST(CAST(TBL.ITEM_NO AS INT) AS VARCHAR) AS ITEM_NO,
	
	SH.PIC_SH, 
	SH.PLAN_SH, 
	[dbo].[fn_date_format] (SH.ACTUAL_SH) AS ACTUAL_SH, 
	SH.PLNLT_SH,
	CASE WHEN (ISNULL(ACTUAL_COORD, '') <> '') THEN [dbo].[fn_datediff_workday](ACTUAL_COORD, ACTUAL_SH) END AS ACTLT_SH

FROM

(SELECT DISTINCT ITEM_NO FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @PR_NO ) AS TBL
LEFT JOIN
--
(SELECT ITEM_NO, 
	   CONVERT(VARCHAR, APPROVED_DT) AS ACTUAL_COORD
FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @@DOC_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = @@STATUS_LAST_COORD) AS COORD ON COORD.ITEM_NO=TBL.ITEM_NO
LEFT JOIN 
--
(SELECT ITEM_NO, 
	   CASE WHEN(ISNULL(APPROVED_BYPASS, '') <> '' AND ISNULL(APPROVED_BYPASS, '') <> APPROVED_BY) THEN (SELECT ISNULL(PERSONNEL_NAME, '') FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = APPROVED_BYPASS) ELSE APPROVER_NAME END AS PIC_SH, 
	   [dbo].[fn_date_format]([dbo].[fn_dateadd_workday]((APPROVAL_INTERVAL-1)*(-1), INTERVAL_DATE)) AS PLAN_SH,
	   CASE WHEN(IS_APPROVED <> 'Y') THEN NULL ELSE CONVERT(VARCHAR, APPROVED_DT) END AS ACTUAL_SH,
	   CONVERT(VARCHAR, APPROVAL_INTERVAL) AS PLNLT_SH
FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @PR_NO AND IS_DISPLAY = 'Y' AND APPROVAL_CD = @@STATUS_SH) AS SH ON SH.ITEM_NO=TBL.ITEM_NO

)AS D
WHERE D.NUMBER >= @start AND D.NUMBER <= @length
END