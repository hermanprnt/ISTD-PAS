DECLARE @@SQLQUERY VARCHAR(MAX)

SET @@SQLQUERY = '
	SELECT COUNT(1)
	FROM TB_R_LOG_H A
	INNER JOIN TB_M_SYSTEM B
		ON B.SYSTEM_REMARK = ''Process Status Master''
				AND B.FUNCTION_ID = ''00000''
				AND A.PROCESS_STATUS = B.SYSTEM_CD
	INNER JOIN TB_M_FUNCTION C
		ON A.FUNCTION_ID = C.FUNCTION_ID
		AND ((A.PROCESS_ID LIKE ''%' + @ProcessId + '%''
				AND isnull(''' + @ProcessId + ''', '''') <> ''''
				OR (isnull(''' + @ProcessId + ''', '''') = '''')))
		AND ((A.FUNCTION_ID = ''' + @FunctionId + '''
			  AND isnull(''' + @FunctionId + ''', '''') <> ''''
			  OR (isnull(''' + @FunctionId + ''', '''') = '''')))
		AND ((A.PROCESS_STATUS = ''' + @Status + '''
			  AND isnull(''' + @Status + ''', '''') <> ''''
			  OR (isnull(''' + @Status + ''', '''') = '''')))
		AND ((A.CREATED_BY = ''' + @User + '''
			  AND isnull(''' + @User + ''', '''') <> ''''
			  OR (isnull(''' + @User + ''', '''') = '''')))
		'
IF(@ProcDateFrom <> '')
BEGIN
	IF(@ProcDateTo <> '')
	BEGIN
		SET @@SQLQUERY = @@SQLQUERY + 'AND A.START_DT  >= ''' + @ProcDateFrom + ' 00:00:00'' AND A.END_DT <= ''' + @ProcDateTo + ' 23:59:59'''
	END
	ELSE
	BEGIN
		SET @@SQLQUERY = @@SQLQUERY + 'AND A.START_DT >= ''' + @ProcDateFrom + ' 00:00:00'''
	END
END
ELSE
BEGIN
	IF(@ProcDateTo <> '')
	BEGIN
		SET @@SQLQUERY = @@SQLQUERY + 'AND A.END_DT <= ''' + @ProcDateTo + ' 23:59:59'''
	END
END

exec (@@SQLQUERY)