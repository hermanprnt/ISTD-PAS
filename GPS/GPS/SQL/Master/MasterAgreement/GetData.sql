IF OBJECT_ID('tempdb..##TEMPTABLESTATUS') IS NOT NULL DROP TABLE ##TEMPTABLESTATUS

SELECT	
	VENDOR_CODE,
	START_DATE,
	EXP_DATE,
	CASE
		WHEN EXP_DATE >= DATEADD(mm, 3, GETDATE()) THEN '1'
		WHEN EXP_DATE BETWEEN GETDATE() AND DATEADD(mm, 3, GETDATE())THEN '3'
		WHEN EXP_DATE <= GETDATE() THEN '4'
	ELSE '2'
	END AS STATUS
INTO ##TEMPTABLESTATUS
FROM TB_M_AGREEMENT_NO
WHERE STATUS <> 2

UPDATE UPD
	SET UPD.STATUS = TMP.STATUS
FROM TB_M_AGREEMENT_NO UPD JOIN ##TEMPTABLESTATUS TMP
ON TMP.VENDOR_CODE = UPD.VENDOR_CODE




SELECT * FROM (
	SELECT DISTINCT
		   DENSE_RANK() OVER (ORDER BY mc.VENDOR_CODE ASC, mc.VENDOR_NAME) AS Number,
		   mc.VENDOR_CODE,
		   mc.VENDOR_NAME,
		   mc.PURCHASING_GROUP,
		   mc.BUYER,
		   mc.AGREEMENT_NO,
		   mc.AN_ATTACHMENT,
		   [dbo].[fn_date_format] (mc.START_DATE) AS START_DATE,
		   [dbo].[fn_date_format] (mc.EXP_DATE) AS EXP_DATE,
		   CASE
				WHEN mc.EXP_DATE >= DATEADD(mm, 3, GETDATE()) THEN 'GREEN'
				WHEN mc.EXP_DATE BETWEEN GETDATE() AND DATEADD(mm, 3, GETDATE())THEN 'YELLOW'
			ELSE 'RED'
			END AS BG_COLOR,
		   mc.[STATUS],
		   mc.NEXT_ACTION
	FROM TB_M_AGREEMENT_NO mc
		WHERE ((mc.[STATUS] = @Status
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