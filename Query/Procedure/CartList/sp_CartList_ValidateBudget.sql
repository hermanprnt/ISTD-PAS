/****** Object:  StoredProcedure [dbo].[sp_CartList_ValidateBudget]    Script Date: 9/27/2017 11:36:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_CartList_ValidateBudget]  
  @CART_ID VARCHAR(17),
  @MAT_NO VARCHAR(23),
  @CARRENCY_CD VARCHAR(10),
  @DIVISION_ID VARCHAR(10),
  @CONSUME_MONTH VARCHAR(10),
  @CATEGORY_TYPE VARCHAR(10),
  @WBS_NO VARCHAR(30),
  @AMOUNT MONEY,
  @QUOTA_FLAG VARCHAR(1),
  @USER_ID VARCHAR(20),
  @STATUS VARCHAR(20) OUTPUT,
  @message VARCHAR (1000) OUTPUT
AS  
BEGIN  

DECLARE  
 @MessageId varchar(20),  
 @str_validation_err_key varchar(20) = '##ERROR_VALIDATION##',  
 @validationMessage VARCHAR (MAX),  
 @iStatus int=0,  
 @erroMessage VARCHAR(MAX),  
 @Value varchar(MAX)  
  
BEGIN TRY  
 SET NOCOUNT OFF   

 DECLARE 
	@REMAIN_QUOTA		MONEY, 
	@ACTUAL_EXC_RATE	numeric(10, 2)
 
IF(ISNULL(@CART_ID,'')='')    
 BEGIN    
  SET @MessageId = 'ERR00013'    
  Select @Value = dbo.fn_GetMessage(@MessageId)    
  SET @validationMessage = replace(@Value, '{0}', 'Cart Id') + ' ;'    
  SET @iStatus = 1    
    
 END     
  
 if(@iStatus<>0)  
  SET @message = @message + @validationMessage    

IF(ISNULL(@MAT_NO,'')='')    
 BEGIN    
  SET @MessageId = 'ERR00013'    
  Select @Value = dbo.fn_GetMessage(@MessageId)    
  SET @validationMessage = replace(@Value, '{0}', 'Material No') + ' ;'    
  SET @iStatus = 1    
    
 END     
  
 if(@iStatus<>0)  
  SET @message = @message + @validationMessage  
  
IF(ISNULL(@WBS_NO,'')='')    
 BEGIN    
  SET @MessageId = 'ERR00013'    
  Select @Value = dbo.fn_GetMessage(@MessageId)    
  SET @validationMessage = replace(@Value, '{0}', 'WBS No') + ' ;'    
  SET @iStatus = 1    
    
 END     
  
 if(@iStatus<>0)  
  SET @message = @message + @validationMessage  

IF(ISNULL(@QUOTA_FLAG,'')='')    
 BEGIN    
  SET @MessageId = 'ERR00013'    
  Select @Value = dbo.fn_GetMessage(@MessageId)    
  SET @validationMessage = replace(@Value, '{0}', 'Quota Flag') + ' ;'    
  SET @iStatus = 1    
    
 END     
  
 if(@iStatus<>0)  
  SET @message = @message + @validationMessage 
  
 if (LEN(@message)>0)  
 BEGIN  
  RAISERROR(@str_validation_err_key, 16, 1)  
 END  

 BEGIN  
	
    --Is Product type quota?
	if(@QUOTA_FLAG = 'Y')
	BEGIN
		SELECT TOP 1 @REMAIN_QUOTA = (ISNULL(QUOTA_AMOUNT, 0) + ISNULL(ADDITIONAL_AMOUNT, 0)) - ISNULL(USAGE_AMOUNT, 0) FROM TB_R_QUOTA
				   WHERE CONSUME_MONTH = @CONSUME_MONTH AND WBS_NO = @WBS_NO AND DIVISION_ID = @DIVISION_ID AND QUOTA_TYPE = @CATEGORY_TYPE

		IF(@REMAIN_QUOTA < @AMOUNT)
			SET @message =  'Not Enough Quota Amount for WBS No ' + @WBS_NO + ' and Valuation Class ' + @CATEGORY_TYPE + ' , Remaining Quota Amount After Calculation is ' + CONVERT(VARCHAR, @REMAIN_QUOTA)

		 if (LEN(@message)>0)  
		 BEGIN  
			RAISERROR(@str_validation_err_key, 16, 1)  
		 END  
	END

	BEGIN
		EXEC @iStatus = dbo.[sp_BudgetCheck_Linked]
									@message OUTPUT,
									@USER_ID,
									@WBS_NO,
									null,
									@CART_ID,
									@CARRENCY_CD,
									@AMOUNT,
									@ACTUAL_EXC_RATE OUTPUT
		IF @iStatus <> 0 
		BEGIN
			RAISERROR(@str_validation_err_key, 16, 1)  
		END
	END
      
 END  

SET @STATUS = 'SUCCESS'  
   
END TRY  
BEGIN CATCH   
 declare @ErrorMessage Nvarchar(4000)  
  declare @ErrorSeverity INT  
  declare @ErrorState INT  
  declare @ErrorLine INT  
   
  SELECT @ErrorMessage = ERROR_MESSAGE(),  
    @ErrorSeverity = ERROR_SEVERITY(),  
    @ErrorState = ERROR_STATE(),  
    @ErrorLine = ERROR_LINE()  
  
 if @ErrorMessage = @str_validation_err_key  
 BEGIN  
  SET @STATUS = 'VALIDATE_FAILED'  
 END  
 ELSE  
 BEGIN  
  SET @message = @ErrorMessage + ', at line = ' +  cast (@ErrorLine as varchar)  
  SET @STATUS = 'FAILED'  
 END  
END CATCH  
SET NOCOUNT ON  
END  