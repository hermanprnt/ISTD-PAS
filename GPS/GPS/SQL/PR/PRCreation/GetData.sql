DECLARE @@VAL VARCHAR(4)
IF(@ValClass <> '')
BEGIN
	SELECT @@VAL = PROC_CHANNEL_CD FROM TB_M_VALUATION_CLASS WHERE VALUATION_CLASS = @ValClass
END

IF(@Param = '') --IF Query called from screen Vendor Master
BEGIN
	SELECT * FROM (
		SELECT  ROW_NUMBER() OVER (ORDER BY CREATED_DT DESC) AS Number,
				VENDOR_CD AS VendorCd,
				VENDOR_NAME AS VendorName,
				VENDOR_PLANT AS VendorPlant,
				SAP_VENDOR_ID AS SAPVendorID,
				PAYMENT_METHOD_CD AS PaymentMethodCd,
				PAYMENT_TERM_CD AS PaymentTermCd,
				DELETION_FLAG AS DeletionFlag,
				CREATED_BY AS CreatedBy,
				CONVERT(DATETIME,CREATED_DT) AS CreatedDt,
				CHANGED_BY AS ChangedBy,
				CONVERT(DATETIME,CHANGED_DT) AS ChangedDt
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
	) tbl WHERE tbl.Number >= @Start AND tbl.Number <= @Length
END
ELSE --if Query Called from other controller (ex: for retrieve dropdown data)
BEGIN
		SELECT * FROM (
		SELECT  ROW_NUMBER() OVER (ORDER BY CREATED_DT DESC) AS Number,
				VENDOR_CD AS VendorCd,
				VENDOR_NAME AS VendorName,
				VENDOR_PLANT AS VendorPlant,
				SAP_VENDOR_ID AS SAPVendorID,
				PAYMENT_METHOD_CD AS PaymentMethodCd,
				PAYMENT_TERM_CD AS PaymentTermCd,
				DELETION_FLAG AS DeletionFlag,
				CREATED_BY AS CreatedBy,
				CONVERT(DATETIME,CREATED_DT) AS CreatedDt,
				CHANGED_BY AS ChangedBy,
				CONVERT(DATETIME,CHANGED_DT) AS ChangedDt
		FROM TB_M_VENDOR
			WHERE (DELETION_FLAG <> 'Y') AND (DELETION_FLAG <> '1')
			AND ((VENDOR_PLANT = ISNULL(@@VAL, '')
					AND isnull(@@VAL, '') <> ''
					OR (isnull(@@VAL, '') = ''))
					OR (isnull(VENDOR_PLANT, '') = '')	
				)
			AND (((VENDOR_CD LIKE '%' + ISNULL(@Param, '') + '%'
					AND isnull(@Param, '') <> ''
					OR (isnull(@Param, '') = '')))
			OR ((VENDOR_NAME LIKE '%' + ISNULL(@Param, '') + '%'
					AND isnull(@Param, '') <> ''
					OR (isnull(@Param, '') = ''))))
	) tbl WHERE tbl.Number >= @Start AND tbl.Number <= @Length
END