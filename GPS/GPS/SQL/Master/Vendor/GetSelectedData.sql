﻿SELECT VENDOR_CD AS VendorCd,
	   SAP_VENDOR_ID AS SAPVendorID,
	   VND.VENDOR_NAME AS VendorName,
	   VND.VENDOR_PLANT AS VendorPlant,
	   PURCHASING_GRP_CD AS PurchGroup,
	   PAYMENT_METHOD_CD AS PaymentMethodCd,
	   PAYMENT_TERM_CD AS PaymentTermCd,
	   VENDOR_ADDRESS AS [Address],
	   CITY AS City,
	   PHONE AS Phone,
	   FAX AS Fax,
	   ATTENTION AS Attention,
	   POSTAL_CODE AS Postal,
	   COUNTRY AS Country,
	   EMAIL_ADDR AS Mail,
	   --DD.ATTACHMENT,
	   'WWW.GOOGLE.COM' AS ATTACHMENT,
	   DD.DD_STATUS,
	   DD.VALID_DD_FROM,
	   DD.VALID_DD_TO
FROM TB_M_VENDOR VND LEFT JOIN TB_M_DUE_DILLIGENCE DD
ON VND.VENDOR_CD = DD.VENDOR_CODE 
WHERE VENDOR_CD = @VendorCd