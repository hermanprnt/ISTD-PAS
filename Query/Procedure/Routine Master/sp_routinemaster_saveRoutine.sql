﻿SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author	  : FID)Intan Puspitasari
-- Created Dt : 02/12/215
-- Description: Save Routine PR Master
-- =============================================
ALTER PROCEDURE [dbo].[sp_routinemaster_saveRoutine]
		@ROUTINE_NO VARCHAR(15),
		@PROCESS_ID BIGINT,
		@USER_ID VARCHAR(20),
		@EDIT_FLAG VARCHAR(1),
		@ROUTINE_DATA ROUTINE_PR_H_TEMP READONLY,
		@STATUS VARCHAR(MAX) OUTPUT
AS
BEGIN

DECLARE @COUNT INT

DECLARE @TEMP_LOG LOG_TEMP,
		@MESSAGE VARCHAR(MAX),
		@MSG_ID VARCHAR(12),
		@MODULE VARCHAR(3) = '1',
		@FUNCTION VARCHAR(5) = '115001',
		@LOCATION VARCHAR(50) = 'Saving Routine'
	
	SET NOCOUNT ON;

SET @MESSAGE = 'Saving Routine No ' + @ROUTINE_NO + ' Started'
SET @MSG_ID = 'MSG0000005'
INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

/*** Insert TB_M_ROUTINE_PR_H ***/
IF((@STATUS = 'SUCCESS') AND (@EDIT_FLAG = 'N'))
BEGIN
	BEGIN TRY
		SET @MESSAGE = 'Insert New Data Into TB_M_ROUTINE_PR_H Started'
		SET @MSG_ID = 'MSG0000006'
		INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
		EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

		INSERT INTO [dbo].[TB_M_ROUTINE_PR_H]
				   ([ROUTINE_NO]
				   ,[PR_DESC]
				   ,[PR_TYPE]
				   ,[PR_STATUS]
				   ,[PLANT_CD]
				   ,[SLOC_CD]
				   ,[PR_COORDINATOR]
				   ,[DIVISION_ID]
				   ,[DIVISION_NAME]
				   ,[DIVISION_PIC]
				   ,[RELEASED_FLAG]
				   ,[SCH_TYPE]
				   ,[SCH_TYPE_DESC]
				   ,[SCH_VALUE]
				   ,[PROCESS_ID]
				   ,[CREATED_BY]
				   ,[CREATED_DT]
				   ,[CHANGED_BY]
				   ,[CHANGED_DT]
				   ,[ACTIVE_FLAG]
				   ,[VALID_FROM]
				   ,[VALID_TO])
			 SELECT @ROUTINE_NO 
			        ,PR_DESC
					,'RT'
					,PR_STATUS
					,PLANT_CD
					,SLOC_CD
					,PR_COORDINATOR
					,DIVISION_ID
					,DIVISION_NAME
					,DIVISION_PIC
					,'N'
					,SCH_TYPE
					,SCH_TYPE_DESC
					,SCH_VALUE
					,PROCESS_ID
					,@USER_ID
					,GETDATE()
					,null
					,null
					,ACTIVE_FLAG
					,VALID_FROM
					,VALID_TO FROM @ROUTINE_DATA WHERE PROCESS_ID = @PROCESS_ID

		SET @MESSAGE = 'Insert New Data Into TB_M_ROUTINE_PR_H Success'
		SET @MSG_ID = 'MSG0000007'
		INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
		EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
		
		SET @STATUS = 'SUCCESS'
	END TRY
	BEGIN CATCH
		SET @MESSAGE = 'Insert New Data Into TB_M_ROUTINE_PR_H Failed'
		SET @MSG_ID = 'MSG0000016'
		INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
		EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

		SELECT @MESSAGE = ERROR_MESSAGE()
		SET @MSG_ID = 'EXCEPTION'
		INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
		EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 3;
		
		SET @STATUS = 'FAILED'
	END CATCH
END

IF((@STATUS = 'SUCCESS') AND (@EDIT_FLAG = 'Y'))
BEGIN
	BEGIN TRY
		SET @MESSAGE = 'Update Data Into TB_M_ROUTINE_PR_H Started'
		SET @MSG_ID = 'MSG0000008'
		INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
		EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

		UPDATE TB_M_ROUTINE_PR_H SET 
				[PR_DESC] = B.PR_DESC
				,[PR_TYPE] = 'RT'
				,[PR_STATUS] = B.PR_STATUS
				,[PLANT_CD] = B.PLANT_CD
				,[SLOC_CD] = B.SLOC_CD
				,[PR_COORDINATOR] = B.PR_COORDINATOR
				,[DIVISION_ID] = B.DIVISION_ID
				,[DIVISION_NAME] = B.DIVISION_NAME
				,[DIVISION_PIC] = B.DIVISION_PIC
				,[RELEASED_FLAG] = 'N'
				,[SCH_TYPE] = B.SCH_TYPE
				,[SCH_TYPE_DESC] = B.SCH_TYPE_DESC
				,[SCH_VALUE] = B.SCH_VALUE
				,[PROCESS_ID] = B.PROCESS_ID
				,[CHANGED_BY] = @USER_ID
				,[CHANGED_DT] = GETDATE()
				,[ACTIVE_FLAG] = B.ACTIVE_FLAG
				,[VALID_FROM] = B.VALID_FROM
				,[VALID_TO] = B.VALID_TO
		FROM TB_M_ROUTINE_PR_H A INNER JOIN @ROUTINE_DATA B ON A.PROCESS_ID = B.PROCESS_ID 
			WHERE B.PROCESS_ID = @PROCESS_ID

		SET @MESSAGE = 'Update Data Into TB_M_ROUTINE_PR_H Success'
		SET @MSG_ID = 'MSG0000010'
		INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
		EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
		
		SET @STATUS = 'SUCCESS'
	END TRY
	BEGIN CATCH
		SET @MESSAGE = 'Update Data Into TB_M_ROUTINE_PR_H Failed'
		SET @MSG_ID = 'MSG0000017'
		INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
		EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

		SELECT @MESSAGE = ERROR_MESSAGE()
		SET @MSG_ID = 'EXCEPTION'
		INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
		EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

		SET @STATUS = 'FAILED'
	END CATCH
END
/*** End of Insert TB_M_ROUTINE_PR_H ***/

/*** Insert TB_M_ROUTINE_PR_ITEM ***/
IF(@STATUS = 'SUCCESS')
BEGIN
	SELECT @COUNT = COUNT(*) FROM TB_T_PR_ITEM WHERE PROCESS_ID = @PROCESS_ID AND NEW_FLAG = 'Y' AND ISNULL(DELETE_FLAG, 'N') <> 'Y'
	IF(@COUNT > 0)
	BEGIN
		BEGIN TRY
			SET @MESSAGE = 'Insert New Data Into TB_M_ROUTINE_PR_ITEM Started'
			SET @MSG_ID = 'MSG0000015'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
			EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
		
			INSERT INTO [dbo].[TB_M_ROUTINE_PR_ITEM]
					   ([ROUTINE_NO]
					   ,[ITEM_NO]
					   ,[ITEM_TYPE]
					   ,[IS_PARENT]
					   ,[PROCUREMENT_PURPOSE]
					   ,[MAT_NO]
					   ,[MAT_DESC]
					   ,[COST_CENTER_CD]
					   ,[WBS_NO]
					   ,[WBS_NAME]
					   ,[ITEM_CLASS]
					   ,[ITEM_CLASS_DESC]
					   ,[VALUATION_CLASS]
					   ,[VALUATION_CLASS_DESC]
					   ,[SOURCE_TYPE]
					   ,[BUYER_CD]
					   ,[DOC_TYPE]
					   ,[PACKING_TYPE]
					   ,[PART_COLOR_SFX]
					   ,[SPECIAL_PROC_TYPE]
					   ,[PR_QTY]
					   ,[UNIT_OF_MEASURE_CD]
					   ,[ORI_CURR_CD]
					   ,[PRICE_PER_UOM]
					   ,[ORI_AMOUNT]
					   ,[LOCAL_CURR_CD]
					   ,[EXCHANGE_RATE]
					   ,[LOCAL_AMOUNT]
					   ,[GL_ACCOUNT]
					   ,[CAR_FAMILY_CD]
					   ,[MAT_TYPE_CD]
					   ,[MAT_GRP_CD]
					   ,[QUOTA_FLAG]
					   ,[PR_STATUS]
					   ,[VENDOR_CD]
					   ,[VENDOR_NAME]
					   ,[COMPLETION]
					   ,[CREATED_BY]
					   ,[CREATED_DT]
					   ,[CHANGED_BY]
					   ,[CHANGED_DT])
				SELECT @ROUTINE_NO
					   ,ITEM_NO
					   ,ITEM_TYPE
					   ,IS_PARENT
					   ,PROCUREMENT_PURPOSE
					   ,MAT_NO
					   ,MAT_DESC
					   ,COST_CENTER_CD
					   ,WBS_NO
					   ,WBS_NAME
					   ,ITEM_CLASS
					   ,ITEM_CLASS_DESC
					   ,VALUATION_CLASS
					   ,VALUATION_CLASS_DESC
					   ,SOURCE_TYPE
					   ,'' -- BUYER_CD
					   ,'PR' --DOC_TYPE
					   ,PACKING_TYPE
					   ,PART_COLOR_SFX
					   ,SPECIAL_PROC_TYPE
					   ,NEW_ITEM_QTY
					   ,ITEM_UOM
					   ,ORI_CURR_CD
					   ,NEW_PRICE_PER_UOM
					   ,NEW_AMOUNT
					   ,LOCAL_CURR_CD
					   ,EXCHANGE_RATE
					   ,NEW_LOCAL_AMOUNT
					   ,GL_ACCOUNT
					   ,CAR_FAMILY_CD
					   ,MAT_TYPE_CD
					   ,MAT_GRP_CD
					   ,QUOTA_FLAG
					   ,''--CASE WHEN(@PR_STATUS = '94') THEN '00' ELSE '10' END AS PR_STATUS
					   ,VENDOR_CD
					   ,VENDOR_NAME
					   ,COMPLETION
					   ,CREATED_BY
					   ,CREATED_DT
					   ,null
					   ,null
				FROM TB_T_PR_ITEM WHERE PROCESS_ID = @PROCESS_ID AND NEW_FLAG = 'Y' AND ISNULL(DELETE_FLAG, 'N') <> 'Y'
			
			SET @MESSAGE = 'Insert New Data Into TB_M_ROUTINE_PR_ITEM Success'
			SET @MSG_ID = 'MSG0000019'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
			EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;

			SET @STATUS = 'SUCCESS'
		END TRY
		BEGIN CATCH
			SET @MESSAGE = 'Insert New Data Into TB_M_ROUTINE_PR_ITEM Failed'
			SET @MSG_ID = 'MSG0000020'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
			EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;
			
			SET @MESSAGE = ERROR_MESSAGE()
			SET @MSG_ID = 'EXCEPTION'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
			EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;
			
			SET @STATUS = 'FAILED'
		END CATCH
	END

	SELECT @COUNT = COUNT(*) FROM TB_T_PR_ITEM 
			WHERE PROCESS_ID = @PROCESS_ID AND
				UPDATE_FLAG = 'Y' AND 
				ISNULL(NEW_FLAG, 'N') <> 'Y' AND 
				ISNULL(DELETE_FLAG, 'N') <> 'Y' AND 
				PROCESS_ID = @PROCESS_ID
	IF((@STATUS = 'SUCCESS') AND (@COUNT > 0))
	BEGIN
		BEGIN TRY
				SET @MESSAGE = 'Update Data Into TB_M_ROUTINE_PR_ITEM Started'
				SET @MSG_ID = 'MSG0000022'
				INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
				EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

				UPDATE TB_M_ROUTINE_PR_ITEM SET
					   [ITEM_NO] = B.ITEM_NO
					   ,[ITEM_TYPE] = B.ITEM_TYPE
					   ,[IS_PARENT] = B.IS_PARENT
					   ,[PROCUREMENT_PURPOSE] = B.PROCUREMENT_PURPOSE
					   ,[MAT_NO] = B.MAT_NO
					   ,[MAT_DESC] = B.MAT_DESC
					   ,[COST_CENTER_CD] = B.COST_CENTER_CD
					   ,[WBS_NO] = B.WBS_NO
					   ,[WBS_NAME] = B.WBS_NAME
					   ,[ITEM_CLASS] = B.ITEM_CLASS
					   ,[ITEM_CLASS_DESC] = B.ITEM_CLASS_DESC
					   ,[VALUATION_CLASS] = B.VALUATION_CLASS
					   ,[VALUATION_CLASS_DESC] = B.VALUATION_CLASS_DESC
					   ,[SOURCE_TYPE] = B.SOURCE_TYPE
					   ,[PACKING_TYPE] = B.PACKING_TYPE
					   ,[PART_COLOR_SFX] = B.PART_COLOR_SFX
					   ,[SPECIAL_PROC_TYPE] = B.SPECIAL_PROC_TYPE
					   ,[PR_QTY] = B.NEW_ITEM_QTY
					   ,[UNIT_OF_MEASURE_CD] = B.ITEM_UOM
					   ,[ORI_CURR_CD] = B.ORI_CURR_CD
					   ,[PRICE_PER_UOM] = B.NEW_PRICE_PER_UOM
					   ,[ORI_AMOUNT] = B.NEW_AMOUNT
					   ,[LOCAL_CURR_CD] = B.LOCAL_CURR_CD
					   ,[EXCHANGE_RATE] = B.EXCHANGE_RATE
					   ,[LOCAL_AMOUNT] = B.NEW_LOCAL_AMOUNT
					   ,[GL_ACCOUNT] = B.GL_ACCOUNT
					   ,[CAR_FAMILY_CD] = B.CAR_FAMILY_CD
					   ,[QUOTA_FLAG] = B.QUOTA_FLAG
					   ,[VENDOR_CD] = B.VENDOR_CD
					   ,[VENDOR_NAME] = B.VENDOR_NAME
					   ,[CHANGED_BY] = B.CHANGED_BY
					   ,[CHANGED_DT] = B.CHANGED_DT
					   ,[COMPLETION] = B.COMPLETION
				FROM TB_M_ROUTINE_PR_ITEM A 
					INNER JOIN TB_T_PR_ITEM B ON 
						A.ITEM_NO = B.ITEM_NO AND
						B.UPDATE_FLAG = 'Y' AND 
						ISNULL(B.NEW_FLAG, 'N') <> 'Y' AND 
						ISNULL(B.DELETE_FLAG, 'N') <> 'Y'  
					INNER JOIN TB_M_ROUTINE_PR_H C ON
						A.ROUTINE_NO = C.ROUTINE_NO AND 
						C.PROCESS_ID = B.PROCESS_ID AND
						B.PROCESS_ID = @PROCESS_ID
				
				SET @MESSAGE = 'Update Data Into TB_M_ROUTINE_PR_ITEM Success'
				SET @MSG_ID = 'MSG0000023'
				INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
				EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
				
				SET @STATUS = 'SUCCESS'
		END TRY
		BEGIN CATCH
			SET @MESSAGE = 'Update Data Into TB_M_ROUTINE_PR_ITEM Failed'
			SET @MSG_ID = 'MSG0000024'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
			EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;
			
			SET @MESSAGE = ERROR_MESSAGE()
			SET @MSG_ID = 'EXCEPTION'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
			EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;
			
			SET @STATUS = 'FAILED'
		END CATCH
	END

	SELECT @COUNT = COUNT(*) FROM TB_T_PR_ITEM WHERE PROCESS_ID = @PROCESS_ID AND DELETE_FLAG = 'Y' AND ISNULL(NEW_FLAG, 'N') <> 'Y'
	IF((@STATUS = 'SUCCESS') AND (@COUNT > 0))
	BEGIN
		BEGIN TRY
			SET @MESSAGE = 'Delete Data From TB_M_ROUTINE_PR_ITEM Started'
			SET @MSG_ID = 'MSG0000025'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
			EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
				
				DELETE FROM TB_M_ROUTINE_PR_ITEM
					WHERE ROUTINE_NO = @ROUTINE_NO AND 
						  ITEM_NO IN (SELECT ITEM_NO FROM TB_T_PR_ITEM
											WHERE PROCESS_ID = @PROCESS_ID AND DELETE_FLAG = 'Y' AND ISNULL(NEW_FLAG, 'N') <> 'Y')

			SET @MESSAGE = 'Delete Data From TB_M_ROUTINE_PR_ITEM Success'
			SET @MSG_ID = 'MSG0000026'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
			EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
			
			SET @STATUS = 'SUCCESS'
		END TRY
		BEGIN CATCH
			SET @MESSAGE = 'Delete Data From TB_M_ROUTINE_PR_ITEM Failed' 
			SET @MSG_ID = 'MSG0000027'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
			EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

			SET @MESSAGE = ERROR_MESSAGE()
			SET @MSG_ID = 'EXCEPTION'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
			EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;
			
			SET @STATUS = 'FAILED'
		END CATCH 
	END
END
/*** End of Insert TB_M_ROUTINE_PR_ITEM ***/

/*** Insert TB_M_ROUTINE_PR_SUBITEM ***/
IF(@STATUS = 'SUCCESS')
BEGIN
	SELECT @COUNT = COUNT(*) FROM TB_T_PR_SUBITEM WHERE PROCESS_ID = @PROCESS_ID AND NEW_FLAG = 'Y' AND ISNULL(DELETE_FLAG, 'N') <> 'Y'
	IF(@COUNT > 0)
	BEGIN
		BEGIN TRY
			SET @MESSAGE = 'Insert New Data Into TB_M_ROUTINE_PR_SUBITEM Started'
			SET @MSG_ID = 'MSG0000015'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
			EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
		
			INSERT INTO [dbo].[TB_M_ROUTINE_PR_SUBITEM]
					   ([ROUTINE_NO]
					   ,[ITEM_NO]
					   ,[SUBITEM_NO]
					   ,[MAT_NO]
					   ,[MAT_DESC]
					   ,[COST_CENTER_CD]
					   ,[WBS_NO]
					   ,[GL_ACCOUNT]
					   ,[SUBITEM_QTY]
					   ,[SUBITEM_UOM]
					   ,[PRICE_PER_UOM]
					   ,[ORI_AMOUNT]
					   ,[LOCAL_AMOUNT]
					   ,[COMPLETION]
					   ,[CREATED_BY]
					   ,[CREATED_DT]
					   ,[CHANGED_BY]
					   ,[CHANGED_DT])
				SELECT @ROUTINE_NO
					   ,ITEM_NO
					   ,SUBITEM_NO
					   ,MAT_NO
					   ,MAT_DESC
					   ,COST_CENTER_CD
					   ,WBS_NO
					   ,GL_ACCOUNT
					   ,NEW_SUBITEM_QTY
					   ,SUBITEM_UOM
					   ,NEW_PRICE_PER_UOM
					   ,NEW_AMOUNT
					   ,NEW_LOCAL_AMOUNT
					   ,'N'
					   ,CREATED_BY
					   ,CREATED_DT
					   ,null
					   ,null
				FROM TB_T_PR_SUBITEM WHERE PROCESS_ID = @PROCESS_ID AND NEW_FLAG = 'Y' AND ISNULL(DELETE_FLAG, 'N') <> 'Y'
			
			SET @MESSAGE = 'Insert New Data Into TB_M_ROUTINE_PR_SUBITEM Success'
			SET @MSG_ID = 'MSG0000019'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
			EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;

			SET @STATUS = 'SUCCESS'
		END TRY
		BEGIN CATCH
			SET @MESSAGE = 'Insert New Data Into TB_M_ROUTINE_PR_SUBITEM Failed'
			SET @MSG_ID = 'MSG0000020'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
			EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;
			
			SET @MESSAGE = ERROR_MESSAGE()
			SET @MSG_ID = 'EXCEPTION'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
			EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;
			
			SET @STATUS = 'FAILED'
		END CATCH
	END

	SELECT @COUNT = COUNT(*) FROM TB_T_PR_SUBITEM 
			WHERE PROCESS_ID = @PROCESS_ID AND
				UPDATE_FLAG = 'Y' AND 
				ISNULL(NEW_FLAG, 'N') <> 'Y' AND 
				ISNULL(DELETE_FLAG, 'N') <> 'Y' AND 
				PROCESS_ID = @PROCESS_ID
	IF((@STATUS = 'SUCCESS') AND (@COUNT > 0))
	BEGIN
		BEGIN TRY
				SET @MESSAGE = 'Update Data Into TB_M_ROUTINE_PR_SUBITEM Started'
				SET @MSG_ID = 'MSG0000022'
				INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
				EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

				UPDATE TB_M_ROUTINE_PR_SUBITEM SET
					   [MAT_NO] = B.MAT_NO
					   ,[MAT_DESC] = B.MAT_DESC
					   ,[COST_CENTER_CD] = B.COST_CENTER_CD
					   ,[WBS_NO] = B.WBS_NO
					   ,[GL_ACCOUNT] = B.GL_ACCOUNT
					   ,[SUBITEM_QTY] = B.GL_ACCOUNT
					   ,[SUBITEM_UOM] = B.SUBITEM_UOM
					   ,[PRICE_PER_UOM] = B.NEW_PRICE_PER_UOM
					   ,[ORI_AMOUNT] = B.NEW_AMOUNT
					   ,[LOCAL_AMOUNT] = B.NEW_LOCAL_AMOUNT
					   ,[CHANGED_BY] = B.CHANGED_BY
					   ,[CHANGED_DT] = B.CHANGED_DT
				FROM TB_M_ROUTINE_PR_SUBITEM A 
					INNER JOIN TB_T_PR_SUBITEM B ON 
						A.SUBITEM_NO = B.SUBITEM_NO AND
						B.UPDATE_FLAG = 'Y' AND 
						ISNULL(B.NEW_FLAG, 'N') <> 'Y' AND 
						ISNULL(B.DELETE_FLAG, 'N') <> 'Y'  
					INNER JOIN TB_M_ROUTINE_PR_ITEM C ON
						A.ROUTINE_NO = C.ROUTINE_NO AND
						A.ITEM_NO = C.ITEM_NO
					INNER JOIN TB_M_ROUTINE_PR_H D ON 
						D.PROCESS_ID = B.PROCESS_ID AND
						B.PROCESS_ID = @PROCESS_ID
				
				SET @MESSAGE = 'Update Data Into TB_M_ROUTINE_PR_SUBITEM Success'
				SET @MSG_ID = 'MSG0000023'
				INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
				EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
				
				SET @STATUS = 'SUCCESS'
		END TRY
		BEGIN CATCH
			SET @MESSAGE = 'Update Data Into TB_M_ROUTINE_PR_SUBITEM Failed'
			SET @MSG_ID = 'MSG0000024'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
			EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;
			
			SET @MESSAGE = ERROR_MESSAGE()
			SET @MSG_ID = 'EXCEPTION'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
			EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;
			
			SET @STATUS = 'FAILED'
		END CATCH
	END

	SELECT @COUNT = COUNT(*) FROM TB_T_PR_SUBITEM WHERE PROCESS_ID = @PROCESS_ID AND DELETE_FLAG = 'Y' AND ISNULL(NEW_FLAG, 'N') <> 'Y'
	IF((@STATUS = 'SUCCESS') AND (@COUNT > 0))
	BEGIN
		BEGIN TRY
			SET @MESSAGE = 'Delete Data From TB_M_ROUTINE_PR_SUBITEM Started'
			SET @MSG_ID = 'MSG0000025'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
			EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
				
				DELETE r
				FROM TB_M_ROUTINE_PR_SUBITEM r
					INNER JOIN TB_T_PR_SUBITEM t
					ON r.ITEM_NO = t.ITEM_NO AND r.SUBITEM_NO = t.SUBITEM_NO AND 
					   t.PROCESS_ID = @PROCESS_ID AND t.DELETE_FLAG = 'Y' AND ISNULL(t.NEW_FLAG, 'N') <> 'Y'
					INNER JOIN TB_M_ROUTINE_PR_H rh
					ON r.ROUTINE_NO = rh.ROUTINE_NO AND rh.PROCESS_ID = t.PROCESS_ID 

			SET @MESSAGE = 'Delete Data From TB_M_ROUTINE_PR_SUBITEM Success'
			SET @MSG_ID = 'MSG0000026'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
			EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
			
			SET @STATUS = 'SUCCESS'
		END TRY
		BEGIN CATCH
			SET @MESSAGE = 'Delete Data From TB_M_ROUTINE_PR_SUBITEM Failed' 
			SET @MSG_ID = 'MSG0000027'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
			EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

			SET @MESSAGE = ERROR_MESSAGE()
			SET @MSG_ID = 'EXCEPTION'
			INSERT INTO @TEMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MESSAGE, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
			EXEC dbo.sp_PutLog @MESSAGE, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;
			
			SET @STATUS = 'FAILED'
		END CATCH 
	END
END
/*** End of Insert TB_M_ROUTINE_PR_SUBITEM ***/

SELECT PROCESS_ID, PROCESS_TIME, MESSAGE_ID, MESSAGE_TYPE, MESSAGE_DESC, MODULE_ID, MODULE_DESC, FUNCTION_ID, STATUS_ID, [USER_NAME] FROM @TEMP_LOG
END





