DECLARE @@EXIST INT

-- Check if user login is PR Creator
SELECT @@EXIST = COUNT(1) FROM TB_R_PR_H WHERE PR_NO = @PR_NO AND (CREATED_BY = @USER_ID OR CREATED_BY = @NOREG)
IF(@@EXIST = 0)
BEGIN
	SELECT 'User ID <b>' + @USER_ID + '</b> doesn''t have authorize to Cancel Document No : <b>' + @PR_NO + '</b>'
	RETURN
END

-- Check if document already cancelled
SELECT @@EXIST = COUNT(1) FROM TB_R_PR_H WHERE PR_NO = @PR_NO AND PR_STATUS = '95'
IF(@@EXIST > 0)
BEGIN
	SELECT 'Document No <b>' + @PR_NO + '</b> is already cancelled' 
	RETURN
END

--Check if PR already made into PO (checking by used_qty)
SELECT @@EXIST = COUNT(1) FROM TB_R_PR_ITEM WHERE PR_NO = @PR_NO AND ISNULL(USED_QTY, 0) <> 0
IF(@@EXIST > 0)
BEGIN
	SELECT 'Document No <b>' + @PR_NO + '</b> cannot be cancelled. There is item(s) that already created into Purchase Order.'
	RETURN
END

SELECT @@EXIST = COUNT(1) FROM TB_R_PR_H WHERE PR_NO = @PR_NO AND ISNULL(PROCESS_ID, '') <> ''
IF(@@EXIST > 0)
BEGIN
	SELECT @@EXIST = COUNT(1) FROM TB_T_LOCK A INNER JOIN TB_R_PR_H B ON A.PROCESS_ID = B.PROCESS_ID AND B.PR_NO = @PR_NO AND A.[USER_ID] = @USER_ID
	IF(@@EXIST = 0)
	BEGIN
		SELECT 'Document No <b>' + @PR_NO + '</b> is being used by another user'
		RETURN
	END
	ELSE
	BEGIN
		DELETE FROM TB_T_LOCK WHERE PROCESS_ID IN (SELECT PROCESS_ID FROM TB_R_PR_H WHERE PR_NO = @PR_NO) AND [USER_ID] = @USER_ID
		UPDATE TB_R_PR_H SET PROCESS_ID = NULL WHERE PR_NO = @PR_NO
	END
END

SELECT 'SUCCESS'
