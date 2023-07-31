DECLARE @@VALIDATE_INPUT VARCHAR (1) = '1'
DECLARE @@MSG VARCHAR (8000) 


IF (IsNull(@Startdate, '') = ''  OR IsNull(@Expdate, '') = '')
BEGIN
    SET @Status = 2
END


--VALIDATION

--END VALIDATION

    IF(@Flag = '0')
    BEGIN
	    IF NOT EXISTS(select 1 from TB_M_AGREEMENT_NO 
        where VENDOR_CODE = @VendorCode
        and AGREEMENT_NO = @Agreementno
        AND EXP_DATE = @Expdate )
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
              AMOUNT,
              EMAIL_BUYER,
              EMAIL_SH,
              EMAIL_DPH,
              EMAIL_LEGAL,
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
              
                  CASE @Amount
                    WHEN '' THEN 0
                    ELSE @Amount
                  END,
                  @mailbuyer,
                  @mailsh,
                  @maildph,
                  @maillegal,
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
        IF (@filename <> '')
        BEGIN
                UPDATE dbo.TB_M_AGREEMENT_NO
                 SET VENDOR_NAME = @VendorName,
	            PURCHASING_GROUP = @PurchasingGrp,
		        BUYER = @Buyer,
                AGREEMENT_NO = @Agreementno,
                START_DATE = @Startdate,
                EXP_DATE = @Expdate,
                STATUS = @Status,
                EMAIL_BUYER = @mailbuyer,
                EMAIL_SH = @mailsh,
                EMAIL_DPH = @maildph,
                EMAIL_LEGAL = @maillegal,
                NEXT_ACTION = @Nextaction,
                AN_ATTACHMENT = @filename,
                CHANGED_BY = @UId,
                CHANGED_DT = GETDATE()
            WHERE VENDOR_CODE = @VendorCode
            AND ID = @identity

	        SELECT 'True|Edit Successfully'
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
                EMAIL_BUYER = @mailbuyer,
                EMAIL_SH = @mailsh,
                EMAIL_DPH = @maildph,
                EMAIL_LEGAL = @maillegal,
                NEXT_ACTION = @Nextaction,
                CHANGED_BY = @UId,
                CHANGED_DT = GETDATE()
            WHERE VENDOR_CODE = @VendorCode
            AND ID = @identity

	        SELECT 'True|Edit Successfully'
        END
    END
    