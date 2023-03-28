SELECT COUNT(1) from
(SELECT DISTINCT *
	FROM TB_M_COST_CENTER mc
		WHERE ((mc.DIVISION_ID = @Division 
		  AND isnull(@Division, '') <> ''
		  OR (isnull(@Division, '') = '')))
		AND ((mc.COST_CENTER_CD LIKE '%' + @CostCenter + '%'
		  AND isnull(@CostCenter, '') <> ''
		  OR (isnull(@CostCenter, '') = '')))
)a