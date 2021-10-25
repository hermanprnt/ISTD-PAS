DECLARE @@DIVISION_ID INT

SELECT @@DIVISION_ID = DIVISION_ID FROM TB_R_SYNCH_EMPLOYEE
WHERE NOREG = @NOREG

SELECT PROC_CHANNEL_CD, PROC_CHANNEL_DESC FROM TB_M_PROCUREMENT_CHANNEL
WHERE ((DIVISION_ID = @@DIVISION_ID AND ISNULL(@@DIVISION_ID, 0) IN (19, 14)) OR (ISNULL(@@DIVISION_ID, 0) NOT IN (19, 14)))