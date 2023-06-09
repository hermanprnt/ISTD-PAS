SELECT * FROM (
SELECT DISTINCT
	DENSE_RANK() OVER (ORDER BY A.PR_ITEM_NO ASC) AS number, 
	A.IS_PARENT,
	CAST(CAST(A.PR_ITEM_NO AS INT) AS VARCHAR) AS ITEM_NO,
	A.PR_NO AS PR_NO,
	A.PO_NO AS PO_NO,
	A.ITEM_CLASS,
	A.VALUATION_CLASS,
	A.WBS_NO,
	A.COST_CENTER_CD AS COST_CENTER,
	A.GL_ACCOUNT AS GL_ACCOUNT_CD,
	A.MAT_NO AS MAT_NUMBER,
	A.MAT_DESC,
	ISNULL(A.PR_QTY,0) AS QTY,
	ISNULL(A.OPEN_QTY, 0) AS OPEN_QTY,
	ISNULL(A.USED_QTY, 0) AS USED_QTY,
	ISNULL(A.CANCEL_QTY, 0) AS CANCEL_QTY,
	A.UNIT_OF_MEASURE_CD AS UOM,
	A.ORI_CURR_CD AS CURR,
	A.EXCHANGE_RATE AS EXCHANGE_RATE,
	ISNULL(A.PRICE_PER_UOM,0) AS PRICE,
	A.ORI_AMOUNT AS AMOUNT,
	A.LOCAL_AMOUNT AS LOCAL_AMOUNT,
	[dbo].[fn_date_format](A.DELIVERY_PLAN_DT) as DELIVERY_DATE_ITEM,
	A.ASSET_CATEGORY AS ASSET_CATEGORY_CD,
	C.SYSTEM_VALUE AS ASSET_CATEGORY_DESC,
	A.ASSET_CLASS AS ASSET_CLASS_DESC,
	A.ASSET_LOCATION,
	A.ASSET_NO,
	B.STATUS_DESC,
	A.VENDOR_CD + ' - ' + A.VENDOR_NAME AS VENDOR_NAME,
	D.APPROVER_NAME AS CURRENT_PIC,
	E.PURCHASING_GROUP_CD
FROM TB_R_PR_ITEM A 
	JOIN TB_R_PR_H F ON A.PR_NO = F.PR_NO
	JOIN TB_M_STATUS B ON B.STATUS_CD = CASE WHEN A.RELEASE_FLAG = 'N' THEN A.PR_STATUS ELSE '14' END -- IF RELEASE_FLAG = Y CHANGE STATUS TO PR_RELEASE
	JOIN TB_M_SYSTEM C ON C.FUNCTION_ID = '20021' AND ASSET_CATEGORY = SUBSTRING(C.SYSTEM_CD, 4, 5)
	JOIN TB_M_VALUATION_CLASS E ON A.VALUATION_CLASS = E.VALUATION_CLASS AND F.PR_TYPE = E.PROCUREMENT_TYPE AND F.PR_COORDINATOR = E.PR_COORDINATOR
	LEFT JOIN TB_R_WORKFLOW D ON A.PR_NO = D.DOCUMENT_NO AND A.PR_ITEM_NO = D.ITEM_NO
		 AND A.PR_NEXT_STATUS = D.APPROVAL_CD AND A.RELEASE_FLAG = 'N'
WHERE A.PR_NO = @PR_NO) TBL1
WHERE number >= @start AND number <= @length