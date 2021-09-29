DECLARE @@ACTION_TYPE CHAR(1) = 'I', --action type Insert / Update
		@@MESSAGE VARCHAR(MAX) = '',
		@@DIFF_AMOUNT NUMERIC(18, 2) = 0,
		@@USER_ID VARCHAR(20) = 'SAPBudgetSynch',
		@@SEQ INT = 0,
		@@NON_SAP_FLAG VARCHAR(1) = NULL,
		@@IS_LOCKED CHAR(1) = 'N'

DECLARE @@LOG_TEMP TABLE(
	[process_id] [int] NOT NULL,
	[seq_no] [int] NOT NULL,
	[msg_id] [varchar](12) NOT NULL,
	[msg_type] [varchar](3) NOT NULL,
	[err_location] [varchar](8000) NOT NULL,
	[err_message] [varchar](8000) NOT NULL,
	[err_dt] [datetime])

BEGIN TRANSACTION
BEGIN TRY
	SELECT @@SEQ = ISNULL(MAX(seq_no), 1) FROM TB_R_LOG_D WHERE process_id = @PROCESS_ID

	INSERT INTO @@LOG_TEMP VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Saving data WBS No : ' + @WBS_NO + ' started', GETDATE())
	INSERT INTO TB_R_LOG_D VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Saving data WBS No : ' + @WBS_NO + ' started', GETDATE())
	SET @@SEQ = @@SEQ + 1

	--Note : Check if WBS already exists
	IF EXISTS(SELECT 1 FROM TB_R_BUDGET_CONTROL_H WHERE WBS_NO = @WBS_NO AND WBS_YEAR = @WBS_YEAR)
	BEGIN
		SET @@ACTION_TYPE = 'U'
	END

	--Note : insert into TB_R_BUDGET_CONTROL_H
	IF(@@ACTION_TYPE = 'I')
	BEGIN
		INSERT INTO @@LOG_TEMP VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Insert Into TB_R_BUDGET_CONTROL_H for WBS No : ' + @WBS_NO + ' started', GETDATE())
		INSERT INTO TB_R_LOG_D VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Insert Into TB_R_BUDGET_CONTROL_H for WBS No : ' + @WBS_NO + ' started', GETDATE())
		SET @@SEQ = @@SEQ + 1

		INSERT INTO [dbo].[TB_R_BUDGET_CONTROL_H]
				   ([WBS_NO]
				   ,[ORIGINAL_WBS_NO]
				   ,[WBS_YEAR]
				   ,[CURR_CD]
				   ,[INITIAL_AMOUNT]
				   ,[INITIAL_RATE]
				   ,[INITIAL_BUDGET]
				   ,[ADJUSTED_BUDGET]
				   ,[REMAINING_BUDGET_ACTUAL]
				   ,[REMAINING_BUDGET_INITIAL_RATE]
				   ,[BUDGET_CONSUME_GR_SA]
				   ,[BUDGET_CONSUME_INITIAL_RATE]
				   ,[BUDGET_COMMITMENT_PR_PO]
				   ,[BUDGET_COMMITMENT_INITIAL_RATE]
				   ,[CREATED_BY]
				   ,[CREATED_DT])
			VALUES (@WBS_NO
				   ,@ORIGINAL_WBS_NO
				   ,@WBS_YEAR
				   ,@CURRENCY
				   ,@INITIAL_AMOUNT
				   ,@INITIAL_RATE
				   ,@INITIAL_BUDGET
				   ,@ADJUSTED_BUDGET
				   ,@REMAINING_BUDGET_ACTUAL
				   ,@REMAINING_BUDGET_INITIAL_RATE
				   ,@BUDGET_CONSUME_GR_SA
				   ,@BUDGET_CONSUME_INITIAL_RATE
				   ,@BUDGET_COMMITMENT_PR_PO
				   ,@BUDGET_COMMITMENT_INITIAL_RATE
				   ,@@USER_ID
				   ,GETDATE())

		INSERT INTO @@LOG_TEMP VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Insert Into TB_R_BUDGET_CONTROL_H for WBS No : ' + @WBS_NO + ' finished', GETDATE())
		INSERT INTO TB_R_LOG_D VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Insert Into TB_R_BUDGET_CONTROL_H for WBS No : ' + @WBS_NO + ' finished', GETDATE())
		SET @@SEQ = @@SEQ + 1
	END
	ELSE
	BEGIN
		INSERT INTO @@LOG_TEMP VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Update Data TB_R_BUDGET_CONTROL_H for WBS No : ' + @WBS_NO + ' started', GETDATE())
		INSERT INTO TB_R_LOG_D VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Update Data TB_R_BUDGET_CONTROL_H for WBS No : ' + @WBS_NO + ' started', GETDATE())
		SET @@SEQ = @@SEQ + 1

		--Note : Check if wbs no locked
		DECLARE @@COUNTER INT = 1
		WHILE(EXISTS(SELECT 1 FROM TB_R_LOCK WHERE LOCK_TYPE = 'BUDGET_CONTROL' AND LOCK_ITEM = @WBS_NO))
		BEGIN
			IF(@@COUNTER > 3)
			BEGIN
				SET @@MESSAGE = 'Budget cannot be updated. WBS No ' + @WBS_NO + ' is being used by another user'
				RAISERROR(@@MESSAGE, 16, 1)
			END

			WAITFOR DELAY '00:00:05'
			SET @@COUNTER = @@COUNTER + 1
		END

		--Note: Lock WBS 
		INSERT INTO @@LOG_TEMP VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Locking WBS No : ' + @WBS_NO + ' started.', GETDATE())
		INSERT INTO TB_R_LOG_D VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Locking WBS No : ' + @WBS_NO + ' started.', GETDATE())
		SET @@SEQ = @@SEQ + 1
		
		INSERT INTO [dbo].[TB_R_LOCK]
			   ([LOCK_ITEM]
			   ,[LOCK_TYPE]
			   ,[LOCK_BY]
			   ,[LOCK_DT]
			   ,[CREATED_BY]
			   ,[CREATED_DT]
			   ,[CHANGED_BY]
			   ,[CHANGED_DT])
		 VALUES
			   (@WBS_NO
			   ,'BUDGET_CONTROL'
			   ,'SAPMaintainBudget'
			   ,GETDATE()
			   ,'SAPMaintainBudget'
			   ,GETDATE()
			   ,NULL
			   ,NULL)

		INSERT INTO @@LOG_TEMP VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Locking WBS No : ' + @WBS_NO + ' finished.', GETDATE())
		INSERT INTO TB_R_LOG_D VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Locking WBS No : ' + @WBS_NO + ' finished.', GETDATE())
		SET @@SEQ = @@SEQ + 1

		SELECT @@NON_SAP_FLAG = NON_SAP_FLAG FROM TB_R_BUDGET_CONTROL_H WHERE WBS_NO = @WBS_NO AND WBS_YEAR = @WBS_YEAR
		
		IF(@@NON_SAP_FLAG IS NOT NULL)
		BEGIN
			SELECT @@DIFF_AMOUNT = @ADJUSTED_BUDGET - ADJUSTED_BUDGET FROM TB_R_BUDGET_CONTROL_H WHERE WBS_NO = @WBS_NO AND WBS_YEAR = @WBS_YEAR
		END

		--Note : If non_sap_flag <> null then do not update
		IF(@@DIFF_AMOUNT <> 0 OR @@NON_SAP_FLAG IS NULL)
		BEGIN
			UPDATE TB_R_BUDGET_CONTROL_H
				SET ADJUSTED_BUDGET = @ADJUSTED_BUDGET,
					REMAINING_BUDGET_ACTUAL = CASE WHEN(@@NON_SAP_FLAG IS NOT NULL) THEN REMAINING_BUDGET_ACTUAL + @@DIFF_AMOUNT ELSE @REMAINING_BUDGET_ACTUAL END,
					REMAINING_BUDGET_INITIAL_RATE = CASE WHEN(@@NON_SAP_FLAG IS NOT NULL) THEN REMAINING_BUDGET_INITIAL_RATE + @@DIFF_AMOUNT ELSE @REMAINING_BUDGET_INITIAL_RATE END,
					BUDGET_CONSUME_GR_SA = CASE WHEN(@@NON_SAP_FLAG IS NOT NULL) THEN BUDGET_CONSUME_GR_SA ELSE @BUDGET_CONSUME_GR_SA END,
					BUDGET_CONSUME_INITIAL_RATE = CASE WHEN(@@NON_SAP_FLAG IS NOT NULL) THEN BUDGET_CONSUME_INITIAL_RATE ELSE @BUDGET_CONSUME_INITIAL_RATE END,
					BUDGET_COMMITMENT_PR_PO = CASE WHEN(@@NON_SAP_FLAG IS NOT NULL) THEN BUDGET_COMMITMENT_PR_PO ELSE @BUDGET_COMMITMENT_PR_PO END,
					BUDGET_COMMITMENT_INITIAL_RATE = CASE WHEN(@@NON_SAP_FLAG IS NOT NULL) THEN BUDGET_COMMITMENT_INITIAL_RATE ELSE @BUDGET_COMMITMENT_INITIAL_RATE END,
					CHANGED_BY = @@USER_ID,
					CHANGED_DT = GETDATE()
			WHERE WBS_NO = @WBS_NO AND WBS_YEAR = @WBS_YEAR

			INSERT INTO @@LOG_TEMP VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Update Data TB_R_BUDGET_CONTROL_H for WBS No : ' + @WBS_NO + ' finished', GETDATE())
			INSERT INTO TB_R_LOG_D VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Update Data TB_R_BUDGET_CONTROL_H for WBS No : ' + @WBS_NO + ' finished', GETDATE())
			SET @@SEQ = @@SEQ + 1
		END
		ELSE
		BEGIN
			INSERT INTO @@LOG_TEMP VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Adjusted budget for WBS No : ' + @WBS_NO + ' not changed.', GETDATE())
			INSERT INTO TB_R_LOG_D VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Adjusted budget for WBS No : ' + @WBS_NO + ' not changed.', GETDATE())
			SET @@SEQ = @@SEQ + 1
		END
	END

	--Note: Insert Into TB_R_BUDGET_CONTROL_D
	IF(@@ACTION_TYPE = 'I' OR (@@ACTION_TYPE = 'U' AND (@@DIFF_AMOUNT <> 0 OR @@NON_SAP_FLAG IS NULL)))
	BEGIN
		INSERT INTO @@LOG_TEMP VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Insert Into TB_R_BUDGET_CONTROL_D for WBS No : ' + @WBS_NO + ' started.', GETDATE())
		INSERT INTO TB_R_LOG_D VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Insert Into TB_R_BUDGET_CONTROL_D for WBS No : ' + @WBS_NO + ' started.', GETDATE())
		SET @@SEQ = @@SEQ + 1

		INSERT INTO [dbo].[TB_R_BUDGET_CONTROL_D]
				   ([WBS_NO]
				   ,[SEQ_NO]
				   ,[BUDGET_TRANSACTION_GROUP]
				   ,[BUDGET_DOC_NO]
				   ,[REFERENCE_DOC_NO]
				   ,[PARENT_SEQ_NO]
				   ,[MATERIAL_NO]
				   ,[ITEM_DESCRIPTION]
				   ,[CURR_CD]
				   ,[EXC_RATE_ACTUAL]
				   ,[ACTUAL_AMOUNT]
				   ,[TOTAL_AMOUNT]
				   ,[ACTION_TYPE]
				   ,[SIGN]
				   ,[IS_SYNCH]
				   ,[SYSTEM_SOURCE]
				   ,[CREATED_BY]
				   ,[CREATED_DT]
				   ,[CHANGED_BY]
				   ,[CHANGED_DT])
			 VALUES (@WBS_NO
					,(SELECT ISNULL(MAX(SEQ_NO), 0) + 1 FROM [dbo].[TB_R_BUDGET_CONTROL_D] WHERE WBS_NO = @WBS_NO)
					,'SYNCH'
					,@WBS_NO + '_' + (SELECT RIGHT ('0000'+ CAST ((ISNULL(MAX(SEQ_NO), 0) + 1) AS varchar), 4) FROM TB_R_BUDGET_CONTROL_D WHERE WBS_NO = @WBS_NO)
					,'-'
					,NULL
					,NULL
					,CASE WHEN(@@ACTION_TYPE = 'I') THEN 'Initial Budget Release' ELSE 'Adjustment Budget Release' END
					,@CURRENCY
					,(SELECT TOP 1 EXCHANGE_RATE FROM TB_M_EXCHANGE_RATE WHERE CURR_CD = @CURRENCY AND GETDATE() BETWEEN VALID_FROM_DT AND VALID_TO_DT)
					,CASE WHEN(@@ACTION_TYPE = 'I') THEN @INITIAL_AMOUNT ELSE (CASE WHEN(@@NON_SAP_FLAG IS NULL) THEN @ADJUSTED_BUDGET ELSE ABS(@@DIFF_AMOUNT) END) END
					,((SELECT TOP 1 EXCHANGE_RATE FROM TB_M_EXCHANGE_RATE WHERE CURR_CD = @CURRENCY AND GETDATE() BETWEEN VALID_FROM_DT AND VALID_TO_DT) * CASE WHEN(@@ACTION_TYPE = 'I') THEN @INITIAL_AMOUNT ELSE (CASE WHEN(@@NON_SAP_FLAG IS NULL) THEN @ADJUSTED_BUDGET ELSE ABS(@@DIFF_AMOUNT) END) END)
					,CASE WHEN(@@ACTION_TYPE = 'I') THEN 'Initial_Relase' ELSE 'Adjustment_Release' END
					,CASE WHEN(@@DIFF_AMOUNT >= 0) THEN 'P' ELSE 'N' END
					,'0'
					,'SAP'
					,@@USER_ID
					,GETDATE()
					,NULL
					,NULL)

		--Note: Unlocking WBS 
		INSERT INTO @@LOG_TEMP VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Unlocking WBS No : ' + @WBS_NO + ' started.', GETDATE())
		INSERT INTO TB_R_LOG_D VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Unlocking WBS No : ' + @WBS_NO + ' started.', GETDATE())
		SET @@SEQ = @@SEQ + 1

		DELETE FROM TB_R_LOCK WHERE LOCK_ITEM = @WBS_NO AND LOCK_TYPE = 'BUDGET_CONTROL' AND LOCK_BY = 'SAPMaintainBudget'

		INSERT INTO @@LOG_TEMP VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Unlocking WBS No : ' + @WBS_NO + ' finished.', GETDATE())
		INSERT INTO TB_R_LOG_D VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Unlocking WBS No : ' + @WBS_NO + ' finished.', GETDATE())
		SET @@SEQ = @@SEQ + 1

		INSERT INTO @@LOG_TEMP VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Insert Into TB_R_BUDGET_CONTROL_D for WBS No : ' + @WBS_NO + ' finished.', GETDATE())
		INSERT INTO TB_R_LOG_D VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Insert Into TB_R_BUDGET_CONTROL_D for WBS No : ' + @WBS_NO + ' finished.', GETDATE())
		SET @@SEQ = @@SEQ + 1
	END

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	SELECT @@MESSAGE = ERROR_MESSAGE()

	--Note: Unlocking WBS 
	INSERT INTO @@LOG_TEMP VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Unlocking WBS No : ' + @WBS_NO + ' started.', GETDATE())
	INSERT INTO TB_R_LOG_D VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Unlocking WBS No : ' + @WBS_NO + ' started.', GETDATE())
	SET @@SEQ = @@SEQ + 1

	DELETE FROM TB_R_LOCK WHERE LOCK_ITEM = @WBS_NO AND LOCK_TYPE = 'BUDGET_CONTROL' AND LOCK_BY = 'SAPMaintainBudget'

	INSERT INTO @@LOG_TEMP VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Unlocking WBS No : ' + @WBS_NO + ' finished.', GETDATE())
	INSERT INTO TB_R_LOG_D VALUES(@PROCESS_ID, (@@SEQ + 1), 'INF', 'INF', 'Budget Data Importer Service', 'Unlocking WBS No : ' + @WBS_NO + ' finished.', GETDATE())
	SET @@SEQ = @@SEQ + 1

	INSERT INTO [dbo].[TB_R_LOG_D]
			   ([process_id]
			   ,[seq_no]
			   ,[msg_id]
			   ,[msg_type]
			   ,[err_location]
			   ,[err_message]
			   ,[err_dt])
		SELECT [process_id]
			   ,[seq_no]
			   ,[msg_id]
			   ,[msg_type]
			   ,[err_location]
			   ,[err_message]
			   ,[err_dt] FROM @@LOG_TEMP

	INSERT INTO @@LOG_TEMP VALUES(@PROCESS_ID, (@@SEQ + 1), 'ERR', 'ERR', 'Budget Data Importer Service', 'Error when save data for WBS No : ' + @WBS_NO + '. ' + @@MESSAGE, GETDATE())
	INSERT INTO TB_R_LOG_D VALUES(@PROCESS_ID, (@@SEQ + 1), 'ERR', 'ERR', 'Budget Data Importer Service', 'Error when save data for WBS No : ' + @WBS_NO + '. ' + @@MESSAGE, GETDATE())
	SET @@SEQ = @@SEQ + 1

	UPDATE TB_R_LOG_H SET process_sts = '2' WHERE process_id = @PROCESS_ID

	RAISERROR(@@MESSAGE, 16, 1)
END CATCH