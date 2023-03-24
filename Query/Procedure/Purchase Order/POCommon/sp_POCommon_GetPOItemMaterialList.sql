CREATE PROCEDURE [dbo].[sp_POCommon_GetPOItemMaterialList]
    @poNo VARCHAR(11)
AS
BEGIN
    SELECT
        PO_NO PONo, 
        PO_ITEM_NO POItemNo,
        CASE WHEN MAT_NO = 'X' THEN ''
        ELSE MAT_NO END MaterialNo,
        MAT_DESC MaterialDesc
    FROM TB_R_PO_ITEM WHERE PO_NO = @poNo
END