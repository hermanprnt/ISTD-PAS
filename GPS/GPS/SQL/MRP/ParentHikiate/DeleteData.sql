﻿DELETE FROM TB_M_PARENT_GENTANI_HEADER_HIKIATE
WHERE PARENT_CD = @ParentCd AND
      PROC_USAGE_CD = @ProcUsage AND
	  GENTANI_HEADER_TYPE = @HeaderType AND
	  GENTANI_HEADER_CD = @HeaderCd AND	 
	  VALID_DT_FR = @ValidDt	