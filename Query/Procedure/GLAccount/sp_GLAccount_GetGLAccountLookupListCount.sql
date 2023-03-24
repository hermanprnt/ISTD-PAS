CREATE PROCEDURE [dbo].[sp_GLAccount_GetGLAccountLookupListCount]
    @plantCode VARCHAR(50),
    @searchText VARCHAR(50)
AS
BEGIN
    SELECT COUNT(0)
    FROM TB_M_GL_ACCOUNT
    WHERE 1=1 --PLANT_CD = ISNULL(@plantCode, '')
    AND (ISNULL(GL_ACCOUNT_CD, '') LIKE '%' + ISNULL(@searchText, '') + '%'
    OR ISNULL(GL_ACCOUNT_DESC, '') LIKE '%' + ISNULL(@searchText, '') + '%')
END