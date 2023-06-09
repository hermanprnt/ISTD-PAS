﻿DECLARE @@COUNT INT,
		@@PR_STATUS VARCHAR(5),
		@@PR_NEXT_STATUS VARCHAR(5),
		@@APPROVAL_CD VARCHAR(10),
		@@NEW_FLAG VARCHAR(2),
		@@PO_NO VARCHAR(20)

SELECT @@COUNT = COUNT(*) 
FROM TB_R_WORKFLOW 
WHERE DOCUMENT_NO = @PR_NO 
      AND ITEM_NO = @PR_ITEM_NO 
	  AND STRUCTURE_ID = @ORG_ID 
	  AND APPROVER_POSITION = @POSITION_LEVEL
IF(@@COUNT <= 0)
BEGIN
	SELECT @@NEW_FLAG = NEW_FLAG FROM TB_T_PR_ITEM WHERE PROCESS_ID = @PROCESS_ID AND ITEM_NO = @PR_ITEM_NO 
	IF(@@NEW_FLAG IS NULL)
	BEGIN
		SELECT 'Error : User Is Not Listed in Workflow for PR_ITEM_NO : ' + CONVERT(VARCHAR,@PR_ITEM_NO) + ' and PR_NO : ' + @PR_NO
		RETURN
	END
END

SELECT TOP 1 @@APPROVAL_CD = APPROVAL_CD 
FROM TB_R_WORKFLOW 
WHERE DOCUMENT_NO = @PR_NO 
      AND ITEM_NO = @PR_ITEM_NO 
	  AND STRUCTURE_ID = @ORG_ID 
	  AND APPROVER_POSITION = @POSITION_LEVEL

SELECT @@PR_NEXT_STATUS = PR_NEXT_STATUS FROM TB_R_PR_ITEM WHERE PR_NO = @PR_NO AND PR_ITEM_NO = @PR_ITEM_NO

IF((@@APPROVAL_CD <> '10') AND (@@APPROVAL_CD <> @@PR_NEXT_STATUS))
BEGIN
	SELECT 'Only Next Approver and PR Creator Can Edit this Item'
	RETURN
END

SELECT @@PR_STATUS = PR_STATUS FROM TB_R_PR_ITEM WHERE PR_NO = @PR_NO AND PR_ITEM_NO = @PR_ITEM_NO 
IF(CONVERT(INT,@@PR_STATUS) >= 30)
BEGIN
	SELECT 'Error : PR_ITEM_NO : ' + CONVERT(VARCHAR,@PR_ITEM_NO) + ' and PR_NO : ' + @PR_NO + ' Already Complete, Cannot Edited'
	RETURN
END

SELECT @@PO_NO = PO_NO FROM TB_R_PR_ITEM WHERE PR_NO = @PR_NO AND PR_ITEM_NO = @PR_ITEM_NO
IF((@@PO_NO <> ''))
BEGIN
	SELECT 'Error : All item has been Released, Cannot Edit this Item'
	RETURN
END

SELECT ''