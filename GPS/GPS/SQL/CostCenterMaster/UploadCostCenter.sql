INSERT INTO 
TB_M_COST_CENTER
 (
	  COST_CENTER_CD
	  ,COST_CENTER_DESC
	  ,COST_CENTER_GRP_CD
	  ,VALID_DT_FROM
	  ,VALID_DT_TO
	  ,CREATED_BY
	  ,CREATED_DT
	  ,CHANGED_BY
	  ,CHANGED_DT

)
 VALUES
(
	  @COST_CENTER_CD
	  ,@COST_CENTER_DESC
	  ,@COST_CENTER_GRP_CD
	  ,@VALID_DT_FROM
	  ,@VALID_DT_TO
	  ,'System'
	  ,GETDATE()
	  ,NULL
	  ,NULL
)