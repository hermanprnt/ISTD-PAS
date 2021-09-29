CREATE PROCEDURE [dbo].[sp_PurchasingGroup_CheckRegNo]
    @regNo VARCHAR(50)
AS
BEGIN
    IF (EXISTS(SELECT NOREG FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = @regNo AND GETDATE() BETWEEN VALID_FROM AND VALID_TO))
    BEGIN
        SELECT 'S|RegNo is exists.'
    END
    ELSE
    BEGIN
        SELECT 'W|RegNo doesn''t exists.'
    END
END
