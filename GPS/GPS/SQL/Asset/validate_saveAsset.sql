﻿DECLARE @@STATUS VARCHAR(10) = 'SUCCESS',
		@@MESSAGE VARCHAR(MAX) = ''

IF EXISTS(SELECT 1 FROM TB_T_ASSET WHERE PROCESS_ID = @PROCESS_ID AND DELETE_FLAG = 'N' AND VALID_FLAG = 'N')
BEGIN
	SET @@STATUS = 'ERR'
	SET @@MESSAGE = 'There is some invalid data asset.'
END

IF NOT EXISTS(SELECT 1 FROM TB_T_ASSET WHERE PROCESS_ID = @PROCESS_ID AND DELETE_FLAG = 'N')
BEGIN
	SET @@STATUS = 'ERR'
	SET @@MESSAGE = 'There is no data to be saved.'
END

SELECT @@STATUS AS PROCESS_STATUS, @@MESSAGE AS [MESSAGE]