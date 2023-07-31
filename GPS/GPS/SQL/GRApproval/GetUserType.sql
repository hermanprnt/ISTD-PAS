  select Split SYSTEM_CD, Split SYSTEM_VALUE from TB_M_SYSTEM A 
  cross apply SplitString(A.SYSTEM_VALUE,';')
  where FUNCTION_ID='V0601' and SYSTEM_CD='USER_TYPE'