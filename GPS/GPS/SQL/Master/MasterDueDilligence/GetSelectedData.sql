﻿SELECT 
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
		mc.CREATED_BY,
		mc.CREATED_DT,
		mc.CHANGED_BY,
		mc.CHANGED_DT
FROM TB_M_DUE_DILLIGENCE mc
		WHERE VENDOR_CODE = @VendorCode
