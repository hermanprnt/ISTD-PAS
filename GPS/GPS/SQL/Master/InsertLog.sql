exec [dbo].[sp_PutLog] 
	@Message,
	@uid,
	@MessageLoc, 	
	@ProcessId,
	@MessageID, 
	@type,
	@module, 
	@func,
	@sts