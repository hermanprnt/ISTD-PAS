IF(@Flag = '0')
BEGIN
	if exists(select 1 from TB_M_VENDOR 
		          WHERE VENDOR_CD = @VendorCd)
        begin
			select 'Error|Data is duplicate. Please check mandatory field *)'
		end
		else
		begin
            --Begin Insert
           INSERT INTO [dbo].[TB_M_VENDOR]
			   ([VENDOR_CD]
			   ,[VENDOR_NAME]
			   ,[VENDOR_PLANT]
			   ,[SAP_VENDOR_ID]
			   ,[PURCHASING_GRP_CD]
			   ,[PAYMENT_METHOD_CD]
			   ,[PAYMENT_TERM_CD]
			   ,[DELETION_FLAG]
			   ,[VENDOR_ADDRESS]
			   ,[POSTAL_CODE]
			   ,[CITY]
			   ,[ATTENTION]
			   ,[PHONE]
			   ,[FAX]
			   ,[COUNTRY]
			   ,[CREATED_BY]
			   ,[CREATED_DT]
			   ,[CHANGED_BY]
			   ,[CHANGED_DT]
			   ,[EMAIL_ADDR])
		 VALUES
			   (@VendorCd
			   ,@VendorName
			   ,@VendorPlant
			   ,@SAPVendorID
			   ,@PurchGroup
			   ,@PaymentMethodCd
			   ,@PaymentTermCd
			   ,'0'
			   ,@Address
			   ,@Postal
			   ,@City
			   ,@Attention
			   ,@Phone
			   ,@Fax
			   ,@Country
			   ,@uid
			   ,GETDATE()
			   ,null
			   ,null
			   ,SUBSTRING(@Mail, 1, LEN(@Mail)-1))

		   select 'True|Save Successfully'
        end
END
ELSE
BEGIN
    --Begin Edit
    UPDATE TB_M_VENDOR 
    SET VENDOR_NAME = @VendorName,
        VENDOR_PLANT = @VendorPlant,
        SAP_VENDOR_ID = @SAPVendorID,
		PURCHASING_GRP_CD = @PurchGroup,
        PAYMENT_METHOD_CD = @PaymentMethodCd,
        PAYMENT_TERM_CD = @PaymentTermCd,
		VENDOR_ADDRESS = @Address,
		POSTAL_CODE = @Postal,
		CITY = @City,
		ATTENTION = @Attention,
		PHONE = @Phone,
		FAX = @Fax,
		COUNTRY = @Country,
        CHANGED_BY = @uid,
        CHANGED_DT = GETDATE(),
		EMAIL_ADDR = SUBSTRING(@Mail, 1, LEN(@Mail)-1)
    WHERE VENDOR_CD = @VendorCd

	select 'True|Save Successfully'
END