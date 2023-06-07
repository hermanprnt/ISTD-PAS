
	 UPDATE dbo.TB_M_DUE_DILLIGENCE
		SET DELETION = 'Y',
			CHANGED_BY = @uid,
			CHANGED_DT = GETDATE()
		WHERE VENDOR_CODE = @vendorcd
	 select 'True|Delete successfully'

 --insert tb h
		INSERT INTO TB_H_DUE_DILLIGENCE(
            [VENDOR_CODE] ,
	        [VENDOR_PLANT] ,
	        [VENDOR_NAME] ,
	        [DD_STATUS] ,
	        [VALID_DD_FROM] ,
	        [VALID_DD_TO] ,
			 [ACTION],
	        [CREATED_BY] ,
	        [CREATED_DT],
			[SAP_VENDOR_ID]
			)
        SELECT 
		[VENDOR_CODE] ,
	        [VENDOR_PLANT] ,
	        [VENDOR_NAME] ,
	        [DD_STATUS] ,
	        [VALID_DD_FROM] ,
	        [VALID_DD_TO] ,
			 'DELETE' [ACTION],
	         @uid ,
	        GETDATE() 
			[SAP_VENDOR_ID]
        FROM TB_M_DUE_DILLIGENCE
		WHERE VENDOR_CODE = @vendorcd 
