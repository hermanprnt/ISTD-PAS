/****** Object:  StoredProcedure [dbo].[sp_POInquiry_RejectByVendor]    Script Date: 9/27/2017 9:33:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_POInquiry_RejectByVendor]
    @currentUser VARCHAR(50),
    @poNo VARCHAR(11),
	@poItem VARCHAR(500)
AS
BEGIN
	SET @poItem = ISNULL(@poItem,'')
    DECLARE
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = 'sp_POInquiry_RejectByVendor',
        @tmpLog LOG_TEMP,
		@processId bigint,
		@moduleId VARCHAR(3) = '3',
		@functionId VARCHAR(6) = '302001',
		@RELATED_PROCESS_ID bigint
		
	DECLARE @vendor_order VARCHAR(6) ,
			@system_source VARCHAR(30),
			@PO_STATUS VARCHAR(5),
			@old_doc_pr VARCHAR(23)

	DECLARE @relatedProcessTable AS TABLE
	(
		PROCESS_ID bigint
	)

	DECLARE @budgetTransactTemp TABLE
    (
        DataNo INT IDENTITY(1, 1), WBSNo VARCHAR(30), RefDocNo VARCHAR(15),
        NewDocNo VARCHAR(15), Currency VARCHAR(3), TotalAmount DECIMAL(18, 6),
        MaterialNo VARCHAR(30), DocDesc VARCHAR(MAX), BmsOperation VARCHAR(50)
    )

    SET NOCOUNT ON
    BEGIN TRY
        EXEC dbo.sp_PutLog 'Process PO Reject By Vendor starting', @currentUser, @actionName, @processId OUTPUT, 'MSG0000001', 'INF', @moduleId, @functionId, 0

        BEGIN TRAN

		DECLARE @poitemlist as TABLE(
			PO_NO VARCHAR(10),
			PO_ITEM VARCHAR(5)
		)

		DECLARE @poitemlist_notchanged as TABLE(
			PO_NO VARCHAR(10),
			PO_ITEM VARCHAR(5)
		)

		IF(LEN(@poItem)>0)
		BEGIN
			INSERT INTO @poitemlist
			SELECT PO.PO_NO,  LTRIM(RTRIM(splitdata)) 
			FROm dbo.fnSplitString(@poItem, ',')
			CROSS JOIN (SELECT @poNo PO_NO) AS PO
		END
		ELSE
		BEGIN
			INSERT INTO @poitemlist
			SELECT PO_NO, PO_ITEM_NO 
			FROm TB_R_PO_ITEM WHERE PO_NO = @poNo
		END

		INSERT INTO @poitemlist_notchanged
		SELECT POI.PO_NO, POI.PO_ITEM_NO 
		FROm TB_R_PO_ITEM POI WHERE NOT EXISTS(SELECT 1 FROM @poitemlist a WHERE a.PO_NO = POI.PO_NO AND a.PO_ITEM = poi.PO_ITEM_NO) AND PO_NO = @poNo

		SELECT @vendor_order = VENDOR_CD, @system_source = SYSTEM_SOURCE, @PO_STATUS = PO_STATUS  FROm TB_R_PO_H WHERE PO_NO = @poNo
		SELECT TOP 1 @old_doc_pr = PR_NO FROm TB_R_PR_ITEM WHERE PO_NO = @poNo

		IF (RTRIM(LTRIM(@system_source))<>'ECatalogue')
		BEGIN
			RAISERROR('Unable to Reject Order, This Feature only available for ECatalogue only',16,1)
		END

		IF (@PO_STATUS <> '44')
		BEGIN
			RAISERROR('Reject PO only allowed for release document.!',16,1)
		END

		SET @message = 'Save last Vendor Code for PO_NO ' + @poNo + ' and item '+ ISNULL(@poItem,'')+':start'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000002', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

		INSERT INTO TB_H_PO_REJECT_VENDOR (PO_NO, PO_ITEM_NO, VENDOR_CD, CREATED_BY, CREATED_DT)
		select PO_NO, PO_ITEM, @vendor_order, @currentUser, GETDATE() from @poitemlist

		SET @message = 'Save last Vendor Code for PO_NO ' + @poNo +' and item '+ ISNULL(@poItem,'')+':end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000003', 'SUC', @message, @moduleId, @actionName, @functionId, 1, @currentUser)


		--SET @message = 'reject Old PO no ' + @poNo + ': begin'
  --      INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000004', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

		----exec dbo.sp_POInquiry_Cancel @currentUser, @processId, @moduleId, @functionId, @poNo, '45' -- 45 : Reject By Vendor

		--SET @message = 'reject Old PO no ' + @poNo + ': end'
  --      INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000005', 'SUC', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

		DECLARE @availVendor as TABLE(
			Number int identity(1,1),
			MAT_NO VARCHAR(23),
			VENDOR_CD VARCHAR(6),
			VENDOR_NAME VARCHAR(50),
			PR_COORDINATOR VARCHAR(20),
			PROC_CHANNEL_CD VARCHAR(4)
		)

		;WITH cte AS
		(
		   SELECT poi.MAT_NO, sli.VENDOR_CD, 
				 ROW_NUMBER() OVER (PARTITION BY poi.MAT_NO ORDER BY sli.VENDOR_CD DESC) AS rn
		   FROM TB_R_PO_ITEM poi
		   INNER JOIN @poitemlist item on item.PO_NO = poi.PO_NO and item.PO_ITEM = poi.PO_ITEM_NO
		   LEFT JOIN TB_M_SOURCE_LIST sli ON poi.MAT_NO = sli.MAT_NO  WHERE poi.PO_NO =@poNo AND sli.VENDOR_CD NOT IN (SELECT @vendor_order UNION ALL SELECT prv.VENDOR_CD FROm TB_H_PO_REJECT_VENDOR prv WHERE prv.PO_NO = poi.PO_NO AND prv.PO_ITEM_NO = poi.PO_ITEM_NO)
		)
		INSERT INTO @availVendor(MAT_NO, VENDOR_CD, PR_COORDINATOR)
		SELECT DISTINCT poi.MAT_NO, cte.VENDOR_CD, (SELECT TOP 1 prh.PR_COORDINATOR FROM  TB_R_PR_H prh WHERE prh.PR_NO = poi.PR_NO)
		FROM TB_R_PO_ITEM poi
		INNER JOIN @poitemlist item on item.PO_NO = poi.PO_NO and item.PO_ITEM = poi.PO_ITEM_NO
		LEFT JOIN cte ON cte.MAT_NO = poi.MAT_NO 
		WHERE ISNULL(rn,1) = 1 

		UPDATE temp SET VENDOR_NAME = v.VENDOR_NAME
		FROM @availVendor temp 
		INNER JOIN TB_M_VENDOR v ON v.VENDOR_CD = temp.VENDOR_CD

		UPDATE temp SET PROC_CHANNEL_CD = vclass.PROC_CHANNEL_CD
		FROM @availVendor temp 
		INNER JOIN TB_M_MATERIAL_NONPART mat ON mat.MAT_NO = temp.MAT_NO
		INNER JOIN TB_M_VALUATION_CLASS vclass ON vclass.VALUATION_CLASS = mat.VALUATION_CLASS and vclass.PROCUREMENT_TYPE = 'RM' AND vclass.PR_COORDINATOR = temp.PR_COORDINATOR 

		DECLARE @MAT_NO VARCHAR(23),
			@VENDOR_CD VARCHAR(6),
			@VENDOR_NAME VARCHAR(50),
			@PROC_CHANNEL_CD VARCHAR(4),
			@Number int,
			@tmpLogRelated LOG_TEMP,
			@PURCHASING_GROUP VARCHAR(3),
			@EXCHANGE_RATE decimal(12,5)


		DECLARE db_cursor_vendor CURSOR FOR  
		SELECT Number, MAT_NO, VENDOR_CD, VENDOR_NAME, PROC_CHANNEL_CD FROM @availVendor 

		OPEN db_cursor_vendor   
		FETCH NEXT FROM db_cursor_vendor INTO @Number, @MAT_NO, @VENDOR_CD, @VENDOR_NAME, @PROC_CHANNEL_CD
		WHILE @@FETCH_STATUS = 0   
		BEGIN   

			DECLARE @PR_ITEM_T AS TABLE
			(	
				PR_NO VARCHAR(10),
				PR_ITEM_NO VARCHAR(5),
				CALCSCHEME VARCHAR(4),
				BASEPRICE DECIMAL(18,4),
				BASEQTY DECIMAL(18,4)
			)

			SET @RELATED_PROCESS_ID = NULL
			BEGIN -- Clone PO Header
				SET @message = 'Insert PO Header Temp started:start'
				EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @RELATED_PROCESS_ID OUTPUT, 'MSG0000006', 'INF', @moduleId, @functionId, 1;
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000006', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

				SET @message = 'Related Process Id '+ CONVERT(VARCHAR, @RELATED_PROCESS_ID)
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000007', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

				INSERT INTO @relatedProcessTable VALUES (@RELATED_PROCESS_ID)

				SET @message = 'Clone PO Header for PO_NO ' + @poNo + ': begin'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000008', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)


				INSERT INTO TB_T_PO_H
				(PROCESS_ID, PO_DESC, DOC_DT, 
				VENDOR_CD, VENDOR_NAME, PROC_CHANNEL_CD, PURCHASING_GRP_CD, ORI_CURR_CD, ORI_EXCHANGE_RATE, ORI_AMOUNT,
				NEW_CURR_CD, NEW_EXCHANGE_RATE, NEW_AMOUNT, ORI_LOCAL_AMOUNT, NEW_LOCAL_AMOUNT, NEW_FLAG, UPDATE_FLAG, DELETE_FLAG, PO_NO, PO_NOTE1,
				PO_NOTE2, PO_NOTE3, PO_NOTE4, PO_NOTE5, PO_NOTE6, PO_NOTE7, PO_NOTE8, PO_NOTE9, PO_NOTE10, VENDOR_ADDRESS, POSTAL_CODE, CITY, ATTENTION,
				PHONE, FAX, COUNTRY, DELIVERY_ADDR, DELIVERY_NAME, DELIVERY_ADDRESS, DELIVERY_POSTAL_CODE, DELIVERY_CITY, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT, OTHER_MAIL)
				SELECT @RELATED_PROCESS_ID, PO_DESC + ', PO No : ' + @poNo, DOC_DT, 
				VENDOR_CD, VENDOR_NAME, @PROC_CHANNEL_CD, PURCHASING_GRP_CD, LOCAL_CURR, PO_EXCHANGE_RATE, PO_AMOUNT,
				LOCAL_CURR, PO_EXCHANGE_RATE, PO_AMOUNT, PO_AMOUNT, PO_AMOUNT, 'Y', 'N', 'N', '', PO_NOTE1,
				PO_NOTE2, PO_NOTE3, PO_NOTE4, PO_NOTE5, PO_NOTE6, PO_NOTE7, PO_NOTE8, PO_NOTE9, PO_NOTE10, VENDOR_ADDRESS, POSTAL_CODE, CITY, ATTENTION,
				PHONE, FAX, COUNTRY, DELIVERY_ADDR, DELIVERY_NAME, DELIVERY_ADDRESS, DELIVERY_POSTAL_CODE, DELIVERY_CITY, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT, OTHER_MAIL
				FROM TB_R_PO_H WHERE PO_NO = @poNo

				SET @message = 'Clone PO Header for PO_NO ' + @poNo + ': end'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000009', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
			END

			BEGIN -- Insert PO Item
				SET @message = 'Clone PO Item for PO_NO ' + @poNo + ': start'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000010', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

				INSERT INTO @PR_ITEM_T
				select poi.PR_NO, poi.PR_ITEM_NO, valc.CALCULATION_SCHEME_CD, poi.PRICE_PER_UOM, poi.PO_QTY_ORI
				from TB_R_PO_ITEM poi 
				INNER JOIN @poitemlist item on item.PO_NO = poi.PO_NO and item.PO_ITEM = poi.PO_ITEM_NO
				JOIN TB_M_VALUATION_CLASS valc ON poi.VALUATION_CLASS = valc.VALUATION_CLASS AND PROCUREMENT_TYPE = 'RM'
				where poi.PO_NO = @poNo AND MAT_NO = @MAT_NO 

				iF ((select count(0) from @PR_ITEM_T) <= 0)
				BEGIN
					RAISERROR('PO must have at lease 1 item..!',16,1)
				END

				INSERT INTO TB_T_PO_ITEM  
				(PROCESS_ID, SEQ_ITEM_NO, PR_NO, PR_ITEM_NO, VENDOR_CD, VENDOR_NAME, QUOTATION_NO, 
				PURCHASING_GRP_CD, VALUATION_CLASS, MAT_NO, MAT_DESC, PROCUREMENT_PURPOSE, DELIVERY_PLAN_DT, 
				SOURCE_TYPE, PLANT_CD, SLOC_CD, WBS_NO, COST_CENTER_CD, UNLIMITED_FLAG, TOLERANCE_PERCENTAGE, SPECIAL_PROCUREMENT_TYPE,  
				PO_QTY_ORI, PO_QTY_USED, PO_QTY_REMAIN, UOM, CURR_CD, ORI_AMOUNT, 
				NEW_FLAG, UPDATE_FLAG, DELETE_FLAG, PO_NO,  
				PO_ITEM_NO, URGENT_DOC, GROSS_PERCENT, ITEM_CLASS, 
				IS_PARENT, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT, WBS_NAME,  
				GL_ACCOUNT, PO_QTY_NEW, ORI_PRICE_PER_UOM, NEW_PRICE_PER_UOM, NEW_AMOUNT, 
				ORI_LOCAL_AMOUNT, NEW_LOCAL_AMOUNT
				)   
				SELECT @RELATED_PROCESS_ID, DENSE_RANK() OVER (partition BY @RELATED_PROCESS_ID order by poi.PO_NO, poi.PO_ITEM_NO DESC) AS Row, poi.PR_NO, poi.PR_ITEM_NO, '' AS VENDOR_CS, '' AS VENDOR_NAME, '', 
                poh.PURCHASING_GRP_CD, poi.VALUATION_CLASS, poi.MAT_NO, poi.MAT_DESC, '', poi.DELIVERY_PLAN_DT,  
                poi.SOURCE_TYPE, poi.PLANT_CD, poi.SLOC_CD, poi.WBS_NO, poi.COST_CENTER_CD, NULL, 0, '',
				0, poi.PO_QTY_USED, poi.PO_QTY_REMAIN, poi.UOM, poh.PO_CURR, poi.PO_QTY_ORI * poi.PRICE_PER_UOM * (SELECT ISNULL(CALC_VALUE, 0) FROM TB_M_UNIT_OF_MEASURE WHERE UNIT_OF_MEASURE_CD = poi.UOM),
                'Y', 'N', 'N', '' PO_NO,  
                NULL PO_ITEM_NO, 'N', 0, (SELECT ITEM_CLASS FROM TB_M_VALUATION_CLASS WHERE VALUATION_CLASS = poi.VALUATION_CLASS AND PURCHASING_GROUP_CD = poh.PURCHASING_GRP_CD AND PROCUREMENT_TYPE = 'RM'),
                'N' isParent, @currentUser, GETDATE(), NULL, NULL, poi.WBS_NAME,  
                poi.GL_ACCOUNT, poi.PO_QTY_ORI, 0, poi.PRICE_PER_UOM, poi.PO_QTY_ORI * poi.PRICE_PER_UOM * (SELECT ISNULL(CALC_VALUE, 0) FROM TB_M_UNIT_OF_MEASURE WHERE UNIT_OF_MEASURE_CD = poi.UOM),
                0, poi.PO_QTY_ORI * poi.PRICE_PER_UOM * poh.PO_EXCHANGE_RATE * (SELECT ISNULL(CALC_VALUE, 0) FROM TB_M_UNIT_OF_MEASURE WHERE UNIT_OF_MEASURE_CD = poi.UOM)
                FROM TB_R_PO_ITEM poi 
				INNER JOIN @poitemlist item on item.PO_NO = poi.PO_NO and item.PO_ITEM = poi.PO_ITEM_NO
				INNER JOIN TB_R_PO_H poh ON poh.PO_NO = poi.PO_NO 
				WHERE poi.PO_NO = @poNo AND MAT_NO = @MAT_NO 

				SET @message = 'Clone PO Item for PO_NO ' + @poNo + ': end'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000011', 'SUC', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
			END

			BEGIN -- Insert PO Condition
				SET @message = 'Insert PO Condition for PO_NO ' + @poNo + ': start'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000012', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)


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

				--recalculate all Category and CalcType
				update cr SET Price = 
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
									CASE WHEN cr.PlusMinus = 1 THEN (cr.Rate/100) * (SELECT SUM(cri.Price) FROM @calculationRef cri WHERE cri.SeqNo BETWEEN cr.BaseFrom AND ISNULL(cr.BaseTo, cr.BaseFrom)AND cri.SeqNo < cr.SeqNo and cri.Seq_Item_No = cr.Seq_Item_No)  
									ELSE ((cr.Rate/100) * (SELECT SUM(cri.Price) FROM @calculationRef cri WHERE cri.SeqNo BETWEEN cr.BaseFrom AND ISNULL(cr.BaseTo, cr.BaseFrom)AND cri.SeqNo < cr.SeqNo and cri.Seq_Item_No = cr.Seq_Item_No)) * -1  
									END  
								WHEN 4 THEN -- Summary  
									CASE WHEN cr.PlusMinus = 1 THEN (SELECT SUM(cri.Price) FROM @calculationRef cri WHERE cri.SeqNo BETWEEN cr.BaseFrom AND ISNULL(cr.BaseTo, cr.BaseFrom)AND cri.SeqNo < cr.SeqNo and cri.Seq_Item_No = cr.Seq_Item_No)  
									ELSE (SELECT SUM(cri.Price) FROM @calculationRef cri WHERE cri.SeqNo BETWEEN cr.BaseFrom AND ISNULL(cr.BaseTo, cr.BaseFrom) AND cri.SeqNo < cr.SeqNo and cri.Seq_Item_No = cr.Seq_Item_No) * -1  
									END  
							END  
					END
				from @calculationRef cr
  
				INSERT INTO TB_T_PO_CONDITION  
				(PROCESS_ID, SEQ_ITEM_NO, PO_NO, PO_ITEM_NO, COMP_PRICE_CD, COMP_PRICE_RATE, INVOICE_FLAG, EXCHANGE_RATE, SEQ_NO, BASE_VALUE_FROM,  
				BASE_VALUE_TO, PO_CURR, INVENTORY_FLAG, CALCULATION_TYPE, PLUS_MINUS_FLAG, CONDITION_CATEGORY, ACCRUAL_FLAG_TYPE, CONDITION_RULE, PRICE_AMT, QTY,  
				QTY_PER_UOM, COMP_TYPE, PRINT_STATUS, NEW_FLAG, UPDATE_FLAG, DELETE_FLAG, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT)  
				SELECT  @RELATED_PROCESS_ID, DENSE_RANK() OVER (partition BY LEFT(seq_item_No, 10) order by RIGHT(seq_item_No, 5) DESC) AS Row, poi.PO_NO, NULL, CompPriceCode, Rate, 'N', poh.PO_EXCHANGE_RATE, SeqNo, BaseFrom, BaseTo, poh.PO_CURR, 'N', CalcType, 1,  
				'D', 'Y', 'V', Price * (Qty / QtyPerUOM), Qty, QtyPerUOM, CompType, 'N', 'Y', 'N', 'N', @currentUser, GETDATE(), NULL, NULL  
				FROM @calculationRef ref
				INNER JOIN TB_R_PO_ITEM poi on poi.PR_NO = LEFT(ref.seq_item_No, 10) AND poi.PR_ITEM_NO = RIGHT(ref.seq_item_No, 5) and poi.MAT_NO = @MAT_NO
				INNER JOIN @poitemlist item on item.PO_NO = poi.PO_NO and item.PO_ITEM = poi.PO_ITEM_NO
				INNER JOIN TB_R_PO_H poh ON poh.PO_NO = poi.PO_NO
				ORDER BY Row, SeqNo

				SET @message = 'Insert PO Condition for PO_NO ' + @poNo + ' : end'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000013', 'SUC', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

			END

			SET @message = 'Create PO Temp Data success'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000014', 'SUC', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

			BEGIN -- Copy data from temp to real table
				SET @message = 'Insert PO Data to real table started'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000015', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
				
				SELECT @PURCHASING_GROUP = PURCHASING_GRP_CD, @EXCHANGE_RATE = NEW_EXCHANGE_RATE FROm TB_T_PO_H WHERE PROCESS_ID = @RELATED_PROCESS_ID
				DECLARE @Status_Info VARCHAR(20)	
	
				exec [dbo].[sp_POCreation_Save_ECatalog]
												NULL,
												@currentUser,
												@RELATED_PROCESS_ID,
												@moduleId,
												@functionId,
												@PURCHASING_GROUP,
												@EXCHANGE_RATE,
												@tmpLogRelated,
												@isSPKCreated = 0,
												@message = @message OUTPUT,
												@Status = @Status_Info OUTPUT,
												@isDraft = 1,
												@clonePONO = @poNo

				
				--select @Status_Info, @message
				IF @Status_Info = 'FAILED'
				BEGIN
					SET @message = @message + ' - [sp_POCreation_Save_ECatalog]'
					RAISERROR(@message, 16, 1)
				END
				ELSE
				BEGIN
					SET @message = 'New PO NO : ' + @Status_Info
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000015', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
				END
					
				INSERT INTO @budgetTransactTemp (WBSNO, RefDocNo, NewDocNo, Currency, TotalAmount, MaterialNo, DocDesc, BmsOperation)
				SELECT POI.WBS_NO, POI.PO_NO+'_001', POI.PO_NO+'_001', POH.PO_CURR, SUM(POI.PO_QTY_ORI * POI.PRICE_PER_UOM), '', poh.PO_DESC, 'CANCEL_COMMIT'
					FROM TB_R_PO_ITEM POI 
					INNER JOIN TB_R_PO_H POH ON POH.PO_NO = POI.PO_NO
					WHERE POI.PO_NO = @Status_Info
				GROUP BY POI.WBS_NO, POI.PO_NO, POI.PO_NO, POH.PO_CURR, poh.PO_DESC


				  -- Clear Temp table
				IF (1 = 0)
				BEGIN
					SET @message = 'Delete data from TB_T_PO_ITEM where CREATED_BY = ' + @currentUser + ': begin'
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000019', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

					DELETE FROM TB_T_PO_H WHERE CREATED_BY = @currentUser AND PROCESS_ID = @RELATED_PROCESS_ID
					DELETE FROM TB_T_PO_ITEM WHERE CREATED_BY = @currentUser AND PROCESS_ID = @RELATED_PROCESS_ID

					SET @message = 'Delete data from TB_T_PO_ITEM where CREATED_BY = ' + @currentUser + ' : end'
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000020', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

					SET @message = 'Delete data from TB_T_PO_CONDITION where CREATED_BY = ' + @currentUser + ' : begin'
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000021', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

					DELETE FROM TB_T_PO_CONDITION WHERE CREATED_BY = @currentUser AND PROCESS_ID = @RELATED_PROCESS_ID

					SET @message = 'Delete data from TB_T_PO_CONDITION where CREATED_BY = ' + @currentUser + ' : end'
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000022', 'SUC', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
				END

				SET @message = 'Reset PROCESS_ID from TB_R_ASSET where CHANGED_BY = ' + @currentUser + ' : begin'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000023', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

				UPDATE TB_R_ASSET SET PROCESS_ID = NULL WHERE CHANGED_BY = @currentUser
				AND ISNULL(PROCESS_ID, '') NOT IN (SELECT DISTINCT PROCESS_ID FROM TB_T_PO_ITEM)
				AND (ISNULL(PO_NO, '') = '' AND ISNULL(PO_ITEM_NO, '') = '')

				SET @message = 'Reset PROCESS_ID from TB_R_ASSET where CHANGED_BY = ' + @currentUser + ' : end'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000024', 'SUC', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
				
				SET @message = 'Insert PO Data to real table success'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000025', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
			END

			FETCH NEXT FROM db_cursor_vendor INTO @Number, @MAT_NO, @VENDOR_CD, @VENDOR_NAME, @PROC_CHANNEL_CD
		END

		CLOSE db_cursor_vendor   
		DEALLOCATE db_cursor_vendor

		if not exists(select 1 from @poitemlist_notchanged)
		BEGIN
			SET @message = 'Update TB_R_PO_H Status where PO_NO: ' + @poNo + ' : begin'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000026', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
		
			UPDATE TB_R_PO_H SET PO_STATUS = '45' WHERE PO_NO = @poNo

			SET @message = 'Update TB_R_PO_H Status where PO_NO: ' + @poNo + ' : end'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000027', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

			SET @message = 'Delete TB_R_WORKFLOW where DOC_NO: ' + @poNo + ' : begin'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000028', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

			DELETE FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @poNo

			SET @message = 'Delete TB_R_WORKFLOW where DOC_NO: ' + @poNo + ' : end'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000029', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
		END

		--Must delete item to hide item po when only reject partial item
		if exists(select 1 from @poitemlist_notchanged)
		BEGIN
			SET @message = 'Delete TB_R_PO_ITEM where DOC_NO: ' + @poNo + ' and ITEM_NO: ' + @poItem + ' : begin'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000030', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

			UPDATE POI 
				SET POI.PO_STATUS = '45'
			FROM TB_R_PO_ITEM POI WHERE EXISTS (SELECT 1 FROM @poitemlist a where a.PO_NO = poi.PO_NO AND a.PO_ITEM = poi.PO_ITEM_NO)

			SET @message = 'Delete TB_R_PO_ITEM where DOC_NO: ' + @poNo + ' and ITEM_NO: ' + @poItem + ' : end'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000031', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
		END

		SET @message = 'Delete TB_R_PO_CONDITION where DOC_NO: ' + @poNo + ' and ITEM_NO: ' + @poItem + ' : begin'
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000032', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

		DELETE POC FROM TB_R_PO_CONDITION POC WHERE EXISTS (SELECT 1 FROM @poitemlist a where a.PO_NO = POC.PO_NO AND a.PO_ITEM = POC.PO_ITEM_NO)

		SET @message = 'Delete TB_R_PO_CONDITION where DOC_NO: ' + @poNo + ' and ITEM_NO: ' + @poItem + ' : end'
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000033', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

		if not exists(select 1 from @poitemlist_notchanged)
		BEGIN
			SET @message = 'Update Amount TB_R_PO_H where DOC_NO: ' + @poNo + ' : begin'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000034', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

			UPDATE temp SET PO_AMOUNT = (SELECT SUM((poi.PO_QTY_ORI * poi.PRICE_PER_UOM)) FROM TB_R_PO_ITEM POI WHERE POI.PO_NO = temp.PO_NO)
			FROM TB_R_PO_H temp
			WHERE temp.PO_NO = @poNo

			SET @message = 'Update Amount TB_R_PO_H where DOC_NO: ' + @poNo   + ' : end'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000035', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
		END

		SET @message = 'Release locking DOC_NO: ' + @poNo + ' : info'
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000036', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

		UPDATE TB_R_PO_H SET PROCESS_ID = NULL WHERE PO_NO = @poNo

		DECLARE @budgetCheck TABLE (DATA_NO int identity(1,1),DOC_NO VARCHAR(30), WBS_NO VARCHAR(30), CURR_CD VARCHAR(10), TOTAL_AMOUNT DECIMAL(18, 6), RETURN_AMOUNT DECIMAL(18, 6), BMS_OPERATION VARCHAR(20) DEFAULT 'CANCEL_COMMIT'  )

		INSERT INTO @budgetCheck (DOC_NO, WBS_NO, CURR_CD, TOTAL_AMOUNT)
		select poi.PO_NO, poi.WBS_NO, poh.PO_CURR,  SUM((poi.PO_QTY_ORI * poi.PRICE_PER_UOM)) TOTAL_PO
		from TB_R_PO_ITEM poi
		INNER JOIN TB_R_PO_H poh ON poh.PO_NO = poi.PO_NO
		INNER JOIN @poitemlist item on item.PO_NO = poi.PO_NO and item.PO_ITEM = poi.PO_ITEM_NO
		WHERE poi.PO_NO = @poNo
		GROUP BY poi.PO_NO, poi.WBS_NO, poh.PO_CURR

		UPDATE temp
			SET RETURN_AMOUNT = (SELECT SUM(poi.PO_QTY_ORI * poi.PRICE_PER_UOM) 
										FROM TB_R_PO_ITEM poi 
										INNER JOIN @poitemlist_notchanged item on item.PO_NO = poi.PO_NO and item.PO_ITEM = poi.PO_ITEM_NO
										WHERE poi.PO_NO = temp.DOC_NO AND poi.WBS_NO = temp.WBS_NO)
		FROM @budgetCheck temp
		

		UPDATE temp
			SET BMS_OPERATION = CASE WHEN RETURN_AMOUNT > 0 THEN 'REV_COMMIT' ELSE BMS_OPERATION END
		FROM @budgetCheck temp

		DECLARE @poGroupedByWBSCount int, 
				@wbsIdx int = 1,
				@oldDocNo VARCHAR(30),
				@wbsNo VARCHAR(30),
				@currency VARCHAR(10),
				@totalAmount DECIMAL(18, 6),
				@bmsOperation VARCHAR(20),
				@bmsResponse VARCHAR(20),
				@bmsRetryCounter INT = 0,
				@cancelDesc VARCHAR(MAX),
				@poDesc VARCHAR(MAX),
				@bmsResponseMessage VARCHAR(1000)

		SELECT @poGroupedByWBSCount = ISNULL(MAX(DATA_NO), 0) FROM @budgetCheck
		
		WHILE (@wbsIdx <= @poGroupedByWBSCount)
		BEGIN
			SELECT @oldDocNo = DOC_NO + '_001', 
					@wbsNo = WBS_NO, 
					@currency = CURR_CD,
					@totalAmount = TOTAL_AMOUNT,
					@bmsOperation = BMS_OPERATION
			FROM @budgetCheck WHERE DATA_NO = @wbsIdx
				
			SELECT @cancelDesc = PO_DESC+ ' - Reject By Vendor', @poDesc=PO_DESC FROM TB_R_PO_H WHERE PO_NO = @poNo

			SET @message = 'Budget ' + @bmsOperation + ' on WBS No: ' + @wbsNo + ' with Ref Doc No ' + ISNULL(@oldDocNo, 'NULL') + ', Currency Cd ' + @currency + ' Amount ' + CAST(@totalAmount AS VARCHAR) + ' : start'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000037', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
				
			--SET @bmsResponse = 0
			EXEC @bmsResponse =
				dbo.[sp_BudgetControl_Linked]
				    @bmsResponseMessage OUTPUT, @currentUser, @bmsOperation, @wbsNo, @oldDocNo, @oldDocNo,
				    @currency, @totalAmount, @totalAmount, '', @cancelDesc, 'GPS', ''

			-- NOTE: bmsResponse always 0 or 1 String which means Success or Failed respectively
			WHILE (@bmsResponse = '1' AND @bmsRetryCounter < 3)
			BEGIN
				-- NOTE: if Failed retry in 1 sec and log
				SET @message = 'Budget ' + @bmsOperation + ' Failed on WBS No: ' + @wbsNo + ' with reff Doc No ' + ISNULL(@oldDocNo, 'NULL') + ', Currency Cd ' + @currency + ' Amount ' + CAST(@totalAmount AS VARCHAR)  + ' : retry'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000038', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

				WAITFOR DELAY '00:00:01'
				EXEC @bmsResponse =
					dbo.[sp_BudgetControl_Linked]
				    @bmsResponseMessage OUTPUT, @currentUser, @bmsOperation, @wbsNo, @oldDocNo, @oldDocNo,
				    @currency, @totalAmount, @totalAmount, '', @cancelDesc, 'GPS', ''

				SET @bmsRetryCounter = @bmsRetryCounter + 1
			END

			IF ISNULL(@bmsResponse, '0') <> '0' BEGIN RAISERROR(@bmsResponseMessage, 16, 1) END

			INSERT INTO @budgetTransactTemp (WBSNO, RefDocNo, NewDocNo, Currency, TotalAmount, MaterialNo, DocDesc, BmsOperation)
			VALUES(@wbsNo, NULL, @oldDocNo, @currency, @totalAmount, '', @poDesc, 'NEW_COMMIT')
				
			SET @message = 'Budget ' + @bmsOperation + ' on WBS No: ' + @wbsNo + ' with reff Doc No ' + ISNULL(@oldDocNo, 'NULL') + ' and Ref Doc No' + ISNULL(@oldDocNo, 'NULL')  + ', Currency Cd ' + @currency + ' Amount ' + CAST(@totalAmount AS VARCHAR) + ' : end'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000039', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
				
			SET @wbsIdx = @wbsIdx + 1
		END

		--Reverse Budget to PR for current document
		DELETE FROM @budgetCheck
		SET @bmsRetryCounter = 0
		SET @bmsResponse = 0
		DECLARE @PR_NO VARCHAR(23)

		INSERT INTO @budgetCheck (DOC_NO, WBS_NO, CURR_CD, TOTAL_AMOUNT, RETURN_AMOUNT, BMS_OPERATION)
		select poi.PR_NO, poi.WBS_NO, poh.PO_CURR,  SUM((poi.PO_QTY_ORI * poi.PRICE_PER_UOM)) TOTAL_PO,0, 'NEW_COMMIT'
		from TB_R_PO_ITEM poi
		INNER JOIN TB_R_PO_H poh ON poh.PO_NO = poi.PO_NO
		INNER JOIN @poitemlist item on item.PO_NO = poi.PO_NO and item.PO_ITEM = poi.PO_ITEM_NO
		WHERE poi.PO_NO = @poNo
		GROUP BY poi.PR_NO, poi.WBS_NO, poh.PO_CURR

		SELECT @poGroupedByWBSCount = ISNULL(MAX(DATA_NO), 0) FROM @budgetCheck
		
		WHILE (@wbsIdx <= @poGroupedByWBSCount)
		BEGIN
			SELECT @oldDocNo = DOC_NO + '_001', 
					@wbsNo = WBS_NO, 
					@currency = CURR_CD,
					@totalAmount = TOTAL_AMOUNT,
					@bmsOperation = BMS_OPERATION,
					@PR_NO = DOC_NO
			FROM @budgetCheck WHERE DATA_NO = @wbsIdx
				
			SELECT @poDesc=PR_DESC FROM TB_R_PR_H WHERE PR_NO = @PR_NO

			SET @message = 'Budget-reverse ' + @bmsOperation + ' on WBS No: ' + @wbsNo + ' with Ref Doc No ' + ISNULL(@oldDocNo, 'NULL') + ', Currency Cd ' + @currency + ' Amount ' + CAST(@totalAmount AS VARCHAR) + ' : start'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000037', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
				
			--SET @bmsResponse = 0
			EXEC @bmsResponse =
				dbo.[sp_BudgetControl_Linked]
				    @bmsResponseMessage OUTPUT, @currentUser, @bmsOperation, @wbsNo, null, @oldDocNo,
				    @currency, @totalAmount, @totalAmount, '', @cancelDesc, 'GPS', ''
			-- NOTE: bmsResponse always 0 or 1 String which means Success or Failed respectively
			WHILE (@bmsResponse = '1' AND @bmsRetryCounter < 3)
			BEGIN
				-- NOTE: if Failed retry in 1 sec and log
				SET @message = 'Budget-reverse ' + @bmsOperation + ' Failed on WBS No: ' + @wbsNo + ' with reff Doc No ' + ISNULL(@oldDocNo, 'NULL') + ', Currency Cd ' + @currency + ' Amount ' + CAST(@totalAmount AS VARCHAR)  + ' : retry'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000038', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

				WAITFOR DELAY '00:00:01'
				EXEC @bmsResponse =
				dbo.[sp_BudgetControl_Linked]
				    @bmsResponseMessage OUTPUT, @currentUser, @bmsOperation, @wbsNo, @oldDocNo, @oldDocNo,
				    @currency, @totalAmount, @totalAmount, '', @cancelDesc, 'GPS', ''

				SET @bmsRetryCounter = @bmsRetryCounter + 1
			END

			IF ISNULL(@bmsResponse, '0') <> '0' BEGIN RAISERROR(@bmsResponseMessage, 16, 1) END

			INSERT INTO @budgetTransactTemp (WBSNO, RefDocNo, NewDocNo, Currency, TotalAmount, MaterialNo, DocDesc, BmsOperation)
			VALUES(@wbsNo, @oldDocNo, @oldDocNo, @currency, @totalAmount, '', @poDesc, 'CANCEL_COMMIT')
				
			SET @message = 'Budget-reverse ' + @bmsOperation + ' on WBS No: ' + @wbsNo + ' with reff Doc No ' + ISNULL(@oldDocNo, 'NULL') + ' and Ref Doc No' + ISNULL(@oldDocNo, 'NULL')  + ', Currency Cd ' + @currency + ' Amount ' + CAST(@totalAmount AS VARCHAR) + ' : end'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000039', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
				
			SET @wbsIdx = @wbsIdx + 1
		END

		-- Insert or Update Quota
		-- Reverse Quota to PR
		BEGIN
			IF CURSOR_STATUS('global','db_cursor_quota3') >= -1
			BEGIN
				DEALLOCATE db_cursor_quota3
			END


			DECLARE @QUOTA_WBS_NO VARCHAR(30),
				@QUOTA_VALUATUION_CLASS VARCHAR(4),
				@QUOTA_MAT_NO VARCHAR(23),
				@QUOTA_MAT_DESC VARCHAR(50),
				@QUOTA_DIVISION_ID INT,
				@QUOTA_AMOUNT DECIMAL(18,4),
				@QUOTA_PO_NO VARCHAR(10),
				@QUOTA_CONSUME_MONTH VARCHAR(6)

			DECLARE db_cursor_quota3 CURSOR FOR  
			SELECT  POI.WBS_NO, POI.VALUATION_CLASS, POI.MAT_NO, POI.MAT_DESC, PRH.DIVISION_ID, SUM((POI.PO_QTY_REMAIN*POI.PRICE_PER_UOM)), POI.PR_NO
                    FROM TB_R_PO_ITEM POI
					INNER JOIN @poitemlist item on item.PO_NO = poi.PO_NO and item.PO_ITEM = poi.PO_ITEM_NO
                    INNER JOIN TB_R_PR_ITEM PRI ON PRI.PR_NO = POI.PR_NO AND PRI.PR_ITEM_NO = POI.PR_ITEM_NO
					INNER JOIN TB_R_PR_H PRH ON PRH.PR_NO = PRI.PR_NO
					INNER JOIN TB_M_QUOTA MQ ON MQ.WBS_NO = PRI.WBS_NO AND MQ.DIVISION_ID = PRH.DIVISION_ID AND MQ.QUOTA_TYPE = PRI.VALUATION_CLASS 
                    WHERE ((POI.WBS_NO <> 'X') AND (ISNULL(POI.WBS_NO, '') <> ''))
                        AND ISNULL(PRI.QUOTA_FLAG,'N') = 'Y' AND POI.PO_NO = @poNo
			GROUP BY POI.WBS_NO, POI.VALUATION_CLASS, POI.MAT_NO, POI.MAT_DESC, PRH.DIVISION_ID, POI.PR_NO
			OPEN db_cursor_quota3   
			FETCH NEXT FROM db_cursor_quota3 INTO @QUOTA_WBS_NO, @QUOTA_VALUATUION_CLASS, @QUOTA_MAT_NO, @QUOTA_MAT_DESC, @QUOTA_DIVISION_ID, @QUOTA_AMOUNT, @QUOTA_PO_NO
			WHILE @@FETCH_STATUS = 0   
			BEGIN
				SELECT @message = 'Quota No: ' + @QUOTA_WBS_NO + ', Reff Doc: '  + @QUOTA_PO_NO + ', New Doc: '  + @QUOTA_PO_NO + ', Total Amount: '  + CONVERT(VARCHAR, @QUOTA_AMOUNT) +': starting' 
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000040', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

				SELECT @QUOTA_CONSUME_MONTH = CONVERT(CHAR(6), CREATED_DT, 112) FROM TB_R_PO_H WHERE PO_NO = @poNo

				EXEC dbo.sp_ecatalogue_quotaCalculation 'COMMIT', @QUOTA_WBS_NO, @QUOTA_WBS_NO, @QUOTA_VALUATUION_CLASS, @QUOTA_MAT_NO, @QUOTA_MAT_DESC, @QUOTA_DIVISION_ID, @QUOTA_CONSUME_MONTH , @QUOTA_CONSUME_MONTH,
					@QUOTA_AMOUNT, @QUOTA_AMOUNT, @QUOTA_PO_NO, @QUOTA_PO_NO, @actionName, @currentUser, @bmsResponseMessage OUTPUT, @message OUTPUT

				IF @bmsResponseMessage <> 'SUCCESS' BEGIN RAISERROR(@message, 16, 1) END

				SELECT @message = 'Quota No: ' + @QUOTA_WBS_NO + ', Reff Doc: '  + @QUOTA_PO_NO + ', New Doc: '  + @QUOTA_PO_NO + ', Total Amount: '  + CONVERT(VARCHAR, @QUOTA_AMOUNT)+': end' 
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000041', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

				FETCH NEXT FROM db_cursor_quota3 INTO @QUOTA_WBS_NO, @QUOTA_VALUATUION_CLASS, @QUOTA_MAT_NO, @QUOTA_MAT_DESC, @QUOTA_DIVISION_ID, @QUOTA_AMOUNT, @QUOTA_PO_NO
			END

			CLOSE db_cursor_quota3   
			DEALLOCATE db_cursor_quota3
		END

		DELETE FROM @calculationRef 

		BEGIN
			SET @message = 'Reject PO By Vendor Processed succesfully'
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000042', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
		END

        COMMIT TRAN

        SET @message = 'S|Finish'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000099', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
        
		ROLLBACK TRAN

		--Rollback Segment
		IF EXISTS(SELECT 1 FROM @budgetTransactTemp)
		BEGIN
			SET @message =  'Rollback Budget' 
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000043', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

			DECLARE @1WBSNo VARCHAR(30), @1RefDocNo VARCHAR(15),
				@1NewDocNo VARCHAR(15), @1Currency VARCHAR(3), @1TotalAmount DECIMAL(18, 6), @1TotalReturnAmount DECIMAL(18, 6),
				@1MaterialNo VARCHAR(30), @1DocDesc VARCHAR(MAX), @1BmsOperation VARCHAR(50), @currentUser_rollback VARCHAR(50)

			DECLARE db_cursor_bms_rollback CURSOR FOR  
			SELECT WBSNo, RefDocNo, NewDocNo, Currency,SUM(TotalAmount) AS TotalAmount, MaterialNo, DocDesc, BmsOperation FROM @budgetTransactTemp GROUP BY WBSNo, RefDocNo, NewDocNo, Currency, MaterialNo, DocDesc, BmsOperation

			SET @currentUser_rollback = 'rollbackBgPOCatalog'

			OPEN db_cursor_bms_rollback   
			FETCH NEXT FROM db_cursor_bms_rollback INTO @1WBSNo, @1RefDocNo, @1NewDocNo, @1Currency, @1TotalAmount, @1MaterialNo, @1DocDesc, @1BmsOperation
			WHILE @@FETCH_STATUS = 0   
			BEGIN
				BEGIN TRY
					SET @1TotalReturnAmount = CASE WHEN @1BmsOperation = 'CANCEL_COMMIT' THEN @1TotalAmount ELSE 0 END
					SELECT @message = 'Rollback WBS No: ' + @1WBSNo + ', Reff Doc: '  + ISNULL(@1RefDocNo,'NULL') + ', New Doc: '  + ISNULL(@1NewDocNo,'NULL') + ', Total Amount: '  + CONVERT(VARCHAR, @1TotalAmount) + ', Rollback Amount: '+CONVERT(VARCHAR, @1TotalReturnAmount)+', BMS Operation: ' +@1BmsOperation
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000044', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

					EXEC @bmsResponse =
							dbo.[sp_BudgetControl_Linked]
								@bmsResponseMessage OUTPUT,
								@currentUser_rollback,
								@1BmsOperation,
								@1WBSNo,
								@1RefDocNo, --@oldPONo,
								@1NewDocNo, --@poNoForBMS,
								@1Currency,
								@1TotalAmount,
								@1TotalReturnAmount,
								@1MaterialNo,
								@1DocDesc,
								'GPS',
								''

					IF ISNULL(@bmsResponse, '0') <> '0' BEGIN RAISERROR(@bmsResponseMessage, 16, 1) END

				END TRY
				BEGIN CATCH
					SET @message = CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MSG0000045', 'ERR', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
				END CATCH
				FETCH NEXT FROM db_cursor_bms_rollback INTO @1WBSNo, @1RefDocNo, @1NewDocNo, @1Currency, @1TotalAmount, @1MaterialNo, @1DocDesc, @1BmsOperation
			END

			CLOSE db_cursor_bms_rollback   
			DEALLOCATE db_cursor_bms_rollback
		END
		
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'EXCEPTION', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
    END CATCH

	IF CURSOR_STATUS('global','db_cursor_vendor') >= -1
	BEGIN
		DEALLOCATE db_cursor_vendor
	END
	IF CURSOR_STATUS('global','db_cursor_bms_rollback') >= -1
	BEGIN
		DEALLOCATE db_cursor_bms_rollback
	END
	IF CURSOR_STATUS('global','db_cursor_quota3') >= -1
	BEGIN
		DEALLOCATE db_cursor_quota3
	END

    EXEC sp_putLog_Temp @tmpLog
    SET NOCOUNT OFF
    SELECT @message
END

--select * from TB_R_LOG_D where PROCESS_ID = @processId
--select * from TB_R_LOG_D where PROCESS_ID in (select PROCESS_ID from  @relatedProcessTable)