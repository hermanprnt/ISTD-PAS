
IF NOT EXISTS (SELECT 1 FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'MAIL' AND SYSTEM_CD = 'LINK_PRAPPROVAL')
BEGIN
    Insert Into TB_M_SYSTEM(FUNCTION_ID,    SYSTEM_CD,    SYSTEM_VALUE,    SYSTEM_REMARK,    CREATED_BY,    CREATED_DT,    CHANGED_BY,    CHANGED_DT)
    VALUES
    ('MAIL',    'LINK_PRAPPROVAL',    'http://localhost:2656/PRApproval',    'Link for Pr Approval mail',    'System',    '2017-02-27 00:00:00.000',    NULL,    NULL)
END

