INSERT INTO TB_M_EXCHANGE_RATE
	([CURR_CD]
    ,[EXCHANGE_RATE]
    ,[VALID_DT_FROM]
    ,[VALID_DT_TO]
    ,[FOREX_TYPE]
    ,[RELEASED_FLAG]
    ,[CREATED_BY]
    ,[CREATED_DT]
    ,[CHANGED_BY]
    ,[CHANGED_DT])
VALUES (
	@CURR_CD,
	@EXCHANGE_RATE,
	@VALID_DT_FROM,
	'9999-12-31',
	null,
	'1',
	@uid,
	GETDATE(),
	null,
	null
)