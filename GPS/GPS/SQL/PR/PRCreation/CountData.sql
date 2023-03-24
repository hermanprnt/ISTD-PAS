DECLARE @@VAL VARCHAR(4)
IF(@ValClass <> '')
BEGIN
	SELECT @@VAL = PROC_CHANNEL_CD FROM TB_M_VALUATION_CLASS WHERE VALUATION_CLASS = @ValClass
END

IF(@Param = '')
BEGIN
	SELECT COUNT(1)
	FROM TB_M_VENDOR
		WHERE (DELETION_FLAG <> 'Y') AND (DELETION_FLAG <> '1')
		AND ((VENDOR_CD LIKE '%' + ISNULL(@VendorCd, '') + '%'
				AND isnull(@VendorCd, '') <> ''
				OR (isnull(@VendorCd, '') = '')))
		AND ((VENDOR_NAME LIKE '%' + ISNULL(@VendorName, '') + '%'
			  AND isnull(@VendorName, '') <> ''
			  OR (isnull(@VendorName, '') = '')))
		AND ((PAYMENT_METHOD_CD = ISNULL(@PayMethod, '')
			  AND isnull(@PayMethod, '') <> ''
			  OR (isnull(@PayMethod, '') = '')))
		AND ((PAYMENT_TERM_CD = ISNULL(@PayTerm, '')
			  AND isnull(@PayTerm, '') <> ''
			  OR (isnull(@PayTerm, '') = '')))
		AND ((VENDOR_PLANT = ISNULL(@@VAL, '')
					AND isnull(@@VAL, '') <> ''
					OR (isnull(@@VAL, '') = ''))
					OR (isnull(VENDOR_PLANT, '') = '')
			)
END
ELSE
BEGIN
	SELECT COUNT(1)
	FROM TB_M_VENDOR
		WHERE (DELETION_FLAG <> 'Y') AND (DELETION_FLAG <> '1')
		AND ((VENDOR_PLANT = ISNULL(@@VAL, '')
					AND isnull(@@VAL, '') <> ''
					OR (isnull(@@VAL, '') = ''))
					OR (isnull(VENDOR_PLANT, '') = '')
			)
		AND(((VENDOR_CD LIKE '%' + ISNULL(@Param, '') + '%'
				AND isnull(@Param, '') <> ''
				OR (isnull(@Param, '') = '')))
		OR ((VENDOR_NAME LIKE '%' + ISNULL(@Param, '') + '%'
			  AND isnull(@Param, '') <> ''
			  OR (isnull(@Param, '') = ''))))
END