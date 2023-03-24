INSERT INTO #tmpCostCenter
VALUES
(
	@CostCenterCode,
	@CostCenterDesc,
	@CostCenterGrpCode,
    @ValidDateFrom,
	@ValidDateTo,
	'System',
	GETDATE(),
	null,
	null
)