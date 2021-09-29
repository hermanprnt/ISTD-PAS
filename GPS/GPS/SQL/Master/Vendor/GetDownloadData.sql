SELECT  VENDOR_CD AS VendorCd,
		VENDOR_NAME AS VendorName,
		VENDOR_PLANT AS VendorPlant,
		SAP_VENDOR_ID AS SAPVendorID,
		PAYMENT_METHOD_CD AS PaymentMethodCd,
		PAYMENT_TERM_CD AS PaymentTermCd,
		CREATED_BY AS CreatedBy,
		CONVERT(DATETIME,CREATED_DT) AS CreatedDt,
		CHANGED_BY AS ChangedBy,
		CONVERT(DATETIME,CHANGED_DT) AS ChangedDt
FROM TB_M_VENDOR
	WHERE ((VENDOR_CD LIKE '%' + @VendorCd + '%'
			AND isnull(@VendorCd, '') <> ''
			OR (isnull(@VendorCd, '') = '')))
	AND ((VENDOR_NAME LIKE '%' + @VendorName + '%'
			AND isnull(@VendorName, '') <> ''
			OR (isnull(@VendorName, '') = '')))
	AND ((PAYMENT_METHOD_CD = @PayMethod
			AND isnull(@PayMethod, '') <> ''
			OR (isnull(@PayMethod, '') = '')))
	AND ((PAYMENT_TERM_CD = @PayTerm
			AND isnull(@PayTerm, '') <> ''
			OR (isnull(@PayTerm, '') = '')))
	AND DELETION_FLAG <> '1'