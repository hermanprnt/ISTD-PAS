SET NOCOUNT ON
DECLARE @@processId BIGINT = 0
EXEC dbo.sp_PutLog 'I|Start', 'Service', @ActionName, @@processId OUTPUT, 'INF', 'INF', '0', @FunctionId, 0
SET NOCOUNT OFF
SELECT @@processId