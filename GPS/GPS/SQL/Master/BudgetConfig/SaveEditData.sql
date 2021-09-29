IF(@Flag = '0')
BEGIN
	if not exists(select 1 from TB_R_WBS where WBS_NO = @WBS_NO)
	BEGIN --Begin Insert
		INSERT INTO dbo.TB_R_WBS
		( 
			WBS_NO,
			WBS_NAME,
			WBS_YEAR,
			DIVISION_ID,
			PROJECT_NO,
			CREATED_BY ,
			CREATED_DT ,
			CHANGED_BY ,
			CHANGED_DT
		)
		VALUES  
		( 
			@WBS_NO,
			@WBS_NAME,
			@WBS_YEAR,
			@DIVISION_ID,
			@WBS_TYPE,
			@UId,
			GETDATE(),
			NULL,
			NULL
		)
         
		select 'True|Save Successfully'
	END
	ELSE
	BEGIN
		UPDATE dbo.TB_R_WBS
		SET 
			PROJECT_NO = @WBS_TYPE,
			CHANGED_BY = @UId,
			CHANGED_DT = GETDATE()
		WHERE WBS_NO = @WBS_NO AND WBS_NAME = @WBS_NAME AND WBS_YEAR = @WBS_YEAR

		select 'True|Update Successfully'
	END
END
ELSE IF(@Flag = '0')
BEGIN
	UPDATE dbo.TB_R_WBS
	SET 
		PROJECT_NO = @WBS_TYPE,
		CHANGED_BY = @UId,
		CHANGED_DT = GETDATE()
	WHERE WBS_NO = @WBS_NO AND WBS_NAME = @WBS_NAME AND WBS_YEAR = @WBS_YEAR

	select 'True|Update Successfully'
END
ELSE
BEGIN
	DELETE FROM dbo.TB_R_WBS
	WHERE WBS_NO = @WBS_NO AND WBS_YEAR = @WBS_YEAR AND PROJECT_NO = @WBS_TYPE
	select 'True|Delete Successfully'
END