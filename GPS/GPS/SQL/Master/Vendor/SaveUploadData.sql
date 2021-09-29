DECLARE @@MESSAGE VARCHAR(MAX),
		@@row INT

exec [dbo].[sp_PutLog] 'Insert Data Into Master Table Started', @uid, @MessageLoc, @ProcessId, '', 'INF', '', null, 1
BEGIN TRANSACTION 
BEGIN TRY
	INSERT INTO [dbo].[TB_M_VENDOR]
			   ([VENDOR_CD]
			   ,[VENDOR_NAME]
			   ,[VENDOR_PLANT]
			   ,[SAP_VENDOR_ID]
			   ,[PURCHASING_GRP_CD]
			   ,[PAYMENT_METHOD_CD]
			   ,[PAYMENT_TERM_CD]
			   ,[DELETION_FLAG]
			   ,[CREATED_BY]
			   ,[CREATED_DT]
			   ,[CHANGED_BY]
			   ,[CHANGED_DT]
			   ,[VENDOR_ADDRESS]
			   ,[POSTAL_CODE]
			   ,[CITY]
			   ,[ATTENTION]
			   ,[PHONE]
			   ,[FAX]
			   ,[COUNTRY]
			   ,[EMAIL_ADDR])
		SELECT [VENDOR_CD]
			  ,[VENDOR_NAME]
			  ,[VENDOR_PLANT]
			  ,[SAP_VENDOR_ID]
			  ,[PURCHASING_GRP_CD]
			  ,[PAYMENT_METHOD_CD]
			  ,[PAYMENT_TERM_CD]
			  ,[DELETION_FLAG]
			  ,[CREATED_BY]
			  ,[CREATED_DT]
			  ,[CHANGED_BY]
			  ,[CHANGED_DT]
			  ,[VENDOR_ADDRESS]
			  ,[POSTAL_CODE]
			  ,[CITY]
			  ,[ATTENTION]
			  ,[PHONE]
			  ,[FAX]
			  ,[COUNTRY]
			  ,[EMAIL_ADDR]
		FROM TB_T_VENDOR
			WHERE ERROR_FLAG = 'N' AND PROCESS_ID = @ProcessId
	SET @@row = @@@ROWCOUNT
	SET @@MESSAGE = CONVERT(VARCHAR(5), @@row) + ' row(s) data Inserted Into Master Table'
	COMMIT;
	exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'INF', '', null, 2
END TRY
BEGIN CATCH
	SET @@MESSAGE = ERROR_MESSAGE()
	ROLLBACK;
	SET @@row = 0
	exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 3
	exec [dbo].[sp_PutLog] 'No row data Inserted Into Master Table', @uid, @MessageLoc, @ProcessId, '', 'INF', '', null, 3
END CATCH
exec [dbo].[sp_PutLog] 'Insert Data Into Master Table Finished', @uid, @MessageLoc, @ProcessId, '', 'INF', '', null, 2

SELECT @@row