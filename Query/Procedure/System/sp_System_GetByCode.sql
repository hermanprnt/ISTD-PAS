CREATE PROCEDURE [dbo].[sp_System_GetByCode]
    @systemCode VARCHAR(30)
AS
BEGIN
    SELECT
    '1' DataNo,
    sys.FUNCTION_ID FunctionId,
    sys.SYSTEM_CD [Code],
    sys.SYSTEM_VALUE [Value],
    sys.SYSTEM_REMARK Remark,
    sys.CREATED_BY CreatedBy,
    sys.CREATED_DT CreatedDate,
    sys.CHANGED_BY ChangedBy,
    sys.CHANGED_DT ChangedDate
    FROM TB_M_SYSTEM sys
    WHERE sys.SYSTEM_CD = @systemCode
END