﻿BEGIN TRY
    BEGIN TRAN

	DELETE TB_R_QUOTA_CONSUME 
	WHERE DOC_NO = @DOC_NO and SEQ_NO = @SEQ_NO and CONFIRM_FLAG = @CONFIRM_FLAG

	UPDATE TB_R_QUOTA 
	SET UNCONFIRM_AMOUNT = UNCONFIRM_AMOUNT - @Amount,	   
		CHANGED_BY = @Userid,
		CHANGED_DT = GETDATE()
	WHERE CONSUME_MONTH = @DT_MONTH AND DIVISION_ID = @DIVISION_ID AND  QUOTA_TYPE = @DST_TYPE	
	
    COMMIT TRAN
	SELECT 'True|Cancel data successfully'	

END TRY
BEGIN CATCH   
	ROLLBACK TRAN
	SELECT 'Error|' + ERROR_MESSAGE();
END CATCH