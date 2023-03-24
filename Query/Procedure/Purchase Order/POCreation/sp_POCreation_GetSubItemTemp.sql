ALTER PROCEDURE [dbo].[sp_POCreation_GetSubItemTemp]
    @processId BIGINT,
    @poNo VARCHAR(11),
    @poItemNo INT,
    @seqItemNo INT
AS
BEGIN
    SELECT
    ROW_NUMBER() OVER (ORDER BY posit.PO_NO ASC, posit.PO_ITEM_NO ASC, posit.SEQ_ITEM_NO ASC, posit.PO_SUBITEM_NO ASC) DataNo,
    posit.PO_NO PONo,
    posit.PO_ITEM_NO POItemNo,
    posit.PO_SUBITEM_NO POSubItemNo,
    posit.SEQ_ITEM_NO SeqItemNo,
    posit.SEQ_NO SeqNo,
    '' ValuationClass,
    posit.WBS_NO WBSNo,
    posit.COST_CENTER_CD CostCenter,
    posit.GL_ACCOUNT GLAccount,
    posit.MAT_NO MatNo,
    posit.MAT_DESC MatDesc,
    posit.PRICE_PER_UOM PricePerUOM,
    posit.AMOUNT PriceAmount,
    posit.UOM,
    posit.PO_QTY_REMAIN Qty,
    CASE WHEN (ISNULL(poh.SYSTEM_SOURCE, '') <> '' AND poh.SYSTEM_SOURCE <> 'GPS') OR posit.PO_QTY_USED > 0
		THEN 1 ELSE 0 END IsLocked
    FROM TB_T_PO_SUBITEM posit
    LEFT JOIN TB_R_PO_H poh ON posit.PO_NO = poh.PO_NO
    WHERE posit.PROCESS_ID = @processId
    AND ISNULL(posit.PO_NO, '') = ISNULL(@poNo, '')
    AND ISNULL(posit.PO_ITEM_NO, '') = ISNULL(@poItemNo, '')
    AND posit.SEQ_ITEM_NO = @seqItemNo
    AND posit.DELETE_FLAG <> 'Y'
END