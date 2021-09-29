--USE [NEW_BMS_DB]
--GO
-- =============================================
-- Author:		FID : Asep Syahidin
-- Create date:  01/02/2017
-- Description:	Auto Sync Exchange Rate with BMS
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[sp_ExchangeRateSyncRequest] AS
BEGIN TRY

    SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#ExcRateMax') IS NOT NULL
		DROP TABLE #ExcRateMax

	SELECT CURR_CD, MAX(VALID_DT_FROM) AS MAX_VALID_DT_FROM INTO #ExcRateMax FROM TB_M_EXCHANGE_RATE
	GROUP BY CURR_CD
	
	INSERT INTO #ExcRateMax
	SELECT CURR_CD, '1971-01-01' AS MAX_VALID_DT_FROM FROM BMS_DB.NEW_BMS_DB.[dbo].TB_M_EXCHANGE_RATE 
		WHERE CURR_CD NOT IN (SELECT DISTINCT CURR_CD  FROM #ExcRateMax )
		GROUP BY CURR_CD

	DECLARE @ExcRateSync TABLE
	(
		NUM INT IDENTITY(1,1),
		CURR_CD VARCHAR(3), 
		VALID_FROM_DT datetime, 
		VALID_TO_DT datetime, 
		EXCHANGE_RATE numeric (16,5), 
		CREATED_BY VARCHAR(20), 
		CREATE_DT datetime, 
		CHANGED_BY VARCHAR(20), 
		CHANGED_DT datetime
	)

	DECLARE @Curr_cd VARCHAR(3), @Valid_from_dt datetime, @Valid_from_to datetime, @Exchange_rate numeric (16,5), @Created_by VARCHAR(20), @Created_dt datetime, @Changed_by VARCHAR(20), @Changed_dt datetime, @Current_Currcd VARCHAR(3), @rowNum int
	SET @Current_Currcd = ''

	INSERT INTO @ExcRateSync
	SELECT DEST_TABLE.* 
	FROM BMS_DB.NEW_BMS_DB.[dbo].TB_M_EXCHANGE_RATE DEST_TABLE
	INNER JOIN #ExcRateMax SOURCE_TABLE ON DEST_TABLE.CURR_CD = SOURCE_TABLE.CURR_CD AND DEST_TABLE.VALID_FROM_DT > SOURCE_TABLE.MAX_VALID_DT_FROM

	SET @rowNum = (SELECT TOP 1 NUM FROM @ExcRateSync ORDER BY NUM)

	WHILE @rowNum IS NOT NULL
	BEGIN
		SELECT @Curr_cd = CURR_CD, @Valid_from_dt = VALID_FROM_DT, @Valid_from_to = VALID_TO_DT, @Exchange_rate = EXCHANGE_RATE, @Created_by = CREATED_BY, @Created_dt = CREATE_DT, @Changed_by = CHANGED_BY, @Changed_dt = CHANGED_DT FROM @ExcRateSync where NUM = @rowNum
		
		IF(@Current_Currcd != @Curr_cd)
		BEGIN
			UPDATE TB_M_EXCHANGE_RATE SET VALID_DT_TO = DATEADD(day, -1, @Valid_from_dt) WHERE CURR_CD = @Curr_cd AND VALID_DT_FROM = (SELECT TOP 1 MAX_VALID_DT_FROM FROM #ExcRateMax WHERE CURR_CD = @Curr_cd)

			SET @Current_Currcd = @Curr_cd
		END

		IF(@Current_Currcd = @Curr_cd)
		BEGIN
			IF EXISTS( SELECT 1 FROM @ExcRateSync WHERE CURR_CD = @Curr_cd AND NUM = @rowNum +1)
			BEGIN
				INSERT INTO TB_M_EXCHANGE_RATE (CURR_CD, EXCHANGE_RATE, VALID_DT_FROM, VALID_DT_TO,RELEASED_FLAG, CREATED_BY, CREATED_DT)
				VALUES(@Curr_cd, @Exchange_rate, @Valid_from_dt,@Valid_from_to, 1, @Created_by, @Created_dt)
			END
			ELSE BEGIN
				INSERT INTO TB_M_EXCHANGE_RATE (CURR_CD, EXCHANGE_RATE, VALID_DT_FROM, VALID_DT_TO,RELEASED_FLAG, CREATED_BY, CREATED_DT)
				VALUES(@Curr_cd, @Exchange_rate, @Valid_from_dt,'9999-12-31', 1, @Created_by, @Created_dt)
			END
		END

		--Select @rowNum, @Curr_cd, @Valid_from_dt, @Valid_from_to, @Exchange_rate, @Created_by, @Created_dt, @Changed_by, @Changed_dt
		SET @rowNum = (SELECT TOP 1 NUM FROM @ExcRateSync WHERE NUM > @rowNum  ORDER BY NUM)
	END;

END TRY
BEGIN CATCH   
    DECLARE @ErrorMessage NVARCHAR(4000)
    DECLARE @ErrorSeverity INT
    DECLARE @ErrorState INT
    DECLARE @ErrorLine INT
   
    SELECT @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE(),
            @ErrorLine = ERROR_LINE()
  
   
    PRINT 'sp_ExchangeRateSyncRequest : ' + @ErrorMessage + ', at line = ' +  cast (@ErrorLine as varchar)
       
END CATCH


