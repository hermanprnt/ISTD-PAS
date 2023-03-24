ALTER PROCEDURE [dbo].[sp_POCreation_Initial]
    @currentUser VARCHAR(50) = '',
	@userName VARCHAR(200),
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6),
    @poNo VARCHAR(11)
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = 'sp_POCreation_Initial',
        @tmpLog LOG_TEMP

    SET NOCOUNT ON
    BEGIN TRY
        BEGIN TRAN Initial

        -- Update all unfinish process Log status to abnormal but recover latest unfinish process
        /*
           0: Starting/Initial
           1: Processing
           2: Finish
           3: Finish with error
           4: Abnormal/Unfinish
        */


        DECLARE @allUnfinishProcessId TABLE ( Id VARCHAR(50) )
        INSERT INTO @allUnfinishProcessId
        SELECT PROCESS_ID FROM TB_T_PO_H WHERE CREATED_BY = @currentUser AND GETDATE() > CREATED_DT ORDER BY CREATED_DT DESC

        IF (SELECT COUNT(0) FROM @allUnfinishProcessId) > 0 BEGIN SELECT TOP 1 @processId = Id FROM @allUnfinishProcessId END
        ELSE BEGIN SET @processId = 0 END
        EXEC dbo.sp_PutLog 'I|Start', @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Update unfinish process Log status: begin', @moduleId, @actionName, @functionId, 1, @currentUser)
        UPDATE TB_R_LOG_H SET PROCESS_STATUS = 4, CHANGED_BY = 'System', CHANGED_DT = GETDATE()
        WHERE PROCESS_ID IN (SELECT Id FROM @allUnfinishProcessId)
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Update unfinish process Log status: end', @moduleId, @actionName, @functionId, 1, @currentUser)

        -- Clear Temp table
        IF ISNULL(@poNo, '') = ''
        BEGIN
            SET @message = 'I|Delete data from TB_T_PO_H where CREATED_BY = ' + @currentUser + ': begin'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            DELETE FROM TB_T_PO_H WHERE CREATED_BY = @currentUser AND PROCESS_ID IN (SELECT Id FROM @allUnfinishProcessId WHERE Id <> @processId)
            DELETE FROM TB_T_PO_H WHERE CREATED_BY = @currentUser AND ISNULL(PO_NO, '') <> ''
            UPDATE TB_R_PR_ITEM SET PROCESS_ID = NULL WHERE PROCESS_ID IN (SELECT Id FROM @allUnfinishProcessId WHERE Id <> @processId)

            SET @message = 'I|Delete data from TB_T_PO_H where CREATED_BY = ' + @currentUser + ': end'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            SET @message = 'I|Delete data from TB_T_PO_ITEM where CREATED_BY = ' + @currentUser + ': begin'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            DELETE FROM TB_T_PO_ITEM WHERE CREATED_BY = @currentUser AND PROCESS_ID IN (SELECT Id FROM @allUnfinishProcessId WHERE Id <> @processId)
            DELETE FROM TB_T_PO_ITEM WHERE CREATED_BY = @currentUser AND ISNULL(PO_NO, '') <> ''

            SET @message = 'I|Delete data from TB_T_PO_ITEM where CREATED_BY = ' + @currentUser + ': end'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            SET @message = 'I|Delete data from TB_T_PO_SUBITEM where CREATED_BY = ' + @currentUser + ': begin'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            DELETE FROM TB_T_PO_SUBITEM WHERE CREATED_BY = @currentUser AND PROCESS_ID IN (SELECT Id FROM @allUnfinishProcessId WHERE Id <> @processId)
            DELETE FROM TB_T_PO_SUBITEM WHERE CREATED_BY = @currentUser AND ISNULL(PO_NO, '') <> ''

            SET @message = 'I|Delete data from TB_T_PO_SUBITEM where CREATED_BY = ' + @currentUser + ': end'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            SET @message = 'I|Delete data from TB_T_PO_CONDITION where CREATED_BY = ' + @currentUser + ': begin'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            DELETE FROM TB_T_PO_CONDITION WHERE CREATED_BY = @currentUser AND PROCESS_ID IN (SELECT Id FROM @allUnfinishProcessId WHERE Id <> @processId)
            DELETE FROM TB_T_PO_CONDITION WHERE CREATED_BY = @currentUser AND ISNULL(PO_NO, '') <> ''

            SET @message = 'I|Delete data from TB_T_PO_CONDITION where CREATED_BY = ' + @currentUser + ': end'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            SET @message = 'I|Delete data from TB_T_ATTACHMENT where CREATED_BY = ' + @currentUser + ': begin'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            DELETE FROM TB_T_ATTACHMENT WHERE CREATED_BY = @currentUser AND PROCESS_ID IN (SELECT Id FROM @allUnfinishProcessId WHERE Id <> @processId)
            DELETE FROM TB_T_ATTACHMENT WHERE CREATED_BY = @currentUser AND ISNULL(DOC_NO, '') <> ''

            SET @message = 'I|Delete data from TB_T_ATTACHMENT where CREATED_BY = ' + @currentUser + ': end'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
        END
        ELSE
        BEGIN
            SET @message = 'I|Delete data from TB_T_PO_H where CREATED_BY = ' + @currentUser + ': begin'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            UPDATE TB_R_PR_ITEM SET PROCESS_ID = NULL WHERE PROCESS_ID IN (SELECT PROCESS_ID FROM TB_T_PO_H WHERE CREATED_BY = @currentUser)
            DELETE FROM TB_T_PO_H WHERE CREATED_BY = @currentUser

            SET @message = 'I|Delete data from TB_T_PO_H where CREATED_BY = ' + @currentUser + ': end'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            SET @message = 'I|Delete data from TB_T_PO_ITEM where CREATED_BY = ' + @currentUser + ': begin'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            DELETE FROM TB_T_PO_ITEM WHERE CREATED_BY = @currentUser

            SET @message = 'I|Delete data from TB_T_PO_ITEM where CREATED_BY = ' + @currentUser + ': end'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            SET @message = 'I|Delete data from TB_T_PO_SUBITEM where CREATED_BY = ' + @currentUser + ': begin'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            DELETE FROM TB_T_PO_SUBITEM WHERE CREATED_BY = @currentUser

            SET @message = 'I|Delete data from TB_T_PO_SUBITEM where CREATED_BY = ' + @currentUser + ': end'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            SET @message = 'I|Delete data from TB_T_PO_CONDITION where CREATED_BY = ' + @currentUser + ': begin'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            DELETE FROM TB_T_PO_CONDITION WHERE CREATED_BY = @currentUser

            SET @message = 'I|Delete data from TB_T_PO_CONDITION where CREATED_BY = ' + @currentUser + ': end'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            SET @message = 'I|Delete data from TB_T_ATTACHMENT where CREATED_BY = ' + @currentUser + ': begin'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            DELETE FROM TB_T_ATTACHMENT WHERE CREATED_BY = @currentUser

            SET @message = 'I|Delete data from TB_T_ATTACHMENT where CREATED_BY = ' + @currentUser + ': end'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)	
        END

        SET @message = 'I|Reset PROCESS_ID from TB_R_ASSET where CHANGED_BY = ' + @currentUser + ' and PO_NO IS NULL AND PO_ITEM_NO IS NULL: begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        UPDATE TB_R_ASSET SET PROCESS_ID = NULL WHERE CHANGED_BY = @currentUser
        AND ISNULL(PROCESS_ID, '') NOT IN (SELECT DISTINCT PROCESS_ID FROM TB_T_PO_ITEM)
        AND (ISNULL(PO_NO, '') = '' AND ISNULL(PO_ITEM_NO, '') = '')

        SET @message = 'I|Reset PROCESS_ID from TB_R_ASSET where CHANGED_BY = ' + @currentUser + ' and PO_NO IS NULL AND PO_ITEM_NO IS NULL: end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        -- Check whether it's an add or edit
        IF ISNULL(@poNo, '') = ''
        BEGIN
            SET @message = 'S|Finish: It''s an Add process'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
            COMMIT TRAN Initial
            EXEC sp_PutLog_Temp @tmpLog
            SET NOCOUNT OFF
            SELECT @processId ProcessId, @message [Message]
            RETURN
        END

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Get currency rate: begin', @moduleId, @actionName, @functionId, 1, @currentUser)

        DECLARE @currencyRate TABLE ( CurrencyCode VARCHAR(3), ExchangeRate DECIMAL(7,2), ValidFrom DATETIME, ValidTo DATETIME )
        DECLARE
            @exchangeRate DECIMAL(7,2),
            @currency VARCHAR(3) = (SELECT PO_CURR FROM TB_R_PO_H WHERE PO_NO = @poNo)
        INSERT INTO @currencyRate EXEC sp_Currency_GetCurrency @currency
        IF (SELECT COUNT(0) FROM @currencyRate) > 1 BEGIN RAISERROR('Bug - Currently applicable currency rate is duplicate', 16, 1) END
        SELECT @exchangeRate = ExchangeRate FROM @currencyRate

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Get currency rate: end', @moduleId, @actionName, @functionId, 1, @currentUser)

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Copy TB_R_PO_H and TB_R_PO_ITEM to TB_T_PO_ITEM: begin', @moduleId, @actionName, @functionId, 1, @currentUser)

        INSERT INTO TB_T_PO_ITEM
        (PROCESS_ID, SEQ_ITEM_NO, PR_NO, PR_ITEM_NO, VENDOR_CD, VENDOR_NAME, QUOTATION_NO, PURCHASING_GRP_CD, VALUATION_CLASS, MAT_NO, MAT_DESC,
        PROCUREMENT_PURPOSE, DELIVERY_PLAN_DT, SOURCE_TYPE, PLANT_CD, SLOC_CD, WBS_NO, COST_CENTER_CD, UNLIMITED_FLAG, TOLERANCE_PERCENTAGE, SPECIAL_PROCUREMENT_TYPE,
        PO_QTY_ORI, PO_QTY_USED, PO_QTY_REMAIN, UOM, CURR_CD, ORI_AMOUNT, NEW_FLAG, UPDATE_FLAG, DELETE_FLAG, PO_NO,
        PO_ITEM_NO, URGENT_DOC, GROSS_PERCENT, ITEM_CLASS, IS_PARENT, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT, WBS_NAME,
        GL_ACCOUNT, 
		PO_QTY_NEW, 
		ORI_PRICE_PER_UOM, 
		NEW_PRICE_PER_UOM, 
		NEW_AMOUNT, 
		ORI_LOCAL_AMOUNT, 
		NEW_LOCAL_AMOUNT, 
		ASSET_NO, SUB_ASSET_NO)
        SELECT @processId, ROW_NUMBER() OVER (ORDER BY poi.PO_ITEM_NO ASC), poi.PR_NO, poi.PR_ITEM_NO, poh.VENDOR_CD, poh.VENDOR_NAME, '', poh.PURCHASING_GRP_CD, poi.VALUATION_CLASS,
        poi.MAT_NO, poi.MAT_DESC, poi.PROCUREMENT_PURPOSE, poi.DELIVERY_PLAN_DT, poi.SOURCE_TYPE, poi.PLANT_CD, poi.SLOC_CD, poi.WBS_NO, poi.COST_CENTER_CD, poi.UNLIMITED_FLAG,
        poi.TOLERANCE_PERCENTAGE, poi.SPECIAL_PROCUREMENT_TYPE, poi.PO_QTY_ORI, poi.PO_QTY_USED, poi.PO_QTY_REMAIN, poi.UOM, poh.PO_CURR,  poi.ORI_AMOUNT, 'N', 'Y', 'N',
        poi.PO_NO, poi.PO_ITEM_NO, poh.URGENT_DOC, poi.GROSS_PERCENT, poi.ITEM_CLASS, poi.IS_PARENT, poi.CREATED_BY, poi.CREATED_DT, @currentUser, GETDATE(), poi.WBS_NAME,
        poi.GL_ACCOUNT, 
		poi.PO_QTY_ORI, 
		poi.PRICE_PER_UOM, 
		poi.PRICE_PER_UOM, 
		poi.ORI_AMOUNT,
        poi.LOCAL_AMOUNT, 
		poi.LOCAL_AMOUNT, 
		ass.ASSET_NO, ass.SUB_ASSET_NO
        FROM TB_R_PO_H poh JOIN TB_R_PO_ITEM poi ON poh.PO_NO = poi.PO_NO
        LEFT JOIN TB_R_ASSET ass ON poi.PO_NO = ass.PO_NO AND poi.PO_ITEM_NO = ass.PO_ITEM_NO
        WHERE poh.PO_NO = @poNo

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Copy TB_R_PO_H and TB_R_PO_ITEM to TB_T_PO_ITEM: end', @moduleId, @actionName, @functionId, 1, @currentUser)

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Copy TB_R_PO_H to TB_T_PO_H: begin', @moduleId, @actionName, @functionId, 1, @currentUser)

        INSERT INTO TB_T_PO_H
        (PROCESS_ID, PO_DESC, DOC_DT, VENDOR_CD, VENDOR_NAME, PROC_CHANNEL_CD, PURCHASING_GRP_CD, ORI_CURR_CD, ORI_EXCHANGE_RATE, ORI_AMOUNT,
        NEW_CURR_CD, NEW_EXCHANGE_RATE, NEW_AMOUNT, ORI_LOCAL_AMOUNT, NEW_LOCAL_AMOUNT, NEW_FLAG, UPDATE_FLAG, DELETE_FLAG, PO_NO, PO_NOTE1,
        PO_NOTE2, PO_NOTE3, PO_NOTE4, PO_NOTE5, PO_NOTE6, PO_NOTE7, PO_NOTE8, PO_NOTE9, PO_NOTE10, VENDOR_ADDRESS, POSTAL_CODE, CITY, ATTENTION,
        PHONE, FAX, COUNTRY, DELIVERY_NAME, DELIVERY_ADDRESS, DELIVERY_POSTAL_CODE, DELIVERY_CITY, SPK_NO, SPK_DT, SPK_BIDDING_DT, SPK_WORK_DESC,
        SPK_LOCATION, SPK_AMOUNT, SPK_PERIOD_START, SPK_PERIOD_END, SPK_RETENTION, SPK_TERMIN_I, SPK_TERMIN_I_DESC, SPK_TERMIN_II, SPK_TERMIN_II_DESC,
        SPK_TERMIN_III, SPK_TERMIN_III_DESC, SPK_TERMIN_IV, SPK_TERMIN_IV_DESC, SPK_TERMIN_V, SPK_TERMIN_V_DESC, SPK_SIGN, SPK_SIGN_NAME, CREATED_BY,
        CREATED_DT, CHANGED_BY, CHANGED_DT)
        SELECT @processId, PO_DESC, DOC_DT, VENDOR_CD, VENDOR_NAME, (SELECT PROC_CHANNEL_CD FROM TB_M_COORDINATOR WHERE COORDINATOR_CD = PURCHASING_GRP_CD),
        PURCHASING_GRP_CD, PO_CURR, PO_EXCHANGE_RATE, PO_AMOUNT, PO_CURR, @exchangeRate, (SELECT SUM(NEW_AMOUNT) FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId AND PO_NO = @poNo),
        PO_AMOUNT, (SELECT SUM(NEW_LOCAL_AMOUNT) FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId AND PO_NO = @poNo) * @exchangeRate, 'N', 'Y', 'N', PO_NO, PO_NOTE1,
        PO_NOTE2, PO_NOTE3, PO_NOTE4, PO_NOTE5, PO_NOTE6, PO_NOTE7, PO_NOTE8, PO_NOTE9, PO_NOTE10, VENDOR_ADDRESS, POSTAL_CODE, CITY, ATTENTION,
        PHONE, FAX, COUNTRY, DELIVERY_NAME, DELIVERY_ADDRESS, DELIVERY_POSTAL_CODE, DELIVERY_CITY, SPK_NO, SPK_DT, SPK_BIDDING_DT, SPK_WORK_DESC,
        SPK_LOCATION, SPK_AMOUNT, SPK_PERIOD_START, SPK_PERIOD_END, SPK_RETENTION, SPK_TERMIN_I, SPK_TERMIN_I_DESC, SPK_TERMIN_II, SPK_TERMIN_II_DESC,
        SPK_TERMIN_III, SPK_TERMIN_III_DESC, SPK_TERMIN_IV, SPK_TERMIN_IV_DESC, SPK_TERMIN_V, SPK_TERMIN_V_DESC, SPK_SIGN, SPK_SIGN_NAME, CREATED_BY,
        CREATED_DT, @currentUser, GETDATE()
        FROM TB_R_PO_H WHERE PO_NO = @poNo

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Copy TB_R_PO_H to TB_T_PO_H: end', @moduleId, @actionName, @functionId, 1, @currentUser)

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Copy TB_R_PO_SUBITEM to TB_T_PO_SUBITEM: begin', @moduleId, @actionName, @functionId, 1, @currentUser)

        INSERT INTO TB_T_PO_SUBITEM
        (PROCESS_ID, SEQ_ITEM_NO, SEQ_NO, PO_NO, PO_ITEM_NO, PO_SUBITEM_NO, PR_NO, PR_ITEM_NO, PR_SUBITEM_NO, MAT_NO,
        MAT_DESC, WBS_NO, WBS_NAME, GL_ACCOUNT, COST_CENTER_CD, PO_QTY_ORI, PO_QTY_USED, PO_QTY_REMAIN, PO_QTY_NEW, UOM,
        CURR_CD, ORI_PRICE_PER_UOM, PRICE_PER_UOM, ORI_AMOUNT, AMOUNT, ORI_LOCAL_AMOUNT, LOCAL_AMOUNT, NEW_FLAG, UPDATE_FLAG, DELETE_FLAG,
        CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT)
        SELECT @processId, (SELECT SEQ_ITEM_NO FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId AND PO_NO = @poNo AND PO_ITEM_NO = posi.PO_ITEM_NO),
        ROW_NUMBER() OVER (ORDER BY posi.PO_SUBITEM_NO ASC), posi.PO_NO, posi.PO_ITEM_NO, posi.PO_SUBITEM_NO, posi.PR_NO, posi.PR_ITEM_NO, posi.PR_SUBITEM_NO,
        posi.MAT_NO, posi.MAT_DESC, posi.WBS_NO, posi.WBS_NAME, posi.GL_ACCOUNT, posi.COST_CENTER_CD, posi.PO_QTY_ORI, posi.PO_QTY_USED, posi.PO_QTY_REMAIN,
        posi.PO_QTY_ORI, posi.UOM, @currency, posi.PRICE_PER_UOM, posi.PRICE_PER_UOM,
        posi.ORI_AMOUNT, posi.ORI_AMOUNT, posi.LOCAL_AMOUNT,
        posi.LOCAL_AMOUNT, 'N', 'Y', 'N', posi.CREATED_BY, posi.CREATED_DT, @currentUser, GETDATE()
        FROM TB_R_PO_H poh JOIN TB_R_PO_SUBITEM posi ON poh.PO_NO = posi.PO_NO WHERE poh.PO_NO = @poNo

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Copy TB_R_PO_SUBITEM to TB_T_PO_SUBITEM: end', @moduleId, @actionName, @functionId, 1, @currentUser)

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Copy TB_R_PO_CONDITION to TB_T_PO_CONDITION: begin', @moduleId, @actionName, @functionId, 1, @currentUser)

        INSERT INTO TB_T_PO_CONDITION
        (PROCESS_ID, SEQ_ITEM_NO, PO_NO, PO_ITEM_NO, COMP_PRICE_CD, COMP_PRICE_RATE, INVOICE_FLAG, EXCHANGE_RATE, SEQ_NO, BASE_VALUE_FROM,
        BASE_VALUE_TO, PO_CURR, INVENTORY_FLAG, CALCULATION_TYPE, PLUS_MINUS_FLAG, CONDITION_CATEGORY, ACCRUAL_FLAG_TYPE, CONDITION_RULE, PRICE_AMT, QTY, QTY_PER_UOM,
        COMP_TYPE, PRINT_STATUS, NEW_FLAG, UPDATE_FLAG, DELETE_FLAG, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT)
        SELECT @processId, (SELECT SEQ_ITEM_NO FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId AND PO_NO = @poNo AND PO_ITEM_NO = poc.PO_ITEM_NO), poc.PO_NO, poc.PO_ITEM_NO, poc.COMP_PRICE_CD,
        poc.COMP_PRICE_RATE, poc.INVOICE_FLAG, poc.EXCHANGE_RATE, ROW_NUMBER() OVER (ORDER BY poc.PO_NO ASC, poc.PO_ITEM_NO ASC, poc.SEQ_NO ASC), poc.BASE_VALUE_FROM,
        poc.BASE_VALUE_TO, poc.PO_CURR, poc.INVENTORY_FLAG, poc.CALCULATION_TYPE, poc.PLUS_MINUS_FLAG, poc.CONDITION_CATEGORY, poc.ACCRUAL_FLAG_TYPE, poc.CONDITION_RULE,
        poc.PRICE_AMT, poc.QTY, poc.QTY_PER_UOM, poc.COMP_TYPE, poc.PRINT_STATUS, 'N', 'N', 'N', poc.CREATED_BY, poc.CREATED_DT, @currentUser, GETDATE()
        FROM TB_R_PO_CONDITION poc WHERE poc.PO_NO = @poNo

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Copy TB_R_PO_CONDITION to TB_T_PO_CONDITION: end', @moduleId, @actionName, @functionId, 1, @currentUser)

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Copy TB_R_ATTACHMENT to TB_T_ATTACHMENT: begin', @moduleId, @actionName, @functionId, 1, @currentUser)

        INSERT INTO TB_T_ATTACHMENT
        (PROCESS_ID, SEQ_NO, DOC_NO, DOC_TYPE, FILE_PATH, FILE_NAME_ORI, FILE_EXTENSION, FILE_SIZE, DELETE_FLAG, NEW_FLAG, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT)
        SELECT @processId, SEQ_NO, DOC_NO, DOC_TYPE, FILE_PATH, FILE_NAME_ORI, FILE_EXTENSION, FILE_SIZE, 'N', 'N', @currentUser, CREATED_DT, @currentUser, GETDATE()
        FROM TB_R_ATTACHMENT WHERE DOC_NO = @poNo AND DOC_SOURCE = 'PO'

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Copy TB_R_ATTACHMENT to TB_T_ATTACHMENT: end', @moduleId, @actionName, @functionId, 1, @currentUser)

        SET @message = 'I|Locking TB_R_ASSET with ProcessId ' + CAST(@processId AS VARCHAR) + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
        MERGE INTO TB_R_ASSET ass USING TB_T_PO_ITEM poit
        ON ass.ASSET_NO = poit.ASSET_NO AND ass.SUB_ASSET_NO = poit.SUB_ASSET_NO
        WHEN MATCHED THEN
        UPDATE SET PROCESS_ID = @processId
        ;
        SET @message = 'I|Locking TB_R_ASSET with ProcessId ' + CAST(@processId AS VARCHAR) + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        SET @message = 'I|Locking TB_R_PO_H with ProcessId ' + CAST(@processId AS VARCHAR) + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
        
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
			   (@processId
			   ,@moduleId
			   ,@functionId
			   ,@currentUser
			   ,@userName
			   ,@currentUser
			   ,GETDATE()
			   ,NULL
			   ,NULL)
		UPDATE TB_R_PO_H SET PROCESS_ID = @processId WHERE PO_NO = @poNo

        SET @message = 'I|Locking TB_R_PO_H with ProcessId ' + CAST(@processId AS VARCHAR) + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        COMMIT TRAN Initial

        SET @message = 'S|Finish'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN Initial
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
    END CATCH

    EXEC sp_PutLog_Temp @tmpLog
    SET NOCOUNT OFF
    SELECT @processId ProcessId, @message [Message]
END