SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===================================================================  
-- Author  : Asep Syahidin 
-- Create date : 26/01/2017  
-- Description : Get List PR Inquery for Downloading To Excel  
-- ===================================================================  
IF EXISTS (SELECT * FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].sp_ReceivingList_ValidateCancelGRSA') AND type IN ( N'P', N'PC' ))
BEGIN
  DROP PROCEDURE [dbo].sp_ReceivingList_ValidateCancelGRSA
END
GO

CREATE PROCEDURE [dbo].[sp_ReceivingList_ValidateCancelGRSA]
    @currentUser VARCHAR(50),
    @MatDoc VARCHAR(50),
    @processId BIGINT
AS
BEGIN
    SET NOCOUNT ON
    DECLARE
        @message VARCHAR(MAX),
		@stringMessage VARCHAR(MAX)

	SET @message = 'S|GRSA Cancelation succesfully pass for validation';

    BEGIN TRY
		DECLARE @DBID INT, @DBNAME NVARCHAR(128);
		SET @DBID = DB_ID();
		SET @DBNAME = DB_NAME();
        
		IF NOT EXISTS(Select 1 from TB_R_GR_IR where CREATED_BY = @currentUser AND MAT_DOC_NO = @MatDoc )
		BEGIN
			SET @stringMessage = CONCAT('User ID ',@currentUser,' doesn''t have authorize to cancel Receiving No : ',@MatDoc );
			RAISERROR (@stringMessage,
				16, -- Severity.
				1, -- State.
				@DBID, -- First substitution argument.
				@DBNAME); -- Second substitution argument.
		END

    END TRY
    BEGIN CATCH
		 SET @message = 'E|' + ERROR_MESSAGE()
    END CATCH

    SET NOCOUNT OFF
    SELECT @message [Message]
END