CREATE PROCEDURE [dbo].[sp_POCreation_GetValuationClassLookupList]
    @purchasingGroup VARCHAR(6),
    @searchText VARCHAR(50),
    @currentPage INT,
    @pageSize INT
AS
BEGIN
    DECLARE @rowCount INT = (SELECT @currentPage * @pageSize)
    ;
    
    WITH tmp AS (
        SELECT ROW_NUMBER() OVER (ORDER BY valc.ValuationClass ASC) DataNo,
        valc.* FROM (
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
    ) SELECT * FROM tmp WHERE DataNo BETWEEN (@rowCount - @pageSize + 1) AND @rowCount
END