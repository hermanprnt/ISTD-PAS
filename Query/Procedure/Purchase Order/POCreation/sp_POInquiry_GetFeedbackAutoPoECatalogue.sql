USE [PAS_DB_QA]
GO
/****** Object:  StoredProcedure [dbo].[sp_POInquiry_ProcessGeneratePO]    Script Date: 11/23/2017 4:37:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_POInquiry_GetFeedbackAutoPoECatalogue]
	@ProcessId BIGINT
AS
BEGIN
	BEGIN TRY
		DECLARE @isError int = 0,
				@total_PO_Document int = 0,
				@total_Document int = 0,
				@total_Success int = 0,
				@total_Failed int = 0,
				@errorMessage VARCHAR(1000)

		if exists(SELECT 1 FROM TB_R_LOG_D WHERE PROCESS_ID = @ProcessId AND MESSAGE_ID = 'EXCEPTION')
		BEGIN
			SET @errorMessage = (SELECT TOP 1 MESSAGE_CONTENT FROM TB_R_LOG_D WHERE PROCESS_ID = @ProcessId AND MESSAGE_ID = 'EXCEPTION')
			RAISERROR (@errorMessage,16,1)
		END

		IF EXISTS(SELECT 1 FROM TB_H_PO_PROCESSING_INFO WHERE STATUS = 'F' AND PROCESS_ID = @ProcessId)
			SET @isError = 1

			
		SELECT  @total_PO_Document = COUNT(DISTINCT(PO_NO)) FROM TB_H_PO_PROCESSING_INFO WHERE PROCESS_ID = @ProcessId AND ISNULL(PO_NO,'') <> ''
		SELECT  @total_Document = COUNT(DISTINCT(PR_NO)) FROM TB_H_PO_PROCESSING_INFO WHERE PROCESS_ID = @ProcessId
		SELECT  @total_Success = COUNT(0) FROM TB_H_PO_PROCESSING_INFO WHERE PROCESS_ID = @ProcessId AND STATUS = 'F'
		SELECT  @total_Failed = COUNT(DISTINCT(PR_NO)) FROM TB_H_PO_PROCESSING_INFO WHERE PROCESS_ID = @ProcessId AND STATUS = 'S'

		SELECT 'S|'+CONVERT(VARCHAR, @ProcessId) +'|'+ CONVERT(VARCHAR,@total_PO_Document) +'|'+ CONVERT(VARCHAR,@total_Document) +'|'+ CONVERT(VARCHAR,@total_Failed) +'|'+ CONVERT(VARCHAR,@total_Success)
	END TRY
	BEGIN CATCH
		DECLARE @MessageResult VARCHAR(500) = ERROR_MESSAGE(), @MessageLine int = ERROR_LINE()
		SELECT 'E|' + @MessageResult + ', at line : ' + CONVERT(VARCHAR,@MessageLine)
	END CATCH
END