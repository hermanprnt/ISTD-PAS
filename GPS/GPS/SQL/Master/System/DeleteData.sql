DELETE FROM TB_M_SYSTEM
WHERE FUNCTION_ID = @FunctionID AND SYSTEM_CD = @Code
 
select 'True|Delete successfully'