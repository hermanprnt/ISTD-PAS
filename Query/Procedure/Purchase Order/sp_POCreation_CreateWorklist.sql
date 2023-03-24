-- =============================================
-- Author:        FID)Reggy
-- Create date: 3/19/2015
-- Description:    Do Insert Workflow

-- Modified By: FID.Intan Puspitasari
-- Modified Dt: 06/11/2015
-- Description: Change Data Reference 
-- =============================================
CREATE PROCEDURE [dbo].[sp_POCreation_CreateWorklist] 
    @PO_NO varchar(12),
    @PROCESS_ID bigint,
    @USER_ID varchar(20),
    @DIVISION_ID int,
    @NOREG VARCHAR(15),
    @EDIT_FLAG VARCHAR(1), 
    @STATUS VARCHAR(MAX) OUTPUT
AS
BEGIN
DECLARE @WRK_PO_ITEM_NO INT = 1,
        @WRK_VAL_CLASS VARCHAR(10),
        @WRK_AMOUNT DECIMAL(18,2),
        @WRK_LAST_AMOUNT DECIMAL(18,2),
        @WRK_SUM_AMOUNT DECIMAL(18,2),
        @WRK_NEW_FLAG VARCHAR(1),
        @WRK_DELETE_FLAG VARCHAR(1),
        @WRK_EDITOR_STATUS VARCHAR(2),
        @WRK_PO_NEXT_STATUS VARCHAR(2),
        @WRK_DO_CREATE INT,
        @WRK_WBS_NO VARCHAR(50),
        @STATUS_DESC VARCHAR(50),
        @WRK_APPROVAL_CD CHAR(2),
        @WRK_APPROVAL_INTERVAL INT,
        @APPROVED_DT DATE,
        @WRK_COUNT INT

DECLARE @WRK_APPROVER_POSITION INT,
        @WRK_REGISTERED_USER VARCHAR(200),
        @WRK_PERSONNEL_NAME VARCHAR(100),
        @WRK_ORG_ID INT,
        @WRK_ORG_TITLE VARCHAR(200)
    
DECLARE @DOCUMENT_SEQ INT = 1,
        @TB_T_APPROVAL_CD APPROVAL_TEMP,
        @TB_TMP_LOG LOG_TEMP, --LOGGING TEMP. TABLE
        @MSG VARCHAR(MAX), --LOGGING MESSAGE
        @MSG_ID VARCHAR(12),
        @MODULE VARCHAR(3) = '3',
        @FUNCTION VARCHAR(5) = '301001',
        @LOCATION VARCHAR(50) = 'Create Worklist'

DECLARE @ORG TABLE (
            ORG_ID INT,
            ORG_NAME VARCHAR(50)
        )

    SET NOCOUNT ON;

    BEGIN TRY
        SET @MSG = 'Create Worklist for Document No. ' + @PO_NO + ' Started'
        SET @MSG_ID = 'MSG0000040'
        INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
        EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID, @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
        SET @STATUS = 'SUCCESS'
    END TRY
    BEGIN CATCH
        SET @MSG = 'Create Worklist for Document No. ' + @PO_NO + ' Failed'
        SET @MSG_ID = 'MSG0000041'
        INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
        EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

        SET @MSG = ERROR_MESSAGE()
        SET @MSG_ID = 'EXCEPTION'
        INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
        EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

        SET @STATUS = 'FAILED'
    END CATCH

    IF(@STATUS = 'SUCCESS')
    BEGIN
        -- checkpoint 1
        SELECT 
                @WRK_APPROVER_POSITION = POSITION_LEVEL, 
                @WRK_PERSONNEL_NAME = PERSONNEL_NAME, 
                @WRK_REGISTERED_USER = NOREG, 
                @WRK_ORG_ID = ORG_ID, 
                @WRK_ORG_TITLE = ORG_TITLE
        FROM TB_R_SYNCH_EMPLOYEE
        WHERE 
             GETDATE() BETWEEN VALID_FROM AND VALID_TO AND 
             NOREG =  @NOREG

        INSERT INTO @ORG
        SELECT ORG_ID, ORG_NAME FROM(
                SELECT DEPARTMENT_ID, DIVISION_ID, SECTION_ID, DIRECTORATE_ID from 
                TB_R_SYNCH_EMPLOYEE WHERE NOREG = @NOREG AND GETDATE() BETWEEN VALID_FROM AND VALID_TO
        ) SE
        UNPIVOT
        (
          ORG_ID
          for [ORG_NAME] in (SECTION_ID, DEPARTMENT_ID, DIVISION_ID, DIRECTORATE_ID) 
        ) UnpivotTable;


        SELECT @WRK_SUM_AMOUNT = SUM(ISNULL(NEW_LOCAL_AMOUNT, 0)) FROM TB_T_PR_ITEM WHERE PROCESS_ID = @PROCESS_ID
        /*DECLARE worklist_cursor CURSOR FOR
            SELECT  A.VALUATION_CLASS, 
                    A.ITEM_NO, 
                    A.PR_NEXT_STATUS,
                    ISNULL(A.ORI_LOCAL_AMOUNT,0),
                    ISNULL(A.NEW_LOCAL_AMOUNT,0), 
                    A.NEW_FLAG, 
                    A.DELETE_FLAG, 
                    A.WBS_NO
            FROM TB_T_PR_ITEM A WHERE A.PROCESS_ID = @PROCESS_ID ORDER BY A.VALUATION_CLASS ASC
        OPEN worklist_cursor
        FETCH NEXT FROM worklist_cursor 
                    INTO 
                        @WRK_VAL_CLASS,
                        @WRK_PO_ITEM_NO,
                        @WRK_PO_NEXT_STATUS, 
                        @WRK_LAST_AMOUNT, 
                        @WRK_AMOUNT, 
                        @WRK_NEW_FLAG, 
                        @WRK_DELETE_FLAG, 
                        @WRK_WBS_NO
            WHILE @@FETCH_STATUS = 0
            BEGIN*/
                IF(@EDIT_FLAG = 'Y')
                BEGIN
                    SELECT TOP 1 
                        @WRK_EDITOR_STATUS = ISNULL(APPROVAL_CD,'0') 
                    FROM TB_R_WORKFLOW 
                    WHERE STRUCTURE_ID = @WRK_ORG_ID AND 
                          APPROVER_POSITION = @WRK_APPROVER_POSITION AND 
                          DOCUMENT_NO = @PO_NO AND 
                          ITEM_NO = @WRK_PO_ITEM_NO
                END

                IF(ISNULL(@WRK_DELETE_FLAG, 'N') = 'N')
                BEGIN
                    IF ((@EDIT_FLAG = 'Y') AND (ISNULL(@WRK_NEW_FLAG, 'N') = 'N'))
                    BEGIN
                        IF(@WRK_AMOUNT > @WRK_LAST_AMOUNT)
                        BEGIN
                            SET @MSG = 'New Amount For Document No ' + @PO_NO + ' and Item No ' + CONVERT(VARCHAR,@WRK_PO_ITEM_NO) + 
                                          ' Larger than Previous Amount'
                            SET @MSG_ID = 'MSG0000043'
                            INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
                            EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

                            SET @MSG = 'Editor Status For Document No ' + @PO_NO + ' and Item No ' + CONVERT(VARCHAR,@WRK_PO_ITEM_NO) + 
                                          ' is ' + @WRK_EDITOR_STATUS 
                            SET @MSG_ID = 'MSG0000044'
                            INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
                            EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

                            IF(@WRK_EDITOR_STATUS <> '40')
                            BEGIN
                                IF(CONVERT(INT,@WRK_EDITOR_STATUS) = CONVERT(INT,@WRK_PO_NEXT_STATUS))
                                BEGIN
                                    SET @WRK_DO_CREATE = 1 --SET IS_DISPLAY STATUS
                                END
                                ELSE --IF(CONVERT(INT,@WRK_EDITOR_STATUS) < CONVERT(INT,@WRK_PO_NEXT_STATUS))
                                BEGIN
                                    SET @WRK_DO_CREATE = 0 --DELETE INSERT WORKFLOW
                                END
                            END
                            ELSE
                            BEGIN
                                SET @WRK_DO_CREATE = 0 --DELETE INSERT WORKFLOW
                            END
                        END
                        ELSE
                        BEGIN 
                            SET @MSG = 'New Amount For Document No ' + @PO_NO + ' and Item No ' + 
                                          CONVERT(VARCHAR,@WRK_PO_ITEM_NO) + ' Smaller than / Equal Previous Amount'
                            SET @MSG_ID = 'MSG0000045'
                            INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
                            EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

                            SET @WRK_DO_CREATE = 1 --SET IS_DISPLAY STATUS
                        END
                    END
                    ELSE
                    BEGIN
                        SET @WRK_DO_CREATE = 2 --CREATE WORKFLOW
                    END
                END
                ELSE
                BEGIN
                    SET @WRK_DO_CREATE = 99 --DELETE EXISTING WORKLIST AND DO NOTHING

                    BEGIN TRY
                        SET @MSG = 'Delete Worklist for Item No. ' + CONVERT(VARCHAR, @WRK_PO_ITEM_NO) + ' Started'
                        SET @MSG_ID = 'MSG0000046'
                        INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
                        EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

                            DELETE FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @PO_NO AND ITEM_NO = @WRK_PO_ITEM_NO

                        SET @MSG = 'Delete Worklist for Item No. ' + CONVERT(VARCHAR, @WRK_PO_ITEM_NO) + ' Success'
                        SET @MSG_ID = 'MSG0000047'
                        INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
                        EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
                    END TRY
                    BEGIN CATCH
                        SET @MSG = 'Delete Worklist for Item No. ' + CONVERT(VARCHAR, @WRK_PO_ITEM_NO) + ' Failed'
                        SET @MSG_ID = 'MSG0000048'
                        INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
                        EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

                        SET @MSG = ERROR_MESSAGE()
                        SET @MSG_ID = 'EXCEPTION'
                        INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
                        EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

                        SET @STATUS = 'FAILED'
                    END CATCH
                END

                IF(@WRK_DO_CREATE = 0)
                BEGIN
                    BEGIN TRY
                        SET @MSG = 'Delete Worklist Data From TB_R_WORKFLOW Started For Document No ' + @PO_NO + 
                                      ' and Item No ' + CONVERT(VARCHAR,@WRK_PO_ITEM_NO)
                        SET @MSG_ID = 'MSG0000049'
                        INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
                        EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

                            DELETE FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @PO_NO --AND ITEM_NO = @WRK_PO_ITEM_NO
                            
                            UPDATE TB_R_PO_ITEM SET PO_STATUS = '40', PO_NEXT_STATUS = '41' WHERE PO_NO = @PO_NO
                        
                            SET @WRK_DO_CREATE = 2 --INSERT WORKFLOW AFTER DELETE

                        SET @MSG = 'Delete Worklist Data From TB_R_WORKFLOW Success For Document No ' + @PO_NO + 
                                      ' and Item No ' + CONVERT(VARCHAR,@WRK_PO_ITEM_NO)
                        SET @MSG_ID = 'MSG0000050'
                        INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
                        EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
                    END TRY
                    BEGIN CATCH
                        SET @MSG = 'Delete Worklist Data From TB_R_WORKFLOW Failed For Document No ' + @PO_NO
                        SET @MSG_ID = 'MSG0000051'
                        INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
                        EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

                        SET @MSG = ERROR_MESSAGE()
                        SET @MSG_ID = 'EXCEPTION'
                        INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
                        EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

                        SET @STATUS = 'FAILED'
                    END CATCH
                END

                IF(@WRK_DO_CREATE = 1)
                BEGIN
                    BEGIN TRY
                        SET @MSG = 'Update Worklist Data To TB_R_WORKFLOW Started For Document No ' + @PO_NO + 
                                      ' and Item No ' + CONVERT(VARCHAR,@WRK_PO_ITEM_NO)
                        SET @MSG_ID = 'MSG0000052'
                        INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
                        EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
                    
                        EXEC [dbo].[sp_worklist_updateWorkflow] 
                                                    @PO_NO, 
                                                    @FUNCTION,
                                                    @WRK_PO_ITEM_NO, 
                                                    @WRK_SUM_AMOUNT, 
                                                    @USER_ID, 
                                                    @STATUS OUTPUT

                        SET @MSG = 'Update Worklist Data To TB_R_WORKFLOW Success For Document No ' + @PO_NO + 
                                      ' and Item No ' + CONVERT(VARCHAR,@WRK_PO_ITEM_NO)
                        SET @MSG_ID = 'MSG0000053'
                        INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
                        EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
                    END TRY
                    BEGIN CATCH
                        SET @MSG = 'Update Worklist Data To TB_R_WORKFLOW Failed For Document No ' + @PO_NO
                        SET @MSG_ID = 'MSG0000054'
                        INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
                        EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

                        SET @MSG = ERROR_MESSAGE()
                        SET @MSG_ID = 'EXCEPTION'
                        INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
                        EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

                        SET @STATUS = 'FAILED'
                        
                    END CATCH
                END

                IF(@WRK_DO_CREATE = 2)
                BEGIN
                    SET @MSG = 'Insert Worklist Data To TB_R_WORKFLOW Started For Document No ' + @PO_NO + 
                                  ' and Item No ' + CONVERT(VARCHAR,@WRK_PO_ITEM_NO)
                    SET @MSG_ID = 'MSG0000057'
                    INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
                    EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
            
                    BEGIN TRY
                        DELETE FROM @TB_T_APPROVAL_CD
                        INSERT INTO @TB_T_APPROVAL_CD 
                            SELECT SE.ORG_ID,
                                MIN(SE.POSITION_LEVEL),
                                '301002'
                                FROM TB_R_SYNCH_EMPLOYEE SE
                                    INNER JOIN TB_M_ORG_POSITION OP ON SE.POSITION_LEVEL = OP.POSITION_LEVEL
                                    INNER JOIN TB_M_SYSTEM TM ON TM.SYSTEM_CD = OP.LEVEL_ID AND TM.FUNCTION_ID = '301002'
                                WHERE SE.DIVISION_ID = @DIVISION_ID AND SE.ORG_ID IN 
                                    (SELECT ORG_ID FROM @ORG WHERE ISNULL(ORG_ID, '') <> '') 
                                GROUP BY SE.ORG_ID 

                        SELECT @STATUS_DESC = STATUS_DESC FROM TB_M_STATUS WHERE STATUS_CD = '40'
                        SET @WRK_APPROVAL_INTERVAL = 1 --APPROVAL_INTERVAL FROM TB_M_VALUATION_CLASS WHERE VALUATION_CLASS = @WRK_VAL_CLASS
                        SELECT @DOCUMENT_SEQ = ISNULL(DOCUMENT_SEQ, 0) + 1 FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @PO_NO AND ITEM_NO = @WRK_PO_ITEM_NO

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
                            SELECT  @PO_NO,
                                    @WRK_PO_ITEM_NO,
                                    @DOCUMENT_SEQ,
                                    '40',
                                    @STATUS_DESC,
                                    @WRK_REGISTERED_USER,
                                    @NOREG,
                                    GETDATE(),
                                    @WRK_ORG_ID, 
                                    @WRK_ORG_TITLE,
                                    @WRK_APPROVER_POSITION,
                                    'N' AS IS_APPROVED,
                                    'N' AS IS_REJECTED,
                                    'Y' AS IS_DISPLAY,
                                    'N' AS LIMIT_FLAG,
                                    'N' AS MAX_AMOUNT,
                                    @USER_ID AS CREATED_BY,
                                    GETDATE() AS CREATED_DT,
                                    1,
                                    @WRK_PERSONNEL_NAME,
                                    'N'
                                    
                        IF((SELECT COUNT(*) FROM @TB_T_APPROVAL_CD) > 0)
                        BEGIN
                            EXEC [dbo].[sp_worklist_doinsertWorkflow] 
                                            @USER_ID,
                                            @PO_NO, 
                                            @WRK_PO_ITEM_NO, 
                                            @WRK_SUM_AMOUNT, 
                                            @WRK_APPROVAL_INTERVAL, 
                                            @TB_T_APPROVAL_CD, 
                                            @STATUS OUTPUT

                            SET @MSG = 'Insert Worklist Data To TB_R_WORKFLOW Success For Document No ' + @PO_NO + 
                                       ' And Item No ' + CONVERT(VARCHAR,@WRK_PO_ITEM_NO)
                            SET @MSG_ID = 'MSG0000060'
                            INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
                            EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
                        END
                        ELSE
                        BEGIN
                            SET @MSG = 'End User Approval CD with ORG ID ' + CONVERT(VARCHAR,@WRK_ORG_ID) + 
                                       ' Cannot be found in TB_M_APPROVAL_GROUP'
                            RAISERROR(@MSG, 16, 1)
                        END
                    END TRY
                    BEGIN CATCH
                        SET @MSG = 'Insert Worklist Data To TB_R_WORKFLOW Failed For Document No ' + @PO_NO + ' And Item No ' + CONVERT(VARCHAR,@WRK_PO_ITEM_NO)
                        SET @MSG_ID = 'MSG0000061'
                        INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
                        EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

                        SET @MSG = ERROR_MESSAGE()
                        SET @MSG_ID = 'EXCEPTION'
                        INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
                        EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

                        SET @STATUS = 'FAILED'
                        
                    END CATCH
                END

                SELECT @WRK_COUNT = COUNT(*) FROM TB_R_WORKFLOW 
                        WHERE DOCUMENT_NO = @PO_NO AND 
                                STRUCTURE_ID = @DIVISION_ID AND 
                                SUBSTRING(APPROVAL_CD, 1, 1) = '2'
                IF((@WRK_COUNT > 0) AND (@STATUS = 'SUCCESS'))
                BEGIN
                    BEGIN TRY
                        SET @MSG = 'Structure ID of BC DH is same with User Division ID ' + CONVERT(VARCHAR, @DIVISION_ID) + 
                                   ', BC Will Not Displayed'
                        SET @MSG_ID = 'MSG0000064'
                        INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
                        EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
                        
                            UPDATE TB_R_WORKFLOW SET IS_DISPLAY = 'N' 
                                WHERE SUBSTRING(APPROVAL_CD, 1, 1) = '2' AND 
                                        DOCUMENT_NO = @PO_NO
                    END TRY
                    BEGIN CATCH
                        SET @MSG = 'Update BC Display Status Failed'
                        SET @MSG_ID = 'MSG0000065'
                        INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
                        EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

                        SET @MSG = ERROR_MESSAGE()
                        SET @MSG_ID = 'EXCEPTION'
                        INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
                        EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

                        SET @STATUS = 'FAILED'
                        
                    END CATCH
                END

                /*FETCH NEXT FROM worklist_cursor
                            INTO 
                                @WRK_VAL_CLASS,
                                @WRK_PO_ITEM_NO,
                                @WRK_PO_NEXT_STATUS, 
                                @WRK_LAST_AMOUNT, 
                                @WRK_AMOUNT, 
                                @WRK_NEW_FLAG, 
                                @WRK_DELETE_FLAG, 
                                @WRK_WBS_NO
            END
        CLOSE worklist_cursor
        DEALLOCATE worklist_cursor*/
    END

    IF(@STATUS = 'SUCCESS')
    BEGIN
        BEGIN TRY
            SET @MSG = 'Get Approver Data from HR.Portal for Document No. ' + @PO_NO + ' Started'
            SET @MSG_ID = 'MSG0000066'
            INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
            EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
            
            EXEC [dbo].[sp_worklist_getApprovalData] @PO_NO

            SET @MSG = 'Get Approver Data from HR.Portal for Document No. ' + @PO_NO + ' Success'
            SET @MSG_ID = 'MSG0000067'
            INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
            EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
        END TRY
        BEGIN CATCH
            SET @MSG = 'Get Approver Data from HR.Portal for Document No ' + @PO_NO
            SET @MSG_ID = 'MSG0000068'
            INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
            EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

            SET @MSG = ERROR_MESSAGE()
            SET @MSG_ID = 'EXCEPTION'
            INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
            EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

            SET @STATUS = 'FAILED'
        END CATCH
    END

    IF(@STATUS = 'SUCCESS')
    BEGIN
        DECLARE item_cursor CURSOR FOR
            SELECT DISTINCT ITEM_NO FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @PO_NO ORDER BY ITEM_NO ASC
        OPEN item_cursor
        FETCH NEXT FROM item_cursor INTO @WRK_PO_ITEM_NO
            WHILE @@FETCH_STATUS = 0
            BEGIN
                SELECT @APPROVED_DT = APPROVED_DT FROM TB_R_WORKFLOW 
                WHERE DOCUMENT_NO = @PO_NO AND ITEM_NO = @WRK_PO_ITEM_NO AND DOCUMENT_SEQ = 1

                BEGIN TRY
                    SET @MSG = 'Calculate Interval Started for Document No ' + @PO_NO + ' And Item No ' + CONVERT(VARCHAR, @WRK_PO_ITEM_NO)
                    SET @MSG_ID = 'MSG000069'
                    INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
                    EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

                    EXEC [dbo].[sp_worklist_calculateInterval] 
                                            @PO_NO, 
                                            @WRK_PO_ITEM_NO, 
                                            @APPROVED_DT, 
                                            1

                    SET @MSG = 'Calculate Interval Success for Document No ' + @PO_NO + ' And Item No ' + CONVERT(VARCHAR, @WRK_PO_ITEM_NO)
                    SET @MSG_ID = 'MSG0000070'
                    INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
                    EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
                END TRY
                BEGIN CATCH    
                    SET @MSG = 'Calculate Interval Failed For Document No ' + @PO_NO
                    SET @MSG_ID = 'MSG0000071'
                    INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
                    EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

                    SET @MSG = ERROR_MESSAGE() 
                    SET @MSG_ID = 'EXCEPTION'
                    INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
                    EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;
                    
                    SET @STATUS = 'FAILED'
                    
                END CATCH    
                FETCH NEXT FROM item_cursor INTO @WRK_PO_ITEM_NO
            END
        CLOSE item_cursor
        DEALLOCATE item_cursor
    END

    IF(@STATUS = 'SUCCESS')
    BEGIN
        BEGIN TRY
            SET @MSG = 'Checking Approval Bypass For Document No ' + @PO_NO + ' Started'
            SET @MSG_ID = 'MSG0000072'
            INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
            EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
        
            EXEC [dbo].[sp_worklist_bypassChecking] 
                                @PO_NO, 
                                'PR', 
                                @PROCESS_ID, 
                                @USER_ID, 
                                @WRK_ORG_ID, 
                                @WRK_APPROVER_POSITION, 
                                @STATUS OUTPUT

            SET @MSG = 'Checking Approval Bypass For Document No ' + @PO_NO + ' Success'
            SET @MSG_ID = 'MSG0000073'
            INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
            EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
        END TRY
        BEGIN CATCH
            SET @MSG = 'Checking Approval Bypass For Document No ' + @PO_NO + ' Failed'
            SET @MSG_ID = 'MSG0000074'
            INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
            EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

            SET @MSG = ERROR_MESSAGE()
            SET @MSG_ID = 'EXCEPTION'
            INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
            EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

            SET @STATUS = 'FAILED'
        END CATCH
    END

    IF(@STATUS = 'SUCCESS')
    BEGIN
        SET @MSG = 'Insert Worklist Success For Document No. ' + @PO_NO
        SET @MSG_ID = 'MSG0000076'
        INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
        EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
    END
    --ELSE
    --BEGIN
    --    SET @MSG = 'Insert Worklist Failed For Document No. ' + @PO_NO
    --    SET @MSG_ID = 'MSG0000075'
    --    INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
    --    EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;
    --END

SELECT PROCESS_ID, PROCESS_TIME, MESSAGE_ID, MESSAGE_TYPE, MESSAGE_DESC, MODULE_ID, MODULE_DESC, FUNCTION_ID, STATUS_ID, [USER_NAME] FROM @TB_TMP_LOG
END


