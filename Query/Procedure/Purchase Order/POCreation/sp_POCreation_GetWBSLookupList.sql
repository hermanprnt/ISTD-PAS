CREATE PROCEDURE [dbo].[sp_POCreation_GetWBSLookupList]
    @currentUserRegNo VARCHAR(50),
    @searchText VARCHAR(50),
    @currentPage INT,
    @pageSize INT
AS
BEGIN
    DECLARE
        @rowCount INT = (SELECT @currentPage * @pageSize),
        @fiYear VARCHAR(4) = (SELECT TOP 1 SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'FI_YEAR'),
        @divisionId VARCHAR(10) = (SELECT TOP 1 DIVISION_ID FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = @currentUserRegNo ORDER BY POSITION_LEVEL ASC)
    ;

    WITH tmp AS (
        SELECT
        ROW_NUMBER() OVER (ORDER BY WBS_NO ASC) DataNo,
        WBS_NO,
        WBS_NAME
        FROM TB_R_WBS WHERE WBS_YEAR = @fiYear
        AND DIVISION_ID = @divisionId
        AND LEFT(WBS_NO, 1) = 'E' -- Expense type WBS
        AND (ISNULL(WBS_NO, '') LIKE '%' + ISNULL(@searchText, '') + '%'
        OR ISNULL(WBS_NAME, '') LIKE '%' + ISNULL(@searchText, '') + '%')
    ) SELECT * FROM tmp WHERE DataNo BETWEEN (@rowCount - @pageSize + 1) AND @rowCount
END