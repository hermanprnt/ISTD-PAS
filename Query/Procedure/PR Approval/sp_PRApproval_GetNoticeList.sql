CREATE PROCEDURE sp_PRApproval_GetNoticeList
    @docNo VARCHAR(11),
	@noreg VARCHAR(50)
AS
BEGIN
    -- Created By   : alira.salman
    -- Created Date : 01.04.2015
    -- Description  : Get PRApproval notice data (TB_R_NOTICE).
    
    DECLARE 
        @QUERY AS VARCHAR(MAX)
    
    SET @QUERY = 'SELECT
        N.DOC_NO,
        N.DOC_TYPE,
        N.DOC_DATE,
        N.SEQ_NO,
        N.NOTICE_FROM_USER,
        N.NOTICE_FROM_ALIAS,
        N.NOTICE_TO_USER,
        N.NOTICE_TO_ALIAS,
        N.NOTICE_MESSAGE,
        N.NOTICE_IMPORTANCE,
        N.IS_REPLIED,
        N.REPLY_FOR,
        (
            SELECT 
                N2.NOTICE_FROM_ALIAS
            FROM TB_R_NOTICE N2
            WHERE 
                N2.DOC_NO = N.DOC_NO
                AND N2.SEQ_NO = N.REPLY_FOR
        ) AS ''NOTICE_REPLY_FROM_ALIAS'',
        (
            SELECT 
                N2.NOTICE_MESSAGE
            FROM TB_R_NOTICE N2
            WHERE 
                N2.DOC_NO = N.DOC_NO
                AND N2.SEQ_NO = N.REPLY_FOR
        ) AS ''NOTICE_REPLY_MESSAGE'',
        N.CREATED_BY,
        N.CREATED_DT
    FROM TB_R_NOTICE N
    WHERE 
        N.DOC_NO = ''' + @docNo + '''
        AND (
            N.NOTICE_FROM_USER = ''' + @noreg + '''
            OR N.NOTICE_TO_USER LIKE ''%' + @noreg + ']%''
        )
    ORDER BY N.SEQ_NO DESC';
    
    EXEC (@QUERY)
END