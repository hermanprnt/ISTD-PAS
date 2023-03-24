INSERT INTO #tmpCostCenterMapping
VALUES
(
	@CostCenterGroupCode,
    @CostCenterGroupDesc,
    @DivisionCode,
	'System',
	GETDATE(),
	null,
	null
)