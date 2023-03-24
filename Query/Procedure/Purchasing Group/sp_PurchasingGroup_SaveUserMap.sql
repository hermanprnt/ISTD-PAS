CREATE PROCEDURE [dbo].[sp_PurchasingGroup_SaveUserMap]
    @purchasingGroup VARCHAR(6),
    @regNo VARCHAR(50),
    @divisionId VARCHAR(5),
    @deptId VARCHAR(5),
    @sectionId VARCHAR(5),
    @currentUser VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @message VARCHAR(MAX)

    BEGIN TRY
        BEGIN TRAN SaveUserMap

        DECLARE
            @oriDivisionId VARCHAR(50),
            @divisionName VARCHAR(50),
            @oriDepartmentId VARCHAR(50),
            @oriSectionId VARCHAR(50),
            @orgId VARCHAR(50),
            @orgTitle VARCHAR(100),
            @directorateId VARCHAR(50),
            @personnelName VARCHAR(100),
            @positionLevel VARCHAR(100),
            @positionTitle VARCHAR(100)

        SELECT
            @oriDivisionId = DIVISION_ID,
            @divisionName = DIVISION_NAME,
            @oriDepartmentId = DEPARTMENT_ID,
            @oriSectionId = SECTION_ID,
            @orgId = ORG_ID,
            @orgTitle = ORG_TITLE,
            @directorateId = DIRECTORATE_ID,
            @personnelName = PERSONNEL_NAME,
            @positionLevel = POSITION_LEVEL,
            @positionTitle = POSITION_TITLE
        FROM TB_R_SYNCH_EMPLOYEE
        WHERE NOREG = @regNo AND GETDATE() BETWEEN VALID_FROM AND VALID_TO

        IF (@oriDivisionId IS NULL AND
            @divisionName IS NULL AND
            @oriDepartmentId IS NULL AND
            @oriSectionId IS NULL AND
            @orgId IS NULL AND
            @orgTitle IS NULL AND
            @directorateId IS NULL AND
            @personnelName IS NULL AND
            @positionLevel IS NULL AND
            @positionTitle IS NULL)
        BEGIN
            RAISERROR('RegNo is not valid.', 16, 1)
        END

        IF (@divisionId <> @oriDivisionId)
        BEGIN
            RAISERROR('RegNo can''t be assigned to other division.', 16, 1)
        END

        INSERT INTO TB_M_COORDINATOR_MAPPING
        (COORDINATOR_CD, ORG_ID, ORG_NAME, POSITION_LEVEL, POSITION_LEVEL_NAME, NOREG,
        PIC_NAME, APPROVAL_FLAG, SECTION_ID, DEPARTMENT_ID, DIVISION_ID, CREATED_BY,
        CREATED_DT, CHANGED_BY, CHANGED_DT)
        VALUES (@purchasingGroup, @orgId, @orgTitle, @positionLevel, '', @regNo,
        @personnelName, 'N', @sectionId, @deptId, @divisionId, @currentUser, GETDATE(), NULL, NULL)

        COMMIT TRAN SaveUserMap

        SET @message = 'S|Finish'
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN SaveUserMap
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
    END CATCH

    SELECT @message [Message]
    SET NOCOUNT OFF
END
