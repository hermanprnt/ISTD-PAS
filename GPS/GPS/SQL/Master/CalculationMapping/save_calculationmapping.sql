﻿DECLARE @@MESSAGE VARCHAR(MAX) = '',
		@@COUNT INT = 0,
		@@NEW_CALCULATION_SCHEME_CD VARCHAR(4),
		@@TYPE VARCHAR(10),
		@@MESSAGE_FINISH VARCHAR(MAX) = '',
		@@LOC_FINISH VARCHAR(MAX) = ''

exec [dbo].[sp_PutLog] 'Insert Data Into Master Table Started', @uid, 'Insert Data Calculation Mapping', @PROCESS_ID, '', 'INF', '', null, 0
BEGIN TRANSACTION
BEGIN TRY
	IF(@IS_EDIT = 0)
	BEGIN
		IF(@CALCULATION_SCHEME_CD IS NULL OR @CALCULATION_SCHEME_CD = '')
		BEGIN
			SELECT @@NEW_CALCULATION_SCHEME_CD = 'GP' + RIGHT('00' + CAST((1 + CONVERT(INT, ISNULL(MAX(CONVERT(INT, SUBSTRING(CALCULATION_SCHEME_CD,3,4))), 0))) AS VARCHAR(2)), 2) 
				FROM TB_M_CALCULATION_SCHEME WHERE CALCULATION_SCHEME_CD LIKE 'GP%'

			INSERT INTO [dbo].[TB_M_CALCULATION_SCHEME]
				   ([CALCULATION_SCHEME_CD]
				   ,[CALCULATION_SCHEME_DESC]
				   ,[CREATED_BY]
				   ,[CREATED_DT]
				   ,[CHANGED_BY]
				   ,[CHANGED_DT]
				   ,[STATUS])
			 VALUES
				   (@@NEW_CALCULATION_SCHEME_CD
				   ,@CALCULATION_SCHEME_DESC
				   ,@uid
				   ,GETDATE()
				   ,null
				   ,null
				   ,@STATUS)
		END
		ELSE
		BEGIN
			SET @@NEW_CALCULATION_SCHEME_CD = @CALCULATION_SCHEME_CD
			UPDATE TB_M_CALCULATION_SCHEME
				SET STATUS = @STATUS
			WHERE CALCULATION_SCHEME_CD = @CALCULATION_SCHEME_CD
		END

		INSERT INTO [dbo].[TB_M_CALCULATION_MAPPING]
				([CALCULATION_SCHEME_CD]
				,[COMP_PRICE_CD]
				,[SEQ_NO]
				,[COMP_PRICE_TEXT]
				,[BASE_VALUE_FROM]
				,[BASE_VALUE_TO]
				,[INVENTORY_FLAG]
				,[QTY_PER_UOM]
				,[CALCULATION_TYPE]
				,[PLUS_MINUS_FLAG]
				,[CONDITION_CATEGORY]
				,[ACCRUAL_FLAG_TYPE]
				,[CONDITION_RULE]
				,[CREATED_BY]
				,[CREATED_DT]
				,[CHANGED_BY]
				,[CHANGED_DT]
				,[ITEM_STATUS])
		SELECT @@NEW_CALCULATION_SCHEME_CD
				,[COMP_PRICE_CD]
				,[SEQ_NO]
				,[COMP_PRICE_TEXT]
				,[BASE_VALUE_FROM]
				,[BASE_VALUE_TO]
				,[INVENTORY_FLAG]
				,[QTY_PER_UOM]
				,[CALCULATION_TYPE]
				,[PLUS_MINUS_FLAG]
				,[CONDITION_CATEGORY]
				,[ACCRUAL_FLAG_TYPE]
				,[CONDITION_RULE]
				,[CREATED_BY]
				,[CREATED_DT]
				,[CHANGED_BY]
				,[CHANGED_DT]
				,[ITEM_STATUS]
		FROM TB_T_CALCULATION_MAPPING
			WHERE PROCESS_ID = @PROCESS_ID AND DELETE_FLAG IS NULL 
	END
	ELSE
	BEGIN
		SET @@NEW_CALCULATION_SCHEME_CD = @CALCULATION_SCHEME_CD

		UPDATE TB_M_CALCULATION_SCHEME
			SET STATUS = @STATUS
		WHERE CALCULATION_SCHEME_CD = @@NEW_CALCULATION_SCHEME_CD

		--Insert New Data
		INSERT INTO [dbo].[TB_M_CALCULATION_MAPPING]
				([CALCULATION_SCHEME_CD]
				,[COMP_PRICE_CD]
				,[SEQ_NO]
				,[COMP_PRICE_TEXT]
				,[BASE_VALUE_FROM]
				,[BASE_VALUE_TO]
				,[INVENTORY_FLAG]
				,[QTY_PER_UOM]
				,[CALCULATION_TYPE]
				,[PLUS_MINUS_FLAG]
				,[CONDITION_CATEGORY]
				,[ACCRUAL_FLAG_TYPE]
				,[CONDITION_RULE]
				,[CREATED_BY]
				,[CREATED_DT]
				,[CHANGED_BY]
				,[CHANGED_DT]
				,[ITEM_STATUS])
		SELECT @@NEW_CALCULATION_SCHEME_CD
				,[COMP_PRICE_CD]
				,[SEQ_NO]
				,[COMP_PRICE_TEXT]
				,[BASE_VALUE_FROM]
				,[BASE_VALUE_TO]
				,[INVENTORY_FLAG]
				,[QTY_PER_UOM]
				,[CALCULATION_TYPE]
				,[PLUS_MINUS_FLAG]
				,[CONDITION_CATEGORY]
				,[ACCRUAL_FLAG_TYPE]
				,[CONDITION_RULE]
				,[CREATED_BY]
				,[CREATED_DT]
				,[CHANGED_BY]
				,[CHANGED_DT]
				,[ITEM_STATUS]
		FROM TB_T_CALCULATION_MAPPING
			WHERE PROCESS_ID = @PROCESS_ID AND DELETE_FLAG IS NULL AND NEW_FLAG = 'Y'

		--Update Existing Data
		UPDATE TB_M_CALCULATION_MAPPING
			SET COMP_PRICE_CD = B.COMP_PRICE_CD,
				COMP_PRICE_TEXT = B.COMP_PRICE_TEXT,
				BASE_VALUE_FROM = B.BASE_VALUE_FROM,
				BASE_VALUE_TO = B.BASE_VALUE_TO,
				INVENTORY_FLAG = B.INVENTORY_FLAG,
				PLUS_MINUS_FLAG = B.PLUS_MINUS_FLAG,
				CONDITION_CATEGORY = B.CONDITION_CATEGORY,
				QTY_PER_UOM = B.QTY_PER_UOM,
				CALCULATION_TYPE = B.CALCULATION_TYPE,
				ACCRUAL_FLAG_TYPE = B.ACCRUAL_FLAG_TYPE,
				CONDITION_RULE = B.CONDITION_RULE,
				CHANGED_BY = B.CHANGED_BY,
				CHANGED_DT = B.CHANGED_DT
		FROM TB_M_CALCULATION_MAPPING A 
		INNER JOIN TB_T_CALCULATION_MAPPING B 
			ON A.SEQ_NO = B.SEQ_NO AND B.PROCESS_ID = @PROCESS_ID
			   AND UPDATE_FLAG = 'Y' AND NEW_FLAG IS NULL AND DELETE_FLAG IS NULL AND A.CALCULATION_SCHEME_CD = @@NEW_CALCULATION_SCHEME_CD

		--Delete Existing Data
		DELETE FROM TB_M_CALCULATION_MAPPING
			WHERE CALCULATION_SCHEME_CD = @@NEW_CALCULATION_SCHEME_CD
				AND SEQ_NO IN 
				(SELECT SEQ_NO FROM TB_T_CALCULATION_MAPPING WHERE PROCESS_ID = @PROCESS_ID AND DELETE_FLAG = 'Y' AND NEW_FLAG IS NULL)	
	END
	COMMIT;
	
	SELECT @@COUNT = COUNT(1) FROM TB_M_CALCULATION_MAPPING WHERE CALCULATION_SCHEME_CD = @@NEW_CALCULATION_SCHEME_CD
	IF(@@COUNT = 0)
	BEGIN
		UPDATE TB_M_CALCULATION_SCHEME SET STATUS = 'I' WHERE CALCULATION_SCHEME_CD = @@NEW_CALCULATION_SCHEME_CD
	END
	exec [dbo].[sp_PutLog] 'Data Saved Successfully', @uid, 'Insert Data Calculation Mapping', @PROCESS_ID, '', 'INF', '', null, 2
	
	SET @@MESSAGE = '|' + @@NEW_CALCULATION_SCHEME_CD
END TRY
BEGIN CATCH
	ROLLBACK;
	SET @@MESSAGE = ERROR_MESSAGE()
	exec [dbo].[sp_PutLog] @@MESSAGE, @uid, 'Insert Data Calculation Mapping', @PROCESS_ID, '', 'INF', '', null, 3
	SET @@MESSAGE = 'FAILED|' + ERROR_MESSAGE()
END CATCH

SET @@TYPE = 'Edit'
IF(@IS_EDIT = 0)
BEGIN
	SET @@TYPE = 'Add'
END
SET @@MESSAGE_FINISH = @@TYPE + ' calculation mapping Finished'
SET @@LOC_FINISH =  @@TYPE + ' calculation mapping'
exec [dbo].[sp_PutLog] @@MESSAGE_FINISH, @uid, @@LOC_FINISH, @PROCESS_ID, '', 'INF', '', null, 2

SELECT @@MESSAGE