IF OBJECT_ID('tempdb..#tmpCostCenterMapping') IS NULL
BEGIN
	CREATE TABLE #tmpCostCenterMapping
	(
		CostCenterGrpCode VARCHAR(10),
		CostCenterGrpDesc VARCHAR(50),
		DivisionId VARCHAR(4),
		CreatedBy VARCHAR(20),
		CreatedDate DATETIME,
		ChangedBy VARCHAR(20),
		ChangedDate DATETIME
	)
END