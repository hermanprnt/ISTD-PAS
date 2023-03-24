UPDATE TB_M_EXCHANGE_RATE
	SET VALID_DT_TO = '9999-12-31', CHANGED_BY= @USER_ID, CHANGED_DT= GETDATE()
WHERE CURR_CD = @CURR_CD AND VALID_DT_TO = DATEADD(day, -1, @VALID_DT_FROM)

DELETE FROM TB_M_EXCHANGE_RATE
WHERE CURR_CD = @CURR_CD AND VALID_DT_FROM = @VALID_DT_FROM

SELECT @@@ROWCOUNT