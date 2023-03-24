INSERT INTO [dbo].[TB_T_NON_COMPONENT_PART_LIST]
           ([NO]
           ,[LINE]
           ,[PROC_USAGE_CD]
           ,[GENTANI_HEADER_TYPE]
           ,[GENTANI_HEADER_CD]
           ,[MAT_NO]
           ,[USAGE_QTY]
		   ,[UOM]
           ,[PLANT_CD]
           ,[STORAGE_LOCATION]
           ,[VALID_DT_FR]
           ,[VALID_DT_TO]
           )
SELECT @row,
	   @LINE,
	   @PROC_USAGE_CD,
	   @GENTANI_HEADER_TYPE,
	   @GENTANI_HEADER_CD,
	   @MAT_NO,
	   @USAGE_QTY,
	   @UOM,
	   @PLANT_CD,
	   @STORAGE_LOCATION,
	   @VALID_DT_FR,
	   @VALID_DT_TO	



