/****** Object:  StoredProcedure [dbo].[sp_Job_ECatalogue_AutoPOCreation]    Script Date: 11/23/2017 2:38:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_Job_ECatalogue_AutoPOCreation] 
	@Feedback VARCHAR(500) OUTPUT,
	@UserId VARCHAR(30) = '',
	@RegNo VARCHAR(30) = ''	   
AS
BEGIN
    DECLARE
		@MSG VARCHAR(MAX),
		@MODULE VARCHAR(4) = '6',
		@FUNCTION VARCHAR(6) = '601004',
		@LOCATION VARCHAR(512) = 'sp_Job_ECatalogue_AutoPOCreation',
		@USER_ID VARCHAR(30) = 'BackgroundPOCatalog',
		@MSG_ID VARCHAR(12),
		@PROCESS_ID bigint,
		@RELATED_PROCESS_ID bigint,
		@PROCUREMENT_TYPE VARCHAR(2) = 'RM',
        @tmpLog LOG_TEMP,
		@tmpLogRelated LOG_TEMP,
		@str_related_err_key varchar(20) = '##ERROR_RELATED_PROCESS##'

	IF(ISNULL(@UserId,'')<>'')
		SET @USER_ID = @UserId

	DECLARE @PR_NO VARCHAR(50),
			@VENDOR_CD VARCHAR(6),
			@VENDOR_NAME VARCHAR(50),
			@DELIVERY_ADDR VARCHAR(150),
			@CURRENCY VARCHAR(5),
			@PURCHASING_GROUP VARCHAR(3),
			@PROC_CHANNEL VARCHAR(4),
			@PO_DESC VARCHAR(100),
			@PR_NOTES_1 VARCHAR(1000),
			@PR_NOTES_2 VARCHAR(1000),
			@PR_NOTES_3 VARCHAR(1000),
			@PR_NOTES_4 VARCHAR(1000),
			@PR_NOTES_5 VARCHAR(1000),
			@PR_NOTES_6 VARCHAR(1000),
			@PR_NOTES_7 VARCHAR(1000),
			@PR_NOTES_8 VARCHAR(1000),
			@PR_NOTES_9 VARCHAR(1000),
			@PR_NOTES_10 VARCHAR(1000)


	DECLARE @relatedProcessTable AS TABLE
	(
		PROCESS_ID bigint
	)

	BEGIN TRY
		
		SET NOCOUNT ON;
		SET @MSG = 'Job AutoCreatePO Process Started'
		SET @MSG_ID = 'MSG0000001'
		EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID OUT, @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
		--INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID)

		DELETE FROM TB_T_PO_H WHERE CREATED_BY = @USER_ID
		DELETE FROM TB_T_PO_ITEM WHERE CREATED_BY = @USER_ID

		IF ISNULL(@CURRENCY, '') = '' BEGIN SELECT @CURRENCY = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'LOCAL_CURR_CD' END

		SET @MSG = 'Get currency rate Started'
		SET @MSG_ID = 'MSG0000002'
		EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
		--INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID)

		DECLARE @currencyRate TABLE ( CurrencyCode VARCHAR(3), ExchangeRate DECIMAL(7,2), ValidFrom DATETIME, ValidTo DATETIME )
        DECLARE @EXCHANGE_RATE DECIMAL(7,2)
        INSERT INTO @currencyRate EXEC sp_Currency_GetCurrency @currency
        SET @MSG = 'Bug - Currently applicable currency rate of ''' + ISNULL(@currency, '') + ''' is duplicate'
        IF (SELECT COUNT(0) FROM @currencyRate) > 1 BEGIN RAISERROR(@MSG, 16, 1) END
        SELECT @EXCHANGE_RATE = ExchangeRate FROM @currencyRate
        DELETE FROM @currencyRate

		SET @MSG = 'Get currency rate success'
		SET @MSG_ID = 'MSG0000003'
		EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 1;
		--INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID)

		DECLARE @PR_TO_PROCESS TABLE (
			PR_NO [varchar](10),
			PR_ITEM_NO [varchar](5),
			MAT_NO [varchar](23),
			VENDOR_CD [varchar](6),
			VENDOR_NAME [varchar](100),
			PURCHASING_GROUP_CD  [varchar](3),
			PROC_CHANNEL_CD [varchar](4),
			DELIVERY_ADDR VARCHAR(150),
			STATUS VARCHAR(20)
			)

		DELETE FROm TB_H_PO_PROCESSING_INFO WHERE PROCESS_ID = @PROCESS_ID

		UPDATE temp
			 SET STATUS ='SKIP',
				 PO_NO = (SELECT TOP 1 PO_NO FROM TB_R_PO_ITEM WHERE PR_NO = temp.PR_NO AND PR_ITEM_NO = temp.PR_ITEM_NO) 
		FROM TB_R_PO_GENERATE_MONITORING temp
		WHERE NOT EXISTS (SELECT 1 FROM fnt_POGenerate_GetOutstandingList () t WHERE t.PR_NO = temp.PO_NO and t.PR_ITEM_NO = temp.PR_ITEM_NO)
		AND STATUS NOT IN ('SUCCESS','LOCK') 

		INSERT INTO @PR_TO_PROCESS  (PR_NO, PR_ITEM_NO, MAT_NO, VENDOR_CD, VENDOR_NAME, PURCHASING_GROUP_CD, PROC_CHANNEL_CD, DELIVERY_ADDR, STATUS)
		SELECT PR_NO, PR_ITEM_NO, MAT_NO, VENDOR_CD, VENDOR_NAME, PURCHASING_GROUP_CD, PROC_CHANNEL_CD, DELIVERY_ADDR, STATUS FROM fnt_POGenerate_GetOutstandingList ()
		WHERE STATUS = 'OPEN'

		INSERT INTO TB_T_PO_GENERATE_MONITORING (PROCESS_ID, PR_NO, PR_ITEM_NO, MAT_NO, STATUS,PROCESS_DATE,CREATED_BY,CREATED_DT)
		SELECT @PROCESS_ID, PR_NO, PR_ITEM_NO, MAT_NO, 'LOCK', GETDATE(), @USER_ID, GETDATE()
		FROM @PR_TO_PROCESS

		--BEGIN
		--	SET @MSG = 'Clear PO Number for processing PO :Start'
		--	SET @MSG_ID = 'MSG0000004'
		--	EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

		--	UPDATE R
		--		SET PO_NO = ''
		--	FROM TB_R_PR_ITEM R
		--	INNER JOIN @PR_TO_PROCESS T ON T.PR_NO = R.PR_NO AND T.PR_ITEM_NO = R.PR_ITEM_NO

		--	SET @MSG = 'Clear PO Number for processing PO :end'
		--	SET @MSG_ID = 'MSG0000004'
		--	EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 1;
		--END

		DECLARE @PROCESS_DATE DATETIME = GETDATE()
		MERGE TB_R_PO_GENERATE_MONITORING AS [Target]
			USING fnt_POGenerate_GetOutstandingList () AS [Source]
			ON ([Target].PR_NO = [Source].PR_NO AND [Target].PR_ITEM_NO = [Source].PR_ITEM_NO)
		WHEN NOT MATCHED THEN
			INSERT (PR_NO, PR_ITEM_NO, MAT_NO, STATUS, PROCESS_DATE, CREATED_BY, CREATED_DT)
			VALUES ([Source].PR_NO, [Source].PR_ITEM_NO, [Source].MAT_NO, 'OPEN', @PROCESS_DATE, @USER_ID, GETDATE())
		WHEN MATCHED THEN
			UPDATE SET STATUS = 'OPEN', PROCESS_ID = NULL, PROCESS_DATE = @PROCESS_DATE;

		UPDATE PRI
			SET VENDOR_CD = t.VENDOR_CD,
				VENDOR_NAME = t.VENDOR_NAME
		FROM TB_R_PR_ITEM PRI
		INNER JOIN @PR_TO_PROCESS t ON t.PR_NO = PRI.PR_NO AND t.PR_ITEM_NO = PRI.PR_ITEM_NO

		DECLARE @VENDOR_LIST AS TABLE 
		(
			PR_NO VARCHAR(50),
			VENDOR_CD VARCHAR(6),
			VENDOR_NAME VARCHAR(100),
			DELIVERY_ADDR VARCHAR(150),
			PURCHASING_GROUP VARCHAR(3),
			PROC_CHANNEL VARCHAR(4)
		)

		INSERT INTO @VENDOR_LIST (PR_NO, VENDOR_CD, VENDOR_NAME, DELIVERY_ADDR, PURCHASING_GROUP, PROC_CHANNEL)
		select DISTINCT pri.PR_NO, pri.VENDOR_CD, pri.VENDOR_NAME, pri.DELIVERY_ADDR, mvc.PURCHASING_GROUP_CD, mvc.PROC_CHANNEL_CD
			from tb_r_pr_item pri 
			INNER JOIN TB_R_PR_H prh on prh.PR_NO = pri.PR_NO
			LEFT JOIN TB_M_VALUATION_CLASS mvc on mvc.VALUATION_CLASS = pri.VALUATION_CLASS AND mvc.PROCUREMENT_TYPE = @PROCUREMENT_TYPE AND mvc.PR_COORDINATOR = prh.PR_COORDINATOR
			INNER JOIN @PR_TO_PROCESS t ON t.PR_NO = PRI.PR_NO AND t.PR_ITEM_NO = PRI.PR_ITEM_NO

		DECLARE db_cursor_vendor CURSOR FOR  
		SELECT PR_NO, VENDOR_CD, VENDOR_NAME, DELIVERY_ADDR, PURCHASING_GROUP, PROC_CHANNEL FROM @VENDOR_LIST

		OPEN db_cursor_vendor   
		FETCH NEXT FROM db_cursor_vendor INTO @PR_NO, @VENDOR_CD, @VENDOR_NAME, @DELIVERY_ADDR, @PURCHASING_GROUP, @PROC_CHANNEL
		WHILE @@FETCH_STATUS = 0   
		BEGIN   

			DECLARE @ITEM_T AS TABLE
			(	
				NUM INT,
				PR_NO VARCHAR(10),
				PR_ITEM_NO VARCHAR(5),
				CALCSCHEME VARCHAR(4),
				BASEPRICE DECIMAL(18,4),
				BASEQTY DECIMAL(18,2)
			)

			DECLARE @PR_ITEM_T AS TABLE
			(	
				PR_NO VARCHAR(10),
				PR_ITEM_NO VARCHAR(5),
				CALCSCHEME VARCHAR(4),
				BASEPRICE DECIMAL(18,4),
				BASEQTY DECIMAL(18,2)
			)

			DELETE FROM @ITEM_T
			SET @PR_NOTES_1 = ''
			SET @PR_NOTES_2 = ''
			SET @PR_NOTES_3 = ''
			SET @PR_NOTES_4 = ''
			SET @PR_NOTES_5 = ''
			SET @PR_NOTES_6 = ''
			SET @PR_NOTES_7 = ''
			SET @PR_NOTES_8 = ''
			SET @PR_NOTES_9 = ''
			SET @PR_NOTES_10 = ''

			SET @MSG = 'Create PO Temp Data Started'
			SET @MSG_ID = 'MSG0000004'
			EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
			INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID)

			DECLARE @DELIVERY_NAME VARCHAR(30), @DELIVERY_ADDRESS VARCHAR(150), @DELIVERY_POSTAL VARCHAR(6), @DELIVERY_CITY VARCHAR(30)
			SELECT @DELIVERY_NAME = DELIVERY_NAME, @DELIVERY_ADDRESS = ADDRESS, @DELIVERY_POSTAL = POSTAL_CODE, @DELIVERY_CITY = CITY
			FROM TB_M_DELIVERY_ADDR WHERE DELIVERY_ADDR = @DELIVERY_ADDR
			select @PR_NOTES_1 = Split from [dbo].[SplitString] ((select PR_NOTES from TB_R_PR_H where PR_NO = @PR_NO), CHAR(10))
								WHERE No = 1
			select @PR_NOTES_2 = Split from [dbo].[SplitString] ((select PR_NOTES from TB_R_PR_H where PR_NO = @PR_NO), CHAR(10))
								WHERE No = 2
			select @PR_NOTES_3 = Split from [dbo].[SplitString] ((select PR_NOTES from TB_R_PR_H where PR_NO = @PR_NO), CHAR(10))
								WHERE No = 3
			select @PR_NOTES_4 = Split from [dbo].[SplitString] ((select PR_NOTES from TB_R_PR_H where PR_NO = @PR_NO), CHAR(10))
								WHERE No = 4
			select @PR_NOTES_5 = Split from [dbo].[SplitString] ((select PR_NOTES from TB_R_PR_H where PR_NO = @PR_NO), CHAR(10))
								WHERE No = 5
			select @PR_NOTES_6 = Split from [dbo].[SplitString] ((select PR_NOTES from TB_R_PR_H where PR_NO = @PR_NO), CHAR(10))
								WHERE No = 6
			select @PR_NOTES_7 = Split from [dbo].[SplitString] ((select PR_NOTES from TB_R_PR_H where PR_NO = @PR_NO), CHAR(10))
								WHERE No = 7
			select @PR_NOTES_8 = Split from [dbo].[SplitString] ((select PR_NOTES from TB_R_PR_H where PR_NO = @PR_NO), CHAR(10))
								WHERE No = 8
			select @PR_NOTES_9 = Split from [dbo].[SplitString] ((select PR_NOTES from TB_R_PR_H where PR_NO = @PR_NO), CHAR(10))
								WHERE No = 9
			select @PR_NOTES_10 = Split from [dbo].[SplitString] ((select PR_NOTES from TB_R_PR_H where PR_NO = @PR_NO), CHAR(10))
								WHERE No = 10

			IF ISNULL(@DELIVERY_NAME,'') = '' 
			BEGIN 
				SET @MSG = 'Address Not found.'

				UPDATE T 
					SET STATUS = 'FAILED',
						REMARK = @MSG,
						CHANGED_BY = @USER_ID,
						CHANGED_DT = GETDATE()
				FROM TB_T_PO_GENERATE_MONITORING T
				INNER JOIN @PR_TO_PROCESS temp ON temp.PR_NO = t.PR_NO and temp.PR_ITEM_NO = t.PR_ITEM_NO 
					and ISNULL(T.PR_NO,'') = ISNULL(@PR_NO,'') and ISNULL(VENDOR_CD,'') = ISNULL(@VENDOR_CD,'') 
					and ISNULL(DELIVERY_ADDR,'') =ISNULL(@DELIVERY_ADDR,'')  and ISNULL(PROC_CHANNEL_CD,'') = ISNULL(@PROC_CHANNEL,'') 
					and ISNULL(PURCHASING_GROUP_CD,'') = ISNULL(@PURCHASING_GROUP,'')
					AND T.STATUS = 'LOCK' AND T.PROCESS_ID = @PROCESS_ID

				EXEC dbo.sp_PutLog 'Delivery Null', @USER_ID, @LOCATION, @PROCESS_ID , 'SKIP', 'SUC', @MODULE, @FUNCTION, 1;
				GOTO nextFetch;
			END

			IF ISNULL(@VENDOR_CD,'') = '' 
			BEGIN 
				SET @MSG = 'Not Found Source list for this material. '

				UPDATE T 
					SET STATUS = 'FAILED',
						REMARK = @MSG,
						CHANGED_BY = @USER_ID,
						CHANGED_DT = GETDATE()
				FROM TB_T_PO_GENERATE_MONITORING T
				INNER JOIN @PR_TO_PROCESS temp ON temp.PR_NO = t.PR_NO and temp.PR_ITEM_NO = t.PR_ITEM_NO 
					and ISNULL(T.PR_NO,'') = ISNULL(@PR_NO,'') and ISNULL(VENDOR_CD,'') = ISNULL(@VENDOR_CD,'') 
					and ISNULL(DELIVERY_ADDR,'') =ISNULL(@DELIVERY_ADDR,'')  and ISNULL(PROC_CHANNEL_CD,'') = ISNULL(@PROC_CHANNEL,'') 
					and ISNULL(PURCHASING_GROUP_CD,'') = ISNULL(@PURCHASING_GROUP,'')
					AND T.STATUS = 'LOCK' AND T.PROCESS_ID = @PROCESS_ID

				EXEC dbo.sp_PutLog 'Vendor Null', @USER_ID, @LOCATION, @PROCESS_ID , 'SKIP', 'SUC', @MODULE, @FUNCTION, 1;
				GOTO nextFetch;
			END

			DECLARE @PAYMENT_METHOD_CD VARCHAR(1), @PAYMENT_TERM VARCHAR(4), @VENDOR_ADDRESS VARCHAR(150), @VENDOR_CITY VARCHAR(30),
					@VENDOR_COUNTRY VARCHAR(2), @VENDOR_POSTAL VARCHAR(6), @VENDOR_PHONE VARCHAR(30), @VENDOR_FAX VARCHAR(30), @VENDOR_ATTENTION VARCHAR(50)
			SELECT
				@PAYMENT_METHOD_CD = PAYMENT_METHOD_CD,	@PAYMENT_TERM = PAYMENT_TERM_CD, @VENDOR_ADDRESS = VENDOR_ADDRESS,
				@VENDOR_COUNTRY = COUNTRY, @VENDOR_CITY = CITY, @VENDOR_POSTAL = POSTAL_CODE,	@VENDOR_PHONE = PHONE, @VENDOR_FAX = FAX,
				@VENDOR_ATTENTION = ATTENTION
			FROM TB_M_VENDOR WHERE VENDOR_CD = @VENDOR_CD
			IF ISNULL(@VENDOR_COUNTRY, '') = '' BEGIN SELECT @VENDOR_COUNTRY = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'LOCAL_COUNTRY' END

			DECLARE @MAX_ROW_PER_GROUP INT = 50, @Count_Group_Row INT = 1, @Row_id int = 0
			SELECT @MAX_ROW_PER_GROUP = CONVERT(INT, SYSTEM_VALUE) FROM TB_M_SYSTEM WHERE FUNCTION_ID = '00000' AND SYSTEM_CD = 'MAX_PR_ITEM'

			BEGIN
				INSERT INTO @ITEM_T
				select DENSE_RANK() over (partition by NULL ORDER BY  pri.PR_NO, pri.PR_ITEM_NO) AS NUM, pri.PR_NO, pri.PR_ITEM_NO, valc.CALCULATION_SCHEME_CD, pri.PRICE_PER_UOM, pri.OPEN_QTY
				from tb_r_pr_item pri
				JOIN TB_M_VALUATION_CLASS valc ON pri.VALUATION_CLASS = valc.VALUATION_CLASS AND PROCUREMENT_TYPE = @PROCUREMENT_TYPE
				INNER JOIN @PR_TO_PROCESS t ON t.PR_NO = PRI.PR_NO AND t.PR_ITEM_NO = PRI.PR_ITEM_NO
				where pri.PR_Status = '14' AND pri.PR_NO = @PR_NO
					and ISNULL(pri.RELEASE_FLAG,'N') = 'Y' AND pri.VENDOR_CD = @VENDOR_CD AND ISNULL(pri.VENDOR_CD,'') <> ''
					AND pri.DELIVERY_ADDR = @DELIVERY_ADDR AND ISNULL(pri.DELIVERY_ADDR,'') <> '' 
					AND	t.PROC_CHANNEL_CD = @PROC_CHANNEL AND ISNULL(t.PROC_CHANNEL_CD ,'') <> '' 
					AND	t.PURCHASING_GROUP_CD = @PURCHASING_GROUP  AND ISNULL(t.PURCHASING_GROUP_CD, '') <> '' 

				iF ((select count(0) from @ITEM_T) <= 0)
				BEGIN
					RAISERROR('PO must have at lease 1 item..!',16,1)
				END
			END
				
			SELECT @Count_Group_Row = (COUNT(0)/@MAX_ROW_PER_GROUP) + 1 FROM @ITEM_T

			SET @Row_id = 0
			WHILE @Row_id < @Count_Group_Row
			BEGIN
				SET @RELATED_PROCESS_ID = NULL
				BEGIN -- Insert PO Header
					SET @MSG = 'Insert PO Header Temp started'
					SET @MSG_ID = 'MSG0000001'
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID OUTPUT , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

					SET @MSG = 'Related Process Id '+ CONVERT(VARCHAR, @RELATED_PROCESS_ID)
					SET @MSG_ID = 'MSG0000005'
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
					INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID)

					INSERT INTO @relatedProcessTable VALUES (@RELATED_PROCESS_ID)

					IF ISNULL(@PURCHASING_GROUP, '') = '' 
					BEGIN 
						SET @MSG = 'Cannot find the Purchasing Group.'

						UPDATE T 
							SET STATUS = 'FAILED',
								REMARK = @MSG,
								CHANGED_BY = @USER_ID,
								CHANGED_DT = GETDATE()
						FROM TB_T_PO_GENERATE_MONITORING T
						INNER JOIN @PR_TO_PROCESS temp ON temp.PR_NO = t.PR_NO and temp.PR_ITEM_NO = t.PR_ITEM_NO 
						and ISNULL(T.PR_NO,'') = ISNULL(@PR_NO,'') and ISNULL(VENDOR_CD,'') = ISNULL(@VENDOR_CD,'') 
						and ISNULL(DELIVERY_ADDR,'') =ISNULL(@DELIVERY_ADDR,'')  and ISNULL(PROC_CHANNEL_CD,'') = ISNULL(@PROC_CHANNEL,'') 
						and ISNULL(PURCHASING_GROUP_CD,'') = ISNULL(@PURCHASING_GROUP,'')
							AND T.STATUS = 'LOCK' AND T.PROCESS_ID = @PROCESS_ID
					
						EXEC dbo.sp_PutLog 'Purchasing Group Null', @USER_ID, @LOCATION, @PROCESS_ID , 'SKIP', 'SUC', @MODULE, @FUNCTION, 1;
						GOTO nextFetch;
					END
					IF ISNULL(@PROC_CHANNEL, '') = '' 
					BEGIN 
						SET @MSG = 'Cannot find the Procurement Channel.'

						UPDATE T 
							SET STATUS = 'FAILED',
								REMARK = @MSG,
								CHANGED_BY = @USER_ID,
								CHANGED_DT = GETDATE()
						FROM TB_T_PO_GENERATE_MONITORING T
						INNER JOIN @PR_TO_PROCESS temp ON temp.PR_NO = t.PR_NO and temp.PR_ITEM_NO = t.PR_ITEM_NO 
						and ISNULL(T.PR_NO,'') = ISNULL(@PR_NO,'') and ISNULL(VENDOR_CD,'') = ISNULL(@VENDOR_CD,'') 
						and ISNULL(DELIVERY_ADDR,'') =ISNULL(@DELIVERY_ADDR,'')  and ISNULL(PROC_CHANNEL_CD,'') = ISNULL(@PROC_CHANNEL,'') 
						and ISNULL(PURCHASING_GROUP_CD,'') = ISNULL(@PURCHASING_GROUP,'')
							AND T.STATUS = 'LOCK' AND T.PROCESS_ID = @PROCESS_ID

						EXEC dbo.sp_PutLog 'Procuremenet Channel Null', @USER_ID, @LOCATION, @PROCESS_ID , 'SKIP', 'SUC', @MODULE, @FUNCTION, 1;

						GOTO nextFetch;
					END

					IF ISNULL(@CURRENCY, '') = '' BEGIN SELECT @CURRENCY = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'LOCAL_CURR_CD' END

					INSERT INTO TB_T_PO_H
					(PROCESS_ID, PO_DESC, DOC_DT, 
					VENDOR_CD, VENDOR_NAME, PROC_CHANNEL_CD, PURCHASING_GRP_CD, ORI_CURR_CD, ORI_EXCHANGE_RATE, ORI_AMOUNT,
					NEW_CURR_CD, NEW_EXCHANGE_RATE, NEW_AMOUNT, ORI_LOCAL_AMOUNT, NEW_LOCAL_AMOUNT, NEW_FLAG, UPDATE_FLAG, DELETE_FLAG, PO_NO, PO_NOTE1,
					PO_NOTE2, PO_NOTE3, PO_NOTE4, PO_NOTE5, PO_NOTE6, PO_NOTE7, PO_NOTE8, PO_NOTE9, PO_NOTE10, VENDOR_ADDRESS, POSTAL_CODE, CITY, ATTENTION,
					PHONE, FAX, COUNTRY, DELIVERY_ADDR, DELIVERY_NAME, DELIVERY_ADDRESS, DELIVERY_POSTAL_CODE, DELIVERY_CITY, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT, OTHER_MAIL)
					SELECT @RELATED_PROCESS_ID, '[Auto] ' + CONVERT(VARCHAR, GETDATE(),105 )+ ' ' + CONVERT(VARCHAR, GETDATE(),108) AS PO_DESC, GETDATE(), 
					@VENDOR_CD, @VENDOR_NAME, @PROC_CHANNEL, @PURCHASING_GROUP, NULL, 0, 0, @CURRENCY, @EXCHANGE_RATE, 0, 0, 0, 'Y', 'N', 'N', NULL,
					@PR_NOTES_1 AS PO_NOTE1, @PR_NOTES_2 AS PO_NOTE2, @PR_NOTES_3 AS PO_NOTE3, @PR_NOTES_4 AS PO_NOTE4, @PR_NOTES_5 AS PO_NOTE5, @PR_NOTES_6 AS PO_NOTE6, @PR_NOTES_7 AS PO_NOTE7, @PR_NOTES_8 AS PO_NOTE8, @PR_NOTES_9 AS PO_NOTE9, @PR_NOTES_10 AS PO_NOTE10, 
					@VENDOR_ADDRESS, @VENDOR_POSTAL, @VENDOR_CITY, @VENDOR_ATTENTION, @VENDOR_PHONE, @VENDOR_FAX, @VENDOR_COUNTRY, @DELIVERY_ADDR, @DELIVERY_NAME, @DELIVERY_ADDRESS, @DELIVERY_POSTAL, 
					@DELIVERY_CITY, @USER_ID AS CURR_USER, GETDATE(), NULL, NULL, '' AS OTHER_EMAIL

					SET @MSG = 'Insert PO Header Temp finished'
					SET @MSG_ID = 'MSG0000002'
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID, @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
				END

				BEGIN
					DELETE FROM @PR_ITEM_T
					INSERT INTO @PR_ITEM_T
						SELECT PR_NO, PR_ITEM_NO, CALCSCHEME , BASEPRICE, BASEQTY 
						FROM @ITEM_T WHERE NUM BETWEEN (@Row_id*@MAX_ROW_PER_GROUP)+1 AND ((@Row_id+1)*@MAX_ROW_PER_GROUP)
				END

				BEGIN -- Insert PO Item
					SET @MSG = 'Insert PO Temp Item started'
					SET @MSG_ID = 'MSG0000003'
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID, @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

					INSERT INTO TB_T_PO_ITEM  
					(PROCESS_ID, SEQ_ITEM_NO, PR_NO, PR_ITEM_NO, VENDOR_CD, VENDOR_NAME, QUOTATION_NO, 
					PURCHASING_GRP_CD, VALUATION_CLASS, MAT_NO, MAT_DESC, PROCUREMENT_PURPOSE, DELIVERY_PLAN_DT, 
					SOURCE_TYPE, PLANT_CD, SLOC_CD, WBS_NO, COST_CENTER_CD, UNLIMITED_FLAG, TOLERANCE_PERCENTAGE, SPECIAL_PROCUREMENT_TYPE,  
					PO_QTY_ORI, PO_QTY_USED, PO_QTY_REMAIN, UOM, CURR_CD, ORI_AMOUNT, 
					NEW_FLAG, UPDATE_FLAG, DELETE_FLAG, PO_NO,  
					PO_ITEM_NO, URGENT_DOC, GROSS_PERCENT, ITEM_CLASS, 
					IS_PARENT, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT, WBS_NAME,  
					GL_ACCOUNT, PO_QTY_NEW, ORI_PRICE_PER_UOM, NEW_PRICE_PER_UOM, NEW_AMOUNT, 
					ORI_LOCAL_AMOUNT, NEW_LOCAL_AMOUNT)   
					SELECT @RELATED_PROCESS_ID, DENSE_RANK() OVER (partition BY @RELATED_PROCESS_ID order by tmp.PR_NO, tmp.PR_ITEM_NO DESC) AS Row, tmp.PR_NO, tmp.PR_ITEM_NO, @VENDOR_CD, @VENDOR_NAME, '', 
					@PURCHASING_GROUP, pri.VALUATION_CLASS, pri.MAT_NO, pri.MAT_DESC, '', pri.DELIVERY_PLAN_DT,  
					pri.SOURCE_TYPE, prh.PLANT_CD, prh.SLOC_CD, pri.WBS_NO, pri.COST_CENTER_CD, NULL, 0, '', 
					pri.OPEN_QTY, 0, pri.OPEN_QTY, pri.UNIT_OF_MEASURE_CD, pri.LOCAL_CURR_CD, 0, 
					(CASE WHEN ISNULL(PO_NO,'') = '' THEN 'Y' ELSE 'N' END), (CASE WHEN ISNULL(PO_NO,'') = '' THEN 'N' ELSE 'Y' END), 'N',  
					NULL, NULL, 'N', 0, (SELECT ITEM_CLASS FROM TB_M_VALUATION_CLASS WHERE VALUATION_CLASS = pri.VALUATION_CLASS AND PURCHASING_GROUP_CD = @PURCHASING_GROUP AND PROCUREMENT_TYPE = 'RM'),
					'N' isParent, @USER_ID, GETDATE(), NULL, NULL, pri.WBS_NAME,  
					pri.GL_ACCOUNT, pri.OPEN_QTY, 0, pri.PRICE_PER_UOM, pri.OPEN_QTY * pri.PRICE_PER_UOM * (SELECT ISNULL(CALC_VALUE, 0) FROM TB_M_UNIT_OF_MEASURE WHERE UNIT_OF_MEASURE_CD = pri.UNIT_OF_MEASURE_CD),
					0, pri.OPEN_QTY * pri.PRICE_PER_UOM * @EXCHANGE_RATE * (SELECT ISNULL(CALC_VALUE, 0) FROM TB_M_UNIT_OF_MEASURE WHERE UNIT_OF_MEASURE_CD = pri.UNIT_OF_MEASURE_CD)
					FROM @PR_ITEM_T tmp
					INNER JOIN TB_R_PR_ITEM pri ON pri.PR_NO= tmp.PR_NO AND pri.PR_ITEM_NO = tmp.PR_ITEM_NO 
					INNER JOIN TB_R_PR_H prh on prh.PR_NO = pri.PR_NO
					--WHERE NOT EXISTS (SELECT 1 FROM TB_R_PO_ITEM WHERE PR_NO = pri.PR_NO  AND PR_ITEM_NO = pri.PR_ITEM_NO) AND pri.VENDOR_CD = @VENDOR_CD

					Update TB_T_PO_ITEM SET IS_PARENT = CASE WHEN ITEM_CLASS = 'S' THEN 'Y' ELSE 'N' END
					WHERE PROCESS_ID = @RELATED_PROCESS_ID

					INSERT INTO TB_H_PO_PROCESSING_INFO ([PROCESS_ID], [PO_NO], [PR_NO], [PR_ITEM_NO], [STATUS], [RELATED_PROCESS_ID], [CREATED_BY], [CREATED_DT])
					SELECT @PROCESS_ID, '', PR_NO, PR_ITEM_NO, 'O', @RELATED_PROCESS_ID, @USER_ID, GETDATE()
					FROM @PR_ITEM_T

					SET @MSG = 'Insert PO Temp Item finished'
					SET @MSG_ID = 'MSG0000003'
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID, @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
				END

				--Update PO Description
				BEGIN
					SET @MSG = 'Update PO Temp Description Header started'
					SET @MSG_ID = 'MSG0000004'
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID, @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

					SELECT TOP 1 @PO_DESC = '[Auto] '+ pri.MAT_NO +'-'+ pri.MAT_DESC
					FROM @PR_ITEM_T t
					INNER JOIN TB_R_PR_ITEM pri ON pri.PR_NO= t.PR_NO AND pri.PR_ITEM_NO = t.PR_ITEM_NO 

					UPDATE TB_T_PO_H SET PO_DESC = @PO_DESC WHERE PROCESS_ID = @RELATED_PROCESS_ID

					SET @MSG = 'Update PO Temp Description Header finished'
					SET @MSG_ID = 'MSG0000004'
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID, @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
				END


				BEGIN -- Insert PO Condition
					SET @MSG = 'Insert PO Temp Condition started'
					SET @MSG_ID = 'MSG0000005'
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID, @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

					DECLARE @calculationRef CALC_COMP_PRICE  
					INSERT INTO @calculationRef 
					SELECT tmp.*  
					FROM (  
						SELECT SEQ_NO SeqNo, CONDITION_CATEGORY Category, CALCULATION_TYPE CalcType, COMP_PRICE_CD CompPriceCode,   
							BASE_VALUE_FROM BaseFrom, BASE_VALUE_TO BaseTo, PLUS_MINUS_FLAG PlusMinus, item.BASEPRICE Rate, ACCRUAL_FLAG_TYPE AccrualType,  
							CONDITION_RULE ConditionRule, 'M' CompType, item.BASEQTY Qty, (CASE QTY_PER_UOM WHEN 'N' THEN item.BASEQTY ELSE CAST(QTY_PER_UOM AS INT) END) QtyPerUOM, 0 Price, item.PR_NO+'-'+item.PR_ITEM_NO  seq_Item_No  
						FROM @PR_ITEM_T item JOIN TB_M_CALCULATION_MAPPING ON CALCULATION_SCHEME_CD = item.CALCSCHEME AND CONDITION_CATEGORY = 'H'  
						UNION  
						SELECT calcm.SEQ_NO SeqNo, calcm.CONDITION_CATEGORY Category, calcm.CALCULATION_TYPE CalcType, calcm.COMP_PRICE_CD CompPriceCode,  
							calcm.BASE_VALUE_FROM BaseFrom, calcm.BASE_VALUE_TO BaseTo, calcm.PLUS_MINUS_FLAG PlusMinus, cmppr.COMP_PRICE_RATE Rate,  
							calcm.ACCRUAL_FLAG_TYPE AccrualType, calcm.CONDITION_RULE ConditionRule, 'M' CompType, item.BASEQTY Qty,  
							(CASE QTY_PER_UOM WHEN 'N' THEN item.BASEQTY ELSE CAST(QTY_PER_UOM AS INT) END) QtyPerUOM, 0 Price, item.PR_NO+'-'+item.PR_ITEM_NO seq_Item_No   
						FROM @PR_ITEM_T item
						JOIN TB_M_CALCULATION_MAPPING calcm ON CALCULATION_SCHEME_CD = item.CALCSCHEME
						JOIN TB_M_COMP_PRICE_RATE cmppr ON calcm.COMP_PRICE_CD = cmppr.COMP_PRICE_CD  
						WHERE calcm.CONDITION_CATEGORY = 'D'  
					) tmp 

					--calculate Category H & D (CalType 1 and 2)
					update cr SET Price = 
						CASE  
							WHEN cr.Category = 'H' THEN   
								CASE WHEN cr.PlusMinus = 1 THEN (cr.Rate*qty)
								ELSE (cr.Rate*qty) * -1  
								END  
								--CASE WHEN cr.PlusMinus = 1 THEN cr.Rate  
								--ELSE cr.Rate * -1  
								--END  
							WHEN cr.Category = 'D' THEN  
								CASE cr.CalcType  
									WHEN 1 THEN -- Fix Amount  
										CASE WHEN cr.PlusMinus = 1 THEN cr.Rate  
										ELSE cr.Rate * -1  
										END  
									WHEN 2 THEN -- By Quantity  
										CASE WHEN cr.PlusMinus = 1 THEN cr.Rate / cr.QtyPerUOM  
										ELSE (cr.Rate / cr.QtyPerUOM) * -1  
										END 
									ELSE Price
								END  
						END
					from @calculationRef cr 

					--calculate Category D (CalType 1 and 2)
					update cr SET Price = 
						CASE  
							WHEN cr.Category = 'D' THEN  
								CASE cr.CalcType  
									WHEN 3 THEN -- Percentage or Percentage Summary  
										CASE WHEN cr.PlusMinus = 1 THEN (cr.Rate/100) * (SELECT SUM(cri.Price) FROM @calculationRef cri WHERE cri.SeqNo BETWEEN cr.BaseFrom AND ISNULL(cr.BaseTo, cr.BaseFrom)AND cri.SeqNo < cr.SeqNo and cri.Seq_Item_No = cr.Seq_Item_No)  
										ELSE ((cr.Rate/100) * (SELECT SUM(cri.Price) FROM @calculationRef cri WHERE cri.SeqNo BETWEEN cr.BaseFrom AND ISNULL(cr.BaseTo, cr.BaseFrom)AND cri.SeqNo < cr.SeqNo and cri.Seq_Item_No = cr.Seq_Item_No)) * -1  
										END  
									WHEN 4 THEN -- Summary  
										CASE WHEN cr.PlusMinus = 1 THEN (SELECT SUM(cri.Price) FROM @calculationRef cri WHERE cri.SeqNo BETWEEN cr.BaseFrom AND ISNULL(cr.BaseTo, cr.BaseFrom)AND cri.SeqNo < cr.SeqNo and cri.Seq_Item_No = cr.Seq_Item_No)  
										ELSE (SELECT SUM(cri.Price) FROM @calculationRef cri WHERE cri.SeqNo BETWEEN cr.BaseFrom AND ISNULL(cr.BaseTo, cr.BaseFrom) AND cri.SeqNo < cr.SeqNo and cri.Seq_Item_No = cr.Seq_Item_No) * -1  
										END  
									else Price
								END  
							else Price
						END
					from @calculationRef cr where CalcType >2 

					----recalculate all Category and CalcType
					update cr SET Price = 
						CASE
							WHEN cr.Category = 'D' THEN  
								CASE cr.CalcType  
									WHEN 1 THEN -- Fix Amount  
										CASE WHEN cr.PlusMinus = 1 THEN cr.Rate  
										ELSE cr.Rate * -1  
										END  
									WHEN 2 THEN -- By Quantity  
										CASE WHEN cr.PlusMinus = 1 THEN cr.Rate / cr.QtyPerUOM  
										ELSE (cr.Rate / cr.QtyPerUOM) * -1  
										END  
									WHEN 3 THEN -- Percentage or Percentage Summary  
										CASE WHEN cr.PlusMinus = 1 THEN (cr.Rate/100) * (SELECT SUM(cri.Price) FROM @calculationRef cri WHERE cri.SeqNo BETWEEN cr.BaseFrom AND ISNULL(cr.BaseTo, cr.BaseFrom)AND cri.SeqNo < cr.SeqNo and cri.Seq_Item_No = cr.Seq_Item_No)  
										ELSE ((cr.Rate/100) * (SELECT SUM(cri.Price) FROM @calculationRef cri WHERE cri.SeqNo BETWEEN cr.BaseFrom AND ISNULL(cr.BaseTo, cr.BaseFrom)AND cri.SeqNo < cr.SeqNo and cri.Seq_Item_No = cr.Seq_Item_No)) * -1  
										END  
									WHEN 4 THEN -- Summary  
										CASE WHEN cr.PlusMinus = 1 THEN (SELECT SUM(cri.Price) FROM @calculationRef cri WHERE cri.SeqNo BETWEEN cr.BaseFrom AND ISNULL(cr.BaseTo, cr.BaseFrom)AND cri.SeqNo < cr.SeqNo and cri.Seq_Item_No = cr.Seq_Item_No)  
										ELSE (SELECT SUM(cri.Price) FROM @calculationRef cri WHERE cri.SeqNo BETWEEN cr.BaseFrom AND ISNULL(cr.BaseTo, cr.BaseFrom) AND cri.SeqNo < cr.SeqNo and cri.Seq_Item_No = cr.Seq_Item_No) * -1  
										END  
								END  
						END
					from @calculationRef cr WHERE Category <> 'H'

					DELETE FROM TB_T_PO_CONDITION WHERE PROCESS_ID = @RELATED_PROCESS_ID

					INSERT INTO TB_T_PO_CONDITION  
					(PROCESS_ID, SEQ_ITEM_NO, PO_NO, PO_ITEM_NO, COMP_PRICE_CD, COMP_PRICE_RATE, INVOICE_FLAG, EXCHANGE_RATE, SEQ_NO, BASE_VALUE_FROM,  
					BASE_VALUE_TO, PO_CURR, INVENTORY_FLAG, CALCULATION_TYPE, PLUS_MINUS_FLAG, CONDITION_CATEGORY, ACCRUAL_FLAG_TYPE, CONDITION_RULE, PRICE_AMT, QTY,  
					QTY_PER_UOM, COMP_TYPE, PRINT_STATUS, NEW_FLAG, UPDATE_FLAG, DELETE_FLAG, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT)  
					SELECT  @RELATED_PROCESS_ID, DENSE_RANK() OVER  (partition BY CompPriceCode order by  tmp.PR_NO, tmp.PR_ITEM_NO DESC) AS Row, pri.PO_NO, NULL, CompPriceCode, Rate, 'N', @EXCHANGE_RATE, SeqNo, BaseFrom, BaseTo, @currency, 'N', CalcType, 1,  
					'D', 'Y', 'V', Price, Qty, QtyPerUOM, CompType, 'N', 'Y', 'N', 'N', @USER_ID, GETDATE(), NULL, NULL  
					FROM @calculationRef ref
					INNER JOIN  @PR_ITEM_T tmp on tmp.PR_NO = LEFT(ref.seq_item_No, 10) AND tmp.PR_ITEM_NO = RIGHT(ref.seq_item_No, 5)
					INNER JOIN TB_R_PR_ITEM pri ON pri.PR_NO= tmp.PR_NO AND pri.PR_ITEM_NO = tmp.PR_ITEM_NO 
					ORDER BY Row, tmp.PR_NO, tmp.PR_ITEM_NO DESC, CompPriceCode ASC

					SET @MSG = 'Insert PO Temp Condition finished'
					SET @MSG_ID = 'MSG0000006'
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @RELATED_PROCESS_ID, @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

				END

				SET @MSG = 'Create PO Temp Data success'
				SET @MSG_ID = 'MSG0000007'
				EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 1;
				INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID)

				DECLARE @PONO VARCHAR(11) = (SELECT TOP 1 PO_NO FROM TB_T_PO_ITEM WHERE PROCESS_ID = @RELATED_PROCESS_ID)
				BEGIN -- Copy data from temp to real table
					SET @MSG = 'Insert PO Data to real table started'
					SET @MSG_ID = 'MSG0000008'
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
					INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID)
				
					DECLARE @Status_Info VARCHAR(20)
					SET @Status_Info = ''

					INSERT INTO TB_T_JOB_PO_PROCESSING (PROCESS_ID, [STATUS], PONO, USER_ID, RELATED_PROCESS_ID, MODULE, [FUNCTION], 
								PURCHASING_GRP, EXCHANGE_RATE, IS_SPKCREATED, IS_DRAFT, CLONE_PONO, REGNO, CREATED_BY, CREATED_DT, CHANGED_BY,CHANGED_DT)
					SELECT @PROCESS_ID, 'PREPARE', @PONO, @USER_ID, @RELATED_PROCESS_ID, @MODULE, @FUNCTION, 
								@PURCHASING_GROUP, @EXCHANGE_RATE, 0, 0, NULL, @RegNo, @USER_ID, GETDATE(), NULL, NULL


					
				END

			   SET @Row_id = @Row_id + 1;
			END;

			
		nextFetch:
			FETCH NEXT FROM db_cursor_vendor INTO @PR_NO, @VENDOR_CD, @VENDOR_NAME, @DELIVERY_ADDR, @PURCHASING_GROUP, @PROC_CHANNEL
		END

		CLOSE db_cursor_vendor   
		DEALLOCATE db_cursor_vendor

		DELETE FROM @calculationRef 

		BEGIN
			SET @MSG = 'Job AutoCreatePO Processed succesfully'
			SET @MSG_ID = 'MSG0000099'
			EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
		END

		SELECT @Feedback = @process_id
    END TRY
    BEGIN CATCH
		DECLARE @Message_Error VARCHAR(MAX) = ERROR_MESSAGE(), @Message_Line_Error int = ERROR_LINE()
		
		--EXEC sp_PutLog_Temp @tmpLog 

		SET @MSG_ID = 'MSG0000099'
		EXEC dbo.sp_PutLog 'Job AutoCreatePO Process finished with error', @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 2;

		IF(@Message_Error = @str_related_err_key)
		BEGIN
			SET @MSG_ID = 'EXCEPTION'
			EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;
		END
		ELSE
		BEGIN
			SET @MSG_ID = 'EXCEPTION'
			SET @MSG = ERROR_MESSAGE() + '. at line : '+ CONVERT(VARCHAR, @Message_Line_Error)
			EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;
		END

		BEGIN 
			UPDATE T 
				SET STATUS = 'FAILED',
					REMARK = @MSG,
					CHANGED_BY = @USER_ID,
					CHANGED_DT = GETDATE()
			FROM TB_T_PO_GENERATE_MONITORING T
			INNER JOIN @PR_TO_PROCESS temp ON temp.PR_NO = t.PR_NO and temp.PR_ITEM_NO = t.PR_ITEM_NO
				AND T.STATUS = 'LOCK' AND T.PROCESS_ID = @PROCESS_ID

			DELETE FROM TB_T_JOB_PO_PROCESSING WHERE PROCESS_ID = @PROCESS_ID
		END

		IF CURSOR_STATUS('global','db_cursor_vendor') >= -1
		BEGIN
			DEALLOCATE db_cursor_vendor
		END

		SELECT @Feedback = @process_id
    END CATCH

	DECLARE @JobId binary(16)
	SELECT @JobId = job_id FROM msdb.dbo.sysjobs WHERE (name = 'eCatalogue_ExecuteJobPO')

	IF (@JobId IS NOT NULL)
	BEGIN
		EXEC msdb.dbo.sp_start_job @job_id = @JobId;
	END

    SET NOCOUNT OFF

	select @Feedback
END
--select * from tb_r_log_d where process_id = @process_id
--select * from tb_r_log_d where process_id in (SELECT PROCESS_ID from @relatedProcessTable)

