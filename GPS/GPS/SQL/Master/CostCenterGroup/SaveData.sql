DECLARE @@MESSAGE VARCHAR(MAX) = '',
		@@EXIST INT

BEGIN TRY
	IF(@Flag = '0')
	BEGIN
		SELECT @@EXIST = COUNT(1) FROM TB_M_COST_CENTER_GRP WHERE COST_CENTER_GRP_CD = @CostGroup AND DIVISION_CD = @DivisionCd

		IF(@@EXIST = 0)
		BEGIN
			--Begin Insert
			INSERT INTO [dbo].[TB_M_COST_CENTER_GRP]
				   ([COST_CENTER_GRP_CD]
				   ,[COST_CENTER_GRP_DESC]
				   ,[DIVISION_CD]
				   ,[CREATED_BY]
				   ,[CREATED_DT]
				   ,[CHANGED_BY]
				   ,[CHANGED_DT])
			 VALUES
				   (@CostGroup
				   ,@CostGroupDesc
				   ,@DivisionCd
				   ,@uid
				   ,GETDATE()
				   ,null
				   ,null)
		END
		ELSE
		BEGIN
			SET @@MESSAGE = 'Data for Cost Center Group ' + @CostGroup + ' and Division ' + @DivisionCd + ' already exist'
		END
	END
	ELSE
	BEGIN
		--Begin Edit
		UPDATE TB_M_COST_CENTER_GRP
		SET COST_CENTER_GRP_DESC = @CostGroupDesc,
			DIVISION_CD = @DivisionCd,
			CHANGED_BY = @uid,
			CHANGED_DT = GETDATE()
		WHERE COST_CENTER_GRP_CD = @CostGroup
	END
END TRY
BEGIN CATCH
	SET @@MESSAGE = ERROR_MESSAGE()
END CATCH

SELECT @@MESSAGE