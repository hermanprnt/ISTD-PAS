DECLARE @@ProcessId BIGINT = 0

exec [dbo].[sp_PutLog] 
	@Message,
	@uid,
	@MessageLoc, 	
	@@ProcessId OUTPUT,
	@MessageID, 
	@type,
	@module, 
	@func,
	@sts

select @@ProcessId as newProcessId