﻿DECLARE @@SQL VARCHAR(MAX) = ''
 
SET @@SQL = @@SQL + 'SELECT ISNULL(COUNT(1), 0) FROM ('

IF (@Kelas = 'P')
BEGIN
	SET @@SQL = @@SQL +
	    'SELECT DISTINCT MAT_NO,
		  	    MAT_DESC,
			    ORDER_UOM,
			    MRP_TYPE,
		        VALUATION_CLASS,
			    PROC_USAGE_GROUP,
			    ASSET_FLAG,
			    QUOTA_FLAG
				FROM TB_M_MATERIAL_PART AS A
				WHERE 1=1 AND DELETION_FLAG = ''N'' 
		'
END
ELSE IF (@Kelas = 'N')
BEGIN
	SET @@SQL = @@SQL +
	   'SELECT DISTINCT MAT_NO,
			   MAT_DESC,
			   ORDER_UOM,
			   MRP_TYPE,
		       VALUATION_CLASS,
			   PROC_USAGE_GROUP,
			   ASSET_FLAG,
			   QUOTA_FLAG
			   FROM TB_M_MATERIAL_NONPART AS A
			   WHERE 1=1 AND DELETION_FLAG = ''N'' 
		'
END
ELSE
BEGIN
	SET @@SQL = @@SQL +
	'SELECT DISTINCT MAT_NO,
			MAT_DESC,
			ORDER_UOM,
			MRP_TYPE,
			VALUATION_CLASS,
			PROC_USAGE_GROUP,
			ASSET_FLAG,
			QUOTA_FLAG
			FROM TB_M_MATERIAL_PART
			WHERE 1=1 AND DELETION_FLAG = ''N'' 
	UNION
	SELECT DISTINCT MAT_NO,
		   MAT_DESC,
		   ORDER_UOM,
		   MRP_TYPE,
		   VALUATION_CLASS,
		   PROC_USAGE_GROUP,
		   ASSET_FLAG,
		   QUOTA_FLAG
		   FROM TB_M_MATERIAL_NONPART
		   WHERE 1=1 AND DELETION_FLAG = ''N'' 
   '
END

SET @@SQL = @@SQL + ') A WHERE 1=1 '

IF (ISNULL(@MAT_NO, '') <> '')
	SET @@SQL = @@SQL + ' AND MAT_NO LIKE ''%' + @MAT_NO + '%'''

IF (ISNULL(@MAT_DESC, '') <> '')
	SET @@SQL = @@SQL + ' AND MAT_DESC LIKE ''%' + @MAT_DESC + '%'''

IF (ISNULL(@UOM, '') <> '')
	SET @@SQL = @@SQL + ' AND ORDER_UOM LIKE ''%' + @UOM + '%'''

IF (ISNULL(@MRP_TYPE, '') <> '')
	SET @@SQL = @@SQL + ' AND MRP_TYPE LIKE ''%' + @MRP_TYPE + '%'''

IF (ISNULL(@VALUATION_CLASS, '') <> '')
	SET @@SQL = @@SQL + ' AND VALUATION_CLASS LIKE ''%' + @VALUATION_CLASS + '%'''

IF (ISNULL(@PROC_USAGE_CD, '') <> '')
	SET @@SQL = @@SQL + ' AND PROC_USAGE_GROUP LIKE ''%' + @PROC_USAGE_CD + '%'''

IF (ISNULL(@ASSET_FLAG, '') <> '')
	SET @@SQL = @@SQL + ' AND ASSET_FLAG LIKE ''%' + @ASSET_FLAG + '%'''

IF (ISNULL(@QUOTA_FLAG, '') <> '')
	SET @@SQL = @@SQL + ' AND QUOTA_FLAG LIKE ''%' + @QUOTA_FLAG + '%'''

EXEC (@@SQL)