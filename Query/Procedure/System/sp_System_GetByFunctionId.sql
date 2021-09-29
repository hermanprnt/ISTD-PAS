CREATE PROCEDURE [dbo].[sp_System_GetByFunctionId]
    @functionId VARCHAR(6)
AS
BEGIN
    SELECT
    ROW_NUMBER() OVER (ORDER BY sys.FUNCTION_ID ASC, sys.SYSTEM_CD ASC) DataNo,
    sys.FUNCTION_ID FunctionId,
    sys.SYSTEM_CD [Code],
    sys.SYSTEM_VALUE [Value],
    sys.SYSTEM_REMARK Remark,
    sys.CREATED_BY CreatedBy,
    sys.CREATED_DT CreatedDate,
    sys.CHANGED_BY ChangedBy,
    sys.CHANGED_DT ChangedDate
    FROM TB_M_SYSTEM sys
    WHERE sys.FUNCTION_ID = @functionId
END
