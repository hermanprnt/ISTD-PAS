-- =================================================
-- Author:        alira.salman
-- Create date: 05.05.2015 
-- Description:    Backward Checking Approve PRApproval
-- =================================================
CREATE PROCEDURE [dbo].[sp_BackwardChecking_ApprovePRApproval]
    -- Add the parameters for the stored procedure here
    @DOC_NO AS VARCHAR(11),
    @DOC_TYPE AS VARCHAR(2),
    @ITEM_NO AS VARCHAR(50)
AS
BEGIN
    DECLARE
        @DOC_NEXT_APPROVAL_CD AS VARCHAR(50),
        @DOC_LAST_APPROVAL_CD AS VARCHAR(50),
        @DOC_SUMMARY_APPROVAL_CD AS VARCHAR(50),
        @USER_NEXT_APPROVAL_CD AS VARCHAR(50),
        @SEQ_NO AS INT,
        @USER_NAME AS VARCHAR(50)

    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
        
    SELECT TOP 1
        @USER_NEXT_APPROVAL_CD = W.APPROVAL_CD,
        @SEQ_NO = W.DOCUMENT_SEQ,
        @USER_NAME = W.APPROVED_BY
    FROM TB_R_WORKFLOW W
    WHERE
        W.DOCUMENT_NO = @DOC_NO
        AND W.ITEM_NO = @ITEM_NO
        AND W.IS_APPROVED = 'N'
        AND W.IS_DISPLAY = 'Y'
    ORDER BY DOCUMENT_SEQ ASC;
    
    IF EXISTS (
        SELECT TOP 1 APPROVAL_CD
        FROM TB_R_WORKFLOW W
        WHERE
            W.DOCUMENT_NO = @DOC_NO
            AND W.ITEM_NO = @ITEM_NO
            AND W.APPROVED_BY = @USER_NAME
            AND W.DOCUMENT_SEQ < @SEQ_NO
            AND W.IS_DISPLAY = 'Y'
        ORDER BY W.DOCUMENT_SEQ ASC
    ) 
    BEGIN
        --//// Logic Get Document Last Approval Code (Document Release).
        SELECT TOP 1 
            @DOC_LAST_APPROVAL_CD = APPROVAL_CD
        FROM TB_R_WORKFLOW
        WHERE
            DOCUMENT_NO = @DOC_NO
            AND ITEM_NO = @ITEM_NO
            AND IS_APPROVED = 'N'
            AND IS_DISPLAY = 'Y'
        ORDER BY DOCUMENT_SEQ DESC        

        --//// Update WORKFLOW
        UPDATE TB_R_WORKFLOW
        SET
            APPROVED_DT = GETDATE(),
            IS_APPROVED = 'Y',
            IS_REJECTED = 'N',
            CHANGED_BY = @USER_NAME,
            CHANGED_DT = GETDATE()
        WHERE
            DOCUMENT_NO = @DOC_NO
            AND ITEM_NO = @ITEM_NO
            AND APPROVED_BY = @USER_NAME
            AND IS_APPROVED = 'N'
            AND IS_DISPLAY = 'Y'
            AND APPROVAL_CD = @USER_NEXT_APPROVAL_CD;
                            
        SELECT TOP 1
            @DOC_NEXT_APPROVAL_CD = APPROVAL_CD
        FROM TB_R_WORKFLOW
        WHERE
            DOCUMENT_NO = @DOC_NO
            AND ITEM_NO = @ITEM_NO
            AND IS_APPROVED = 'N'
            AND IS_DISPLAY = 'Y'
        ORDER BY DOCUMENT_SEQ ASC;

        IF @DOC_TYPE = 'PR'
        BEGIN
            --//// Update DOCUMENT DETAIL
            UPDATE TB_R_PR_ITEM
            SET
                PR_STATUS = @USER_NEXT_APPROVAL_CD,
                PR_NEXT_STATUS = @DOC_NEXT_APPROVAL_CD,
                IS_REJECTED = 'N',
                RELEASE_FLAG =
                (
                    CASE 
                        WHEN @USER_NEXT_APPROVAL_CD = @DOC_LAST_APPROVAL_CD THEN
                            'Y'
                        ELSE
                            'N'
                    END
                ),
                CHANGED_BY = @USER_NAME,
                CHANGED_DT = GETDATE()
            WHERE
                PR_NO = @DOC_NO
                AND PR_ITEM_NO = @ITEM_NO;

            --//// Summary of DOCUMENT DETAIL
            --//// Outstanding Status for document in TB_M_STATUS is 91.
            --//// Released Status for document in TB_M_STATUS is 92.
            IF EXISTS (
                SELECT PR_NO
                FROM TB_R_PR_ITEM
                WHERE
                    PR_NO = @DOC_NO
                    AND PR_STATUS <> @DOC_LAST_APPROVAL_CD)
            BEGIN
                SET @DOC_SUMMARY_APPROVAL_CD = 91;
            END
            ELSE
            BEGIN
                SET @DOC_SUMMARY_APPROVAL_CD = 92;
            END

            --//// Update DOCUMENT HEADER
            --//// Update document header occur after update document detail because
            --//// document header update based on summary of document detail value.
            UPDATE TB_R_PR_H
            SET
                PR_STATUS = @DOC_SUMMARY_APPROVAL_CD,
                RELEASED_FLAG = 
                (
                    CASE 
                        WHEN @DOC_SUMMARY_APPROVAL_CD = 92 THEN
                            'Y'
                        ELSE
                            'N'
                    END
                ),
                CHANGED_BY = @USER_NAME,
                CHANGED_DT = GETDATE()
            WHERE
                PR_NO = @DOC_NO;
        END
        ELSE IF @DOC_TYPE = 'PO'
        BEGIN
            --//// Update DOCUMENT DETAIL
            UPDATE TB_R_PO_ITEM
            SET
                PO_STATUS = @USER_NEXT_APPROVAL_CD,
                PO_NEXT_STATUS = @DOC_NEXT_APPROVAL_CD,
                IS_REJECTED = 'N',
                RELEASE_FLAG =
                (
                    CASE 
                        WHEN @USER_NEXT_APPROVAL_CD = @DOC_LAST_APPROVAL_CD THEN
                            'Y'
                        ELSE
                            'N'
                    END
                ),
                CHANGED_BY = @USER_NAME,
                CHANGED_DT = GETDATE()
            WHERE
                PO_NO = @DOC_NO
                AND PO_ITEM_NO = @ITEM_NO;

            --//// Summary of DOCUMENT DETAIL
            --//// Outstanding Status for document in TB_M_STATUS is 91.
            --//// Released Status for document in TB_M_STATUS is 92.
            IF EXISTS (
                SELECT PO_NO
                FROM TB_R_PO_ITEM
                WHERE
                    PO_NO = @DOC_NO
                    AND PO_STATUS <> @DOC_LAST_APPROVAL_CD)
            BEGIN
                SET @DOC_SUMMARY_APPROVAL_CD = 91;
            END
            ELSE
            BEGIN
                SET @DOC_SUMMARY_APPROVAL_CD = 92;
            END

            --//// Update DOCUMENT HEADER
            --//// Update document header occur after update document detail because
            --//// document header update based on summary of document detail value.
            UPDATE TB_R_PO_H
            SET
                PO_STATUS = @DOC_SUMMARY_APPROVAL_CD,
                RELEASED_FLAG = 
                (
                    CASE 
                        WHEN @DOC_SUMMARY_APPROVAL_CD = 92 THEN
                            'Y'
                        ELSE
                            'N'
                    END
                ),
                CHANGED_BY = @USER_NAME,
                CHANGED_DT = GETDATE()
            WHERE
                PO_NO = @DOC_NO;
        END;

        EXEC sp_BackwardChecking_ApprovePRApproval @DOC_NO, @DOC_TYPE, @ITEM_NO;
    END;

    RETURN;
END