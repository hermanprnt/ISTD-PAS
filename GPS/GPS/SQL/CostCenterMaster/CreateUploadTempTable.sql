IF OBJECT_ID('tempdb..#tmpCostCenter') IS NULL
BEGIN
	CREATE TABLE #tmpCostCenter
	(
		CostCenterCode VARCHAR(8),
		CostCenterDesc VARCHAR(50),
		CostCenterGrpCode VARCHAR(8),
		ValidDateFrom datetime,
		ValidDateTo datetime,
		CreatedBy VARCHAR(20),
		CreatedDate DATETIME,
		ChangedBy VARCHAR(20),
		ChangedDate DATETIME
	)
END