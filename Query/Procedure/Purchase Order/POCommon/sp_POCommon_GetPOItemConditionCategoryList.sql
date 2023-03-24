CREATE PROCEDURE [dbo].[sp_POCommon_GetPOItemConditionCategoryList]
    @conditionCategory INT
AS
BEGIN
    WITH tmp AS (
        SELECT 1 ConditionCategory, 'Fixed Rate' ConditionCategoryName
        UNION SELECT 2 ConditionCategory, 'By Qty' ConditionCategoryName
        UNION SELECT 3 ConditionCategory, 'Percentage' ConditionCategoryName
    ) SELECT * FROM tmp WHERE (@conditionCategory = 0 AND ConditionCategory IN (1, 2, 3)) -- NOTE: hackish way to define if condCat = 0 then select all else select by condCat
        OR (@conditionCategory <> 0 AND ConditionCategory = @conditionCategory)
END