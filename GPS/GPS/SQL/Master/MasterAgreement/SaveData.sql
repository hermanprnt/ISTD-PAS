IF(@Flag = '0')
BEGIN
	IF NOT EXISTS(select 1 from TB_M_AGREEMENT_NO where VENDOR_CODE = @VendorCode)
	begin --Begin Insert
        INSERT INTO dbo.TB_M_AGREEMENT_NO
        ( VENDOR_CODE ,
          VENDOR_NAME ,
		  PURCHASING_GROUP,
		  BUYER,
          AGREEMENT_NO ,
          [START_DATE] ,
          EXP_DATE,
		  STATUS,
		  NEXT_ACTION,
          AN_ATTACHMENT,
		  CREATED_BY ,
          CREATED_DT ,
          CHANGED_BY ,
          CHANGED_DT
        )
    VALUES  ( @VendorCode,
              @VendorName,
			  @PurchasingGrp,
			  @Buyer,
              @Agreementno,
              @Startdate,
			  @Expdate,
			  @Status,
			  @Nextaction,
              @filename,
              @UId,
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
    UPDATE dbo.TB_M_AGREEMENT_NO
    SET VENDOR_NAME = @VendorName,
	    PURCHASING_GROUP = @PurchasingGrp,
		BUYER = @Buyer,
        AGREEMENT_NO = @Agreementno,
        START_DATE = @Startdate,
        EXP_DATE = @Expdate,
        STATUS = @Status,
        NEXT_ACTION = @Nextaction,
        AN_ATTACHMENT = @filename,
        CHANGED_BY = @UId,
        CHANGED_DT = GETDATE()
    WHERE VENDOR_CODE = @VendorCode

	SELECT 'True|Edit Successfully'
END