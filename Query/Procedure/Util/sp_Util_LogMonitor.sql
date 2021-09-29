CREATE PROCEDURE [dbo].[sp_Util_LogMonitor]
    @currentUser VARCHAR(50),
    @processId VARCHAR(50),
    @functionId VARCHAR(6)
AS
BEGIN
    DECLARE @message VARCHAR(MAX)
    
    SET NOCOUNT ON
    
    IF (ISNULL(@currentUser, '') = '' AND ISNULL(@processId, '') = '' AND ISNULL(@functionId, '') = '')
    BEGIN
        SELECT 'E|Either Username, Function Id or Process Id must be defined' RETURN
    END
    
    SELECT
    CAST(logh.PROCESS_ID AS VARCHAR) ProcessId,
    logh.MODULE_ID + ': ' + mod.MODULE_NAME Module,
    logh.FUNCTION_ID + ': ' + fun.FUNCTION_NAME [Function],
    CASE logh.PROCESS_STATUS
        WHEN 0 THEN '0: Starting/Initial'
        WHEN 1 THEN '1: Processing'
        WHEN 2 THEN '2: Finish'
        WHEN 3 THEN '3: Finish with error'
        WHEN 4 THEN '4: Abnormal/Unfinish'
    END Status,
    logd.LOCATION Location,
    CAST(logd.SEQ_NO AS VARCHAR) SeqNo,
    logd.MESSAGE_CONTENT [Message],
    CAST(DATEPART(DAY, logh.START_DT) AS VARCHAR) + '.' +
    CAST(DATEPART(MONTH, logh.START_DT) AS VARCHAR) + '.' +
    CAST(DATEPART(YEAR, logh.START_DT) AS VARCHAR) + ' ' +
    CAST(
        CASE WHEN DATEPART(HOUR, logh.START_DT) > 12
            THEN DATEPART(HOUR, logh.START_DT) - 12
            ELSE DATEPART(HOUR, logh.START_DT) END AS VARCHAR) + ':' +
    CAST(DATEPART(MINUTE, logh.START_DT) AS VARCHAR) + ':' +
    CAST(DATEPART(SECOND, logh.START_DT) AS VARCHAR) + ' ' +
    CASE WHEN DATEPART(HOUR, logh.START_DT) > 12 THEN 'PM' ELSE 'AM' END StartDate,
    CAST(DATEPART(DAY, logh.END_DT) AS VARCHAR) + '.' +
    CAST(DATEPART(MONTH, logh.END_DT) AS VARCHAR) + '.' +
    CAST(DATEPART(YEAR, logh.END_DT) AS VARCHAR) + ' ' +
    CAST(
        CASE WHEN DATEPART(HOUR, logh.END_DT) > 12
            THEN DATEPART(HOUR, logh.END_DT) - 12
            ELSE DATEPART(HOUR, logh.END_DT) END AS VARCHAR) + ':' +
    CAST(DATEPART(MINUTE, logh.END_DT) AS VARCHAR) + ':' +
    CAST(DATEPART(SECOND, logh.END_DT) AS VARCHAR) + ' ' +
    CASE WHEN DATEPART(HOUR, logh.END_DT) > 12 THEN 'PM' ELSE 'AM' END EndDate
    FROM TB_R_LOG_H logh
    JOIN TB_R_LOG_D logd ON logh.PROCESS_ID = logd.PROCESS_ID
    AND ISNULL(CAST(logh.PROCESS_ID AS VARCHAR(50)), '') LIKE '%' + ISNULL(@processId, '') + '%'
    AND ISNULL(logh.FUNCTION_ID, '') LIKE '%' + ISNULL(@functionId, '') + '%'
    AND ISNULL(logh.CREATED_BY, '') LIKE '%' + ISNULL(@currentUser, '') + '%'
    LEFT JOIN TB_M_MODULE mod ON logh.MODULE_ID = mod.MODULE_ID
    LEFT JOIN TB_M_FUNCTION fun ON logh.FUNCTION_ID = fun.FUNCTION_ID
    ORDER BY logh.CREATED_DT DESC, logh.CHANGED_DT DESC, logh.PROCESS_ID, logd.SEQ_NO
    
    SET NOCOUNT OFF
END