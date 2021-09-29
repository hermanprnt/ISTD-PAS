USE [NCP_QA]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_datediff_workday]    Script Date: 12/18/2015 9:12:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		FID) Intan Puspitasari
-- Create date: 26.11.2015
-- Description:	Get Date Difference, exclude weekend
-- =============================================
ALTER FUNCTION [dbo].[fn_datediff_workday]
(
	@START SMALLDATETIME,
	@END SMALLDATETIME
)
RETURNS INT
AS
BEGIN
	DECLARE 
		@INTERVAL AS INT,
		@START_DT DATETIME,
		@END_DT DATETIME

	SET @START_DT = CAST(@START AS DATETIME)
	SET @END_DT = CAST(@END AS DATETIME)
	SELECT @INTERVAL =
		   (DATEDIFF(dd, @START_DT, @END_DT))  -- total number of days (inclusive)
		  -(DATEDIFF(wk, @START_DT, @END_DT) * 2) -- number of complete weekends in period
		  -(CASE WHEN DATENAME(dw, @START_DT) = 'Sunday' THEN 1 ELSE 0 END) 
		  -(CASE WHEN DATENAME(dw, @START_DT) = 'Saturday' THEN 1 ELSE 0 END) 

	--SELECT @INTERVAL = CASE WHEN (@INTERVAL = 1) THEN 1 ELSE @INTERVAL-1 END
	RETURN @INTERVAL;
END