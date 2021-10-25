CREATE PROCEDURE [dbo].[sp_POCommon_GetPurchasingGroup]
    @currentRegNo VARCHAR(50)
AS
BEGIN
DECLARE @result varchar(20)

SELECT TOP 1 @result = CAST(SE.DIVISION_ID AS VARCHAR)+ISNULL(CAST(SE.DEPARTMENT_ID AS VARCHAR), '')+ISNULL(CAST(SE.SECTION_ID AS VARCHAR), '')
FROM TB_R_SYNCH_EMPLOYEE SE 
	INNER JOIN TB_M_ORG_POSITION OP ON OP.POSITION_LEVEL = SE.POSITION_LEVEL AND OP.LEVEL_ID <= 4
WHERE SE.NOREG = @currentRegNo AND GETDATE() BETWEEN SE.VALID_FROM AND SE.VALID_TO

SELECT DISTINCT CM.COORDINATOR_CD PurchasingGroupCode, C.COORDINATOR_DESC [Description]
FROM TB_M_COORDINATOR_MAPPING CM
	INNER JOIN TB_M_COORDINATOR C ON C.COORDINATOR_CD = CM.COORDINATOR_CD AND C.COOR_FUNCTION = 'PG'
WHERE 
	CM.NOREG = @currentRegNo
	OR
	(
		@result = CAST(CM.DIVISION_ID AS VARCHAR)+ISNULL(CAST(CM.DEPARTMENT_ID AS VARCHAR), '')+ISNULL(CAST(CM.SECTION_ID AS VARCHAR), '')
		OR
		@result = CAST(CM.DIVISION_ID AS VARCHAR)+ISNULL(CAST(CM.DEPARTMENT_ID AS VARCHAR), '')
		OR
		@result = CAST(CM.DIVISION_ID AS VARCHAR)
	)
END