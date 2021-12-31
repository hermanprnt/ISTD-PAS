INSERT INTO #tmpSourceList
VALUES
(
	@MaterialNo,
	@VendorCode,
    @ValidDateFrom,
	'9999-12-31',
	@uid,
	GETDATE(),
	null,
	null
)

if(exists (select 1 from TB_M_SOURCE_LIST
		   where MAT_NO = @MaterialNo AND VALID_DT_TO = '9999-12-31'))
BEGIN
	INSERT INTO #tmpUpdateSourceList
	VALUES(@MaterialNo,
		   DATEADD(day, -1, @ValidDateFrom),
		   @uid,
		   GETDATE())
END