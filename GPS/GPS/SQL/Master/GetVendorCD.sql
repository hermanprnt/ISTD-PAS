SELECT DD_STATUS,VENDOR_CD VendorCd, O.VENDOR_NAME VendorName 
FROM TB_M_VENDOR O
LEFT JOIN TB_M_DUE_DILLIGENCE DDM ON DDM.VENDOR_CODE =  O.VENDOR_CD
ORDER BY O.VENDOR_NAME


