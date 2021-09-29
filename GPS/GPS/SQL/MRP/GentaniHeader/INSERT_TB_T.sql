INSERT INTO [dbo].[TB_T_GENTANI_HEADER]
           ([NO]
           ,[LINE]		  
           ,[PROC_USAGE_CD]
           ,[GENTANI_HEADER_TYPE]
           ,[GENTANI_HEADER_CD]           
           ,[VALID_DT_FR]
           ,[VALID_DT_TO]
           )
SELECT @row,
	   @LINE,	  
	   @PROC_USAGE_CD,
	   @GENTANI_HEADER_TYPE,
	   @GENTANI_HEADER_CD,	   
	   @VALID_DT_FR,
	   @VALID_DT_TO	



