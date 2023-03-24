﻿DECLARE @@PROCESS_ID BIGINT,
		@@PR_STATUS_FLAG INT,
		@@ORG_ID INT,
		@@POSITION_LEVEL INT,
		@@SQLTEXT NVARCHAR(MAX),
		@@MSG VARCHAR(MAX),
		@@MSG_ID VARCHAR(12),
		@@LOCATION VARCHAR(50) = 'Creation Init',
		@@MODULE VARCHAR(4) = '2',
		@@FUNCTION VARCHAR(6) = '201002'

SET NOCOUNT ON;

SELECT 
	@@POSITION_LEVEL = POSITION_LEVEL, 
	@@ORG_ID = ORG_ID 
FROM TB_R_SYNCH_EMPLOYEE 
WHERE GETDATE() BETWEEN VALID_FROM AND VALID_TO 
		AND NOREG = @NOREG

DELETE FROM TB_T_PR_H WHERE [CREATED_BY] = @USERID
DELETE FROM TB_T_PR_ITEM WHERE [CREATED_BY] = @USERID
DELETE FROM TB_T_PR_SUBITEM WHERE [CREATED_BY] = @USERID
DELETE FROM TB_T_ATTACHMENT WHERE [CREATED_BY] = @USERID
DELETE FROM TB_T_LOCK WHERE [USER_ID] = @USERID AND FUNCTION_ID = @@FUNCTION AND MODULE_ID = @@MODULE 
--Update processid TB_R_PR_H if processid not registered in TB_T_LOCK
UPDATE TB_R_PR_H
	SET PROCESS_ID = NULL
WHERE PROCESS_ID IS NOT NULL AND PROCESS_ID NOT IN (SELECT PROCESS_ID FROM TB_T_LOCK)

IF(@PR_NO = '0')
BEGIN
	SET @@MSG = 'PR Creation Process Initialization'
	SET @@MSG_ID = 'MSG0000085'
	EXEC dbo.sp_PutLog @@MSG, @USERID, @@LOCATION, @@PROCESS_ID OUTPUT, @@MSG_ID, 'INF', @@MODULE, @@FUNCTION, 1;
END
ELSE
BEGIN
	SET @@MSG = 'Update PR for PR No ' + @PR_NO + ' Initialized'
	SET @@MSG_ID = 'MSG0000086'
	EXEC dbo.sp_PutLog @@MSG, @USERID, @@LOCATION, @@PROCESS_ID OUTPUT, @@MSG_ID, 'INF', @@MODULE, @@FUNCTION, 1;
END

IF(@PR_NO <> '0')
BEGIN
	INSERT INTO [dbo].[TB_T_PR_H]
           ([PROCESS_ID]
           ,[PR_NO]
           ,[DOC_DT]
           ,[PR_DESC]
           ,[PR_TYPE]
           ,[PLANT_CD]
           ,[SLOC_CD]
           ,[PR_COORDINATOR]
           ,[DIVISION_ID]
           ,[DIVISION_NAME]
           ,[PR_STATUS]
           ,[PROJECT_NO]
           ,[URGENT_DOC]
           ,[EQUIP_NO]
           ,[PR_NOTES]
           ,[DELIVERY_PLAN_DT]
           ,[CREATED_BY]
           ,[CREATED_DT]
           ,[CHANGED_BY]
           ,[CHANGED_DT])
    SELECT @@PROCESS_ID
		   ,PR_NO
		   ,DOC_DT
		   ,PR_DESC
		   ,PR_TYPE
		   ,PLANT_CD
		   ,SLOC_CD
		   ,PR_COORDINATOR
		   ,DIVISION_ID
		   ,DIVISION_NAME
		   ,PR_STATUS
		   ,PROJECT_NO
		   ,URGENT_DOC
		   ,MAIN_ASSET
		   ,PR_NOTES
		   ,DELIVERY_PLAN_DT
		   ,@USERID
		   ,GETDATE()
		   ,null
		   ,null
	FROM TB_R_PR_H WHERE PR_NO = @PR_NO

	INSERT INTO [dbo].[TB_T_PR_ITEM]
			   ([PROCESS_ID]
			   ,[ITEM_NO]
			   ,[ITEM_TYPE]
			   ,[IS_PARENT]
			   ,[PROCUREMENT_PURPOSE]
			   ,[MAT_NO]
			   ,[MAT_DESC]
			   ,[COST_CENTER_CD]
			   ,[WBS_NO]
			   ,[WBS_NAME]
			   ,[GL_ACCOUNT]
			   ,[ITEM_CLASS]
			   ,[ITEM_CLASS_DESC]
			   ,[VALUATION_CLASS]
			   ,[VALUATION_CLASS_DESC]
			   ,[SOURCE_TYPE]
			   ,[PACKING_TYPE]
			   ,[PART_COLOR_SFX]
			   ,[SPECIAL_PROC_TYPE]
			   ,[CAR_FAMILY_CD]
			   ,[MAT_TYPE_CD]
			   ,[MAT_GRP_CD]
			   ,[ORI_ITEM_QTY]
			   ,[NEW_ITEM_QTY]
			   ,[ITEM_UOM]
			   ,[ORI_CURR_CD]
			   ,[ORI_PRICE_PER_UOM]
			   ,[NEW_PRICE_PER_UOM]
			   ,[ORI_AMOUNT]
			   ,[NEW_AMOUNT]
			   ,[LOCAL_CURR_CD]
			   ,[EXCHANGE_RATE]
			   ,[ORI_LOCAL_AMOUNT]
			   ,[NEW_LOCAL_AMOUNT]
			   ,[DELIVERY_PLAN_DT]
			   ,[VENDOR_CD]
			   ,[VENDOR_NAME]
			   ,[RELEASE_FLAG]
			   ,[QUOTA_FLAG]
			   ,[PR_NEXT_STATUS]
			   ,[NEW_FLAG]
			   ,[UPDATE_FLAG]
			   ,[DELETE_FLAG]
			   ,[CREATED_BY]
			   ,[CREATED_DT]
			   ,[CHANGED_BY]
			   ,[CHANGED_DT]
			   ,[COMPLETION]
			   ,[ASSET_CATEGORY]
			   ,[ASSET_CLASS]
			   ,[ASSET_LOCATION]
			   ,[ASSET_NO]
			   ,[OPEN_QTY]
			   ,[USED_QTY]
			   ,[BUDGET_REF]
			   ,[OLD_WBS_NO]
			   ,[OLD_WBS_NAME])
		SELECT @@PROCESS_ID
			   ,[PR_ITEM_NO]
			   ,[ITEM_TYPE]
			   ,[IS_PARENT]
			   ,[PROCUREMENT_PURPOSE]
			   ,[MAT_NO]
			   ,[MAT_DESC]
			   ,[COST_CENTER_CD]
			   ,[WBS_NO]
			   ,[WBS_NAME]
			   ,[GL_ACCOUNT]
			   ,[ITEM_CLASS]
			   ,[ITEM_CLASS_DESC]
			   ,[VALUATION_CLASS]
			   ,[VALUATION_CLASS_DESC]
			   ,[SOURCE_TYPE]
			   ,[PACKING_TYPE]
			   ,[PART_COLOR_SFX]
			   ,[SPECIAL_PROC_TYPE]
			   ,[CAR_FAMILY_CD]
			   ,[MAT_TYPE_CD]
			   ,[MAT_GRP_CD]
			   ,[PR_QTY]
			   ,[PR_QTY]
			   ,[UNIT_OF_MEASURE_CD]
			   ,[ORI_CURR_CD]
			   ,[PRICE_PER_UOM]
			   ,[PRICE_PER_UOM]
			   ,[ORI_AMOUNT]
			   ,[ORI_AMOUNT]
			   ,[LOCAL_CURR_CD]
			   ,[EXCHANGE_RATE]
			   ,[LOCAL_AMOUNT]
			   ,[LOCAL_AMOUNT]
			   ,[DELIVERY_PLAN_DT]
			   ,[VENDOR_CD]
			   ,[VENDOR_NAME]
			   ,[RELEASE_FLAG]
			   ,[QUOTA_FLAG]
			   ,[PR_NEXT_STATUS]
			   ,'N'
			   ,'N'
			   ,'N'
			   ,[CREATED_BY]
			   ,[CREATED_DT]
			   ,[CHANGED_BY]
			   ,[CHANGED_DT]
			   ,CASE WHEN(ITEM_CLASS = 'M' AND (PRICE_PER_UOM = 0 OR PR_QTY = 0)) THEN 'N' ELSE 'Y' END
			   ,[ASSET_CATEGORY]
			   ,[ASSET_CLASS]
			   ,[ASSET_LOCATION]
			   ,[ASSET_NO]
			   ,[OPEN_QTY]
			   ,[USED_QTY]
			   ,[BUDGET_REF]
			   ,[WBS_NO]
			   ,[WBS_NAME]
		FROM [dbo].[TB_R_PR_ITEM] 
		WHERE PR_NO = @PR_NO /*AND PR_ITEM_NO IN 
		(SELECT DISTINCT ITEM_NO FROM TB_R_WORKFLOW 
			WHERE DOCUMENT_NO = @PR_NO AND STRUCTURE_ID = @@ORG_ID AND APPROVER_POSITION = @@POSITION_LEVEL)*/
		ORDER BY PR_ITEM_NO ASC

	INSERT INTO [dbo].[TB_T_PR_SUBITEM]
			   ([PROCESS_ID]
			   ,[ITEM_NO]
			   ,[SUBITEM_NO]
			   ,[MAT_NO]
			   ,[MAT_DESC]
			   ,[COST_CENTER_CD]
			   ,[WBS_NO]
			   ,[GL_ACCOUNT]
			   ,[ORI_SUBITEM_QTY]
			   ,[NEW_SUBITEM_QTY]
			   ,[SUBITEM_UOM]
			   ,[ORI_PRICE_PER_UOM]
			   ,[NEW_PRICE_PER_UOM]
			   ,[ORI_AMOUNT]
			   ,[NEW_AMOUNT]
			   ,[ORI_LOCAL_AMOUNT]
			   ,[NEW_LOCAL_AMOUNT]
			   ,[CREATED_BY]
			   ,[CREATED_DT]
			   ,[CHANGED_BY]
			   ,[CHANGED_DT]
			   ,[OLD_WBS_NO])
		SELECT @@PROCESS_ID
			  ,A.[PR_ITEM_NO]
			  ,A.[PR_SUBITEM_NO]
			  ,A.[MAT_NO]
			  ,A.[MAT_DESC]
			  ,A.[COST_CENTER_CD]
			  ,A.[WBS_NO]
			  ,A.[GL_ACCOUNT]
			  ,A.[SUBITEM_QTY]
			  ,A.[SUBITEM_QTY]
			  ,A.[SUBITEM_UOM]
			  ,A.[PRICE_PER_UOM]
			  ,A.[PRICE_PER_UOM]
			  ,A.[ORI_AMOUNT]
			  ,A.[ORI_AMOUNT]
			  ,A.[LOCAL_AMOUNT]
			  ,A.[LOCAL_AMOUNT]
			  ,A.[CREATED_BY]
			  ,A.[CREATED_DT]
			  ,A.[CHANGED_BY]
			  ,A.[CHANGED_DT]
			  ,A.[WBS_NO]
		  FROM [dbo].[TB_R_PR_SUBITEM] A
		  INNER JOIN [dbo].[TB_R_PR_ITEM] B
			  ON A.PR_NO = @PR_NO AND A.PR_NO = B.PR_NO AND A.PR_ITEM_NO = B.PR_ITEM_NO /*AND 
			  B.PR_ITEM_NO IN 
				(SELECT DISTINCT ITEM_NO FROM TB_R_WORKFLOW 
					WHERE DOCUMENT_NO = @PR_NO AND STRUCTURE_ID = @@ORG_ID AND APPROVER_POSITION = @@POSITION_LEVEL)*/
				ORDER BY PR_ITEM_NO, PR_SUBITEM_NO ASC

	INSERT INTO [dbo].[TB_T_ATTACHMENT]
        ([DOC_NO]
        ,[SEQ_NO]
        ,[DOC_TYPE]
        ,[FILE_PATH]
        ,[FILE_NAME_ORI]
        ,[FILE_EXTENSION]
		,[FILE_SIZE]
        ,[PROCESS_ID]
		,[NEW_FLAG]
		,[DELETE_FLAG]
		,[CREATED_BY]
		,[CREATED_DT])
	SELECT [DOC_NO]
		,[SEQ_NO]
		,[DOC_TYPE]
		,[FILE_PATH]
		,[FILE_NAME_ORI]
		,[FILE_EXTENSION]
		,[FILE_SIZE]
		,@@PROCESS_ID
		,'N'
		,'N'
		,CREATED_BY
		,CREATED_DT
	FROM TB_R_ATTACHMENT WHERE DOC_NO = @PR_NO ORDER BY SEQ_NO

	UPDATE TB_R_PR_H SET PROCESS_ID = @@PROCESS_ID WHERE PR_NO = @PR_NO
	
	SET @@MSG = 'Locking TB_R_PR_ITEM with PR No ' + @PR_NO
	SET @@MSG_ID = 'MSG0000086'
	EXEC dbo.sp_PutLog @@MSG, @USERID, @@LOCATION, @@PROCESS_ID , @@MSG_ID, 'SUC', @@MODULE, @@FUNCTION, 2;
END

INSERT INTO [dbo].[TB_T_LOCK]
        ([PROCESS_ID]
        ,[MODULE_ID]
        ,[FUNCTION_ID]
        ,[USER_ID]
        ,[USER_NAME]
        ,[CREATED_BY]
        ,[CREATED_DT]
        ,[CHANGED_BY]
        ,[CHANGED_DT])
    VALUES
        (@@PROCESS_ID
        ,@@MODULE
        ,@@FUNCTION
        ,@USERID
        ,@USERNAME
        ,@USERID
        ,GETDATE()
        ,null
        ,null)

SELECT @@PROCESS_ID