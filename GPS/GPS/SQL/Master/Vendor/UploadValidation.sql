DECLARE @@VENDOR_CD VARCHAR(50),
		@@VENDOR_NAME VARCHAR(50),
		@@VENDOR_PLANT VARCHAR(50),
		@@PURCH_GROUP VARCHAR(50),
		@@SAP_VENDOR_ID VARCHAR(50),
		@@PAYMENT_METHOD_CD VARCHAR(50),
		@@PAYMENT_TERM_CD VARCHAR(50),
		@@ADDRESS VARCHAR(100),
		@@PHONE VARCHAR(50),
		@@FAX VARCHAR(50),
		@@CITY VARCHAR(50),
		@@POSTAL VARCHAR(50),
		@@COUNTRY VARCHAR(50),
		@@ATTENTION VARCHAR(50),
		@@ROW VARCHAR(5), 
		@@ERROR_FLAG CHAR(1),
		@@DUPLICATE INT,
		@@MESSAGE VARCHAR(MAX) = '',
		@@ROW_ERROR VARCHAR(MAX)

exec [dbo].[sp_PutLog] 'Data Validating Process Started', @uid, @MessageLoc, @ProcessId, '', 'INF', '', null, 0

DECLARE db_cursor CURSOR FOR 
    SELECT VENDOR_CD, VENDOR_NAME, VENDOR_PLANT, SAP_VENDOR_ID, PURCHASING_GRP_CD, PAYMENT_METHOD_CD, PAYMENT_TERM_CD, 
		   VENDOR_ADDRESS, PHONE, CITY, ATTENTION, COUNTRY, [ROW], ERROR_FLAG 
		FROM TB_T_VENDOR
			WHERE PROCESS_ID = @ProcessId   

    OPEN db_cursor 
    FETCH NEXT FROM db_cursor INTO @@VENDOR_CD, @@VENDOR_NAME, @@VENDOR_PLANT, @@SAP_VENDOR_ID, @@PURCH_GROUP, @@PAYMENT_METHOD_CD, 
		@@PAYMENT_TERM_CD, @@ADDRESS, @@PHONE, @@CITY, @@ATTENTION, @@COUNTRY, @@ROW, @@ERROR_FLAG

    WHILE @@@FETCH_STATUS = 0 
    BEGIN
		IF(@@ERROR_FLAG = 'Y')
		BEGIN
			SET @@MESSAGE = 'Incorrect email address. At Row ' + @@ROW
			exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 3
		END

		IF(@@ERROR_FLAG = 'N')
		BEGIN
			--Duplication Checking : Compare data between TB_T_VENDOR and TB_M_VENDOR
			SELECT @@DUPLICATE = COUNT(1) FROM TB_M_VENDOR WHERE VENDOR_CD = @@VENDOR_CD
			IF(@@DUPLICATE > 0)
			BEGIN
				SET @@MESSAGE = 'Data Already Exist in Master Table for Vendor Code : ' + @@VENDOR_CD + '. At Row ' + @@ROW
				exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 3
				UPDATE TB_T_VENDOR SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				SET @@ERROR_FLAG = 'Y'
			END

			--Duplication Checking : Compare new data that uploaded
			SELECT @@DUPLICATE = COUNT(1) FROM TB_T_VENDOR WHERE VENDOR_CD = @@VENDOR_CD AND PROCESS_ID = @ProcessId
			IF(@@DUPLICATE > 1 AND @@ERROR_FLAG = 'N')
			BEGIN
				SELECT @@ROW_ERROR = COALESCE(@@ROW_ERROR+', ' ,'') + [ROW] FROM TB_T_VENDOR WHERE VENDOR_CD = @@VENDOR_CD AND PROCESS_ID = @ProcessId
				SET @@MESSAGE = 'There are Duplicate Data for Vendor Code : ' + @@VENDOR_CD + '. At Row ' + @@ROW_ERROR
				exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 1
				--Get Row That Duplicate and Upload Error Flag = 'Y'
				SET @@ROW_ERROR = '''' + REPLACE(@@ROW_ERROR, ', ', ''', ''' ) + ''''
				EXEC('UPDATE TB_T_VENDOR SET ERROR_FLAG = ''Y'' WHERE PROCESS_ID = ' + @ProcessId  +'AND [ROW] IN (' +@@ROW_ERROR + ')')
				SET @@ERROR_FLAG = 'Y'
			END

			IF(@@ERROR_FLAG = 'N')
			BEGIN
				--Nullable Checking
				IF(ISNULL(@@VENDOR_CD, '') = '')
				BEGIN
					SET @@MESSAGE = 'Vendor Code Should Not Be Null. At Row ' + @@ROW
					exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 3
					UPDATE TB_T_VENDOR SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				END
				IF(ISNULL(@@VENDOR_NAME, '') = '')
				BEGIN
					SET @@MESSAGE = 'Vendor Name Should Not Be Null. At Row ' + @@ROW
					exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 3
					UPDATE TB_T_VENDOR SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				END
				IF(ISNULL(@@PURCH_GROUP, '') = '')
				BEGIN
					SET @@MESSAGE = 'Purchasing Group Should Not Be Null. At Row ' + @@ROW
					exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 3
					UPDATE TB_T_VENDOR SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				END
				IF(ISNULL(@@PAYMENT_METHOD_CD, '') = '')
				BEGIN
					SET @@MESSAGE = 'Payment Method Code Should Not Be Null. At Row ' + @@ROW
					exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 3
					UPDATE TB_T_VENDOR SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				END
				IF(ISNULL(@@PAYMENT_TERM_CD, '') = '')
				BEGIN
					SET @@MESSAGE = 'Payment Term Code Should Not Be Null. At Row ' + @@ROW
					exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 3
					UPDATE TB_T_VENDOR SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				END
				IF(ISNULL(@@COUNTRY, '') = '')
				BEGIN
					SET @@MESSAGE = 'Country Should Not Be Null. At Row ' + @@ROW
					exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 3
					UPDATE TB_T_VENDOR SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				END
			END

			IF(@@ERROR_FLAG = 'N')
			BEGIN
				--Length Checking
				IF(LEN(@@VENDOR_CD) > 6)
				BEGIN
					SET @@MESSAGE = 'Vendor Code Should Not Be More Than 6 Character. At Row ' + @@ROW
					exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 3
					UPDATE TB_T_VENDOR SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				END
				IF(LEN(@@VENDOR_NAME) > 50)
				BEGIN
					SET @@MESSAGE = 'Vendor Name Should Not Be More Than 50 Character. At Row ' + @@ROW
					exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 3
					UPDATE TB_T_VENDOR SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				END
				IF(LEN(@@VENDOR_PLANT) > 4)
				BEGIN
					SET @@MESSAGE = 'Vendor Plant Should Not Be More Than 4 Character. At Row ' + @@ROW
					exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 3
					UPDATE TB_T_VENDOR SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				END
				IF(LEN(@@SAP_VENDOR_ID) > 10)
				BEGIN
					SET @@MESSAGE = 'SAP Vendor ID Should Not Be More Than 10 Character. At Row ' + @@ROW
					exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 3
					UPDATE TB_T_VENDOR SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				END
				IF(LEN(@@PAYMENT_METHOD_CD) > 1)
				BEGIN
					SET @@MESSAGE = 'Payment Method Code Should Not Be More Than 1 Character. At Row ' + @@ROW
					exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 3
					UPDATE TB_T_VENDOR SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				END
				IF(LEN(@@PAYMENT_TERM_CD) > 4)
				BEGIN
					SET @@MESSAGE = 'Payment Term Code Should Not Be More Than 4 Character. At Row ' + @@ROW
					exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 3
					UPDATE TB_T_VENDOR SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				END
			END

			IF(@@ERROR_FLAG = 'N')
			BEGIN
				--Master Data Checking
				IF NOT EXISTS(SELECT 1 FROM TB_M_PAY_METHOD WHERE PAY_METHOD_CD = @@PAYMENT_METHOD_CD)
				BEGIN
					SET @@MESSAGE = 'Payment Method Code is not regitered yet in TB_M_PAY_METHOD. At Row ' + @@ROW
					exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 3
					UPDATE TB_T_VENDOR SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				END

				IF NOT EXISTS(SELECT 1 FROM TB_M_TERM_OF_PAYMENT WHERE PAY_TERM_CD = @@PAYMENT_TERM_CD)
				BEGIN
					SET @@MESSAGE = 'Payment Term Code is not regitered yet in TB_M_TERM_OF_PAYMENT. At Row ' + @@ROW
					exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 3
					UPDATE TB_T_VENDOR SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				END

				IF NOT EXISTS(SELECT 1 FROM TB_M_COUNTRY WHERE COUNTRY_ID = @@COUNTRY)
				BEGIN
					SET @@MESSAGE = 'Country is not regitered yet in TB_M_COUNTRY. At Row ' + @@ROW
					exec [dbo].[sp_PutLog] @@MESSAGE, @uid, @MessageLoc, @ProcessId, '', 'ERR', '', null, 3
					UPDATE TB_T_VENDOR SET ERROR_FLAG = 'Y' WHERE PROCESS_ID = @ProcessId AND [ROW] = @@ROW
				END
			END
		END

		FETCH NEXT FROM db_cursor INTO @@VENDOR_CD, @@VENDOR_NAME, @@VENDOR_PLANT, @@SAP_VENDOR_ID, @@PURCH_GROUP, @@PAYMENT_METHOD_CD, 
		@@PAYMENT_TERM_CD, @@ADDRESS, @@PHONE, @@CITY, @@ATTENTION, @@COUNTRY, @@ROW, @@ERROR_FLAG
    END 
    CLOSE db_cursor 
DEALLOCATE db_cursor

exec [dbo].[sp_PutLog] 'Data Validating Process Finished', @uid, @MessageLoc, @ProcessId, '', 'INF', '', null, 1