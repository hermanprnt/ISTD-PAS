CREATE PROCEDURE [dbo].[sp_POCommon_GetPOItemTempMaterialList]
    @processId BIGINT
AS
BEGIN
    SELECT
        PO_NO PONo,
        PO_ITEM_NO POItemNo,
        SEQ_ITEM_NO SeqItemNo,
        CASE WHEN MAT_NO = 'X' THEN ''
        ELSE MAT_NO END MaterialNo,
        MAT_DESC MaterialDesc
    FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId AND DELETE_FLAG <> 'Y' ORDER BY MAT_DESC
END