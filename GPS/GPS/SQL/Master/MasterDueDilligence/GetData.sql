SELECT * FROM (
	SELECT DISTINCT
		DENSE_RANK() OVER (ORDER BY mc.VENDOR_CODE ASC, mc.VENDOR_NAME) AS Number,
		mc.VENDOR_CODE,
		MC.VENDOR_PLANT,
		mc.VENDOR_NAME,
		mc.DD_STATUS,
		CASE 
			WHEN DD_STATUS = 'HIGH' THEN 'RED'
			WHEN DD_STATUS = 'MEDIUM' THEN 'YELLOW'
			WHEN DD_STATUS = 'LOW' THEN 'GREEN'
		ELSE 'BLUE'
		END AS BG_COLOR,
		[dbo].[fn_date_format] (mc.VALID_AGREEMENT_NO_FROM) AS VALID_AGREEMENT_NO_FROM,
		[dbo].[fn_date_format] (mc.VALID_AGREEMENT_NO_TO) AS VALID_AGREEMENT_NO_TO,
		mc.AGREEMENT_NO,
		[dbo].[fn_date_format] (mc.VALID_DD_FROM) AS VALID_DD_FROM,
		[dbo].[fn_date_format] (mc.VALID_DD_TO) AS VALID_DD_TO,
		mc.DELETION,
		mc.CREATED_BY,
		mc.CREATED_DT,
		mc.CHANGED_BY,
		mc.CHANGED_DT
FROM TB_M_DUE_DILLIGENCE mc
		WHERE ((mc.[DD_STATUS] = @Status
		  AND isnull(@Status, '') <> ''
		  OR (isnull(@Status, '') = '')))
		AND ((mc.VENDOR_CODE LIKE '%' + @VendorCode + '%'
		  AND isnull(@VendorCode, '') <> ''
		  OR (isnull(@VendorCode, '') = '')))
		AND ((mc.VENDOR_NAME LIKE '%' + @VendorName + '%'
		  AND isnull(@VendorName, '') <> ''
		  OR (isnull(@VendorName, '') = '')))
		AND ((mc.AGREEMENT_NO LIKE '%' + @AgreementNo+ '%'
		  AND isnull(@AgreementNo, '') <> ''
		  OR (isnull(@AgreementNo, '') = '')))
) tbl WHERE tbl.Number >= @Start AND tbl.Number <= @Length