DECLARE @@pid BIGINT

SET @@pid = @PROCESS_ID
EXEC [dbo].[sp_PutLog] 
		@what,
		@userid,
		@where, 	
		@@pid OUTPUT ,
		@id, 
		@type,
		@module, 
		@function,
		@status

SELECT @@pid