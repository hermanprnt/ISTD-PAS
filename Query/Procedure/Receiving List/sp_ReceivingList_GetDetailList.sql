ALTER PROCEDURE [dbo].[sp_ReceivingList_GetDetailList]
    @receivingNo VARCHAR(11)
AS
BEGIN
    WITH tmp AS (
        SELECT
        ROW_NUMBER() OVER (ORDER BY gr.MAT_DOC_NO, gr.PO_NO, gr.PO_ITEM) DataNo,
        gr.MAT_DOC_NO ReceivingNo,
        gr.HEADER_TEXT HeaderText,
        gr.PO_NO PONo,
		gr.PO_ITEM POItemNo,
        gr.MATERIAL_NO MaterialNo,
		gr.MAT_DOC_ITEM_NO ReceivingItemNo,
        gr.MATERIAL_DESCRIPTION MaterialDesc,
        poi.PO_QTY_ORI OrderQty,
        gr.MOVEMENT_QTY ReceiveQty,
        gr.UNIT_OF_MEASURE_CD UOM,
        gr.MOVEMENT_QTY * gr.PO_DETAIL_PRICE TotalReceive
        FROM TB_R_GR_IR gr
        JOIN TB_R_PO_H poh ON gr.PO_NO = poh.PO_NO
        JOIN TB_R_PO_ITEM poi ON gr.PO_NO = poi.PO_NO
        AND gr.PO_ITEM = poi.PO_ITEM_NO
        WHERE gr.MAT_DOC_NO = @receivingNo
    ) SELECT * FROM tmp
END
