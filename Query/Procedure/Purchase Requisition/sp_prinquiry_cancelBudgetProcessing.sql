/****** Object:  StoredProcedure [dbo].[sp_prinquiry_cancelBudgetProcessing]    Script Date: 7/6/2017 11:34:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: FID)Intan Puspitasari
-- Created dt	: 13/01/2015
-- Description	: Cancelling budget when cancel PR
-- =============================================
ALTER PROCEDURE [dbo].[sp_prinquiry_cancelBudgetProcessing] 
	@PROCESS_ID BIGINT,
	@PR_NO VARCHAR(20),
	@USER_ID VARCHAR(20),
	@PROCESS_TYPE VARCHAR(20), --COMMIT/ROLLBACK
	@ROW_ROLLBACK INT --TOTAL ROW THAT ALREADY INSERT TO BMS BUT NEED TO ROLLBACK
					  --FILL IT WITH 0 TO ROLLBACK ALL ITEM IN RELATED PR
AS
BEGIN
DECLARE @PR_DESC VARCHAR(MAX),
		@PARAM_PR_NO VARCHAR(20),
		@TEMP_LOG LOG_TEMP,
		@WBS_NO VARCHAR(30),
		@ORI_AMOUNT DECIMAL(18, 4),
		@TYPE VARCHAR(100),
		@CURR_CD VARCHAR(6),
		@SUCCESS INT = 0,
		@PROCESS_STATUS VARCHAR(20) = 'SUCCESS',
		@MSG VARCHAR(1000),
		@MSG_ID VARCHAR(12),
		@MODULE VARCHAR(10) = '2',
		@FUNCTION VARCHAR(20) = '202002',
		@LOCATION VARCHAR(50) = CASE WHEN (@PROCESS_TYPE = 'ROLLBACK') THEN @PROCESS_TYPE + ' 'ELSE '' END + 'Cancel Budget Calculation'
	
	SET NOCOUNT ON;

	SELECT @PR_DESC = PR_DESC FROM TB_R_PR_H WHERE PR_NO = @PR_NO
	SET @MSG = CASE WHEN (@PROCESS_TYPE = 'ROLLBACK') THEN @PROCESS_TYPE + ' 'ELSE '' END + 'Cancel Budget Calculation Function For Process ID ' + CONVERT(VARCHAR,@PROCESS_ID) + ' Started'
	SET @MSG_ID = 'MSG0000100'
	INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
	EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
	
	DECLARE db_cursor_budget CURSOR FOR
		SELECT PR_NO, WBS_NO, ORI_CURR_CD, SUM(TOTAL_ORI_AMOUNT) FROM
		(SELECT DISTINCT 
				@PR_NO + '_' + BUDGET_REF AS PR_NO,
				WBS_NO,
				ORI_CURR_CD,
				ORI_AMOUNT AS TOTAL_ORI_AMOUNT
		FROM TB_R_PR_ITEM 
		WHERE PR_NO = @PR_NO AND ITEM_CLASS = 'M' AND ((ISNULL(WBS_NO, '') <> '' AND coalesce(ltrim(rtrim(WBS_NO)) ,'') <> '')
			  AND (ISNULL(WBS_NO, 'X') <> 'X'))
		UNION
		SELECT DISTINCT 
				@PR_NO + '_' + BUDGET_REF AS PR_NO,
				A.WBS_NO,
				B.ORI_CURR_CD,
				A.ORI_AMOUNT AS TOTAL_ORI_AMOUNT
		FROM TB_R_PR_SUBITEM A
		INNER JOIN TB_R_PR_ITEM B
		ON A.PR_NO = @PR_NO AND B.PR_NO = A.PR_NO AND A.PR_ITEM_NO = B.PR_ITEM_NO AND B.ITEM_CLASS = 'S'
			AND ((ISNULL(A.WBS_NO, '') <> '' AND coalesce(ltrim(rtrim(A.WBS_NO)) ,'') <> '')
			AND (ISNULL(A.WBS_NO, 'X') <> 'X'))
		) A GROUP BY PR_NO, WBS_NO, ORI_CURR_CD
	OPEN db_cursor_budget
	FETCH NEXT FROM db_cursor_budget
			INTO 
				@PARAM_PR_NO,
				@WBS_NO,
				@CURR_CD,
				@ORI_AMOUNT
	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN TRY
			SELECT @TYPE = CASE WHEN (@PROCESS_TYPE = 'ROLLBACK') THEN 'NEW_COMMIT' ELSE 'CANCEL_COMMIT' END

			SELECT @MSG = 'Budget Calculation Function ' + @type + ' For WBS No ' + @WBS_NO + ' and Doc. No ' + @PR_NO + ' Started'

			SET @MSG_ID = 'MSG0000100'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
			EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

			DECLARE @OLD VARCHAR(50) = '', @NEW VARCHAR(50)
			SELECT @OLD = CASE WHEN(@TYPE = 'CANCEL_COMMIT') THEN @PARAM_PR_NO ELSE NULL END,
				   @NEW = CASE WHEN(@TYPE = 'CANCEL_COMMIT') THEN @PARAM_PR_NO ELSE @PARAM_PR_NO END--,
				   --@ORI_AMOUNT = CASE WHEN(@TYPE = 'CANCEL_COMMIT') THEN 0 ELSE @ORI_AMOUNT END

			SET @MSG = ''
			EXEC @PROCESS_STATUS = [BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
								@MSG OUTPUT,
								@USER_ID,
								@TYPE,
								@WBS_NO,
								@OLD,
								@NEW,
								@CURR_CD,
								@ORI_AMOUNT,
								NULL,
								'',
								@PR_DESC,
								'GPS'

			IF(@PROCESS_STATUS <> '0')
			BEGIN
				WAITFOR DELAY '00:00:01'
				EXEC @PROCESS_STATUS = [BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
								@MSG OUTPUT,
								@USER_ID,
								@TYPE,
								@WBS_NO,
								@OLD,
								@NEW,
								@CURR_CD,
								@ORI_AMOUNT,
								NULL,
								'',
								@PR_DESC,
								'GPS'
				IF(@PROCESS_STATUS <> '0')
				BEGIN
					WAITFOR DELAY '00:00:01'
					EXEC @PROCESS_STATUS = [BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
									@MSG OUTPUT,
									@USER_ID,
									@TYPE,
									@WBS_NO,
									@OLD,
									@NEW,
									@CURR_CD,
									@ORI_AMOUNT,
									NULL,
									'',
									@PR_DESC,
									'GPS'
				END
			END

			IF(@PROCESS_STATUS = '0')
			BEGIN
				SET @PROCESS_STATUS = 'SUCCESS'
				SET @MSG = 'Cancel Budget Calculation Function For WBS No ' + @WBS_NO + ' and Doc. No ' + @PR_NO + ' Success'

				SET @MSG_ID = 'MSG0000105'
				INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
				EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
			END
			ELSE
			BEGIN
				SET @PROCESS_STATUS = 'FAILED'
				RAISERROR(@MSG, 16, 1)
			END

			SET @SUCCESS = @SUCCESS + 1

			IF(@PROCESS_TYPE = 'ROLLBACK' AND @ROW_ROLLBACK > 0)
			BEGIN
				IF(@SUCCESS >= @ROW_ROLLBACK)
					BREAK;
			END
		END TRY
		BEGIN CATCH
			SET @MSG = ERROR_MESSAGE();
			SET @MSG_ID = 'EXCEPTION'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
			EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;
			RAISERROR(@MSG, 16, 1)

			SET @MSG = 'Cancel Budget Calculation for WBS No ' + @WBS_NO + ' and Process ID ' + CONVERT(VARCHAR,@PROCESS_ID) + ' Failed'
			SET @MSG_ID = 'MSG0000103'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
			EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;
			BREAK;
		END CATCH

		FETCH NEXT FROM db_cursor_budget 
				INTO 
					@PARAM_PR_NO,
					@WBS_NO,
					@CURR_CD,
					@ORI_AMOUNT
	END
	CLOSE db_cursor_budget
	DEALLOCATE	db_cursor_budget

	IF(@PROCESS_STATUS = 'SUCCESS')
	BEGIN
		SET @MSG = CASE WHEN (@PROCESS_TYPE = 'ROLLBACK') THEN @PROCESS_TYPE + ' ' ELSE '' END + 'Cancel Budget Calculation Function For Process ID ' + CONVERT(VARCHAR,@PROCESS_ID) + ' Success'
		SET @MSG_ID = 'MSG0000105'
		INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
		EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
	END
	ELSE
	BEGIN
		IF CURSOR_STATUS('global','db_cursor_budget') >= -1
		BEGIN
			DEALLOCATE db_cursor_budget
		END
		EXEC sp_PutLog_Temp @TEMP_LOG
	END

	SELECT @MSG AS [MESSAGE], @PROCESS_STATUS AS PROCESS_STATUS, @SUCCESS AS NUMBER_OF_SUCCESS
END
