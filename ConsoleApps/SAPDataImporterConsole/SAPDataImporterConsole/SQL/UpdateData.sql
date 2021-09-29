DECLARE @@MESSAGE VARCHAR(MAX) = ''

BEGIN TRANSACTION
BEGIN TRY

    --1. Update Header if result from SAP is success
    IF(@TYPE = 'PO')
    BEGIN
        UPDATE poh
            SET SAP_PO_NO = tsap.SAP_PO_NO,
                PO_STATUS = '44',
                PO_NEXT_STATUS = '44',
				RELEASED_FLAG = 'Y',
				RELEASED_DT = GETDATE(),
				PROCESS_ID = NULL
        FROM TB_R_PO_H poh JOIN #SAP_OUTPUT_TEMP tsap
            ON poh.PO_NO = tsap.PO_NO AND tsap.STATUS = 'S' AND tsap.IS_DONE = 'N'

        UPDATE #SAP_OUTPUT_TEMP SET IS_DONE = 'Y' WHERE STATUS = 'S'
		
		--20200129 start
		--insert/update into tabel err_receiving where SAP status = 'E'	
		delete from TB_R_ERR_PO 
		where PO_NO = any(select P.PO_NO from #SAP_OUTPUT_TEMP T join TB_R_ERR_PO P on T.PO_NO = P.PO_NO WHERE T.PO_NO = P.PO_NO)

		insert into TB_R_ERR_PO
		(
			[PO_NO],
			[STATUS],
			[ERROR_MESSAGE],
			[CREATED_DT]
		)
		(
			SELECT
			T.[PO_NO],
			T.[STATUS],
			T.[MESSAGE],
			GETDATE()
			FROM #SAP_OUTPUT_TEMP T
			LEFT JOIN TB_R_ERR_PO P ON T.PO_NO = P.PO_NO
			WHERE T.[STATUS] = 'E' AND P.PO_NO IS NULL
		)
		--20200129 end
    END

    IF(@TYPE = 'GR')
    BEGIN
		
        UPDATE gr
            SET SAP_MAT_DOC_NO = tsap.MAT_DOC_NO,
                SAP_MAT_DOC_YEAR = tsap.DOC_YEAR,
				CHANGED_DT = getdate(),
                STATUS_CD = '62'
        FROM TB_R_GR_IR gr JOIN #SAP_OUTPUT_TEMP tsap
            ON gr.MAT_DOC_NO = tsap.REF_DOC_NO AND gr.PO_NO = tsap.PO_NO AND tsap.STATUS = 'S' AND tsap.IS_DONE = 'N'

        UPDATE #SAP_OUTPUT_TEMP SET IS_DONE = 'Y' WHERE STATUS = 'S'

        UPDATE gr
            SET STATUS_CD = '68'
				,CHANGED_DT = getdate()
        FROM TB_R_GR_IR gr JOIN #SAP_OUTPUT_TEMP tsap
            ON gr.MAT_DOC_NO = tsap.REF_DOC_NO AND gr.PO_NO = tsap.PO_NO AND tsap.STATUS = 'E' AND tsap.IS_DONE = 'N' 

		--20191127 start
		--insert/update into tabel err_receiving where SAP status = 'E'
		delete from TB_R_ERR_RECEIVING
		WHERE [RECEIVING_NO] = ANY(select R.[RECEIVING_NO] from #SAP_OUTPUT_TEMP T join TB_R_ERR_RECEIVING R on T.[REF_DOC_NO] = R.[RECEIVING_NO] WHERE T.[REF_DOC_NO] = R.[RECEIVING_NO])
		
		INSERT INTO TB_R_ERR_RECEIVING
		(
			[RECEIVING_NO],
			[PO_NO],
			[ITEM_NO],
			[STATUS],
			[ERROR_MESSAGE],
			[CREATED_DT]
		)
		(SELECT
			T.[REF_DOC_NO],
			T.[PO_NO],
			T.[PO_ITEM],
			T.[STATUS],
			T.[MESSAGE],
			GETDATE()
		FROM #SAP_OUTPUT_TEMP T
		LEFT JOIN TB_R_ERR_RECEIVING R ON T.[REF_DOC_NO] = R.[RECEIVING_NO]
		WHERE T.[STATUS] = 'E' AND R.[RECEIVING_NO] IS NULL)
		--20191127 start
	END

    IF(@TYPE = 'SA')
    BEGIN
        UPDATE sa
            SET SAP_MAT_DOC_NO = tsap.ENTRY_SHEET,
                STATUS_CD = '62'
        FROM TB_R_GR_IR sa JOIN #SAP_OUTPUT_TEMP tsap
            ON sa.MAT_DOC_NO = tsap.REF_DOC_NO AND sa.PO_NO = tsap.PO_NO AND sa.PO_ITEM = tsap.PO_ITEM AND tsap.STATUS = 'S' AND tsap.IS_DONE = 'N'

        UPDATE #SAP_OUTPUT_TEMP SET IS_DONE = 'Y' WHERE STATUS = 'S'

        UPDATE sa
            SET STATUS_CD = '68'
        FROM TB_R_GR_IR sa JOIN #SAP_OUTPUT_TEMP tsap
            ON sa.MAT_DOC_NO = tsap.REF_DOC_NO AND sa.PO_NO = tsap.PO_NO AND sa.PO_ITEM = tsap.PO_ITEM AND tsap.STATUS = 'E' AND tsap.IS_DONE = 'N'

		--20191127 start
		--insert/update into tabel err_receiving where SAP status = 'E'
		delete from TB_R_ERR_RECEIVING
		WHERE [RECEIVING_NO] = ANY(select R.[RECEIVING_NO] from #SAP_OUTPUT_TEMP T join TB_R_ERR_RECEIVING R on T.[REF_DOC_NO] = R.[RECEIVING_NO] WHERE T.[REF_DOC_NO] = R.[RECEIVING_NO])

		INSERT INTO TB_R_ERR_RECEIVING
		(
			[RECEIVING_NO],
			[PO_NO],
			[ITEM_NO],
			[STATUS],
			[ERROR_MESSAGE],
			[CREATED_DT]
		)
		(SELECT
			T.[REF_DOC_NO],
			T.[PO_NO],
			T.[PO_ITEM],
			T.[STATUS],
			T.[MESSAGE],
			GETDATE()
		FROM #SAP_OUTPUT_TEMP T
		LEFT JOIN TB_R_ERR_RECEIVING R ON T.[REF_DOC_NO] = R.[RECEIVING_NO]
		WHERE T.[STATUS] = 'E' AND R.[RECEIVING_NO] IS NULL)
		--20191127 end

    END

	IF(@TYPE = 'IR')
    BEGIN
        UPDATE mp
            SET SAP_NO = CASE WHEN STATUS = 'S' THEN tsap.ENTRY_SHEET ELSE NULL END,
                SAP_REMARKS = CASE WHEN STATUS = 'S' THEN tsap.MESSAGE ELSE ISNULL(SAP_REMARKS,'') + tsap.MESSAGE END + ';'
        FROM TB_M_MATERIAL_PRICE mp JOIN #SAP_OUTPUT_TEMP tsap
            ON mp.PRICE_ID = tsap.REF_DOC_NO AND tsap.IS_DONE = 'N'

        UPDATE #SAP_OUTPUT_TEMP SET IS_DONE = 'Y' WHERE STATUS = 'S'
    END

	IF(@TYPE = 'SL')
    BEGIN
        UPDATE sl
            SET SAP_NO = CASE WHEN STATUS = 'S' THEN '000000' ELSE NULL END,
                SAP_REMARKS = CASE WHEN STATUS = 'S' THEN tsap.MESSAGE ELSE tsap.MESSAGE END
        FROM TB_M_SOURCE_LIST sl JOIN #SAP_OUTPUT_TEMP tsap
            ON sl.SOURCE_LIST_ID = tsap.REF_DOC_NO AND tsap.IS_DONE = 'N'

        UPDATE #SAP_OUTPUT_TEMP SET IS_DONE = 'Y' WHERE STATUS = 'S'
    END
    --End of Step 1

    --2. Insert Log if result from SAP is Error/Failed
    DECLARE @@LOCATION VARCHAR(50) = 'SAP ' + @TYPE + ' Synchronous'
    WHILE EXISTS(SELECT 1 FROM #SAP_OUTPUT_TEMP WHERE STATUS = 'E' AND IS_DONE = 'N')
    BEGIN
        DECLARE @@KEY VARCHAR(MAX), @@ID INT
        
        SELECT TOP 1 @@ID = ID, 
                     @@MESSAGE = 
                        CASE WHEN(@TYPE = 'PO') THEN 'PO No ' + PO_NO + ' : '
                             WHEN(@TYPE = 'GR' OR @TYPE = 'SA') THEN 'Mat Doc No ' + REF_DOC_NO + ', PO No. ' + PO_NO + ', PO Item No. ' + PO_ITEM + ' : '
                        END + MESSAGE
        FROM #SAP_OUTPUT_TEMP WHERE STATUS = 'E' AND IS_DONE = 'N' ORDER BY PO_NO, ID ASC

        EXEC [dbo].[sp_PutLog] @@MESSAGE, 'SYSTEM', @@LOCATION, @PROCESS_ID, null, 'ERR', @MODULE, @FUNCTION, 1

        UPDATE #SAP_OUTPUT_TEMP SET IS_DONE = 'Y' WHERE ID = @@ID
    END

	IF(@TYPE = 'PO')
    BEGIN
		UPDATE TB_R_PO_H SET PROCESS_ID = NULL WHERE PO_NO IN (SELECT PO_NO FROM #SAP_OUTPUT_TEMP WHERE IS_DONE = 'Y') AND ISNULL(PROCESS_ID, '') <> ''
	END

    SET @@LOCATION = 'Import Data ' + @TYPE
    SET @@MESSAGE = 'Import data ' + @TYPE + ' Finished Successfully'
    EXEC [dbo].[sp_PutLog] @@MESSAGE, 'SYSTEM', @@LOCATION, @PROCESS_ID, null, 'INF', @MODULE, @FUNCTION, 2
    --End of step 2

    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION

    SELECT @@MESSAGE = ERROR_MESSAGE()
    RAISERROR(@@MESSAGE, 16, 1)
END CATCH