CREATE PROCEDURE [dbo].[sp_Material_DeleteMaterial]
		@Kelas char (1),
		@MAT_NO VARCHAR (23),
		@UserId VARCHAR(20)
AS
BEGIN
DECLARE
		@ProcessId BIGINT,
		@Message VARCHAR (MAX),
		@StatusEdit VARCHAR(1),
		@StatusSukses VARCHAR(10)

SET @StatusSukses = 'SUCCESS'

BEGIN TRY
	IF(@Kelas = 'P')
	--EXEC dbo.sp_PutLog 'Delete Data Material Started', @UserId, 'Delete Material', @ProcessId output, 'MSG', 'INF', '000', '0000',0;
		BEGIN
		--EXEC dbo.sp_PutLog 'Delete Data Material From TB_M_MATERIAL Started', @UserId, 'Delete Material', @ProcessId , 'MSG', 'INF', '000', '0000',1;
			UPDATE TB_M_MATERIAL_PART SET
			DELETION_FLAG = 'Y' ,
			CHANGED_BY = @UserId,
			CHANGED_DT = GETDATE()
			WHERE MAT_NO = @MAT_NO
			--SET @Message = 'Delete Data Material With Material Number : '+@MAT_NO+' From TB_M_MATERIAL Success'
			--EXEC dbo.sp_PutLog @Message, @UserId, 'Delete Material', @ProcessId , 'MSG', 'INF', '000', '0000',2;
		END		
	ELSE
		BEGIN
			UPDATE TB_M_MATERIAL_NONPART SET
			DELETION_FLAG = 'Y' ,
			CHANGED_BY = @UserId,
			CHANGED_DT = GETDATE()
			WHERE MAT_NO = @MAT_NO
		END
	SET @StatusSukses = 'SUCCESS'
END TRY
BEGIN CATCH
	--ROLLBACK TRAN
	--SELECT @Message = 'Delete Data Material From TB_M_MATERIAL FAILED : ' + ERROR_MESSAGE()
	--EXEC dbo.sp_PutLog @Message, @UserId, 'Delete Material', @ProcessId , 'MSG', 'ERR', '000', '0000',3;
	SET @StatusSukses = 'FAILED'
END CATCH
SELECT @StatusSukses
END