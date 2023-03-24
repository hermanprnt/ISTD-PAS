INSERT INTO TB_M_COORDINATOR
SELECT PurchasingGrpCode, PurchasingGrpDesc,
ProcChannelCode, 'PG', CreatedBy, CreatedDate,
ChangedBy, ChangedDate
FROM #tmpPurchasingGroup
;

IF OBJECT_ID('tempdb..#tmpPurchasingGroup') IS NOT NULL
BEGIN
	DROP TABLE #tmpPurchasingGroup
END