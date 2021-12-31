UPDATE TB_M_SOURCE_LIST
	SET 
		MAT_NO = @MAT_NO,
		VENDOR_CD = @VENDOR_CD,
		VALID_DT_FROM = @VALID_DT_FROM,
		CHANGED_BY = @username,
		CHANGED_DT = GETDATE()
WHERE MAT_NO = @MAT_NO AND VENDOR_CD = @VENDOR_CD

select 'Save Successfully'