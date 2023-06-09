USE [PAS_DB_QA]
GO
/****** Object:  StoredProcedure [dbo].[sp_PRStatusMonitoring_CountList]    Script Date: 12/27/2017 11:26:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_PRStatusMonitoring_GetFilterDelayStatus]
AS 
BEGIN
	SELECT 'Maximum Delay times' AS [NAME], 'MAX_DELAY' AS [VALUE], 1 AS [NO] 
	UNION
	SELECT 'Minimum Delay times' AS [NAME], 'MIN_DELAY' AS [VALUE], 3 AS [NO] 
	ORDER BY [NO]
END
