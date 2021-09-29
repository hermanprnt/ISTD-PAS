CREATE PROCEDURE [dbo].[sp_PRChecker_GetList]
AS
BEGIN
    SELECT
    pc.PR_CHECKER_CD [Code],
    pc.PR_CHECKER_DESC [Desc]
    FROM TB_M_PR_CHECKER pc
END