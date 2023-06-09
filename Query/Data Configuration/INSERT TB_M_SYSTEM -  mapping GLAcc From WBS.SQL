BEGIN
IF NOT EXISTS (SELECT 1 FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'GLMAP1' AND SYSTEM_CD = 'P')
BEGIN
	Insert Into TB_M_SYSTEM(FUNCTION_ID,	SYSTEM_CD,	SYSTEM_VALUE,	SYSTEM_REMARK,	CREATED_BY,	CREATED_DT,	CHANGED_BY,	CHANGED_DT)
	VALUES
	('GLMAP1',	'P',	'D',	'First Level GL MAPPING Pattern P',	'System',	'2017-01-01 00:00:00.000',	NULL,	NULL)
END

IF NOT EXISTS (SELECT 1 FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'GLMAP1' AND SYSTEM_CD = 'S')
BEGIN
	Insert Into TB_M_SYSTEM(FUNCTION_ID,	SYSTEM_CD,	SYSTEM_VALUE,	SYSTEM_REMARK,	CREATED_BY,	CREATED_DT,	CHANGED_BY,	CHANGED_DT)
	VALUES
	('GLMAP1',	'S',	'D',	'First Level GL MAPPING Pattern S',	'System',	'2017-01-01 00:00:00.000',	NULL,	NULL)
END

IF NOT EXISTS (SELECT 1 FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'GLMAP2' AND SYSTEM_CD = 'PM')
BEGIN
	Insert Into TB_M_SYSTEM(FUNCTION_ID,	SYSTEM_CD,	SYSTEM_VALUE,	SYSTEM_REMARK,	CREATED_BY,	CREATED_DT,	CHANGED_BY,	CHANGED_DT)
	VALUES
	('GLMAP2',	'PM',	'E',	'Fifth Level GL MAPPING Pattern PM',	'System',	'2017-01-01 00:00:00.000',	NULL,	NULL)
END

IF NOT EXISTS (SELECT 1 FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'GLMAP2' AND SYSTEM_CD = 'CM')
BEGIN
	Insert Into TB_M_SYSTEM(FUNCTION_ID,	SYSTEM_CD,	SYSTEM_VALUE,	SYSTEM_REMARK,	CREATED_BY,	CREATED_DT,	CHANGED_BY,	CHANGED_DT)
	VALUES
	('GLMAP2',	'CM',	'E',	'Fifth Level GL MAPPING Pattern CM',	'System',	'2017-01-01 00:00:00.000',	NULL,	NULL)
END

IF NOT EXISTS (SELECT 1 FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'GLMAP2' AND SYSTEM_CD = 'BM')
BEGIN
	Insert Into TB_M_SYSTEM(FUNCTION_ID,	SYSTEM_CD,	SYSTEM_VALUE,	SYSTEM_REMARK,	CREATED_BY,	CREATED_DT,	CHANGED_BY,	CHANGED_DT)
	VALUES
	('GLMAP2',	'BM',	'E',	'Fifth Level GL MAPPING Pattern BM',	'System',	'2017-01-01 00:00:00.000',	NULL,	NULL)
END

IF NOT EXISTS (SELECT 1 FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'GLMAP2' AND SYSTEM_CD = 'OH')
BEGIN
	Insert Into TB_M_SYSTEM(FUNCTION_ID,	SYSTEM_CD,	SYSTEM_VALUE,	SYSTEM_REMARK,	CREATED_BY,	CREATED_DT,	CHANGED_BY,	CHANGED_DT)
	VALUES
	('GLMAP2',	'OH',	'E',	'Fifth Level GL MAPPING Pattern OH',	'System',	'2017-01-01 00:00:00.000',	NULL,	NULL)
END

IF NOT EXISTS (SELECT 1 FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'GLMAP2' AND SYSTEM_CD = 'HE')
BEGIN
	Insert Into TB_M_SYSTEM(FUNCTION_ID,	SYSTEM_CD,	SYSTEM_VALUE,	SYSTEM_REMARK,	CREATED_BY,	CREATED_DT,	CHANGED_BY,	CHANGED_DT)
	VALUES
	('GLMAP2',	'HE',	'E',	'Fifth Level GL MAPPING Pattern HE',	'System',	'2017-01-01 00:00:00.000',	NULL,	NULL)
END

IF NOT EXISTS (SELECT 1 FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'GLMAP2' AND SYSTEM_CD = 'KI')
BEGIN
	Insert Into TB_M_SYSTEM(FUNCTION_ID,	SYSTEM_CD,	SYSTEM_VALUE,	SYSTEM_REMARK,	CREATED_BY,	CREATED_DT,	CHANGED_BY,	CHANGED_DT)
	VALUES
	('GLMAP2',	'KI',	'E',	'Fifth Level GL MAPPING Pattern KI',	'System',	'2017-01-01 00:00:00.000',	NULL,	NULL)
END
END

