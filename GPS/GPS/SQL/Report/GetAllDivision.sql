
SELECT count(*) AS DIVISION_ID 
  FROM [TB_M_COORDINATOR_MAPPING] 
where NOREG = @NO_REG
  