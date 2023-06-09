
ALTER PROCEDURE [dbo].[sp_Job_ECatalogue_ExecuteJobPO]  
AS
BEGIN
		DECLARE @PROCESS_ID BIGINT,
				@LOCATION VARCHAR(512) = 'sp_Job_ECatalogue_ExecuteJobPO',
				@MSG_ID VARCHAR(12) = ''

		DECLARE @PROCESSING_TABLE AS TABLE (ID INT IDENTITY(1,1), PROCESS_ID BIGINT NOT NULL)
		DECLARE @PROCESSING_DATA_TABLE AS TABLE(
												[ID] INT IDENTITY(1,1), 
												[PROCESS_ID] BIGINT NOT NULL,
												[STATUS] VARCHAR(50) NOT NULL,
												[PONO] [VARCHAR](10) NULL,
												[USER_ID] [varchar](50) NOT NULL,
												[RELATED_PROCESS_ID] BIGINT NOT NULL,
												[MODULE] [varchar](3) NOT NULL,
												[FUNCTION] [varchar](6) NOT NULL,
												[PURCHASING_GRP] [varchar](5) NOT NULL,
												[EXCHANGE_RATE] DECIMAL(7,2) NOT NULL,
												[IS_SPKCREATED] BIT NOT NULL DEFAULT 0,
												[IS_DRAFT] BIT NOT NULL DEFAULT 0,
												[CLONE_PONO] [varchar](11) NULL,
												[REGNO] [varchar](30) NULL
												) 

		INSERT INTO @PROCESSING_TABLE (PROCESS_ID)
		SELECT DISTINCT PROCESS_ID FROM TB_T_JOB_PO_PROCESSING WHERE [STATUS] = 'PREPARE'

		INSERT INTO @PROCESSING_DATA_TABLE ([PROCESS_ID], [STATUS], [PONO], [USER_ID], [RELATED_PROCESS_ID], [MODULE], [FUNCTION], [PURCHASING_GRP], [EXCHANGE_RATE], [IS_SPKCREATED], [IS_DRAFT], [CLONE_PONO], [REGNO] )
		SELECT PROCESS_ID, [STATUS], PONO, USER_ID, RELATED_PROCESS_ID, MODULE, [FUNCTION], PURCHASING_GRP, EXCHANGE_RATE, IS_SPKCREATED, IS_DRAFT, CLONE_PONO, REGNO  FROM TB_T_JOB_PO_PROCESSING 
		WHERE PROCESS_ID IN (SELECT PROCESS_ID FROM @PROCESSING_TABLE)
		ORDER BY PROCESS_ID, RELATED_PROCESS_ID

		UPDATE TB_T_JOB_PO_PROCESSING SET STATUS = 'PROCESSING' WHERE PROCESS_ID IN (SELECT PROCESS_ID FROM @PROCESSING_TABLE)

		DECLARE @Row_id INT = 1, @Count_Row int = 0
		SELECT @Count_Row = COUNT(0) FROM @PROCESSING_TABLE

		WHILE @Row_id <= @Count_Row
		BEGIN
			BEGIN TRY
				SELECT @PROCESS_ID = PROCESS_ID FROM @PROCESSING_TABLE WHERE ID = @Row_id

				DECLARE @Row_item_id INT = 1, @Count_item_Row int = 0
				SELECT @Count_item_Row = COUNT(RELATED_PROCESS_ID) FROM @PROCESSING_DATA_TABLE WHERE PROCESS_ID = @PROCESS_ID

				DECLARE @PONO VARCHAR(11),
						@USER_ID VARCHAR(30),
						@RELATED_PROCESS_ID BIGINT,
						@MODULE VARCHAR(3),
						@FUNCTION VARCHAR(5),
						@PURCHASING_GRP VARCHAR(3),
						@EXCHANGE_RATE DECIMAL(7,2),
						@IS_SPK_CREATED BIT,
						@IS_DRAFT BIT,
						@CLONE_PO VARCHAR(11),
						@REGNO VARCHAR(30),
						@tmpLogRelated LOG_TEMP,
						@MSG VARCHAR(MAX),
						@Status_Info VARCHAR(20) = ''

				WHILE @Row_item_id <= @Count_item_Row
				BEGIN
					SET @PONO = ''; SET @USER_ID = ''; SET @RELATED_PROCESS_ID = 0; SET @MODULE = ''; SET @FUNCTION =''
					SET @PURCHASING_GRP = ''; SET @EXCHANGE_RATE = 0; SET @IS_SPK_CREATED = 0; SET @IS_DRAFT = 0; SET @CLONE_PO = ''; SET @REGNO = ''; SET @MSG = ''; SET @Status_Info = ''

					SELECT @PONO = PONO,
						@USER_ID = [USER_ID],
						@RELATED_PROCESS_ID = RELATED_PROCESS_ID,
						@MODULE = MODULE,
						@FUNCTION = [FUNCTION],
						@PURCHASING_GRP =PURCHASING_GRP,
						@EXCHANGE_RATE = EXCHANGE_RATE,
						@IS_SPK_CREATED = IS_SPKCREATED,
						@IS_DRAFT = IS_DRAFT,
						@CLONE_PO = CLONE_PONO,
						@REGNO = REGNO
					FROM @PROCESSING_DATA_TABLE WHERE ID = @Row_item_id

					BEGIN TRAN
					 exec [dbo].[sp_POCreation_Save_ECatalog]
															@PONO,
															@USER_ID,
															@RELATED_PROCESS_ID,
															@MODULE,
															@FUNCTION,
															@PURCHASING_GRP,
															@EXCHANGE_RATE,
															@tmpLogRelated,
															@isSPKCreated = @IS_SPK_CREATED,
															@message = @MSG OUTPUT,
															@Status = @Status_Info OUTPUT,
															@isDraft = @IS_DRAFT,
															@clonePONO = @CLONE_PO,
															@regno = @RegNo

					IF @Status_Info = 'FAILED'
					BEGIN
						SET @MSG = @MSG
						ROLLBACK TRAN

						UPDATE TB_H_PO_PROCESSING_INFO SET STATUS = 'F' WHERE RELATED_PROCESS_ID = @RELATED_PROCESS_ID AND PROCESS_ID = @PROCESS_ID

						UPDATE T 
							SET STATUS = 'FAILED',
								REMARK = @MSG,
								CHANGED_BY = @USER_ID,
								CHANGED_DT = GETDATE()
						FROM TB_T_PO_GENERATE_MONITORING T
						INNER JOIN TB_T_PO_ITEM temp ON temp.PR_NO = t.PR_NO and temp.PR_ITEM_NO = t.PR_ITEM_NO 
							AND T.STATUS = 'LOCK' AND T.PROCESS_ID = @PROCESS_ID AND temp.PROCESS_ID = @RELATED_PROCESS_ID
					
						EXEC dbo.sp_PutLog 'Budget Failed', @USER_ID, @LOCATION, @RELATED_PROCESS_ID , 'SKIP', 'ERR', @MODULE, @FUNCTION, 1;
						EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID , 'ERR', 'ERR', @MODULE, @FUNCTION, 3;

						-- Clear Temp table
						IF (1 = 1)
						BEGIN
							SET @MSG = 'Delete data from TB_T_PO_ITEM where CREATED_BY = ' + @USER_ID + ': begin'
							SET @MSG_ID = 'MSG0000009'
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

							DELETE FROM TB_T_PO_H WHERE CREATED_BY = @USER_ID AND PROCESS_ID = @RELATED_PROCESS_ID
							DELETE FROM TB_T_PO_ITEM WHERE CREATED_BY = @USER_ID AND PROCESS_ID = @RELATED_PROCESS_ID

							SET @MSG = 'Delete data from TB_T_PO_ITEM where CREATED_BY = ' + @USER_ID + ': end'
							SET @MSG_ID = 'MSG0000010'
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

							SET @MSG = 'Delete data from TB_T_PO_CONDITION where CREATED_BY = ' + @USER_ID + ': begin'
							SET @MSG_ID = 'MSG0000011'
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

							DELETE FROM TB_T_PO_CONDITION WHERE CREATED_BY = @USER_ID AND PROCESS_ID = @RELATED_PROCESS_ID

							SET @MSG = 'Delete data from TB_T_PO_CONDITION where CREATED_BY = ' + @USER_ID + ': end'
							SET @MSG_ID = 'MSG0000012'
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
						END

						SET @MSG = 'Reset PROCESS_ID from TB_R_ASSET where CHANGED_BY = ' + @USER_ID + ': begin'
						SET @MSG_ID = 'MSG0000013'
						EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

						UPDATE TB_R_ASSET SET PROCESS_ID = NULL WHERE CHANGED_BY = @USER_ID
						AND ISNULL(PROCESS_ID, '') NOT IN (SELECT DISTINCT PROCESS_ID FROM TB_T_PO_ITEM)
						AND (ISNULL(PO_NO, '') = '' AND ISNULL(PO_ITEM_NO, '') = '')

						SET @MSG = 'Reset PROCESS_ID from TB_R_ASSET where CHANGED_BY = ' + @USER_ID + ': end'
						SET @MSG_ID = 'MSG0000014'
						EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

						GOTO nextFetch;
					END
				
					UPDATE TB_H_PO_PROCESSING_INFO SET PO_NO = @Status_Info, STATUS = 'S' WHERE RELATED_PROCESS_ID = @RELATED_PROCESS_ID AND PROCESS_ID = @PROCESS_ID
					--WHEN SUCCESS
					BEGIN 
						UPDATE T 
							SET STATUS = 'SUCCESS',
								REMARK = '',
								PO_NO = @Status_Info,
								CHANGED_BY = @USER_ID,
								CHANGED_DT = GETDATE()
						FROM TB_T_PO_GENERATE_MONITORING T
						INNER JOIN TB_T_PO_ITEM temp ON temp.PR_NO = t.PR_NO and temp.PR_ITEM_NO = t.PR_ITEM_NO 
							AND T.STATUS = 'LOCK' AND T.PROCESS_ID = @PROCESS_ID AND temp.PROCESS_ID = @RELATED_PROCESS_ID
					END


					SET @MSG = 'PO NO : '+ @Status_Info
					SET @MSG_ID = 'MSG0000009'
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

					-- Clear Temp table
					IF (1 = 1)
					BEGIN
						SET @MSG = 'Delete data from TB_T_PO_ITEM where CREATED_BY = ' + @USER_ID + ': begin'
						SET @MSG_ID = 'MSG0000009'
						EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

						DELETE FROM TB_T_PO_H WHERE CREATED_BY = @USER_ID AND PROCESS_ID = @RELATED_PROCESS_ID
						DELETE FROM TB_T_PO_ITEM WHERE CREATED_BY = @USER_ID AND PROCESS_ID = @RELATED_PROCESS_ID

						SET @MSG = 'Delete data from TB_T_PO_ITEM where CREATED_BY = ' + @USER_ID + ': end'
						SET @MSG_ID = 'MSG0000010'
						EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

						SET @MSG = 'Delete data from TB_T_PO_CONDITION where CREATED_BY = ' + @USER_ID + ': begin'
						SET @MSG_ID = 'MSG0000011'
						EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

						DELETE FROM TB_T_PO_CONDITION WHERE CREATED_BY = @USER_ID AND PROCESS_ID = @RELATED_PROCESS_ID

						SET @MSG = 'Delete data from TB_T_PO_CONDITION where CREATED_BY = ' + @USER_ID + ': end'
						SET @MSG_ID = 'MSG0000012'
						EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
					END

					SET @MSG = 'Reset PROCESS_ID from TB_R_ASSET where CHANGED_BY = ' + @USER_ID + ': begin'
					SET @MSG_ID = 'MSG0000013'
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

					UPDATE TB_R_ASSET SET PROCESS_ID = NULL WHERE CHANGED_BY = @USER_ID
					AND ISNULL(PROCESS_ID, '') NOT IN (SELECT DISTINCT PROCESS_ID FROM TB_T_PO_ITEM)
					AND (ISNULL(PO_NO, '') = '' AND ISNULL(PO_ITEM_NO, '') = '')

					SET @MSG = 'Reset PROCESS_ID from TB_R_ASSET where CHANGED_BY = ' + @USER_ID + ': end'
					SET @MSG_ID = 'MSG0000014'
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

					COMMIT TRAN
				
					SET @MSG = 'Insert PO Data to real table success'
					SET @MSG_ID = 'MSG0000015'
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 1;

					nextFetch:
					SET @Row_item_id = @Row_item_id + 1
				END
			END TRY
			BEGIN CATCH
				DECLARE @Message_Error VARCHAR(MAX) = ERROR_MESSAGE(), @Message_Line_Error int = ERROR_LINE()
		
				--EXEC sp_PutLog_Temp @tmpLog 

				SET @MSG_ID = 'MSG0000099'
				EXEC dbo.sp_PutLog 'Job ExecuteJobPO Process finished with error', @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 2;

				SET @MSG_ID = 'EXCEPTION'
				SET @MSG = ERROR_MESSAGE() + '. at line : '+ CONVERT(VARCHAR, @Message_Line_Error)
				EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;
				EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

				BEGIN 
					UPDATE T 
						SET STATUS = 'FAILED',
							REMARK = @MSG,
							CHANGED_BY = @USER_ID,
							CHANGED_DT = GETDATE()
					FROM TB_T_PO_GENERATE_MONITORING T
						WHERE T.STATUS = 'LOCK' AND T.PROCESS_ID = @PROCESS_ID
				END
			END CATCH

			SET @Row_id = @Row_id  + 1
		END

		UPDATE R
			SET STATUS = CASE WHEN T.STATUS ='LOCK' THEN 'OPEN' ELSE T.STATUS END,
				REMARK = T.REMARK,
				PROCESS_ID = T.PROCESS_ID,
				PROCESS_DATE = T.PROCESS_DATE,
				PO_NO = T.PO_NO,
				CHANGED_BY = @USER_ID,
				CHANGED_DT = GETDATE()
		FROM TB_R_PO_GENERATE_MONITORING R
		INNER JOIN TB_T_PO_GENERATE_MONITORING T ON T.PR_NO = R.PR_NO and T.PR_ITEM_NO = R.PR_ITEM_NO
			AND T.PROCESS_ID IN (SELECT PROCESS_ID FROM @PROCESSING_TABLE)

		DELETE FROM TB_T_PO_GENERATE_MONITORING WHERE PROCESS_ID = (SELECT PROCESS_ID FROM @PROCESSING_TABLE)
		DELETE FROM TB_T_JOB_PO_PROCESSING WHERE PROCESS_ID = (SELECT PROCESS_ID FROM @PROCESSING_TABLE)
END

