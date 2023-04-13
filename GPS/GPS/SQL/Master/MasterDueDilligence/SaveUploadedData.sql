DECLARE @@MSG VARCHAR(8000) = '',
		@@VENDOR_NM VARCHAR(50),
		@@VENDOR_PLANT VARCHAR(50),
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

IF(@dd_Status = '1')
BEGIN
	SET @@VALID_DD_TO = DATEADD(year, 1, @dd_from)
END
ELSE IF(@dd_Status = '2')
BEGIN
	SET @@VALID_DD_TO = DATEADD(year, 2, @dd_from)
END
ELSE IF(@dd_Status = '3' OR @dd_Status = '4')
BEGIN
	SET @@VALID_DD_TO = DATEADD(year, 3, @dd_from)
END
ELSE 
BEGIN
	SET @@MSG = 'Please only insert due dilligence status between 1 - 4 only '
	SELECT @@MSG
	RETURN;
END

IF NOT EXISTS(SELECT 1 FROM TB_M_DUE_DILLIGENCE WHERE VENDOR_CODE = @vendorCd)
BEGIN
	INSERT INTO dbo.TB_M_DUE_DILLIGENCE
		(VENDOR_CODE,
         VENDOR_PLANT,
		 VENDOR_NAME,
		 DD_STATUS,
         VALID_DD_FROM,
         VALID_DD_TO,
         DD_ATTACHMENT,
         DELETION,
		 CREATED_BY,
		 CREATED_DT,
         CHANGED_BY,
         CHANGED_DT)
    VALUES
		(@vendorCd,
         @@VENDOR_PLANT,
	     @@VENDOR_NM,
	     @dd_Status,
         @dd_from,
		 @@VALID_DD_TO,
         '',
		 'N',
         @UId,
         GETDATE(),
         NULL,
         NULL)
END
ELSE
BEGIN
	
	UPDATE TB_M_DUE_DILLIGENCE 
		SET DD_STATUS = @dd_Status,
			VALID_DD_FROM = @dd_from,
			VALID_DD_TO = @@VALID_DD_TO,
			CHANGED_BY = @UId,
            CHANGED_DT = GETDATE()
		WHERE VENDOR_CODE = @vendorCd
END


SELECT 'SUCCESS'