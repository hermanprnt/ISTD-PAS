/****** Object:  UserDefinedFunction [dbo].[fnt_POGenerate_GetOutstandingList]    Script Date: 10/9/2017 9:00:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		FID.Intan Puspitasari
-- Create date: 23/12/2015
-- Description:	Get PO Condition for Data PO from other System (Called by Job SQL)
-- =============================================
ALTER FUNCTION [dbo].[fnt_POGenerate_GetOutstandingList]()
RETURNS @returnTable TABLE (
		PR_NO [varchar](10),
		PR_ITEM_NO [varchar](5),
		MAT_NO [varchar](23),
		VENDOR_CD [varchar](6),
		VENDOR_NAME [varchar](100),
		PURCHASING_GROUP_CD  [varchar](3),
		PROC_CHANNEL_CD [varchar](4),
		DELIVERY_ADDR VARCHAR(150),
		STATUS VARCHAR(20) DEFAULT 'OPEN'
		)
BEGIN

	DECLARE @PROCUREMENT_TYPE VARCHAR(2) = 'RM'

	INSERT INTO @returnTable (PR_NO, PR_ITEM_NO, MAT_NO, VENDOR_CD, VENDOR_NAME, PURCHASING_GROUP_CD, PROC_CHANNEL_CD, DELIVERY_ADDR)
	select pri.PR_NO, PR_ITEM_NO, MAT_NO, VENDOR_CD, VENDOR_NAME, mvc.PURCHASING_GROUP_CD, mvc.PROC_CHANNEL_CD, DELIVERY_ADDR
			from tb_r_pr_item pri 
			INNER JOIN TB_R_PR_H prh on prh.PR_NO = pri.PR_NO
			LEFT JOIN TB_M_VALUATION_CLASS mvc on mvc.VALUATION_CLASS = pri.VALUATION_CLASS AND mvc.PROCUREMENT_TYPE = @PROCUREMENT_TYPE AND mvc.PR_COORDINATOR = prh.PR_COORDINATOR
		where pri.PR_Status = '14' AND pri.OPEN_QTY>0
			  and ISNULL(pri.RELEASE_FLAG,'N') = 'Y' AND SOURCE_TYPE = 'ECatalogue'
			  AND (NOT EXISTS (SELECT 1 FROM TB_R_PO_ITEM WHERE PR_NO = pri.PR_NO  AND PR_ITEM_NO = pri.PR_ITEM_NO)
			 		OR (EXISTS (SELECT 1 FROM TB_R_PO_ITEM POI2 JOIN TB_R_PR_ITEM PRI2 ON PRI2.PR_NO = POI2.PR_NO AND PRI2.PR_ITEM_NO = POI2.PR_ITEM_NO  
								WHERE POI2.PR_NO = pri.PR_NO  AND POI2.PR_ITEM_NO = pri.PR_ITEM_NO AND PRI2.OPEN_QTY>0)))

	UPDATE temp SET
		VENDOR_CD = SLI.VENDOR_CD,
		VENDOR_NAME = VDR.VENDOR_NAME
	FROM @returnTable temp
	INNER JOIN TB_M_SOURCE_LIST SLI ON SLI.MAT_NO = temp.MAT_NO AND SLI.DELIVERY_ADDR =  temp.DELIVERY_ADDR AND SLI.DELETE_FLAG = 'N'
	INNER JOIN TB_M_VENDOR VDR ON VDR.VENDOR_CD = SLI.VENDOR_CD AND ISNULL(VDR.DELETION_FLAG,'N') = 'N'

	UPDATE temp SET
		STATUS = 'LOCK'
	FROM @returnTable temp
	INNER JOIN TB_T_PO_GENERATE_MONITORING pgm ON pgm.PR_NO = temp.PR_NO AND pgm.PR_ITEM_NO = temp.PR_ITEM_NO

	RETURN
END
