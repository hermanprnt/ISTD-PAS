DECLARE 
@@From datetime
,@@To datetime


IF(@DateFrom <> '' AND @DateTo <> '')
BEGIN
	set @@From = (select CONVERT(DATETIME,@DateFrom , 104))
	set @@To = (select CONVERT(DATETIME,@DateTo , 104))	
END


SELECT COUNT(1) from
(SELECT DISTINCT *
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
		AND ((mc.EXP_DATE >= @@From
		  AND isnull(@@From, '') <> ''
		  OR (isnull(@@From, '') = '')))
		AND ((mc.EXP_DATE <= @@To
		  AND isnull(@@To, '') <> ''
		  OR (isnull(@@To, '') = '')))
)a