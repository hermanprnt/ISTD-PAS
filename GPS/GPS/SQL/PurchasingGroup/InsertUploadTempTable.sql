INSERT INTO #tmpPurchasingGroup
VALUES
(
	@PurchasingGrpCode,
	@PurchasingGrpDesc,
	@ProcChannelCode,
	'System',
	GETDATE(),
	null,
	null
)