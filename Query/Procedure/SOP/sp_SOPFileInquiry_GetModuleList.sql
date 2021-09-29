USE [PAS_DB_QA]
GO
/****** Object:  StoredProcedure [dbo].[sp_ItemList_GetList]    Script Date: 12/18/2017 11:21:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SOPFileInquiry_GetModuleList]
AS
BEGIN
	SELECT 'PR Module' AS NAME, 'PR' AS VALUE
	UNION ALL
	SELECT 'PO Module' AS NAME, 'PO' AS VALUE
	UNION ALL
	SELECT 'GR Module' AS NAME, 'GR' AS VALUE
END