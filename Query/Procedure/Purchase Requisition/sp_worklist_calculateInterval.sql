﻿USE [NCP_QA]
GO
/****** Object:  StoredProcedure [dbo].[sp_worklist_calculateInterval]    Script Date: 12/18/2015 9:16:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		FID)REGGY
-- Create date: 04/07/2015
-- Description:	Add Date Interval
-- =============================================
ALTER PROCEDURE [dbo].[sp_worklist_calculateInterval] 
	@DOCUMENT_NO VARCHAR(13),
	@ITEM_NO VARCHAR(5),
	@APPROVED_DT DATE,
	@SEQ_NO INT
AS
BEGIN
DECLARE @INTERVAL INT,
		@APPROVAL_CD VARCHAR(5),
		@SEGMENT VARCHAR(1),
		@INTERVAL_DT DATE,
		@APPROVAL_DT DATE,
		@MSG VARCHAR(MAX),
		@STATUS VARCHAR(10)

	SET NOCOUNT ON;

	DECLARE interval_cursor CURSOR FOR
		SELECT 
			DOCUMENT_SEQ, 
			APPROVAL_CD, 
			APPROVAL_INTERVAL 
		FROM TB_R_WORKFLOW 
		WHERE DOCUMENT_NO = @DOCUMENT_NO 
			  AND ITEM_NO = @ITEM_NO
			  AND DOCUMENT_SEQ >= @SEQ_NO --AND SUBSTRING(APPROVAL_CD, 1,1) = @SEGMENTATION
			  AND IS_DISPLAY = 'Y' 
		ORDER BY DOCUMENT_SEQ ASC
	OPEN interval_cursor
	FETCH NEXT FROM interval_cursor 
				INTO 
					@SEQ_NO, 
					@APPROVAL_CD, 
					@INTERVAL
		WHILE @@FETCH_STATUS = 0
		BEGIN
			BEGIN TRY
				SET @SEGMENT = SUBSTRING(@APPROVAL_CD, 1, 1)
			
				SELECT @INTERVAL_DT = 
							CASE WHEN ((@APPROVAL_CD <> '10') AND (@APPROVAL_CD <> '40')) 
									THEN dbo.fn_dateadd_workday(@INTERVAL, @APPROVED_DT)
									ELSE @APPROVED_DT END

				UPDATE TB_R_WORKFLOW SET INTERVAL_DATE = @INTERVAL_DT 
					WHERE DOCUMENT_NO = @DOCUMENT_NO AND ITEM_NO = @ITEM_NO AND DOCUMENT_SEQ = @SEQ_NO

				--Note: for approval code 21 and 20 approved in same day
				IF(@APPROVAL_CD <> '20')
				BEGIN
					SET @APPROVED_DT = @INTERVAL_DT
				END
			END TRY
			BEGIN CATCH
				SET @MSG = ERROR_MESSAGE()
				SET @STATUS = 'FAILED'
				BREAK
			END CATCH

			FETCH NEXT FROM interval_cursor INTO @SEQ_NO, @APPROVAL_CD, @INTERVAL
		END
	CLOSE interval_cursor
	DEALLOCATE interval_cursor

	UPDATE TB_R_WORKFLOW SET INTERVAL_DATE = NULL WHERE DOCUMENT_NO = @DOCUMENT_NO AND IS_DISPLAY = 'N'
	
	IF(@STATUS = 'FAILED')
		RAISERROR(@MSG, 16, 1)
END