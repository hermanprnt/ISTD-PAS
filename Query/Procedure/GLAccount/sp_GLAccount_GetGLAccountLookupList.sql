CREATE PROCEDURE [dbo].[sp_GLAccount_GetGLAccountLookupList]
    @plantCode VARCHAR(50),
    @searchText VARCHAR(50),
    @currentPage INT,
    @pageSize INT
AS
BEGIN
    DECLARE @rowCount INT = (SELECT @currentPage * @pageSize)
    ;
    
    WITH tmp AS (
        SELECT
        ROW_NUMBER() OVER (ORDER BY GL_ACCOUNT_CD ASC) DataNo,
        GL_ACCOUNT_CD Code,
        GL_ACCOUNT_DESC [Description]
        FROM TB_M_GL_ACCOUNT
        WHERE 1=1 --PLANT_CD = ISNULL(@plantCode, '')
        AND (ISNULL(GL_ACCOUNT_CD, '') LIKE '%' + ISNULL(@searchText, '') + '%'
        OR ISNULL(GL_ACCOUNT_DESC, '') LIKE '%' + ISNULL(@searchText, '') + '%')
    ) SELECT * FROM tmp WHERE DataNo BETWEEN (@rowCount - @pageSize + 1) AND @rowCount
END