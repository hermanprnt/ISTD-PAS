SELECT COUNT(COST_CENTER_CD)
FROM TB_M_COST_CENTER
WHERE COST_CENTER_CD IN (SELECT COST_CENTER_CD FROM TB_M_COST_CENTER WHERE COST_CENTER_CD LIKE @COST_CENTER_CD)