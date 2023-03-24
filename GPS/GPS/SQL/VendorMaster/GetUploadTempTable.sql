SELECT
	VendorCode VENDOR_CD,
	VendorName VENDOR_NAME,
	VendorPlant VENDOR_PLANT,
	SAPVendorID SAP_VENDOR_ID,
	PaymentMethodCode PAYMENT_METHOD_CD,
	PaymentTermCode PAYMENT_TERM_CD,
	DeletionFlag DELETION_FLAG,
	CreatedBy CREATED_BY,
	CreatedDate CREATED_DT,
	ChangedBy CHANGED_BY,
	ChangedDate CHANGED_DT
FROM #tmpVendor