﻿
 UPDATE dbo.TB_M_DUE_DILLIGENCE
    SET DELETION = 'Y',
        CHANGED_BY = @uid,
        CHANGED_DT = GETDATE()
    WHERE VENDOR_CODE = @vendorcd
 select 'True|Delete successfully'