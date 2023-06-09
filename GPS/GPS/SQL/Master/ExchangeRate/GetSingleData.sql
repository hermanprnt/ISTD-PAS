SELECT 
	CURR_CD AS CURR_CD,
	EXCHANGE_RATE AS EXCHANGE_RATE,
	dbo.fn_date_format(VALID_DT_FROM) AS VALID_DT_FROM,
	dbo.fn_date_format(VALID_DT_TO) AS VALID_DT_TO
FROM TB_M_EXCHANGE_RATE 
WHERE CURR_CD = @CURR_CD AND RELEASED_FLAG = @RELEASED_FLAG
