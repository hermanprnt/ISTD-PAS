CREATE PROCEDURE [dbo].[sp_PurchasingGroup_GetUserMapDepartmentList]
    @divisionId VARCHAR(5)
AS
BEGIN
    SELECT DISTINCT
    ROW_NUMBER() OVER (ORDER BY se.DEPARTMENT_NAME ASC) [No],
    se.DEPARTMENT_NAME [Name], se.DEPARTMENT_ID [Value]
    FROM TB_M_PROCUREMENT_CHANNEL pc
    JOIN (
        SELECT DIVISION_ID, DEPARTMENT_ID, DEPARTMENT_NAME
        FROM TB_R_SYNCH_EMPLOYEE
        WHERE DIVISION_ID IS NOT NULL AND DEPARTMENT_ID IS NOT NULL
        GROUP BY DIVISION_ID, DEPARTMENT_ID, DEPARTMENT_NAME
    ) se ON pc.DIVISION_ID = se.DIVISION_ID
    WHERE pc.DIVISION_ID = @divisionId
END