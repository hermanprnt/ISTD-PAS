﻿Select  A.PROC_USAGE_CD,
		A.GENTANI_HEADER_TYPE,
		A.GENTANI_HEADER_CD,
		A.MAT_NO,
		A.USAGE_QTY,
		B.BASE_UOM,
		A.PLANT_CD,
		A.STORAGE_LOCATION,
		--b.SLOC_NAME,
		REPLACE(CONVERT(varchar(10),A.VALID_DT_FR,102),'.','-') VALID_DT_FR,	
	    REPLACE(CONVERT(varchar(10),A.VALID_DT_TO,102),'.','-') VALID_DT_TO
FROM TB_M_NON_COMPONENT_PART_LIST A LEFT JOIN TB_M_MATERIAL_NONPART B ON A.MAT_NO=B.MAT_NO
--inner join TB_M_SLOC b on a.STORAGE_LOCATION = b.SLOC_CD AND A.PLANT_CD = B.PLANT_CD
WHERE A.PROC_USAGE_CD = @ProcUsage AND
	  A.GENTANI_HEADER_TYPE = @HeaderType AND
	  A.GENTANI_HEADER_CD = @HeaderCd AND
	  A.MODEL = @Model AND
	  A.MAT_NO = @MatNo AND
	  A.VALID_DT_FR = @ValidDt	