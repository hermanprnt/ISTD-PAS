﻿INSERT INTO [dbo].[TB_T_VENDOR]
           ([VENDOR_CD]
           ,[VENDOR_NAME]
           ,[VENDOR_PLANT]
           ,[SAP_VENDOR_ID]
           ,[PURCHASING_GRP_CD]
           ,[PAYMENT_METHOD_CD]
           ,[PAYMENT_TERM_CD]
           ,[DELETION_FLAG]
           ,[CREATED_BY]
           ,[CREATED_DT]
           ,[CHANGED_BY]
           ,[CHANGED_DT]
           ,[VENDOR_ADDRESS]
           ,[POSTAL_CODE]
           ,[CITY]
           ,[ATTENTION]
           ,[PHONE]
           ,[FAX]
           ,[COUNTRY]
           ,[EMAIL_ADDR]
           ,[PROCESS_ID]
           ,[ROW]
           ,[ERROR_FLAG])
     VALUES
           (@VendorCd
           ,@VendorName
           ,@VendorPlant
           ,@SAPVendorID
           ,@PurchGroup
           ,@PaymentMethodCd
           ,@PaymentTermCd
           ,'N'
           ,@CreatedBy
           ,GETDATE()
           ,null
           ,null
           ,@Address
           ,@Postal
           ,@City
           ,@Attention
           ,@Phone
           ,@Fax
           ,@Country
           ,@Mail
           ,@ProcessId
           ,@Row
           ,@ErrorFlag)