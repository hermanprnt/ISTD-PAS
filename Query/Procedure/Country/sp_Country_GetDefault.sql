CREATE PROCEDURE [dbo].[sp_Country_GetDefault]
AS
BEGIN
    SELECT
    1 DataNo,
    c.COUNTRY_ID CountryCode,
    c.COUNTRY_NAME CountryName
    FROM TB_M_SYSTEM s
    JOIN TB_M_COUNTRY c ON s.SYSTEM_VALUE = c.COUNTRY_ID
    AND s.SYSTEM_CD = 'LOCAL_COUNTRY'
END