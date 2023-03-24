UPDATE TB_M_SOURCE_LIST
	SET VALID_DT_TO = B.ValidDateTo,
		CHANGED_BY = B.ChangedBy,
		CHANGED_DT = B.ChangedDate
FROM TB_M_SOURCE_LIST A 
JOIN #tmpUpdateSourceList B
	ON A.MAT_NO = B.MaterialNo AND A.VALID_DT_TO = '9999-12-31'	
	  
INSERT INTO TB_M_SOURCE_LIST
SELECT * FROM #tmpSourceList;

IF OBJECT_ID('tempdb..#tmpSourceList') IS NOT NULL
BEGIN
	DROP TABLE #tmpSourceList
END

IF OBJECT_ID('tempdb..#tmpUpdateSourceList') IS NOT NULL
BEGIN
	DROP TABLE #tmpUpdateSourceList
END