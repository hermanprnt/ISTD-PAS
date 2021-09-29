﻿DECLARE @@MSG VARCHAR(MAX),
		@@TEMP_LOG LOG_TEMP,
		@@MODULE VARCHAR(10) = '1',
		@@FUNCTION VARCHAR(20) = '115001',
		@@LOCATION VARCHAR(512) = 'Generating Routine Number',
		@@MSG_ID VARCHAR(12),
		@@EXIST INT,
		@@ROUTINE_NO VARCHAR(MAX),
		@@MAX_ID VARCHAR(5)

SET NOCOUNT ON;

BEGIN TRY
	SET @@MSG = 'Generate New Routine Number Started'
	SET @@MSG_ID = 'MSG0000002'
	EXEC dbo.sp_PutLog @@MSG, @USER_ID, @@LOCATION, @PROCESS_ID , @@MSG_ID, 'INF', @@MODULE, @@FUNCTION, 1;
	
	SELECT @@MAX_ID = ISNULL(SYSTEM_VALUE, 0) + 1 FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'ROUTINE_NO_COUNTER' AND FUNCTION_ID = '115001'
	select @@ROUTINE_NO = CONVERT(VARCHAR, DATEPART(YEAR, GETDATE())) + RIGHT('000' + CAST(CAST(ISNULL(@@MAX_ID, '1') AS INT) AS VARCHAR(3)), 3) 
	UPDATE TB_M_SYSTEM SET SYSTEM_VALUE = @@MAX_ID WHERE SYSTEM_CD = 'ROUTINE_NO_COUNTER' AND FUNCTION_ID = '115001'

	IF((@@ROUTINE_NO = '') OR (@@ROUTINE_NO IS NULL))
	BEGIN
		RAISERROR('Generate New Routine Number Failed', 16, 1)
	END

	SET @@MSG = 'Success Generate New Routine Number ' + @@ROUTINE_NO
	SET @@MSG_ID = 'MSG0000003'
	EXEC dbo.sp_PutLog @@MSG, @USER_ID, @@LOCATION, @PROCESS_ID , @@MSG_ID, 'SUC', @@MODULE, @@FUNCTION, 2;
END TRY
BEGIN CATCH
	SET @@MSG = ERROR_MESSAGE()
	SET @@MSG_ID = 'EXCEPTION'
	EXEC dbo.sp_PutLog @@MSG, @USER_ID, @@LOCATION, @PROCESS_ID, @@MSG_ID, 'ERR', @@MODULE, @@FUNCTION, 3;
	SET @@ROUTINE_NO = 'FAILED'
END CATCH

SELECT @@ROUTINE_NO