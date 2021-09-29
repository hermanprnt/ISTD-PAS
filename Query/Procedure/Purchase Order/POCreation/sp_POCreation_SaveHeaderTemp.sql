ALTER PROCEDURE [dbo].[sp_POCreation_SaveHeaderTemp]
    @currentUser VARCHAR(50),
    @currentUserNoReg VARCHAR(50),
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6),
    @poNo VARCHAR(11),
    @poDesc VARCHAR(MAX),
    @poNote1 VARCHAR(132),
    @poNote2 VARCHAR(132),
    @poNote3 VARCHAR(132),
    @poNote4 VARCHAR(132),
    @poNote5 VARCHAR(132),
    @poNote6 VARCHAR(132),
    @poNote7 VARCHAR(132),
    @poNote8 VARCHAR(132),
    @poNote9 VARCHAR(132),
    @poNote10 VARCHAR(132),
    @vendor VARCHAR(6),
    @vendorName VARCHAR(50),
    @vendorAddress VARCHAR(150),
    @vendorCountry VARCHAR(2),
    @vendorCity VARCHAR(30),
    @vendorPostalCode VARCHAR(6),
    @vendorPhone VARCHAR(30),
    @vendorFax VARCHAR(30),
    @purchasingGroup VARCHAR(3),
    @currency VARCHAR(3),
    @deliveryAddress VARCHAR(MAX),
	@OtherMail VARCHAR(200)
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = 'sp_POCreation_SaveHeaderTemp',
        @tmpLog LOG_TEMP

    BEGIN TRY
        SET @message = 'I|Start'
        EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0

        BEGIN TRAN SaveHeader

        DECLARE
            @paymentMethod VARCHAR(1),
            @paymentTerm VARCHAR(4),
            @isOneTimeVendor BIT = (SELECT CASE WHEN COUNT(0) > 0 THEN 1 ELSE 0 END FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'OTV' AND SYSTEM_VALUE = @vendor),
            @vendorAttention VARCHAR(50) = '-'
		
		IF (ISNULL((SELECT SYSTEM_SOURCE FROM TB_R_PO_H WHERE PO_NO = @poNo), '') <> 'SAP')
		BEGIN
			SELECT
				@paymentMethod = PAYMENT_METHOD_CD,
				@paymentTerm = PAYMENT_TERM_CD,
				@vendorName = CASE WHEN @isOneTimeVendor = 1 THEN @vendorName ELSE VENDOR_NAME END,
				@vendorAddress = CASE WHEN @isOneTimeVendor = 1 THEN @vendorAddress ELSE VENDOR_ADDRESS END,
				@vendorCountry = CASE WHEN @isOneTimeVendor = 1 THEN @vendorCountry ELSE COUNTRY END,
				@vendorCity = CASE WHEN @isOneTimeVendor = 1 THEN @vendorCity ELSE CITY END,
				@vendorPostalCode = CASE WHEN @isOneTimeVendor = 1 THEN @vendorPostalCode ELSE POSTAL_CODE END,
				@vendorPhone = CASE WHEN @isOneTimeVendor = 1 THEN @vendorPhone ELSE PHONE END,
				@vendorFax = CASE WHEN @isOneTimeVendor = 1 THEN @vendorFax ELSE FAX END,
				@vendorAttention = CASE WHEN @isOneTimeVendor = 1 THEN @vendorAttention ELSE ATTENTION END
			FROM TB_M_VENDOR WHERE VENDOR_CD = @vendor
		END
		
        IF ISNULL(@purchasingGroup, '') = '' BEGIN RAISERROR('Purchasing Group is not valid.', 16, 1) END
        IF ISNULL(@vendorCountry, '') = '' BEGIN SELECT @vendorCountry = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'LOCAL_COUNTRY' END
        DECLARE @procChannel VARCHAR(4) = (SELECT PROC_CHANNEL_CD FROM TB_M_COORDINATOR WHERE COORDINATOR_CD = @purchasingGroup)
        DECLARE @delivName VARCHAR(30), @delivAddress VARCHAR(150), @delivPostal VARCHAR(6), @delivCity VARCHAR(30)
        SELECT @delivName = DELIVERY_NAME, @delivAddress = ADDRESS, @delivPostal = POSTAL_CODE, @delivCity = CITY
        FROM TB_M_DELIVERY_ADDR WHERE DELIVERY_ADDR = @deliveryAddress

        DECLARE @currencyRate TABLE ( CurrencyCode VARCHAR(3), ExchangeRate DECIMAL(7,2), ValidFrom DATETIME, ValidTo DATETIME )
        DECLARE @exchangeRate DECIMAL(7,2)
        INSERT INTO @currencyRate EXEC sp_Currency_GetCurrency @currency
        SET @message = 'Bug - Currently applicable currency rate of ''' + ISNULL(@currency, '') + ''' is duplicate'
        IF (SELECT COUNT(0) FROM @currencyRate) > 1 BEGIN RAISERROR(@message, 16, 1) END
        SELECT @exchangeRate = ExchangeRate FROM @currencyRate
        DELETE FROM @currencyRate

        IF EXISTS(SELECT PROCESS_ID FROM TB_T_PO_H WHERE PROCESS_ID = @processId)
        BEGIN
            UPDATE TB_T_PO_H SET
            PO_DESC = @poDesc, VENDOR_CD = @vendor, VENDOR_NAME = @vendorName,
            PURCHASING_GRP_CD = @purchasingGroup, CHANGED_BY = @currentUser, CHANGED_DT = GETDATE(),
            ORI_CURR_CD = NEW_CURR_CD, NEW_CURR_CD = @currency, ORI_EXCHANGE_RATE = NEW_EXCHANGE_RATE,
            NEW_EXCHANGE_RATE = @exchangeRate, PO_NOTE1 = @poNote1, PO_NOTE2 = @poNote2, PO_NOTE3 = @poNote3,
            PO_NOTE4 = @poNote4, PO_NOTE5 = @poNote5, PO_NOTE6 = @poNote6, PO_NOTE7 = @poNote7, PO_NOTE8 = @poNote8,
            PO_NOTE9 = @poNote9, PO_NOTE10 = @poNote10, VENDOR_ADDRESS = @vendorAddress, COUNTRY = @vendorCountry,
            POSTAL_CODE = @vendorPostalCode, CITY = @vendorCity, ATTENTION = @vendorAttention,
            PHONE = @vendorPhone, FAX = @vendorFax, DELIVERY_NAME = @delivName,
            DELIVERY_ADDRESS = @delivAddress, DELIVERY_POSTAL_CODE = @delivPostal, DELIVERY_CITY = @delivCity,
			OTHER_MAIL = @OtherMail
            WHERE PROCESS_ID = @processId
        END
        ELSE
        BEGIN
            INSERT INTO TB_T_PO_H
            (PROCESS_ID, PO_DESC, DOC_DT, VENDOR_CD, VENDOR_NAME, PROC_CHANNEL_CD, PURCHASING_GRP_CD, ORI_CURR_CD, ORI_EXCHANGE_RATE, ORI_AMOUNT,
            NEW_CURR_CD, NEW_EXCHANGE_RATE, NEW_AMOUNT, ORI_LOCAL_AMOUNT, NEW_LOCAL_AMOUNT, NEW_FLAG, UPDATE_FLAG, DELETE_FLAG, PO_NO, PO_NOTE1,
            PO_NOTE2, PO_NOTE3, PO_NOTE4, PO_NOTE5, PO_NOTE6, PO_NOTE7, PO_NOTE8, PO_NOTE9, PO_NOTE10, VENDOR_ADDRESS, POSTAL_CODE, CITY, ATTENTION,
            PHONE, FAX, COUNTRY, DELIVERY_NAME, DELIVERY_ADDRESS, DELIVERY_POSTAL_CODE, DELIVERY_CITY, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT, OTHER_MAIL)
            VALUES (@processId, @poDesc, GETDATE(), @vendor, @vendorName, @procChannel, @purchasingGroup, NULL, 0, 0, @currency, 0, 0, 0, 0, 'Y', 'N', 'N', NULL,
            @poNote1, @poNote2, @poNote3, @poNote4, @poNote5, @poNote6, @poNote7, @poNote8, @poNote9, @poNote10, @vendorAddress, @vendorPostalCode,
            @vendorCity, @vendorAttention, @vendorPhone, @vendorFax, @vendorCountry, @delivName, @delivAddress, @delivPostal, @delivCity, @currentUser,
            GETDATE(), NULL, NULL, @OtherMail)
        END

        MERGE INTO TB_T_PO_H poht USING (
            SELECT PROCESS_ID, ISNULL(PO_NO, '') PO_NO, SUM(NEW_AMOUNT) NewAmount, SUM(NEW_LOCAL_AMOUNT) NewLocalAmount
            FROM TB_T_PO_ITEM GROUP BY PROCESS_ID, ISNULL(PO_NO, '')
        ) poit
        ON poht.PROCESS_ID = poit.PROCESS_ID AND ISNULL(poht.PO_NO, '') = ISNULL(poit.PO_NO, '')
        WHEN MATCHED THEN UPDATE SET
        poht.NEW_AMOUNT = poit.NewAmount,
        poht.NEW_LOCAL_AMOUNT = poit.NewLocalAmount
        ;

        COMMIT TRAN SaveHeader

        SET @message = 'S|Finish'
        EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @processId OUTPUT, 'SUC', 'SUC', @moduleId, @functionId, 2
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN SaveHeader
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
    END CATCH

    EXEC sp_PutLog_Temp @tmpLog
    SET NOCOUNT OFF

    SELECT @message [Message]
END