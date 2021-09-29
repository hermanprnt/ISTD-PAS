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

ALTER PROCEDURE [dbo].[sp_Upload_Quota]
    @USER_ID VARCHAR(50),
	@PROCESS_ID numeric	   		
AS
SET NOCOUNT ON
DECLARE @LINE int,
        @DIVISION_ID VARCHAR(50),        
		@DIVISION_NAME VARCHAR(50),
		@QUOTA_TYPE VARCHAR(50),
		@WBS_NO VARCHAR(50),
		@TYPE_DESCRIPTION VARCHAR(50),		
		@ORDER_COORD VARCHAR(50),
		@ORDER_COORD_NAME VARCHAR(50),
		@QUOTA_AMOUNT VARCHAR(50),
		@QUOTA_AMOUNT_TOL VARCHAR(50),
		        
		@ERR_MSG_DUPLACATE_COUNT INT,
	    @L_ERR INT,
		@N_ERR INT,
		@maxid INT,	
		@Flag INT,		
	    @MSG_TEXT VARCHAR(1000),	
		@ERR_MSG AS VARCHAR(50),
		@tmpLog LOG_TEMP	    	   			
				    
BEGIN TRY
  
   SET @L_ERR = 0
      
   EXEC dbo.sp_PutLog 'Start Upload', @USER_ID, 'sp_Upload_Quota', @PROCESS_ID OUTPUT, 'INF00001', 'INF', '1', '111002', 0
		
--CHECK VALIDASI						   
-----------------
	SELECT @maxid = COUNT(1) FROM TB_T_QUOTA
	SET @Flag = 1

	INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), 'INF00002', 'INF', 'Process', '1', 'sp_Upload_Quota', '111002', 1, @USER_ID)
	
	WHILE (@Flag <= @maxid)
		BEGIN 
			SELECT @LINE = LINE,
			       @DIVISION_ID = DIVISION_ID,
			       @DIVISION_NAME = DIVISION_NAME,
				   @WBS_NO = WBS_NO,
			       @QUOTA_TYPE = QUOTA_TYPE,
			       @TYPE_DESCRIPTION = TYPE_DESCRIPTION,	
				   @ORDER_COORD = ORDER_COORD,
				   @ORDER_COORD_NAME = ORDER_COORD_NAME,
				   @QUOTA_AMOUNT = QUOTA_AMOUNT,
				   @QUOTA_AMOUNT_TOL = QUOTA_AMOUNT_TOL				   			   
			FROM TB_T_QUOTA 
			WHERE NO=@Flag	
			
			IF (@DIVISION_ID = '' AND @DIVISION_NAME = '' AND @WBS_NO = '' AND @QUOTA_TYPE = '' AND @TYPE_DESCRIPTION = '' AND @ORDER_COORD = '' AND @ORDER_COORD_NAME = '' AND @QUOTA_AMOUNT = '' AND @QUOTA_AMOUNT_TOL = '')				
				BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'Data is empty. Please delete row an excel file'		
					SET @MSG_TEXT = @MSG_TEXT + ' At row ' + CAST(@LINE AS VARCHAR)					
					INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), 'ERR00007', 'ERR', @MSG_TEXT, '1', 'sp_Upload_Quota', '111002', 1, @USER_ID)														
				END 

            IF NOT EXISTS(SELECT 1 FROM TB_R_SYNCH_EMPLOYEE WHERE  DIVISION_ID = @DIVISION_ID) 
				 BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(A), '
					SET @MSG_TEXT = @MSG_TEXT + 'DIVISION_ID not found in Synch Employee Master'					
					INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), 'ERR00011', 'ERR', @MSG_TEXT, '1', 'sp_Upload_Quota', '111002', 1, @USER_ID)																												
				 END
           
		   IF NOT EXISTS(select 1 from TB_R_WBS where WBS_NO = @WBS_NO) 
				 BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(C), '
					SET @MSG_TEXT = @MSG_TEXT + 'WBS_NO not found in WBS Master'					
					INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), 'ERR00011', 'ERR', @MSG_TEXT, '1', 'sp_Upload_Quota', '111002', 1, @USER_ID)																												
				 END
				
			IF NOT EXISTS(SELECT 1 FROM TB_M_VALUATION_CLASS WHERE VALUATION_CLASS = @QUOTA_TYPE) 
				 BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(D), '
					SET @MSG_TEXT = @MSG_TEXT + 'QUOTA_TYPE not found in Valuation Class Master'					
					INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), 'ERR00011', 'ERR', @MSG_TEXT, '1', 'sp_Upload_Quota', '111002', 1, @USER_ID)																																										
				 END	

            IF((SELECT ISNUMERIC(@DIVISION_ID)) = 0)
			 BEGIN
				SET @L_ERR = 1	
				SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(A), '
				SET @MSG_TEXT = @MSG_TEXT + 'DIVISION_ID, format should numeric'					
				INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), 'ERR00014', 'ERR', @MSG_TEXT, '1', 'sp_Upload_Quota', '111002', 1, @USER_ID)				
			 END	    	

			IF((SELECT ISNUMERIC(@QUOTA_AMOUNT)) = 0)
			 BEGIN
				SET @L_ERR = 1	
				SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(H), '
				SET @MSG_TEXT = @MSG_TEXT + 'QUOTA_AMOUNT, format should numeric'					
				INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), 'ERR00014', 'ERR', @MSG_TEXT, '1', 'sp_Upload_Quota', '111002', 1, @USER_ID)				
			 END
			 
			IF((SELECT ISNUMERIC(@QUOTA_AMOUNT_TOL)) = 0)
				 BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'Row ' + CAST(@LINE AS VARCHAR) + ' column(I), '
					SET @MSG_TEXT = @MSG_TEXT + 'QUOTA_AMOUNT_TOL, format should numeric'					
					INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), 'ERR00014', 'ERR', @MSG_TEXT, '1', 'sp_Upload_Quota', '111002', 1, @USER_ID)				
				 END			
				
			IF LEN(@DIVISION_NAME) > 40
				BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'DIVISION_NAME not more 40 character'		
					SET @MSG_TEXT = @MSG_TEXT + ' At row' + CAST(@LINE AS VARCHAR)					
					INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), 'ERR00005', 'ERR', @MSG_TEXT, '1', 'sp_Upload_Quota', '111002', 1, @USER_ID)								
				END

            IF LEN(@WBS_NO) > 30
				BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'WBS_NO not more 30 character'		
					SET @MSG_TEXT = @MSG_TEXT + ' At row' + CAST(@LINE AS VARCHAR)					
					INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), 'ERR00005', 'ERR', @MSG_TEXT, '1', 'sp_Upload_Quota', '111002', 1, @USER_ID)								
				END
				
			IF LEN(@ORDER_COORD) > 6
				BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'ORDER_COORD not more 6 character'		
					SET @MSG_TEXT = @MSG_TEXT + ' At row' + CAST(@LINE AS VARCHAR)					
					INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), 'ERR00005', 'ERR', @MSG_TEXT, '1', 'sp_Upload_Quota', '111002', 1, @USER_ID)								
				END		
				
			IF LEN(@QUOTA_TYPE) > 4
				BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'QUOTA_TYPE not more 4 character'		
					SET @MSG_TEXT = @MSG_TEXT + ' At row' + CAST(@LINE AS VARCHAR)				
					INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), 'ERR00005', 'ERR', @MSG_TEXT, '1', 'sp_Upload_Quota', '111002', 1, @USER_ID)									
				END	
				
			IF LEN(@TYPE_DESCRIPTION) > 50
				BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'TYPE_DESCRIPTION not more 50 character'		
					SET @MSG_TEXT = @MSG_TEXT + ' At row' + CAST(@LINE AS VARCHAR)				
					INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), 'ERR00005', 'ERR', @MSG_TEXT, '1', 'sp_Upload_Quota', '111002', 1, @USER_ID)									
				END
			
			IF LEN(@ORDER_COORD_NAME) > 40
				BEGIN
					SET @L_ERR = 1	
					SET @MSG_TEXT = 'ORDER_COORD_NAME not more 40 character'		
					SET @MSG_TEXT = @MSG_TEXT + ' At row' + CAST(@LINE AS VARCHAR)				
					INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), 'ERR00005', 'ERR', @MSG_TEXT, '1', 'sp_Upload_Quota', '111002', 1, @USER_ID)									
				END					
				
			--CHECK DUPLICATE DATA 
			SET @ERR_MSG_DUPLACATE_COUNT = (SELECT COUNT(1) FROM TB_T_QUOTA 
										    WHERE DIVISION_ID = @DIVISION_ID AND
												  QUOTA_TYPE = @QUOTA_TYPE ) 
			IF (@ERR_MSG_DUPLACATE_COUNT > 1)
				BEGIN
					SET @L_ERR = 1					
					SET @MSG_TEXT = 'Data is duplicate in uploaded file at row ' + CAST(@LINE AS VARCHAR)					
					INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), 'ERR00015', 'ERR', @MSG_TEXT, '1', 'sp_Upload_Quota', '111002', 1, @USER_ID)							
				END	
            SET @ERR_MSG_DUPLACATE_COUNT = (SELECT COUNT(1) FROM TB_M_QUOTA 
										    WHERE DIVISION_ID = @DIVISION_ID AND
												  QUOTA_TYPE = @QUOTA_TYPE ) 
			IF (@ERR_MSG_DUPLACATE_COUNT > 0)
				BEGIN
					SET @L_ERR = 1					
					SET @MSG_TEXT = 'Data is already registered in Quota Master at row ' + CAST(@LINE AS VARCHAR)					
					INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), 'ERR00006', 'ERR', @MSG_TEXT, '1', 'sp_Upload_Quota', '111002', 1, @USER_ID)							
				END														
			
		    SET @Flag = @Flag + 1
		END	
-----------------

IF (@L_ERR = 0)
	BEGIN
		
		INSERT INTO [dbo].[TB_M_QUOTA]
				([DIVISION_ID]
				,[DIVISION_NAME]
				,[WBS_NO]
				,[QUOTA_TYPE]
				,[TYPE_DESCRIPTION]
				,[ORDER_COORD]
				,[ORDER_COORD_NAME]
				,[QUOTA_AMOUNT]
				,[QUOTA_AMOUNT_TOL]
				,[CREATED_BY]
				,[CREATED_DT]
				,[CHANGED_BY]
				,[CHANGED_DT])							  
		SELECT  CAST(DIVISION_ID AS INT),
				DIVISION_NAME,
				WBS_NO,
				QUOTA_TYPE,				
				TYPE_DESCRIPTION,
			    ORDER_COORD,
				ORDER_COORD_NAME,
				CAST(QUOTA_AMOUNT AS decimal(18,2)),
				CAST(QUOTA_AMOUNT_TOL AS decimal(18,2)),
				@USER_ID,
				GETDATE(),
				NULL,
				NULL
        FROM [dbo].[TB_T_QUOTA]		
	
		INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), 'INF00003', 'INF', 'Finish Uploading', '1', 'sp_Upload_Quota', '111002', 2, @USER_ID)
		
		SET @ERR_MSG = 'True|'
		SELECT @ERR_MSG	AS Text		
	END
ELSE
	BEGIN
		SET @MSG_TEXT = 'Upload is ended with error'
		
		INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), 'ERR00009', 'ERR', @MSG_TEXT, '1', 'sp_Upload_Quota', '111002', 3, @USER_ID)
		
		SET @ERR_MSG = 'False|'
		SELECT @ERR_MSG	AS Text
	END

EXEC sp_PutLog_Temp @tmpLog
DELETE FROM TB_T_QUOTA 
	
END TRY
BEGIN CATCH 
	IF EXISTS (SELECT * FROM TB_R_LOG_H WHERE PROCESS_ID = @PROCESS_ID)
	BEGIN
		SET @MSG_TEXT = 'LINE'+CONVERT(VARCHAR,ERROR_LINE())+ ERROR_MESSAGE();
	
		INSERT INTO @tmpLog VALUES (@PROCESS_ID, GETDATE(), 'ERR00009', 'ERR', @MSG_TEXT, '1', 'sp_Upload_Quota', '111002', 3, @USER_ID)

		EXEC sp_PutLog_Temp @tmpLog
		DELETE FROM TB_T_QUOTA 

		SET @ERR_MSG = 'False|'
		SELECT @ERR_MSG	AS Text	
	END
END CATCH		    



