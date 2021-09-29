Select  A.FUNCTION_ID as FunctionId,
		A.SYSTEM_CD as Code,
		A.SYSTEM_VALUE as Value,
		A.SYSTEM_REMARK as Remark
FROM TB_M_SYSTEM A
WHERE A.FUNCTION_ID = @FunctionID AND
      A.SYSTEM_CD = @Code