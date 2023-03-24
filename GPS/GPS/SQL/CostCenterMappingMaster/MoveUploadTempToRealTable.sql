INSERT INTO TB_M_COST_CENTER_GRP
SELECT * FROM #tmpCostCenterMapping
;

IF OBJECT_ID('tempdb..#tmpCostCenterMapping') IS NOT NULL
BEGIN
	DROP TABLE #tmpCostCenterMapping
END