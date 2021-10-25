UPDATE TB_M_VENDOR
	SET 
		VENDOR_CD = @VENDOR_CD,
		VENDOR_NAME = @VENDOR_NAME,
		VENDOR_PLANT = @VENDOR_PLANT,
		SAP_VENDOR_ID = @SAP_VENDOR_ID,
		PAYMENT_METHOD_CD = @PAYMENT_METHOD_CD,
		PAYMENT_TERM_CD = @PAYMENT_TERM_CD,
		CHANGED_BY = 'pma.ilham',
		CHANGED_DT = GETDATE()
WHERE VENDOR_CD = @VENDOR_CD