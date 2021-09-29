INSERT INTO #tmpVendor
VALUES
(
	@VendorCode,
	@VendorName,
	@VendorPlant,
    @SAPVendorID,
	@PaymentMethodCode,
	@PaymentTermCode,
	'0',
	'System',
	GETDATE(),
	null,
	null
)