SET NOCOUNT ON
DECLARE @@processId BIGINT = 0
EXEC dbo.sp_PutLog 'I|Start', 'GPSWebApps', @ActionName, @@processId OUTPUT, 'INF', 'INF', @Module, @Function, 0
SET NOCOUNT OFF
SELECT @@processId