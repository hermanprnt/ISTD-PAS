﻿CREATE PROCEDURE [dbo].[sp_CheckIsEmployee]
	@NOREG VARCHAR(10)
AS
BEGIN
    IF EXISTS(SELECT 1 FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = @NOREG)
	BEGIN
		SELECT 'TRUE'
	END
	ELSE
	BEGIN
		SELECT 'FALSE'
	END
END