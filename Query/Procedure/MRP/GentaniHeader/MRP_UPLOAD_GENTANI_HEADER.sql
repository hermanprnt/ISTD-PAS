USE [NCP_QA]
GO
/****** Object:  StoredProcedure [dbo].[MRP_UPLOAD_GENTANI_HEADER]    Script Date: 10/6/2015 9:53:19 AM ******/
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

ALTER PROCEDURE [dbo].[MRP_UPLOAD_GENTANI_HEADER]
    @USER_ID VARCHAR(50),
	@PROCESS_ID numeric	   		
AS
SET NOCOUNT ON
DECLARE @LINE int,             
		@PROC_USAGE_CD VARCHAR(50),
		@GENTANI_HEADER_TYPE VARCHAR(50),
		@GENTANI_HEADER_CD VARCHAR(50),		
		@VALID_DT_FR varchar(50),
		@VALID_DT_TO varchar(50),
        
		@ERR_MSG_DUPLACATE_COUNT INT,
	    @L_ERR INT,
		@N_ERR INT,
		@maxid INT,	
		@Flag INT,
		@ERR_MSG AS VARCHAR(50),		
	    @MSG_TEXT VARCHAR(1000)					
				    
BEGIN TRY
  
   SET @L_ERR = 0
   
   EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Start Upload', 'GPS0004INF', 'Upload Gentani Header', @N_ERR
		
--CHECK VALIDASI						   
-----------------
	SELECT @maxid = COUNT(1) FROM TB_T_GENTANI_HEADER
	SET @Flag = 1
	
	WHILE (@Flag <= @maxid)
		BEGIN 
			SELECT @LINE = LINE,			       
			       @PROC_USAGE_CD = PROC_USAGE_CD,
			       @GENTANI_HEADER_TYPE = GENTANI_HEADER_TYPE,
			       @GENTANI_HEADER_CD = GENTANI_HEADER_CD,				    
				   @VALID_DT_FR = VALID_DT_FR,
				   @VALID_DT_TO= VALID_DT_TO			   
			FROM TB_T_GENTANI_HEADER 
			WHERE NO=@Flag	
			
			IF (@PROC_USAGE_CD = '' AND @GENTANI_HEADER_TYPE = '' AND @GENTANI_HEADER_CD = '' AND @VALID_DT_FR IS NULL AND @VALID_DT_TO IS NULL)				
				BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'Data is empty. Please delete row an excel file'		
					SET @MSG_TEXT = @MSG_TEXT + ' At row ' + CAST(@LINE AS VARCHAR)	
					EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Check Data Exists', 'GPS0004ERR', @MSG_TEXT, @N_ERR										
				END	
			
			IF NOT EXISTS(select 1 from TB_M_PROC_USAGE where PROC_USAGE_CD = @PROC_USAGE_CD) 
				 BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(A), '
					SET @MSG_TEXT = @MSG_TEXT + 'PROC_USAGE_CD not found in System Master'	
					EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Check Data Exists', 'GPS0004ERR', @MSG_TEXT, @N_ERR														
				 END
				 
		    IF NOT EXISTS(select 1 from TB_M_GENTANI_TYPE where GENTANI_HEADER_TYPE = @GENTANI_HEADER_TYPE) 
				 BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(B), '
					SET @MSG_TEXT = @MSG_TEXT + 'GENTANI_HEADER_TYPE not found in System Master'	
					EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Check Data Exists', 'GPS0004ERR', @MSG_TEXT, @N_ERR														
				 END		 			

			IF((SELECT ISDATE(@VALID_DT_FR)) = 0)
			 BEGIN
				SET @L_ERR = 1	
				SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(D), '
				SET @MSG_TEXT = @MSG_TEXT + 'Valid Date From, format should Date (yyyy-MM-dd)'	
				EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Check Data Type', 'GPS0004ERR', @MSG_TEXT, @N_ERR														
			 END

		   IF((SELECT ISDATE(@VALID_DT_TO)) = 0)
			 BEGIN
				SET @L_ERR = 1	
				SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(E), '
				SET @MSG_TEXT = @MSG_TEXT + 'Valid Date To, format should Date (yyyy-MM-dd)'	
				EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Check Data Type', 'GPS0004ERR', @MSG_TEXT, @N_ERR																		
			 END
		
		   IF(cast(@VALID_DT_TO as date) <= cast(@VALID_DT_FR as date))
			 BEGIN
				SET @L_ERR = 1	
				SET @MSG_TEXT = 'line ' + CAST(@LINE AS VARCHAR) + ' column(D) and column(E), Valid Date From must be earlier than Valid Date To'						
				EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Check Data Exists', 'GPS0004ERR', @MSG_TEXT, @N_ERR										
			 END
			 			
			IF LEN(@PROC_USAGE_CD) > 5
				BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'PROC_USAGE_CD not more 5 character'		
					SET @MSG_TEXT = @MSG_TEXT + ' At row' + CAST(@LINE AS VARCHAR)
					EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Check Data Length', 'GPS0004ERR', @MSG_TEXT, @N_ERR										
				END	
				
			IF LEN(@GENTANI_HEADER_TYPE) > 3
				BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'GENTANI_HEADER_TYPE not more 3 character'		
					SET @MSG_TEXT = @MSG_TEXT + ' At row' + CAST(@LINE AS VARCHAR)	
					EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Check Data Length', 'GPS0004ERR', @MSG_TEXT, @N_ERR									
				END	
				
			IF LEN(@GENTANI_HEADER_CD) > 23
				BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'GENTANI_HEADER_CD not more 23 character'		
					SET @MSG_TEXT = @MSG_TEXT + ' At row' + CAST(@LINE AS VARCHAR)	
					EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Check Data Length', 'GPS0004ERR', @MSG_TEXT, @N_ERR									
				END			
				
			--CHECK DUPLICATE DATA 
			SET @ERR_MSG_DUPLACATE_COUNT = (SELECT COUNT(1) FROM TB_T_GENTANI_HEADER 
										    WHERE PROC_USAGE_CD = @PROC_USAGE_CD AND
												  GENTANI_HEADER_TYPE = @GENTANI_HEADER_TYPE AND
												  GENTANI_HEADER_CD = @GENTANI_HEADER_CD AND							 
												  VALID_DT_FR = @VALID_DT_FR) 
			IF (@ERR_MSG_DUPLACATE_COUNT > 1)
				BEGIN
					SET @L_ERR = 1					
					SET @MSG_TEXT = 'Data is duplicate in uploaded file at row ' + CAST(@LINE AS VARCHAR) 
					EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Check Duplicate Data', 'GPS0004ERR', @MSG_TEXT, @N_ERR												
				END	
            SET @ERR_MSG_DUPLACATE_COUNT = (SELECT COUNT(1) FROM TB_M_GENTANI_HEADER 
										    WHERE PROC_USAGE_CD = @PROC_USAGE_CD AND
												  GENTANI_HEADER_TYPE = @GENTANI_HEADER_TYPE AND
												  GENTANI_HEADER_CD = @GENTANI_HEADER_CD AND							 
												  VALID_DT_FR = @VALID_DT_FR) 
			IF (@ERR_MSG_DUPLACATE_COUNT > 0)
				BEGIN
					SET @L_ERR = 1					
					SET @MSG_TEXT = 'Data is already registered in System Master at row ' + CAST(@LINE AS VARCHAR) 
					EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Check Duplicate Data', 'GPS0004ERR', @MSG_TEXT, @N_ERR							
				END															
			
		    SET @Flag = @Flag + 1
		END	
-----------------

IF (@L_ERR = 0)
	BEGIN
		INSERT INTO [dbo].[TB_M_GENTANI_HEADER]
							   ([PROC_USAGE_CD]
							   ,[GENTANI_HEADER_TYPE]
							   ,[GENTANI_HEADER_CD]							   
							   ,[VALID_DT_FR]
							   ,[VALID_DT_TO]
							   ,CREATED_BY
							   ,CREATED_DT
							   )
		SELECT  PROC_USAGE_CD,
				GENTANI_HEADER_TYPE,
				GENTANI_HEADER_CD,			    
				VALID_DT_FR,
				VALID_DT_TO,
				@USER_ID,
				GETDATE()
        FROM [dbo].[TB_T_GENTANI_HEADER]
		
		EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Finish Uploading', 'GPS0004SUC', 'Finish Uploading Gentani Header', @N_ERR
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

DELETE FROM TB_T_GENTANI_HEADER 
	
END TRY
BEGIN CATCH 
	IF EXISTS (SELECT * FROM TB_R_LOG_H WHERE PROCESS_ID = @PROCESS_ID)
	BEGIN
		SET @MSG_TEXT = 'LINE'+CONVERT(VARCHAR,ERROR_LINE())+ ERROR_MESSAGE();
		EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check System Error', 'GPS0004ERR', @MSG_TEXT, @N_ERR
		EXEC SP_WRITE_LOG_FINISH @PROCESS_ID, '3'

		DELETE FROM TB_T_GENTANI_HEADER 

		SET @ERR_MSG = 'False|'
		SELECT @ERR_MSG	AS Text	
	END
END CATCH		    



