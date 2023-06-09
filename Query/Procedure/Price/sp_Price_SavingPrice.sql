USE [PAS_DB_QA]
GO
/****** Object:  StoredProcedure [dbo].[sp_Price_SavingPrice]    Script Date: 12/13/2017 5:13:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_Price_SavingPrice]     
	@PROCESS_TYPE VARCHAR(10),
	@PRICE_ID int,  
	@MAT_NO VARCHAR (25),    
	@PRICE_AMOUNT DECIMAL (18,4),    
	@VALID_DT_FROM DATETIME,    
	@VALID_DT_TO DATETIME,    
	@QUOTATION_FILE_ORI VARCHAR (50),
	@ATTACHMENT_FILE_ORI VARCHAR (50),
	@USER_ID VARCHAR(20),   
	@EXTENTION_QUOT VARCHAR(5),
	@EXTENTION_ATTCH VARCHAR(5),
	@PRICE_STATUS VARCHAR(5),
	@SOURCE_DATA VARCHAR(1),
	@PC_NO VARCHAR(50),
	@CURR_CD VARCHAR(3)
AS    
BEGIN    
DECLARE    
	@MessageId varchar(20),    
	@str_validation_err_key varchar(20) = '##ERROR_VALIDATION##',    
	@message VARCHAR (MAX) = '',    
	@validationMessage VARCHAR (MAX),    
	@iStatus int=0,    
	@erroMessage VARCHAR(MAX),    
	@Value varchar(MAX),
	@QUOTATION_FILE VARCHAR (50),
	@ATTACHMENT_FILE VARCHAR (50),
	@DELETION_FLAG VARCHAR (1),
	@DEFAULT_PRICE_STATUS VARCHAR(2),
	@processDate DateTime = GETDATE(),
	@PriceIdInRange int
    
BEGIN TRY   
	SET NOCOUNT OFF    
	SET @QUOTATION_FILE = ''
	SET @ATTACHMENT_FILE = '' 
	SET @DELETION_FLAG = ISNULL(@DELETION_FLAG,'N')    
	SET @QUOTATION_FILE = 
	CASE WHEN @QUOTATION_FILE_ORI = '' THEN ''
		ELSE CONCAT('Quotation', '-', @MAT_NO, @EXTENTION_QUOT)
	END
	SET @ATTACHMENT_FILE = 
	CASE WHEN @ATTACHMENT_FILE_ORI = '' THEN ''
		ELSE CONCAT('Attachment', '-', @MAT_NO, @EXTENTION_ATTCH)    
	END

    
	IF(ISNULL(@MAT_NO,'')='')
	BEGIN    
		SET @MessageId = 'ERR00013'    
		Select @Value = dbo.fn_GetMessage(@MessageId)    
		SET @validationMessage = replace(@Value, '{0}', 'Material No') + ' ;'    
		SET @iStatus = 1    
    
	END    
    
	if(@iStatus<>0)    
		SET @message = @message + @validationMessage  
		
	IF(NOT EXISTS(SELECT 1 FROm TB_M_MATERIAL_NONPART WHERE MAT_NO = @MAT_NO))
	BEGIN      
		SET @validationMessage = 'Invalid data, input Material No is not exists in Master Material Non Part' + ' ;'    
		SET @iStatus = 1    
    
	END    
    
	if(@iStatus<>0)    
		SET @message = @message + @validationMessage    
    
	IF(@PRICE_AMOUNT = 0)    
	BEGIN    
		SET @MessageId = 'ERR00013'    
		Select @Value = dbo.fn_GetMessage(@MessageId)    
		SET @validationMessage = replace(@Value, '{0}', 'Price Amount') + ' ;'    
      
		SET @iStatus = 1    
	END    
    
	if(@iStatus<>0)    
		SET @message = @message + @validationMessage    
    
	SET @iStatus = 0    
	IF(ISNULL(@VALID_DT_FROM,'')='')    
	BEGIN    
		SET @MessageId = 'ERR00013'    
		Select @Value = dbo.fn_GetMessage(@MessageId)    
		SET @validationMessage = replace(@Value, '{0}', 'Valid Date From') + ' ;'    
		SET @iStatus = 1    
	END    
    
	if(@iStatus<>0)    
		SET @message = @message + @validationMessage   
   
    
	SET @iStatus = 0    
	IF(ISNULL(@VALID_DT_TO,'')='')    
	BEGIN    
		SET @MessageId = 'ERR00013'    
		Select @Value = dbo.fn_GetMessage(@MessageId)    
		SET @validationMessage = replace(@Value, '{0}', 'Valid Date To') + ' ;'    
		SET @iStatus = 1    
	END    
    
	if(@iStatus<>0)    
		SET @message = @message + @validationMessage 

	SET @iStatus = 0    
	IF(@VALID_DT_TO < @processDate)    
	BEGIN       
		SET @validationMessage ='Invalid data: input Valid Date To must greater then or same with The Current Date. ['+ Convert(VARCHAR(10), @processDate, 102)  +'] ;'  
		SET @iStatus = 1    
	END   
    
	if(@iStatus<>0)    
		SET @message = @message + @validationMessage    

	SET @iStatus = 0    
	IF(@VALID_DT_FROM > @VALID_DT_TO)    
	BEGIN       
		SET @validationMessage = 'Invalid data: input Valid Date From can not greater then Valid Date To. ;'    
		SET @iStatus = 1    
	END    
    
	if(@iStatus<>0)    
		SET @message = @message + @validationMessage    
    
	SET @iStatus = 0    
	IF(@QUOTATION_FILE_ORI IS NULL)    
	BEGIN    
		SET @MessageId = 'ERR00013'    
		Select @Value = dbo.fn_GetMessage(@MessageId)    
		SET @validationMessage = replace(@Value, '{0}', 'Quotation') + ' ;'    
		SET @iStatus = 1    
	END    
    
	if(@iStatus<>0)    
		SET @message = @message + @validationMessage    
    
	IF(ISNULL(@SOURCE_DATA, '') = '')    
	BEGIN    
		SET @MessageId = 'ERR00013'    
		Select @Value = dbo.fn_GetMessage(@MessageId)    
		SET @validationMessage = replace(@Value, '{0}', 'Source Data') + ' ;'    
      
		SET @iStatus = 1    
	END    
    
	if(@iStatus<>0)    
		SET @message = @message + @validationMessage  

	IF(ISNULL(@CURR_CD, '') = '')    
	BEGIN    
		SET @MessageId = 'ERR00013'    
		Select @Value = dbo.fn_GetMessage(@MessageId)    
		SET @validationMessage = replace(@Value, '{0}', 'Currency Code') + ' ;'    
      
		SET @iStatus = 1    
	END    
    
	if(@iStatus<>0)    
		SET @message = @message + @validationMessage 

	IF(ISNULL(@PC_NO, '') = '')    
	BEGIN    
		SET @MessageId = 'ERR00013'    
		Select @Value = dbo.fn_GetMessage(@MessageId)    
		SET @validationMessage = replace(@Value, '{0}', 'PC No.') + ' ;'    
      
		SET @iStatus = 1    
	END    
    
	if(@iStatus<>0)    
		SET @message = @message + @validationMessage 

	IF(LEN(ISNULL(@PC_NO, '')) > 21)    
	BEGIN    
		--SET @MessageId = 'ERR00013'    
		Select @Value = 'PC No Must cannot exceed 23 Character'
		SET @validationMessage = @Value + ' ;'    
      
		SET @iStatus = 1    
	END    
    
	if(@iStatus<>0)    
		SET @message = @message + @validationMessage 

	if (LEN(@message)>0)    
	BEGIN    
		RAISERROR(@str_validation_err_key, 16, 1)    
	END    

	

	IF(NOT EXISTS(SELECT 'x' FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'PRCSRC' AND (SYSTEM_VALUE = UPPER(ISNULL(@SOURCE_DATA, '')) OR SYSTEM_CD = UPPER(ISNULL(@SOURCE_DATA, '')))))    
	BEGIN    
		--SET @MessageId = 'ERR00013'    
		Select @Value = 'Source Data ' + ISNULL(@SOURCE_DATA, '') + ' Not Exist in System Master'
		SET @validationMessage = @Value + ' ;'    
      
		SET @iStatus = 1    
	END    
    
	if(@iStatus<>0)    
		SET @message = @message + @validationMessage 

	IF(NOT EXISTS(SELECT 'x' FROM (
							SELECT DISTINCT CURR_CD FROM TB_M_EXCHANGE_RATE WHERE YEAR(VALID_DT_TO) = 9999
						)TBL WHERE CURR_CD = ISNULL(@CURR_CD, '')))    
	BEGIN    
		--SET @MessageId = 'ERR00013'    
		Select @Value = 'Currency Code ' + ISNULL(@CURR_CD, '') + ' Not Exist in Exchange Rate Master'
		SET @validationMessage = @Value + ' ;'    
      
		SET @iStatus = 1    
	END    
    
	if(@iStatus<>0)    
		SET @message = @message + @validationMessage 
   
	if (LEN(@message)>0)    
	BEGIN    
		RAISERROR(@str_validation_err_key, 16, 1)    
	END    

	--select CASE WHEN VALID_DT_FROM < @VALID_DT_FROM
 --     and VALID_DT_TO > @VALID_DT_TO THEN 1 ELSE 0 END
	--  FROM  TB_M_MATERIAL_PRICE WHERE @MAT_NO = MAT_NO  AND PRICE_ID <> @PRICE_ID

	--select CASE WHEN @VALID_DT_FROM < VALID_DT_FROM
 --     and @VALID_DT_TO > VALID_DT_TO THEN 1 ELSE 0 END
	--  FROM  TB_M_MATERIAL_PRICE WHERE @MAT_NO = MAT_NO  AND PRICE_ID <> @PRICE_ID

	SELECT @DEFAULT_PRICE_STATUS = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'PRICE' AND SYSTEM_CD = 'PRICE_DEFAULT_STATUS'
	SET @PRICE_STATUS = ISNULL(NULLIF(@PRICE_STATUS,''), @DEFAULT_PRICE_STATUS)  

	--NEW DATA HAS INSIDE EXISTING
	IF EXISTS(select 1  FROM  TB_M_MATERIAL_PRICE WHERE @MAT_NO = MAT_NO AND VALID_DT_FROM < @VALID_DT_FROM and VALID_DT_TO > @VALID_DT_TO AND PRICE_ID <> @PRICE_ID)
	BEGIN
		IF EXISTS(select 1  FROM  TB_M_MATERIAL_PRICE WHERE @MAT_NO = MAT_NO AND @VALID_DT_FROM < VALID_DT_FROM  and @VALID_DT_TO <= VALID_DT_TO  AND PRICE_ID <> @PRICE_ID)
		BEGIN
			INSERT INTO TB_M_MATERIAL_PRICE(    
				MAT_NO,    
				PRICE_AMOUNT,    
				VALID_DT_FROM,
				VALID_DT_TO,
				PRICE_STATUS,
				QUOTATION_FILE_ORI,
				QUOTATION_FILE,
				ATTACHMENT_FILE_ORI,
				ATTACHMENT_FILE,
				DELETION_FLAG, 
				CREATED_BY, 
				CREATED_DT,
				PC_NO,
				SOURCE_DATA,
				CURR_CD)    
			SELECT TOP 1 
				MAT_NO,    
				PRICE_AMOUNT,    
				VALID_DT_FROM,
				@VALID_DT_TO,
				PRICE_STATUS,
				QUOTATION_FILE_ORI,
				QUOTATION_FILE,
				ATTACHMENT_FILE_ORI,
				ATTACHMENT_FILE,
				DELETION_FLAG, 
				CREATED_BY, 
				CREATED_DT,
				PC_NO,
				SOURCE_DATA,
				CURR_CD 
			FROM TB_M_MATERIAL_PRICE WHERE @MAT_NO = MAT_NO AND VALID_DT_FROM < @VALID_DT_FROM and VALID_DT_TO > @VALID_DT_TO AND PRICE_ID <> @PRICE_ID
		END
		ELSE IF EXISTS(select 1  FROM  TB_M_MATERIAL_PRICE WHERE @MAT_NO = MAT_NO AND @VALID_DT_FROM >= VALID_DT_FROM  and @VALID_DT_TO > VALID_DT_TO  AND PRICE_ID <> @PRICE_ID)
		BEGIN
			INSERT INTO TB_M_MATERIAL_PRICE(    
				MAT_NO,    
				PRICE_AMOUNT,    
				VALID_DT_FROM,
				VALID_DT_TO,
				PRICE_STATUS,
				QUOTATION_FILE_ORI,
				QUOTATION_FILE,
				ATTACHMENT_FILE_ORI,
				ATTACHMENT_FILE,
				DELETION_FLAG, 
				CREATED_BY, 
				CREATED_DT,
				PC_NO,
				SOURCE_DATA,
				CURR_CD)    
			SELECT TOP 1 
				MAT_NO,    
				PRICE_AMOUNT,    
				VALID_DT_FROM,
				VALID_DT_TO,
				PRICE_STATUS,
				QUOTATION_FILE_ORI,
				QUOTATION_FILE,
				ATTACHMENT_FILE_ORI,
				ATTACHMENT_FILE,
				DELETION_FLAG, 
				CREATED_BY, 
				CREATED_DT,
				PC_NO,
				SOURCE_DATA,
				CURR_CD 
			FROM TB_M_MATERIAL_PRICE WHERE @MAT_NO = MAT_NO AND VALID_DT_FROM < @VALID_DT_FROM and VALID_DT_TO > @VALID_DT_TO AND PRICE_ID <> @PRICE_ID
		END
		ELSE IF EXISTS(select 1  FROM  TB_M_MATERIAL_PRICE WHERE @MAT_NO = MAT_NO AND @VALID_DT_FROM > VALID_DT_FROM  and @VALID_DT_TO < VALID_DT_TO  AND PRICE_ID <> @PRICE_ID)
		BEGIN
			INSERT INTO TB_M_MATERIAL_PRICE(    
				MAT_NO,    
				PRICE_AMOUNT,    
				VALID_DT_FROM,
				VALID_DT_TO,
				PRICE_STATUS,
				QUOTATION_FILE_ORI,
				QUOTATION_FILE,
				ATTACHMENT_FILE_ORI,
				ATTACHMENT_FILE,
				DELETION_FLAG, 
				CREATED_BY, 
				CREATED_DT,
				PC_NO,
				SOURCE_DATA,
				CURR_CD)    
			SELECT TOP 1 
				MAT_NO,    
				PRICE_AMOUNT,    
				VALID_DT_FROM,
				@VALID_DT_TO,
				PRICE_STATUS,
				QUOTATION_FILE_ORI,
				QUOTATION_FILE,
				ATTACHMENT_FILE_ORI,
				ATTACHMENT_FILE,
				DELETION_FLAG, 
				CREATED_BY, 
				CREATED_DT,
				PC_NO,
				SOURCE_DATA,
				CURR_CD 
			FROM TB_M_MATERIAL_PRICE WHERE @MAT_NO = MAT_NO AND VALID_DT_FROM < @VALID_DT_FROM and VALID_DT_TO > @VALID_DT_TO AND PRICE_ID <> @PRICE_ID
		END
	END

	--EXISTING DATA HAS INSIDE NEW DATA
	IF EXISTS(select 1  FROM  TB_M_MATERIAL_PRICE WHERE @MAT_NO = MAT_NO AND @VALID_DT_FROM < VALID_DT_FROM and @VALID_DT_TO > VALID_DT_TO AND PRICE_ID <> @PRICE_ID)
	BEGIN
		DECLARE @DATE_INSIDE_RANGE_FROM DATETIME,  @DATE_INSIDE_RANGE_TO DATETIME
		select TOP 1 @DATE_INSIDE_RANGE_FROM = VALID_DT_FROM, @DATE_INSIDE_RANGE_TO = VALID_DT_TO  FROM  TB_M_MATERIAL_PRICE WHERE @MAT_NO = MAT_NO AND @VALID_DT_FROM < VALID_DT_FROM and @VALID_DT_TO > VALID_DT_TO AND PRICE_ID <> @PRICE_ID

		INSERT INTO TB_M_MATERIAL_PRICE(    
			MAT_NO,    
			PRICE_AMOUNT,    
			VALID_DT_FROM,
			VALID_DT_TO,
			PRICE_STATUS,
			QUOTATION_FILE_ORI,
			QUOTATION_FILE,
			ATTACHMENT_FILE_ORI,
			ATTACHMENT_FILE,
			DELETION_FLAG, 
			CREATED_BY, 
			CREATED_DT,
			PC_NO,
			SOURCE_DATA,
			CURR_CD)    
		VALUES (    
			@MAT_NO,    
			@PRICE_AMOUNT,    
			@VALID_DT_FROM,    
			DATEADD(DAY, -1,@DATE_INSIDE_RANGE_FROM),    
			@DEFAULT_PRICE_STATUS,    
			@QUOTATION_FILE_ORI,    
			@QUOTATION_FILE,    
			@ATTACHMENT_FILE_ORI,    
			@ATTACHMENT_FILE,    
			'N', 
			@USER_ID,    
			GETDATE(),
			@PC_NO,
			@SOURCE_DATA,
			@CURR_CD)  

		SET @VALID_DT_FROM = DATEADD(DAY, 1,@DATE_INSIDE_RANGE_TO)    
	END

	IF EXISTS(SELECT 1 FROM TB_M_MATERIAL_PRICE WHERE @MAT_NO = MAT_NO AND @VALID_DT_FROM = VALID_DT_FROM  AND @VALID_DT_TO = VALID_DT_TO  AND PRICE_ID <> @PRICE_ID)
	BEGIN
		SET @PROCESS_TYPE = 'EDIT'
		SELECT @PRICE_ID = PRICE_ID FROM TB_M_MATERIAL_PRICE WHERE @MAT_NO = MAT_NO AND @VALID_DT_FROM = VALID_DT_FROM  AND @VALID_DT_TO = VALID_DT_TO  AND PRICE_ID <> @PRICE_ID
	END
	ELSE
		BEGIN
		IF EXISTS(SELECT 1 FROM TB_M_MATERIAL_PRICE WHERE @MAT_NO = MAT_NO AND @VALID_DT_TO BETWEEN VALID_DT_FROM  AND VALID_DT_TO  AND PRICE_ID <> @PRICE_ID) 
		BEGIN
			SELECT @PriceIdInRange = PRICE_ID from TB_M_MATERIAL_PRICE WHERE 1 = 1 AND @VALID_DT_TO BETWEEN VALID_DT_FROM AND VALID_DT_TO AND MAT_NO = @MAT_NO  AND PRICE_ID <> @PRICE_ID

			IF (@PriceIdInRange IS NOT NULL)
			BEGIN
				IF EXISTS(SELECT 1 from TB_M_MATERIAL_PRICE WHERE 1 = 1 AND @VALID_DT_TO BETWEEN VALID_DT_FROM AND VALID_DT_TO AND MAT_NO = @MAT_NO  AND PRICE_ID <> @PRICE_ID AND @VALID_DT_TO = VALID_DT_TO)
				BEGIN
					UPDATE TB_M_MATERIAL_PRICE     
					SET 
					VALID_DT_TO = DATEADD(DAY, -1,@VALID_DT_FROM),
					CHANGED_BY = @USER_ID,    
					CHANGED_DT = GETDATE()    
				WHERE MAT_NO = @MAT_NO AND PRICE_ID = @PriceIdInRange
				END
				ELSE IF EXISTS(SELECT 1 from TB_M_MATERIAL_PRICE WHERE 1 = 1 AND @VALID_DT_FROM BETWEEN VALID_DT_FROM AND VALID_DT_TO AND MAT_NO = @MAT_NO  AND PRICE_ID <> @PRICE_ID AND @VALID_DT_FROM = VALID_DT_FROM)
				BEGIN
					UPDATE TB_M_MATERIAL_PRICE     
					SET 
					VALID_DT_FROM = DATEADD(DAY, 1,@VALID_DT_TO),
					CHANGED_BY = @USER_ID,    
					CHANGED_DT = GETDATE()    
				WHERE MAT_NO = @MAT_NO AND PRICE_ID = @PriceIdInRange
				END
				ELSE
				BEGIN
					UPDATE TB_M_MATERIAL_PRICE     
					SET 
					VALID_DT_FROM = DATEADD(DAY, 1,@VALID_DT_TO),
					CHANGED_BY = @USER_ID,    
					CHANGED_DT = GETDATE()    
				WHERE MAT_NO = @MAT_NO AND PRICE_ID = @PriceIdInRange
				END
				
			END
		END

		IF EXISTS(SELECT 1 FROM TB_M_MATERIAL_PRICE WHERE @MAT_NO = MAT_NO AND @VALID_DT_FROM BETWEEN VALID_DT_FROM  AND VALID_DT_TO  AND PRICE_ID <> @PRICE_ID) 
		BEGIN
			SELECT @PriceIdInRange = PRICE_ID from TB_M_MATERIAL_PRICE WHERE 1 = 1 AND @VALID_DT_FROM BETWEEN VALID_DT_FROM AND VALID_DT_TO AND MAT_NO = @MAT_NO  AND PRICE_ID <> @PRICE_ID

			IF (@PriceIdInRange IS NOT NULL)
			BEGIN
				IF EXISTS(SELECT 1 from TB_M_MATERIAL_PRICE WHERE 1 = 1 AND @VALID_DT_FROM BETWEEN VALID_DT_FROM AND VALID_DT_TO AND MAT_NO = @MAT_NO  AND PRICE_ID <> @PRICE_ID AND @VALID_DT_FROM = VALID_DT_FROM)
				BEGIN
					SET @VALID_DT_FROM = DATEADD(DAY, 1,@VALID_DT_FROM)
					IF(@VALID_DT_TO < @VALID_DT_FROM)
						SET @VALID_DT_TO = @VALID_DT_FROM
				END

				UPDATE TB_M_MATERIAL_PRICE     
					SET 
					VALID_DT_TO = DATEADD(DAY, -1,@VALID_DT_FROM),
					CHANGED_BY = @USER_ID,    
					CHANGED_DT = GETDATE()    
				WHERE MAT_NO = @MAT_NO AND PRICE_ID = @PriceIdInRange
			END
		END
	END
	 
	IF(ISNULL(@PROCESS_TYPE,'ADD')='ADD')    
	BEGIN  
		INSERT INTO TB_M_MATERIAL_PRICE(    
			MAT_NO,    
			PRICE_AMOUNT,    
			VALID_DT_FROM,
			VALID_DT_TO,
			PRICE_STATUS,
			QUOTATION_FILE_ORI,
			QUOTATION_FILE,
			ATTACHMENT_FILE_ORI,
			ATTACHMENT_FILE,
			DELETION_FLAG, 
			CREATED_BY, 
			CREATED_DT,
			PC_NO,
			SOURCE_DATA,
			CURR_CD)    
		VALUES (    
			@MAT_NO,    
			@PRICE_AMOUNT,    
			@VALID_DT_FROM,    
			@VALID_DT_TO,    
			@DEFAULT_PRICE_STATUS,    
			@QUOTATION_FILE_ORI,    
			@QUOTATION_FILE,    
			@ATTACHMENT_FILE_ORI,    
			@ATTACHMENT_FILE,    
			'N', 
			@USER_ID,    
			GETDATE(),
			@PC_NO,
			@SOURCE_DATA,
			@CURR_CD)     
	END ELSE    
	BEGIN    
		UPDATE TB_M_MATERIAL_PRICE     
		SET 
			PRICE_AMOUNT = @PRICE_AMOUNT,    
			VALID_DT_FROM = @VALID_DT_FROM,
			VALID_DT_TO = @VALID_DT_TO,
			QUOTATION_FILE_ORI = @QUOTATION_FILE_ORI,
			ATTACHMENT_FILE_ORI = @ATTACHMENT_FILE_ORI,
			QUOTATION_FILE = @QUOTATION_FILE,
			ATTACHMENT_FILE = @ATTACHMENT_FILE,
			CHANGED_BY = @USER_ID,    
			CHANGED_DT = GETDATE(),
			PC_NO = @PC_NO,
			SOURCE_DATA = @SOURCE_DATA,
			CURR_CD = @CURR_CD
		WHERE MAT_NO = @MAT_NO  AND PRICE_ID = @PRICE_ID  
	END  
    
	select 'S|'    
     
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
		SELECT 'V|' + @message    
	END    
	ELSE    
	BEGIN    
		SET @message = @ErrorMessage + ', at line = ' +  cast (@ErrorLine as varchar)    
		SELECT 'E|' + @message    
	END    
END CATCH    
SET NOCOUNT ON    
END 