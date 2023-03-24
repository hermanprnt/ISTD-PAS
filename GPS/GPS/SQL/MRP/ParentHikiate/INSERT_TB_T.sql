INSERT INTO [dbo].[TB_T_PARENT_GENTANI_HEADER_HIKIATE]
           ([NO]
           ,[LINE]
		   ,[PARENT_CD]
           ,[PROC_USAGE_CD]
           ,[GENTANI_HEADER_TYPE]
           ,[GENTANI_HEADER_CD]          
           ,[MULTIPLY_USAGE]          
           ,[VALID_DT_FR]
           ,[VALID_DT_TO]
           )
SELECT @row,
	   @LINE,
	   @PARENT_CD,
	   @PROC_USAGE_CD,
	   @GENTANI_HEADER_TYPE,
	   @GENTANI_HEADER_CD,	 
	   CAST(@USAGE_QTY AS VARCHAR(50)),	  
	   @VALID_DT_FR,
	   @VALID_DT_TO	



