CREATE PROCEDURE [dbo].[sp_POInquiry_IsReleased]
    @poNo VARCHAR(11)
AS
BEGIN
    SELECT CASE PO_STATUS WHEN '43' THEN 1 ELSE 0 END FROM TB_R_PO_H WHERE PO_NO = @poNo
END