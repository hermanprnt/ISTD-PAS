DECLARE @@VALID_DT_FROM VARCHAR(20)

SELECT @@VALID_DT_FROM = VALID_DT_FROM 
	FROM TB_M_SOURCE_LIST
	WHERE MAT_NO = @MAT_NO AND VENDOR_CD = @VENDOR_CD 

UPDATE TB_M_SOURCE_LIST
	SET VALID_DT_TO = '9999-12-31'
WHERE MAT_NO = @MAT_NO AND VALID_DT_TO = DATEADD(day, -1, @@VALID_DT_FROM)

DELETE FROM TB_M_SOURCE_LIST
WHERE MAT_NO = @MAT_NO AND VENDOR_CD = @VENDOR_CD

SELECT @@@ROWCOUNT