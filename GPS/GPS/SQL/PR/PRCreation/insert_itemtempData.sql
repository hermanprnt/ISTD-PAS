DECLARE @@EXIST_ITEM INT,
		@@CHILD_EXIST INT,
		@@IS_PARENT CHAR(1),
		@@EXCHANGE_RATE DECIMAL(7, 2),
		@@TOTAL_AMOUNT DECIMAL(18, 2),
		@@TOTAL_LOCAL_AMOUNT DECIMAL(18, 2),
		@@LOCAL_CURR VARCHAR(5),
		@@CALC_VALUE DECIMAL(7, 4),
		@@COMPLETION CHAR(1) = 'Y',
		@@MESSAGE VARCHAR(MAX) = '',
		@@IS_LOCKED CHAR(1),
		@@OLD_QTY DECIMAL(7, 2),
		@@DIFF_QTY DECIMAL(7, 2) = 0,
		@@TEMP_CHECK INT,
		@@MSG VARCHAR (400),
		@@MSG_ID VARCHAR (200),
		@@BUDGET_REF VARCHAR(3)

BEGIN TRANSACTION
BEGIN TRY
	IF(@ASSET_CATEGORY <> 'X') --if not save for routine master, check wbs and asset category
	BEGIN
		IF(
			(
				-- - OLD CONDITION
				
				SUBSTRING(@WBS_NO, 1, 1) = 'L' OR

				-- - NEW CONDITION
				SUBSTRING(@WBS_NO, 1, 1) = 'C' OR
				SUBSTRING(@WBS_NO, 1, 1) = 'R'
			) 
			AND 
			(@ASSET_CATEGORY = 'NA')
		)
		BEGIN
			SET @@MESSAGE = 'Cannot Choose Asset Category Non-Asset for WBS No ' + @WBS_NO
			RAISERROR(@@MESSAGE, 16, 1)
		END
		ELSE IF(
			(
				-- - OLD CONDITION
				SUBSTRING(@WBS_NO, 1, 1) = 'E' OR 

				-- - NEW CONDITION
				SUBSTRING(@WBS_NO, 1, 1) = 'I' OR --change D3 ke I3
 				SUBSTRING(@WBS_NO, 1, 1) = 'A' OR
				SUBSTRING(@WBS_NO, 1, 1) = 'F' OR
				(SUBSTRING(@WBS_NO, 1, 1) = 'X' AND LEN(@WBS_NO) > 1)
			) 
			AND 
			@ASSET_CATEGORY <> 'NA'
		)
		BEGIN
			SET @@MESSAGE = 'For WBS No ' + @WBS_NO + ' must Choose Asset Category Non-Asset'
			RAISERROR(@@MESSAGE, 16, 1)
		END
	END	

	SELECT @@EXIST_ITEM = COUNT(*) FROM TB_T_PR_ITEM WHERE [PROCESS_ID] = @PROCESS_ID AND ITEM_NO = @ITEM_NO
	SELECT @@CALC_VALUE = CALC_VALUE FROM TB_M_UNIT_OF_MEASURE WHERE UNIT_OF_MEASURE_CD = @UOM

	SELECT @@EXCHANGE_RATE = CASE WHEN EXISTS
	(
		SELECT 1 FROM TB_M_EXCHANGE_RATE WHERE CURR_CD = @CURR AND RELEASED_FLAG = '1'  AND GETDATE() BETWEEN VALID_DT_FROM AND VALID_DT_TO
	) 
	THEN
	(
		SELECT TOP 1 ISNULL(EXCHANGE_RATE, 0) FROM TB_M_EXCHANGE_RATE WHERE CURR_CD = @CURR AND RELEASED_FLAG = '1' AND GETDATE() BETWEEN VALID_DT_FROM AND VALID_DT_TO
	)
	ELSE 0 END

	--DECLARE @@CURRENT_CUR AS VARCHAR (5)
	--SELECT @@CURRENT_CUR = ORI_CURR_CD FROM TB_T_PR_ITEM WHERE ITEM_NO = @ITEM_NO AND PROCESS_ID = @PROCESS_ID
	--SELECT @@CURRENT_CUR  = tpri.ORI_CURR_CD 
	--	FROM TB_T_PR_ITEM tpri 
	--	INNER JOIN TB_R_PR_H prh on prh.PROCESS_ID = tpri.PROCESS_ID
	--	INNER JOIN TB_R_PR_ITEM rpri on rpri.PR_NO = prh.PR_NO and rpri.PR_ITEM_NO = tpri.ITEM_NO
	--	WHERE rpri.PR_ITEM_NO = @ITEM_NO AND tpri.PROCESS_ID = @PROCESS_ID

	--IF(ISNULL(@@CURRENT_CUR,'')<>'')
	--	SET @@BUDGET_REF = (SELECT TOP 1 BUDGET_REF FROM [dbo].[TB_T_PR_ITEM] WHERE [PROCESS_ID] = @PROCESS_ID AND [ORI_CURR_CD] = @@CURRENT_CUR)
	--ELSE
	--	IF EXISTS(SELECT 1 FROM TB_T_PR_ITEM WHERE PROCESS_ID= @PROCESS_ID AND  ITEM_NO = @ITEM_NO AND NEW_FLAG <>'Y')
	--		SET @@BUDGET_REF = (SELECT TOP 1 tpri.BUDGET_REF FROM TB_T_PR_ITEM tpri 
	--														INNER JOIN TB_R_PR_H prh on prh.PROCESS_ID = tpri.PROCESS_ID
	--														INNER JOIN TB_R_PR_ITEM rpri on rpri.PR_NO = prh.PR_NO and rpri.PR_ITEM_NO = tpri.ITEM_NO
	--															and rpri.ORI_CURR_CD <> tpri.ORI_CURR_CD 
	--															AND tpri.PROCESS_ID = @PROCESS_ID AND tpri.ITEM_NO = @ITEM_NO AND tpri.ORI_CURR_CD = @CURR)
	--	ELSE
	--		SET @@BUDGET_REF = (SELECT TOP 1 BUDGET_REF FROM [dbo].[TB_T_PR_ITEM] WHERE [PROCESS_ID] = @PROCESS_ID AND [ORI_CURR_CD] = @CURR)

	--	IF (@@BUDGET_REF IS NOT NULL 
	--	AND EXISTS (SELECT 1 FROM TB_T_PR_ITEM tpri 
	--						INNER JOIN TB_R_PR_H prh on prh.PROCESS_ID = tpri.PROCESS_ID
	--						INNER JOIN TB_R_PR_ITEM rpri on rpri.PR_NO = prh.PR_NO and rpri.PR_ITEM_NO = tpri.ITEM_NO
	--							AND tpri.PROCESS_ID = @PROCESS_ID AND rpri.BUDGET_REF = @@BUDGET_REF and tpri.ORI_CURR_CD <> @CURR))
	--	BEGIN
	--		SET @@BUDGET_REF = NULL
	--	END
	SET @@BUDGET_REF = (SELECT TOP 1 BUDGET_REF FROM [dbo].[TB_T_PR_ITEM] WHERE [PROCESS_ID] = @PROCESS_ID AND [ORI_CURR_CD] = @CURR)
		--IF (((SELECT COUNT(1) FROM [dbo].[TB_T_PR_ITEM] WHERE [PROCESS_ID] = @PROCESS_ID) > 0) AND ISNULL(@@BUDGET_REF, '') = '')
		--SET @@BUDGET_REF = (SELECT TOP 1 BUDGET_REF FROM [dbo].[TB_T_PR_ITEM] WHERE [PROCESS_ID] = @PROCESS_ID AND [ORI_CURR_CD] = 'IDR')
		IF (((SELECT COUNT(1) FROM [dbo].[TB_T_PR_ITEM] WHERE [PROCESS_ID] = @PROCESS_ID) = 0) AND ISNULL(@@BUDGET_REF, '') = '')
			SET @@BUDGET_REF = '001'
		ELSE IF (((SELECT COUNT(1) FROM [dbo].[TB_T_PR_ITEM] WHERE [PROCESS_ID] = @PROCESS_ID) > 0) AND ISNULL(@@BUDGET_REF, '') <> '')
			SET @@BUDGET_REF = @@BUDGET_REF
		ELSE BEGIN
			SET @@BUDGET_REF = (SELECT MAX(BUDGET_REF) FROM [dbo].[TB_T_PR_ITEM] WHERE [PROCESS_ID] = @PROCESS_ID)
			SET @@BUDGET_REF = (SELECT 
									CASE 
										WHEN CAST(@@BUDGET_REF AS INT)+1 > 99 THEN CAST(CAST(@@BUDGET_REF AS INT)+1 AS VARCHAR)
										WHEN CAST(@@BUDGET_REF AS INT)+1 <= 99 AND CAST(@@BUDGET_REF AS INT)+1 > 9 THEN '0' + CAST(CAST(@@BUDGET_REF AS INT)+1 AS VARCHAR)
										WHEN CAST(@@BUDGET_REF AS INT)+1 <= 9 THEN '00' + CAST(CAST(@@BUDGET_REF AS INT)+1 AS VARCHAR)
									END)
		END

	SELECT @@LOCAL_CURR = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'LOCAL_CURR_CD'
	IF(@@EXIST_ITEM = 0)
	BEGIN
		SELECT @@CHILD_EXIST = COUNT(*) FROM TB_T_PR_SUBITEM WHERE PROCESS_ID = @PROCESS_ID AND ITEM_NO = '0'
		IF(@ITEM_CLASS = 'S')
		BEGIN
			IF(@@CHILD_EXIST > 0)
			BEGIN
				SET @@IS_PARENT = 'Y'
			END
			ELSE
			BEGIN
				SET @@MESSAGE = 'Item with class Service Should have at least one sub-item'
				RAISERROR(@@MESSAGE, 16, 1)
			END
		END
		ELSE
		BEGIN
			IF(@ITEM_CLASS = 'M')
			BEGIN
				SELECT @@COMPLETION = CASE WHEN(@PRICE = 0) THEN 'N' ELSE 'Y' END
				IF(@@COMPLETION = 'Y')
				BEGIN
					SELECT @@COMPLETION = CASE WHEN(ISNULL(@WBS_NO, '') = '' OR ISNULL(@WBS_NO, 'X') = 'X') THEN 'N' ELSE 'Y' END
				END
			END
			SET @@IS_PARENT = 'N'
		END
		
		
		
		INSERT INTO [dbo].[TB_T_PR_ITEM]
			   ([PROCESS_ID]
			   ,[ITEM_NO]
			   ,[ITEM_TYPE]
			   ,[IS_PARENT]
			   ,[PROCUREMENT_PURPOSE]
			   ,[MAT_NO]
			   ,[MAT_DESC]
			   ,[COST_CENTER_CD]
			   ,[WBS_NO]
			   ,[WBS_NAME]
			   ,[GL_ACCOUNT]
			   ,[VALUATION_CLASS]
			   ,[VALUATION_CLASS_DESC]
			   ,[SOURCE_TYPE]
			   ,[PACKING_TYPE]
			   ,[PART_COLOR_SFX]
			   ,[SPECIAL_PROC_TYPE]
			   ,[CAR_FAMILY_CD]
			   ,[MAT_TYPE_CD]
			   ,[MAT_GRP_CD]
			   ,[ORI_ITEM_QTY]
			   ,[NEW_ITEM_QTY]
			   ,[ITEM_UOM]
			   ,[ORI_CURR_CD]
			   ,[ORI_PRICE_PER_UOM]
			   ,[NEW_PRICE_PER_UOM]
			   ,[ORI_AMOUNT]
			   ,[NEW_AMOUNT]
			   ,[LOCAL_CURR_CD]
			   ,[EXCHANGE_RATE]
			   ,[ORI_LOCAL_AMOUNT]
			   ,[NEW_LOCAL_AMOUNT]
			   ,[DELIVERY_PLAN_DT]
			   ,[VENDOR_CD]
			   ,[VENDOR_NAME]
			   ,[QUOTA_FLAG]
			   ,[ASSET_CATEGORY]
			   ,[ASSET_CLASS]
			   ,[ASSET_LOCATION]
			   ,[ASSET_NO]
			   ,[NEW_FLAG]
			   ,[UPDATE_FLAG]
			   ,[DELETE_FLAG]
			   ,[CREATED_BY]
			   ,[CREATED_DT]
			   ,[ITEM_CLASS]
			   ,[ITEM_CLASS_DESC]
			   ,[RELEASE_FLAG]
			   ,[PR_NEXT_STATUS]
			   ,[COMPLETION]
			   ,[OPEN_QTY]
			   ,[USED_QTY]
			   ,[BUDGET_REF])
		 VALUES
			   (@PROCESS_ID
			   ,@ITEM_NO
			   ,@ITEM_TYPE
			   ,@@IS_PARENT
			   ,'' -- procurement purpose
			   ,@MAT_NO
			   --,RTRIM(LTRIM(@MAT_DESC))
			   ,LTRIM(RTRIM((REPLACE(@MAT_DESC, SUBSTRING(@MAT_DESC, PATINDEX('%[^a-zA-Z0-9 '''''']%', @MAT_DESC), 1), ''))))
			   ,@COST_CENTER_CD
			   ,@WBS_NO
			   ,@WBS_NAME
			   ,@GL_ACCOUNT
			   ,@VALUATION_CLASS
			   ,@VALUATION_CLASS_DESC
			   ,'' --<SOURCE_TYPE, varchar(10),>
			   ,'' --<PACKING_TYPE, varchar(3),>
			   ,'' --<PART_COLOR_SFX, varchar(2),>
			   ,'' --<SPECIAL_PROC_TYPE, varchar(2),>
			   ,@CAR_FAMILY_CD
			   ,@MAT_TYPE_CD
			   ,@MAT_GRP_CD
			   ,0
			   ,@QTY
			   ,@UOM
			   ,@CURR 
			   ,0
			   ,@PRICE
			   ,0
			   ,(@QTY * @PRICE * @@CALC_VALUE) 
			   ,@@LOCAL_CURR
			   ,@@EXCHANGE_RATE
			   ,(0 * @@EXCHANGE_RATE)
			   ,(@QTY * @PRICE * @@EXCHANGE_RATE  * @@CALC_VALUE)
			   ,@DELIVERY_DATE_ITEM
			   ,@VENDOR_CD
			   ,@VENDOR_NAME
			   ,@QUOTA_FLAG
			   ,@ASSET_CATEGORY
			   ,@ASSET_CLASS
			   ,@ASSET_LOCATION
			   ,@ASSET_NO
			   ,'Y'
			   ,'N'
			   ,'N'
			   ,@USERID
			   ,GETDATE()
			   ,@ITEM_CLASS
			   ,@ITEM_CLASS_DESC
			   ,'N'
			   ,'11'
			   ,@@COMPLETION
			   ,0  --Open Qty
			   ,0
			   ,@@BUDGET_REF) --Used Qty

		IF(@ITEM_CLASS = 'S')
		BEGIN
			IF(@@CHILD_EXIST > 0)
			BEGIN
				UPDATE TB_T_PR_SUBITEM 
						SET ITEM_NO = @ITEM_NO,
							NEW_LOCAL_AMOUNT = (NEW_AMOUNT * @@EXCHANGE_RATE)
					WHERE PROCESS_ID = @PROCESS_ID
						AND ITEM_NO = '0'
			END
		END
	END
	ELSE
	BEGIN
		SELECT @@CHILD_EXIST = COUNT(*) FROM TB_T_PR_SUBITEM WHERE PROCESS_ID = @PROCESS_ID AND ITEM_NO = @ITEM_NO
		IF(@ITEM_CLASS = 'S')
		BEGIN
			IF(@@CHILD_EXIST > 0)
			BEGIN
				SET @@IS_PARENT = 'Y'
			END
			ELSE
			BEGIN
				SET @@MESSAGE = 'Item with class Service Should have at least one sub-item'
				RAISERROR(@@MESSAGE, 16, 1)
			END
		END
		ELSE
		BEGIN
			IF(@ITEM_CLASS = 'M')
			BEGIN
				SELECT @@COMPLETION = CASE WHEN(@PRICE = 0) THEN 'N' ELSE 'Y' END
				IF(@@COMPLETION = 'Y')
				BEGIN
					SELECT @@COMPLETION = CASE WHEN(ISNULL(@WBS_NO, '') = '' OR ISNULL(@WBS_NO, 'X') = 'X') THEN 'N' ELSE 'Y' END
				END
			END
			SET @@IS_PARENT = 'N'
		END

		IF(@ASSET_CATEGORY <> 'X') --If not save for Routine Master
		BEGIN
			SELECT @@IS_LOCKED = COUNT(1) FROM TB_R_PR_ITEM PRI JOIN TB_R_PR_H PRH 
				ON PRI.PR_NO = PRH.PR_NO AND PRH.PROCESS_ID = @PROCESS_ID AND PRI.PR_ITEM_NO = @ITEM_NO AND ((ISNULL(PRI.PROCESS_ID, '') <> '') AND (ISNULL(PRI.PROCESS_ID, '') <> @PROCESS_ID))
			IF(@@IS_LOCKED > 0)
			BEGIN
				SET @@MESSAGE = 'WRN|Cannot edit this item. Item is locked by other user.'
				RAISERROR(@@MESSAGE, 16, 1)
			END
			ELSE
			BEGIN
				UPDATE PRI SET PROCESS_ID = @PROCESS_ID FROM TB_R_PR_ITEM PRI JOIN TB_R_PR_H PRH ON PRI.PR_NO = PRH.PR_NO AND PRI.PR_ITEM_NO = @ITEM_NO
					AND PRH.PROCESS_ID = @PROCESS_ID
			END

			--Note : Edit Quantity Checking
			SELECT @@OLD_QTY = ORI_ITEM_QTY FROM TB_T_PR_ITEM WHERE PROCESS_ID = @PROCESS_ID AND ITEM_NO = @ITEM_NO
			IF(ISNULL(@@OLD_QTY, 0) <> 0)
			BEGIN
				--1. If new_qty > old_qty
				IF(@QTY > @@OLD_QTY)
				BEGIN
					SELECT @@TEMP_CHECK = COUNT(1) FROM TB_T_PR_ITEM WHERE PROCESS_ID = @PROCESS_ID AND ITEM_NO = @ITEM_NO AND ISNULL(USED_QTY, 0) > 0
					IF(@@TEMP_CHECK > 0)
					BEGIN
						SELECT @@OLD_QTY = OPEN_QTY FROM TB_T_PR_ITEM WHERE PROCESS_ID = @PROCESS_ID AND ITEM_NO = @ITEM_NO
						SET @@MESSAGE = '<p>Cannot change quantity into value that greater than available quantity.</p><p>Available quantity is ' + CAST(@@OLD_QTY AS VARCHAR) + ' ' + @UOM + '.</p>'
						RAISERROR(@@MESSAGE, 16, 1)
					END
					ELSE
					BEGIN
						SET @@DIFF_QTY = CAST(@QTY AS DECIMAL(7, 2)) - @@OLD_QTY
					END
				END
				ELSE
				BEGIN
					--2. Compare WBS. Is new WBS similar with the old one?
					SELECT @@TEMP_CHECK = COUNT(1) FROM TB_R_PR_ITEM WHERE PROCESS_ID = @PROCESS_ID AND PR_ITEM_NO = @ITEM_NO AND WBS_NO <> @WBS_NO
					IF(@@TEMP_CHECK > 0)
					BEGIN
						SELECT @@TEMP_CHECK = COUNT(1) FROM TB_T_PR_ITEM WHERE PROCESS_ID = @PROCESS_ID AND ITEM_NO = @ITEM_NO AND ISNULL(USED_QTY, 0) > 0
						IF(@@TEMP_CHECK > 0)
						BEGIN
							SET @@MESSAGE = '<p>Cannot change WBS No. Some quantity of this item already used by Purchase Order</p>'
							RAISERROR(@@MESSAGE, 16, 1)
						END
					END

					--3. Compare is qty - new_qty <= open_qty
					SELECT @@TEMP_CHECK = COUNT(1) FROM TB_R_PR_ITEM WHERE PROCESS_ID = @PROCESS_ID AND PR_ITEM_NO = @ITEM_NO AND (PR_QTY - @QTY) > OPEN_QTY AND OPEN_QTY > 0 AND USED_QTY > 0
					IF(@@TEMP_CHECK > 0)
					BEGIN
						SELECT @@OLD_QTY = OPEN_QTY FROM TB_T_PR_ITEM WHERE PROCESS_ID = @PROCESS_ID AND ITEM_NO = @ITEM_NO
						SET @@MESSAGE = '<p>Cannot reduce quantity until less than zero.</p><p>Current available quantity is ' + CAST(@@OLD_QTY AS VARCHAR(5)) + ' ' + @UOM + '.</p>'
						RAISERROR(@@MESSAGE, 16, 1)
					END
					ELSE
					BEGIN
						SELECT @@DIFF_QTY = (PR_QTY - @QTY) FROM TB_R_PR_ITEM WHERE PROCESS_ID = @PROCESS_ID AND PR_ITEM_NO = @ITEM_NO
					END
				END
			END
		END

		UPDATE TB_T_PR_ITEM
			SET ITEM_TYPE = @ITEM_TYPE,
			    MAT_NO = @MAT_NO,
				MAT_DESC = @MAT_DESC,
				COST_CENTER_CD = @COST_CENTER_CD,
				WBS_NO = @WBS_NO,
				WBS_NAME = @WBS_NAME,
				GL_ACCOUNT = @GL_ACCOUNT,
				ITEM_CLASS = @ITEM_CLASS,
				ITEM_CLASS_DESC = @ITEM_CLASS_DESC,
				VALUATION_CLASS = @VALUATION_CLASS,
				VALUATION_CLASS_DESC = @VALUATION_CLASS_DESC,
				CAR_FAMILY_CD = @CAR_FAMILY_CD,
				MAT_TYPE_CD = @MAT_TYPE_CD,
				MAT_GRP_CD = @MAT_GRP_CD,
				NEW_ITEM_QTY = @QTY,
				ITEM_UOM = @UOM,
				ORI_CURR_CD = @CURR, 
				NEW_PRICE_PER_UOM = @PRICE,
			    NEW_AMOUNT = (@QTY * @PRICE * @@CALC_VALUE),
				EXCHANGE_RATE = @@EXCHANGE_RATE,
				NEW_LOCAL_AMOUNT = (@QTY * @PRICE * @@EXCHANGE_RATE * @@CALC_VALUE),
				
				DELIVERY_PLAN_DT = @DELIVERY_DATE_ITEM,
			    VENDOR_CD = @VENDOR_CD,
			    VENDOR_NAME = @VENDOR_NAME,
			    QUOTA_FLAG = @QUOTA_FLAG,
				ASSET_CATEGORY = @ASSET_CATEGORY,
				ASSET_CLASS = @ASSET_CLASS,
				ASSET_LOCATION = @ASSET_LOCATION,
				ASSET_NO = @ASSET_NO,
				UPDATE_FLAG = 'Y',
				CHANGED_BY = @USERID,
				CHANGED_DT = GETDATE(),
				COMPLETION = @@COMPLETION,
				OPEN_QTY = CASE WHEN (USED_QTY > 0 OR (OPEN_QTY > 0 AND OPEN_QTY >= @@DIFF_QTY)) --if already used by po or already released
									THEN OPEN_QTY - @@DIFF_QTY 
								ELSE( 
								CASE WHEN (NEW_FLAG = 'N' AND USED_QTY = 0) 
									THEN @QTY
								ELSE 0 END
								)
						   END,
				BUDGET_REF = @@BUDGET_REF
			WHERE ITEM_NO = @ITEM_NO AND PROCESS_ID = @PROCESS_ID
	END

	SELECT @@CHILD_EXIST = COUNT(*) FROM TB_T_PR_SUBITEM WHERE PROCESS_ID = @PROCESS_ID AND ITEM_NO = @ITEM_NO AND ISNULL(DELETE_FLAG, 'N') <> 'Y'
	IF(@@CHILD_EXIST > 0)
	BEGIN
		SELECT @@TOTAL_AMOUNT = SUM(NEW_AMOUNT) FROM TB_T_PR_SUBITEM WHERE PROCESS_ID = @PROCESS_ID AND ITEM_NO = @ITEM_NO AND ISNULL(DELETE_FLAG, 'N') <> 'Y'
		SELECT @@TOTAL_LOCAL_AMOUNT = SUM(NEW_LOCAL_AMOUNT) FROM TB_T_PR_SUBITEM WHERE PROCESS_ID = @PROCESS_ID AND ITEM_NO = @ITEM_NO AND ISNULL(DELETE_FLAG, 'N') <> 'Y'

		UPDATE TB_T_PR_ITEM 
			SET NEW_AMOUNT = @@TOTAL_AMOUNT, NEW_LOCAL_AMOUNT = @@TOTAL_LOCAL_AMOUNT
			WHERE PROCESS_ID = @PROCESS_ID AND ITEM_NO = @ITEM_NO
		SET @@MSG = 'Smaller than / Equal Previous Amount. New Amount : ' + CAST(@@TOTAL_AMOUNT AS VARCHAR) + ' Last Amount : ' + CAST(@@TOTAL_LOCAL_AMOUNT AS VARCHAR)
								SET @@MSG_ID = 'MSG0000045'
								EXEC dbo.sp_PutLog @@MSG, 'YHS', 'Validate Amount', @PROCESS_ID , @@MSG_ID, 'INF', '5', '22', 1;

		IF(@ITEM_CLASS = 'S')
		BEGIN
			UPDATE PRI1 
			SET NEW_PRICE_PER_UOM = PRI2.NEW_AMOUNT
			FROM TB_T_PR_ITEM PRI1 JOIN TB_T_PR_ITEM PRI2 ON PRI1.PROCESS_ID = @PROCESS_ID AND PRI1.ITEM_NO = @ITEM_NO AND PRI1.PROCESS_ID = PRI2.PROCESS_ID AND PRI1.ITEM_NO = PRI2.ITEM_NO
		END
	END

	COMMIT TRANSACTION
	SELECT 'SUCCESS|'
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	SELECT CASE WHEN (SUBSTRING(ERROR_MESSAGE(), 1, 3) <> 'WRN') THEN 'ERR|' ELSE '' END + ERROR_MESSAGE()
END CATCH