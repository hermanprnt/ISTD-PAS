
IF EXISTS
(
select 1
from
(
select No,Cast(Split as datetime) LU
from SplitString(@LAST_CHANGE_LIST,';') A
) A
inner join 
(
select No,MAT_DOC_NO, MAX(ISNULL(CHANGED_DT,CREATED_DT)) LAST_UPDATE
from SplitString(@MAT_DOC_NO_LIST,';') A
inner join TB_R_GR_IR B ON A.Split=B.MAT_DOC_NO
GROUP BY No,MAT_DOC_NO
) B ON A.No=B.No
where ABS(DATEDIFF(second,B.LAST_UPDATE,A.LU)) > 2)
BEGIN
 SELECT 'ERR00020:Concurrency Found In Approve Process'
END
ELSE
BEGIN
	UPDATE B
	SET B.STATUS_CD='63',
	B.CHANGED_BY=@USER,
	B.CHANGED_DT=GETDATE(),
	B.APPROVED_BY=@USER,
	B.APPROVED_DT=GETDATE()
	from SplitString(@MAT_DOC_NO_LIST,';') A
	inner join TB_R_GR_IR B ON A.Split=B.MAT_DOC_NO
	
	SELECT 'OK'
END

