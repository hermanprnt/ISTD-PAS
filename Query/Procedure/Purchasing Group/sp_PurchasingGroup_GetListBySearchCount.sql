CREATE PROCEDURE [dbo].[sp_PurchasingGroup_GetListBySearchCount]
    @code VARCHAR(3), @description VARCHAR(30)
AS
BEGIN
    DECLARE
        @allowedRowCount INT = (SELECT CAST(SYSTEM_VALUE AS INT) FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH'),
        @rowCount INT
    ;

    SELECT @rowCount = COUNT(0)
    FROM TB_M_COORDINATOR coor
    JOIN TB_M_PROCUREMENT_CHANNEL pc ON coor.PROC_CHANNEL_CD = pc.PROC_CHANNEL_CD
    AND coor.COOR_FUNCTION = 'PG'
    AND ISNULL(coor.COORDINATOR_CD, '') LIKE '%' + ISNULL(@code, '') + '%'
    AND ISNULL(coor.COORDINATOR_DESC, '') LIKE '%' + ISNULL(@description, '') + '%'
    
    SELECT CASE WHEN @rowCount > @allowedRowCount THEN @allowedRowCount ELSE @rowCount END
END