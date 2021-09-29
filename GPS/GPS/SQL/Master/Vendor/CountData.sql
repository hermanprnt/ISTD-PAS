IF(@Param = '')
BEGIN
	SELECT COUNT(1)
	FROM TB_M_VENDOR
		WHERE ((VENDOR_CD LIKE '%' + ISNULL(@VendorCd, '') + '%'
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
END
ELSE
BEGIN
	SELECT COUNT(1)
	FROM TB_M_VENDOR
		WHERE (((VENDOR_CD LIKE '%' + ISNULL(@Param, '') + '%'
				AND isnull(@Param, '') <> ''
				OR (isnull(@Param, '') = '')))
		OR ((VENDOR_NAME LIKE '%' + ISNULL(@Param, '') + '%'
			  AND isnull(@Param, '') <> ''
			  OR (isnull(@Param, '') = ''))))
END