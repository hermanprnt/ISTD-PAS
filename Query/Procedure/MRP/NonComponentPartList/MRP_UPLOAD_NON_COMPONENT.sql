USE [NCP_QA]
GO
/****** Object:  StoredProcedure [dbo].[MRP_UPLOAD_NON_COMPONENT]    Script Date: 10/6/2015 9:55:02 AM ******/
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

ALTER PROCEDURE [dbo].[MRP_UPLOAD_NON_COMPONENT]
    @USER_ID VARCHAR(50),
	@PROCESS_ID numeric	   		
AS
SET NOCOUNT ON
DECLARE @LINE int,        
		@PROC_USAGE_CD VARCHAR(50),
		@GENTANI_HEADER_TYPE VARCHAR(50),
		@GENTANI_HEADER_CD VARCHAR(50),
		@MAT_NO VARCHAR(50),
		@USAGE_QTY VARCHAR(50),
		@UOM VARCHAR(50),
		@PLANT_CD VARchar(50),
		@STORAGE_LOCATION varchar(50),
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
   
   EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Start Upload', 'GPS0004INF', 'Upload Non Component PartList', @N_ERR
		
--CHECK VALIDASI						   
-----------------
	SELECT @maxid = COUNT(1) FROM TB_T_NON_COMPONENT_PART_LIST
	SET @Flag = 1
	
	WHILE (@Flag <= @maxid)
		BEGIN 
			SELECT @LINE = LINE,
			       @PROC_USAGE_CD = PROC_USAGE_CD,
			       @GENTANI_HEADER_TYPE = GENTANI_HEADER_TYPE,
			       @GENTANI_HEADER_CD = GENTANI_HEADER_CD,				   
				   @MAT_NO = MAT_NO,
				   @USAGE_QTY = USAGE_QTY,
				   @UOM = UOM,
				   @PLANT_CD = PLANT_CD,
				   @STORAGE_LOCATION = STORAGE_LOCATION,
				   @VALID_DT_FR = VALID_DT_FR,
				   @VALID_DT_TO= VALID_DT_TO			   
			FROM TB_T_NON_COMPONENT_PART_LIST 
			WHERE NO=@Flag	

			IF (@PROC_USAGE_CD = '' AND @GENTANI_HEADER_TYPE = '' AND @GENTANI_HEADER_CD = '' AND @MAT_NO = '' AND @USAGE_QTY = '' AND 
			    @UOM = '' AND @PLANT_CD = '' AND @STORAGE_LOCATION = '' AND @VALID_DT_FR IS NULL AND @VALID_DT_TO IS NULL)				
				BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'Data is empty. Please delete row an excel file'		
					SET @MSG_TEXT = @MSG_TEXT + ' At row ' + CAST(@LINE AS VARCHAR)	
					EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Data Exists', 'GPS0004ERR', @MSG_TEXT, @N_ERR					
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

            IF NOT EXISTS(select 1 from TB_M_GENTANI_HEADER where GENTANI_HEADER_CD = @GENTANI_HEADER_CD) 
				 BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(C), '
					SET @MSG_TEXT = @MSG_TEXT + 'GENTANI_HEADER_CD not found in System Master'	
					EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Check Data Exists', 'GPS0004ERR', @MSG_TEXT, @N_ERR														
				 END

             IF NOT EXISTS(select 1 from TB_M_MATERIAL where MAT_NO = @MAT_NO) 
				 BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(D), '
					SET @MSG_TEXT = @MSG_TEXT + 'MAT_NO not found in System Master'	
					EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Check Data Exists', 'GPS0004ERR', @MSG_TEXT, @N_ERR														
				 END

             IF NOT EXISTS(select 1 from TB_M_SLOC where SLOC_CD = @STORAGE_LOCATION) 
				 BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(E), '
					SET @MSG_TEXT = @MSG_TEXT + 'STORAGE_LOCATION not found in System Master'	
					EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Check Data Exists', 'GPS0004ERR', @MSG_TEXT, @N_ERR														
				 END
			
			IF((SELECT ISNUMERIC(@USAGE_QTY)) = 0)
			 BEGIN
				SET @L_ERR = 1	
				SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(E), '
				SET @MSG_TEXT = @MSG_TEXT + 'USAGE_QTY, format should numeric'	
				EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Data Type', 'GPS0004ERR', @MSG_TEXT, @N_ERR				
			 END	

			IF((SELECT ISDATE(@VALID_DT_FR)) = 0)
			 BEGIN
				SET @L_ERR = 1	
				SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(I), '
				SET @MSG_TEXT = @MSG_TEXT + 'Valid Date From: ' + @VALID_DT_FR + ' Format should Date (yyyy-MM-dd)'	
				EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Data Type', 'GPS0004ERR', @MSG_TEXT, @N_ERR				
			 END

		   IF((SELECT ISDATE(@VALID_DT_TO)) = 0)
			 BEGIN
				SET @L_ERR = 1	
				SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(J), '
				SET @MSG_TEXT = @MSG_TEXT + 'Valid Date To: ' + @VALID_DT_TO + ' Format should Date (yyy-MM-dd)'	
				EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Data Type', 'GPS0004ERR', @MSG_TEXT, @N_ERR				
			 END
		
		   IF(cast(@VALID_DT_TO as date) <= cast(@VALID_DT_FR as date))
			 BEGIN
				SET @L_ERR = 1	
				SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(I) and column(J), Valid Date From must be earlier than Valid Date To'						
				EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Data Exists', 'GPS0004ERR', @MSG_TEXT, @N_ERR									
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
				
			IF LEN(@MAT_NO) > 23
				BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'MAT_NO not more 23 character'		
					SET @MSG_TEXT = @MSG_TEXT + ' At row' + CAST(@LINE AS VARCHAR)
					EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Data Length', 'GPS0004ERR', @MSG_TEXT, @N_ERR										
				END	
            
			IF LEN(@UOM) > 10
				BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'UOM not more 10 character'		
					SET @MSG_TEXT = @MSG_TEXT + ' At row' + CAST(@LINE AS VARCHAR)
					EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Data Length', 'GPS0004ERR', @MSG_TEXT, @N_ERR										
				END	
				
			IF LEN(@PLANT_CD) > 5
				BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'PLANT_CD not more 5 character'		
					SET @MSG_TEXT = @MSG_TEXT + ' At row' + CAST(@LINE AS VARCHAR)
					EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Data Length', 'GPS0004ERR', @MSG_TEXT, @N_ERR									
				END	
				
			IF LEN(@STORAGE_LOCATION) > 10
				BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'STORAGE_LOCATION not more 10 character'		
					SET @MSG_TEXT = @MSG_TEXT + ' At row' + CAST(@LINE AS VARCHAR)
					EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Data Length', 'GPS0004ERR', @MSG_TEXT, @N_ERR										
				END	
				
			--CHECK DUPLICATE DATA 
			SET @ERR_MSG_DUPLACATE_COUNT = (SELECT COUNT(1) FROM TB_T_NON_COMPONENT_PART_LIST 
										    WHERE PROC_USAGE_CD = @PROC_USAGE_CD AND
												  GENTANI_HEADER_TYPE = @GENTANI_HEADER_TYPE AND
												  GENTANI_HEADER_CD = @GENTANI_HEADER_CD AND
												  MAT_NO = @MAT_NO AND
												  VALID_DT_FR = @VALID_DT_FR)
			IF (@ERR_MSG_DUPLACATE_COUNT > 1)
				BEGIN
					SET @L_ERR = 1					
					SET @MSG_TEXT = 'Data is duplicate in uploaded file at row ' + CAST(@LINE AS VARCHAR) 
					EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check Duplicate Data', 'GPS0004ERR', @MSG_TEXT, @N_ERR							
				END	
			SET @ERR_MSG_DUPLACATE_COUNT = (SELECT COUNT(1) FROM TB_M_NON_COMPONENT_PART_LIST 
										     WHERE PROC_USAGE_CD = @PROC_USAGE_CD AND
												   GENTANI_HEADER_TYPE = @GENTANI_HEADER_TYPE AND
												   GENTANI_HEADER_CD = @GENTANI_HEADER_CD AND
												   MAT_NO = @MAT_NO AND
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
		
		INSERT INTO [dbo].[TB_M_NON_COMPONENT_PART_LIST]
							   (
							    [PROC_USAGE_CD]
							   ,[GENTANI_HEADER_TYPE]
							   ,[GENTANI_HEADER_CD]
							   ,[MAT_NO]
							   ,[USAGE_QTY]
							   ,[UOM]
							   ,[PLANT_CD]
							   ,[STORAGE_LOCATION]
							   ,[VALID_DT_FR]
							   ,[VALID_DT_TO]
							   ,CREATED_BY
							   ,CREATED_DT
							   )
		SELECT  PROC_USAGE_CD,
				GENTANI_HEADER_TYPE,
				GENTANI_HEADER_CD,
				MAT_NO,				
				CAST(USAGE_QTY AS INT),
				UOM,
				PLANT_CD,
				STORAGE_LOCATION,
				VALID_DT_FR,
				VALID_DT_TO,
				@USER_ID,
				GETDATE()
        FROM [dbo].[TB_T_NON_COMPONENT_PART_LIST]
		
		EXEC SP_WRITE_LOG_D @USER_ID,@PROCESS_ID, 'Finish Uploading', 'GPS0004SUC', 'Finish Uploading Non Component PartList', @N_ERR
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

DELETE FROM TB_T_NON_COMPONENT_PART_LIST 
	
END TRY
BEGIN CATCH 
	IF EXISTS (SELECT * FROM TB_R_LOG_H WHERE PROCESS_ID = @PROCESS_ID)
	BEGIN
		SET @MSG_TEXT = 'LINE'+CONVERT(VARCHAR,ERROR_LINE())+ ERROR_MESSAGE();
		EXEC SP_WRITE_LOG_D @USER_ID, @PROCESS_ID, 'Check System Error', 'GPS0004ERR', @MSG_TEXT, @N_ERR
		EXEC SP_WRITE_LOG_FINISH @PROCESS_ID, '3'

		DELETE FROM TB_T_NON_COMPONENT_PART_LIST 

		SET @ERR_MSG = 'False|'
		SELECT @ERR_MSG	AS Text	
	END
END CATCH		    



