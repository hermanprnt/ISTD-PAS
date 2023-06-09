/****** Object:  StoredProcedure [dbo].[sp_POCreation_Save]    Script Date: 11/1/2017 2:54:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_POCreation_Save]
    @currentUser VARCHAR(50),
    @currentUserNoReg VARCHAR(50),
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6),
    @poNo VARCHAR(11),
    @poDesc VARCHAR(MAX),
    @poNote1 VARCHAR(132),
    @poNote2 VARCHAR(132),
    @poNote3 VARCHAR(132),
    @poNote4 VARCHAR(132),
    @poNote5 VARCHAR(132),
    @poNote6 VARCHAR(132),
    @poNote7 VARCHAR(132),
    @poNote8 VARCHAR(132),
    @poNote9 VARCHAR(132),
    @poNote10 VARCHAR(132),
    @vendor VARCHAR(6),
    @vendorName VARCHAR(50),
    @vendorAddress VARCHAR(150),
    @vendorCountry VARCHAR(2),
    @vendorCity VARCHAR(30),
    @vendorPostalCode VARCHAR(6),
    @vendorPhone VARCHAR(30),
    @vendorFax VARCHAR(30),
    @purchasingGroup VARCHAR(3),
    @currency VARCHAR(3),
    @deliveryAddress VARCHAR(MAX),
    @isSPKCreated BIT,
    @biddingDate DATETIME,
    @spkOpening VARCHAR(MAX),
    @spkWork VARCHAR(100),
    @spkAmount DECIMAL(13,3),
    @spkLocation VARCHAR(50),
    @spkPeriodStart DATETIME,
    @spkPeriodEnd DATETIME,
    @spkRetention INT,
    @terminI VARCHAR(5),
    @terminIDesc VARCHAR(50),
    @terminII VARCHAR(5),
    @terminIIDesc VARCHAR(50),
    @terminIII VARCHAR(5),
    @terminIIIDesc VARCHAR(50),
    @terminIV VARCHAR(5),
    @terminIVDesc VARCHAR(50),
    @terminV VARCHAR(5),
    @terminVDesc VARCHAR(50),
    @saveAsDraft BIT,
	@OtherMail VARCHAR(200)
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = 'sp_POCreation_Save',
        @tmpLog LOG_TEMP,
        @isFromSAP CHAR(1) = 'N',
        @isEdit CHAR(1) = 'N'

    DECLARE @process_level AS TABLE (level_id INT)
    INSERT INTO @process_level VALUES(0)

        /*
            0    => Initial
            1    => Insert PO Header
            2    => Insert PO SPK
            3    => Insert PO Item
            4    => Insert PO Sub-item
            5    => Insert PO Condition
            6    =>
        */

    SET NOCOUNT ON
    BEGIN TRY
        EXEC dbo.sp_PutLog 'I|Start', @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0

        BEGIN TRAN SaveData

        -- Initial
        SELECT @poNo = CASE WHEN @poNo IS NULL THEN '' ELSE @poNo END

        DECLARE @budgetTransactTemp TABLE
        (
            DataNo INT IDENTITY(1, 1), WBSNo VARCHAR(30), RefDocNo VARCHAR(15),
            NewDocNo VARCHAR(15), Currency VARCHAR(3), TotalAmount DECIMAL(18, 6),
			ReturnAmount DECIMAL(18, 6), BMSOperation VARCHAR(20),
            MaterialNo VARCHAR(30), DocDesc VARCHAR(MAX)
        )

        SELECT @isFromSAP = CASE WHEN(COUNT(1) > 0) THEN 'Y' ELSE 'N' END FROM TB_R_PO_H WHERE PO_NO = @poNo AND SYSTEM_SOURCE = 'SAP'

        DECLARE @procMonth VARCHAR(1000) = (SELECT SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'PROC_MONTH')
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Generate PO No: begin', @moduleId, @actionName, @functionId, 1, @currentUser)

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Get currency rate: begin', @moduleId, @actionName, @functionId, 1, @currentUser)

        DECLARE @currencyRate TABLE ( CurrencyCode VARCHAR(3), ExchangeRate DECIMAL(7,2), ValidFrom DATETIME, ValidTo DATETIME )
        DECLARE @exchangeRate DECIMAL(7,2)
        INSERT INTO @currencyRate EXEC sp_Currency_GetCurrency @currency
        SET @message = 'Bug - Currently applicable currency rate of ''' + ISNULL(@currency, '') + ''' is duplicate'
        IF (SELECT COUNT(0) FROM @currencyRate) > 1 BEGIN RAISERROR(@message, 16, 1) END
        SELECT @exchangeRate = ExchangeRate FROM @currencyRate
        DELETE FROM @currencyRate

        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Get currency rate: end', @moduleId, @actionName, @functionId, 1, @currentUser)

        DECLARE
            @paymentMethod VARCHAR(1),
            @paymentTerm VARCHAR(4),
            @isOneTimeVendor BIT = (SELECT CASE WHEN COUNT(0) > 0 THEN 1 ELSE 0 END FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'OTV' AND SYSTEM_VALUE = @vendor),
            @vendorAttention VARCHAR(50) = '-'

        SELECT
            @paymentMethod = PAYMENT_METHOD_CD,
            @paymentTerm = PAYMENT_TERM_CD,
            @vendorName = CASE WHEN @isOneTimeVendor = 1 THEN @vendorName ELSE VENDOR_NAME END,
            @vendorAddress = CASE WHEN @isOneTimeVendor = 1 THEN @vendorAddress ELSE VENDOR_ADDRESS END,
            @vendorCountry = CASE WHEN @isOneTimeVendor = 1 THEN @vendorCountry ELSE COUNTRY END,
            @vendorCity = CASE WHEN @isOneTimeVendor = 1 THEN @vendorCity ELSE CITY END,
            @vendorPostalCode = CASE WHEN @isOneTimeVendor = 1 THEN @vendorPostalCode ELSE POSTAL_CODE END,
            @vendorPhone = CASE WHEN @isOneTimeVendor = 1 THEN @vendorPhone ELSE PHONE END,
            @vendorFax = CASE WHEN @isOneTimeVendor = 1 THEN @vendorFax ELSE FAX END,
            @vendorAttention = CASE WHEN @isOneTimeVendor = 1 THEN @vendorAttention ELSE ATTENTION END
        FROM TB_M_VENDOR WHERE VENDOR_CD = @vendor

        DECLARE
            @localCurrency VARCHAR(3) = (SELECT SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'LOCAL_CURR_CD'),
            @poHeaderStatusCode VARCHAR(5) = (SELECT CASE WHEN @saveAsDraft = 1 THEN '47' /* Draft */ ELSE '40' /* Created */ END),
            @poHeaderNextStatusCode VARCHAR(5) = (SELECT CASE WHEN @saveAsDraft = 1 THEN '40' /* Draft */ ELSE '41' /* Created */ END)

        DECLARE
            @divisionId VARCHAR(50),
            @divisionName VARCHAR(50),
            @departmentId VARCHAR(50),
            @sectionId VARCHAR(50),
            @orgId VARCHAR(50),
            @orgTitle VARCHAR(100),
            @directorateId VARCHAR(50),
            @personnelName VARCHAR(100),
            @positionLevel VARCHAR(100)

		IF(@isFromSAP = 'Y')
		BEGIN
		   SELECT
            @divisionId = DIVISION_ID,
            @divisionName = DIVISION_NAME,
            @departmentId = DEPARTMENT_ID,
            @sectionId = SECTION_ID,
            @orgId = ORG_ID,
            @orgTitle = ORG_TITLE,
            @directorateId = DIRECTORATE_ID,
            @personnelName = PERSONNEL_NAME,
            @positionLevel = POSITION_LEVEL
        FROM TB_R_SYNCH_EMPLOYEE
        WHERE NOREG = @currentUserNoReg AND GETDATE() BETWEEN VALID_FROM AND VALID_TO
		END

		ELSE
		BEGIN
        SELECT
            @divisionId = DIVISION_ID,
            @divisionName = DIVISION_NAME,
            @departmentId = DEPARTMENT_ID,
            @sectionId = SECTION_ID,
            @orgId = ORG_ID,
            @orgTitle = ORG_TITLE,
            @directorateId = DIRECTORATE_ID,
            @personnelName = PERSONNEL_NAME,
            @positionLevel = POSITION_LEVEL
        FROM TB_R_SYNCH_EMPLOYEE
        WHERE NOREG = @currentUserNoReg AND GETDATE() BETWEEN VALID_FROM AND VALID_TO

		--IF EXISTS(SELECT 1 from TB_M_COORDINATOR_MAPPING WHERE (NOREG = @currentUserNoReg AND COORDINATOR_CD = @purchasingGroup)
		--	OR SECTION_ID = @sectionId
		--)  

				
			IF EXISTS(SELECT 1 from TB_M_COORDINATOR_MAPPING WHERE (NOREG = @currentUserNoReg AND COORDINATOR_CD = @purchasingGroup)
			OR (@sectionId IN (SELECT  SECTION_ID FROM TB_M_COORDINATOR_MAPPING WHERE COORDINATOR_CD = @purchasingGroup
			  )))

		BEGIN
		select 
			@orgId = ORG_ID,
            @orgTitle = ORG_NAME,
			@sectionId = SECTION_ID,
			@departmentId = DEPARTMENT_ID,
			@divisionId = DIVISION_ID
		from TB_M_COORDINATOR_MAPPING
		WHERE NOREG = @currentUserNoReg AND COORDINATOR_CD = @purchasingGroup
		END
		ELSE 
		BEGIN 
			SET @divisionName =''
			declare @messageErr VARCHAR(200)
			SET @messageErr = 'Bug - Coordinator Mapping is not well configured for No Reg : ' + @currentUserNoReg +' Purchasing Grp : '+ @purchasingGroup
			RAISERROR(@messageErr, 16, 1) 
		END
		END
		

        DECLARE @orgRef TABLE ( OrgId VARCHAR(10), OrgName VARCHAR(50) )
        INSERT INTO @orgRef VALUES
        (@sectionId, 'SectionId'),
        (@departmentId, 'DepartmentId'),
        (@divisionId, 'DivisionId'),
        (@directorateId, 'DirectorateId')
		

        DECLARE
            @procChannelPrefix VARCHAR(4),
            @procChannel VARCHAR(4)

        SELECT @procChannelPrefix = PO_PREFIX, @procChannel = PROC_CHANNEL_CD FROM TB_M_PROCUREMENT_CHANNEL WHERE DIVISION_ID = @divisionId

        -- Generate PONo
        DECLARE
            @candidatePONo VARCHAR(10),
            @numberingPrefix VARCHAR(2),
            @numberingVariant VARCHAR(2)

        IF @poNo = ''
        BEGIN
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Generate PO No: begin', @moduleId, @actionName, @functionId, 1, @currentUser)

            DECLARE @docNumbering VARCHAR(MAX)
            DECLARE @docNumberingMessage TABLE ( Severity VARCHAR(1), [Message] VARCHAR(MAX), GeneratedNo VARCHAR(MAX) )
            DECLARE @splittedSPKMonth TABLE ( No INT, Split VARCHAR(100) )

            IF @procChannelPrefix IS NULL BEGIN RAISERROR('Bug - Procurement Channel is not well configured', 16, 1) END

            SELECT @numberingPrefix = LEFT(@procChannelPrefix, 2), @numberingVariant = RIGHT(@procChannelPrefix, 2)
            SELECT @docNumbering = dbo.GetNextDocNumbering(@numberingPrefix, @numberingVariant)
            INSERT INTO @docNumberingMessage
            SELECT
                (SELECT Split FROM dbo.SplitString(@docNumbering, '|') WHERE [No] = 2),
                (SELECT Split FROM dbo.SplitString(@docNumbering, '|') WHERE [No] = 3),
                (SELECT Split FROM dbo.SplitString(@docNumbering, '|') WHERE [No] = 1)

            IF (SELECT TOP 1 Severity FROM @docNumberingMessage) = 'E'
            BEGIN
                SET @message = (SELECT TOP 1 [Message] FROM @docNumberingMessage)
                RAISERROR(@message, 16, 1)
            END

            SELECT @candidatePONo = @numberingPrefix + RTRIM(LTRIM((SELECT TOP 1 GeneratedNo FROM @docNumberingMessage)))
            SET @message = 'I|Generated PO No: ' + @candidatePONo
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            -- Reserve PONo
            UPDATE TB_M_DOC_NUMBERING SET CURRENT_NUMBER = RIGHT(@candidatePONo, LEN(@candidatePONo)-2)
            WHERE NUMBERING_PREFIX = @numberingPrefix AND VARIANT = @numberingVariant

            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Generate PO No: end', @moduleId, @actionName, @functionId, 1, @currentUser)
        END

        DECLARE
            @exactPONo VARCHAR(11) = (SELECT CASE WHEN (@poNo IS NULL OR @poNo = '') THEN @candidatePONo ELSE @poNo END),
            @isAnyUrgentDoc VARCHAR(1) = (SELECT CASE WHEN COUNT(0) > 0 THEN 'Y' ELSE 'N' END FROM TB_T_PO_ITEM WHERE DELETE_FLAG = 'N' AND URGENT_DOC = 'Y')

		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|SAP Flag : ' + @isFromSAP, @moduleId, @actionName, @functionId, 1, @currentUser)
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Draft Flag : ' + cast(@saveAsDraft as varchar), @moduleId, @actionName, @functionId, 1, @currentUser)


        IF(@isFromSAP <> 'Y' AND @saveAsDraft = 0)
        BEGIN
            --- Budget Update Start
            -- Commit Budget
            -- NOTE: budget always called using reserved Document No
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Budget Update Start : NOTE: budget always called using reserved Document No', @moduleId, @actionName, @functionId, 1, @currentUser)

            SELECT @isEdit = CASE WHEN(COUNT(1) > 0) THEN 'Y' ELSE 'N' END FROM TB_R_PO_H WHERE PO_NO = @exactPONo
            DECLARE @isPOManual BIT = (SELECT CASE WHEN COUNT(0) > 0 THEN 1 ELSE 0 END FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId AND ISNULL(PO_NO, '') = ISNULL(@poNo, '') AND ISNULL(PR_NO, '') = '' AND ISNULL(PR_ITEM_NO, '') = '')
            DECLARE
                @wbsIdx INT = 0,
                @poItemGroupedByWBSCount INT,
                @oldPONo VARCHAR(15) = NULL,
                @totalAmount DECIMAL(18, 2), -- NOTE: BMS accept DECIMAL(18,2)
				@totalNewAmount DECIMAL(18, 2), -- NOTE: BMS accept DECIMAL(18,2)
                @totalReturnAmount DECIMAL(18, 2) = NULL,
                @materialNo VARCHAR(30) = '',
                @doc_no VARCHAR(10),
                @wbsNo VARCHAR(30),
                --@bmsOperation VARCHAR(20) = (SELECT CASE WHEN @isPOManual = 1 AND @exactPONo = '' THEN 'NEW_COMMIT' ELSE 'REV_COMMIT' END),
                @bmsOperation VARCHAR(30),
                @additionalAct VARCHAR(1) = NULL,
                @bmsResponse VARCHAR(20),
                @bmsResponseMessage VARCHAR(8000),
                @bmsRetryCounter INT = 0

            DECLARE @budgetCheck2 TABLE (DATA_NO INT, WBS_NO VARCHAR(30), DOC_NO VARCHAR(30), TRANS VARCHAR(30), TOTAL_AMOUNT DECIMAL(18,4), TOTAL_NEW_AMOUNT DECIMAL(18,4), RETURN_VALUE DECIMAL(18,4))

            --TOTAL AMOUNT : Yang mau di commit ke budget
			--TOTAL NEW AMOUNT : Yang mau dibalikin ke dokumen baru (in case : yang mau dijadikan PO)
			--TOTAL RETURN AMOUNT : Yang mau dibalikin ke dokumen lama (in case : yang mau dijadikan PR kembali)

            -- Budget calculation start (EXCLUDE DELETE FLAG !!!! PERLU DI ANALISA LAGI)
            INSERT INTO @budgetCheck2
            SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) DATA_NO, WBS_NO, DOC_NO, TRANS, SUM(TOTAL_AMOUNT), SUM(TOTAL_NEW_AMOUNT), SUM(RETURN_VALUE)
            FROM (
                SELECT WBS_NO, DOC_NO, TRANS, SUM(TOTAL_AMOUNT) AS TOTAL_AMOUNT, SUM(TOTAL_NEW_AMOUNT) AS TOTAL_NEW_AMOUNT, SUM(RETURN_VALUE) AS RETURN_VALUE
                FROM (
                    SELECT
                        POI.WBS_NO, ISNULL((CASE WHEN PRI.PR_NO IS NULL THEN NULL ELSE PRI.PR_NO + '_' + PRI.BUDGET_REF END), @exactPONo + '_001') AS DOC_NO,
                        CASE WHEN (@isEdit = 'Y' OR @isPOManual <> 1) THEN 
							(CASE 
							 WHEN POI.PO_QTY_ORI = 0 THEN 'CONVERT_COMMIT' 
							 WHEN POI.PO_QTY_ORI = POI.PO_QTY_NEW AND POI.ORI_AMOUNT <> POI.NEW_AMOUNT AND POI.DELETE_FLAG = 'N' THEN 'CANCEL_COMMIT'
							 WHEN (POI.PO_QTY_ORI <= POI.PO_QTY_NEW) AND POI.DELETE_FLAG = 'N'  THEN 'CONVERT_COMMIT'  
							 ELSE 'REVERSE_COMMIT' 
							 END) 
						ELSE 'NEW_COMMIT' 
						END AS TRANS,
                        CASE 
							WHEN  POI.DELETE_FLAG = 'Y' AND POI.UPDATE_FLAG ='Y' THEN
								(POI.PO_QTY_NEW)*(NEW_PRICE_PER_UOM)
							WHEN POI.PO_QTY_ORI > POI.PO_QTY_NEW THEN POI.ORI_AMOUNT - POI.NEW_AMOUNT
							--WHEN POI.PO_QTY_ORI = POI.PO_QTY_NEW THEN (POI.PO_QTY_NEW)*(NEW_PRICE_PER_UOM) --ADD BY YANES
							WHEN POI.PO_QTY_ORI = POI.PO_QTY_NEW AND POI.ORI_AMOUNT = POI.NEW_AMOUNT  THEN 0
							WHEN POI.PO_QTY_ORI = POI.PO_QTY_NEW AND POI.ORI_AMOUNT <> POI.NEW_AMOUNT  THEN POI.NEW_AMOUNT
							ELSE POI.NEW_AMOUNT - ISNULL(POI.ORI_AMOUNT, 0) END AS TOTAL_AMOUNT,
						CASE WHEN  POI.DELETE_FLAG = 'Y' AND POI.UPDATE_FLAG ='Y' THEN
							0 
						ELSE
							POI.NEW_AMOUNT
						END AS TOTAL_NEW_AMOUNT,
                        CASE
							WHEN  POI.DELETE_FLAG = 'Y' AND POI.UPDATE_FLAG ='Y' THEN
								(POI.PO_QTY_NEW)*(NEW_PRICE_PER_UOM)
                            WHEN POI.PO_QTY_ORI < POI.PO_QTY_NEW
                                THEN
                                    CASE WHEN POI.PO_QTY_ORI = 0 AND PRI.OPEN_QTY > POI.PO_QTY_NEW
                                        THEN
                                            ((PRI.OPEN_QTY - POI.PO_QTY_NEW)*ISNULL(PRI.PRICE_PER_UOM, POI.ORI_PRICE_PER_UOM))
                                    WHEN POI.PO_QTY_ORI = 0 AND PRI.OPEN_QTY <= POI.PO_QTY_NEW
                                        THEN
                                            ((POI.PO_QTY_NEW - PRI.OPEN_QTY)*ISNULL(PRI.PRICE_PER_UOM, POI.ORI_PRICE_PER_UOM))
									WHEN POI.PO_QTY_ORI > 0 AND POI.PO_QTY_NEW > POI.PO_QTY_ORI
                                        THEN
                                            ((POI.PO_QTY_NEW - PRI.OPEN_QTY - POI.PO_QTY_ORI)*ISNULL(PRI.PRICE_PER_UOM, POI.ORI_PRICE_PER_UOM)) --ADD BY A.SY (2017/08/02)
                                    ELSE
                                        ((POI.PO_QTY_NEW-POI.PO_QTY_ORI)*ISNULL(PRI.PRICE_PER_UOM, POI.ORI_PRICE_PER_UOM))
                                    END
							--WHEN POI.PO_QTY_ORI = POI.PO_QTY_NEW THEN POI.ORI_AMOUNT - POI.NEW_AMOUNT --ADD BY YANES
                            ELSE
                                ((POI.PO_QTY_ORI-POI.PO_QTY_NEW)*POI.NEW_PRICE_PER_UOM)
                        END AS RETURN_VALUE
                    FROM TB_T_PO_ITEM POI
                        INNER JOIN TB_T_PO_H POH ON POH.PROCESS_ID = POI.PROCESS_ID
                        LEFT JOIN TB_R_PR_ITEM PRI ON PRI.PR_NO = POI.PR_NO AND PRI.PR_ITEM_NO = POI.PR_ITEM_NO
                    WHERE POI.PROCESS_ID = @processId AND ((POI.WBS_NO <> 'X') AND (ISNULL(POI.WBS_NO, '') <> ''))
                        AND (POI.DELETE_FLAG = 'N' OR (POI.DELETE_FLAG = 'Y' AND POI.UPDATE_FLAG = 'Y'))
                ) tblm GROUP BY WBS_NO, DOC_NO, TRANS
                UNION
                SELECT
                    WBS_NO, DOC_NO, TRANS, SUM(TOTAL_AMOUNT) AS TOTAL_AMOUNT, SUM(TOTAL_NEW_AMOUNT) AS TOTAL_NEW_AMOUNT, SUM(RETURN_VALUE) AS RETURN_VALUE
                FROM (
                    SELECT
                        POS.WBS_NO, ISNULL((CASE WHEN PRI.PR_NO IS NULL THEN NULL ELSE PRI.PR_NO + '_' + PRI.BUDGET_REF END), @exactPONo + '_001') AS DOC_NO,
                        CASE WHEN (@isEdit = 'Y' OR @isPOManual <> 1) THEN 
							(CASE 
							 WHEN POS.PO_QTY_ORI = 0 THEN 'CONVERT_COMMIT' 
							 WHEN POS.PO_QTY_ORI = POS.PO_QTY_NEW AND ((POS.PO_QTY_ORI * POS.ORI_PRICE_PER_UOM) <> (POS.PO_QTY_NEW * POS.PRICE_PER_UOM)) AND POS.DELETE_FLAG = 'N' THEN 'CANCEL_COMMIT'
							 WHEN (POS.PO_QTY_ORI <= POS.PO_QTY_NEW) AND POI.DELETE_FLAG = 'N' THEN 'CONVERT_COMMIT' 
							 ELSE 'REVERSE_COMMIT' 
							 END) 
						ELSE 'NEW_COMMIT' 
						END AS TRANS,
                        CASE
						WHEN  POI.DELETE_FLAG = 'Y' AND POI.UPDATE_FLAG ='Y' THEN
								(ISNULL(POS.PO_QTY_ORI, 0) * ISNULL(POS.ORI_PRICE_PER_UOM, 0))
						WHEN POS.PO_QTY_ORI > POS.PO_QTY_NEW THEN ((POS.PO_QTY_ORI * POS.ORI_PRICE_PER_UOM) - (POS.PO_QTY_NEW * POS.PRICE_PER_UOM))
							--WHEN POI.PO_QTY_ORI = POI.PO_QTY_NEW THEN (POI.PO_QTY_NEW)*(NEW_PRICE_PER_UOM) --ADD BY YANES
						WHEN POS.PO_QTY_ORI = POS.PO_QTY_NEW AND ((POS.PO_QTY_ORI * POS.ORI_PRICE_PER_UOM) = (POS.PO_QTY_NEW * POS.PRICE_PER_UOM)) AND POI.DELETE_FLAG = 'N'  THEN 0
						WHEN POS.PO_QTY_ORI = POS.PO_QTY_NEW AND ((POS.PO_QTY_ORI * POS.ORI_PRICE_PER_UOM) <> (POS.PO_QTY_NEW * POS.PRICE_PER_UOM)) AND POI.DELETE_FLAG = 'N'  THEN (POS.PO_QTY_NEW * POS.PRICE_PER_UOM)
						ELSE (POS.PO_QTY_NEW * POS.PRICE_PER_UOM) - (ISNULL(POS.PO_QTY_ORI, 0) * ISNULL(POS.ORI_PRICE_PER_UOM, 0)) END AS TOTAL_AMOUNT,
						CASE 
						WHEN  POI.DELETE_FLAG = 'Y' AND POI.UPDATE_FLAG ='Y' THEN 0 
						ELSE (POS.PO_QTY_NEW * POS.PRICE_PER_UOM)
						END AS TOTAL_NEW_AMOUNT,
                        CASE
							WHEN  POI.DELETE_FLAG = 'Y' AND POI.UPDATE_FLAG ='Y' THEN
								(ISNULL(POS.PO_QTY_ORI, 0) * ISNULL(POS.ORI_PRICE_PER_UOM, 0))
                            WHEN POI.PO_QTY_ORI < POI.PO_QTY_NEW
                                THEN
                                    CASE WHEN POI.PO_QTY_ORI = 0 AND PRI.OPEN_QTY > POI.PO_QTY_NEW
                                        THEN
                                            ((PRI.OPEN_QTY - POI.PO_QTY_NEW)*ISNULL(PRI.PRICE_PER_UOM, POI.ORI_PRICE_PER_UOM))
                                    WHEN POI.PO_QTY_ORI = 0 AND PRI.OPEN_QTY <= POI.PO_QTY_NEW
                                        THEN
                                            ((POI.PO_QTY_NEW - PRI.OPEN_QTY)*ISNULL(PRI.PRICE_PER_UOM, POI.ORI_PRICE_PER_UOM))
                                    ELSE
                                        ((POI.PO_QTY_NEW-POI.PO_QTY_ORI)*ISNULL(PRI.PRICE_PER_UOM, POI.ORI_PRICE_PER_UOM))
                                    END
                            ELSE
                                ((POI.PO_QTY_ORI-POI.PO_QTY_NEW)*POI.NEW_PRICE_PER_UOM)
                        END AS RETURN_VALUE
                    FROM TB_T_PO_SUBITEM POS
                        INNER JOIN TB_T_PO_ITEM POI ON POI.PROCESS_ID = POS.PROCESS_ID AND ISNULL(POI.PR_NO, '') = ISNULL(POS.PR_NO, '') AND ISNULL(POI.PR_ITEM_NO, '') = ISNULL(POS.PR_ITEM_NO, '')  AND POI.SEQ_ITEM_NO = POS.SEQ_ITEM_NO
                        INNER JOIN TB_T_PO_H POH ON POH.PROCESS_ID = POS.PROCESS_ID
                        LEFT JOIN TB_R_PR_ITEM PRI ON PRI.PR_NO = POS.PR_NO AND PRI.PR_ITEM_NO = POS.PR_ITEM_NO
                        LEFT JOIN TB_R_PR_SUBITEM PRS ON PRS.PR_NO = POS.PR_NO AND PRS.PR_ITEM_NO = POS.PR_ITEM_NO AND PRS.PR_SUBITEM_NO = POS.PR_SUBITEM_NO
                    WHERE POS.PROCESS_ID = @processId AND PRI.WBS_NO = 'X' AND PRI.ITEM_CLASS = 'S'  AND (POI.DELETE_FLAG = 'N' OR (POI.DELETE_FLAG = 'Y' AND POI.UPDATE_FLAG = 'Y'))
                ) tbls GROUP BY WBS_NO, DOC_NO, TRANS
            ) tbla GROUP BY WBS_NO, DOC_NO, TRANS
            -- Budget calculation end

			DECLARE @maxId int
			SELECT @maxId = DATA_NO FROM @budgetCheck2
			SET @maxId = ISNULL(@maxId,0) 

			MERGE @budgetCheck2 AS [Target]
			USING (
				SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @maxId AS DATA_NO, PRI.WBS_NO, PRI.PR_NO, PRI.BUDGET_REF,
					0 TOTAL_NEW_AMOUNT, SUM(PRI.OPEN_QTY * PRI.PRICE_PER_UOM) AS FIX_RETURN_VALUE
				FROM TB_R_PR_ITEM PRI
				WHERE PRI.WBS_NO <> 'X' AND PRI.ITEM_CLASS = 'M' --AND @isEdit = 'N'
					AND OPEN_QTY>0 AND PRI.ORI_CURR_CD = @currency
					AND PR_NO IN (SELECT POI.PR_NO FROM TB_T_PO_ITEM POI WHERE PROCESS_ID =@processId AND DELETE_FLAG = 'N')
					AND NOT EXISTS (SELECT 1 FROM TB_T_PO_ITEM POI WHERE POI.PR_NO = PRI.PR_NO AND POI.PR_ITEM_NO = PRI.PR_ITEM_NO AND PROCESS_ID =@processId AND DELETE_FLAG='N')
				GROUP BY PRI.PR_NO, PRI.WBS_NO, PRI.BUDGET_REF
				UNION ALL
				SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @maxId AS DATA_NO, PRS.WBS_NO, PRI.PR_NO, PRI.BUDGET_REF,
					0 TOTAL_NEW_AMOUNT, SUM(PRS.SUBITEM_QTY * PRS.PRICE_PER_UOM) AS FIX_RETURN_VALUE
				FROM TB_R_PR_ITEM PRI 
					INNER JOIN TB_R_PR_SUBITEM PRS ON PRS.PR_NO = PRI.PR_NO AND PRS.PR_ITEM_NO = PRI.PR_ITEM_NO
				WHERE PRI.WBS_NO = 'X' AND PRI.ITEM_CLASS = 'S' --AND @isEdit = 'N'
				AND OPEN_QTY>0 AND PRI.ORI_CURR_CD = @currency
					AND PRI.PR_NO IN (SELECT POI.PR_NO FROM TB_T_PO_ITEM POI WHERE PROCESS_ID =@processId AND DELETE_FLAG = 'N')
					AND NOT EXISTS (SELECT 1 FROM TB_T_PO_ITEM POI WHERE POI.PR_NO = PRI.PR_NO AND POI.PR_ITEM_NO = PRI.PR_ITEM_NO AND PROCESS_ID =@processId AND DELETE_FLAG='N')
				GROUP BY PRI.PR_NO, PRS.WBS_NO, PRI.BUDGET_REF
			) AS [Source]
			ON ([Target].WBS_NO = [Source].WBS_NO AND SUBSTRING([Target].DOC_NO,1,10) = [Source].PR_NO) AND ([Target].RETURN_VALUE = 0 
				AND TRANS = 'CONVERT_COMMIT' AND TOTAL_AMOUNT <> 0 AND NOT EXISTS(SELECT 1 FROM @budgetCheck2 t WHERE t.WBS_NO = [Target].WBS_NO AND t.DOC_NO = [Target].DOC_NO AND TRANS = 'REVERSE_COMMIT'))
			WHEN MATCHED THEN
				UPDATE  SET [Target].RETURN_VALUE = [Source].FIX_RETURN_VALUE;

			UPDATE temp SET TRANS ='REVERSE_COMMIT'
			FROM @budgetCheck2 temp
			WHERE (TRANS = 'CONVERT_COMMIT' OR TRANS = 'CANCEL_COMMIT') AND EXISTS (SELECT 1 FROM @budgetCheck2 t WHERE t.WBS_NO = temp.WBS_NO AND t.DOC_NO = temp.DOC_NO AND TRANS = 'REVERSE_COMMIT')

			--UPDATE temp SET TRANS ='REV_COMMIT'
			--FROM @budgetCheck2 temp
			--WHERE TRANS = 'REVERSE_COMMIT' AND 
			--	(SELECT ISNULL(SUM(TOTAL_NEW_AMOUNT),0) FROM @budgetCheck2 t WHERE t.WBS_NO = temp.WBS_NO AND t.DOC_NO = temp.DOC_NO AND TRANS = 'REVERSE_COMMIT') = 0

			
			DELETE temp
			FROM @budgetCheck2 temp WHERE TRANS = 'CONVERT_COMMIT' AND TOTAL_AMOUNT = 0 AND RETURN_VALUE = 0

			--SELECT * FROM @budgetCheck
			DECLARE @budgetCheck TABLE (DATA_NO INT, WBS_NO VARCHAR(30), DOC_NO VARCHAR(30), TRANS VARCHAR(30), TOTAL_AMOUNT DECIMAL(18,4), TOTAL_NEW_AMOUNT DECIMAL(18,4), RETURN_VALUE DECIMAL(18,4))

			INSERT INTO @budgetCheck
			SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) DATA_NO,
				   WBS_NO, DOC_NO, TRANS, SUM(TOTAL_AMOUNT), SUM(TOTAL_NEW_AMOUNT), SUM(RETURN_VALUE) 
			FROM @budgetCheck2
			GROUP BY WBS_NO, DOC_NO, TRANS
			
			--Cek amount sama atau tidak untuk proceed ke budget atau tidak ISTD) YHS
			DECLARE @ORI_AMOUNT  DECIMAL(18,3), @NEW_AMOUNT DECIMAL (18,3), @IS_DATA_FROM_DRAFT INT

			SELECT @IS_DATA_FROM_DRAFT = COUNT(0) FROM TB_R_PO_H POH
			INNER JOIN TB_T_PO_ITEM T_POI ON T_POI.PO_NO = POH.PO_NO
			WHERE T_POI.PROCESS_ID = @processId AND DELETE_FLAG ='N' AND ISNULL(T_POI.PO_NO,'') <> '' AND POH.PO_STATUS = '47' -- DRAFT STATUS
		
			--SELECT @ORI_AMOUNT = ORI_AMOUNT, @NEW_AMOUNT = NEW_AMOUNT
			--FROM TB_T_PO_ITEM
			--Fixing Kondisi sebelumnya yang ambigu
			SELECT @ORI_AMOUNT = SUM( ORI_AMOUNT), @NEW_AMOUNT = SUM(CASE WHEN DELETE_FLAG ='Y' THEN 0 ELSE NEW_AMOUNT END)
			FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId --AND DELETE_FLAG ='N'
			
			IF(@ORI_AMOUNT <>@NEW_AMOUNT OR @IS_DATA_FROM_DRAFT>0)
			BEGIN
				SET @poItemGroupedByWBSCount = (SELECT COUNT(0) FROM @budgetCheck)

				DECLARE @poNoForBMS VARCHAR(15)
			
				WHILE (@wbsIdx < @poItemGroupedByWBSCount)
				BEGIN
					SELECT
						@wbsNo = WBS_NO,
						@totalAmount = TOTAL_AMOUNT,
						@totalNewAmount = TOTAL_NEW_AMOUNT,
						@totalReturnAmount = RETURN_VALUE,
						@doc_no = DOC_NO,
						@bmsOperation = TRANS
					FROM @budgetCheck WHERE DATA_NO = @wbsIdx+1
			
					SELECT @message = CAST (TOTAL_AMOUNT AS VARCHAR) FROM @budgetCheck WHERE DATA_NO = @wbsIdx+1
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)


					IF @isPOManual = 1 AND @poNo = '' BEGIN SET @oldPONo = NULL END -- PO MANUAL BARU
					ELSE IF @isPOManual = 1 AND @poNo <> '' BEGIN SET @oldPONo = @poNo + '_001' END -- PO MANUAL EDIT
					ELSE IF @isPOManual = 0 AND @poNo = '' BEGIN SET @oldPONo = (SELECT TOP 1 DOC_NO FROM @budgetCheck WHERE DATA_NO = @wbsIdx+1) END -- PO ADOPT BARU
					ELSE BEGIN SET @oldPONo = @poNo + '_001' END

					SET @poNoForBMS = @exactPONo + '_001'
					IF (@bmsOperation = 'REVERSE_COMMIT') BEGIN 
						SET @poNoForBMS = (SELECT TOP 1 DOC_NO FROM @budgetCheck WHERE DATA_NO = @wbsIdx+1)

						--Pastikan data dari Total new Amount
						--DECLARE @tempReturnAmount DECIMAL(18, 2) = ISNULL(@totalReturnAmount, 0)
						----Tukar nilai returnAmount & newAmount
						--SET @totalNewAmount = @tempReturnAmount
						SET @totalAmount = @totalReturnAmount
						SET @totalReturnAmount = @totalNewAmount
					END
	
					IF (@bmsOperation = 'CONVERT_COMMIT') AND @totalAmount = 0 BEGIN
						SET @totalAmount = ISNULL(@totalNewAmount,0)
					END

					IF (@bmsOperation = 'REV_COMMIT') BEGIN
						SET @poNoForBMS = (SELECT TOP 1 DOC_NO FROM @budgetCheck WHERE DATA_NO = @wbsIdx+1)
						SET @totalAmount = ISNULL(@totalAmount,0)
						SET @totalReturnAmount = 0
					END

					SET @message = 'I|Operation : ' + @bmsOperation + '; Total amount  = ' + cast(@totalAmount as varchar) + '; Total new amount  = ' + cast(@totalNewAmount as varchar) + '; Total return value = ' + cast(@totalReturnAmount as varchar) + ';
							wbs no = ' + @wbsNo + '; old ref = ' + ISNULL(@oldPONo, '') + '; new ref = ' + ISNULL(@poNoForBMS, '') + '; curr = ' + @currency + '; desc = ' + @poDesc + '
						'
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

					IF (@bmsOperation = 'CONVERT_COMMIT')
					BEGIN
						SET @oldPONo = (SELECT TOP 1 DOC_NO FROM @budgetCheck WHERE DATA_NO = @wbsIdx+1)
						--((SELECT SUM((PRI.OPEN_QTY-PRI.USED_QTY)*PRI.PRICE_PER_UOM) FROM TB_R_PR_ITEM PRI 
						--							WHERE PRI.PR_NO = LEFT(@oldPONo, LEN(@oldPONo)-4) AND PRI.ORI_CURR_CD = @currency AND PRI.WBS_NO = @wbsNo)-@totalNewAmount)
						SET @message = 'I|Total amount  = ' + cast(@totalAmount as varchar) + '; Total new amount  = ' + cast(@totalNewAmount as varchar) + '; Total return value = ' + cast(@totalReturnAmount as varchar) + ';
							wbs no = ' + @wbsNo + '; old ref = ' + ISNULL(@oldPONo, '') + '; new ref = ' + ISNULL(@poNoForBMS, '') + '; curr = ' + @currency + '; desc = ' + @poDesc + '
						'
						SET @totalReturnAmount = ISNULL(@totalReturnAmount, 0)
						INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
					END

					SET @message = 'I|Budget ' + @bmsOperation + ' on WBS No: ' + @wbsNo + ' in the amount of: ' + CAST(@totalAmount AS VARCHAR) + ' with New Doc No ' + ISNULL(@poNoForBMS, '') + ' and Ref Doc No' + ISNULL(@oldPONo, '')+ ' start'
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

					-- BMS operation initialization
					--IF (@isPOManual = 1 AND @exactPONo = '') SET @bmsOperation = 'NEW_COMMIT'
					--ELSE IF (@isPOManual = 1 AND @exactPONo <> '') SET @bmsOperation = 'REV_COMMIT'
					--ELSE SET @additionalAct = 'E'

					SET @message = 'I|Total amount  = ' + cast(@totalAmount as varchar) + '; Total return value = ' + cast(@totalReturnAmount as varchar) + ';
						wbs no = ' + @wbsNo + '; old ref = ' + ISNULL(@oldPONo, '') + '; new ref = ' + ISNULL(@poNoForBMS, '') + '; curr = ' + @currency + '; desc = ' + @poDesc 
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

					EXEC @bmsResponse =
						[BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
							@bmsResponseMessage OUTPUT,
							@currentUser,
							@bmsOperation,
							@wbsNo,
							@oldPONo,
							@poNoForBMS,
							@currency,
							@totalAmount,
							@totalReturnAmount,
							@materialNo,
							@poDesc,
							'GPS',
							@additionalAct

					SET @message = 'I|Feedback BMS :: ' + ISNULL(@bmsResponseMessage,'')
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

					-- NOTE: bmsResponse always 0 or 1 String which means Success or Failed respectively
					WHILE (ISNULL(@bmsResponse, '0') <> '0' AND @bmsRetryCounter < 3)
					BEGIN
						-- NOTE: if Failed retry in 1 sec and log
						SET @message = 'I|Budget ' + @bmsOperation + ' Failed on WBS No: ' + @wbsNo + ' in the amount of: ' + CAST(@totalAmount AS VARCHAR) + ' with New Doc No ' + ISNULL(@poNoForBMS, '') + ' and Ref Doc No' + ISNULL(@oldPONo, '') + ': retry'
						INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

						WAITFOR DELAY '00:00:01'
						/*EXEC @bmsResponse =
							[BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
								@bmsResponseMessage OUTPUT, @currentUser, @bmsOperation, @wbsNo, @oldPONo, @poNoForBMS,
								@currency, @totalAmount, @materialNo, @poDesc*/

							EXEC @bmsResponse =
								[BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
									@bmsResponseMessage OUTPUT,
									@currentUser,
									@bmsOperation,
									@wbsNo,
									@oldPONo,
									@poNoForBMS,
									@currency,
									@totalAmount,
									@totalReturnAmount,
									@materialNo,
									@poDesc,
									'GPS',
									@additionalAct
						SET @bmsRetryCounter = @bmsRetryCounter + 1
					END

					IF ISNULL(@bmsResponse, '0') <> '0' BEGIN RAISERROR(@bmsResponseMessage, 16, 1) END

					INSERT INTO @budgetTransactTemp VALUES (@wbsNo, @oldPONo, @poNoForBMS, @currency, @totalAmount, @totalReturnAmount, @bmsOperation, @materialNo, @poDesc)

					SET @message = 'I|Budget ' + @bmsOperation + ' on WBS No: ' + @wbsNo + ' in the amount of: ' + CAST(@totalAmount AS VARCHAR) + ' with New Doc No ' + ISNULL(@poNoForBMS, '') + ' and Ref Doc No' + ISNULL(@oldPONo, '') + ' : end'
					INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
					SET @wbsIdx = @wbsIdx + 1
				END
			END
            --- Budget Update End
        END


        -- Insert or Update
        SET @message = 'I|Insert data to TB_R_PO_H where PO_NO: ' + @poNo + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        DECLARE @delivName VARCHAR(30), @delivAddress VARCHAR(150), @delivPostal VARCHAR(6), @delivCity VARCHAR(30)
        SELECT @delivName = DELIVERY_NAME, @delivAddress = ADDRESS, @delivPostal = POSTAL_CODE, @delivCity = CITY
        FROM TB_M_DELIVERY_ADDR WHERE DELIVERY_ADDR = @deliveryAddress

        IF @poNo = ''
        BEGIN -- Insert
            INSERT INTO TB_R_PO_H
            (PO_NO, PO_DESC, VENDOR_CD, VENDOR_NAME, DOC_DT, PROC_MONTH, PAYMENT_METHOD_CD, PAYMENT_TERM_CD, DOC_TYPE, DOC_CATEGORY,
            PURCHASING_GRP_CD, INV_WO_GR_FLAG, PO_CURR, PO_AMOUNT, PO_EXCHANGE_RATE, LOCAL_CURR, PO_STATUS, RELEASED_FLAG, RELEASED_DT, DELETION_FLAG,
            PROCESS_ID, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT, SAP_DOC_NO, URGENT_DOC, DRAFT_FLAG, DELIVERY_ADDR, SYSTEM_SOURCE,
            REF_NO, PO_NEXT_STATUS, PO_NOTE1, PO_NOTE2, PO_NOTE3, PO_NOTE4, PO_NOTE5, PO_NOTE6, PO_NOTE7, PO_NOTE8, PO_NOTE9, PO_NOTE10,
            VENDOR_ADDRESS, COUNTRY, POSTAL_CODE, CITY, ATTENTION, PHONE, FAX, SAP_PO_NO, SPK_NO, SPK_DT, SPK_BIDDING_DT, SPK_WORK_DESC, SPK_LOCATION,
            SPK_AMOUNT, SPK_PERIOD_START, SPK_PERIOD_END, SPK_RETENTION, SPK_TERMIN_I, SPK_TERMIN_I_DESC, SPK_TERMIN_II, SPK_TERMIN_II_DESC,
            SPK_TERMIN_III, SPK_TERMIN_III_DESC, SPK_TERMIN_IV, SPK_TERMIN_IV_DESC, SPK_TERMIN_V, SPK_TERMIN_V_DESC, SPK_SIGN, SPK_SIGN_NAME,
            DELIVERY_NAME, DELIVERY_ADDRESS, DELIVERY_POSTAL_CODE, DELIVERY_CITY, OTHER_MAIL)
            SELECT @candidatePONo, @poDesc, @vendor, @vendorName, GETDATE(), @procMonth, @paymentMethod, @paymentTerm, 'PO', '',
            @purchasingGroup, NULL, @currency, 0, @exchangeRate, @localCurrency, @poHeaderStatusCode, 'N', NULL, 'N', @processId,
            @currentUser, GETDATE(), NULL, NULL, NULL, @isAnyUrgentDoc, @saveAsDraft, @deliveryAddress, 'GPS', '', @poHeaderNextStatusCode, @poNote1, @poNote2,
            @poNote3, @poNote4, @poNote5, @poNote6, @poNote7, @poNote8, @poNote9, @poNote10, @vendorAddress, @vendorCountry, @vendorPostalCode,
            @vendorCity, @vendorAttention, @vendorPhone, @vendorFax, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @delivName, @delivAddress, @delivPostal, @delivCity, @OtherMail
        END
        ELSE -- Update
        BEGIN
            UPDATE TB_R_PO_H
            SET PO_NO = @poNo, PO_DESC = @poDesc, VENDOR_CD = @vendor, VENDOR_NAME = @vendorName,
            PROC_MONTH = @procMonth, PAYMENT_METHOD_CD = @paymentMethod, PAYMENT_TERM_CD = @paymentTerm,
            PURCHASING_GRP_CD = @purchasingGroup, PO_CURR = @currency, PO_EXCHANGE_RATE = @exchangeRate,
            LOCAL_CURR = @localCurrency, URGENT_DOC = @isAnyUrgentDoc, DRAFT_FLAG = @saveAsDraft,
            DELIVERY_ADDR = @deliveryAddress, CHANGED_BY = @currentUser, CHANGED_DT = GETDATE(),
            PO_NOTE1 = @poNote1, PO_NOTE2 = @poNote2, PO_NOTE3 = @poNote3, PO_NOTE4 = @poNote4,
            PO_NOTE5 = @poNote5, PO_NOTE6 = @poNote6, PO_NOTE7 = @poNote7, PO_NOTE8 = @poNote8,
            PO_NOTE9 = @poNote9, PO_NOTE10 = @poNote10, VENDOR_ADDRESS = @vendorAddress, COUNTRY = @vendorCountry,
            POSTAL_CODE = @vendorPostalCode, CITY = @vendorCity, ATTENTION = @vendorAttention,
            PHONE = @vendorPhone, FAX = @vendorFax, DELIVERY_NAME = @delivName,
            DELIVERY_ADDRESS = @delivAddress, DELIVERY_POSTAL_CODE = @delivPostal, DELIVERY_CITY = @delivCity,
            PROCESS_ID = @processId, OTHER_MAIL = ISNULL(OTHER_MAIL,'') + @OtherMail
            WHERE PO_NO = @poNo AND PROCESS_ID = @processId
        END

INSERT INTO @process_level VALUES(1)

        -- Generate SPK
        DECLARE
            @spkNoCounter VARCHAR(4),
            @spkNo VARCHAR(18),
            @spkDate DATETIME = GETDATE(),
            @signerName VARCHAR(50),
            @signerTitle VARCHAR(50)
        SELECT @spkNo = SPK_NO FROM TB_R_PO_H WHERE PO_NO = @exactPONo
        IF (@isSPKCreated = 1)
        BEGIN
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Saving SPK: begin', @moduleId, @actionName, @functionId, 1, @currentUser)

            IF (ISNULL(@spkNo, '') = '')
            BEGIN
                INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Generate SPK No: begin', @moduleId, @actionName, @functionId, 1, @currentUser)

                SELECT @numberingPrefix = 'SP', @numberingVariant = 'PK'
                SELECT @docNumbering = dbo.GetNextDocNumbering(@numberingPrefix, @numberingVariant)
                INSERT INTO @docNumberingMessage
                SELECT
                    (SELECT Split FROM dbo.SplitString(@docNumbering, '|') WHERE [No] = 2),
                    (SELECT Split FROM dbo.SplitString(@docNumbering, '|') WHERE [No] = 3),
                    (SELECT Split FROM dbo.SplitString(@docNumbering, '|') WHERE [No] = 1)

                IF (SELECT TOP 1 Severity FROM @docNumberingMessage) = 'E'
                BEGIN
                    SET @message = (SELECT TOP 1 [Message] FROM @docNumberingMessage)
                    RAISERROR(@message, 16, 1)
                END

                INSERT INTO @splittedSPKMonth
                SELECT No, Split FROM dbo.SplitString('I,II,III,IV,V,VI,VII,VIII,IX,X,XI,XII', ',')
                SELECT @spkNoCounter = RTRIM(LTRIM((SELECT TOP 1 GeneratedNo FROM @docNumberingMessage)))
                SELECT @spkNo = 'SPK/' + @spkNoCounter + '/E/' + (SELECT Split FROM @splittedSPKMonth WHERE No = MONTH(@spkDate)) + '/' + CAST(YEAR(@spkDate) AS VARCHAR)
                SET @message = 'I|Generated SPK No: ' + @spkNo
                INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

                -- Reserve SPKNo
                UPDATE TB_M_DOC_NUMBERING SET CURRENT_NUMBER = @spkNoCounter
                WHERE NUMBERING_PREFIX = 'SP' AND VARIANT = 'PK'

                -- Update SPK No in POH
                UPDATE TB_R_PO_H SET SPK_NO = @spkNo WHERE PO_NO = @exactPONo

                -- Always archive
                INSERT INTO TB_H_SPK
                (PROCESS_ID, PR_NO, PO_NO, SPK_NO, SPK_DT, SPK_BIDDING_DT, SPK_PARAGRAPH1, SPK_WORK_DESC, SPK_LOCATION, SPK_AMOUNT,
                SPK_PERIOD_START, SPK_PERIOD_END, SPK_RETENTION, SPK_TERMIN_I, SPK_TERMIN_I_DESC, SPK_TERMIN_II, SPK_TERMIN_II_DESC,
                SPK_TERMIN_III, SPK_TERMIN_III_DESC, SPK_TERMIN_IV, SPK_TERMIN_IV_DESC, SPK_TERMIN_V, SPK_TERMIN_V_DESC, SPK_SIGN,
                SPK_SIGN_NAME, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT)
                VALUES (@processId, @poNo, @poNo, @spkNo, @spkDate, @biddingDate, REPLACE(@spkOpening, '[enter]', '<br/>'), @spkWork,
                @spkLocation, @spkAmount, @spkPeriodStart, @spkPeriodEnd, @spkRetention, @terminI, @terminIDesc, @terminII, @terminIIDesc,
                @terminIII, @terminIIIDesc, @terminIV, @terminIVDesc, @terminV, @terminVDesc, @signerTitle, @signerName, @currentUser,
                GETDATE(), NULL, NULL)

                INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Generate SPK No: end', @moduleId, @actionName, @functionId, 1, @currentUser)
            END

            IF ISNULL(@spkAmount, 0) > 0 AND @spkAmount >= 1000000000
            BEGIN
                SELECT TOP 1
                    @signerName = dbo.TitleCase(se.PERSONNEL_NAME),
                    @signerTitle = dbo.TitleCase(se.JOB_TITLE)
                FROM dbo.TB_R_SYNCH_EMPLOYEE se
                JOIN dbo.TB_M_ORG_POSITION op ON se.POSITION_LEVEL = op.POSITION_LEVEL
                WHERE se.ORG_ID IN (SELECT OrgId FROM @orgRef GROUP BY OrgId)
                AND op.LEVEL_ID IN (0, 1) -- NOTE: Director or BOD
                ORDER BY op.LEVEL_ID DESC, se.POSITION_LEVEL ASC
            END
            IF ISNULL(@spkAmount, 0) > 0 AND @spkAmount < 1000000000
            BEGIN
                SELECT TOP 1
                    @signerName = dbo.TitleCase(se.PERSONNEL_NAME),
                    @signerTitle = dbo.TitleCase(se.JOB_TITLE)
                FROM dbo.TB_R_SYNCH_EMPLOYEE se
                JOIN dbo.TB_M_ORG_POSITION op ON se.POSITION_LEVEL = op.POSITION_LEVEL
                WHERE se.ORG_ID IN (SELECT OrgId FROM @orgRef GROUP BY OrgId)
                AND op.LEVEL_ID = 2 -- NOTE: DH
                ORDER BY op.LEVEL_ID DESC, se.POSITION_LEVEL ASC
            END

            UPDATE TB_R_PO_H SET
            SPK_DT = GETDATE(), SPK_BIDDING_DT = @biddingDate, SPK_PARAGRAPH1 = REPLACE(@spkOpening, '[enter]', '<br/>'),
            SPK_WORK_DESC = @spkWork, SPK_LOCATION = @spkLocation, SPK_AMOUNT = @spkAmount, SPK_PERIOD_START = @spkPeriodStart,
            SPK_PERIOD_END = @spkPeriodEnd, SPK_RETENTION = @spkRetention, SPK_TERMIN_I = @terminI,
            SPK_TERMIN_I_DESC = @terminIDesc, SPK_TERMIN_II = @terminII, SPK_TERMIN_II_DESC = @terminIIDesc,
            SPK_TERMIN_III = @terminIII, SPK_TERMIN_III_DESC = @terminIIIDesc, SPK_TERMIN_IV = @terminIV,
            SPK_TERMIN_IV_DESC = @terminIVDesc, SPK_TERMIN_V = @terminV, SPK_TERMIN_V_DESC = @terminVDesc,
            SPK_SIGN = @signerTitle, SPK_SIGN_NAME = @signerName
            WHERE PO_NO = @exactPONo

            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Saving SPK: end', @moduleId, @actionName, @functionId, 1, @currentUser)
INSERT INTO @process_level VALUES(2)
        END

        SET @message = '|Insert data to TB_R_PO_H where PO_NO: ' + @poNo + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        DECLARE @poCreatorStatusCode VARCHAR(5) = '40', @poNextStatus VARCHAR(5) = '41', @poApprovalSegmentCode VARCHAR(5) = '4', @itemIdx INT = 0, @detailItemDataCount INT
        DECLARE @poApprovalSegment APPROVAL_TEMP
        INSERT INTO @poApprovalSegment SELECT @orgId, @positionLevel, @functionId
        UNION
        SELECT ORG_ID, POSITION_LEVEL, @functionId FROM TB_R_SYNCH_EMPLOYEE
        WHERE DIVISION_ID = @divisionId AND DEPARTMENT_ID = @departmentId AND SECTION_ID = @sectionId AND POSITION_LEVEL = 50 AND GETDATE() BETWEEN VALID_FROM AND VALID_TO
        UNION SELECT ORG_ID, POSITION_LEVEL, @functionId FROM TB_R_SYNCH_EMPLOYEE
        WHERE DIVISION_ID = @divisionId AND DEPARTMENT_ID = @departmentId AND POSITION_LEVEL = 40 AND GETDATE() BETWEEN VALID_FROM AND VALID_TO
        UNION SELECT ORG_ID, POSITION_LEVEL, @functionId FROM TB_R_SYNCH_EMPLOYEE
        WHERE DIVISION_ID = @divisionId AND POSITION_LEVEL = 30 AND GETDATE() BETWEEN VALID_FROM AND VALID_TO

        -- Move temp (TB_T) to it's real table (TB_R)
        SET @message = 'I|Insert data to TB_R_PO_ITEM where PO_NO: ' + ISNULL(@poNo, 'NULL') + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        DECLARE
            @lastItemNo INT = (SELECT ISNULL(MAX(PO_ITEM_NO), 0) FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId),
            @lastSubItemNo INT = (SELECT ISNULL(MAX(PO_SUBITEM_NO), 0) FROM TB_T_PO_SUBITEM WHERE PROCESS_ID =  @processId)

        /*
        NOTE: SQL Server 2008+ only
        http://stackoverflow.com/questions/224732/sql-update-from-one-table-to-another-based-on-a-id-match
        http://stackoverflow.com/a/9241260/1181782
        */

        -- Delete matching rows first
        MERGE TB_R_PO_ITEM poi USING TB_T_PO_ITEM poit
        ON poi.PO_NO = ISNULL(poit.PO_NO, '') AND poi.PO_ITEM_NO = ISNULL(poit.PO_ITEM_NO, '')
        AND poi.PR_NO = ISNULL(poit.PR_NO, '') AND poi.PR_ITEM_NO = ISNULL(poit.PR_ITEM_NO, '')
        AND poit.PROCESS_ID = @processId AND poit.DELETE_FLAG = 'Y' AND poit.NEW_FLAG = 'N'
        WHEN MATCHED THEN DELETE
        ;

        -- Rollback budget here

        -- Then update matching rows
        MERGE INTO TB_R_PO_ITEM poi USING TB_T_PO_ITEM poit
        ON poi.PO_NO = ISNULL(poit.PO_NO, '') AND poi.PO_ITEM_NO = ISNULL(poit.PO_ITEM_NO, '')
        AND poi.PR_NO = ISNULL(poit.PR_NO, '') AND poi.PR_ITEM_NO = ISNULL(poit.PR_ITEM_NO, '')
        AND poit.PROCESS_ID = @processId
        AND poit.UPDATE_FLAG = 'Y' AND poit.NEW_FLAG = 'N' AND poit.DELETE_FLAG = 'N'
        WHEN MATCHED THEN
        UPDATE SET
        poi.MAT_DESC = poit.MAT_DESC,
        poi.PO_QTY_ORI = poit.PO_QTY_NEW,
        poi.PO_QTY_REMAIN = poit.PO_QTY_NEW - poi.PO_QTY_USED,
        poi.PRICE_PER_UOM = poit.NEW_PRICE_PER_UOM, poi.DELIVERY_PLAN_DT = poit.DELIVERY_PLAN_DT,
        poi.ORI_AMOUNT = poit.NEW_AMOUNT, poi.LOCAL_AMOUNT = poit.NEW_LOCAL_AMOUNT, poi.CHANGED_BY = @currentUser, poi.CHANGED_DT = GETDATE()
        ;

		-- Remarked as Requested by Yanes H Sui
        -- Validate source list before add item
        --DECLARE @notRegistered TABLE ( DataNo INT, MatNo VARCHAR(23), Plant VARCHAR(4) )
        --INSERT INTO @notRegistered
        --SELECT DISTINCT DENSE_RANK() OVER ( ORDER BY Plant ASC), MatNo, Plant
        --FROM (
        --    SELECT poit.MAT_NO MatNo, @vendor Vendor, @procChannel ProcChannel, poit.PLANT_CD Plant, sl.MAT_NO SourceListMatNo
        --    FROM TB_T_PO_ITEM poit
        --    LEFT JOIN (SELECT * FROM TB_M_SOURCE_LIST WHERE VENDOR_CD = @vendor AND PROC_CHANNEL_CD = @procChannel AND YEAR(VALID_DT_TO) = 9999) sl
        --    ON poit.PLANT_CD = sl.PLANT_CD AND poit.MAT_NO = sl.MAT_NO
        --    WHERE poit.PROCESS_ID = @processId AND NEW_FLAG = 'Y'
        --    AND poit.DELETE_FLAG = 'N' AND ISNULL(poit.MAT_NO, '') <> '' AND poit.ITEM_CLASS = 'M'
        --) sourceList
        --WHERE SourceListMatNo IS NULL GROUP BY Plant, MatNo

        --IF (EXISTS(SELECT MatNo FROM @notRegistered))
        --BEGIN
        --    SET @message = ''
        --    DECLARE @notRegCounter INT = 1, @notRegCount INT = (SELECT COUNT(0) FROM @notRegistered), @notRegMatNo VARCHAR(MAX), @notRegPlant VARCHAR(4)
        --    WHILE(@notRegCounter <= @notRegCount)
        --    BEGIN
        --        SELECT @notRegMatNo = STUFF (
        --            (SELECT ', ' + CAST(MatNo AS VARCHAR) FROM @notRegistered
        --            WHERE DataNo = @notRegCounter FOR XML PATH('')),
        --        1, 2, '')
        --        SET @notRegPlant = (SELECT DISTINCT Plant FROM @notRegistered WHERE DataNo = @notRegCounter)
        --        SET @message = @message + 'Material ' + @notRegMatNo + ' is not registered in Source List with Vendor ' + @vendor + ', Procurement Channel ' + @procChannel + ' and Plant ' + @notRegPlant + '{newline}'

        --        SET @notRegCounter = @notRegCounter + 1
        --    END

        --    RAISERROR(@message, 16, 1)
        --END

        -- Lastly insert all new rows
        INSERT INTO TB_R_PO_ITEM
        (PO_NO, PO_ITEM_NO, PR_NO, PR_ITEM_NO, MAT_NO, MAT_DESC, VALUATION_CLASS, VALUATION_CLASS_DESC, PROCUREMENT_PURPOSE, DELIVERY_PLAN_DT,
        SOURCE_TYPE, PLANT_CD, SLOC_CD, DIVISION_ID, DIVISION_NAME, WBS_NO, COST_CENTER_CD, UNLIMITED_FLAG, TOLERANCE_PERCENTAGE, SPECIAL_PROCUREMENT_TYPE,
        PO_QTY_ORI, PO_QTY_USED, PO_QTY_REMAIN, UOM, PRICE_PER_UOM, ORI_AMOUNT, LOCAL_AMOUNT, PO_STATUS, PO_NEXT_STATUS, IS_REJECTED,
        CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT, WBS_NAME, GL_ACCOUNT, RELEASE_FLAG, IS_PARENT, ITEM_CLASS, GROSS_PERCENT, URGENT_DOC)
        SELECT @exactPONo PO_NO, ISNULL(tmp.PO_ITEM_NO, tmp.DATA_NO) PO_ITEM_NO, tmp.PR_NO, tmp.PR_ITEM_NO, tmp.MAT_NO, tmp.MAT_DESC, tmp.VALUATION_CLASS,
        (SELECT TOP 1 VALUATION_CLASS_DESC FROM TB_M_VALUATION_CLASS WHERE VALUATION_CLASS = tmp.VALUATION_CLASS) VALUATION_CLASS_DESC, tmp.PROCUREMENT_PURPOSE,
        tmp.DELIVERY_PLAN_DT, tmp.SOURCE_TYPE, tmp.PLANT_CD, tmp.SLOC_CD, @divisionId DIVISION_ID, @divisionName DIVISION_NAME, tmp.WBS_NO, tmp.COST_CENTER_CD,
        tmp.UNLIMITED_FLAG, tmp.TOLERANCE_PERCENTAGE, tmp.SPECIAL_PROCUREMENT_TYPE, tmp.PO_QTY_NEW, tmp.PO_QTY_USED, (tmp.PO_QTY_NEW-tmp.PO_QTY_USED), tmp.UOM, tmp.NEW_PRICE_PER_UOM,
        tmp.NEW_AMOUNT, tmp.NEW_LOCAL_AMOUNT, @poCreatorStatusCode PO_STATUS, @poNextStatus PO_NEXT_STATUS, 'N' IS_REJECTED, tmp.CREATED_BY,
        tmp.CREATED_DT, NULL CHANGED_BY, NULL CHANGED_DT, tmp.WBS_NAME, tmp.GL_ACCOUNT, 'N' RELEASE_FLAG, tmp.IS_PARENT, tmp.ITEM_CLASS, tmp.GROSS_PERCENT, tmp.URGENT_DOC
        FROM (SELECT dbo.GetZeroPaddedNo(5, (@lastItemNo + (ROW_NUMBER() OVER (ORDER BY PO_NO ASC, PO_ITEM_NO ASC, SEQ_ITEM_NO ASC)* 10)) ) DATA_NO, *
            FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId AND NEW_FLAG = 'Y' AND DELETE_FLAG = 'N'
        ) tmp

  --      -- Don't forget to decrease Adopted PR Qty
  --      MERGE INTO TB_R_PR_ITEM pri USING (
  --          SELECT poit.PROCESS_ID, poit.PR_NO, poit.PR_ITEM_NO, --ass.ASSET_NO,
  --          SUM(poit.PO_QTY_NEW) PO_QTY_NEW, SUM(poit.PO_QTY_ORI) PO_QTY_ORI, poit.DELETE_FLAG FROM TB_T_PO_ITEM poit
  --          --LEFT JOIN TB_R_ASSET ass ON poit.PR_NO = ass.PR_NO AND poit.PR_ITEM_NO = ass.PR_ITEM_NO AND poit.ASSET_NO = ass.ASSET_NO
  --          WHERE poit.PROCESS_ID = @processId AND poit.DELETE_FLAG = 'N'
  --          GROUP BY poit.PROCESS_ID, poit.PR_NO, poit.PR_ITEM_NO,
  --          --ass.ASSET_NO,
  --          poit.DELETE_FLAG
  --      ) tmp ON pri.PR_NO = ISNULL(tmp.PR_NO, '') AND pri.PR_ITEM_NO = ISNULL(tmp.PR_ITEM_NO, '')
  --      --AND ISNULL(pri.ASSET_NO, '') = ISNULL(tmp.ASSET_NO, '') AND pri.OPEN_QTY > 0
  --      WHEN MATCHED THEN
  --      UPDATE SET
  --      pri.OPEN_QTY = pri.OPEN_QTY + (tmp.PO_QTY_ORI - tmp.PO_QTY_NEW),
  --      pri.USED_QTY = pri.USED_QTY + (tmp.PO_QTY_NEW - tmp.PO_QTY_ORI),
		----add info PO No in TB_R_PR_ITEM 25/11/2016
		--PO_NO = @exactPONo
  --      ;

		---- Don't forget also to decrease Adopted PR Qty for deletion Flag 'Y'
  --      MERGE INTO TB_R_PR_ITEM pri USING (
  --          SELECT poit.PROCESS_ID, poit.PR_NO, poit.PR_ITEM_NO, --ass.ASSET_NO,
  --          SUM(poit.PO_QTY_NEW) PO_QTY_NEW, SUM(poit.PO_QTY_ORI) PO_QTY_ORI FROM TB_T_PO_ITEM poit
  --          --LEFT JOIN TB_R_ASSET ass ON poit.PR_NO = ass.PR_NO AND poit.PR_ITEM_NO = ass.PR_ITEM_NO AND poit.ASSET_NO = ass.ASSET_NO
  --          WHERE poit.PROCESS_ID = @processId AND poit.DELETE_FLAG = 'Y' AND NEW_FLAG = 'N'
  --          GROUP BY poit.PROCESS_ID, poit.PR_NO, poit.PR_ITEM_NO
  --      ) tmp ON pri.PR_NO = ISNULL(tmp.PR_NO, '') AND pri.PR_ITEM_NO = ISNULL(tmp.PR_ITEM_NO, '')
  --      --AND ISNULL(pri.ASSET_NO, '') = ISNULL(tmp.ASSET_NO, '') AND pri.OPEN_QTY > 0
  --      WHEN MATCHED THEN
  --      UPDATE SET
  --      pri.OPEN_QTY = pri.OPEN_QTY + (tmp.PO_QTY_NEW),
  --      pri.USED_QTY = pri.USED_QTY - (tmp.PO_QTY_NEW),
		----add info PO No in TB_R_PR_ITEM 25/11/2016
		--PO_NO = @exactPONo
  --      ;

		UPDATE temp
			SET USED_QTY = CASE WHEN  (poit.DELETE_FLAG = 'Y' AND poit.UPDATE_FLAG ='Y') THEN USED_QTY - poit.PO_QTY_ORI  ELSE  poit.PO_QTY_NEW +  ISNULL((SELECT SUM(POI.PO_QTY_ORI) FROM TB_R_PO_ITEM POI WHERE POI.PR_NO = poit.PR_NO AND POI.PR_ITEM_NO = poit.PR_ITEM_NO AND POI.PO_NO <> @exactPONo AND POI.PO_STATUS NOT IN ('45', '48', '49')),0) END, 
			    OPEN_QTY = CASE WHEN  (poit.DELETE_FLAG = 'Y' AND poit.UPDATE_FLAG ='Y') THEN 
							OPEN_QTY + poit.PO_QTY_ORI
						   ELSE 
							(temp.PR_QTY - poit.PO_QTY_NEW) - ISNULL((SELECT SUM(POI.PO_QTY_ORI) FROM TB_R_PO_ITEM POI WHERE POI.PR_NO = poit.PR_NO AND POI.PR_ITEM_NO = poit.PR_ITEM_NO AND POI.PO_NO <> @exactPONo AND POI.PO_STATUS NOT IN ('45', '48', '49')),0)
						   END,
				----add info PO No in TB_R_PR_ITEM 25/11/2016
				PO_NO = @exactPONo
		FROM TB_R_PR_ITEM temp
		INNER JOIN TB_T_PO_ITEM poit ON poit.PR_NO = temp.PR_NO AND poit.PR_ITEM_NO = temp.PR_ITEM_NO AND poit.PROCESS_ID =@processId AND (poit.DELETE_FLAG= 'N' OR (poit.DELETE_FLAG = 'Y' AND poit.UPDATE_FLAG ='Y'))
		

        INSERT INTO @process_level VALUES(3)

        SET @message = 'I|Insert data to TB_R_PO_ITEM where PO_NO: ' + ISNULL(@poNo, 'NULL') + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        SET @message = 'I|Insert data to TB_R_PO_CONDITION where PO_NO: ' + ISNULL(@poNo, 'NULL') + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        -- Delete matching rows first
        MERGE INTO TB_R_PO_CONDITION poc USING (
            SELECT poct.* FROM TB_T_PO_CONDITION poct
            JOIN TB_T_PO_ITEM poit ON poct.PROCESS_ID = poit.PROCESS_ID
            AND poit.DELETE_FLAG = 'Y' AND poct.SEQ_ITEM_NO = poit.SEQ_ITEM_NO
            AND poct.PROCESS_ID = @processId AND poct.DELETE_FLAG = 'Y' AND poct.NEW_FLAG = 'N') tmp
        ON poc.PO_NO = ISNULL(tmp.PO_NO, '') AND poc.PO_ITEM_NO = ISNULL(tmp.PO_ITEM_NO, '')
        AND poc.COMP_PRICE_CD = tmp.COMP_PRICE_CD
        WHEN MATCHED THEN DELETE
        ;

        -- Then update matching rows
        MERGE INTO TB_R_PO_CONDITION poc USING (
            SELECT poct.* FROM TB_T_PO_CONDITION poct
            JOIN TB_T_PO_ITEM poit ON poct.PROCESS_ID = poit.PROCESS_ID
            AND poit.DELETE_FLAG = 'N' AND poct.SEQ_ITEM_NO = poit.SEQ_ITEM_NO
            AND poct.PROCESS_ID = @processId AND poct.UPDATE_FLAG = 'Y'
            AND poct.NEW_FLAG = 'N' AND poct.DELETE_FLAG = 'N') tmp
        ON poc.PO_NO = ISNULL(tmp.PO_NO, '') AND poc.PO_ITEM_NO = ISNULL(tmp.PO_ITEM_NO, '')
        AND poc.COMP_PRICE_CD = tmp.COMP_PRICE_CD
        WHEN MATCHED THEN
        UPDATE SET
        poc.CALCULATION_TYPE = tmp.CALCULATION_TYPE,
        poc.QTY_PER_UOM = tmp.QTY_PER_UOM, poc.COMP_PRICE_RATE = tmp.COMP_PRICE_RATE,
        poc.PRICE_AMT = tmp.PRICE_AMT, poc.CHANGED_BY = @currentUser, poc.CHANGED_DT = GETDATE()
        ;

        -- Lastly insert all new rows
        INSERT INTO TB_R_PO_CONDITION
        (PO_NO, PO_ITEM_NO, COMP_PRICE_CD, COMP_PRICE_RATE, INVOICE_FLAG, EXCHANGE_RATE, SEQ_NO, BASE_VALUE_FROM, BASE_VALUE_TO, PO_CURR,
        INVENTORY_FLAG, CALCULATION_TYPE, PLUS_MINUS_FLAG, CONDITION_CATEGORY, ACCRUAL_FLAG_TYPE, CONDITION_RULE, QTY, QTY_PER_UOM, PRICE_AMT, COMP_TYPE,
        PRINT_STATUS, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT)
        SELECT @exactPONo, ISNULL(tmp.PO_ITEM_NO, tmp.PO_ITEM_NO_2), tmp.COMP_PRICE_CD, tmp.COMP_PRICE_RATE, tmp.INVOICE_FLAG, tmp.EXCHANGE_RATE,
        tmp.SEQ_NO, tmp.BASE_VALUE_FROM, tmp.BASE_VALUE_TO, tmp.PO_CURR, tmp.INVENTORY_FLAG, tmp.CALCULATION_TYPE, tmp.PLUS_MINUS_FLAG,
        tmp.CONDITION_CATEGORY, tmp.ACCRUAL_FLAG_TYPE, tmp.CONDITION_RULE, tmp.QTY, tmp.QTY_PER_UOM, tmp.PRICE_AMT, tmp.COMP_TYPE, tmp.PRINT_STATUS,
        tmp.CREATED_BY, tmp.CREATED_DT, NULL, NULL
        FROM (SELECT poit.PO_ITEM_NO_2, poct.* FROM TB_T_PO_CONDITION poct
        JOIN (
            SELECT ISNULL(PO_ITEM_NO, dbo.GetZeroPaddedNo(5, (@lastItemNo + (ROW_NUMBER() OVER (ORDER BY PO_NO ASC, PO_ITEM_NO ASC, SEQ_ITEM_NO ASC) * 10)))) PO_ITEM_NO_2, *
            FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId AND DELETE_FLAG = 'N') poit
        ON poct.PROCESS_ID = poit.PROCESS_ID AND poct.SEQ_ITEM_NO = poit.SEQ_ITEM_NO
        AND poct.PROCESS_ID = @processId AND poct.NEW_FLAG = 'Y' AND poct.DELETE_FLAG = 'N') tmp

INSERT INTO @process_level VALUES(4)

        SET @message = 'I|Insert data to TB_R_PO_CONDITION where PO_NO: ' + ISNULL(@poNo, 'NULL') + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        SET @message = 'I|Insert data to TB_R_PO_SUBITEM where PO_NO: ' + ISNULL(@poNo, 'NULL') + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        -- Delete matching rows first
        MERGE INTO TB_R_PO_SUBITEM posi USING (
            SELECT posit.* FROM TB_T_PO_SUBITEM posit
            JOIN TB_T_PO_ITEM poit ON posit.PROCESS_ID = poit.PROCESS_ID
            AND poit.DELETE_FLAG = 'Y' AND posit.SEQ_ITEM_NO = poit.SEQ_ITEM_NO
            AND posit.PROCESS_ID = @processId AND posit.DELETE_FLAG = 'Y' AND posit.NEW_FLAG = 'N') tmp
        ON posi.PO_NO = ISNULL(tmp.PO_NO, '') AND posi.PO_ITEM_NO = ISNULL(tmp.PO_ITEM_NO, '')  and posi.PO_SUBITEM_NO = ISNULL(tmp.PO_SUBITEM_NO, '')
        WHEN MATCHED THEN DELETE
        ;

        -- Then update matching rows
        MERGE INTO TB_R_PO_SUBITEM posi USING (
            SELECT posit.* FROM TB_T_PO_SUBITEM posit
            JOIN TB_T_PO_ITEM poit ON posit.PROCESS_ID = poit.PROCESS_ID
            AND poit.DELETE_FLAG = 'N' AND posit.SEQ_ITEM_NO = poit.SEQ_ITEM_NO
            AND posit.PROCESS_ID = @processId AND posit.UPDATE_FLAG = 'Y'
            AND posit.NEW_FLAG = 'N' AND posit.DELETE_FLAG = 'N') tmp
        ON posi.PO_NO = ISNULL(tmp.PO_NO, '') AND posi.PO_ITEM_NO = ISNULL(tmp.PO_ITEM_NO, '') AND posi.PO_SUBITEM_NO = tmp.PO_SUBITEM_NO
        WHEN MATCHED THEN
        UPDATE SET
        posi.PRICE_PER_UOM = tmp.PRICE_PER_UOM,
        posi.PO_QTY_ORI = tmp.PO_QTY_NEW,
        posi.CHANGED_BY = @currentUser,
        posi.CHANGED_DT = GETDATE()
        ;

        -- Lastly insert all new rows
        INSERT INTO TB_R_PO_SUBITEM
        (PO_NO, PO_ITEM_NO, PO_SUBITEM_NO, MAT_NO, MAT_DESC, WBS_NO, WBS_NAME, GL_ACCOUNT, COST_CENTER_CD, UNLIMITED_FLAG,
        TOLERANCE_PERCENTAGE, SPECIAL_PROCUREMENT_TYPE, PO_QTY_ORI, PO_QTY_USED, PO_QTY_REMAIN, UOM, PRICE_PER_UOM, ORI_AMOUNT, LOCAL_AMOUNT, CREATED_BY,
        CREATED_DT, CHANGED_BY, CHANGED_DT, PR_NO, PR_ITEM_NO, PR_SUBITEM_NO)
        SELECT @exactPONo, ISNULL(tmp.PO_ITEM_NO, tmp.PO_ITEM_NO_2), ISNULL(tmp.PO_SUBITEM_NO, tmp.DATA_NO), tmp.MAT_NO, tmp.MAT_DESC, tmp.WBS_NO,
        (SELECT TOP 1 WBS_NAME FROM TB_R_WBS WHERE WBS_NO = tmp.WBS_NO), tmp.GL_ACCOUNT, tmp.COST_CENTER_CD, 'N', 0, 'N', tmp.PO_QTY_NEW, tmp.PO_QTY_USED,
        tmp.PO_QTY_NEW-tmp.PO_QTY_USED, tmp.UOM, tmp.PRICE_PER_UOM, tmp.AMOUNT, tmp.LOCAL_AMOUNT, tmp.CREATED_BY, tmp.CREATED_DT, NULL, NULL,
		PR_NO, PR_ITEM_NO, PR_SUBITEM_NO
        FROM (
            SELECT dbo.GetZeroPaddedNo(5, (@lastSubItemNo + (ROW_NUMBER() OVER (ORDER BY (SELECT NULL))*10))) DATA_NO, poit.PO_ITEM_NO_2, posit.*
            FROM TB_T_PO_SUBITEM posit
            JOIN (
                SELECT ISNULL(PO_ITEM_NO, dbo.GetZeroPaddedNo(5, (@lastItemNo + (ROW_NUMBER() OVER (ORDER BY PO_NO ASC, PO_ITEM_NO ASC, SEQ_ITEM_NO ASC)*10)))) PO_ITEM_NO_2, *
                FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId AND DELETE_FLAG = 'N') poit
            ON posit.PROCESS_ID = poit.PROCESS_ID AND posit.SEQ_ITEM_NO = poit.SEQ_ITEM_NO
        AND posit.PROCESS_ID = @processId AND posit.NEW_FLAG = 'Y' AND posit.DELETE_FLAG = 'N') tmp

INSERT INTO @process_level VALUES(5)

        SET @message = 'I|Insert data to TB_R_PO_SUBITEM where PO_NO: ' + ISNULL(@poNo, 'NULL') + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        SET @message = 'I|Update PO_NO: ' + @poNo + ' to TB_R_ASSET: begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        --MERGE INTO TB_R_ASSET ass USING (
        --    SELECT poit.PROCESS_ID, poit.PR_NO,
        --    poit.PR_ITEM_NO, tmppoi.PO_NO,
        --    tmppoi.PO_ITEM_NO, poit.ASSET_NO,
        --    poit.SUB_ASSET_NO
        --    FROM TB_T_PO_ITEM poit
        --    JOIN (
        --        SELECT ROW_NUMBER() OVER (ORDER BY poii.PO_NO ASC, poii.PO_ITEM_NO ASC) DataNo, poii.*
        --        FROM TB_R_PO_ITEM poii WHERE poii.PO_NO = @exactPONo
        --    ) tmppoi ON poit.PR_NO = tmppoi.PR_NO AND poit.PR_ITEM_NO = tmppoi.PR_ITEM_NO
        --    AND poit.SEQ_ITEM_NO = tmppoi.DataNo AND poit.PROCESS_ID = @processId
        --    AND poit.DELETE_FLAG = 'N'
        --) tmp
        --ON ass.PR_NO = tmp.PR_NO AND ass.PR_ITEM_NO = tmp.PR_ITEM_NO
        --AND ass.ASSET_NO = tmp.ASSET_NO AND ISNULL(ass.SUB_ASSET_NO, '') = ISNULL(tmp.SUB_ASSET_NO, '')
        --AND ass.PROCESS_ID = tmp.PROCESS_ID
        --WHEN MATCHED THEN
        --UPDATE SET ass.PO_NO = tmp.PO_NO, ass.PO_ITEM_NO = tmp.PO_ITEM_NO, ass.CHANGED_BY = @currentUser, ass.CHANGED_DT = GETDATE()
        --;

		UPDATE ass
			SET ass.PO_NO = @exactPONo, 
				ass.PO_ITEM_NO = ISNULL(tmp.PO_ITEM_NO, tmp.DATA_NO), 
				ass.CHANGED_BY = @currentUser, 
				ass.CHANGED_DT = GETDATE()
		FROM TB_R_ASSET ass 
		JOIN (SELECT dbo.GetZeroPaddedNo(5, (@lastItemNo + (ROW_NUMBER() OVER (ORDER BY PO_NO ASC, PO_ITEM_NO ASC, SEQ_ITEM_NO ASC) * 10))) DATA_NO, *
            FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId AND DELETE_FLAG = 'N'
        ) tmp ON tmp.PR_NO = ass.PR_NO AND tmp.PR_ITEM_NO = ass.PR_ITEM_NO


        SET @message = 'I|Update PO_NO: ' + @poNo + ' to TB_R_ASSET: end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        UPDATE TB_R_PO_H SET PO_AMOUNT = (SELECT SUM(ORI_AMOUNT) FROM TB_R_PO_ITEM WHERE PO_NO = @exactPONo) WHERE PO_NO = @exactPONo

INSERT INTO @process_level VALUES(6)

        -- Move temp upload
        DELETE RA
        FROM TB_R_ATTACHMENT RA JOIN TB_T_ATTACHMENT TA ON RA.DOC_NO = TA.DOC_NO AND RA.SEQ_NO = TA.SEQ_NO
        WHERE RA.DOC_NO = @poNo AND TA.DELETE_FLAG = 'Y' AND TA.NEW_FLAG <> 'Y'

        INSERT INTO TB_R_ATTACHMENT
        (DOC_NO, SEQ_NO, DOC_SOURCE, DOC_TYPE, FILE_PATH, FILE_NAME_ORI, FILE_EXTENSION, FILE_SIZE, PROCESS_ID,
        CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT)
        SELECT @exactPONo, SEQ_NO, 'PO', DOC_TYPE, FILE_PATH, [FILE_NAME_ORI], FILE_EXTENSION, FILE_SIZE, @processId, @currentUser, GETDATE(), NULL, NULL
        FROM TB_T_ATTACHMENT WHERE PROCESS_ID = @processId AND DOC_NO = @poNo AND DELETE_FLAG <> 'Y' AND NEW_FLAG = 'Y'

INSERT INTO @process_level VALUES(7)

        IF @saveAsDraft = 0
        BEGIN
            -- Set Worklist
            SET @message = 'I|Insert data to TB_M_WORKFLOW where PO_NO: ' + @exactPONo + ': begin'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            DECLARE
                @approvalFunctionId VARCHAR(6) = '303001',
                @defaultInterval INT = (SELECT ISNULL(MAX(CAST(mvc.APPROVAL_INTERVAL AS INT)), 0) FROM TB_T_PO_ITEM poi JOIN TB_M_VALUATION_CLASS mvc ON poi.VALUATION_CLASS = mvc.VALUATION_CLASS WHERE poi.PROCESS_ID = @processId ),
                @sumOriAmount DECIMAL(18, 4) = (SELECT SUM(ORI_LOCAL_AMOUNT) FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId),
                @sumNewAmount DECIMAL(18, 4) = (SELECT SUM(NEW_LOCAL_AMOUNT) FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId),
                @exactItemNo VARCHAR(5) = '00000'

            IF @sumNewAmount > @sumOriAmount
            BEGIN
                DELETE FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @exactPONo
                UPDATE TB_R_PO_H SET PO_STATUS = '40', PO_NEXT_STATUS = '41' WHERE PO_NO = @exactPONo
                UPDATE TB_R_PO_ITEM SET PO_STATUS = '40', PO_NEXT_STATUS = '41' WHERE PO_NO = @exactPONo
            END

            IF (NOT EXISTS(SELECT DOCUMENT_NO FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @exactPONo))
            BEGIN
                -- Creator approval workflow
                INSERT INTO TB_R_WORKFLOW
                (DOCUMENT_NO, ITEM_NO, DOCUMENT_SEQ, APPROVAL_CD, APPROVAL_DESC, APPROVED_BY, NOREG, APPROVED_BYPASS, APPROVED_DT, STRUCTURE_ID,
                STRUCTURE_NAME, APPROVER_POSITION, IS_APPROVED, IS_REJECTED, IS_DISPLAY, LIMIT_FLAG, MAX_AMOUNT, CREATED_BY, CREATED_DT, CHANGED_BY,
                CHANGED_DT, IS_CANCELLED, APPROVER_NAME, APPROVAL_INTERVAL, INTERVAL_DATE, RELEASE_FLAG)
                SELECT @exactPONo, @exactItemNo, 1, '40', (SELECT TOP 1 STATUS_DESC FROM TB_M_STATUS WHERE STATUS_CD = '40' AND DOC_TYPE = 'PO'), @currentUserNoReg,
                @currentUserNoReg, @currentUserNoReg, GETDATE(), @orgId, @orgTitle, @positionLevel, 'Y', 'N', 'Y', 'N', 'N', @currentUser, GETDATE(), NULL, NULL,
                'N', @personnelName, 0, GETDATE(), 'N'

                -- Approver approval workflow
                INSERT INTO TB_R_WORKFLOW
                (DOCUMENT_NO, ITEM_NO, DOCUMENT_SEQ, APPROVAL_CD, APPROVAL_DESC, APPROVED_BY, NOREG, APPROVED_BYPASS, APPROVED_DT, STRUCTURE_ID,
                STRUCTURE_NAME, APPROVER_POSITION, IS_APPROVED, IS_REJECTED, IS_DISPLAY, LIMIT_FLAG, MAX_AMOUNT, CREATED_BY, CREATED_DT, CHANGED_BY,
                CHANGED_DT, IS_CANCELLED, APPROVER_NAME, APPROVAL_INTERVAL, INTERVAL_DATE, RELEASE_FLAG)
                SELECT @exactPONo, @exactItemNo, ROW_NUMBER() OVER(ORDER BY tmp.PositionLevel DESC) + 1, tmp.POStatus,
                (SELECT TOP 1 STATUS_DESC FROM TB_M_STATUS WHERE STATUS_CD = tmp.POStatus AND DOC_TYPE = 'PO'),
                tmp.RegNo, tmp.RegNo, CASE WHEN @positionLevel < tmp.PositionLevel THEN @currentUserNoReg ELSE NULL END,
                CASE WHEN @positionLevel < tmp.PositionLevel THEN GETDATE() ELSE NULL END, tmp.OrgId, tmp.OrgTitle,
                tmp.PositionLevel, CASE WHEN @positionLevel < tmp.PositionLevel THEN 'Y' ELSE 'N' END, 'N', tmp.IsDisplay,
                'N', tmp.MaxAmount, @currentUser, GETDATE(), NULL, NULL, 'N', tmp.ApproverName, @defaultInterval,
                dbo.fn_dateadd_workday(@defaultInterval, GETDATE()), 'N'
                FROM (
                    SELECT
                        se.ORG_ID OrgId,
                        se.ORG_TITLE OrgTitle,
                        MIN(se.POSITION_LEVEL) PositionLevel,
                        @approvalFunctionId FunctionId,
                        op.LEVEL_ID LevelId,
                        st.SYSTEM_VALUE POStatus,
                        am.SYSTEM_VALUE MaxAmount,
                        CASE WHEN @sumNewAmount > CAST(am.SYSTEM_VALUE AS DECIMAL(18, 4)) THEN 'Y' ELSE 'N' END IsDisplay,
                        se.PERSONNEL_NAME ApproverName,
                        se.NOREG RegNo
                    FROM TB_R_SYNCH_EMPLOYEE se
                    JOIN TB_M_ORG_POSITION op ON se.POSITION_LEVEL = op.POSITION_LEVEL
                    JOIN TB_M_SYSTEM am ON se.POSITION_LEVEL = am.SYSTEM_CD AND am.FUNCTION_ID = 'XPOAMT'
                    JOIN TB_M_SYSTEM st ON op.LEVEL_ID = st.SYSTEM_CD AND st.FUNCTION_ID = @approvalFunctionId
                    WHERE se.DIVISION_ID = @divisionId AND GETDATE() BETWEEN se.VALID_FROM AND VALID_TO AND se.ORG_ID IN (SELECT OrgId FROM @orgRef GROUP BY OrgId)
                    AND CASE WHEN @sumNewAmount > CAST(am.SYSTEM_VALUE AS DECIMAL(18, 4)) THEN 'Y' ELSE 'N' END = 'Y'
                    GROUP BY se.ORG_ID, se.ORG_TITLE, op.LEVEL_ID, st.SYSTEM_VALUE, am.SYSTEM_VALUE, se.PERSONNEL_NAME, se.NOREG
                ) tmp

				DECLARE @last_seq int
				SET @last_seq = (SELECT MAX(DOCUMENT_SEQ) FROM TB_R_WORKFLOW wp WHERE wp.DOCUMENT_NO = @exactPONo AND wp.ITEM_NO = @exactItemNo) 

				-- Add Approver IN SAME LEVEL or higher if current level not exist in approval workflow
                INSERT INTO TB_R_WORKFLOW
                (DOCUMENT_NO, ITEM_NO, DOCUMENT_SEQ, APPROVAL_CD, APPROVAL_DESC, APPROVED_BY, NOREG, APPROVED_BYPASS, APPROVED_DT, STRUCTURE_ID,
                STRUCTURE_NAME, APPROVER_POSITION, IS_APPROVED, IS_REJECTED, IS_DISPLAY, LIMIT_FLAG, MAX_AMOUNT, CREATED_BY, CREATED_DT, CHANGED_BY,
                CHANGED_DT, IS_CANCELLED, APPROVER_NAME, APPROVAL_INTERVAL, INTERVAL_DATE, RELEASE_FLAG)
				SELECT @exactPONo, @exactItemNo, ROW_NUMBER() OVER(ORDER BY tmp.PositionLevel DESC) + @last_seq, tmp.POStatus,
                (SELECT TOP 1 STATUS_DESC FROM TB_M_STATUS WHERE STATUS_CD = tmp.POStatus AND DOC_TYPE = 'PO'),
                tmp.RegNo, tmp.RegNo, CASE WHEN @positionLevel < tmp.PositionLevel THEN @currentUserNoReg ELSE NULL END,
                CASE WHEN @positionLevel < tmp.PositionLevel THEN GETDATE() ELSE NULL END, tmp.OrgId, tmp.OrgTitle,
                tmp.PositionLevel, CASE WHEN @positionLevel < tmp.PositionLevel THEN 'Y' ELSE 'N' END, 'N', tmp.IsDisplay,
                'N', tmp.MaxAmount, @currentUser, GETDATE(), NULL, NULL, 'N', tmp.ApproverName, @defaultInterval,
                dbo.fn_dateadd_workday(@defaultInterval, GETDATE()), 'N'
                FROM (
                    SELECT ROW_NUMBER() OVER(PARTITION BY op.LEVEL_ID ORDER BY op.LEVEL_ID DESC, op.POSITION_LEVEL ASC) AS DATA_ID,
                        se.ORG_ID OrgId,
                        se.ORG_TITLE OrgTitle,
                        se.POSITION_LEVEL PositionLevel,
                        @approvalFunctionId FunctionId,
                        op.LEVEL_ID LevelId,
                        st.SYSTEM_VALUE POStatus,
                        (SELECT TOP 1 am.SYSTEM_VALUE FROM TB_M_SYSTEM am WHERE am.FUNCTION_ID = 'XPOAMT' AND SYSTEM_CD IN (SELECT op2.POSITION_LEVEL FROM TB_M_ORG_POSITION op2 WHERE op2.LEVEL_ID = op.LEVEL_ID)) MaxAmount,
                        CASE WHEN @sumNewAmount > CAST((SELECT TOP 1 am.SYSTEM_VALUE FROM TB_M_SYSTEM am WHERE am.FUNCTION_ID = 'XPOAMT' AND SYSTEM_CD IN (SELECT op2.POSITION_LEVEL FROM TB_M_ORG_POSITION op2 WHERE op2.LEVEL_ID = op.LEVEL_ID)) AS DECIMAL(18, 4)) THEN 'Y' ELSE 'N' END IsDisplay,
                        se.PERSONNEL_NAME ApproverName,
                        se.NOREG RegNo
                    FROM TB_R_SYNCH_EMPLOYEE se
                    JOIN TB_M_ORG_POSITION op ON se.POSITION_LEVEL = op.POSITION_LEVEL AND 
						NOT EXISTS (SELECT 1 FROM TB_R_WORKFLOW wp INNER JOIN TB_M_SYSTEM am2 ON am2.FUNCTION_ID = 'XPOAMT' AND am2.SYSTEM_CD = wp.APPROVER_POSITION WHERE wp.DOCUMENT_NO = @exactPONo AND wp.ITEM_NO = @exactItemNo AND wp.APPROVER_POSITION = op.POSITION_LEVEL)
                    JOIN TB_M_SYSTEM st ON op.LEVEL_ID = st.SYSTEM_CD AND st.FUNCTION_ID = @approvalFunctionId
                    WHERE se.DIVISION_ID = @divisionId AND GETDATE() BETWEEN se.VALID_FROM AND VALID_TO AND se.ORG_ID IN (SELECT OrgId FROM @orgRef GROUP BY OrgId)
                    AND CASE WHEN @sumNewAmount > CAST((SELECT TOP 1 am.SYSTEM_VALUE FROM TB_M_SYSTEM am WHERE am.FUNCTION_ID = 'XPOAMT' AND SYSTEM_CD IN (SELECT op2.POSITION_LEVEL FROM TB_M_ORG_POSITION op2 WHERE op2.LEVEL_ID = op.LEVEL_ID)) AS DECIMAL(18, 4)) THEN 'Y' ELSE 'N' END = 'Y'
                ) tmp WHERE DATA_ID = 1

                --Note : add bypass checking(if PO Creator is SH/DpH/DH then bypass)
                DECLARE @status VARCHAR(MAX)
                EXEC [dbo].[sp_worklist_bypassChecking]
                    @exactPONo,
                    'PO',
                    @processId,
                    @currentUserNoReg,
                    @orgId,
                    @positionLevel,
                    @status OUTPUT

                IF(@status <> 'SUCCESS')
                BEGIN
                    RAISERROR(@status, 16, 1)
                END

                DECLARE @approvalDt VARCHAR(10) = (SELECT TOP 1 CAST(APPROVED_DT AS VARCHAR) FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @exactPONo AND DOCUMENT_SEQ = 1)
                EXEC [dbo].[sp_worklist_calculateInterval]
                    @exactPONo,
                    @exactItemNo,
                    @approvalDt,
                    1

                -- Update status to the latest even if it's bypassed or not
                DECLARE
                    @lastByPassedStatus VARCHAR(3), @lastApprover VARCHAR(20), @lastDocSeq INT,
                    @nextStatus VARCHAR(3), @nextApprover VARCHAR(20), @nextDocSeq INT

                --SELECT @lastApprover = w.APPROVED_BY, @lastByPassedStatus = w.APPROVAL_CD, @lastDocSeq = w.DOCUMENT_SEQ
                --FROM TB_R_WORKFLOW w
                --JOIN (
                --    SELECT DOCUMENT_NO, ISNULL(MAX(DOCUMENT_SEQ), 0) DOCUMENT_SEQ
                --    FROM dbo.TB_R_WORKFLOW WHERE DOCUMENT_NO = @exactPONo AND ITEM_NO = @exactItemNo AND APPROVED_BYPASS = @currentUserNoReg
                --    GROUP BY DOCUMENT_NO
                --) wd ON w.DOCUMENT_NO = wd.DOCUMENT_NO AND w.DOCUMENT_SEQ = wd.DOCUMENT_SEQ

				SELECT @lastApprover = w.APPROVED_BY, @lastByPassedStatus = w.APPROVAL_CD, @lastDocSeq = w.DOCUMENT_SEQ
                FROM TB_R_WORKFLOW w
                JOIN (
                    SELECT TOP 1 DOCUMENT_NO, ISNULL(MAX(DOCUMENT_SEQ), 0) DOCUMENT_SEQ
                    FROM dbo.TB_R_WORKFLOW WHERE DOCUMENT_NO = @exactPONo AND ITEM_NO = @exactItemNo AND APPROVED_DT IS NOT NULL
					--APPROVED_BYPASS = @currentUserNoReg
                    GROUP BY DOCUMENT_NO
                ) wd ON w.DOCUMENT_NO = wd.DOCUMENT_NO AND w.DOCUMENT_SEQ = wd.DOCUMENT_SEQ
					 ORDER BY W.APPROVAL_CD

                SELECT
                    @nextApprover = CASE WHEN @lastByPassedStatus = '43' /* Posting */ THEN @lastApprover ELSE APPROVED_BY END,
                    @nextStatus = CASE WHEN @lastByPassedStatus = '43' /* Posting */ THEN @lastByPassedStatus ELSE APPROVAL_CD END
                FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @exactPONo AND ITEM_NO = @exactItemNo AND DOCUMENT_SEQ = @lastDocSeq + 1

                IF (ISNULL((SELECT SAP_DOC_NO FROM TB_R_PO_H WHERE PO_NO = @exactPONo), '') <> '' AND @nextApprover = '43')
                BEGIN
                    SET @lastByPassedStatus = '44'
                    SET @nextApprover = '44'
                    SET @nextStatus = '44'
                END
				 SET @message = 'I| @lastByPassedStatus: ' + @lastByPassedStatus + ' @nextApprover :' + @nextApprover +' @nextStatus ' +@nextStatus+ ': end'
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)


                UPDATE TB_R_PO_H SET PO_STATUS = @lastByPassedStatus, PO_NEXT_STATUS = @nextStatus 
				WHERE PO_NO = @exactPONo 
                --UPDATE TB_R_PO_ITEM SET PO_STATUS = @lastByPassedStatus, PO_NEXT_STATUS = @nextStatus
            END

            INSERT INTO @process_level VALUES(8)

            SET @message = 'I|Insert data to TB_M_WORKFLOW where PO_NO: ' + @exactPONo + ': end'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            DECLARE @pohStat CHAR(2), @pohnextStat CHAR(2)
            --Update Status PO_H based on PO_ITEM status
            IF EXISTS(SELECT 1 FROM TB_R_PO_H WHERE PO_NO = @exactPONo AND PO_STATUS <> PO_NEXT_STATUS)
            BEGIN
                SELECT DISTINCT @pohStat = CAST(MAX(CAST(PO_STATUS AS INT)) AS VARCHAR) FROM TB_R_PO_H WHERE PO_NO = @exactPONo
                SELECT DISTINCT @pohnextStat = CAST(MAX(CAST(PO_NEXT_STATUS AS INT)) AS VARCHAR) FROM TB_R_PO_H WHERE PO_NO = @exactPONo
            END
            ELSE
            BEGIN
                SET @pohStat = '43'
                SET @pohnextStat = '43'
                IF (ISNULL((SELECT SAP_DOC_NO FROM TB_R_PO_H WHERE PO_NO = @exactPONo), '') <> '') OR
					EXISTS(SELECT 1 FROM TB_R_PO_H WHERE PO_NO = @exactPONo AND PO_STATUS = '44') -- Edit tanggal 03 oct 2017
                BEGIN
                    SET @pohStat = '44'
                    SET @pohnextStat = '44'
                END
            END

            UPDATE TB_R_PO_H SET PO_STATUS = ISNULL(@pohStat, @poHeaderStatusCode), PO_NEXT_STATUS = ISNULL(@pohnextStat, @poHeaderNextStatusCode) WHERE PO_NO = @exactPONo
        END

		IF EXISTS (SELECT 1 FROm TB_R_PO_H WHERE PO_NO = @exactPONo AND PO_STATUS = '48')
		BEGIN
			UPDATE TB_R_WORKFLOW SET IS_APPROVED = 'Y', CHANGED_BY = @currentUser, CHANGED_DT = GETDATE()
            WHERE DOCUMENT_NO = @exactPONo AND IS_DISPLAY = 'Y' AND IS_APPROVED = 'N' AND NOREG = @currentUserNoReg
		END
        -- Set PO_H & PO_ITEM_STATUS
        DECLARE @lastApprovalCd CHAR(2), @nextApprovalCd CHAR(2)
		IF EXISTS(SELECT 1 FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @exactPONo AND IS_DISPLAY = 'Y' AND IS_APPROVED = 'Y')
		BEGIN
			SELECT TOP 1 @lastApprovalCd = APPROVAL_CD
				FROM TB_R_WORKFLOW
				WHERE DOCUMENT_NO = @exactPONo AND IS_DISPLAY = 'Y' AND IS_APPROVED = 'Y'
				ORDER BY DOCUMENT_SEQ DESC
		END
		ELSE
		BEGIN
			SELECT TOP 1 @lastApprovalCd = APPROVAL_CD
				FROM TB_R_WORKFLOW
				WHERE DOCUMENT_NO = @exactPONo AND IS_DISPLAY = 'Y' 
				ORDER BY DOCUMENT_SEQ ASC
		END

        SELECT TOP 1 @nextApprovalCd = APPROVAL_CD
            FROM TB_R_WORKFLOW
            WHERE DOCUMENT_NO = @exactPONo AND IS_DISPLAY = 'Y' AND IS_APPROVED = 'N' AND APPROVAL_CD <> @lastApprovalCd
            ORDER BY DOCUMENT_SEQ ASC

		--IF Status PO is Reject?, Reset Status PO To last Approve Code
		IF EXISTS (SELECT 1 FROm TB_R_PO_H WHERE PO_NO = @exactPONo AND PO_STATUS = '48')
		BEGIN
			UPDATE TB_R_PO_H SET PO_STATUS = @lastApprovalCd, PO_NEXT_STATUS = ISNULL(@nextApprovalCd, @lastApprovalCd)
				WHERE PO_NO = @exactPONo
		END
        --UPDATE TB_R_PO_ITEM SET PO_STATUS = @lastApprovalCd, PO_NEXT_STATUS = ISNULL(@nextApprovalCd, @lastApprovalCd)
        --    WHERE PO_NO = @exactPONo

        -- Release Process Id locking
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Release Process Id locking in TB_R_PO_H, TB_R_ASSET: begin', @moduleId, @actionName, @functionId, 1, @currentUser)
        UPDATE TB_R_PO_H SET PROCESS_ID = NULL WHERE PROCESS_ID = @processId AND PO_NO = @exactPONo
        UPDATE TB_R_PR_ITEM SET PROCESS_ID = NULL WHERE PROCESS_ID = @processId
        UPDATE TB_R_ASSET SET PROCESS_ID = NULL WHERE PROCESS_ID = @processId AND PO_NO = @exactPONo
		DELETE FROM TB_T_LOCK WHERE PROCESS_ID = @processId
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Release Process Id locking in TB_R_PO_H, TB_R_ASSET: end', @moduleId, @actionName, @functionId, 1, @currentUser)

        SELECT @message = CASE
            WHEN @poNo = '' THEN
                'PO with No: ' + @candidatePONo + ' has been created' + (SELECT CASE WHEN @saveAsDraft = 1 THEN ' as Draft.' ELSE '.' END)
            WHEN @poNo <> '' THEN
                'PO with No: ' + @poNo + ' has been updated' + (SELECT CASE WHEN @saveAsDraft = 1 THEN ' as Draft.' ELSE '.' END)
        END

        -- Announce
        INSERT INTO TB_R_ANNOUNCEMENT
        (PROCESS_ID, MSG_TYPE, TARGET_RECIPIENT, MSG_CONTENT,
        MSG_ATTACHMENT, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT)
        VALUES (@processId, 'INF', @currentUserNoReg + ';' + ISNULL(@nextApprover, ''), @message, NULL, @currentUser, GETDATE(), NULL, NULL)

        SET @message = 'I|' + @message
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        -- Clear Temp table
        SET @message = 'I|Delete data from TB_T_PO_ITEM where CREATED_BY = ' + @currentUser + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        DELETE FROM TB_T_PO_H WHERE CREATED_BY = @currentUser AND PROCESS_ID = @processId
        DELETE FROM TB_T_PO_ITEM WHERE CREATED_BY = @currentUser AND PROCESS_ID = @processId

        SET @message = 'I|Delete data from TB_T_PO_ITEM where CREATED_BY = ' + @currentUser + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        SET @message = 'I|Delete data from TB_T_PO_SUBITEM where CREATED_BY = ' + @currentUser + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        DELETE FROM TB_T_PO_SUBITEM WHERE CREATED_BY = @currentUser AND PROCESS_ID = @processId

        SET @message = 'I|Delete data from TB_T_PO_SUBITEM where CREATED_BY = ' + @currentUser + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        SET @message = 'I|Delete data from TB_T_PO_CONDITION where CREATED_BY = ' + @currentUser + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        DELETE FROM TB_T_PO_CONDITION WHERE CREATED_BY = @currentUser AND PROCESS_ID = @processId

        SET @message = 'I|Delete data from TB_T_PO_CONDITION where CREATED_BY = ' + @currentUser + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        SET @message = 'I|Reset PROCESS_ID from TB_R_ASSET where CHANGED_BY = ' + @currentUser + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

        UPDATE TB_R_ASSET SET PROCESS_ID = NULL WHERE CHANGED_BY = @currentUser
        AND ISNULL(PROCESS_ID, '') NOT IN (SELECT DISTINCT PROCESS_ID FROM TB_T_PO_ITEM)
        AND (ISNULL(PO_NO, '') = '' AND ISNULL(PO_ITEM_NO, '') = '')

        SET @message = 'I|Reset PROCESS_ID from TB_R_ASSET where CHANGED_BY = ' + @currentUser + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

		--//// Add By Fid.Reggy Send Email PO
		DECLARE
			@APPROVAL_STATUS_DESC VARCHAR(100) = '', 
			@LAST_STATUS VARCHAR(2) = '',
			@NOREG VARCHAR(50) = '',
			@NAME VARCHAR(100) = '',
			@LINK_PO VARCHAR(MAX) = '',
			@i_numItem AS int = 0,
			@MAIL_AMOUNT_APPROVAL AS MONEY,
			@MAIL_ITEM_DESCRIPTION AS VARCHAR(MAX) = '',
			@SUBJECT VARCHAR(100) = '',
			@BODY VARCHAR(MAX) = '',
			@CREATOR_BODY VARCHAR(MAX) = '',
			@APPROVER_BODY VARCHAR(MAX) = '',
			@BODY_HEADER VARCHAR(MAX) = '',
			@BODY_FOOTER VARCHAR(MAX) = ''
				
		IF(@poNo <> '')
		BEGIN
			SET @candidatePONo = @poNo
		END

		SELECT 
			@MAIL_ITEM_DESCRIPTION = PO_DESC, 
			@MAIL_AMOUNT_APPROVAL = CAST(PO_AMOUNT * PO_EXCHANGE_RATE AS MONEY) 
		FROM TB_R_PO_H
		WHERE PO_NO = @candidatePONo

		SET @BODY = @BODY + '<br/>PO Desc. : ' + ISNULL(@MAIL_ITEM_DESCRIPTION, '') + '';
		SET @BODY = @BODY + '<br/>PO Amount : ' + ISNULL(CONVERT(VARCHAR(MAX), @MAIL_AMOUNT_APPROVAL, -1), '') + '';

		--Approval Email
		SELECT TOP 1 @NOREG = APPROVED_BY
		FROM TB_R_WORKFLOW
		WHERE DOCUMENT_NO = @candidatePONo AND IS_APPROVED = 'N' AND IS_DISPLAY = 'Y'
		ORDER BY DOCUMENT_SEQ ASC

		IF(ISNULL(@NOREG,'')<>'')
		BEGIN
			SELECT TOP 1 @NAME = PERSONNEL_NAME
			FROM TB_R_SYNCH_EMPLOYEE 
			WHERE NOREG = @NOREG AND GETDATE() BETWEEN VALID_FROM AND VALID_TO 
			ORDER BY POSITION_LEVEL DESC

			SELECT @LINK_PO = SYSTEM_VALUE   
			FROM TB_M_SYSTEM 
			WHERE FUNCTION_ID = 'MAIL' AND SYSTEM_CD = 'LINK_POAPPROVAL' 

			SELECT @SUBJECT = SYSTEM_VALUE   
			FROM TB_M_SYSTEM 
			WHERE FUNCTION_ID = 'POMAIL' AND SYSTEM_CD = 'APR_SUB' 

			SELECT @BODY_HEADER = SYSTEM_VALUE   
			FROM TB_M_SYSTEM 
			WHERE FUNCTION_ID = 'POMAIL' AND SYSTEM_CD = 'APR_HEAD' 

			SELECT @BODY_FOOTER = SYSTEM_VALUE   
			FROM TB_M_SYSTEM 
			WHERE FUNCTION_ID = 'POMAIL' AND SYSTEM_CD = 'APR_FOOT'

			SET @APPROVER_BODY = REPLACE(ISNULL(@BODY_HEADER, ''), '[NAME]', @NAME) + 
									'<br/>PO Number : <a href="' + ISNULL(@LINK_PO, '#') + '">' + ISNULL(@candidatePONo, '') + '</a>' +
									ISNULL(@BODY, '') + 
									REPLACE(ISNULL(@BODY_FOOTER, ''), '[APR_LINK]', @LINK_PO)

			SET @message = 'NEXT|' + ISNULL(@candidatePONo, '')
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)

			EXEC [dbo].[sp_announcement_sendmail]
				@NOREG,
				@SUBJECT,
				@APPROVER_BODY,
				@message OUTPUT
						
			IF(@message <> 'SUCCESS')
			BEGIN
				RAISERROR(@message, 16, 1)
			END
		END 
			
		----Creator Email
		--SELECT TOP 1 @APPROVAL_STATUS_DESC = APPROVAL_DESC
		--FROM TB_R_WORKFLOW
		--WHERE DOCUMENT_NO = @candidatePONo AND IS_APPROVED = 'Y' AND IS_DISPLAY = 'Y'
		--ORDER BY DOCUMENT_SEQ DESC

		--SELECT TOP 1 @NOREG = APPROVED_BY
		--FROM TB_R_WORKFLOW
		--WHERE DOCUMENT_NO = @candidatePONo AND DOCUMENT_SEQ = 1

		--IF (@NOREG <>'00000000')
		--BEGIN
		--	SELECT TOP 1 @NAME = PERSONNEL_NAME
		--	FROM TB_R_SYNCH_EMPLOYEE 
		--	WHERE NOREG = @NOREG AND GETDATE() BETWEEN VALID_FROM AND VALID_TO 
		--	ORDER BY POSITION_LEVEL DESC
						
		--	SELECT @LINK_PO = SYSTEM_VALUE   
		--	FROM TB_M_SYSTEM 
		--	WHERE FUNCTION_ID = 'MAIL' AND SYSTEM_CD = 'LINK_POINQUIRY' 

		--	SELECT @SUBJECT = SYSTEM_VALUE   
		--	FROM TB_M_SYSTEM 
		--	WHERE FUNCTION_ID = 'POMAIL' AND SYSTEM_CD = 'CRE_SUB' 

		--	SELECT @BODY_HEADER = SYSTEM_VALUE   
		--	FROM TB_M_SYSTEM 
		--	WHERE FUNCTION_ID = 'POMAIL' AND SYSTEM_CD = 'CRE_HEAD' 

		--	SELECT @BODY_FOOTER = SYSTEM_VALUE   
		--	FROM TB_M_SYSTEM 
		--	WHERE FUNCTION_ID = 'POMAIL' AND SYSTEM_CD = 'CRE_FOOT'

		--	SET @CREATOR_BODY = REPLACE(REPLACE(ISNULL(@BODY_HEADER, ''), '[NAME]', @NAME), '[STATUS]', REPLACE(ISNULL(@APPROVAL_STATUS_DESC, ''), 'PO ', '')) + 
		--						'<br/>PO Number : <a href="' + ISNULL(@LINK_PO, '#') + '">' + ISNULL(@candidatePONo, '') + '</a>' +
		--						ISNULL(@BODY, '') + 
		--						REPLACE(ISNULL(@BODY_FOOTER, ''), '[CRE_LINK]', @LINK_PO)
		
		--	SET @message = 'CREATOR|' + ISNULL(@currentUserNoReg, '')
		--	INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)

		--	EXEC [dbo].[sp_announcement_sendmail]
		--		@NOREG,
		--		@SUBJECT,
		--		@CREATOR_BODY,
		--		@message OUTPUT
						
		--	IF(@message <> 'SUCCESS')
		--	BEGIN
		--		RAISERROR(@message, 16, 1)
		--	END
		--END --Ecatalogue Dummy User 00000000

        COMMIT TRAN SaveData

        SET @message = 'S|Finish'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(MAX) = ERROR_MESSAGE(), @ErrorLine int = ERROR_LINE()
        -- Rollback budget
        IF(@isFromSAP <> 'Y' AND @saveAsDraft = 0)
        BEGIN

			UPDATE @budgetTransactTemp 
				SET BMSOperation = CASE WHEN ReturnAmount > 0 THEN 'REVERSE_COMMIT' 
										WHEN ReturnAmount = 0  THEN 'REV_COMMIT' 
										ELSE BMSOperation END,
					TotalAmount = CASE WHEN ReturnAmount > 0 THEN TotalAmount + ReturnAmount 
									   ELSE TotalAmount END,
					ReturnAmount = CASE WHEN ReturnAmount > 0 THEN 0 
										ELSE ReturnAmount END
			WHERE BMSOperation = 'CONVERT_COMMIT'

            DECLARE @counter INT = 0
            IF (SELECT COUNT(0) FROM @budgetTransactTemp) > 0
            BEGIN

                WHILE (@counter < (SELECT COUNT(0) FROM @budgetTransactTemp))
                BEGIN
					IF EXISTS(SELECT 1 FROM @budgetTransactTemp WHERE DataNo = (@counter + 1))
					BEGIN
						SELECT
							@wbsNo = WBSNo, @oldPONo = CASE WHEN @isPOManual = 1 THEN NewDocNo ELSE RefDocNo END,
							@bmsOperation = CASE WHEN @isPOManual = 1 THEN 'CANCEL_COMMIT' ELSE BMSOperation END,
							@poNoForBMS = NewDocNo, @currency = Currency, @totalAmount = TotalAmount, @totalReturnAmount = ReturnAmount,
							@materialNo = MaterialNo, @poDesc = DocDesc
						FROM @budgetTransactTemp WHERE DataNo = (@counter + 1)

						SET @message = 'I|Rollback with BMSOperation '+@bmsOperation+'; Total amount  = ' + cast(@totalAmount as varchar) + '; Total return value = ' + cast(@totalReturnAmount as varchar) + ';
						wbs no = ' + @wbsNo + '; old ref = ' + ISNULL(@oldPONo, '') + '; new ref = ' + ISNULL(@poNoForBMS, '') + '; curr = ' + @currency + '; desc = ' + @poDesc 
						INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
						SET @bmsResponseMessage = ''

						--EXEC @bmsResponse =
						--					[BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
						--						@bmsResponseMessage OUTPUT,
						--						@currentUser,
						--						@bmsOperation,
						--						@wbsNo,
						--						@oldPONo,
						--						@poNoForBMS,
						--						@currency,
						--						@totalAmount,
						--						@totalReturnAmount,
						--						@materialNo,
						--						@poDesc,
						--						'GPS-R'

						SET @message = 'I|Feedback Rollback BMS :: ' + ISNULL(@bmsResponseMessage,'')
						INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

						/*EXEC @bmsResponse =
							[BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
								@bmsResponseMessage OUTPUT, @currentUser, @bmsOperation, @wbsNo, @oldPONo, @poNoForBMS,
								@currency, @totalAmount, @materialNo, @poDesc*/

						/*
						-- For debugging purposes
						SELECT @bmsOperation CommitOperation, CASE @bmsResponse WHEN '0' THEN 'Success' WHEN '1' THEN 'Failed' END CommitResult, @bmsResponseMessage CommitMessage
						EXEC sp_Util_BudgetMonitor @wbsNo
						*/

						IF @bmsResponse = '1'
						BEGIN
							SET @message = 'E|' + ISNULL(@bmsResponseMessage, ERROR_MESSAGE())
							INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
						END
					END
					SET @counter = @counter + 1
                END

                DELETE FROM @budgetTransactTemp
            END
        END

        ROLLBACK TRAN SaveData
        SET @message = 'E|' + CAST(@ErrorLine AS VARCHAR) + ': ' + @ErrorMessage
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
    END CATCH

    DECLARE @YEAR CHAR(4) = (SELECT ISNULL(DATEPART(YEAR, DOC_DT), '') FROM TB_R_PO_H WHERE PO_NO = @exactPONo)

    EXEC sp_putLog_Temp @tmpLog
    SET NOCOUNT OFF
    SELECT @exactPONo PONo, @YEAR DocYear, @message [Message]
END