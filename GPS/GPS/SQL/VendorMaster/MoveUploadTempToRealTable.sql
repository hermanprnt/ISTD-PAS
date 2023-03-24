INSERT INTO TB_M_VENDOR
	   ([VENDOR_CD]
        ,[VENDOR_NAME]
        ,[VENDOR_PLANT]
        ,[SAP_VENDOR_ID]
        ,[PURCHASING_GRP_CD]
        ,[PAYMENT_METHOD_CD]
        ,[PAYMENT_TERM_CD]
        ,[DELETION_FLAG]
        ,[CREATED_BY]
        ,[CREATED_DT]
        ,[CHANGED_BY]
        ,[CHANGED_DT])
SELECT * FROM #tmpVendor
;

IF OBJECT_ID('tempdb..#tmpVendor') IS NOT NULL
BEGIN
	DROP TABLE #tmpVendor
END