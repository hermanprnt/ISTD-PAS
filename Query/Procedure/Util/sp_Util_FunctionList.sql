CREATE PROCEDURE sp_Util_FunctionList
AS
BEGIN
    SELECT
        mf.MODULE_ID + ': ' + md.MODULE_NAME Module,
        mf.FUNCTION_ID + ': ' + mf.FUNCTION_NAME [Function]
    FROM dbo.TB_M_FUNCTION mf
    JOIN dbo.TB_M_MODULE md ON mf.MODULE_ID = md.MODULE_ID
END