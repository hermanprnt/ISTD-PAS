UPDATE TB_M_EXCHANGE_RATE
SET
 CURR_CD = @CURR_CD,
 VALID_DT_TO = DATEADD(day, -1, @VALID_DT_FROM),
 FOREX_TYPE = NULL,
 RELEASED_FLAG = 0,
 CHANGED_BY = @uid,
 CHANGED_DT = GETDATE() 
 WHERE CURR_CD = @CURR_CD AND VALID_DT_TO = '9999-12-31'