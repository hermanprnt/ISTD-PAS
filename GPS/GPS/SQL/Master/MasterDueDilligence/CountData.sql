
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
) a

