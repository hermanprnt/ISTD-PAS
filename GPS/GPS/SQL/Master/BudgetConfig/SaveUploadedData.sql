﻿DECLARE @@MSG VARCHAR(MAX) = '',
	    @@FI_YEAR VARCHAR(4)

SELECT @@FI_YEAR = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'FI_YEAR';

IF(CAST(@WBS_YEAR AS INT) < CAST(@@FI_YEAR AS INT))
BEGIN
	SET @@MSG = 'ERROR|WBS YEAR : ' + @WBS_YEAR + ' already passed current Financial Year : ' + @@FI_YEAR
	SELECT @@MSG
	RETURN;
END
ELSE
BEGIN
	IF NOT EXISTS (SELECT 1 FROM TB_R_WBS WHERE WBS_NO = @WBS_NO AND @WBS_YEAR = @WBS_YEAR)
	BEGIN
		SET @@MSG = 'ERROR|Data Not Exist in Budget Config';
		SELECT @@MSG
		RETURN;
	END
	ELSE
	BEGIN
		IF NOT EXISTS (SELECT DISTINCT 1 FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'WBSTY' AND SYSTEM_VALUE = @WBS_TYPE )
		BEGIN
			SET @@MSG = 'ERROR|Data WBS TYPE Not Exist in System Config';
			SELECT @@MSG
			RETURN;
		END
		ELSE
		BEGIN
			UPDATE TB_R_WBS 
			SET PROJECT_NO = @WBS_TYPE,
				CHANGED_BY = @UId,
				CHANGED_DT = GETDATE()
			WHERE WBS_NO = @WBS_NO AND WBS_YEAR = @WBS_YEAR
		END
	END
END
SELECT 'SUCCESS'