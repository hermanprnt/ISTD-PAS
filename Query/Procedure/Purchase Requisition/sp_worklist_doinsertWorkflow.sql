/****** Object:  StoredProcedure [dbo].[sp_worklist_doinsertWorkflow]    Script Date: 12/18/2015 2:53:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:        FID)Reggy
-- Create date: 3/19/2015
-- Description:    Do Insert Workflow

-- Modified By: FID.Intan Puspitasari
-- Modified Dt: 06/11/2015
-- Description: Change data reference
-- =============================================
ALTER PROCEDURE [dbo].[sp_worklist_doinsertWorkflow] 
    @USER_ID VARCHAR(20),
    @DOCUMENT_NO VARCHAR(11), --DOCUMENT_NO
    @ITEM_NO VARCHAR(5), --ITEM_NO
    @AMOUNT DECIMAL(18,2), --SUM AMOUNT
    @APPROVAL_INTERVAL INT, --DAY INTERVAL FOR APPROVAL FROM TB_M_VALUATION_CLASS
    @TB_T_APPROVAL_CD APPROVAL_TEMP READONLY, --CONTAIN ORG_ID, POSITION, AND FUNCTION_ID
    @STATUS VARCHAR(MAX) OUTPUT
AS
BEGIN
    DECLARE @DOCUMENT_SEQ INT,
        @MAX_AMOUNT VARCHAR(15),
        @STATUS_CD VARCHAR(2),
        @STATUS_DESC VARCHAR(50),
        @ORG_ID VARCHAR(11),
        @POSITION_LEVEL INT,
        @LEVEL_ID INT,
        @FUNCTION_ID VARCHAR(6),
        @MSG VARCHAR(MAX)

    SET NOCOUNT ON;

	DECLARE @ORG_ID_TEMP VARCHAR(11),
			@ORG_NAME VARCHAR(80)

    DECLARE segment_cursor CURSOR FOR
        SELECT 
            ORG_ID,
            POSITION_LEVEL, 
            FUNCTION_ID
        FROM @TB_T_APPROVAL_CD ORDER BY FUNCTION_ID ASC, POSITION_LEVEL DESC
    OPEN segment_cursor
    FETCH NEXT FROM segment_cursor 
            INTO 
                @ORG_ID, 
                @POSITION_LEVEL,
                @FUNCTION_ID
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            IF(@FUNCTION_ID = '203001' OR @FUNCTION_ID = '203002' OR @FUNCTION_ID = '301002') -- FOR PR, DIVISION CREATOR
            BEGIN
                SELECT @LEVEL_ID = LEVEL_ID FROM TB_M_ORG_POSITION WHERE POSITION_LEVEL = @POSITION_LEVEL
                SELECT @STATUS_CD = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE FUNCTION_ID = @FUNCTION_ID AND SYSTEM_CD = @LEVEL_ID
            END
            ELSE
            BEGIN
                SELECT @STATUS_CD = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE FUNCTION_ID = @FUNCTION_ID AND SYSTEM_CD = @POSITION_LEVEL
            END

            SELECT @DOCUMENT_SEQ = ISNULL(MAX(DOCUMENT_SEQ), 0) + 1 FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @DOCUMENT_NO AND ITEM_NO = @ITEM_NO
            SELECT @STATUS_DESC = STATUS_DESC FROM TB_M_STATUS WHERE STATUS_CD = @STATUS_CD AND POSITION_ID = @POSITION_LEVEL
            
			IF(SUBSTRING(@FUNCTION_ID, 1, 2) = '20')
			BEGIN
				SELECT @MAX_AMOUNT = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'XPRAMT' AND SYSTEM_CD IN(SELECT POSITION_LEVEL FROM TB_M_ORG_POSITION WHERE LEVEL_ID = @LEVEL_ID)
            END
			ELSE
			BEGIN
				SELECT @MAX_AMOUNT = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'XPOAMT' AND SYSTEM_CD IN(SELECT POSITION_LEVEL FROM TB_M_ORG_POSITION WHERE LEVEL_ID = @LEVEL_ID)
			END
			
			--Note : For Segment 2 and 3 using noreg from TB_M_COORDINATOR in APPROVAL_TEMP, not ORG_ID
			DECLARE @NOREG VARCHAR(8)
			IF(@FUNCTION_ID = '203002')
			BEGIN
				SET @NOREG = @ORG_ID
				SELECT TOP 1 @ORG_ID_TEMP = ORG_ID FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = @NOREG AND GETDATE() BETWEEN VALID_FROM AND VALID_TO
			END

			IF(@FUNCTION_ID = '203003')
			BEGIN
				SET @NOREG = @ORG_ID
				--SELECT TOP 1 @ORG_ID = ORG_ID FROM TB_R_SYNCH_EMPLOYEE WHERE NOREG = @NOREG AND GETDATE() BETWEEN VALID_FROM AND VALID_TO
				SELECT TOP 1 @ORG_ID_TEMP = CM.ORG_ID FROM TB_M_COORDINATOR_MAPPING CM
					INNER JOIN TB_M_COORDINATOR C ON C.COORDINATOR_CD = CM.COORDINATOR_CD AND C.COOR_FUNCTION = 'FD'
				WHERE NOREG = @NOREG
			END

			SELECT @MAX_AMOUNT = CASE WHEN(@STATUS_CD = '20') THEN '0' ELSE ISNULL(@MAX_AMOUNT, '0') END

            INSERT INTO TB_R_WORKFLOW
            (
                DOCUMENT_NO,
                ITEM_NO,
                DOCUMENT_SEQ,
                APPROVAL_CD,
                APPROVAL_DESC,
                APPROVED_BY,
                NOREG,
                APPROVED_DT,
                STRUCTURE_ID,
                STRUCTURE_NAME,
                APPROVER_POSITION,
                IS_APPROVED,
                IS_REJECTED,
                IS_DISPLAY,
                LIMIT_FLAG,
                MAX_AMOUNT,
                CREATED_BY,
                CREATED_DT,
                APPROVAL_INTERVAL,
                APPROVER_NAME,
                RELEASE_FLAG
            )
            SELECT
                @DOCUMENT_NO,
                @ITEM_NO,
                @DOCUMENT_SEQ,
                @STATUS_CD,
                @STATUS_DESC,
                CASE WHEN(@STATUS_CD = '20' AND @ORG_ID = 0) THEN '-' ELSE (CASE WHEN(@FUNCTION_ID = '203002' OR @FUNCTION_ID = '203003') THEN @NOREG ELSE 'N' END) END AS APPROVAL_BY,
                CASE WHEN(@STATUS_CD = '20' AND @ORG_ID = 0) THEN '-' ELSE (CASE WHEN(@FUNCTION_ID = '203002' OR @FUNCTION_ID = '203003') THEN @NOREG ELSE 'N' END) END AS NOREG,
                NULL AS APPROVED_DT,
                ISNULL(@ORG_ID_TEMP, @ORG_ID) AS STRUCTURE_ID,
                'N' AS STRUCTURE_NAME,
                @POSITION_LEVEL,
                'N' AS IS_APPROVED,
                'N' AS IS_REJECTED,
				CASE WHEN (@FUNCTION_ID = '203001') THEN (
					CASE WHEN(@AMOUNT > @MAX_AMOUNT)
							THEN 'Y'
							ELSE 'N' END
					) 
					ELSE 'Y' END AS IS_DISPLAY,
                CASE WHEN(@MAX_AMOUNT = 0)
                        THEN 'N'
                        ELSE 'Y' END AS LIMIT_FLAG,
                @MAX_AMOUNT,
                @USER_ID,
                GETDATE(),
                @APPROVAL_INTERVAL,
                CASE WHEN(@STATUS_CD = '20' AND @ORG_ID = 0) THEN '-' ELSE 'N' END AS APPROVER_NAME,
                'N' AS RELEASE_FLAG
        
            SET @STATUS = 'SUCCESS'
        END TRY
        BEGIN CATCH
            SET @STATUS = 'FAILED'
            SET @MSG = ERROR_MESSAGE()
            BREAK
        END CATCH

		SET @ORG_ID_TEMP = NULL
		SET @ORG_NAME = NULL

        FETCH NEXT FROM segment_cursor 
                INTO
                    @ORG_ID,
                    @POSITION_LEVEL, 
                    @FUNCTION_ID
    END
    CLOSE segment_cursor
    DEALLOCATE segment_cursor

    IF(@STATUS <> 'SUCCESS')
    BEGIN
        RAISERROR(@MSG, 16, 1)
    END
END