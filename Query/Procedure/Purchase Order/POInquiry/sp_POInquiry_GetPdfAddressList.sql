USE [PAS_DB_QA]
GO
/****** Object:  StoredProcedure [dbo].[sp_POInquiry_GetPdfAddressList]    Script Date: 10/12/2017 1:49:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_POInquiry_GetPdfAddressList]
    @poNo VARCHAR(11)
AS
BEGIN
	select M.FUNCTION_ID FunctionId,
		   M.SYSTEM_CD Code,
		   M.SYSTEM_VALUE Value,
		   M.SYSTEM_REMARK Remark,
		   M.CREATED_BY CreatedBy,
		   M.CREATED_DT CreatedDate,
		   M.CHANGED_BY ChangedBy,
		   M.CHANGED_DT ChangedDate
	 FROM TB_R_PO_H poh
		CROSS JOIN TB_M_SYSTEM M
		WHERE poh.PO_NO = @poNo
		AND M.SYSTEM_CD IN (SELECT DISTINCT PLANT_CD FROM TB_R_PO_ITEM POI WHERE POI.PO_NO = poh.PO_NO) 
		AND FUNCTION_ID='DLVADR'
END