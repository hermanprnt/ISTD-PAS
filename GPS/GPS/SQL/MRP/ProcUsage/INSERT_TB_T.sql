INSERT INTO [dbo].[TB_T_PROC_USAGE]
           ([NO]
           ,[LINE]		  
           ,[PROC_USAGE_CD]
           ,[DESCRIPTION]           
           )
SELECT @row,
	   @LINE,	  
	   @PROC_USAGE_CD,
	   @DESCRIPTION
	  



