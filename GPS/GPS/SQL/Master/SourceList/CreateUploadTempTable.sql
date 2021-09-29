IF OBJECT_ID('tempdb..#tmpSourceList') IS NULL
BEGIN
	CREATE TABLE #tmpSourceList
	(
		MaterialNo VARCHAR(23),
		VendorCode VARCHAR(6),
		ValidDateFrom datetime,
		ValidDateTo datetime,
		CreatedBy VARCHAR(20),
		CreatedDate DATETIME,
		ChangedBy VARCHAR(20),
		ChangedDate DATETIME
	)
END

IF OBJECT_ID('tempdb..#tmpUpdateSourceList') IS NULL
BEGIN
	CREATE TABLE #tmpUpdateSourceList
	(
		MaterialNo VARCHAR(23),
		ValidDateTo datetime,
		ChangedBy VARCHAR(20),
		ChangedDate DATETIME
	)
END