IF @IsValidOnly = 1
BEGIN
	SELECT COUNT(1) FROM TB_M_EXCHANGE_RATE
    WHERE ISNULL(CURR_CD, '') LIKE '%' + ISNULL(@Currency, '') + '%'
    AND ISNULL(CAST(EXCHANGE_RATE AS VARCHAR), '') LIKE '%' + ISNULL(CAST(@ExchangeRate AS VARCHAR), '') + '%'
    AND ISNULL(FOREX_TYPE, '') LIKE '%' + ISNULL(@ForexType, '') + '%'
    AND ISNULL(RELEASED_FLAG, '') LIKE '%' + ISNULL(@ReleaseFlag, '') + '%'
    AND YEAR(VALID_DT_TO) = 9999
END
ELSE
BEGIN
    SELECT COUNT(1) FROM TB_M_EXCHANGE_RATE
    WHERE ISNULL(CURR_CD, '') LIKE '%' + ISNULL(@Currency, '') + '%'
    AND ISNULL(CAST(EXCHANGE_RATE AS VARCHAR), '') LIKE '%' + ISNULL(CAST(@ExchangeRate AS VARCHAR), '') + '%'
    AND ISNULL(FOREX_TYPE, '') LIKE '%' + ISNULL(@ForexType, '') + '%'
    AND ISNULL(RELEASED_FLAG, '') LIKE '%' + ISNULL(@ReleaseFlag, '') + '%'
    AND (ISNULL(VALID_DT_FROM, CAST('1753-1-1' AS DATETIME)) >= ISNULL(@DateFrom, CAST('1753-1-1' AS DATETIME))
        AND ISNULL(VALID_DT_TO, CAST('9999-12-31' AS DATETIME)) <= ISNULL(@DateTo, CAST('9999-12-31' AS DATETIME)))
END