﻿USE [PASS_DB_DEV]
GO
/****** Object:  StoredProcedure [dbo].[sp_prcreation_quotaProcessing]    Script Date: 1/14/2016 10:06:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		FID.Intan Puspitasari
-- Create date: 28/10/2015
-- Description:	Get data parameters to process by quota calculation function
-- =============================================
ALTER PROCEDURE [dbo].[sp_prcreation_quotaProcessing] 
	@PROCESS_ID BIGINT,
	@DIVISION INT,
	@PR_NO VARCHAR(11),
	@USER_ID VARCHAR(20),
	@PROCESS_TYPE VARCHAR(20) --COMMIT/ROLLBACK
AS
BEGIN
DECLARE @TEMP_LOG LOG_TEMP,
		@WBS_NO VARCHAR(30),
		@VALUATION_CLASS VARCHAR(4),
		@PR_ITEM_NO VARCHAR(5),
		@MAT_NO VARCHAR(23),
		@MAT_DESC VARCHAR(50),
		@ORI_AMOUNT DECIMAL(18, 4),
		@NEW_AMOUNT DECIMAL(18, 4),
		@TEMP_AMOUNT DECIMAL(18, 4),
		@TYPE VARCHAR(10),
		@MONTH VARCHAR(6),
		@IS_DRAFT CHAR(1),
		@IS_CANCELLED CHAR(1),
		@STATUS VARCHAR(MAX) = 'SUCCESS|',
		@MSG VARCHAR(MAX),
		@MSG_ID VARCHAR(12),
		@MODULE VARCHAR(10) = '2',
		@FUNCTION VARCHAR(20) = '201002',
		@LOCATION VARCHAR(50) = CASE WHEN (@PROCESS_TYPE = 'ROLLBACK') THEN @PROCESS_TYPE + ' ' ELSE '' END + 'Quota Calculation'

	SET NOCOUNT ON;

	SELECT @IS_DRAFT = CASE WHEN (COUNT(1) > 0) THEN 'Y' ELSE 'N' END FROM TB_R_PR_H WHERE PR_NO = @PR_NO AND PR_STATUS = '94'
	SELECT @IS_CANCELLED = CASE WHEN (COUNT(1) > 0) THEN 'Y' ELSE 'N' END FROM TB_R_PR_H WHERE PR_NO = @PR_NO AND PR_STATUS = '95'

	IF(@IS_DRAFT = 'Y' OR @IS_CANCELLED = 'Y')
	BEGIN
		UPDATE TB_T_PR_ITEM SET ORI_AMOUNT = 0, ORI_LOCAL_AMOUNT = 0 WHERE PROCESS_ID = @PROCESS_ID
		UPDATE TB_T_PR_SUBITEM SET ORI_AMOUNT = 0, ORI_LOCAL_AMOUNT = 0 WHERE PROCESS_ID = @PROCESS_ID
	END

	BEGIN TRANSACTION
	SET @MSG = CASE WHEN (@PROCESS_TYPE = 'ROLLBACK') THEN @PROCESS_TYPE + ' ' ELSE '' END + 'Quota Calculation Function For Process ID ' + CONVERT(VARCHAR,@PROCESS_ID) + ' Started'
	SET @MSG_ID = 'MSG0000100'
	INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
	EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

	SELECT @MONTH = LEFT(CONVERT(varchar, GetDate(),112),6)
	DECLARE db_cursor_quota CURSOR FOR
		SELECT DISTINCT ITEM_NO,
			   WBS_NO,
			   VALUATION_CLASS,
			   MAT_NO,
			   MAT_DESC,
			   ORI_LOCAL_AMOUNT AS TOTAL_ORI_AMOUNT, 
			   NEW_LOCAL_AMOUNT AS TOTAL_NEW_AMOUNT
		FROM TB_T_PR_ITEM 
		WHERE PROCESS_ID = @PROCESS_ID AND WBS_NO <> 'X' AND ITEM_CLASS = 'M' AND (ISNULL(WBS_NO, '') <> '' OR ISNULL(WBS_NO, 'X') <> 'X')
	OPEN db_cursor_quota
	FETCH NEXT FROM db_cursor_quota 
			INTO 
				@PR_ITEM_NO,
				@WBS_NO,
				@VALUATION_CLASS,
				@MAT_NO,
				@MAT_DESC,
				@ORI_AMOUNT, 
				@NEW_AMOUNT
	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN TRY
			SELECT @TYPE = 
			  CASE WHEN ((@NEW_AMOUNT = 0) AND (@ORI_AMOUNT > 0)) THEN 'RELEASE'
				   WHEN ((@NEW_AMOUNT > 0) AND (@ORI_AMOUNT > 0) AND (@ORI_AMOUNT <> @NEW_AMOUNT)) THEN 'UPDATE'
				   WHEN ((@NEW_AMOUNT > 0) AND (@ORI_AMOUNT = 0)) THEN 'COMMIT'
				   ELSE 'UNPROCESS'
			  END

			IF(@TYPE <> 'UNPROCESS' AND @PROCESS_TYPE = 'ROLLBACK')
			BEGIN
				SET @TEMP_AMOUNT = @NEW_AMOUNT
				SET @NEW_AMOUNT = @ORI_AMOUNT
				SET @ORI_AMOUNT = @TEMP_AMOUNT

				SELECT @TYPE = 
				  CASE WHEN (@TYPE = 'RELEASE') THEN 'COMMIT'
					   WHEN (@TYPE = 'COMMIT') THEN 'RELEASE'
					   ELSE 'UPDATE'
				  END
			END

			IF(@TYPE <> 'UNPROCESS')
			BEGIN
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
					@ORI_AMOUNT, 
					@NEW_AMOUNT
	END
	CLOSE db_cursor_quota
	DEALLOCATE	db_cursor_quota

	IF(SUBSTRING(@STATUS, 0, PATINDEX('%|%',@STATUS)) = 'SUCCESS')
	BEGIN
		COMMIT TRANSACTION
		SET @MSG = CASE WHEN (@PROCESS_TYPE = 'ROLLBACK') THEN @PROCESS_TYPE + ' ' ELSE '' END + 'Quota Calculation Function For Process ID ' + CONVERT(VARCHAR,@PROCESS_ID) + ' Success'
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
