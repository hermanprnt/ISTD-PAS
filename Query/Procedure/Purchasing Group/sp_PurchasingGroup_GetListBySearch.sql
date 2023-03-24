CREATE PROCEDURE [dbo].[sp_PurchasingGroup_GetListBySearch]
    @code VARCHAR(3), @description VARCHAR(30),
    @currentPage INT, @pageSize INT
AS
BEGIN
    DECLARE
        @allowedRowCount INT = (SELECT CAST(SYSTEM_VALUE AS INT) FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH'),
        @rowCount INT
            
    -- NOTE: it's called derived table https://msdn.microsoft.com/en-us/library/ms177634.aspx
    SELECT @rowCount = (SELECT MIN(data) FROM (VALUES (@allowedRowCount), (@currentPage * @pageSize)) AS derived(data))
    ;
    
    WITH tmp AS (
        SELECT TOP (@rowCount)
        ROW_NUMBER() OVER (ORDER BY coor.COORDINATOR_CD ASC) DataNo,
        coor.COORDINATOR_CD PurchasingGroupCode,
        coor.COORDINATOR_DESC [Description],
        coor.PROC_CHANNEL_CD ProcChannelCode,
        pc.PROC_CHANNEL_DESC ProcChannelDesc,
        coor.CREATED_BY CreatedBy,
        coor.CREATED_DT CreatedDate,
        coor.CHANGED_BY ChangedBy,
        coor.CHANGED_DT ChangedDate
        FROM TB_M_COORDINATOR coor
        JOIN TB_M_PROCUREMENT_CHANNEL pc ON coor.PROC_CHANNEL_CD = pc.PROC_CHANNEL_CD
        AND coor.COOR_FUNCTION = 'PG'
        AND ISNULL(coor.COORDINATOR_CD, '') LIKE '%' + ISNULL(@code, '') + '%'
        AND ISNULL(coor.COORDINATOR_DESC, '') LIKE '%' + ISNULL(@description, '') + '%'
    ) SELECT * FROM tmp WHERE DataNo BETWEEN (@rowCount - @pageSize + 1) AND @rowCount
END