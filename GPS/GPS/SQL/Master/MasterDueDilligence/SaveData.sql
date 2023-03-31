IF(@Flag = '0')
BEGIN
	IF NOT EXISTS(select 1 from TB_M_DUE_DILLIGENCE where VENDOR_CODE = @vendorcd)
	begin --Begin Insert
        INSERT INTO dbo.TB_M_DUE_DILLIGENCE
        ( 
            [VENDOR_CODE] ,
	        [VENDOR_PLANT] ,
	        [VENDOR_NAME] ,
	        [DD_STATUS] ,
	        [VALID_DD_FROM] ,
	        [VALID_DD_TO] ,
	        [AGREEMENT_NO] ,
	        [VALID_AGREEMENT_NO_FROM],
	        [VALID_AGREEMENT_NO_TO],
	        [CREATED_BY] ,
	        [CREATED_DT] ,
	        [CHANGED_BY] ,
	        [CHANGED_DT] 
        )
    VALUES  ( @vendorcd,
              @plan,
              @vendornm,
			  @status,
			  @vldddfrom,
              @vldddto,
              @agreementno,
			  @vldagreementfrom,
			  @vldagreementto,
              @uid,
              GETDATE(),
              NULL,
              NULL
            )
         
		 SELECT 'True|Save Successfully'
    END
    ELSE
    BEGIN
		SELECT 'Error|Fail to add Vendor Code, because duplicate entries.'
	end
END
ELSE
BEGIN
    UPDATE dbo.TB_M_DUE_DILLIGENCE
    SET [VENDOR_CODE] = @vendorcd,
	        [VENDOR_PLANT] = @plan,
	        [VENDOR_NAME] =@vendornm,
	        [DD_STATUS] =@status,
	        [VALID_DD_FROM] =@vldddfrom,
	        [VALID_DD_TO] =@vldddto,
	        [AGREEMENT_NO] =@agreementno,
	        [VALID_AGREEMENT_NO_FROM] =@vldagreementfrom,
	        [VALID_AGREEMENT_NO_TO] = @vldagreementto,
        CHANGED_BY = @uid,
        CHANGED_DT = GETDATE()
    WHERE VENDOR_CODE = @vendorcd

	SELECT 'True|Edit Successfully'
END