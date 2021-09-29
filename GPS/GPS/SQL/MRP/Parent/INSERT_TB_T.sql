INSERT INTO [dbo].[TB_T_PARENT]
           ([NO]
           ,[LINE]		  
           ,[PARENT_CD]
           ,[PARENT_TYPE]           
           )
SELECT @row,
	   @LINE,	  
	   @ParentCode,
	   @ParentType
	  



