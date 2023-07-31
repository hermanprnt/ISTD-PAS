
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
		DENSE_RANK() OVER (ORDER BY mc.VENDOR_CODE ASC, mc.VENDOR_NAME) AS Number,
		mc.VENDOR_CODE,
		MC.VENDOR_PLANT,
		mc.VENDOR_NAME,
		mc.DD_STATUS,
		CASE 
			WHEN DD_STATUS = '1' THEN 'RED'
			WHEN DD_STATUS = '2' THEN 'YELLOW'
			WHEN DD_STATUS = '3' THEN 'GREEN'
		ELSE 'BLUE'
		END AS BG_COLOR,
		mc.DD_ATTACHMENT,
		[dbo].[fn_date_format] (mc.VALID_DD_FROM) AS VALID_DD_FROM,
		[dbo].[fn_date_format] (mc.VALID_DD_TO) AS VALID_DD_TO,
		mc.DELETION,
		mc.EMAIL_BUYER,
		mc.EMAIL_SH,
		mc.EMAIL_DPH,
		mc.EMAIL_LEGAL,
		mc.CREATED_BY,
		[dbo].[fn_date_format] (mc.CREATED_DT) AS CREATED_DT,
		
		mc.CHANGED_BY,
		[dbo].[fn_date_format] (mc.CHANGED_DT) AS CHANGED_DT
		
FROM TB_M_DUE_DILLIGENCE mc	
		WHERE 1 = 1
		--AND DELETION = 'N'
		  AND ((mc.[DD_STATUS] = @Status
		  AND isnull(@Status, '') <> ''
		  OR (isnull(@Status, '') = '')))
		AND ((mc.VENDOR_CODE LIKE '%' + @VendorCode + '%'
		  AND isnull(@VendorCode, '') <> ''
		  OR (isnull(@VendorCode, '') = '')))
		AND ((mc.VENDOR_NAME LIKE '%' + @VendorName + '%'
		  AND isnull(@VendorName, '') <> ''
		  OR (isnull(@VendorName, '') = '')))
		  AND ((mc.VALID_DD_FROM >= @@From
		  AND isnull(@@From, '') <> ''
		  OR (isnull(@@From, '') = '')))
		  AND ((mc.VALID_DD_TO <= @@To
		  AND isnull(@@To, '') <> ''
		  OR (isnull(@@To, '') = '')))
) tbl WHERE tbl.Number >= @Start AND tbl.Number <= @Length