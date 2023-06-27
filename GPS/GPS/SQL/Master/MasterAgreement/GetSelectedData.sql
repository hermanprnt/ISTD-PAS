SELECT
			mc.VENDOR_CODE,
		   mc.VENDOR_NAME,
		   mc.PURCHASING_GROUP,
		   mc.BUYER,
		   mc.AGREEMENT_NO,
		   [dbo].[fn_date_format] (mc.START_DATE) AS START_DATE,
		   [dbo].[fn_date_format] (mc.EXP_DATE) AS EXP_DATE,
		   mc.[STATUS],
		   mc.NEXT_ACTION,
		   mc.AMOUNT
	FROM TB_M_AGREEMENT_NO mc
WHERE VENDOR_CODE = @VendorCode AND AGREEMENT_NO = @AgreementNo AND EXP_DATE = @ExpDate

