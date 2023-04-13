DECLARE @@MSG VARCHAR(8000) = '',
		@@VENDOR_NM VARCHAR(50),
		@@VENDOR_PLANT VARCHAR(50),
		@@VALID_DD_TO DATETIME,
		@@STATUS VARCHAR(1)

----------------------START OPERATION------------------------
IF(ISNULL(@vendorCd, '') <> '')
BEGIN
	IF NOT EXISTS(SELECT 1 from TB_M_VENDOR WHERE VENDOR_CD = @vendorCd)
	BEGIN
		SET @@MSG = 'Vendor Code ' + @vendorCd + ' is not registered yet in TB_M_VENDOR'
		SELECT @@MSG
		RETURN;
	END
	ELSE
	BEGIN
		SELECT 
			@@VENDOR_NM = VENDOR_NAME,
			@@VENDOR_PLANT = VENDOR_PLANT
		FROM TB_M_VENDOR WHERE VENDOR_CD = @vendorCd
	END
END




IF NOT EXISTS(SELECT 1 FROM TB_M_AGREEMENT_NO WHERE VENDOR_CODE = @vendorCd)
BEGIN
	INSERT INTO dbo.TB_M_AGREEMENT_NO
		(VENDOR_CODE,
		 VENDOR_NAME,
		 PURCHASING_GROUP,
		 BUYER,
		 AGREEMENT_NO,
		 START_DATE,
		 EXP_DATE,
		 STATUS,
		 NEXT_ACTION,
		 CREATED_BY,
		 CREATED_DT,
         CHANGED_BY,
         CHANGED_DT)
    VALUES
		(@vendorCd,
	     @@VENDOR_NM,
		 @purchasingGroup,
		 @buyer,
		 @agreementNo,
		 @startDate,
		 @expDate,
		 '1',
		 @nextAction,
         @UId,
         GETDATE(),
         NULL,
         NULL)
END
ELSE
BEGIN
	
SELECT 'SUCCESS'
	
END


SELECT 'SUCCESS'