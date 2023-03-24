DECLARE @@sqlquery VARCHAR(MAX)

SET @@sqlquery = 'UPDATE TB_M_VENDOR 
					SET DELETION_FLAG = ''1'' 
					WHERE VENDOR_CD IN (' + @VendorCd + ')'

exec(@@sqlquery)