﻿DECLARE @@STATUS VARCHAR(10),
		@@MSG VARCHAR(MAX) = ''

BEGIN TRANSACTION 
BEGIN TRY
	INSERT INTO TB_H_WORKFLOW 
		(
		   [DOCUMENT_NO]
		  ,[ITEM_NO]
		  ,[DOCUMENT_SEQ]
		  ,[APPROVAL_CD]
		  ,[APPROVAL_DESC]
		  ,[APPROVED_BY]
		  ,[NOREG]
		  ,[APPROVED_BYPASS]
		  ,[APPROVED_DT]
		  ,[STRUCTURE_ID]
		  ,[STRUCTURE_NAME]
		  ,[APPROVER_POSITION]
		  ,[IS_APPROVED]
		  ,[IS_REJECTED]
		  ,[IS_DISPLAY]
		  ,[LIMIT_FLAG]
		  ,[MAX_AMOUNT]
		  ,[IS_CANCELLED]
		  ,[APPROVER_NAME]
		  ,[APPROVAL_INTERVAL]
		  ,[INTERVAL_DATE]
		  ,[RELEASE_FLAG]
		  ,[CREATED_BY]
		  ,[CREATED_DT]
		  ,[CHANGED_BY]
		  ,[CHANGED_DT]
		)
	SELECT
	   [DOCUMENT_NO]
      ,[ITEM_NO]
      ,[DOCUMENT_SEQ]
      ,[APPROVAL_CD]
      ,[APPROVAL_DESC]
      ,[APPROVED_BY]
      ,[NOREG]
      ,[APPROVED_BYPASS]
      ,[APPROVED_DT]
      ,[STRUCTURE_ID]
      ,[STRUCTURE_NAME]
      ,[APPROVER_POSITION]
      ,[IS_APPROVED]
      ,[IS_REJECTED]
      ,[IS_DISPLAY]
      ,[LIMIT_FLAG]
      ,[MAX_AMOUNT]
      ,[IS_CANCELLED]
      ,[APPROVER_NAME]
      ,[APPROVAL_INTERVAL]
      ,[INTERVAL_DATE]
      ,[RELEASE_FLAG]
      ,[CREATED_BY]
      ,[CREATED_DT]
      ,[CHANGED_BY]
      ,[CHANGED_DT]
	FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @PR_NO
	
	UPDATE TB_R_PR_H SET PR_STATUS = '95', PROCESS_ID = NULL, CANCEL_FLAG = 'Y', 
						 CANCEL_BY = @USER_ID, CANCEL_DT = GETDATE(), CANCEL_REASON = @CANCEL_REASON WHERE PR_NO = @PR_NO 
	UPDATE TB_R_PR_ITEM SET PR_STATUS = '98', PR_NEXT_STATUS = '98', IS_REJECTED = 'N' WHERE PR_NO = @PR_NO

	DELETE FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @PR_NO
	DELETE FROM TB_T_LOCK WHERE PROCESS_ID = @PROCESS_ID
	COMMIT TRANSACTION

	SET @@STATUS = 'SUCCESS'
END TRY
BEGIN CATCH
	SELECT @@MSG = ERROR_MESSAGE()
	SET @@STATUS = 'ERROR'
	ROLLBACK TRANSACTION
END CATCH

SELECT @@STATUS AS PROCESS_STATUS, @@MSG AS MESSAGE