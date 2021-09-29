CREATE PROCEDURE sp_PRApproval_GetHistoryList
    @docNo VARCHAR(11),
    @itemNo INT,
    @docType VARCHAR(2),
    @pageIndex INT,
    @pageSize INT
AS
BEGIN
    -- Created By   : alira.salman
    -- Created Date : 02.03.2015
    -- Description  : Get PRApproval module history data (TB_R_WORKFLOW).
    
    DECLARE 
        @MAX_RECORD AS BIGINT
    
    SELECT @MAX_RECORD = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE SYSTEM_CD = 'MAX_SEARCH';
    SELECT @MAX_RECORD = MIN(ROWMIN) FROM (VALUES (@MAX_RECORD), (@pageIndex * @pageSize)) B(ROWMIN);
    
    
    SELECT TOP (@pageSize) PRAPPROVALHISTORY_ORDERED.*
    FROM
    (
        SELECT TOP (@MAX_RECORD) ROW_NUMBER() OVER (ORDER BY PRAPPROVALHISTORY_UNORDERED.DOCUMENT_SEQ DESC) AS 'NUMBER', PRAPPROVALHISTORY_UNORDERED.*
        FROM
        (
            SELECT
                W.DOCUMENT_NO AS 'DOCUMENT_NO',
                W.ITEM_NO AS 'ITEM_NO',
                W.DOCUMENT_SEQ AS 'DOCUMENT_SEQ',
                @docType AS 'DOCUMENT_TYPE', 
                W.APPROVAL_DESC AS 'APPROVAL_DESC',
                W.APPROVED_BY AS 'APPROVED_BY',
                W.APPROVED_DT AS 'APPROVED_DT',
                W.STRUCTURE_ID AS 'STRUCTURE_ID',
                W.STRUCTURE_NAME AS 'STRUCTURE_NAME',
                W.APPROVER_POSITION AS 'APPROVER_POSITION'
            FROM TB_R_WORKFLOW W
            WHERE
                W.DOCUMENT_NO = @docNo
                AND W.ITEM_NO = @itemNo
                AND (ISNULL(W.IS_DISPLAY, '') = '' OR W.IS_DISPLAY = 'Y')
        ) AS PRAPPROVALHISTORY_UNORDERED
    ) AS PRAPPROVALHISTORY_ORDERED
    WHERE
        PRAPPROVALHISTORY_ORDERED.NUMBER >= (((@pageIndex - 1) * @pageSize) + 1)
    ;
END