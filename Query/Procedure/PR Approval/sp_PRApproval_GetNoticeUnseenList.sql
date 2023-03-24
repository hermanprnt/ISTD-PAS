CREATE PROCEDURE sp_PRApproval_GetNoticeUnseenList
    @noreg VARCHAR(50)
AS
BEGIN
    -- Created By   : alira.salman
    -- Created Date : 23.04.2015
    -- Description  : Get PRApproval notice data (TB_R_NOTICE).
    
    DECLARE 
        @QUERY AS VARCHAR(MAX)
    
    SET @QUERY = 'SELECT DISTINCT DOC_NO, DOC_TYPE, DOC_DATE, NOTICE_FROM_ALIAS, CREATED_DT
    FROM TB_R_NOTICE N
    WHERE 
        N.NOTICE_TO_USER LIKE ''%' + @noreg + ']%''
        AND (
            ISNULL(N.SEEN_BY, '''') = ''''
            OR N.SEEN_BY NOT LIKE ''%' + @noreg + ']%''
        )
    ORDER BY N.DOC_NO ASC';
    
    EXEC (@QUERY)
END