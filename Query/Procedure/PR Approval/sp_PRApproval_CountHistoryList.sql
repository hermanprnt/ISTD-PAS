CREATE PROCEDURE sp_PRApproval_CountHistoryList
    @docNo VARCHAR(11),
    @itemNo INT,
    @docType VARCHAR(2)
AS
BEGIN
    -- Created By   : alira.salman
    -- Created Date : 02.03.2015
    -- Description  : Get PRApproval module history data (TB_R_WORKFLOW).
    
    DECLARE 
        @MAX_RECORD AS BIGINT,
        @TOTAL_RECORD AS BIGINT
    
    SELECT @MAX_RECORD = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH';
    
    SELECT @TOTAL_RECORD = COUNT(DOCUMENT_SEQ)
    FROM
    (
        SELECT TOP (@MAX_RECORD) W.DOCUMENT_SEQ AS 'DOCUMENT_SEQ'
        FROM TB_R_WORKFLOW W
        WHERE
            W.DOCUMENT_NO = @docNo
            AND W.ITEM_NO = @itemNo
            AND (ISNULL(W.IS_DISPLAY, '') = '' OR W.IS_DISPLAY = 'Y')
    ) AS PRAPPROVALHISTORY_UNORDERED
    ;
    
    SELECT @MAX_RECORD = MIN(ROWMIN) FROM (VALUES (@MAX_RECORD), (@TOTAL_RECORD)) B(ROWMIN);
    SELECT @MAX_RECORD;
END