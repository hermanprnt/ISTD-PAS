DECLARE @@MESSAGE VARCHAR(MAX),
		@@row INT

exec [dbo].[sp_PutLog] 'Insert Data Into Master Table Started', @uid, @MessageLoc, @ProcessId, '', 'INF', '', null, 0
BEGIN TRANSACTION 
BEGIN TRY
	INSERT INTO [dbo].[TB_M_COST_CENTER_GRP]
				([COST_CENTER_GRP_CD]
				,[COST_CENTER_GRP_DESC]
				,[DIVISION_CD]
				,[CREATED_BY]
				,[CREATED_DT]
				,[CHANGED_BY]
				,[CHANGED_DT])
			SELECT COST_CENTER_GRP_CD,
				COST_CENTER_GRP_DESC,
				DIVISION_CD,
				CREATED_BY,
				CREATED_DT,
				CHANGED_BY,
				CHANGED_DT
			FROM TB_T_COST_CENTER_GRP WHERE PROCESS_ID = @ProcessId AND ERROR_FLAG = 'N'
	SET @@row = @@@ROWCOUNT
	SET @@MESSAGE = CONVERT(VARCHAR(5), @@row) + ' row(s) data Inserted Into Master Table'
	COMMIT;
	exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'INF', '', null, 0
END TRY
BEGIN CATCH
	SET @@MESSAGE = ERROR_MESSAGE()
	ROLLBACK;
	SET @@row = 0
	exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 0
	exec [dbo].[sp_PutLog] 'No row data Inserted Into Master Table', @uid, @MessageLoc, @ProcessId, '', 'INF', '', null, 0
END CATCH
exec [dbo].[sp_PutLog] 'Insert Data Into Master Table Finished', @uid, @MessageLoc, @ProcessId, '', 'INF', '', null, 0

SELECT @@row