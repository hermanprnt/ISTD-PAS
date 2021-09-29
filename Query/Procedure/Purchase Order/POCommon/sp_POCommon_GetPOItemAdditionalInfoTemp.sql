CREATE PROCEDURE [dbo].[sp_POCommon_GetPOItemAdditionalInfoTemp]
    @processId BIGINT,
    @poNo VARCHAR(11),
    @poItemNo VARCHAR(5),
    @seqItemNo INT
AS
BEGIN
    SELECT
    PLANT_CD Plant,
    SLOC_CD Sloc,
    DELIVERY_PLAN_DT DeliveryPlanDate
    FROM TB_T_PO_ITEM
    WHERE PROCESS_ID = @processId
    AND ISNULL(PO_NO, '') = ISNULL(@poNo, '')
    AND ISNULL(PO_ITEM_NO, '') = ISNULL(@poItemNo, '')
    AND SEQ_ITEM_NO = @seqItemNo
END