DECLARE @@ProcessId BIGINT = 0

exec [dbo].[sp_PutLog] 
	@MESSAGE,
	@uid,
	@LOC, 	
	@@ProcessId OUTPUT,
	@MESSAGE_ID, 
	@TYPE,
	@MODULE, 
	@FUNCTION,
	@STS

select @@ProcessId as newProcessId