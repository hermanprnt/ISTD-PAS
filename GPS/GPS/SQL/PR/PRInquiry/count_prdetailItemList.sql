SELECT COUNT(1)
FROM TB_R_PR_ITEM A 
	JOIN TB_M_STATUS B ON B.STATUS_CD = A.PR_STATUS
	JOIN TB_M_SYSTEM C ON C.FUNCTION_ID = '20021' AND ASSET_CATEGORY = SUBSTRING(C.SYSTEM_CD, 4, 5)
	LEFT JOIN TB_R_WORKFLOW D ON A.PR_NO = D.DOCUMENT_NO AND A.PR_ITEM_NO = D.ITEM_NO
		 AND A.PR_NEXT_STATUS = D.APPROVAL_CD AND A.RELEASE_FLAG = 'N'
WHERE PR_NO = @PR_NO