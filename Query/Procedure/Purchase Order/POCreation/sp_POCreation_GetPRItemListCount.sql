CREATE PROCEDURE [dbo].[sp_POCreation_GetPRItemListCount]
    @processId BIGINT, @prNo VARCHAR(11), @valuationClass VARCHAR(4), @plantCode VARCHAR(4),
    @materialNo VARCHAR(23), @currency VARCHAR(3), @sLocCode VARCHAR(4),
    @materialDesc VARCHAR(50), @vendorCode VARCHAR(4), @prCoordinator VARCHAR(3),
    @purchasingGroup VARCHAR(6)
AS
BEGIN
    DECLARE
        @allowedRowCount INT = (SELECT CAST(SYSTEM_VALUE AS INT) FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH'),
        @rowCount INT
    ;

    SELECT @rowCount = COUNT(0)
    FROM TB_R_PR_ITEM pri
        JOIN TB_R_PR_H prh ON prh.PR_NO = pri.PR_NO --AND prh.RELEASED_FLAG = 'Y'
        JOIN TB_M_VALUATION_CLASS vc ON pri.VALUATION_CLASS = vc.VALUATION_CLASS
            AND vc.PROCUREMENT_TYPE = prh.PR_TYPE
            AND vc.PR_COORDINATOR = prh.PR_COORDINATOR
            AND vc.PURCHASING_GROUP_CD = @purchasingGroup
        LEFT JOIN TB_R_ASSET ass ON pri.PR_NO = ass.PR_NO AND pri.PR_ITEM_NO = ass.PR_ITEM_NO
            AND pri.ASSET_CATEGORY IN ('MA', 'SA') AND ass.ASSET_STATUS = '51'
            AND ISNULL(ass.PROCESS_ID, '') = '' AND ISNULL(ass.PO_NO, '') = '' AND ISNULL(ass.PO_ITEM_NO, '') = ''
        LEFT JOIN TB_M_STATUS assst ON ass.ASSET_STATUS = assst.STATUS_CD
        WHERE
            (((SELECT pri.PR_NO + ';' + CAST(pri.PR_ITEM_NO AS VARCHAR) + ';' + CAST(ass.ASSET_NO AS VARCHAR) + ';' + CAST(ass.SUB_ASSET_NO AS VARCHAR)) NOT IN
                (SELECT PR_NO + ';' + CAST(PR_ITEM_NO AS VARCHAR) + ';' + ASSET_NO + ';' + SUB_ASSET_NO FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId AND DELETE_FLAG = 'N')
                AND ass.ASSET_NO IS NOT NULL) OR
                ((SELECT pri.PR_NO + ';' + CAST(pri.PR_ITEM_NO AS VARCHAR)) NOT IN
                (SELECT PR_NO + ';' + CAST(PR_ITEM_NO AS VARCHAR) FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId AND DELETE_FLAG = 'N')))
        AND pri.OPEN_QTY > 0
		AND pri.PR_STATUS = '14'
        AND 1 = CASE WHEN pri.ASSET_CATEGORY = 'NA'
            OR (pri.ASSET_CATEGORY IN ('MA', 'SA') AND ass.ASSET_STATUS = '51')
            THEN 1 ELSE 2 END
        AND ISNULL(pri.PR_NO, '') LIKE '%' + ISNULL(@prNo, '') + '%'
        AND ISNULL(pri.VALUATION_CLASS, '') LIKE '%' + ISNULL(@valuationClass, '') + '%'
        AND ISNULL(prh.PLANT_CD, '') LIKE '%' + ISNULL(@plantCode, '') + '%'
        AND ISNULL(pri.MAT_NO, '') LIKE '%' + ISNULL(@materialNo, '') + '%'
        AND ISNULL(pri.ORI_CURR_CD, '') LIKE '%' + ISNULL(@currency, '') + '%'
        AND ISNULL(prh.SLOC_CD, '') LIKE '%' + ISNULL(@sLocCode, '') + '%'
        AND ISNULL(pri.MAT_DESC, '') LIKE '%' + ISNULL(@materialDesc, '') + '%'
        AND ISNULL(pri.VENDOR_CD, '') LIKE '%' + ISNULL(@vendorCode, '') + '%'
        AND ISNULL(prh.PR_COORDINATOR, '') LIKE '%' + ISNULL(@prCoordinator, '') + '%'

    SELECT CASE WHEN @rowCount > @allowedRowCount THEN @allowedRowCount ELSE @rowCount END
END