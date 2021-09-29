CREATE PROCEDURE [dbo].[sp_POCreation_CopyItemTemp]
    @currentUser VARCHAR(50),
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6),
    @poNo VARCHAR(11),
    @poItemNo VARCHAR(30),
    @seqItemNo INT
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = 'sp_POCreation_CopyItemTemp',
        @tmpLog LOG_TEMP
    
    SET @message = 'I|Start'
    EXEC dbo.sp_PutLog @message, @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0
    
    BEGIN TRY
        BEGIN TRAN CopyItemTemp
        
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Get currency rate: begin', @moduleId, @actionName, @functionId, 1, @currentUser)
        
        SET @message = 'I|Copy data in TB_T_PO_ITEM where PO_NO: ' + ISNULL(@poNo, 'NULL') + ' and PO_ITEM_NO: NULL and SEQ_ITEM_NO: ' + CAST(@seqItemNo AS VARCHAR) + ': begin'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
        
        INSERT INTO TB_T_PO_ITEM
        (PROCESS_ID, SEQ_ITEM_NO, PR_NO, PR_ITEM_NO, VENDOR_CD, VENDOR_NAME, QUOTATION_NO, PURCHASING_GRP_CD, VALUATION_CLASS, MAT_NO, MAT_DESC,
        PROCUREMENT_PURPOSE, DELIVERY_PLAN_DT, SOURCE_TYPE, PLANT_CD, SLOC_CD, WBS_NO, COST_CENTER_CD, UNLIMITED_FLAG, TOLERANCE_PERCENTAGE, SPECIAL_PROCUREMENT_TYPE,
        PO_QTY_ORI, PO_QTY_USED, PO_QTY_REMAIN, UOM, CURR_CD, ORI_AMOUNT, NEW_FLAG, UPDATE_FLAG, DELETE_FLAG, PO_NO,
        PO_ITEM_NO, URGENT_DOC, GROSS_PERCENT, ITEM_CLASS, IS_PARENT, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT, WBS_NAME,
        GL_ACCOUNT, PO_QTY_NEW, ORI_PRICE_PER_UOM, NEW_PRICE_PER_UOM, NEW_AMOUNT, ORI_LOCAL_AMOUNT, NEW_LOCAL_AMOUNT)
        SELECT PROCESS_ID, (SELECT ISNULL(MAX(SEQ_ITEM_NO), 0) FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId AND ISNULL(PO_NO, '') = ISNULL(@poNo, '')) + 1,
        PR_NO, PR_ITEM_NO, VENDOR_CD, VENDOR_NAME, QUOTATION_NO, PURCHASING_GRP_CD, VALUATION_CLASS, MAT_NO, MAT_DESC,
        PROCUREMENT_PURPOSE, DELIVERY_PLAN_DT, SOURCE_TYPE, PLANT_CD, SLOC_CD, WBS_NO, COST_CENTER_CD, UNLIMITED_FLAG, TOLERANCE_PERCENTAGE, SPECIAL_PROCUREMENT_TYPE,
        PO_QTY_ORI, PO_QTY_USED, PO_QTY_REMAIN, UOM, CURR_CD, ORI_AMOUNT, NEW_FLAG, UPDATE_FLAG, DELETE_FLAG, PO_NO,
        PO_ITEM_NO, URGENT_DOC, GROSS_PERCENT, ITEM_CLASS, IS_PARENT, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT, WBS_NAME,
        GL_ACCOUNT, PO_QTY_NEW, ORI_PRICE_PER_UOM, NEW_PRICE_PER_UOM, NEW_AMOUNT, ORI_LOCAL_AMOUNT, NEW_LOCAL_AMOUNT
        FROM TB_T_PO_ITEM WHERE PROCESS_ID = @processId AND ISNULL(PO_NO, '') = ISNULL(@poNo, '') AND ISNULL(PO_ITEM_NO, '') = ISNULL(@poItemNo, '') AND SEQ_ITEM_NO = @seqItemNo

        SET @message = 'I|Copy data in TB_T_PO_ITEM where PO_NO: ' + ISNULL(@poNo, 'NULL') + ' and PO_ITEM_NO: NULL and SEQ_ITEM_NO: ' + CAST(@seqItemNo AS VARCHAR) + ': end'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
        
        COMMIT TRAN CopyItemTemp
        
        SET @message = 'S|Finish'
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN CopyItemTemp
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ' - ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
    END CATCH
    
    EXEC sp_PutLog_Temp @tmpLog
    SET NOCOUNT OFF
    
    SELECT @message [Message]
END

