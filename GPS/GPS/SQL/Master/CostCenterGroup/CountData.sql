SELECT COUNT(*)
FROM TB_M_COST_CENTER_GRP
	WHERE ((COST_CENTER_GRP_CD = @CostGrpCd
			AND isnull(@CostGrpCd, '') <> ''
			OR (isnull(@CostGrpCd, '') = '')))
	AND ((DIVISION_CD = @DivisionCd
		  AND isnull(@DivisionCd, '') <> ''
		  OR (isnull(@DivisionCd, '') = '')))