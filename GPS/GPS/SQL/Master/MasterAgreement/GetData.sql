SELECT * FROM (
	SELECT DISTINCT
		   DENSE_RANK() OVER (ORDER BY mc.COST_CENTER_CD ASC, mc.RESP_PERSON ASC, mc.DIVISION_ID ASC, mc.VALID_DT_FROM, mc.VALID_DT_TO, mc.CREATED_DT DESC) AS Number,
		   mc.COST_CENTER_CD AS CostCenterCd,
		   mc.COST_CENTER_DESC AS CostCenterDesc,
		   mc.RESP_PERSON AS RespPerson,
		   CAST(mc.DIVISION_ID AS VARCHAR) + CASE WHEN(ISNULL(se.DIVISION_NAME, '') = '') THEN '' ELSE ' - ' + se.DIVISION_NAME END AS Division,
		   [dbo].[fn_date_format] (mc.VALID_DT_FROM) AS ValidDtFrom,
		   [dbo].[fn_date_format] (mc.VALID_DT_TO) AS ValidDtTo,
		   mc.CREATED_BY AS CreatedBy,
		   [dbo].[fn_date_format] (mc.CREATED_DT) AS CreatedDt,
		   mc.CHANGED_BY AS ChangedBy,
		   [dbo].[fn_date_format] (mc.CHANGED_DT) AS ChangedDt
	FROM TB_M_COST_CENTER mc
	LEFT JOIN TB_R_SYNCH_EMPLOYEE se ON mc.DIVISION_ID = se.DIVISION_ID
		WHERE ((mc.DIVISION_ID = @Division 
		  AND isnull(@Division, '') <> ''
		  OR (isnull(@Division, '') = '')))
		AND ((mc.COST_CENTER_CD LIKE '%' + @CostCenter + '%'
		  AND isnull(@CostCenter, '') <> ''
		  OR (isnull(@CostCenter, '') = '')))
) tbl WHERE tbl.Number >= @Start AND tbl.Number <= @Length