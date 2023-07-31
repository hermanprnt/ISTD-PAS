SELECT
			mc.ID,
			mc.VENDOR_CODE,
		   mc.VENDOR_NAME,
		   mc.PURCHASING_GROUP,
		   mc.BUYER,
		   mc.AGREEMENT_NO,
		   [dbo].[fn_date_format] (mc.START_DATE) AS START_DATE,
		   [dbo].[fn_date_format] (mc.EXP_DATE) AS EXP_DATE,
		   mc.EMAIL_BUYER,
			mc.EMAIL_SH,
			mc.EMAIL_DPH,
			mc.EMAIL_LEGAL,
		   mc.[STATUS],
		   mc.NEXT_ACTION,
		   mc.AMOUNT
	FROM TB_M_AGREEMENT_NO mc
WHERE VENDOR_CODE = @VendorCode AND ID = @Identity
