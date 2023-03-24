SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===================================================================  
-- Author  : Asep Syahidin 
-- Create date : 02/02/2017  
-- Description : Po Receiving Authorization 
-- ===================================================================  
IF EXISTS (SELECT * FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].sp_PoCommon_PoReceivingAuthorization') AND type IN ( N'P', N'PC' ))
BEGIN
  DROP PROCEDURE [dbo].sp_PoCommon_PoReceivingAuthorization
END
GO

CREATE PROCEDURE [dbo].[sp_PoCommon_PoReceivingAuthorization]
    @currentUser VARCHAR(50),
	@currentRegNo VARCHAR(50),
	@poNo VARCHAR(20),
	@reffNo VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @message VARCHAR(MAX), @prNo VARCHAR(20),@stringMessage VARCHAR(MAX)

	BEGIN TRY
		IF OBJECT_ID('tempdb..#prList') IS NOT NULL
			DROP TABLE #prList

		SELECT PR_NO into #prList 
			FROM TB_R_PO_H h 
			INNER JOIN TB_R_PO_ITEM item on item.PO_NO = h.PO_NO
		WHERE 
		 (h.PO_NO LIKE '%' + ISNULL(@poNo,'') + '%'   
		 AND ISNULL(@poNo,'') <> ''  
		 OR (ISNULL(@poNo,'') = '')) 
		 AND (h.REF_NO LIKE '%' + ISNULL(@reffNo,'') + '%'   
		 AND ISNULL(@reffNo,'') <> ''  
		 OR (ISNULL(@reffNo,'') = '')) 

		IF OBJECT_ID('tempdb..#authorizeUser') IS NOT NULL
			DROP TABLE #authorizeUser

		SELECT NOREG INTO #authorizeUser
			FROM TB_R_WORKFLOW wf WITH(NOLOCK)
			INNER JOIN TB_M_STATUS st WITH(NOLOCK) on st.STATUS_CD = wf.APPROVAL_CD
			WHERE wf.DOCUMENT_NO IN (SELECT PR_NO FROM #prList) AND st.SEGMENTATION_CD = 2

		INSERT INTO #authorizeUser
		SELECT eStaff.NOREG 
			FROM TB_R_SYNCH_EMPLOYEE eStaff WITH(NOLOCK)
			INNER JOIN TB_R_SYNCH_EMPLOYEE eLead WITH(NOLOCK) ON eLead.ORG_ID = eStaff.ORG_ID
		WHERE eLead.NOREG IN (SELECT NOREG FROM #authorizeUser)

		IF EXISTS (SELECT 1 FROM #authorizeUser WHERE NOREG =  @currentRegNo)
			SET @message = 'S|#Po Receiving authorize validation has pass with succesfully';
		ELSE BEGIN
			SET @stringMessage = CONCAT('User ID ',@currentUser,' doesn''t have authorize to Receiving ' + CASE WHEN ISNULL(@poNo,'') = '' THEN 'REFF' ELSE 'PO' END + ' No : ''',CASE WHEN ISNULL(@poNo,'') = '' THEN @reffNo ELSE @poNo END ) + '''';
			SET @message = 'E|#'+ @stringMessage;
		END

		DROP TABLE #prList
		DROP TABLE #authorizeUser
	END TRY
	BEGIN CATCH   
		DECLARE @ErrorMessage NVARCHAR(4000)
		DECLARE @ErrorSeverity INT
		DECLARE @ErrorState INT
		DECLARE @ErrorLine INT
   
		SELECT @ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE(),
				@ErrorLine = ERROR_LINE()
  
		SET @message = 'E|' + @ErrorMessage + ' : At line : ' + CONVERT(VARCHAR, @ErrorLine)
       
	END CATCH

    SET NOCOUNT OFF
    SELECT @message [Message]
END