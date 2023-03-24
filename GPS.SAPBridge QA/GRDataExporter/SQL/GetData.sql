BEGIN
    DECLARE
        @@message VARCHAR(MAX),
        @@actionName VARCHAR(50) = 'GRDataExporter_GetData.sql',
        @@tmpLog LOG_TEMP,
        @@currentUser VARCHAR(50) = 'GRDataExporter'

    SET NOCOUNT ON
    BEGIN TRY
        INSERT INTO @@tmpLog VALUES (@ProcessId, GETDATE(), 'INF', 'INF', 'I|Start', @ModuleId, @@actionName, @FunctionId, 1, @@currentUser)

        BEGIN TRAN GetData

        MERGE INTO TB_R_GR_IR gr USING (
            SELECT gri.* FROM TB_R_GR_IR gri 
            JOIN TB_R_PO_H poh ON gri.PO_NO = poh.PO_NO
            JOIN TB_R_PO_ITEM poi ON gri.PO_NO = poi.PO_NO
            AND gri.PO_ITEM = poi.PO_ITEM_NO
            WHERE gri.SAP_MAT_DOC_NO IS NULL AND STATUS_CD = '60'
            AND poi.ITEM_CLASS = 'M' AND COMPONENT_PRICE_CD = 'PB00'
            AND gri.PROCESS_ID IS NULL) tmp
        ON gr.PO_NO = tmp.PO_NO AND gr.PO_ITEM = tmp.PO_ITEM AND gr.MAT_DOC_NO = tmp.MAT_DOC_NO
        WHEN MATCHED THEN
        UPDATE SET gr.PROCESS_ID = @ProcessId
        ;

        COMMIT TRAN GetData

        INSERT INTO @@tmpLog VALUES (@ProcessId, GETDATE(), 'SUC', 'SUC', 'S|Finish', @ModuleId, @@actionName, @FunctionId, 2, @@currentUser)
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN GetData
        SET @@message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
        INSERT INTO @@tmpLog VALUES (@ProcessId, GETDATE(), 'ERR', 'ERR', @@message, @ModuleId, @@actionName, @FunctionId, 3, @@currentUser)
    END CATCH

    EXEC sp_putLog_Temp @@tmpLog
    SET NOCOUNT OFF

    SELECT
        ISNULL(dbo.fn_date_format(gr.POSTING_DT), '') + '${tab}' +
        ISNULL(dbo.fn_date_format(gr.DOCUMENT_DT), '') + '${tab}' +
        ISNULL(gr.MAT_DOC_NO, '')  + '${tab}' + /* MAT_DOC_NO = REF_DOC_NO = GR Number */
        ISNULL(gr.HEADER_TEXT, '') + '${tab}' +
        ISNULL(REPLACE(ISNULL(CAST(CAST(gr.MOVEMENT_QTY AS INT) AS VARCHAR), ''), '.', ','), '') + '${tab}' +
        ISNULL(gr.UNIT_OF_MEASURE_CD, '') + '${tab}' +
        ISNULL(gr.PO_NO, '') + '${tab}' +
        ISNULL(gr.PO_ITEM, '') + '${tab}' +
        ISNULL(gr.CREATED_BY, '') /* GR Recipient */ DataRow
    FROM TB_R_GR_IR gr
    WHERE gr.PROCESS_ID = @ProcessId AND gr.COMPONENT_PRICE_CD = 'PB00'
END
