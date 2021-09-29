CREATE PROCEDURE [dbo].[sp_POCommon_GetPOItemConditionTempList]
    @processId BIGINT,
    @poNo VARCHAR(11),
    @poItemNo VARCHAR(100),
    @seqItemNo VARCHAR(100)
AS
BEGIN
    WITH tmp AS (
        SELECT poct.COMP_TYPE CompPriceType, cmpp.COMP_PRICE_DESC, poct.COMP_PRICE_RATE CompPriceRate, cond.ConditionCategory,
            cond.ConditionCategoryName, poct.SEQ_NO, poct.COMP_PRICE_CD, poct.PO_NO, poct.PO_ITEM_NO, poct.QTY_PER_UOM, poct.PRICE_AMT Amount
        FROM TB_T_PO_CONDITION poct
        LEFT JOIN TB_M_COMP_PRICE cmpp ON poct.COMP_PRICE_CD = cmpp.COMP_PRICE_CD
        LEFT JOIN (SELECT 1 ConditionCategory, 'Fixed Amount' ConditionCategoryName
            UNION SELECT 2 ConditionCategory, 'By Qty' ConditionCategoryName
            UNION SELECT 3 ConditionCategory, 'Percentage' ConditionCategoryName
            UNION SELECT 4 ConditionCategory, 'Summary' ConditionCategoryName) cond
            ON poct.CALCULATION_TYPE = cond.ConditionCategory
        WHERE poct.PROCESS_ID = @processId AND ISNULL(poct.PO_NO, '') = ISNULL(@poNo, '') AND ISNULL(PO_ITEM_NO, '') = ISNULL(@poItemNo, '')
        AND SEQ_ITEM_NO = @seqItemNo AND DELETE_FLAG = 'N'
    )
    SELECT
        SEQ_NO DataNo, PO_NO PONo, PO_ITEM_NO POItemNo, CompPriceType, COMP_PRICE_CD CompPriceCode, COMP_PRICE_DESC CompPriceName,
        ConditionCategory, ConditionCategoryName, CompPriceRate, QTY_PER_UOM QtyPerUOM, Amount
    FROM tmp ORDER BY SEQ_NO
END