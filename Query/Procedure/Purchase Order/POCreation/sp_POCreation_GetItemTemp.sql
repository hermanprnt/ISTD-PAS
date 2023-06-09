/****** Object:  StoredProcedure [dbo].[sp_POCreation_GetItemTemp]    Script Date: 9/7/2017 9:13:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_POCreation_GetItemTemp]
    @processId BIGINT
AS
BEGIN
    SELECT
        ROW_NUMBER() OVER (ORDER BY poit.PO_NO ASC, poit.PO_ITEM_NO ASC, poit.SEQ_ITEM_NO ASC) DataNo,
        ISNULL(poit.PO_NO, '') PONo,
        ISNULL(CAST(poit.PO_ITEM_NO AS VARCHAR), '') POItemNo,
        poit.SEQ_ITEM_NO SeqItemNo,
        poit.PR_NO PRNo,
        poit.PR_ITEM_NO PRItemNo,
        poit.VALUATION_CLASS ValuationClass,
        CASE WHEN poit.WBS_NO = 'X' THEN ''
        ELSE poit.WBS_NO END WBSNo,
        CASE WHEN poit.COST_CENTER_CD = 'X' THEN ''
        ELSE poit.COST_CENTER_CD END CostCenter,
        CASE WHEN poit.GL_ACCOUNT = 'X' THEN ''
        ELSE poit.GL_ACCOUNT END GLAccount,
        CASE WHEN poit.MAT_NO = 'X' THEN ''
        ELSE poit.MAT_NO END MatNo,
        poit.MAT_DESC MatDesc,
        poit.NEW_PRICE_PER_UOM PricePerUOM,
        poit.NEW_AMOUNT PriceAmount,
        poit.UOM,
        poit.DELIVERY_PLAN_DT DeliveryPlanDate,
        poit.PO_QTY_NEW Qty,
        poit.PLANT_CD Plant,
        poit.SLOC_CD SLoc,
        (SELECT CASE WHEN COUNT(0) > 0 THEN 1 ELSE 0 END
        FROM TB_T_PO_SUBITEM WHERE PROCESS_ID = @processId
        AND SEQ_ITEM_NO = poit.SEQ_ITEM_NO) HasItem,
        poit.CURR_CD Currency,
        CASE WHEN ISNULL(prh.URGENT_DOC, 'N') = 'N' THEN 0 ELSE 1 END IsUrgent,
        CASE WHEN ISNULL(poit.ITEM_CLASS, 'M') = 'M' THEN 0 ELSE 1 END IsService,
        CASE WHEN (ISNULL(poh.SYSTEM_SOURCE, '') <> '' AND poh.SYSTEM_SOURCE <> 'GPS' AND poh.SYSTEM_SOURCE <> 'ECatalogue') OR poit.PO_QTY_USED > 0
			THEN 1 ELSE 0 END IsLocked
    FROM TB_T_PO_ITEM poit
    LEFT JOIN TB_R_PO_H poh ON poit.PO_NO = poh.PO_NO
    LEFT JOIN TB_R_PR_H prh ON poit.PR_NO = prh.PR_NO
    WHERE poit.PROCESS_ID = @processId AND poit.DELETE_FLAG <> 'Y'
END
