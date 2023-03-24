SELECT COST_CENTER_GRP_CD AS CostCenterGroupCd,
		COST_CENTER_GRP_DESC AS CostCenterGroupDesc,
		DIVISION_CD AS DivisionCd,
		CREATED_BY AS CreatedBy,
		CREATED_DT AS CreatedDt,
		CHANGED_BY AS ChangedBy,
		CHANGED_DT AS ChangedDt
FROM TB_M_COST_CENTER_GRP
	WHERE ((COST_CENTER_GRP_CD = @CostGroup
			AND isnull(@CostGroup, '') <> ''
			OR (isnull(@CostGroup, '') = '')))
	AND ((DIVISION_CD = @DivisionCd
			AND isnull(@DivisionCd, '') <> ''
			OR (isnull(@DivisionCd, '') = '')))