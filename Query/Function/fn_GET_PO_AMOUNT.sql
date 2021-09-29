-- =============================================
-- Author		: FID) Intan Puspitasari
-- Create date	: 24.03.2016
-- Description	: Get PO Amount by PO_NO from SAP
-- =============================================
ALTER FUNCTION [dbo].[fn_GET_PO_AMOUNT] (@PO_NO VARCHAR(11))
RETURNS DECIMAL(18, 4)
AS
BEGIN
	DECLARE @RESULT DECIMAL(18, 4) = 0
	
	SELECT @RESULT = SUM(AMOUNT) FROM
	(
		SELECT DISTINCT PO_ITEM_NO, (NEW_QTY * PRICE_PER_UOM /* EXCHANGE_RATE*/) AS AMOUNT FROM TB_T_SAP_PO WHERE PO_NO = @PO_NO
	)posap
	
	RETURN @RESULT
END