/****** Object:  StoredProcedure [dbo].[sp_JobPOCreation_GetCondition]    Script Date: 1/5/2016 3:06:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		FID.Intan Puspitasari
-- Create date: 23/12/2015
-- Description:	Get PO Condition for Data PO from other System (Called by Job SQL)
-- =============================================
ALTER PROCEDURE [dbo].[sp_JobPOCreation_GetCondition]
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6)
AS
BEGIN
    DECLARE
		@exist INT = 0,
		@counter INT = 0,
		@valClass VARCHAR(4),
		@calcCount INT = 0,
		@itemNo INT,
		@systemSource VARCHAR(11),
		@PONo VARCHAR(11),
		@compPrice VARCHAR(4),
		@basePrice DECIMAL(18,4), 
		@itemQty DECIMAL(9,4),
		@exchangeRate DECIMAL(9, 4),
		@currency VARCHAR(3),
		@calculationRef CALC_COMP_PRICE,
		@calculationRes CALC_COMP_PRICE,

		@user VARCHAR(20) = 'SYSTEM',
        @message VARCHAR(MAX) = '',
        @actionName VARCHAR(50) = 'Get PO Condition',
        @tmpLog LOG_TEMP
    
	SET NOCOUNT ON

	BEGIN TRAN AddItemTemp   
	
	BEGIN TRY
		SET @message = 'Get PO Condition Process Started'
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 1, @user)
	 
		DECLARE item_cursor CURSOR FOR
			SELECT B.SYSTEM_SOURCE,
				   A.REF_PO_NO, 
				   A.REF_PO_ITEM, 
				   A.VALUATION_CLASS,
				   A.PRICE_PER_UOM,
				   A.PO_QTY_ORI,
				   A.CURR_CD
			FROM TB_T_INPUT_PO_ITEM A 
			INNER JOIN TB_T_INPUT_PO_H B ON A.REF_PO_NO = B.REF_PO_NO AND B.PROCESS_ID = @processId ORDER BY A.REF_PO_ITEM ASC 
		OPEN item_cursor
		FETCH NEXT FROM item_cursor INTO @systemSource, @PONo, @itemNo, @valClass, @basePrice, @itemQty, @currency
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @exist = COUNT(1) FROM TB_T_INPUT_PO_CONDITION WHERE REF_PO_NO = @PONo AND REF_PO_ITEM = @itemNo --change it into new table
				IF(@exist = 0)
				BEGIN
					SET @message = 'Calculating PO Condition Price Amount for PO_NO: ' + @poNo + ' and PO_ITEM_NO: ' + CAST(@itemNo AS VARCHAR) + ' Started'
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)

					DECLARE @currencyRate TABLE 
						(  
							CurrencyCode VARCHAR(3), 
							ExchangeRate DECIMAL(7,2), 
							ValidFrom DATETIME, 
							ValidTo DATETIME 
						)
					INSERT INTO @currencyRate EXEC sp_Currency_GetCurrency @currency
					SET @message = 'Bug - Currently applicable currency rate of ''' + ISNULL(@currency, '') + ''' is duplicate'
					IF (SELECT COUNT(0) FROM @currencyRate) > 1 BEGIN RAISERROR(@message, 16, 1) END
					SELECT @exchangeRate = ExchangeRate FROM @currencyRate
					DELETE FROM @currencyRate

					/** GET DATA CONDITION **/
					DECLARE @calcScheme VARCHAR(4)
					SELECT @calcScheme = valc.CALCULATION_SCHEME_CD
					FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) DATA_NO, * FROM TB_T_INPUT_PO_ITEM WHERE REF_PO_NO = @poNo) item
					JOIN TB_M_VALUATION_CLASS valc ON item.VALUATION_CLASS = valc.VALUATION_CLASS
					WHERE item.DATA_NO = @itemNo

					DELETE FROM @calculationRef
					INSERT INTO @calculationRef
					SELECT *
					FROM (
						SELECT SEQ_NO SeqNo, CONDITION_CATEGORY Category, CALCULATION_TYPE CalcType, COMP_PRICE_CD CompPriceCode, 
							BASE_VALUE_FROM BaseFrom, BASE_VALUE_TO BaseTo, PLUS_MINUS_FLAG PlusMinus, @basePrice Rate, ACCRUAL_FLAG_TYPE AccrualType,
							CONDITION_RULE ConditionRule, 'M' CompType, @itemQty Qty, (CASE QTY_PER_UOM WHEN 'N' THEN 1 ELSE CAST(QTY_PER_UOM AS INT) END) QtyPerUOM, 0 Price
						FROM TB_M_CALCULATION_MAPPING WHERE CALCULATION_SCHEME_CD = @calcScheme AND CONDITION_CATEGORY = 'H' AND COMP_PRICE_CD = 'PB00'
						UNION
						SELECT calcm.SEQ_NO SeqNo, calcm.CONDITION_CATEGORY Category, calcm.CALCULATION_TYPE CalcType, calcm.COMP_PRICE_CD CompPriceCode,
							calcm.BASE_VALUE_FROM BaseFrom, calcm.BASE_VALUE_TO BaseTo, calcm.PLUS_MINUS_FLAG PlusMinus, cmppr.COMP_PRICE_RATE Rate,
							calcm.ACCRUAL_FLAG_TYPE AccrualType, calcm.CONDITION_RULE ConditionRule, 'M' CompType, @itemQty Qty,
							(CASE QTY_PER_UOM WHEN 'N' THEN 1 ELSE CAST(QTY_PER_UOM AS INT) END) QtyPerUOM, 0 Price
						FROM TB_M_CALCULATION_MAPPING calcm
						JOIN TB_M_COMP_PRICE_RATE cmppr ON calcm.COMP_PRICE_CD = cmppr.COMP_PRICE_CD
						WHERE calcm.CALCULATION_SCHEME_CD = @calcScheme AND calcm.CONDITION_CATEGORY = 'D' AND calcm.COMP_PRICE_CD = 'PB00'
						/*UNION
						SELECT podt.SEQ_NO SeqNo, podt.CONDITION_CATEGORY Category, podt.CALCULATION_TYPE CalcType, podt.COMP_PRICE_CD CompPriceCode,
							podt.BASE_VALUE_FROM BaseFrom, podt.BASE_VALUE_TO BaseTo, podt.PLUS_MINUS_FLAG PlusMinus, podt.COMP_PRICE_RATE Rate,
							podt.ACCRUAL_FLAG_TYPE AccrualType, podt.CONDITION_RULE ConditionRule, 'S' CompType, @itemQty Qty, QTY_PER_UOM QtyPerUOM, 0 Price
						FROM TB_T_INPUT_PO_CONDITION podt
						LEFT JOIN TB_M_COMP_PRICE cmpp ON podt.COMP_PRICE_CD = cmpp.COMP_PRICE_CD
						LEFT JOIN TB_M_COMP_PRICE_RATE cmppr ON cmpp.COMP_PRICE_CD = cmppr.COMP_PRICE_CD
						WHERE podt.REF_PO_NO = @poNo AND podt.REF_PO_ITEM = @itemNo*/
					) tmp
					/** END OF GET DATA CONDITION **/

					/** DELETE TEMP CONDITION **/
					SET @message = 'Clean calculation temp data Started'
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)

					DELETE FROM TB_T_INPUT_PO_CONDITION WHERE REF_PO_NO = @poNo AND REF_PO_ITEM = @itemNo

					SET @message = 'Clean calculation temp data Finished'
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)
					/** END OF DELETE TEMP CONDITION **/

					SELECT @counter = 0
					SELECT @calcCount = COUNT(1) FROM @calculationRef
					WHILE (@counter < @calcCount)
					BEGIN
						DELETE FROM @calculationRes
						INSERT INTO @calculationRes
						SELECT
						cr.SeqNo, cr.Category, cr.CalcType, cr.CompPriceCode, cr.BaseFrom, cr.BaseTo,
						cr.PlusMinus, cr.Rate, cr.AccrualType, cr.ConditionRule, cr.CompType, cr.Qty, cr.QtyPerUOM,
						CASE
							WHEN cr.Category = 'H' THEN
								CASE WHEN cr.PlusMinus = 1 THEN cr.Rate
								ELSE cr.Rate * -1
								END
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
										CASE WHEN cr.PlusMinus = 1 THEN (cr.Rate/100) * (SELECT SUM(cri.Price) FROM @calculationRes cri WHERE cri.SeqNo BETWEEN cr.BaseFrom AND ISNULL(cr.BaseTo, cr.BaseFrom))
										ELSE ((cr.Rate/100) * (SELECT SUM(cri.Price) FROM @calculationRes cri WHERE cri.SeqNo BETWEEN cr.BaseFrom AND ISNULL(cr.BaseTo, cr.BaseFrom))) * -1
										END
									WHEN 4 THEN -- Summary
										CASE WHEN cr.PlusMinus = 1 THEN (SELECT SUM(cri.Price) FROM @calculationRes cri WHERE cri.SeqNo BETWEEN cr.BaseFrom AND ISNULL(cr.BaseTo, cr.BaseFrom))
										ELSE (SELECT SUM(cri.Price) FROM @calculationRes cri WHERE cri.SeqNo BETWEEN cr.BaseFrom AND ISNULL(cr.BaseTo, cr.BaseFrom)) * -1
										END
								END
						END Price
						FROM @calculationRef cr WHERE cr.SeqNo = (@counter + 1)

						SET @message = 'Insert Data PO Condition for PO_NO: ' + @poNo + ' and PO_ITEM_NO: ' + CAST(@itemNo AS VARCHAR) + ' and COMP_PRICE_CD: ' + (SELECT CompPriceCode FROM @calculationRef WHERE SeqNo = (@counter + 1)) + ' Started'
						INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)

						INSERT INTO TB_T_INPUT_PO_CONDITION
									([SYSTEM_SOURCE]
									,[REF_PO_NO]
									,[REF_PO_ITEM]
									,[COMP_PRICE_CD]
									,[COMP_PRICE_RATE]
									,[INVOICE_FLAG]
									,[EXCHANGE_RATE]
									,[SEQ_NO]
									,[BASE_VALUE_FROM]
									,[BASE_VALUE_TO]
									,[PO_CURR]
									,[INVENTORY_FLAG]
									,[CALCULATION_TYPE]
									,[PLUS_MINUS_FLAG]
									,[CONDITION_CATEGORY]
									,[ACCRUAL_FLAG_TYPE]
									,[CONDITION_RULE]
									,[PRICE_AMT]
									,[QTY]
									,[QTY_PER_UOM]
									,[COMP_TYPE]
									,[PRINT_STATUS]
									,[CREATED_BY]
									,[CREATED_DT]
									,[CHANGED_BY]
									,[CHANGED_DT])
							 SELECT @systemSource
									,@PONo 
									,@itemNo
									,CompPriceCode
									,Rate
									,'N'
									,@exchangeRate
									,(@counter + 1)
									,BaseFrom
									,BaseTo
									,@currency
									,'N'
									,CalcType
									,1
									,'D'
									,'Y'
									,'V'
									,Price * (Qty / QtyPerUOM)
									,Qty
									,QtyPerUOM
									,CompType
									,'N' 
									,@user
									,GETDATE()
									,NULL
									,NULL
							FROM @calculationRes WHERE SeqNo = (@counter + 1)

						SET @message = 'Insert Data PO Condition for PO_NO: ' + @poNo + ' and PO_ITEM_NO: ' + CAST(@itemNo AS VARCHAR) + ' and COMP_PRICE_CD: ' + (SELECT CompPriceCode FROM @calculationRef WHERE SeqNo = (@counter + 1)) + ' Finished'
						INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @user)

						SET @counter = @counter + 1
					END
				END
			FETCH NEXT FROM item_cursor INTO @systemSource, @PONo, @itemNo, @valClass, @basePrice, @itemQty, @currency
			END
		CLOSE item_cursor
		DEALLOCATE item_cursor
	
		SET @message = 'Get PO Condition Process Finished'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @user)

		COMMIT TRAN AddItemTemp
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN AddItemTemp
        SET @message = 'Get PO Condition Process Ended with Error : ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @user)
	
		IF CURSOR_STATUS('global','item_cursor') >= -1  
		BEGIN  
		   DEALLOCATE item_cursor  
		END
	END CATCH
    
    EXEC sp_PutLog_Temp @tmpLog
    SET NOCOUNT OFF
END