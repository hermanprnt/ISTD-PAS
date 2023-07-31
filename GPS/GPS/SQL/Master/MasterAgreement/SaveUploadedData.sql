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

IF (ISNUMERIC(@amount) = 0 AND @amount <> '')
BEGIN
	SET @@MSG = 'Amount must be numeric'
	SELECT @@MSG
	RETURN;
END



IF NOT EXISTS(SELECT 1 FROM TB_M_AGREEMENT_NO 
	WHERE VENDOR_CODE = @vendorCd AND
	AGREEMENT_NO = @agreementNo AND
	EXP_DATE = @expDate)
BEGIN
	INSERT INTO dbo.TB_M_AGREEMENT_NO
		(VENDOR_CODE,
		 VENDOR_NAME,
		 PURCHASING_GROUP,
		 BUYER,
		 AGREEMENT_NO,
		 [START_DATE],
		 EXP_DATE,
		 [STATUS],
		 NEXT_ACTION,
		 AMOUNT,
		 EMAIL_BUYER,
		 EMAIL_SH,
		 EMAIL_DPH,
		 EMAIL_LEGAL,
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
		 CASE
			WHEN IsNull(@startDate, '') = ''  OR IsNull(@expDate, '') = '' THEN ''
			ELSE @startDate
		 END,
		 CASE
			WHEN IsNull(@startDate, '') = ''  OR IsNull(@expDate, '') = '' THEN ''
			ELSE @expDate
		 END,
		 CASE
			WHEN IsNull(@startDate, '') = ''  OR IsNull(@expDate, '') = '' THEN 2
			WHEN DATEADD(MONTH,3, GETDATE()) > @expDate THEN 4
			WHEN GETDATE() BETWEEN DATEADD(MONTH,-3,@expDate) AND @expDate THEN 3
			ELSE 1
		 END,
		 @nextAction,
              CASE @amount
                WHEN '' THEN 0
                ELSE @amount
              END,
		  @mailbuyer,
          @mailsh,
          @maildph,
          @maillegal,
         @UId,
         GETDATE(),
         NULL,
         NULL)
END
ELSE
BEGIN
	SELECT 'Fail to add Agreement Data, because duplicate entries.'
	RETURN;
	
END


SELECT 'SUCCESS UPLOAD'