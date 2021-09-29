CREATE PROCEDURE [dbo].[sp_ReceivingList_CancelGRSA]
    @currentUser VARCHAR(50),
    @currentRegNo VARCHAR(50),
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6),
    @matDoc VARCHAR(11),
    @cancelDate DATETIME,
    @cancelReason VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON
    DECLARE
        @message VARCHAR(MAX),
        @subject VARCHAR(MAX),
        @status VARCHAR(50),
        @actionName VARCHAR(50) = 'sp_GoodReceive_CancelGRSA',
        @tmpLog LOG_TEMP

    BEGIN TRY
        SET @message = 'I|Start'
        EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0

        BEGIN TRAN CancelGRSA

        DECLARE @oldStatus VARCHAR(2), @poNo VARCHAR(11), @poItemNo VARCHAR(5), @poSubItemNo VARCHAR(5), @movementQty DECIMAL(13,3), @itemClass VARCHAR(1)
        SELECT @oldStatus = STATUS_CD, @poNo = PO_NO, @poItemNo = PO_ITEM, @poSubItemNo = PO_SUBITEM_NO, @movementQty = MOVEMENT_QTY FROM TB_R_GR_IR WHERE MAT_DOC_NO = @matDoc
        SELECT @itemClass = ITEM_CLASS FROM TB_R_PO_ITEM WHERE PO_NO = @poNo AND PO_ITEM_NO = @poItemNo

        UPDATE TB_R_GR_IR SET STATUS_CD = '69', CANCEL_STATUS = 'Y', CANCEL_DT = @cancelDate, CANCEL_REASON = @cancelReason
        WHERE MAT_DOC_NO = @matDoc

        -- Update item's qty
        IF @itemClass = 'M'
        BEGIN
            UPDATE TB_R_PO_ITEM SET
            PO_QTY_USED = PO_QTY_USED - @movementQty,
            PO_QTY_REMAIN = PO_QTY_REMAIN + @movementQty
        END
        ELSE IF @itemClass = 'S'
        BEGIN
            UPDATE TB_R_PO_SUBITEM SET
            PO_QTY_USED = PO_QTY_USED - @movementQty,
            PO_QTY_REMAIN = PO_QTY_REMAIN + @movementQty
        END

        SET @subject = 'GR/SA Cancelation - ' + @matDoc
        SET @message = '<p>GR/SA has been cancelled with document no <b>' + @matDoc + '</b>.</p>' +
            CASE WHEN CAST(@oldStatus AS INT) > 60
            THEN '<p>Document SAP is not cancelled yet. Please cancel document manually.</p>' ELSE '' END
        EXEC dbo.sp_announcement_sendmail @currentRegNo, @subject, @message, @status OUTPUT
        IF @status <> 'SUCCESS' BEGIN RAISERROR(@status, 16, 1) END

        -- Budget calculation
        DECLARE @budgetCheck TABLE
        (
            DataNo INT, WBSNo VARCHAR(30), RefDocNo VARCHAR(15),
            NewDocNo VARCHAR(30), BMSOperation VARCHAR(30), Currency VARCHAR(3),
            OriQty DECIMAL(9,3), Qty DECIMAL(9,3), MatNo VARCHAR(50),
            ConsumeAmount DECIMAL(18,4), ReturnAmount DECIMAL(18,4)
        )
        DECLARE @budgetTransactTemp TABLE
        (
            DataNo INT IDENTITY(1,1), WBSNo VARCHAR(30), RefDocNo VARCHAR(15),
            NewDocNo VARCHAR(30), Currency VARCHAR(3), OriQty DECIMAL(9,3), Qty DECIMAL(9,3),
            MatNo VARCHAR(50), ConsumeAmount DECIMAL(18,4), ReturnAmount DECIMAL(18,4)
        )

        -- List down all wbs to consume
        INSERT INTO @budgetCheck
        SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) DataNo,
        WBSNo, RefDocNo, NewDocNo, BMSOperation, Currency, OriQty, Qty, MatNo,
        SUM(ConsumeAmount) ConsumeAmount, SUM(ReturnAmount) ReturnAmount
        FROM (
            SELECT CASE poi.ITEM_CLASS WHEN 'M' THEN poi.WBS_NO WHEN 'S' THEN posi.WBS_NO END WBSNo,
            grir.MAT_DOC_NO + '_001' RefDocNo, grir.MAT_DOC_NO + '_001' NewDocNo,
            'CANCEL_CONSUME' BMSOperation, poh.PO_CURR Currency,
            (CASE poi.ITEM_CLASS
            WHEN 'M' THEN poi.PO_QTY_ORI
            WHEN 'S' THEN posi.PO_QTY_ORI END) OriQty, grir.MOVEMENT_QTY Qty,
            CASE poi.ITEM_CLASS WHEN 'M' THEN poi.MAT_NO WHEN 'S' THEN posi.MAT_NO END  MatNo,
            grir.MOVEMENT_QTY *
            (CASE poi.ITEM_CLASS
            WHEN 'M' THEN poi.PRICE_PER_UOM
            WHEN 'S' THEN posi.PRICE_PER_UOM END) ConsumeAmount,
            ((CASE poi.ITEM_CLASS
            WHEN 'M' THEN poi.PO_QTY_ORI
            WHEN 'S' THEN posi.PO_QTY_ORI END) -
            grir.MOVEMENT_QTY) *
            (CASE poi.ITEM_CLASS
            WHEN 'M' THEN poi.PRICE_PER_UOM
            WHEN 'S' THEN posi.PRICE_PER_UOM END) ReturnAmount
            FROM TB_R_GR_IR grir
            JOIN TB_R_PO_ITEM poi ON grir.PO_NO = poi.PO_NO
            AND grir.PO_ITEM = poi.PO_ITEM_NO
            JOIN TB_R_PO_H poh ON poi.PO_NO = poh.PO_NO
            LEFT JOIN TB_R_PO_SUBITEM posi ON grir.PO_NO = posi.PO_NO
            AND grir.PO_ITEM = posi.PO_ITEM_NO AND grir.PO_SUBITEM_NO = posi.PO_SUBITEM_NO
            WHERE grir.MAT_DOC_NO = @matDoc
        ) tmp
        GROUP BY tmp.WBSNo, tmp.RefDocNo, tmp.NewDocNo, tmp.OriQty, tmp.Qty,
        tmp.MatNo, tmp.BMSOperation, tmp.Currency, tmp.MatNo

        DECLARE
            @poItemGroupedByWBSCount INT = (SELECT COUNT(0) FROM @budgetCheck),
            @bmsResponse VARCHAR(20),
            @bmsResponseMessage VARCHAR(8000),
            @bmsRetryCounter INT = 0,
            @wbsIdx INT = 1,
            @wbsNo VARCHAR(30),
            @consumeAmount DECIMAL(18, 2),
            @returnAmount DECIMAL(18, 2) = NULL,
            @matNo VARCHAR(50) = '',
            @bmsOperation VARCHAR(30),
            @refDocNo VARCHAR(15),
            @newDocNo VARCHAR(15),

            @oriQty DECIMAL(9,3),
            @qty DECIMAL(9,3),
            @currency VARCHAR(3) = ''

        WHILE (@wbsIdx <= @poItemGroupedByWBSCount)
        BEGIN
            SELECT
            @wbsNo = WBSNo,
            @consumeAmount = ConsumeAmount,
            @returnAmount = ReturnAmount,
            @currency = Currency,
            @matNo = MatNo,
            @refDocNo = RefDocNo,
            @newDocNo = NewDocNo,
            @bmsOperation = BMSOperation,
            @oriQty = OriQty,
            @qty = Qty
            FROM @budgetCheck WHERE DataNo = @wbsIdx

            SET @message = 'I|Budget ' + @bmsOperation + ' on WBS No: ' + @wbsNo + ' in the amount of: ' + CAST(@consumeAmount AS VARCHAR) + ' with New Doc No ' + ISNULL(@newDocNo, '') + ' and Ref Doc No' + ISNULL(@refDocNo, '')+ ': begin'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            EXEC @bmsResponse =
                [BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
                    @bmsResponseMessage OUTPUT, @currentUser, @bmsOperation, @wbsNo,
                    @refDocNo, @newDocNo, @currency, @consumeAmount, @returnAmount,
                    @matNo, @cancelReason, 'GPS', NULL

            -- NOTE: bmsResponse always 0 or 1 String which means Success or Failed respectively
            WHILE (@bmsResponse = '1' AND @bmsRetryCounter < 3)
            BEGIN
                -- NOTE: if Failed retry in 1 sec and log
                SET @message = 'I|Budget ' + @bmsOperation + ' Failed on WBS No: ' + @wbsNo + ' in the amount of: ' + CAST(@consumeAmount AS VARCHAR) + ' with New Doc No ' + ISNULL(@newDocNo, '') + ' and Ref Doc No' + ISNULL(@refDocNo, '') + ': retry'
                INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

                WAITFOR DELAY '00:00:01'
                EXEC @bmsResponse =
                    [BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
                        @bmsResponseMessage OUTPUT, @currentUser, @bmsOperation, @wbsNo,
                        @refDocNo, @newDocNo, @currency, @consumeAmount, @returnAmount,
                        @matNo, @cancelReason, 'GPS', NULL
                SET @bmsRetryCounter = @bmsRetryCounter + 1
            END

            IF @bmsResponse = '1' BEGIN RAISERROR(@bmsResponseMessage, 16, 1) END

            INSERT INTO @budgetTransactTemp VALUES (@wbsNo, @refDocNo, @newDocNo, @currency, @oriQty, @qty, @matNo, @returnAmount, @consumeAmount)

            SET @message = 'I|Budget ' + @bmsOperation + ' on WBS No: ' + @wbsNo + ' in the amount of: ' + CAST(@consumeAmount AS VARCHAR) + ' with New Doc No ' + ISNULL(@newDocNo, '') + ' and Ref Doc No' + ISNULL(@refDocNo, '') + ': end'
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            SET @wbsIdx = @wbsIdx + 1
        END

        COMMIT TRAN CancelGRSA

        SET @message = 'S|Finish'
        EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @processId OUTPUT, 'SUC', 'SUC', @moduleId, @functionId, 2
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
        DECLARE @budgetRollbackCounter INT = 0
        IF (SELECT COUNT(0) FROM @budgetTransactTemp) > 0
        BEGIN
            WHILE (@budgetRollbackCounter < (SELECT COUNT(0) FROM @budgetTransactTemp))
            BEGIN
                SELECT @wbsNo = WBSNo, @consumeAmount = ReturnAmount,
                @returnAmount = ConsumeAmount, @currency = Currency,
                @matNo = MatNo, @refDocNo = RefDocNo, @newDocNo = NewDocNo,
                @bmsOperation = CASE WHEN @qty > @oriQty THEN 'CONVERT_CONSUME_PARTIAL' ELSE 'CONVERT_CONSUME' END
                FROM @budgetTransactTemp WHERE DataNo = (@budgetRollbackCounter + 1)

                EXEC @bmsResponse =
                    [BMS_DEV].[NEW_BMS_DB].dbo.[sp_BudgetControl]
                        @bmsResponseMessage OUTPUT, @currentUser, @bmsOperation, @wbsNo,
                        @refDocNo, @newDocNo, @currency, @consumeAmount, @returnAmount,
                        @matNo, @cancelReason, 'GPS', NULL

                IF @bmsResponse = '1'
                BEGIN
                    SET @message = 'E|' + @bmsResponseMessage
                    INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
                END

                SET @budgetRollbackCounter = @budgetRollbackCounter + 1
            END

            DELETE FROM @budgetTransactTemp
        END

        ROLLBACK TRAN CancelGRSA
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
    END CATCH

    EXEC sp_PutLog_Temp @tmpLog
    SET NOCOUNT OFF
    SELECT @message [Message]
END