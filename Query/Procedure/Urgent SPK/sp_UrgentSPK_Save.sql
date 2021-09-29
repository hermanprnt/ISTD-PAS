CREATE PROCEDURE [dbo].[sp_UrgentSPK_Save]
    @currentUser VARCHAR(50),
    @currentUserNoReg VARCHAR(50),
    @processId BIGINT,
    @moduleId VARCHAR(3),
    @functionId VARCHAR(6),
    @editMode VARCHAR(1),
    @prNo VARCHAR(11),
    @poNo VARCHAR(11),
    @spkNo VARCHAR(18),
    @biddingDate DATETIME,
    @spkWork VARCHAR(100),
    @spkAmount DECIMAL(13,3),
    @spkLocation VARCHAR(50),
    @vendorCode VARCHAR(6),
    @vendorName VARCHAR(50),
    @vendorAddress VARCHAR(150),
    @vendorPostal VARCHAR(6),
    @vendorCity VARCHAR(30),
    @spkPeriodStart DATETIME,
    @spkPeriodEnd DATETIME,
    @spkRetention INT,
    @terminI VARCHAR(5),
    @terminIDesc VARCHAR(50),
    @terminII VARCHAR(5),
    @terminIIDesc VARCHAR(50),
    @terminIII VARCHAR(5),
    @terminIIIDesc VARCHAR(50),
    @terminIV VARCHAR(5),
    @terminIVDesc VARCHAR(50),
    @terminV VARCHAR(5),
    @terminVDesc VARCHAR(50)
AS
BEGIN
    DECLARE
        @message VARCHAR(MAX),
        @actionName VARCHAR(50) = 'sp_UrgentSPK_Save',
        @tmpLog LOG_TEMP

    SET NOCOUNT ON
    BEGIN TRY
        EXEC dbo.sp_PutLog 'I|Start', @currentUser, @actionName, @processId OUTPUT, 'INF', 'INF', @moduleId, @functionId, 0

        BEGIN TRAN SaveData

        DECLARE @spkDate DATETIME = GETDATE()
        IF (@editMode = 'A' AND ISNULL(@spkNo, '') = '')
        BEGIN
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Generate SPK No: begin', @moduleId, @actionName, @functionId, 1, @currentUser)

            DECLARE
                @numberingPrefix VARCHAR(2),
                @numberingVariant VARCHAR(2),
                @spkNoCounter VARCHAR(4),
                @docNumbering VARCHAR(MAX)

            DECLARE @docNumberingMessage TABLE ( Severity VARCHAR(1), [Message] VARCHAR(MAX), GeneratedNo VARCHAR(MAX) )
            DECLARE @splittedSPKMonth TABLE ( No INT, Split VARCHAR(100) )

            SELECT @numberingPrefix = 'SP', @numberingVariant = 'PK'
            SELECT @docNumbering = dbo.GetNextDocNumbering(@numberingPrefix, @numberingVariant)
            INSERT INTO @docNumberingMessage
            SELECT
                (SELECT Split FROM dbo.SplitString(@docNumbering, '|') WHERE [No] = 2),
                (SELECT Split FROM dbo.SplitString(@docNumbering, '|') WHERE [No] = 3),
                (SELECT Split FROM dbo.SplitString(@docNumbering, '|') WHERE [No] = 1)

            IF (SELECT TOP 1 Severity FROM @docNumberingMessage) = 'E'
            BEGIN
                SET @message = (SELECT TOP 1 [Message] FROM @docNumberingMessage)
                RAISERROR(@message, 16, 1)
            END

            INSERT INTO @splittedSPKMonth
            SELECT No, Split FROM dbo.SplitString('I,II,III,IV,V,VI,VII,VIII,IX,X,XI,XII', ',')
            SELECT @spkNoCounter = RTRIM(LTRIM((SELECT TOP 1 GeneratedNo FROM @docNumberingMessage)))
            SELECT @spkNo = 'SPK/' + @spkNoCounter + '/E/' + (SELECT Split FROM @splittedSPKMonth WHERE No = MONTH(@spkDate)) + '/' + CAST(YEAR(@spkDate) AS VARCHAR)
            SET @message = 'I|Generated SPK No: ' + @spkNo
            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

            -- Reserve SPKNo
            UPDATE TB_M_DOC_NUMBERING SET CURRENT_NUMBER = @spkNoCounter
            WHERE NUMBERING_PREFIX = 'SP' AND VARIANT = 'PK'

            INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INF', 'INF', 'I|Generate SPK No: end', @moduleId, @actionName, @functionId, 1, @currentUser)
        END

        DECLARE
            @divisionId VARCHAR(50),
            @divisionName VARCHAR(50),
            @departmentId VARCHAR(50),
            @sectionId VARCHAR(50),
            @orgId VARCHAR(50),
            @orgTitle VARCHAR(100),
            @directorateId VARCHAR(50),
            @personnelName VARCHAR(100),
            @positionLevel VARCHAR(100)

        SELECT
            @divisionId = DIVISION_ID,
            @divisionName = DIVISION_NAME,
            @departmentId = DEPARTMENT_ID,
            @sectionId = SECTION_ID,
            @orgId = ORG_ID,
            @orgTitle = ORG_TITLE,
            @directorateId = DIRECTORATE_ID,
            @personnelName = PERSONNEL_NAME,
            @positionLevel = POSITION_LEVEL
        FROM TB_R_SYNCH_EMPLOYEE
        WHERE NOREG = @currentUserNoReg AND GETDATE() BETWEEN VALID_FROM AND VALID_TO

        DECLARE @orgRef TABLE ( OrgId VARCHAR(10), OrgName VARCHAR(50) )
        INSERT INTO @orgRef VALUES
        (@sectionId, 'SectionId'),
        (@departmentId, 'DepartmentId'),
        (@divisionId, 'DivisionId'),
        (@directorateId, 'DirectorateId')

        DECLARE @signerName VARCHAR(50), @signerTitle VARCHAR(50)
        IF ISNULL(@spkAmount, 0) > 0 AND @spkAmount >= 1000000000
        BEGIN
            SELECT TOP 1
                @signerName = dbo.TitleCase(se.PERSONNEL_NAME),
                @signerTitle = dbo.TitleCase(op.POSITION_DESC)
            FROM dbo.TB_R_SYNCH_EMPLOYEE se
            JOIN dbo.TB_M_ORG_POSITION op ON se.POSITION_LEVEL = op.POSITION_LEVEL
            WHERE se.ORG_ID IN (SELECT OrgId FROM @orgRef GROUP BY OrgId)
            AND op.LEVEL_ID IN (0, 1) -- NOTE: Director or BOD
            ORDER BY op.LEVEL_ID DESC, se.POSITION_LEVEL ASC
        END
        IF ISNULL(@spkAmount, 0) > 0 AND @spkAmount < 1000000000
        BEGIN
            SELECT TOP 1
                @signerName = dbo.TitleCase(se.PERSONNEL_NAME),
                @signerTitle = dbo.TitleCase(op.POSITION_DESC)
            FROM dbo.TB_R_SYNCH_EMPLOYEE se
            JOIN dbo.TB_M_ORG_POSITION op ON se.POSITION_LEVEL = op.POSITION_LEVEL
            WHERE se.ORG_ID IN (SELECT OrgId FROM @orgRef GROUP BY OrgId)
            AND op.LEVEL_ID = 2 -- NOTE: DH
            ORDER BY op.LEVEL_ID DESC, se.POSITION_LEVEL ASC
        END

        IF (@editMode = 'A')
        BEGIN
            INSERT INTO TB_R_URGENT_SPK
            (PR_NO, PO_NO, SPK_NO, SPK_DT, SPK_BIDDING_DT, SPK_WORK_DESC, SPK_LOCATION, SPK_AMOUNT, SPK_PERIOD_START, SPK_PERIOD_END,
            SPK_RETENTION, SPK_TERMIN_I, SPK_TERMIN_I_DESC, SPK_TERMIN_II, SPK_TERMIN_II_DESC, SPK_TERMIN_III, SPK_TERMIN_III_DESC,
            SPK_TERMIN_IV, SPK_TERMIN_IV_DESC, SPK_TERMIN_V, SPK_TERMIN_V_DESC, SPK_SIGN, SPK_SIGN_NAME, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT,
            VENDOR_CD, VENDOR_NAME, VENDOR_ADDRESS, POSTAL_CODE, CITY)
            VALUES (@prNo, @poNo, @spkNo, @spkDate, @biddingDate, @spkWork, @spkLocation, @spkAmount, @spkPeriodStart, @spkPeriodEnd,
                @spkRetention, @terminI, @terminIDesc, @terminII, @terminIIDesc, @terminIII, @terminIIIDesc, @terminIV, @terminIVDesc,
                @terminV, @terminVDesc, @signerTitle, @signerName, @currentUser, GETDATE(), NULL, NULL, @vendorCode, @vendorName, @vendorAddress, @vendorPostal, @vendorCity)
        END
        ELSE
        BEGIN
            UPDATE TB_R_URGENT_SPK
            SET SPK_BIDDING_DT = @biddingDate, SPK_WORK_DESC = @spkWork,
            SPK_LOCATION = @spkLocation, SPK_AMOUNT = @spkAmount, SPK_PERIOD_START = @spkPeriodStart,
            SPK_PERIOD_END = @spkPeriodEnd, SPK_RETENTION = @spkRetention, SPK_TERMIN_I = @terminI,
            SPK_TERMIN_I_DESC = @terminIDesc, SPK_TERMIN_II = @terminII, SPK_TERMIN_II_DESC = @terminIIDesc,
            SPK_TERMIN_III = @terminIII, SPK_TERMIN_III_DESC = @terminIIIDesc, SPK_TERMIN_IV = @terminIV,
            SPK_TERMIN_IV_DESC = @terminIVDesc, SPK_TERMIN_V = @terminV, SPK_TERMIN_V_DESC = @terminVDesc,
            SPK_SIGN = @signerTitle, SPK_SIGN_NAME = @signerName, CHANGED_BY = @currentUser, CHANGED_DT = GETDATE(),
            VENDOR_CD = @vendorCode, VENDOR_NAME = @vendorName, VENDOR_ADDRESS = @vendorAddress, POSTAL_CODE = @vendorPostal, CITY = @vendorCity
            WHERE PR_NO = @prNo AND SPK_NO = @spkNo
        END

        -- Update SPK in PO if PO has been created
        IF (@poNo <> '')
        BEGIN
            UPDATE TB_R_PO_H
            SET SPK_BIDDING_DT = @biddingDate, SPK_WORK_DESC = @spkWork,
            SPK_LOCATION = @spkLocation, SPK_AMOUNT = @spkAmount, SPK_PERIOD_START = @spkPeriodStart,
            SPK_PERIOD_END = @spkPeriodEnd, SPK_RETENTION = @spkRetention, SPK_TERMIN_I = @terminI,
            SPK_TERMIN_I_DESC = @terminIDesc, SPK_TERMIN_II = @terminII, SPK_TERMIN_II_DESC = @terminIIDesc,
            SPK_TERMIN_III = @terminIII, SPK_TERMIN_III_DESC = @terminIIIDesc, SPK_TERMIN_IV = @terminIV,
            SPK_TERMIN_IV_DESC = @terminIVDesc, SPK_TERMIN_V = @terminV, SPK_TERMIN_V_DESC = @terminVDesc,
            SPK_SIGN = @signerTitle, SPK_SIGN_NAME = @signerName, CHANGED_BY = @currentUser, CHANGED_DT = GETDATE(),
            VENDOR_CD = @vendorCode, VENDOR_NAME = @vendorName, VENDOR_ADDRESS = @vendorAddress, POSTAL_CODE = @vendorPostal, CITY = @vendorCity
            WHERE PO_NO = @poNo
        END

        -- Always archive
        INSERT INTO dbo.TB_H_SPK
        (PROCESS_ID, PR_NO, PO_NO, SPK_NO, SPK_DT, SPK_BIDDING_DT, SPK_WORK_DESC, SPK_LOCATION, SPK_AMOUNT, SPK_PERIOD_START, SPK_PERIOD_END,
        SPK_RETENTION, SPK_TERMIN_I, SPK_TERMIN_I_DESC, SPK_TERMIN_II, SPK_TERMIN_II_DESC, SPK_TERMIN_III, SPK_TERMIN_III_DESC,
        SPK_TERMIN_IV, SPK_TERMIN_IV_DESC, SPK_TERMIN_V, SPK_TERMIN_V_DESC, SPK_SIGN, SPK_SIGN_NAME, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT)
        VALUES (@processId, @prNo, @poNo, @spkNo, @spkDate, @biddingDate, @spkWork, @spkLocation, @spkAmount, @spkPeriodStart, @spkPeriodEnd,
            @spkRetention, @terminI, @terminIDesc, @terminII, @terminIIDesc, @terminIII, @terminIIIDesc, @terminIV, @terminIVDesc,
            @terminV, @terminVDesc, @signerTitle, @signerName, @currentUser, GETDATE(), NULL, NULL)

        COMMIT TRAN SaveData

        SET @message = 'S|Finish: ' + CASE @editMode WHEN 'A' THEN 'Add' ELSE 'Edit' END
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SUC', 'SUC', @message, @moduleId, @actionName, @functionId, 2, @currentUser)
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN SaveData
        SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)
    END CATCH

    EXEC sp_putLog_Temp @tmpLog
    SET NOCOUNT OFF
    SELECT @spkNo SPKNo, @message [Message]
END