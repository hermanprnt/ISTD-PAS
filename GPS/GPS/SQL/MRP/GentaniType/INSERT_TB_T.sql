INSERT INTO [dbo].[TB_T_GENTANI_TYPE]
           ([NO]
           ,[LINE]		  
           ,[PROC_USAGE_CD]
           ,[GENTANI_HEADER_TYPE]
           ,[DESCRIPTION]  
           )
SELECT @row,
	   @LINE,	  
	   @PROC_USAGE_CD,
	   @GENTANI_HEADER_TYPE,
	   @DESCRIPTION  
	  



