DECLARE @@MSG VARCHAR(MAX) = '',
	    @@EXISTS_VALID_FROM DATE

IF(ISNULL(@Division, '') <> '')
BEGIN
	IF NOT EXISTS(SELECT 1 from TB_R_SYNCH_EMPLOYEE WHERE DIVISION_ID = @Division)
	BEGIN
		SET @@MSG = 'Division ID ' + @Division + ' is not registered yet in TB_R_SYNCH_EMPLOYEE'
		SELECT @@MSG
		RETURN;
	END
END

IF NOT EXISTS(SELECT 1 FROM TB_M_COST_CENTER WHERE COST_CENTER_CD = @CostCenterCd)
BEGIN
	INSERT INTO dbo.TB_M_COST_CENTER
		(COST_CENTER_CD,
         COST_CENTER_DESC,
		 DIVISION_ID,
		 RESP_PERSON,
         VALID_DT_FROM,
         VALID_DT_TO,
         CREATED_BY,
         CREATED_DT,
         CHANGED_BY,
         CHANGED_DT)
    VALUES
		(@CostCenterCd,
         @CostCenterDesc,
	     @Division,
	     @RespPerson,
         @ValidDtFrom,
         '9999-12-31',
         @UId,
         GETDATE(),
         NULL,
         NULL)
END
ELSE
BEGIN
	SELECT @@EXISTS_VALID_FROM = VALID_DT_FROM FROM TB_M_COST_CENTER WHERE COST_CENTER_CD = @CostCenterCd
	IF(@@EXISTS_VALID_FROM < CAST(@ValidDtFrom AS DATE))
	BEGIN
		IF(CAST(DATEADD(DAY, -1, CAST(@ValidDtFrom AS DATE)) AS DATETIME) < @@EXISTS_VALID_FROM)
		BEGIN
			SELECT 'Fail to add Cost Center, because duplicate entries.'
			RETURN;
		END
		ELSE
		BEGIN
			UPDATE TB_M_COST_CENTER 
				SET VALID_DT_TO = DATEADD(DAY, -1, CAST(@ValidDtFrom AS DATE)),
				    CHANGED_BY = @UId,
                    CHANGED_DT = GETDATE()
				WHERE VALID_DT_TO = '9999-12-31' and COST_CENTER_CD = @CostCenterCd

				INSERT INTO dbo.TB_M_COST_CENTER
					(COST_CENTER_CD,
					 COST_CENTER_DESC,
					 DIVISION_ID,
					 RESP_PERSON,
					 VALID_DT_FROM,
					 VALID_DT_TO,
					 CREATED_BY,
					 CREATED_DT,
					 CHANGED_BY,
					 CHANGED_DT)
				VALUES
					(@CostCenterCd,
					 @CostCenterDesc,
					 @Division,
					 @RespPerson,
					 @ValidDtFrom,
					 '9999-12-31',
					 @UId,
					 GETDATE(),
					 NULL,
					 NULL)
		END
	END
	ELSE
	BEGIN
		SELECT 'Fail to add Cost Center, because duplicate entries.'
		RETURN;
	END
END
SELECT 'SUCCESS'