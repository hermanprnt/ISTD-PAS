DECLARE @@VENDORPLN VARCHAR(20)
DECLARE @@SAP_VENDOR_CD VARCHAR(20)
DECLARE @@DELETION VARCHAR(20)
DECLARE @@ACTION VARCHAR(20)

SELECT @@VENDORPLN = VENDOR_PLANT
	,@@SAP_VENDOR_CD = SAP_VENDOR_ID
FROM TB_M_VENDOR WHERE VENDOR_CD = @vendorcd

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
	        [CREATED_BY] ,
	        [CREATED_DT] ,
	        [CHANGED_BY] ,
	        [CHANGED_DT] 
        )
    VALUES  ( @vendorcd,
              @@VENDORPLN,
              @vendornm,
			  @status,
			  @vldddfrom,
              @vldddto,
              @fileUrl,
			  @@SAP_VENDOR_CD,
              @uid,
              GETDATE(),
              NULL,
              NULL
            )
    
		 SELECT 'True|Save Successfully'
    END
    ELSE IF EXISTS(SELECT 1 FROM TB_M_DUE_DILLIGENCE WHERE VENDOR_CODE = @vendorcd AND DELETION = 'Y') 
    BEGIN
		UPDATE dbo.TB_M_DUE_DILLIGENCE
		SET [VENDOR_CODE] = @vendorcd,
				[VENDOR_PLANT] = @@VENDORPLN,
				[VENDOR_NAME] =@vendornm,
				[DD_STATUS] =@status,
				[VALID_DD_FROM] =@vldddfrom,
				[VALID_DD_TO] =@vldddto,
				[DD_ATTACHMENT] = @fileUrl,
				[DELETION] = 'N',
			CHANGED_BY = @uid,
			CHANGED_DT = GETDATE()
		WHERE VENDOR_CODE = @vendorcd

		SELECT 'True|Save Successfully'		
	END
	ELSE
	BEGIN
		SELECT 'Error|Fail to add Due Dilligence Data, because duplicate entries.'
	END

END
ELSE
BEGIN
    UPDATE dbo.TB_M_DUE_DILLIGENCE
    SET [VENDOR_CODE] = @vendorcd,
	        [VENDOR_PLANT] = @@VENDORPLN,
	        [VENDOR_NAME] =@vendornm,
	        [DD_STATUS] =@status,
	        [VALID_DD_FROM] =@vldddfrom,
	        [VALID_DD_TO] =@vldddto,
	        [DD_ATTACHMENT] = @fileUrl,
        CHANGED_BY = @uid,
        CHANGED_DT = GETDATE()
    WHERE VENDOR_CODE = @vendorcd

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
			  @vldddfrom,
              @vldddto,
              @@ACTION,
			  @@SAP_VENDOR_CD,
              @uid,
              GETDATE()
            )