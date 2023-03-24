DECLARE @@tmp TABLE
(
    [Number] INT,
    CURR_CD VARCHAR(3),
    EXCHANGE_RATE DECIMAL(7,2),
    VALID_DT_FROM VARCHAR(10),
    VALID_DT_TO VARCHAR(10),
    FOREX_TYPE VARCHAR(1),
    RELEASED_FLAG VARCHAR(1),
    CREATED_BY VARCHAR(20),
    CREATED_DT VARCHAR(10),
    CHANGED_BY VARCHAR(20),
    CHANGED_DT VARCHAR(10)
)

IF @IsValidOnly = 1
BEGIN
    INSERT INTO @@tmp
    SELECT
    ROW_NUMBER() OVER (ORDER BY CURR_CD ASC, VALID_DT_FROM ASC) [Number],
    CURR_CD,
    EXCHANGE_RATE,
    dbo.fn_date_format(VALID_DT_FROM),
    dbo.fn_date_format(VALID_DT_TO),
    FOREX_TYPE,
    RELEASED_FLAG,
    CREATED_BY,
    dbo.fn_date_format(CREATED_DT),
    CHANGED_BY,
    dbo.fn_date_format(CHANGED_DT)
    FROM TB_M_EXCHANGE_RATE
    WHERE ISNULL(CURR_CD, '') LIKE '%' + ISNULL(@Currency, '') + '%'
    AND ISNULL(CAST(EXCHANGE_RATE AS VARCHAR), '') LIKE '%' + ISNULL(CAST(@ExchangeRate AS VARCHAR), '') + '%'
    AND ISNULL(FOREX_TYPE, '') LIKE '%' + ISNULL(@ForexType, '') + '%'
    AND ISNULL(RELEASED_FLAG, '') LIKE '%' + ISNULL(@ReleaseFlag, '') + '%'
    AND YEAR(VALID_DT_TO) = 9999
END
ELSE
BEGIN
    INSERT INTO @@tmp
    SELECT
    ROW_NUMBER() OVER (ORDER BY CURR_CD ASC, VALID_DT_FROM ASC) [Number],
    CURR_CD,
    EXCHANGE_RATE,
    dbo.fn_date_format(VALID_DT_FROM),
    dbo.fn_date_format(VALID_DT_TO),
    FOREX_TYPE,
    RELEASED_FLAG,
    CREATED_BY,
    dbo.fn_date_format(CREATED_DT),
    CHANGED_BY,
    dbo.fn_date_format(CHANGED_DT)
    FROM TB_M_EXCHANGE_RATE
    WHERE ISNULL(CURR_CD, '') LIKE '%' + ISNULL(@Currency, '') + '%'
    AND ISNULL(CAST(EXCHANGE_RATE AS VARCHAR), '') LIKE '%' + ISNULL(CAST(@ExchangeRate AS VARCHAR), '') + '%'
    AND ISNULL(FOREX_TYPE, '') LIKE '%' + ISNULL(@ForexType, '') + '%'
    AND ISNULL(RELEASED_FLAG, '') LIKE '%' + ISNULL(@ReleaseFlag, '') + '%'
    AND (ISNULL(VALID_DT_FROM, CAST('1753-1-1' AS DATETIME)) >= ISNULL(@DateFrom, CAST('1753-1-1' AS DATETIME))
        AND ISNULL(VALID_DT_TO, CAST('9999-12-31' AS DATETIME)) <= ISNULL(@DateTo, CAST('9999-12-31' AS DATETIME)))
END

SELECT * FROM @@tmp WHERE [Number] >= @Start AND [Number] <= @End