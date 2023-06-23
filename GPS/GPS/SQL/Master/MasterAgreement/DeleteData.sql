
 DELETE FROM TB_M_AGREEMENT_NO
 WHERE VENDOR_CODE = @VendorCode and AGREEMENT_NO = @Agreement_No

 select 'True|Delete successfully'


