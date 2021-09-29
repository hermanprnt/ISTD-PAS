IF OBJECT_ID('tempdb..#tmpVendor') IS NULL
BEGIN
	CREATE TABLE #tmpVendor
	(
		VendorCode VARCHAR(6),
		VendorName VARCHAR(50),
		VendorPlant VARCHAR(4),
		SAPVendorID VARCHAR(10),
		PaymentMethodCode VARCHAR(1),
		PaymentTermCode VARCHAR(4),
		DeletionFlag CHAR(1),
		CreatedBy VARCHAR(20),
		CreatedDate DATETIME,
		ChangedBy VARCHAR(20),
		ChangedDate DATETIME
	)
END