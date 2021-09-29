SELECT
	COST_CENTER_CD CostCenterCd,
    COST_CENTER_DESC CostCenterDesc,
	RESP_PERSON RespPerson,
	DIVISION_ID Division,
	[dbo].[fn_date_format] (VALID_DT_FROM) ValidDtFrom,
    [dbo].[fn_date_format] (VALID_DT_TO) ValidDtTo
FROM TB_M_COST_CENTER
WHERE COST_CENTER_CD = @CostCenterCode AND VALID_DT_FROM = @ValidFrom