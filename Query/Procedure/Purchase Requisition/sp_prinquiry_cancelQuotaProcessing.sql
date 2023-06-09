﻿USE [PASS_DB_DEV]
GO
/****** Object:  StoredProcedure [dbo].[sp_prinquiry_cancelQuotaProcessing]    Script Date: 1/13/2016 5:28:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		FID.Intan Puspitasari
-- Create date: 13/01/2015
-- Description:	Cancelling Quota consume when cancel PR
-- =============================================
ALTER PROCEDURE [dbo].[sp_prinquiry_cancelQuotaProcessing] 
	@PROCESS_ID BIGINT,
	@PR_NO VARCHAR(11),
	@USER_ID VARCHAR(20),
	@PROCESS_TYPE VARCHAR(20) --COMMIT/ROLLBACK
AS
BEGIN
DECLARE @TEMP_LOG LOG_TEMP,
		@WBS_NO VARCHAR(30),
		@VALUATION_CLASS VARCHAR(4),
		@PR_ITEM_NO INT,
		@MAT_NO VARCHAR(23),
		@MAT_DESC VARCHAR(50),
		@ORI_AMOUNT DECIMAL(18, 4),
		@NEW_AMOUNT DECIMAL(18, 4),
		@TYPE VARCHAR(10),
		@MONTH VARCHAR(6),
		@STATUS VARCHAR(MAX) = 'SUCCESS|',
		@MSG VARCHAR(MAX),
		@MSG_ID VARCHAR(12),
		@DIVISION INT,
		@MODULE VARCHAR(10) = '2',
		@FUNCTION VARCHAR(20) = '202002',
		@LOCATION VARCHAR(50) = CASE WHEN (@PROCESS_TYPE = 'ROLLBACK') THEN @PROCESS_TYPE + ' ' ELSE '' END + 'Cancel Quota Calculation'

	SET NOCOUNT ON;

	BEGIN TRANSACTION

	SELECT @DIVISION = DIVISION_ID FROM TB_R_PR_H WHERE PR_NO = @PR_NO
	
	SET @MSG = CASE WHEN (@PROCESS_TYPE = 'ROLLBACK') THEN @PROCESS_TYPE + ' ' ELSE '' END + 'Quota Calculation Function For Process ID ' + CONVERT(VARCHAR,@PROCESS_ID) + ' Started'
	SET @MSG_ID = 'MSG0000100'
	INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
	EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

	SELECT @MONTH = LEFT(CONVERT(varchar, GetDate(),112),6)
	DECLARE db_cursor_quota CURSOR FOR
		SELECT DISTINCT PR_ITEM_NO,
			   WBS_NO,
			   VALUATION_CLASS,
			   MAT_NO,
			   MAT_DESC,
			   LOCAL_AMOUNT AS TOTAL_ORI_AMOUNT
		FROM TB_R_PR_ITEM 
		WHERE PR_NO = @PR_NO AND WBS_NO <> 'X' AND ITEM_CLASS = 'M' AND (ISNULL(WBS_NO, '') <> '' OR ISNULL(WBS_NO, 'X') <> 'X')
	OPEN db_cursor_quota
	FETCH NEXT FROM db_cursor_quota 
			INTO 
				@PR_ITEM_NO,
				@WBS_NO,
				@VALUATION_CLASS,
				@MAT_NO,
				@MAT_DESC,
				@ORI_AMOUNT
	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN TRY
			SELECT @TYPE = CASE WHEN (@PROCESS_TYPE = 'ROLLBACK') THEN 'COMMIT' ELSE 'RELEASE' END

			SELECT @NEW_AMOUNT = CASE WHEN (@PROCESS_TYPE = 'ROLLBACK') THEN 0 ELSE @NEW_AMOUNT END

			SET @MSG = 'Quota ' + @TYPE + ' Function For Item No ' + CONVERT(VARCHAR(5), @PR_ITEM_NO) + ' and Doc. No ' + @PR_NO + ' Started'
			SET @MSG_ID = 'MSG0000100'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
			EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
			
			EXEC sp_quotaCalculation @TYPE, @WBS_NO, @VALUATION_CLASS, @MAT_NO, @MAT_DESC, @DIVISION, @MONTH, @NEW_AMOUNT, @ORI_AMOUNT, @PR_NO, '', @USER_ID, @STATUS OUTPUT

			IF(SUBSTRING(@STATUS, 0, PATINDEX('%|%',@STATUS)) <> 'SUCCESS')
			BEGIN
				SET @MSG = SUBSTRING(@STATUS, PATINDEX('%|%',@STATUS) + 1, LEN(@STATUS))
				RAISERROR(@MSG, 16, 1)
			END
			ELSE
			BEGIN
				SET @MSG = 'Quota ' + @TYPE + ' Calculation Function For Item No ' + CONVERT(VARCHAR(5), @PR_ITEM_NO) + ' and Doc. No ' + @PR_NO + ' Success'
				SET @MSG_ID = 'MSG0000105'
				INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
				EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
			END
		END TRY
		BEGIN CATCH
			SET @MSG = ERROR_MESSAGE()
			SET @MSG_ID = 'EXCEPTION'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
			EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

			SET @MSG = 'Quota ' + @TYPE + ' for Item No ' + CONVERT(VARCHAR(5), @PR_ITEM_NO) + ' and Doc. No ' + @PR_NO + ' Failed'
			SET @MSG_ID = 'MSG0000103'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
			EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;
			BREAK;
		END CATCH

		FETCH NEXT FROM db_cursor_quota 
				INTO 
					@PR_ITEM_NO,
					@WBS_NO,
					@VALUATION_CLASS,
					@MAT_NO,
					@MAT_DESC,
					@ORI_AMOUNT
	END
	CLOSE db_cursor_quota
	DEALLOCATE	db_cursor_quota

	IF(SUBSTRING(@STATUS, 0, PATINDEX('%|%',@STATUS)) = 'SUCCESS')
	BEGIN
		COMMIT TRANSACTION
		SET @MSG = CASE WHEN (@PROCESS_TYPE = 'ROLLBACK') THEN @PROCESS_TYPE + ' ' ELSE '' END + 'Cancel Quota Calculation Function For Process ID ' + CONVERT(VARCHAR,@PROCESS_ID) + ' Success'
		SET @MSG_ID = 'MSG0000105'
		INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
		EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
	END
	ELSE
	BEGIN
		IF CURSOR_STATUS('global','db_cursor_quota') >= -1
		BEGIN
			DEALLOCATE db_cursor_quota
		END

		ROLLBACK TRANSACTION
		EXEC sp_PutLog_Temp @TEMP_LOG
	END

	SELECT SUBSTRING(@STATUS, PATINDEX('%|%',@STATUS) + 1, LEN(@STATUS)) AS [MESSAGE], SUBSTRING(@STATUS, 0, PATINDEX('%|%',@STATUS)) AS PROCESS_STATUS
END
