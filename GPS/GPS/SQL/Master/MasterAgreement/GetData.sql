
DECLARE 
@@From datetime
,@@To datetime


IF(@DateFrom <> '' AND @DateTo <> '')
BEGIN
	set @@From = (select CONVERT(DATETIME,@DateFrom , 104))
	set @@To = (select CONVERT(DATETIME,@DateTo , 104))	
END


SELECT * FROM (
	SELECT DISTINCT
		   DENSE_RANK() OVER (ORDER BY mc.VENDOR_CODE ASC, mc.VENDOR_NAME,mc.START_DATE,MC.EXP_DATE,MC.CREATED_DT) AS Number,
		   mc.VENDOR_CODE,
		   mc.VENDOR_NAME,
		   mc.PURCHASING_GROUP,
		   mc.BUYER,
		   mc.AGREEMENT_NO,
		   mc.AN_ATTACHMENT,
		   [dbo].[fn_date_format] (mc.START_DATE) AS START_DATE,
		   [dbo].[fn_date_format] (mc.EXP_DATE) AS EXP_DATE,
			(SELECT SYSTEM_VALUE FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'MSAGR' AND SYSTEM_CD = MC.[STATUS]) AS STATUS_STRING,
			mc.[STATUS],
		   mc.NEXT_ACTION,
		   mc.AMOUNT
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
) tbl WHERE tbl.Number >= @Start AND tbl.Number <= @Length