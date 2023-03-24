CREATE PROCEDURE [dbo].[sp_DeliveryAddr_GetAllDeliveryAddr]
AS
BEGIN
    SELECT
        DELIVERY_ADDR DeliveryAddress,
        DELIVERY_NAME DeliveryName,
        ADDRESS Address,
        POSTAL_CODE PostalCode,
        CITY City
    FROM TB_M_DELIVERY_ADDR
END