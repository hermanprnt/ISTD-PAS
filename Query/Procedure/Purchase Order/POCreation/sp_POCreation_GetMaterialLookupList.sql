CREATE PROCEDURE [dbo].[sp_POCreation_GetMaterialLookupList]
    @valuationClass VARCHAR(6),
    @currency VARCHAR(3),
    @searchText VARCHAR(50),
    @currentPage INT,
    @pageSize INT
AS
BEGIN
    DECLARE
        @rowCount INT = (SELECT @currentPage * @pageSize),
        @itemType VARCHAR(1) = (SELECT ITEM_TYPE FROM TB_M_VALUATION_CLASS WHERE VALUATION_CLASS = @valuationClass AND PROCUREMENT_TYPE = 'RM')
    
    SET @currency = ISNULL(@currency, (SELECT TOP 1 SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'LOCAL_CURR_CD'))
    IF (@itemType = 'P')
    BEGIN
        SELECT * FROM (
            SELECT
            ROW_NUMBER() OVER (ORDER BY prt.MAT_NO ASC) DataNo,
            prt.MAT_NO MatNo,
            prt.MAT_DESC MaterialDesc,
            prt.CAR_FAMILY_CD CarFamilyCode,
            prt.MAT_TYPE_CD MaterialTypeCode,
            prt.MAT_TYPE_CD MaterialTypeDesc,
            prt.MAT_GRP_CD MaterialGroupCode,
            prt.MAT_GRP_CD MaterialGroupDesc,
            prt.ORDER_UOM UOM,
            ISNULL(prc.PRICE_AMT, 0) Price
            FROM TB_M_MATERIAL_PART prt
            LEFT JOIN TB_M_MATERIAL_PRICE prc
                ON prt.MAT_NO = prc.MAT_NO AND prc.CURR_CD = @currency
            WHERE prt.VALUATION_CLASS = @valuationClass
            AND (ISNULL(prt.MAT_NO, '') LIKE '%' + ISNULL(@searchText, '') + '%'
                OR ISNULL(prt.MAT_DESC, '') LIKE '%' + ISNULL(@searchText, '') + '%'
                OR ISNULL(prt.MAT_TYPE_CD, '') LIKE '%' + ISNULL(@searchText, '') + '%'
                OR ISNULL(prt.MAT_GRP_CD, '') LIKE '%' + ISNULL(@searchText, '') + '%'
                OR ISNULL(prt.CAR_FAMILY_CD, '') LIKE '%' + ISNULL(@searchText, '') + '%'
            )
            AND (GETDATE() BETWEEN ISNULL(prc.VALID_DT_FROM, CAST('1753-1-1' AS DATETIME))
                AND ISNULL(prc.VALID_DT_TO, CAST('9999-12-31' AS DATETIME)))
        ) tmp WHERE DataNo BETWEEN (@rowCount - @pageSize + 1) AND @rowCount
    END
    ELSE IF (@itemType = 'N')
    BEGIN
        SELECT * FROM (
            SELECT
            ROW_NUMBER() OVER (ORDER BY nprt.MAT_NO ASC) DataNo,
            nprt.MAT_NO MaterialNo,
            nprt.MAT_DESC MaterialDesc,
            '' CarFamilyCode,
            '' MaterialTypeCode,
            '' MaterialTypeDesc,
            '' MaterialGroupCode,
            '' MaterialGroupDesc,
            nprt.ORDER_UOM UOM,
            ISNULL(prc.PRICE_AMT, 0) Price
            FROM TB_M_MATERIAL_NONPART nprt
            LEFT JOIN TB_M_MATERIAL_PRICE prc
                ON nprt.MAT_NO = prc.MAT_NO AND prc.CURR_CD = @currency
            WHERE nprt.VALUATION_CLASS = @valuationClass
            AND (ISNULL(nprt.MAT_NO, '') LIKE '%' + ISNULL(@searchText, '') + '%'
                OR ISNULL(nprt.MAT_DESC, '') LIKE '%' + ISNULL(@searchText, '') + '%'
                OR ISNULL(nprt.ORDER_UOM, '') LIKE '%' + ISNULL(@searchText, '') + '%'
            )
            AND (GETDATE() BETWEEN ISNULL(prc.VALID_DT_FROM, CAST('1753-1-1' AS DATETIME))
                AND ISNULL(prc.VALID_DT_TO, CAST('9999-12-31' AS DATETIME)))
        ) tmp WHERE DataNo BETWEEN (@rowCount - @pageSize + 1) AND @rowCount
    END
END


