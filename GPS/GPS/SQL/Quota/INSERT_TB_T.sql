INSERT INTO [dbo].[TB_T_QUOTA]   
	   ([NO]
        ,[LINE]
        ,[DIVISION_ID]
        ,[DIVISION_NAME]
        ,[WBS_NO]
        ,[QUOTA_TYPE]
        ,[TYPE_DESCRIPTION]
        ,[ORDER_COORD]
        ,[ORDER_COORD_NAME]
        ,[QUOTA_AMOUNT]
        ,[QUOTA_AMOUNT_TOL])       
SELECT @row,
	   @LINE,	  
	   @DIVISION_ID,
	   @DIVISION_NAME,
	   @WBS_NO,
	   @QUOTA_TYPE,
	   @TYPE_DESCRIPTION,
	   @ORDER_COORD,
	   @ORDER_COORD_NAME,
	   @QUOTA_AMOUNT,
	   @QUOTA_AMOUNT_TOL

