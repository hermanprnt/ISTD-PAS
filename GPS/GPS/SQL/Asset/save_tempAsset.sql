﻿DECLARE @@MANDATORY_FIELD VARCHAR(MAX) = '',
		@@ISVALID_DT INT,
		@@IS_EXISTS INT = 0,

		@@MESSAGE VARCHAR(MAX) = '',
		@@IS_VALID CHAR(1) = 'Y'

--1. Check mandatory field
IF(@@IS_VALID = 'Y')
BEGIN
	IF(@PR_NO = '' OR @PR_NO IS NULL)
	BEGIN
		SET @@MANDATORY_FIELD = @@MANDATORY_FIELD + 'PR No,'
	END

	IF(@ITEM_NO = '' OR @ITEM_NO IS NULL)
	BEGIN
		SET @@MANDATORY_FIELD = @@MANDATORY_FIELD + 'PR Item No,'
	END

	IF(@SEQ_NO = '' OR @SEQ_NO IS NULL)
	BEGIN
		SET @@MANDATORY_FIELD = @@MANDATORY_FIELD + 'Seq No,'
	END

	IF(@REGISTRATION_DT = '' OR @REGISTRATION_DT IS NULL)
	BEGIN
		SET @@MANDATORY_FIELD = @@MANDATORY_FIELD + 'Registration Date,'
	END

	IF(@ASSET_CATEGORY = '' OR @ASSET_CATEGORY IS NULL)
	BEGIN
		SET @@MANDATORY_FIELD = @@MANDATORY_FIELD + 'Asset Category,'
	END

	IF(@ASSET_CLASS = '' OR @ASSET_CLASS IS NULL)
	BEGIN
		SET @@MANDATORY_FIELD = @@MANDATORY_FIELD + 'Asset Class,'
	END

	IF(@ASSET_LOCATION = '' OR @ASSET_LOCATION IS NULL)
	BEGIN
		SET @@MANDATORY_FIELD = @@MANDATORY_FIELD + 'Asset Location,'
	END

	IF(@@MANDATORY_FIELD <> '')
	BEGIN
		SET @@MANDATORY_FIELD = SUBSTRING(@@MANDATORY_FIELD, 1, LEN(@@MANDATORY_FIELD) - 1)
		SET @@MESSAGE = @@MANDATORY_FIELD + ' cannot be empty.'
		SET @@IS_VALID = 'N'
	END
END

--2. Check Date Formatting
IF(@@IS_VALID = 'Y')
BEGIN
	SELECT @@ISVALID_DT = ISDATE(@REGISTRATION_DT)
	IF(@@ISVALID_DT = 0)
	BEGIN
		SET @@MESSAGE = 'Registration Date is not in valid format. (Use date format : YYYY-MM-DD)'
		SET @@IS_VALID = 'N'
	END
END

--3. Check existing data asset (TB_T)
IF(@@IS_VALID = 'Y')
BEGIN
	SELECT @@IS_EXISTS = COUNT(1) FROM TB_T_ASSET WHERE PR_NO = @PR_NO AND PR_ITEM_NO = @ITEM_NO AND SEQ_NO = @SEQ_NO AND PROCESS_ID = @PROCESS_ID AND DELETE_FLAG = 'N'
	IF(@@IS_EXISTS > 0)
	BEGIN
		SET @@MESSAGE = 'Data is duplicate with previous row data.'
		SET @@IS_VALID = 'N'
	END
END

--4. Check existing data PR_ITEM
IF(@@IS_VALID = 'Y')
BEGIN
	SET @@IS_EXISTS = 0
	SELECT @@IS_EXISTS = COUNT(1) FROM TB_R_PR_ITEM WHERE PR_NO = @PR_NO AND PR_ITEM_NO = @ITEM_NO
	IF(@@IS_EXISTS > 0)
	BEGIN
		--4a. Check pr status
		IF((SELECT TOP 1 PR_STATUS FROM TB_R_PR_ITEM WHERE PR_NO = @PR_NO AND PR_ITEM_NO = @ITEM_NO) <> '14')
		BEGIN
			SET @@MESSAGE = 'Data is not released yet.'
			SET @@IS_VALID = 'N'
		END
	END
	ELSE
	BEGIN
		SET @@MESSAGE = 'Data is not exist in TB_R_PR_ITEM.'
		SET @@IS_VALID = 'N'
	END
END

--5. Check existing data asset (TB_R)
IF(@@IS_VALID = 'Y')
BEGIN
	SET @@IS_EXISTS = 0
	SELECT @@IS_EXISTS = COUNT(1) FROM TB_R_ASSET WHERE PR_NO = @PR_NO AND PR_ITEM_NO = @ITEM_NO AND SEQ_NO = @SEQ_NO
	IF(@@IS_EXISTS > 0)
	BEGIN
		SET @@MESSAGE = 'Data already exists in TB_R_ASSET.'
		SET @@IS_VALID = 'N'
	END
END

--6. Insert to TB_T_ASSET
INSERT INTO [dbo].[TB_T_ASSET]
           ([PR_NO]
           ,[PR_ITEM_NO]
           ,[SEQ_NO]
           ,[PROCESS_ID]
           ,[REGISTRATION_DT]
           ,[ASSET_CATEGORY]
           ,[ASSET_CLASS]
           ,[ASSET_LOCATION]
           ,[ASSET_NO]
           ,[SUB_ASSET_NO]
           ,[SERIAL_NO]
           ,[VALID_FLAG]
           ,[SYSTEM_MSG]
           ,[CREATED_BY]
           ,[CREATED_DT]
           ,[CHANGED_BY]
           ,[CHANGED_DT]
           ,[DELETE_FLAG])
	VALUES(@PR_NO
		  ,@ITEM_NO
		  ,@SEQ_NO
		  ,@PROCESS_ID
		  ,@REGISTRATION_DT
		  ,@ASSET_CATEGORY
		  ,@ASSET_CLASS
		  ,@ASSET_LOCATION
		  ,@ASSET_NO
		  ,@SUB_ASSET_NO
		  ,@SERIAL_NO
		  ,@@IS_VALID
		  ,@@MESSAGE
		  ,@USER_ID
		  ,GETDATE()
		  ,NULL
		  ,NULL
		  ,'N')