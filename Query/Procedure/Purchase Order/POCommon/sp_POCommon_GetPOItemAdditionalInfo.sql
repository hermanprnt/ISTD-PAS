CREATE PROCEDURE [dbo].[sp_POCommon_GetPOItemAdditionalInfo]
    @poNo VARCHAR(11),
    @poItemNo VARCHAR(5)
AS
BEGIN
    SELECT
    PLANT_CD Plant,
    SLOC_CD Sloc,
    DELIVERY_PLAN_DT DeliveryPlanDate
    FROM TB_R_PO_ITEM
    WHERE PO_NO = @poNo
    AND PO_ITEM_NO = @poItemNo
END