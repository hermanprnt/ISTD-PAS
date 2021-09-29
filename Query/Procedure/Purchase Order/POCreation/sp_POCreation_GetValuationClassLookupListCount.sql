CREATE PROCEDURE [dbo].[sp_POCreation_GetValuationClassLookupListCount]
    @purchasingGroup VARCHAR(6),
    @searchText VARCHAR(50)
AS
BEGIN
    SELECT COUNT(0)
    FROM (
        SELECT DISTINCT
        ITEM_CLASS ItemClass,
        ITEM_TYPE ItemType,
        VALUATION_CLASS ValuationClass, 
        VALUATION_CLASS_DESC ValuationClassDesc,
        AREA_DESC Area
        FROM TB_M_VALUATION_CLASS
        WHERE PURCHASING_GROUP_CD = ISNULL(@purchasingGroup, '')
        AND (ISNULL(VALUATION_CLASS, '') LIKE '%' + ISNULL(@searchText, '') + '%'
        OR ISNULL(VALUATION_CLASS_DESC, '') LIKE '%' + ISNULL(@searchText, '') + '%')
    ) valc
END