SELECT 
	COST_CENTER_GRP_CD AS COST_CENTER_GRP_CD,
	COST_CENTER_GRP_DESC AS COST_CENTER_GRP_DESC,
	DIVISION_CD AS DIVISION_CD

FROM TB_M_COST_CENTER_GRP
WHERE COST_CENTER_GRP_CD = @COST_CENTER_GRP_CD AND DIVISION_CD = @DIVISION_CD