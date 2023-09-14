DECLARE @@VENDORPLN VARCHAR(20)
DECLARE @@SAP_VENDOR_CD VARCHAR(20)
DECLARE @@DELETION VARCHAR(20)
DECLARE @@ACTION VARCHAR(20)
DECLARE @@VALID_DD_FROM DATE = @vldddfrom
DECLARE @@VALID_DD_TO DATE = @vldddto

SELECT @@VENDORPLN = VENDOR_PLANT
FROM TB_M_VENDOR WHERE VENDOR_CD = @vendorcd

IF(@status = '1')
BEGIN
	SET @@VALID_DD_TO = DATEADD(year, 1, @@VALID_DD_FROM)
END
ELSE IF(@status = '2')
BEGIN
	SET @@VALID_DD_TO = DATEADD(year, 2, @@VALID_DD_FROM)
END
ELSE IF(@status = '3')
BEGIN
	SET @@VALID_DD_TO = DATEADD(year, 3, @@VALID_DD_FROM)
END
ELSE IF(@status = '4')
BEGIN
	SET @@VALID_DD_TO = '9999-01-01'
END


IF(LEN(@vendorcd) < 10)
BEGIN
	SET @@SAP_VENDOR_CD = RIGHT(CONCAT('0000000000', @vendorcd), 10);
END
ELSE
BEGIN
	SET @@SAP_VENDOR_CD = @vendorcd
END


IF(@Flag = '0')
BEGIN
	SET @@ACTION = 'INSERT'
END
ELSE 
BEGIN
	SET @@ACTION = 'UPDATE'
END

IF(@Flag = '0')
BEGIN
	IF NOT EXISTS(SELECT 1 FROM TB_M_DUE_DILLIGENCE WHERE VENDOR_CODE = @vendorcd) 
	BEGIN --Begin Insert
        INSERT INTO dbo.TB_M_DUE_DILLIGENCE
        ( 
            [VENDOR_CODE] ,
	        [VENDOR_PLANT] ,
	        [VENDOR_NAME] ,
	        [DD_STATUS] ,
	        [VALID_DD_FROM] ,
	        [VALID_DD_TO] ,
			 [DD_ATTACHMENT] ,
			 [SAP_VENDOR_ID],
			 [EMAIL_BUYER],
			 [EMAIL_SH],
			 [EMAIL_DPH],
			 [EMAIL_LEGAL],
	        [CREATED_BY] ,
	        [CREATED_DT] 
        )
    VALUES  ( @vendorcd,
              @@VENDORPLN,
              @vendornm,
			  @status,
			  @@VALID_DD_FROM,
              @@VALID_DD_TO,
              @fileUrl,
			  @@SAP_VENDOR_CD,
			  @mailbuyer,
			  @mailsh,
			  @maildph,
			  @maillegal,
              @uid,
              GETDATE()
            )
    
		 SELECT 'True|Save Successfully'
    END
    ELSE
	BEGIN
		SELECT 'Error|Fail to add Due Dilligence Data, because duplicate entries.'
	END

END
ELSE
BEGIN
	IF(@fileUrl <> '')
	BEGIN
		UPDATE dbo.TB_M_DUE_DILLIGENCE
		SET [VENDOR_CODE] = @vendorcd,
				[VENDOR_PLANT] = @@VENDORPLN,
				[VENDOR_NAME] =@vendornm,
				[DD_STATUS] =@status,
				[VALID_DD_FROM] =@@VALID_DD_FROM,
				[VALID_DD_TO] =@@VALID_DD_TO,
				[DD_ATTACHMENT] = @fileUrl ,
				[EMAIL_BUYER] = @mailbuyer,
				[EMAIL_SH] = @mailsh,
				[EMAIL_DPH] = @maildph,
				[EMAIL_LEGAL] = @maillegal,
			CHANGED_BY = @uid,
			CHANGED_DT = GETDATE()
		WHERE VENDOR_CODE = @vendorcd
	END
	ELSE
	BEGIN
		UPDATE dbo.TB_M_DUE_DILLIGENCE
		SET [VENDOR_CODE] = @vendorcd,
				[VENDOR_PLANT] = @@VENDORPLN,
				[VENDOR_NAME] =@vendornm,
				[DD_STATUS] =@status,
				[VALID_DD_FROM] =@@VALID_DD_FROM,
				[VALID_DD_TO] =@@VALID_DD_TO,
				[EMAIL_BUYER] = @mailbuyer,
				[EMAIL_SH] = @mailsh,
				[EMAIL_DPH] = @maildph,
				[EMAIL_LEGAL] = @maillegal,
			CHANGED_BY = @uid,
			CHANGED_DT = GETDATE()
		WHERE VENDOR_CODE = @vendorcd
	END
	SELECT 'True|Edit Successfully'
END

	--insert tb h
	INSERT INTO dbo.TB_H_DUE_DILLIGENCE
        ( 
            [VENDOR_CODE] ,
	        [VENDOR_PLANT] ,
	        [VENDOR_NAME] ,
	        [DD_STATUS] ,
	        [VALID_DD_FROM] ,
	        [VALID_DD_TO] ,
			[ACTION] ,
			[SAP_VENDOR_ID],
	        [CREATED_BY] ,
	        [CREATED_DT] 
        )
    VALUES  ( @vendorcd,
              @@VENDORPLN,
              @vendornm,
			  @status,
			  @@VALID_DD_FROM,
              @@VALID_DD_TO,
              @@ACTION,
			  @@SAP_VENDOR_CD,
              @uid,
              GETDATE()
            )