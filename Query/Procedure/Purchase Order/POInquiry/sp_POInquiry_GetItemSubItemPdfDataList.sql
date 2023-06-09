USE [PAS_DB_QA]
GO
/****** Object:  StoredProcedure [dbo].[sp_POInquiry_GetItemSubItemPdfDataList]    Script Date: 10/12/2017 1:48:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_POInquiry_GetItemSubItemPdfDataList]
    @poNo VARCHAR(11),
	@address_code VARCHAR(20) = '',
	@plan_code VARCHAR(MAX)=''
AS
BEGIN
    SET NOCOUNT ON
	IF EXISTS (SELECT 1 FROm TB_R_PO_ITEM WHERE DIVISION_ID = '19' AND PO_NO = @poNo)
	BEGIN
		SELECT
			poi.PO_ITEM_NO [No],
			CAST(poi.PO_ITEM_NO AS INT) ItemNo,
			CASE WHEN ISNULL(poi.MAT_NO, 'X') = 'X' THEN '' ELSE poi.MAT_NO END MaterialNo,
			poi.MAT_DESC [Description],
			poi.PO_QTY_ORI Qty,
			poi.UOM,
			poi.DELIVERY_PLAN_DT RequiredDate,
			poi.PRICE_PER_UOM Price,
			poi.ORI_AMOUNT Amount,
			ISNULL(sloc.SLOC_NAME, '') SLoc,
			poi.ITEM_CLASS ItemClass,
			(SELECT SUM(P.ORI_AMOUNT) FROM TB_R_PO_ITEM P
				 WHERE P.PO_NO = poi.PO_NO AND 1 = (CASE WHEN ISNULL(@plan_code,'')='' THEN
												1
											ELSE
												CASE WHEN PLANT_CD IN (SELECT RTRIM(LTRIM(splitdata)) FROM dbo.fnSplitString(@plan_code,', '))
												THEN 1
												ELSE 0 END
											END))POAmount
			INTO #tmpItem1
		FROM TB_R_PO_ITEM poi
		JOIN TB_R_PO_H poh ON poi.PO_NO = poh.PO_NO
		CROSS JOIN TB_M_SYSTEM M
		INNER JOIN TB_M_DELIVERY_ADDR DA ON DA.DELIVERY_ADDR = M.SYSTEM_VALUE
		LEFT JOIN TB_M_SLOC sloc ON poi.PLANT_CD = sloc.PLANT_CD AND poi.SLOC_CD = sloc.SLOC_CD
		WHERE poi.PO_NO = @poNo AND M.SYSTEM_CD = poi.PLANT_CD AND FUNCTION_ID='DLVADR'
			AND (DA.DELIVERY_ADDR = @address_code OR ISNULL(@address_code,'')='')
	END
	ELSE
	BEGIN
		SELECT
			poi.PO_ITEM_NO [No],
			CAST(poi.PO_ITEM_NO AS INT) ItemNo,
			CASE WHEN ISNULL(poi.MAT_NO, 'X') = 'X' THEN '' ELSE poi.MAT_NO END MaterialNo,
			poi.MAT_DESC [Description],
			poi.PO_QTY_ORI Qty,
			poi.UOM,
			poi.DELIVERY_PLAN_DT RequiredDate,
			poi.PRICE_PER_UOM Price,
			poi.ORI_AMOUNT Amount,
			ISNULL(sloc.SLOC_NAME, '') SLoc,
			poi.ITEM_CLASS ItemClass,
			poh.PO_AMOUNT POAmount
			INTO #tmpItem2
		FROM TB_R_PO_ITEM poi
		JOIN TB_R_PO_H poh ON poi.PO_NO = poh.PO_NO
		LEFT JOIN TB_M_SLOC sloc ON poi.PLANT_CD = sloc.PLANT_CD AND poi.SLOC_CD = sloc.SLOC_CD
		WHERE poi.PO_NO = @poNo
	END

	IF EXISTS (SELECT 1 FROm TB_R_PO_ITEM WHERE DIVISION_ID = '19' AND PO_NO = @poNo)
	BEGIN
		SELECT
			CAST(si.PO_SUBITEM_NO AS INT) SubItemNo,
			CASE WHEN ISNULL(si.MAT_NO, 'X') = 'X' THEN '' ELSE si.MAT_NO END SubItemMaterialNo,
			si.MAT_DESC SubItemDesc,
			si.PO_QTY_ORI SubItemQty,
			si.UOM SubItemUOM,
			si.PRICE_PER_UOM SubItemPrice,
			si.ORI_AMOUNT SubItemAmount,
			CAST(si.PO_ITEM_NO AS INT) ItemNo
			INTO #tmpSubItem1
		FROM TB_R_PO_SUBITEM si
		INNER JOIN TB_R_PO_ITEM POI ON POI.PO_NO = si.PO_NO AND POI.PO_ITEM_NO = si.PO_ITEM_NO
		CROSS JOIN TB_M_SYSTEM M
		INNER JOIN TB_M_DELIVERY_ADDR DA ON DA.DELIVERY_ADDR = M.SYSTEM_VALUE
		WHERE si.PO_NO = @poNo AND M.SYSTEM_CD = POI.PLANT_CD  AND FUNCTION_ID='DLVADR'
			AND DA.DELIVERY_ADDR = @address_code
	END
	ELSE
	BEGIN
		SELECT
			CAST(si.PO_SUBITEM_NO AS INT) SubItemNo,
			CASE WHEN ISNULL(si.MAT_NO, 'X') = 'X' THEN '' ELSE si.MAT_NO END SubItemMaterialNo,
			si.MAT_DESC SubItemDesc,
			si.PO_QTY_ORI SubItemQty,
			si.UOM SubItemUOM,
			si.PRICE_PER_UOM SubItemPrice,
			si.ORI_AMOUNT SubItemAmount,
			CAST(si.PO_ITEM_NO AS INT) ItemNo
			INTO #tmpSubItem2
		FROM TB_R_PO_SUBITEM si
		WHERE si.PO_NO = @poNo
	END

	IF EXISTS (SELECT 1 FROm TB_R_PO_ITEM WHERE DIVISION_ID = '19' AND PO_NO = @poNo)
	BEGIN
		SELECT tsi.ItemNo [No], * FROM #tmpItem1 ti
		LEFT JOIN #tmpSubItem1 tsi ON ti.ItemNo = tsi.ItemNo
		ORDER BY CAST(ti.ItemNo AS INT) ASC
	END
	ELSE
	BEGIN
		SELECT tsi.ItemNo [No], * FROM #tmpItem2 ti
		LEFT JOIN #tmpSubItem2 tsi ON ti.ItemNo = tsi.ItemNo
		ORDER BY CAST(ti.ItemNo AS INT) ASC
	END

    IF OBJECT_ID('tempdb..#tmpItem1') IS NOT NULL BEGIN DROP TABLE #tmpItem1 END
    IF OBJECT_ID('tempdb..#tmpSubItem1') IS NOT NULL BEGIN DROP TABLE #tmpSubItem1 END
	IF OBJECT_ID('tempdb..#tmpItem2') IS NOT NULL BEGIN DROP TABLE #tmpItem2 END
    IF OBJECT_ID('tempdb..#tmpSubItem2') IS NOT NULL BEGIN DROP TABLE #tmpSubItem2 END
    SET NOCOUNT OFF
END