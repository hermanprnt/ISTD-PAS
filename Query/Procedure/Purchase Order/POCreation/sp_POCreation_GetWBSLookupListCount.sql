CREATE PROCEDURE [dbo].[sp_POCreation_GetWBSLookupListCount]
    @currentUserRegNo VARCHAR(50),
    @searchText VARCHAR(50)
AS
BEGIN
    DECLARE
        @fiYear VARCHAR(4) = (SELECT TOP 1 SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'FI_YEAR'),
        @divisionId VARCHAR(10) = (SELECT TOP 1 DIVISION_ID FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = @currentUserRegNo ORDER BY POSITION_LEVEL ASC)
    ;

    SELECT COUNT(0)
    FROM TB_R_WBS WHERE WBS_YEAR = @fiYear
    AND DIVISION_ID = @divisionId
    AND LEFT(WBS_NO, 1) = 'E' -- Expense type WBS
    AND (ISNULL(WBS_NO, '') LIKE '%' + ISNULL(@searchText, '') + '%'
    OR ISNULL(WBS_NAME, '') LIKE '%' + ISNULL(@searchText, '') + '%')
END
