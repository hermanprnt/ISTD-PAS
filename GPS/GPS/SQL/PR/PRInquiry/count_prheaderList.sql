/*** Count Retrieved Data based on search criteria		***/
/** Created By      : Reggy Budiana						**/
/** Created Date    : 03/02/2015						**/
/** Changed By      : -									**/
/** Changed Date    : -									**/
/*  Used In         : + PRCreationRepository/CountData  */

DECLARE @@SQL_QUERY VARCHAR(MAX),
		@@LIMIT VARCHAR(MAX)

SELECT @@LIMIT = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH'

SET @@SQL_QUERY = 

'SELECT TOP ' + @@LIMIT + '
	ISNULL(COUNT(DISTINCT A.PR_NO),0)
	FROM TB_R_PR_H A 
		JOIN TB_M_STATUS B ON B.STATUS_CD = A.PR_STATUS
		JOIN TB_R_PR_ITEM C ON C.PR_NO = A.PR_NO
		JOIN TB_M_PROCUREMENT_TYPE E ON A.PR_TYPE = E.PROCUREMENT_TYPE
		JOIN TB_M_COORDINATOR F ON A.PR_COORDINATOR = F.COORDINATOR_CD
		LEFT JOIN TB_M_VENDOR G ON G.VENDOR_CD = C.VENDOR_CD
		LEFT JOIN TB_T_LOCK D ON A.PROCESS_ID = D.PROCESS_ID
		LEFT JOIN TB_M_VALUATION_CLASS VC ON VC.VALUATION_CLASS = C.VALUATION_CLASS
WHERE
	((A.PR_NO LIKE ''%' + ISNULL(@PR_NO,'') + '%'' 
	AND isnull(''' + ISNULL(@PR_NO,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@PR_NO,'') + ''', '''') = '''')))
AND ((A.PR_TYPE = ''' + ISNULL(@PR_TYPE,'') + '''
	AND isnull(''' + ISNULL(@PR_TYPE,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@PR_TYPE,'') + ''', '''') = '''')))
AND ((A.PLANT_CD = ''' + ISNULL(@PLANT_CD,'') + '''
	AND isnull(''' + ISNULL(@PLANT_CD,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@PLANT_CD,'') + ''', '''') = '''')))
AND ((A.SLOC_CD = ''' + ISNULL(@SLOC_CD,'') + '''
	AND isnull(''' + ISNULL(@SLOC_CD,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@SLOC_CD,'') + ''', '''') = '''')))
AND ((A.DIVISION_ID = ''' + ISNULL(@DIVISION_CD,'') + '''
	AND isnull(''' + ISNULL(@DIVISION_CD,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@DIVISION_CD,'') + ''', '''') = '''')))
AND ((A.PROJECT_NO LIKE ''%' + ISNULL(@PROJECT_NO,'') + '%''
	AND isnull(''' + ISNULL(@PROJECT_NO,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@PROJECT_NO,'') + ''', '''') = '''')))
AND ((A.DOC_DT >= ''' + ISNULL(@DATEFROM,'') + '''
	AND isnull(''' + ISNULL(@DATEFROM,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@DATEFROM,'') + ''', '''') = '''')))
AND ((A.DOC_DT <= ''' + ISNULL(@DATETO,'') + '''
	AND isnull(''' + ISNULL(@DATETO,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@DATETO,'') + ''', '''') = '''')))
AND (((C.VENDOR_CD LIKE ''%' + ISNULL(@VENDOR_CD,'') + '%''
	AND isnull(''' + ISNULL(@VENDOR_CD,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@VENDOR_CD,'') + ''', '''') = '''')))
	OR ((G.VENDOR_NAME LIKE ''%' + ISNULL(@VENDOR_CD,'') + '%''
	AND isnull(''' + ISNULL(@VENDOR_CD,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@VENDOR_CD,'') + ''', '''') = ''''))))
AND ((A.PR_DESC LIKE ''%' + ISNULL(@PR_DESC,'')  + '%''
	AND isnull(''' + ISNULL(@PR_DESC,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@PR_DESC,'') + ''', '''') = '''')))
AND ((A.PR_COORDINATOR = ''' + ISNULL(@PR_COORDINATOR,'') + '''
	AND isnull(''' + ISNULL(@PR_COORDINATOR,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@PR_COORDINATOR,'') + ''', '''') = '''')))
AND ((C.WBS_NO LIKE ''%' + ISNULL(@WBS_NO,'') + '%''
	AND isnull(''' + ISNULL(@WBS_NO,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@WBS_NO,'') + ''', '''') = '''')))
AND ((C.PR_STATUS = ''' + ISNULL(@DETAIL_STS, '') + '''
	AND isnull(''' + ISNULL(@DETAIL_STS, '') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@DETAIL_STS, '') + ''', '''') = '''')))
AND ((A.CREATED_BY LIKE ''%' + ISNULL(@CREATED_BY, '') + '%''
	AND isnull(''' + ISNULL(@CREATED_BY, '') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@CREATED_BY, '') + ''', '''') = '''')))
AND ((C.PO_NO LIKE ''%' + ISNULL(@PO_NO,'') + '%'' 
	AND isnull(''' + ISNULL(@PO_NO,'') + ''', '''') <> ''''
	OR (isnull(''' + ISNULL(@PO_NO,'') + ''', '''') = '''')))'

IF(@PROCUREMENT_CHANNEL IS NOT NULL) 
  BEGIN
     SET @@SQL_QUERY = @@SQL_QUERY + ' AND VC.PROC_CHANNEL_CD = ''' + ISNULL(@PROCUREMENT_CHANNEL,'')  +''''
  END

IF(@PR_STATUS_FLAG = '92')
  BEGIN
	  IF(@PR_STATUS_DESC = '92 - Open')
		BEGIN 
		 SET @@SQL_QUERY = @@SQL_QUERY + ' AND A.PR_STATUS = ''' + ISNULL(@PR_STATUS_FLAG,'') + ''' 
										 AND  C.PO_NO = '''''
		END
	 ELSE 
		BEGIN
			 SET @@SQL_QUERY = @@SQL_QUERY + ' AND A.PR_STATUS = ''' + ISNULL(@PR_STATUS_FLAG,'') + ''' 
										 AND  C.PO_NO != '''''
		END    
  END 
ELSE
	BEGIN
	SET	@@SQL_QUERY = @@SQL_QUERY + ' AND ((A.PR_STATUS = ''' + ISNULL(@PR_STATUS_FLAG, '') + '''
							        AND isnull(''' + ISNULL(@PR_STATUS_FLAG, '') + ''', '''') <> ''''
				                        OR (isnull(''' + ISNULL(@PR_STATUS_FLAG, '') + ''', '''') = ''''))) '

	END

--prchecker
EXEC (@@SQL_QUERY)