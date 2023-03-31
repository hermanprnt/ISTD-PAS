
 DELETE FROM TB_M_AGREEMENT_NO
 WHERE VENDOR_CODE = @VendorCode

 select 'True|Delete successfully'