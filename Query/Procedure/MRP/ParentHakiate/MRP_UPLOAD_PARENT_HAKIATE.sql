USE [NCP_QA]
GO
/****** Object:  StoredProcedure [dbo].[MRP_UPLOAD_PARENT_HAKIATE]    Script Date: 10/6/2015 9:56:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************
**  Project      : GPS                                                                        
**  Copyright    : TMMIN
**  Script Name  : [[SP_UPLOAD]]
**  Author       : rendra
**  Created      : 30.09.2015
**  Purpose      : [[SP_UPLOAD]]
**  Called by    : 
**************************************************************************************************/

ALTER PROCEDURE [dbo].[MRP_UPLOAD_PARENT_HAKIATE]
    @USER_ID VARCHAR(50),
	@PROCESS_ID numeric	   		
AS
SET NOCOUNT ON
DECLARE @LINE int,
        @PARENT_CD VARCHAR(50),        
		@PROC_USAGE_CD VARCHAR(50),
		@GENTANI_HEADER_TYPE VARCHAR(50),
		@GENTANI_HEADER_CD VARCHAR(50),		
		@USAGE_QTY VARCHAR(50),		
		@VALID_DT_FR varchar(50),
		@VALID_DT_TO varchar(50),
        
		@ERR_MSG_DUPLACATE_COUNT INT,
	    @L_ERR INT,
		@N_ERR INT,
		@maxid INT,	
		@Flag INT,		
	    @MSG_TEXT VARCHAR(1000),	
		@ERR_MSG AS VARCHAR(50)	    	   			
				    
BEGIN TRY
  
   SET @L_ERR = 0
   
   EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Start Upload', 'GPS0004INF', 'Upload Parent Hakiate', @N_ERR
		
--CHECK VALIDASI						   
-----------------
	SELECT @maxid = COUNT(1) FROM TB_T_PARENT_GENTANI_HEADER_HIKIATE
	SET @Flag = 1
	
	WHILE (@Flag <= @maxid)
		BEGIN 
			SELECT @LINE = LINE,
			       @PARENT_CD = PARENT_CD,
			       @PROC_USAGE_CD = PROC_USAGE_CD,
			       @GENTANI_HEADER_TYPE = GENTANI_HEADER_TYPE,
			       @GENTANI_HEADER_CD = GENTANI_HEADER_CD,	
				   @USAGE_QTY = MULTIPLY_USAGE,	  
				   @VALID_DT_FR = VALID_DT_FR,
				   @VALID_DT_TO= VALID_DT_TO			   
			FROM TB_T_PARENT_GENTANI_HEADER_HIKIATE 
			WHERE NO=@Flag	
			
			IF (@PARENT_CD = '' AND @PROC_USAGE_CD = '' AND @GENTANI_HEADER_TYPE = '' AND @GENTANI_HEADER_CD = '' AND @USAGE_QTY = '' AND @VALID_DT_FR IS NULL AND @VALID_DT_TO IS NULL)				
				BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'Data is empty. Please delete row an excel file'		
					SET @MSG_TEXT = @MSG_TEXT + ' At row ' + CAST(@LINE AS VARCHAR)	
					EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Data Exists', 'GPS0004ERR', @MSG_TEXT, @N_ERR					
				END 

            IF NOT EXISTS(select 1 from TB_M_PARENT where PARENT_CD = @PARENT_CD) 
				 BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(A), '
					SET @MSG_TEXT = @MSG_TEXT + 'PARENT_CD not found in System Master'	
					EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Check Data Exists', 'GPS0004ERR', @MSG_TEXT, @N_ERR														
				 END
				
			IF NOT EXISTS(select 1 from TB_M_PROC_USAGE where PROC_USAGE_CD = @PROC_USAGE_CD) 
				 BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(B), '
					SET @MSG_TEXT = @MSG_TEXT + 'PROC_USAGE_CD not found in System Master'	
					EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Check Data Exists', 'GPS0004ERR', @MSG_TEXT, @N_ERR														
				 END
				 
		    IF NOT EXISTS(select 1 from TB_M_GENTANI_TYPE where GENTANI_HEADER_TYPE = @GENTANI_HEADER_TYPE) 
				 BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(C), '
					SET @MSG_TEXT = @MSG_TEXT + 'GENTANI_HEADER_TYPE not found in System Master'	
					EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Check Data Exists', 'GPS0004ERR', @MSG_TEXT, @N_ERR														
				 END

            IF NOT EXISTS(select 1 from TB_M_GENTANI_HEADER where GENTANI_HEADER_CD = @GENTANI_HEADER_CD) 
				 BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(D), '
					SET @MSG_TEXT = @MSG_TEXT + 'GENTANI_HEADER_CD not found in System Master'	
					EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Check Data Exists', 'GPS0004ERR', @MSG_TEXT, @N_ERR														
				 END	

			IF((SELECT ISNUMERIC(@USAGE_QTY)) = 0)
			 BEGIN
				SET @L_ERR = 1	
				SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(E), '
				SET @MSG_TEXT = @MSG_TEXT + 'MULTIPLY_USAGE, format should numeric'	
				EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Data Type', 'GPS0004ERR', @MSG_TEXT, @N_ERR				
			 END

			IF((SELECT ISDATE(@VALID_DT_FR)) = 0)
			 BEGIN
				SET @L_ERR = 1	
				SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(F), '
				SET @MSG_TEXT = @MSG_TEXT + 'Valid Date From, format should Date (yyyy-MM-dd)'	
				EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Data Type', 'GPS0004ERR', @MSG_TEXT, @N_ERR				
			 END

		   IF((SELECT ISDATE(@VALID_DT_TO)) = 0)
			 BEGIN
				SET @L_ERR = 1	
				SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(G), '
				SET @MSG_TEXT = @MSG_TEXT + 'Valid Date To, format should Date (yyyy-MM-dd)'	
				EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Data Type', 'GPS0004ERR', @MSG_TEXT, @N_ERR				
			 END
		
		   IF(cast(@VALID_DT_TO as date) <= cast(@VALID_DT_FR as date))
			 BEGIN
				SET @L_ERR = 1	
				SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(F) and column(G), Valid Date From must be earlier than Valid Date To'						
				EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Data Exists', 'GPS0004ERR', @MSG_TEXT, @N_ERR									
			 END			 
				
			IF LEN(@PARENT_CD) > 23
				BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'PARENT_CODE not more 23 character'		
					SET @MSG_TEXT = @MSG_TEXT + ' At row' + CAST(@LINE AS VARCHAR)
					EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Data Length', 'GPS0004ERR', @MSG_TEXT, @N_ERR										
				END	 	
			
			IF LEN(@PROC_USAGE_CD) > 5
				BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'PROC_USAGE_CD not more 5 character'		
					SET @MSG_TEXT = @MSG_TEXT + ' At row' + CAST(@LINE AS VARCHAR)
					EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Data Length', 'GPS0004ERR', @MSG_TEXT, @N_ERR										
				END	
				
			IF LEN(@GENTANI_HEADER_TYPE) > 3
				BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'GENTANI_HEADER_TYPE not more 3 character'		
					SET @MSG_TEXT = @MSG_TEXT + ' At row' + CAST(@LINE AS VARCHAR)
					EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Data Length', 'GPS0004ERR', @MSG_TEXT, @N_ERR									
				END	
				
			IF LEN(@GENTANI_HEADER_CD) > 23
				BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'GENTANI_HEADER_CD not more 23 character'		
					SET @MSG_TEXT = @MSG_TEXT + ' At row' + CAST(@LINE AS VARCHAR)
					EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Data Length', 'GPS0004ERR', @MSG_TEXT, @N_ERR									
				END			
				
			--CHECK DUPLICATE DATA 
			SET @ERR_MSG_DUPLACATE_COUNT = (SELECT COUNT(1) FROM TB_T_PARENT_GENTANI_HEADER_HIKIATE 
										    WHERE PARENT_CD = @PARENT_CD AND
												  PROC_USAGE_CD = @PROC_USAGE_CD AND
												  GENTANI_HEADER_TYPE = @GENTANI_HEADER_TYPE AND
												  GENTANI_HEADER_CD = @GENTANI_HEADER_CD AND							 
												  VALID_DT_FR = @VALID_DT_FR) 
			IF (@ERR_MSG_DUPLACATE_COUNT > 1)
				BEGIN
					SET @L_ERR = 1					
					SET @MSG_TEXT = 'Data is duplicate in uploaded file at row ' + CAST(@LINE AS VARCHAR) 
					EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Duplicate Data', 'GPS0004ERR', @MSG_TEXT, @N_ERR							
				END	
            SET @ERR_MSG_DUPLACATE_COUNT = (SELECT COUNT(1) FROM TB_M_PARENT_GENTANI_HEADER_HIKIATE 
										    WHERE PARENT_CD = @PARENT_CD AND
												  PROC_USAGE_CD = @PROC_USAGE_CD AND
												  GENTANI_HEADER_TYPE = @GENTANI_HEADER_TYPE AND
												  GENTANI_HEADER_CD = @GENTANI_HEADER_CD AND							 
												  VALID_DT_FR = @VALID_DT_FR) 
			IF (@ERR_MSG_DUPLACATE_COUNT > 0)
				BEGIN
					SET @L_ERR = 1					
					SET @MSG_TEXT = 'Data is already registered in System Master at row ' + CAST(@LINE AS VARCHAR) 
					EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Duplicate Data', 'GPS0004ERR', @MSG_TEXT, @N_ERR						
				END														
			
		    SET @Flag = @Flag + 1
		END	
-----------------

IF (@L_ERR = 0)
	BEGIN
		
		INSERT INTO [dbo].[TB_M_PARENT_GENTANI_HEADER_HIKIATE]
							   ([PARENT_CD]
							   ,[PROC_USAGE_CD]
							   ,[GENTANI_HEADER_TYPE]
							   ,[GENTANI_HEADER_CD]
							   ,[MULTIPLY_USAGE]
							   ,[VALID_DT_FR]
							   ,[VALID_DT_TO]
							   ,CREATED_BY
							   ,CREATED_DT
							   )
		SELECT  PARENT_CD,
				PROC_USAGE_CD,
				GENTANI_HEADER_TYPE,
				GENTANI_HEADER_CD,
			    CAST(MULTIPLY_USAGE AS INT),
				VALID_DT_FR,
				VALID_DT_TO,
				@USER_ID,
				GETDATE()
        FROM [dbo].[TB_T_PARENT_GENTANI_HEADER_HIKIATE]
		
		EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Finish Uploading', 'GPS0004SUC', 'Finish Uploading Parent Hakiate', @N_ERR
	    EXEC SP_WRITE_LOG_FINISH @PROCESS_ID, '2'
		
		SET @ERR_MSG = 'True|'
		SELECT @ERR_MSG	AS Text		
	END
ELSE
	BEGIN
		SET @MSG_TEXT = 'Upload is ended with error'
		EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Data Error', 'GPS0004ERR', @MSG_TEXT, @N_ERR
		EXEC SP_WRITE_LOG_FINISH @PROCESS_ID, '3'	
		
		SET @ERR_MSG = 'False|'
		SELECT @ERR_MSG	AS Text
	END

DELETE FROM TB_T_PARENT_GENTANI_HEADER_HIKIATE 
	
END TRY
BEGIN CATCH 
	IF EXISTS (SELECT * FROM TB_R_LOG_H WHERE PROCESS_ID = @PROCESS_ID)
	BEGIN
		SET @MSG_TEXT = 'LINE'+CONVERT(VARCHAR,ERROR_LINE())+ ERROR_MESSAGE();
		EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check System Error', 'GPS0004ERR', @MSG_TEXT, @N_ERR
		EXEC SP_WRITE_LOG_FINISH @PROCESS_ID, '3'

		DELETE FROM TB_T_PARENT_GENTANI_HEADER_HIKIATE 

		SET @ERR_MSG = 'False|'
		SELECT @ERR_MSG	AS Text	
	END
END CATCH		    



