DECLARE @@MSG VARCHAR(8000) = '',
		@@VENDOR_NM VARCHAR(50),
		@@VENDOR_PLANT VARCHAR(50),
		@@SAP_VENDOR_CD VARCHAR(20),
		@@VALID_DD_FROM DATETIME = @dd_from,
		@@VALID_DD_TO DATETIME

--------------------START OPERATION------------------------
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

IF(LEN(@vendorCd) < 10)
BEGIN
	SET @@SAP_VENDOR_CD = RIGHT(CONCAT('0000000000', @vendorCd), 10);
END
ELSE
BEGIN
	SET @@SAP_VENDOR_CD = @vendorCd
END


IF(@dd_Status = '1')
BEGIN
	SET @@VALID_DD_TO = DATEADD(year, 1, @dd_from)
END
ELSE IF(@dd_Status = '2')
BEGIN
	SET @@VALID_DD_TO = DATEADD(year, 2, @dd_from)
END
ELSE IF(@dd_Status = '3')
BEGIN
	SET @@VALID_DD_TO = DATEADD(year, 3, @dd_from)
END
ELSE IF(@dd_Status = '4')
BEGIN
	SET @@VALID_DD_FROM = '9999-01-01 00:00:00.000'
	SET @@VALID_DD_TO = '9999-01-01 00:00:00.000'
END

ELSE 
BEGIN
	SET @@MSG = 'Please only insert due dilligence status between 1 - 4 only '
	SELECT @@MSG
	RETURN;
END

IF(@dd_Status IN ('1','2','3') AND  IsNull(@dd_from, '') = '')
BEGIN
	SET @@MSG = 'Due Dilligence from cannot be empty'
	SELECT @@MSG
	RETURN;
END


IF NOT EXISTS(SELECT 1 FROM TB_M_DUE_DILLIGENCE WHERE VENDOR_CODE = @vendorCd)
BEGIN
	--INSERT TABLE MASTER
	INSERT INTO dbo.TB_M_DUE_DILLIGENCE
		(VENDOR_CODE,
         VENDOR_PLANT,
		 VENDOR_NAME,
		 DD_STATUS,
         VALID_DD_FROM,
         VALID_DD_TO,
		 EMAIL_BUYER,
		 EMAIL_SH,
		 EMAIL_DPH,
		 EMAIL_LEGAL,
		 SAP_VENDOR_ID,
		 CREATED_BY,
		 CREATED_DT,
         CHANGED_BY,
         CHANGED_DT)
    VALUES
		(
			@vendorCd,
         @@VENDOR_PLANT,
	     @@VENDOR_NM,
	     @dd_Status,
         @@VALID_DD_FROM,
		 @@VALID_DD_TO,
		 @mail_buyer,
		 @mail_sh,
		 @mail_dph,
		 @mail_legal,
		 @@SAP_VENDOR_CD,
         @UId,
         GETDATE(),
         NULL,
         NULL)

	--INSERT TABLE HISOTRY
	INSERT INTO dbo.TB_H_DUE_DILLIGENCE
        ( 
            [VENDOR_CODE] ,
	        [VENDOR_PLANT] ,
	        [VENDOR_NAME] ,
	        [DD_STATUS] ,
	        [VALID_DD_FROM] ,
	        [VALID_DD_TO] ,
			[ACTION],
			[SAP_VENDOR_ID],
	        [CREATED_BY] ,
	        [CREATED_DT] 
        )
    VALUES  ( 
			@vendorCd,
			 @@VENDOR_PLANT,
			 @@VENDOR_NM,
			 @dd_Status,
			 @@VALID_DD_FROM,
			 @@VALID_DD_TO,
              'UPLOAD_CREATE',
			  @@SAP_VENDOR_CD,
              @UId,
              GETDATE()
            )
	SELECT 'INSERT SUCCESS'
END
ELSE
BEGIN	
	UPDATE TB_M_DUE_DILLIGENCE 
		SET DD_STATUS = @dd_Status,
			VALID_DD_FROM = @@VALID_DD_FROM,
			VALID_DD_TO = @@VALID_DD_TO,
			EMAIL_BUYER = @mail_buyer,
			 EMAIL_SH = @mail_sh,
			 EMAIL_DPH= @mail_dph,
			 EMAIL_LEGAL= @mail_legal,
			 SAP_VENDOR_ID = @@SAP_VENDOR_CD,
			CHANGED_BY = @UId,
            CHANGED_DT = GETDATE()
		WHERE VENDOR_CODE = @vendorCd

		--INSERT TABLE HISOTRY
	INSERT INTO dbo.TB_H_DUE_DILLIGENCE
        ( 
            [VENDOR_CODE] ,
	        [VENDOR_PLANT] ,
	        [VENDOR_NAME] ,
	        [DD_STATUS] ,
	        [VALID_DD_FROM] ,
	        [VALID_DD_TO] ,
			[ACTION],
			[SAP_VENDOR_ID],
	        [CREATED_BY] ,
	        [CREATED_DT] 
        )
    VALUES  ( 
			@vendorCd,
			 @@VENDOR_PLANT,
			 @@VENDOR_NM,
			 @dd_Status,
			 @@VALID_DD_FROM,
			 @@VALID_DD_TO,
              'UPLOAD_UPDATE',
			  @@SAP_VENDOR_CD,
              @UId,
              GETDATE()
            )
			
		SELECT 'UPDATE SUCCESS'

END

