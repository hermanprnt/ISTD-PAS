UPDATE TB_M_User SET
[password] = @Password,
PASSWORD_RESET = @ResetAdmin
WHERE USERNAME = @Username
AND IN_ACTIVE_DIRECTORY = 0
