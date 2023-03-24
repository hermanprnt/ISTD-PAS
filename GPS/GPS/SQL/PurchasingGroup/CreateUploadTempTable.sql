IF OBJECT_ID('tempdb..#tmpPurchasingGroup') IS NULL
BEGIN
	CREATE TABLE #tmpPurchasingGroup
	(
		PurchasingGrpCode VARCHAR(6),
		PurchasingGrpDesc VARCHAR(30),
		ProcChannelCode VARCHAR(4),
		CreatedBy VARCHAR(20),
		CreatedDate DATETIME,
		ChangedBy VARCHAR(20),
		ChangedDate DATETIME
	)
END