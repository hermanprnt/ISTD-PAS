CREATE PROCEDURE [dbo].[sp_POCommon_GetPOItemInfoTemp]
    @processId BIGINT,
    @poNo VARCHAR(11),
    @poItemNo INT,
    @seqItemNo INT
AS
BEGIN
    SELECT PO_QTY_NEW Qty, VALUATION_CLASS ValuationClass FROM TB_T_PO_ITEM
    WHERE PROCESS_ID = @processId AND ISNULL(PO_NO, '') = ISNULL(@poNo, '') AND ISNULL(PO_ITEM_NO, '') = ISNULL(@poItemNo, '') AND SEQ_ITEM_NO = @seqItemNo
END