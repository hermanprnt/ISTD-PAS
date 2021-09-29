CREATE PROCEDURE [dbo].[sp_POCommon_GetPOItemConditionList]
    @poNo VARCHAR(11),
    @poItemNo VARCHAR(100)
AS
BEGIN
    WITH tmp AS (
        SELECT poc.COMP_TYPE CompPriceType, cmpp.COMP_PRICE_DESC, poc.COMP_PRICE_RATE CompPriceRate, cond.ConditionCategory,
            cond.ConditionCategoryName, poc.SEQ_NO, poc.COMP_PRICE_CD, poc.PO_NO, poc.PO_ITEM_NO, poc.QTY_PER_UOM, poc.PRICE_AMT Amount
        FROM TB_R_PO_CONDITION poc
        LEFT JOIN TB_M_COMP_PRICE cmpp ON poc.COMP_PRICE_CD = cmpp.COMP_PRICE_CD
        LEFT JOIN (SELECT 1 ConditionCategory, 'Fixed Amount' ConditionCategoryName
            UNION SELECT 2 ConditionCategory, 'By Qty' ConditionCategoryName
            UNION SELECT 3 ConditionCategory, 'Percentage' ConditionCategoryName
            UNION SELECT 4 ConditionCategory, 'Summary' ConditionCategoryName) cond
            ON poc.CALCULATION_TYPE = cond.ConditionCategory
        WHERE poc.PO_NO = @poNo AND PO_ITEM_NO = @poItemNo
    )
    SELECT
        SEQ_NO DataNo, PO_NO PONo, PO_ITEM_NO POItemNo, CompPriceType, COMP_PRICE_CD CompPriceCode, COMP_PRICE_DESC CompPriceName,
        ConditionCategory, ConditionCategoryName, CompPriceRate, QTY_PER_UOM QtyPerUOM, Amount
    FROM tmp ORDER BY SEQ_NO
END