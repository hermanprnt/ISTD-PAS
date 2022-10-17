DECLARE @@SPC_COST_CENTER VARCHAR(1000) 
SELECT @@SPC_COST_CENTER = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'PR'
AND SYSTEM_CD = 'SPECIAL_COST_CENTER'


IF SUBSTRING(@GL_ACCOUNT_PARAM,1,1)='6'
BEGIN
	SELECT DISTINCT 
		COST_CENTER_CD as COST_CENTER, 
		COST_CENTER_DESC 
	FROM TB_M_COST_CENTER WHERE DIVISION_ID = @DIVISION_ID AND GETDATE() BETWEEN VALID_DT_FROM AND VALID_DT_TO
	AND COST_CENTER_CD LIKE 'AA%'
	--2022-10-13 : add logic for special cost center 
	UNION
	SELECT DISTINCT 
		COST_CENTER_CD as COST_CENTER, 
		COST_CENTER_DESC 	
	FROM TB_M_COST_CENTER WHERE DIVISION_ID = @DIVISION_ID AND GETDATE() BETWEEN VALID_DT_FROM AND VALID_DT_TO
	AND COST_CENTER_CD IN (SELECT splitdata FROM dbo.fnSplitString (@@SPC_COST_CENTER,';'))
END
ELSE
BEGIN
	SELECT DISTINCT 
		COST_CENTER_CD as COST_CENTER, 
		COST_CENTER_DESC 
	FROM TB_M_COST_CENTER WHERE DIVISION_ID = @DIVISION_ID AND GETDATE() BETWEEN VALID_DT_FROM AND VALID_DT_TO
	AND COST_CENTER_CD NOT LIKE 'AA%'
		--2022-10-13 : add logic for special cost center 
	UNION
	SELECT DISTINCT 
		COST_CENTER_CD as COST_CENTER, 
		COST_CENTER_DESC 	
	FROM TB_M_COST_CENTER WHERE DIVISION_ID = @DIVISION_ID AND GETDATE() BETWEEN VALID_DT_FROM AND VALID_DT_TO
	AND COST_CENTER_CD IN (SELECT splitdata FROM dbo.fnSplitString (@@SPC_COST_CENTER,';'))
END