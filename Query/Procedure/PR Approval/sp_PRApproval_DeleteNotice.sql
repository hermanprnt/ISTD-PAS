CREATE PROCEDURE sp_PRApproval_DeleteNotice
    @docNo VARCHAR(11),
    @seqNo INT
AS
BEGIN
    -- Created By   : alira.salman
    -- Created Date : 23.04.2015
    -- Description  : Delete PRApproval notice data (TB_R_NOTICE).
    
    DELETE FROM TB_R_NOTICE
    WHERE
        DOC_NO = @docNo
        AND SEQ_NO = @seqNo
END