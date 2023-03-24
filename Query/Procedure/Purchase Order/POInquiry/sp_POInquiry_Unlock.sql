-- =============================================
-- Author:		FID.Intan Puspitasari
-- Create date: 2/22/2016
-- Description:	PO Unlocking Process
-- =============================================
CREATE PROCEDURE [dbo].[sp_POInquiry_Unlock]
    @PONo VARCHAR(11),
	@userid VARCHAR(20)
AS
BEGIN
DECLARE @AUTH INT, @EXIST INT, @MESSAGE VARCHAR(MAX)

	SELECT @AUTH = COUNT(1)
	FROM TB_T_LOCK tlock INNER JOIN TB_R_PO_H poh 
	ON poh.PO_NO = @PONo AND poh.PROCESS_ID = tlock.PROCESS_ID AND tlock.[USER_ID] = @userid

	SELECT @EXIST = COUNT(1) 
	FROM TB_T_LOCK tlock INNER JOIN TB_R_PO_H poh
	ON poh.PROCESS_ID = tlock.PROCESS_ID AND poh.PO_NO = @PONo

	IF(@AUTH <> 0 OR @EXIST = 0)
	BEGIN
		BEGIN TRY
			DELETE tlock 
			FROM TB_T_LOCK tlock INNER JOIN TB_R_PO_H poh ON poh.PO_NO = @PONo AND poh.PROCESS_ID = tlock.PROCESS_ID

			UPDATE TB_R_PO_H
			SET PROCESS_ID = NULL WHERE PO_NO = @PONo

			SELECT 'SUCCESS'
		END TRY
		BEGIN CATCH
			SELECT @MESSAGE = ERROR_MESSAGE()
		END CATCH
	END
	ELSE
	BEGIN
		SELECT @MESSAGE = MESSAGE_TEXT FROM TB_M_MESSAGE WHERE MESSAGE_ID = 'WRN00009'
	END

	SELECT @MESSAGE
END