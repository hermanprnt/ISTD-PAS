DECLARE @@COST_CENTER_GRP_CD VARCHAR(50),
		@@DIVISION_CD VARCHAR(10),
		@@COST_CENTER_GRP_DESC VARCHAR(100),
		@@ROW VARCHAR(5), 
		@@ERROR_FLAG CHAR(1),
		@@DUPLICATE INT,
		@@MESSAGE VARCHAR(MAX) = '',
		@@ROW_ERROR VARCHAR(MAX)

exec [dbo].[sp_PutLog] 'Data Validating Process Started', @uid, @MessageLoc, @ProcessId, '', 'INF', '', null, 0

DECLARE db_cursor CURSOR FOR 
    SELECT COST_CENTER_GRP_CD, DIVISION_CD, COST_CENTER_GRP_DESC, [ROW], ERROR_FLAG 
		FROM TB_T_COST_CENTER_GRP
			WHERE PROCESS_ID = @ProcessId   

    OPEN db_cursor 
    FETCH NEXT FROM db_cursor INTO @@COST_CENTER_GRP_CD, @@DIVISION_CD, @@COST_CENTER_GRP_DESC, @@ROW, @@ERROR_FLAG

    WHILE @@@FETCH_STATUS = 0 
    BEGIN
		
		IF(@@ERROR_FLAG = 'N')
		BEGIN
			--Duplication Checking : Compare data between TB_T_COST_CENTER_GRP and TB_M_COST_CENTER_GRP
			SELECT @@DUPLICATE = COUNT(1) FROM TB_M_COST_CENTER_GRP WHERE COST_CENTER_GRP_CD = @@COST_CENTER_GRP_CD AND DIVISION_CD = @@DIVISION_CD
			IF(@@DUPLICATE > 0)
			BEGIN
				SET @@MESSAGE = 'Data Already Exist in Master Table for Cost Center Group Code : ' + @@COST_CENTER_GRP_CD + ' and Division Code : ' + @@DIVISION_CD + '. At Row ' + @@ROW
				exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 0
				UPDATE TB_T_COST_CENTER_GRP SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				SET @@ERROR_FLAG = 'Y'
			END

			--Duplication Checking : Compare new data that uploaded
			SELECT @@DUPLICATE = COUNT(1) FROM TB_T_COST_CENTER_GRP WHERE COST_CENTER_GRP_CD = @@COST_CENTER_GRP_CD AND DIVISION_CD = @@DIVISION_CD AND PROCESS_ID = @ProcessId
			IF(@@DUPLICATE > 1 AND @@ERROR_FLAG = 'N')
			BEGIN
				SELECT @@ROW_ERROR = COALESCE(@@ROW_ERROR+', ' ,'') + [ROW] FROM TB_T_COST_CENTER_GRP WHERE COST_CENTER_GRP_CD = @@COST_CENTER_GRP_CD AND DIVISION_CD = @@DIVISION_CD AND PROCESS_ID = @ProcessId
				SET @@MESSAGE = 'There are Duplicate Data for Cost Center Group Code : ' + @@COST_CENTER_GRP_CD + ' and Division Code : ' + @@DIVISION_CD + '. At Row ' + @@ROW_ERROR
				exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 0
				--Get Row That Duplicate and Upload Error Flag = 'Y'
				SET @@ROW_ERROR = '''' + REPLACE(@@ROW_ERROR, ', ', ''', ''' ) + ''''
				EXEC('UPDATE TB_T_COST_CENTER_GRP SET ERROR_FLAG = ''Y'' WHERE PROCESS_ID = ' + @ProcessId  +'AND [ROW] IN (' +@@ROW_ERROR + ')')
				SET @@ERROR_FLAG = 'Y'
			END

			IF(@@ERROR_FLAG = 'N')
			BEGIN
				--Nullable Checking
				IF(@@COST_CENTER_GRP_CD IS NULL OR @@COST_CENTER_GRP_CD = '')
				BEGIN
					SET @@MESSAGE = 'Cost Center Group Code Should Not Be Null. At Row ' + @@ROW
					exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 0
					UPDATE TB_T_COST_CENTER_GRP SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				END
				IF(@@DIVISION_CD IS NULL OR @@DIVISION_CD = '')
				BEGIN
					SET @@MESSAGE = 'Division Code Should Not Be Null. At Row ' + @@ROW
					exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 0
					UPDATE TB_T_COST_CENTER_GRP SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				END

				--Length Checking
				IF(LEN(@@COST_CENTER_GRP_CD) > 8)
				BEGIN
					SET @@MESSAGE = 'Cost Center Group Code Should Not Be More Than 8 Character. At Row ' + @@ROW
					exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 0
					UPDATE TB_T_COST_CENTER_GRP SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				END
				IF(LEN(@@COST_CENTER_GRP_DESC) > 50)
				BEGIN
					SET @@MESSAGE = 'Cost Center Group Description Should Not Be More Than 50 Character. At Row ' + @@ROW
					exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 0
					UPDATE TB_T_COST_CENTER_GRP SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				END

				--Type Data Checking
				BEGIN TRY
					DECLARE @@TRY INT
					SELECT @@TRY = CONVERT(INT, @@DIVISION_CD)
				END TRY
				BEGIN CATCH
					SET @@MESSAGE = 'Division Should Be Numeric. At Row ' + @@ROW
					exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 0
					UPDATE TB_T_COST_CENTER_GRP SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				END CATCH

				--TO DO : Division Code Checking
			END
		END

		FETCH NEXT FROM db_cursor INTO @@COST_CENTER_GRP_CD, @@DIVISION_CD, @@COST_CENTER_GRP_DESC, @@ROW, @@ERROR_FLAG
    END 
    CLOSE db_cursor 
DEALLOCATE db_cursor

exec [dbo].[sp_PutLog] 'Data Validating Process Finished', @uid, @MessageLoc, @ProcessId, '', 'INF', '', null, 0