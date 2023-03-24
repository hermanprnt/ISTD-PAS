DECLARE
    @@paddedChar VARCHAR(2) = '00',
    @@now DATETIME = GETDATE()
SELECT
    PROCESS_ID ProcessId,
    SYSTEM_TYPE SystemType,
    SYSTEM_CD SystemCode,
    SCH_STATUS [Status],
    CAST(
        CAST(DATEPART(YEAR, EXECUTION_DATE) AS VARCHAR) + '-' +
        STUFF(@@paddedChar, LEN(@@paddedChar)-LEN(DATEPART(MONTH, EXECUTION_DATE))+1, LEN(@@paddedChar), DATEPART(MONTH, EXECUTION_DATE)) + '-' +
        STUFF(@@paddedChar, LEN(@@paddedChar)-LEN(DATEPART(DAY, EXECUTION_DATE))+1, LEN(@@paddedChar), DATEPART(DAY, EXECUTION_DATE)) + ' ' +
        STUFF(@@paddedChar, LEN(@@paddedChar)-LEN(DATEPART(HOUR, EXECUTION_TIME))+1, LEN(@@paddedChar), DATEPART(HOUR, EXECUTION_TIME)) + ':' +
        STUFF(@@paddedChar, LEN(@@paddedChar)-LEN(DATEPART(MINUTE, EXECUTION_TIME))+1, LEN(@@paddedChar), DATEPART(MINUTE, EXECUTION_TIME)) + ':' +
        STUFF(@@paddedChar, LEN(@@paddedChar)-LEN(DATEPART(SECOND, EXECUTION_TIME))+1, LEN(@@paddedChar), DATEPART(SECOND, EXECUTION_TIME))
    AS DATETIME) PlanExecutionTime,
    CAST(
        CAST(DATEPART(YEAR, EXECUTION_DATE) AS VARCHAR) + '-' +
        STUFF(@@paddedChar, LEN(@@paddedChar)-LEN(DATEPART(MONTH, EXECUTION_DATE))+1, LEN(@@paddedChar), DATEPART(MONTH, EXECUTION_DATE)) + '-' +
        STUFF(@@paddedChar, LEN(@@paddedChar)-LEN(DATEPART(DAY, EXECUTION_DATE))+1, LEN(@@paddedChar), DATEPART(DAY, EXECUTION_DATE)) + ' ' +
        STUFF(@@paddedChar, LEN(@@paddedChar)-LEN(DATEPART(HOUR, START_TIME))+1, LEN(@@paddedChar), DATEPART(HOUR, START_TIME)) + ':' +
        STUFF(@@paddedChar, LEN(@@paddedChar)-LEN(DATEPART(MINUTE, START_TIME))+1, LEN(@@paddedChar), DATEPART(MINUTE, START_TIME)) + ':' +
        STUFF(@@paddedChar, LEN(@@paddedChar)-LEN(DATEPART(SECOND, START_TIME))+1, LEN(@@paddedChar), DATEPART(SECOND, START_TIME))
    AS DATETIME) ActualExecutionTime
FROM dbo.TB_R_BACKGROUND_SCHEDULE
WHERE SYSTEM_TYPE = 'BUDGET_CONTROL' AND SCH_STATUS <> '2'
    AND (YEAR(EXECUTION_DATE) = YEAR(@@now)
        AND MONTH(EXECUTION_DATE) = MONTH(@@now)
        AND DAY(EXECUTION_DATE) = DAY(@@now))