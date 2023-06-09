/****** Object:  StoredProcedure [dbo].[sp_POInquiry_ProcessGeneratePO]    Script Date: 10/4/2017 9:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_POInquiry_ProcessGeneratePO]
	@UserId VARCHAR(30),
	@RegNo VARCHAR(30)
AS
BEGIN
	BEGIN TRY
		DECLARE @FeedbackResult VARCHAR(50),
				@isError int = 0,
				@total_PO_Document int = 0,
				@total_Document int = 0,
				@total_Success int = 0,
				@total_Failed int = 0,
				@errorMessage VARCHAR(1000)

		EXEC sp_Job_ECatalogue_AutoPOCreation @FeedbackResult OUTPUT, @UserId, @RegNo

		if exists(SELECT 1 FROM TB_R_LOG_D WHERE PROCESS_ID = @FeedbackResult AND MESSAGE_ID = 'EXCEPTION')
		BEGIN
			SET @errorMessage = (SELECT TOP 1 MESSAGE_CONTENT FROM TB_R_LOG_D WHERE PROCESS_ID = @FeedbackResult AND MESSAGE_ID = 'EXCEPTION')
			RAISERROR (@errorMessage,16,1)
		END

		IF EXISTS(SELECT 1 FROM TB_H_PO_PROCESSING_INFO WHERE STATUS = 'F' AND PROCESS_ID = @FeedbackResult)
			SET @isError = 1

			
		SELECT  @total_PO_Document = COUNT(DISTINCT(PO_NO)) FROM TB_H_PO_PROCESSING_INFO WHERE PROCESS_ID = @FeedbackResult
		SELECT  @total_Document = COUNT(DISTINCT(PR_NO)) FROM TB_H_PO_PROCESSING_INFO WHERE PROCESS_ID = @FeedbackResult
		SELECT  @total_Success = COUNT(0) FROM TB_H_PO_PROCESSING_INFO WHERE PROCESS_ID = @FeedbackResult AND STATUS = 'F'
		SELECT  @total_Failed = COUNT(DISTINCT(PR_NO)) FROM TB_H_PO_PROCESSING_INFO WHERE PROCESS_ID = @FeedbackResult AND STATUS = 'S'

		SELECT 'S|'+CONVERT(VARCHAR, @FeedbackResult) +'|'+ CONVERT(VARCHAR,@total_PO_Document) +'|'+ CONVERT(VARCHAR,@total_Document) +'|'+ CONVERT(VARCHAR,@total_Success) +'|'+ CONVERT(VARCHAR,@total_Failed)
	END TRY
	BEGIN CATCH
		DECLARE @MessageResult VARCHAR(500) = ERROR_MESSAGE(), @MessageLine int = ERROR_LINE()
		SELECT 'E|' + @MessageResult + ', at line : ' + CONVERT(VARCHAR,@MessageLine)
	END CATCH
END