DECLARE @@DIVISION_ID VARCHAR(5)='';
SELECT @@DIVISION_ID = (SELECT TOP 1 DIVISION_ID FROM TB_R_SYNCH_EMPLOYEE  WHERE GETDATE() BETWEEN VALID_FROM AND VALID_TO AND NOREG=@NOREG)
IF (@@DIVISION_ID='14')
BEGIN
	IF (@PLANT_BEFORE = '0000')
	BEGIN
		SELECT PLANT_CD, PLANT_NAME FROM TB_M_PLANT WHERE PLANT_CD IN (SELECT SYSTEM_VALUE FROM TB_M_SYSTEM WHERE FUNCTION_ID='PLANT' AND SYSTEM_CD='GAD') ORDER BY PLANT_CD
	END
	ELSE
	BEGIN
		SELECT PLANT_CD, PLANT_NAME  FROM TB_M_PLANT WHERE PLANT_CD = @PLANT_BEFORE
	END
END
ELSE IF (@@DIVISION_ID='19')
BEGIN
	SELECT PLANT_CD, PLANT_NAME FROM TB_M_PLANT WHERE PLANT_CD IN (SELECT SYSTEM_VALUE FROM TB_M_SYSTEM WHERE FUNCTION_ID='PLANT' AND SYSTEM_CD='PUD')  ORDER BY PLANT_CD
END
ELSE
BEGIN
	SELECT PLANT_CD, PLANT_NAME FROM TB_M_PLANT ORDER BY PLANT_CD
END