/****** Object:  StoredProcedure [dbo].[sp_prcreation_createWorklist]    Script Date: 8/28/2017 5:02:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		FID)Reggy
-- Create date: 3/19/2015
-- Description:	Do Insert Workflow

-- Modified By: FID.Intan Puspitasari
-- Modified Dt: 06/11/2015
-- Description: Change Data Reference 
-- =============================================

ALTER PROCEDURE [dbo].[sp_prcreation_createWorklist] 
	@PR_NO varchar(12),
	@PROCESS_ID bigint,
	@USER_ID varchar(20),
	@DIVISION_ID int,
	@NOREG VARCHAR(15),
	@EDIT_FLAG VARCHAR(1), --EDIT PR FLAG
	@PR_COORDINATOR VARCHAR(6),
	@STATUS VARCHAR(MAX) OUTPUT
AS
BEGIN
DECLARE @WRK_PR_ITEM_NO VARCHAR(5),
		@WRK_VAL_CLASS VARCHAR(10),
		@WRK_FD_GROUP_CD VARCHAR(4),
		@WRK_PR_COORDINATOR VARCHAR(6),
		@WRK_AMOUNT DECIMAL(18,2),
		@WRK_LAST_AMOUNT DECIMAL(18,2),
		@WRK_NEW_FLAG VARCHAR(1),
		@WRK_DELETE_FLAG VARCHAR(1),
		@WRK_SOURCE_TYPE VARCHAR(50),
		@WRK_MAT_NO VARCHAR(23),
		@WRK_EDITOR_STATUS VARCHAR(2),
		@WRK_PR_NEXT_STATUS VARCHAR(2),
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

DECLARE @UPDATE_FLAG CHAR(1),
		@NEW_FLAG CHAR(1),
		@DELETE_FLAG CHAR(1)
	
DECLARE @DOCUMENT_SEQ INT = 1,
		@TB_T_APPROVAL_CD APPROVAL_TEMP,
		@TB_TMP_LOG LOG_TEMP, --LOGGING TEMP. TABLE
		@MSG VARCHAR(MAX), --LOGGING MESSAGE
		@MSG_ID VARCHAR(12),
		@MODULE VARCHAR(3) = '2',
		@FUNCTION VARCHAR(5) = '201002',
		@LOCATION VARCHAR(50) = 'Create Worklist'

DECLARE @ORG TABLE (
			ORG_ID INT,
			ORG_NAME VARCHAR(50)
		)

	SET NOCOUNT ON;

	BEGIN TRY
		SET @MSG = 'Create Worklist for Document No. ' + @PR_NO + ' Started'
		SET @MSG_ID = 'MSG0000040'
		INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
		EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
		SET @STATUS = 'SUCCESS'
	END TRY
	BEGIN CATCH
		SET @MSG = 'Create Worklist for Document No. ' + @PR_NO + ' Failed'
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

		SELECT @WRK_AMOUNT = SUM(ISNULL(NEW_LOCAL_AMOUNT, 0)) FROM TB_T_PR_ITEM WHERE PROCESS_ID = @PROCESS_ID
		SELECT @WRK_LAST_AMOUNT = SUM(ISNULL(ORI_LOCAL_AMOUNT, 0)) FROM TB_T_PR_ITEM WHERE PROCESS_ID = @PROCESS_ID

		DECLARE worklist_cursor CURSOR FOR
			SELECT  A.VALUATION_CLASS, 
					A.ITEM_NO, 
					A.PR_NEXT_STATUS, 
					A.NEW_FLAG, 
					A.DELETE_FLAG, 
					A.WBS_NO,
					ISNULL(A.NEW_LOCAL_AMOUNT, 0),
					ISNULL(ORI_LOCAL_AMOUNT, 0),
					A.NEW_FLAG,
					A.UPDATE_FLAG,
					A.DELETE_FLAG,
					A.MAT_NO,
					A.SOURCE_TYPE
			FROM TB_T_PR_ITEM A WHERE A.PROCESS_ID = @PROCESS_ID ORDER BY A.VALUATION_CLASS ASC
		OPEN worklist_cursor
		FETCH NEXT FROM worklist_cursor 
					INTO 
						@WRK_VAL_CLASS,
						@WRK_PR_ITEM_NO,
						@WRK_PR_NEXT_STATUS, 
						@WRK_NEW_FLAG, 
						@WRK_DELETE_FLAG, 
						@WRK_WBS_NO,
						@WRK_AMOUNT,
						@WRK_LAST_AMOUNT,
						@NEW_FLAG,
						@UPDATE_FLAG,
						@DELETE_FLAG,
						@WRK_MAT_NO,
						@WRK_SOURCE_TYPE
			WHILE @@FETCH_STATUS = 0
			BEGIN
				--Note : if nothing changed with selected item, then passing the process
				IF(@NEW_FLAG = 'Y' OR @UPDATE_FLAG = 'Y' OR @DELETE_FLAG = 'Y')
				BEGIN
					IF(@EDIT_FLAG = 'Y')
					BEGIN
						SELECT TOP 1 
							@WRK_EDITOR_STATUS = ISNULL(APPROVAL_CD,'0') 
						FROM TB_R_WORKFLOW 
						WHERE STRUCTURE_ID = @WRK_ORG_ID AND 
							  APPROVER_POSITION = @WRK_APPROVER_POSITION AND 
							  DOCUMENT_NO = @PR_NO AND 
							  ITEM_NO = @WRK_PR_ITEM_NO
					END

					IF(ISNULL(@WRK_DELETE_FLAG, 'N') = 'N')
					BEGIN
						IF ((@EDIT_FLAG = 'Y') AND (ISNULL(@WRK_NEW_FLAG, 'N') = 'N'))
						BEGIN
							IF(@WRK_AMOUNT > @WRK_LAST_AMOUNT)
							BEGIN
								SET @MSG = 'New Amount For Document No ' + @PR_NO + ' and Item No ' + CONVERT(VARCHAR,@WRK_PR_ITEM_NO) + 
											  ' Larger than Previous Amount. New Amount : ' + CAST(@WRK_AMOUNT AS VARCHAR) + ' Previous Amount : ' + CAST(@WRK_LAST_AMOUNT AS VARCHAR) + ' Edit Flag : ' + @EDIT_FLAG
								SET @MSG_ID = 'MSG0000043'
								INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
								EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

								SET @MSG = 'Editor Status For Document No ' + @PR_NO + ' and Item No ' + CONVERT(VARCHAR,@WRK_PR_ITEM_NO) + 
											  ' is ' + @WRK_EDITOR_STATUS + ' New Amount : ' + CAST(@WRK_AMOUNT AS VARCHAR) + ' Last Amount : ' + CAST(@WRK_LAST_AMOUNT AS VARCHAR) + ' Edit Flag : ' + @EDIT_FLAG
								SET @MSG_ID = 'MSG0000044'
								INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
								EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

								IF(@WRK_EDITOR_STATUS <> '10')
								BEGIN
									IF(CONVERT(INT,@WRK_EDITOR_STATUS) = CONVERT(INT,@WRK_PR_NEXT_STATUS))
									BEGIN
										SET @WRK_DO_CREATE = 1 --SET IS_DISPLAY STATUS
									END
									ELSE --IF(CONVERT(INT,@WRK_EDITOR_STATUS) < CONVERT(INT,@WRK_PR_NEXT_STATUS))
									BEGIN
										SET @WRK_DO_CREATE = 0 --DELETE INSERT WORKFLOW
									END
								END
								ELSE
								BEGIN
									SET @WRK_DO_CREATE = 0 --DELETE INSERT WORKFLOW
								END
							END --end reset workflow
							ELSE
							BEGIN 
								SET @MSG = 'New Amount For Document No ' + @PR_NO + ' and Item No ' + 
											  CONVERT(VARCHAR,@WRK_PR_ITEM_NO) + ' Smaller than / Equal Previous Amount. New Amount : ' + CAST(@WRK_AMOUNT AS VARCHAR) + ' Last Amount : ' + CAST(@WRK_LAST_AMOUNT AS VARCHAR) + ' Edit Flag : ' + @EDIT_FLAG
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
							SET @MSG = 'Delete Worklist for Item No. ' + CONVERT(VARCHAR, @WRK_PR_ITEM_NO) + ' Started'
							SET @MSG_ID = 'MSG0000046'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

								DELETE FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @PR_NO AND ITEM_NO = @WRK_PR_ITEM_NO

							SET @MSG = 'Delete Worklist for Item No. ' + CONVERT(VARCHAR, @WRK_PR_ITEM_NO) + ' Success'
							SET @MSG_ID = 'MSG0000047'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
						END TRY
						BEGIN CATCH
							SET @MSG = 'Delete Worklist for Item No. ' + CONVERT(VARCHAR, @WRK_PR_ITEM_NO) + ' Failed'
							SET @MSG_ID = 'MSG0000048'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

							SET @MSG = ERROR_MESSAGE()
							SET @MSG_ID = 'EXCEPTION'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

							SET @STATUS = 'FAILED'
							BREAK
						END CATCH
					END

					IF(@WRK_DO_CREATE = 0)
					BEGIN
						BEGIN TRY
							SET @MSG = 'Delete Worklist Data From TB_R_WORKFLOW Started For Document No ' + @PR_NO + 
										  ' and Item No ' + CONVERT(VARCHAR,@WRK_PR_ITEM_NO)
							SET @MSG_ID = 'MSG0000049'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

								DELETE FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @PR_NO AND ITEM_NO = @WRK_PR_ITEM_NO
							
								UPDATE TB_R_PR_ITEM SET PR_STATUS = '10', PR_NEXT_STATUS = '11' WHERE PR_NO = @PR_NO AND PR_ITEM_NO = @WRK_PR_ITEM_NO
						
								SET @WRK_DO_CREATE = 2 --INSERT WORKFLOW AFTER DELETE

							SET @MSG = 'Delete Worklist Data From TB_R_WORKFLOW Success For Document No ' + @PR_NO + 
										  ' and Item No ' + CONVERT(VARCHAR,@WRK_PR_ITEM_NO)
							SET @MSG_ID = 'MSG0000050'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
						END TRY
						BEGIN CATCH
							SET @MSG = 'Delete Worklist Data From TB_R_WORKFLOW Failed For Document No ' + @PR_NO
							SET @MSG_ID = 'MSG0000051'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

							SET @MSG = ERROR_MESSAGE()
							SET @MSG_ID = 'EXCEPTION'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

							SET @STATUS = 'FAILED'
							BREAK
						END CATCH
					END

					IF(@WRK_DO_CREATE = 1)
					BEGIN
						BEGIN TRY
							SET @MSG = 'Update Worklist Data To TB_R_WORKFLOW Started For Document No ' + @PR_NO + 
										  ' and Item No ' + CONVERT(VARCHAR,@WRK_PR_ITEM_NO)
							SET @MSG_ID = 'MSG0000052'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
					
							EXEC [dbo].[sp_worklist_updateWorkflow] 
														@PR_NO, 
														@FUNCTION,
														@WRK_PR_ITEM_NO, 
														@WRK_AMOUNT, 
														@USER_ID, 
														@STATUS OUTPUT

							SET @MSG = 'Update Worklist Data To TB_R_WORKFLOW Success For Document No ' + @PR_NO + 
										  ' and Item No ' + CONVERT(VARCHAR,@WRK_PR_ITEM_NO)
							SET @MSG_ID = 'MSG0000053'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
						END TRY
						BEGIN CATCH
							SET @MSG = 'Update Worklist Data To TB_R_WORKFLOW Failed For Document No ' + @PR_NO
							SET @MSG_ID = 'MSG0000054'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

							SET @MSG = ERROR_MESSAGE()
							SET @MSG_ID = 'EXCEPTION'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

							SET @STATUS = 'FAILED'
							BREAK
						END CATCH
					END

					IF(@WRK_DO_CREATE = 2)
					BEGIN
						SET @MSG = 'Insert Worklist Data To TB_R_WORKFLOW Started For Document No ' + @PR_NO + 
									  ' and Item No ' + CONVERT(VARCHAR,@WRK_PR_ITEM_NO)
						SET @MSG_ID = 'MSG0000057'
						INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
						EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
			
						BEGIN TRY
							SET @MSG = 'Get Aproval Code, PR Checker Code, and FD Code'
							SET @MSG_ID = 'MSG0000058'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
			
							DELETE FROM @TB_T_APPROVAL_CD
							INSERT INTO @TB_T_APPROVAL_CD 
								SELECT SE.ORG_ID,
									MIN(SE.POSITION_LEVEL),
									'203001'
									FROM TB_R_SYNCH_EMPLOYEE SE
										INNER JOIN TB_M_ORG_POSITION OP ON SE.POSITION_LEVEL = OP.POSITION_LEVEL
										INNER JOIN TB_M_SYSTEM TM ON TM.SYSTEM_CD = OP.LEVEL_ID AND TM.FUNCTION_ID = '203001'
									WHERE SE.DIVISION_ID = @DIVISION_ID AND  GETDATE() BETWEEN se.VALID_FROM AND se.VALID_TO AND SE.ORG_ID IN 
										(SELECT ORG_ID FROM @ORG WHERE ISNULL(ORG_ID, '') <> '') 
									GROUP BY SE.ORG_ID 
							
							IF NOT EXISTS (SELECT 1
											FROM TB_M_COORDINATOR_MAPPING A 
											INNER JOIN TB_M_SYSTEM B ON A.COORDINATOR_CD = @PR_COORDINATOR AND B.SYSTEM_CD = A.POSITION_LEVEL AND B.FUNCTION_ID = '203002' AND A.APPROVAL_FLAG = 'Y'
											WHERE A.POSITION_LEVEL = 7) -- Check if checked by staff has not been set in coordinator mapping then insert checked by staff as '-' with ORG 0
							BEGIN
								INSERT INTO @TB_T_APPROVAL_CD VALUES(0, 55, '203002')
							END

							;WITH cte AS (
								SELECT C.NOREG,
									   C.POSITION_LEVEL,
									   ROW_NUMBER() OVER (PARTITION BY OP.LEVEL_ID ORDER BY C.POSITION_LEVEL) AS RN
								FROM TB_M_COORDINATOR_MAPPING A 
									INNER JOIN TB_M_SYSTEM B ON A.COORDINATOR_CD = @PR_COORDINATOR AND B.SYSTEM_CD = A.POSITION_LEVEL AND B.FUNCTION_ID = '203002' AND A.APPROVAL_FLAG = 'Y'
									INNER JOIN TB_R_SYNCH_EMPLOYEE C on 
										(CAST(A.DIVISION_ID AS VArchar) + CAST(ISNULL(A.Department_ID, '') AS varchar) + CAST(ISNULL(A.SECTION_ID, '') AS varchar))
										= CAST(C.DIVISION_ID AS VArchar) + CAST(ISNULL(C.Department_ID, '') AS varchar) + CAST(ISNULL(C.SECTION_ID, '') AS varchar)
										AND A.NOREG = C.NOREG
										AND GETDATE() BETWEEN C.VALID_FROM AND C.VALID_TO
									INNER JOIN TB_M_ORG_POSITION OP ON OP.POSITION_LEVEL = C.POSITION_LEVEL AND OP.LEVEL_ID = A.POSITION_LEVEL
									GROUP BY C.NOREG, OP.Level_id, C.POSITION_LEVEL
							) 
							INSERT INTO @TB_T_APPROVAL_CD 
							select NOREG, POSITION_LEVEL, '203002' from cte where RN = 1

							--Note : if coordinator organization not set yet, delete data for approval code 'checked by staff'
							IF(NOT EXISTS(SELECT 1 FROM @TB_T_APPROVAL_CD t1 JOIN @TB_T_APPROVAL_CD t2 on t1.ORG_ID = 0 AND t2.ROW_INDEX > t1.ROW_INDEX))
							BEGIN
								DELETE FROM @TB_T_APPROVAL_CD WHERE ORG_ID = 0
							END

							INSERT INTO @TB_T_APPROVAL_CD 
								SELECT DISTINCT
									B.NOREG,
									B.POSITION_LEVEL,
									'203003'
									FROM TB_M_VALUATION_CLASS A INNER JOIN TB_M_COORDINATOR_MAPPING B 
									ON A.FD_GROUP_CD = B.COORDINATOR_CD INNER JOIN TB_M_SYSTEM C
									ON B.POSITION_LEVEL = C.SYSTEM_CD AND C.FUNCTION_ID = '203003' 
										AND B.APPROVAL_FLAG = 'Y' AND A.VALUATION_CLASS = @WRK_VAL_CLASS
						
							SELECT @STATUS_DESC = STATUS_DESC FROM TB_M_STATUS WHERE STATUS_CD = '10'
							SELECT @WRK_APPROVAL_INTERVAL = APPROVAL_INTERVAL FROM TB_M_VALUATION_CLASS WHERE VALUATION_CLASS = @WRK_VAL_CLASS
							SELECT @DOCUMENT_SEQ = ISNULL(DOCUMENT_SEQ, 0) + 1 FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @PR_NO AND ITEM_NO = @WRK_PR_ITEM_NO

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
								SELECT  @PR_NO,
										@WRK_PR_ITEM_NO,
										@DOCUMENT_SEQ,
										'10',
										@STATUS_DESC,
										@WRK_REGISTERED_USER,
										@NOREG,
										GETDATE(),
										@WRK_ORG_ID, 
										@WRK_ORG_TITLE,
										@WRK_APPROVER_POSITION,
										'Y' AS IS_APPROVED,
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
												@PR_NO, 
												@WRK_PR_ITEM_NO, 
												@WRK_AMOUNT, 
												@WRK_APPROVAL_INTERVAL, 
												@TB_T_APPROVAL_CD, 
												@STATUS OUTPUT

								--Update BYPASS Approval 'Checked by Staff' if user create is same with user Approval 'Checked by Staff'  
								--UPDATE TB_R_WORKFLOW 
								--	SET APPROVED_BYPASS = @NOREG, APPROVED_DT = GETDATE(), IS_APPROVED = 'Y', CHANGED_BY = @NOREG, CHANGED_DT = GETDATE()
								--WHERE LEFT(APPROVAL_CD,1) = 2 AND IS_DISPLAY = 'Y' AND APPROVED_BY = @NOREG AND APPROVED_DT IS NULL AND DOCUMENT_NO = @PR_NO AND ITEM_NO = @WRK_PR_ITEM_NO

								DECLARE @Doc_Seq int, @Approval_Cd VARCHAR(5)
								DECLARE db_cursor CURSOR FOR  
								select DOCUMENT_SEQ, APPROVAL_CD  FROM
								TB_R_WORKFLOW 
								WHERE IS_DISPLAY = 'Y' AND APPROVED_BY = @NOREG AND APPROVED_DT IS NULL AND DOCUMENT_NO = @PR_NO AND ITEM_NO = @WRK_PR_ITEM_NO

								OPEN db_cursor   
								FETCH NEXT FROM db_cursor INTO @Doc_Seq, @Approval_Cd

								WHILE @@FETCH_STATUS = 0   
								BEGIN   
									SET @MSG = 'Bypass `Checked by Staff` Worklist Data To TB_R_WORKFLOW Started For Document No ' + @PR_NO + 
										   ' And Item No ' + CONVERT(VARCHAR,@WRK_PR_ITEM_NO) + ' And Level Aproval ' + LEFT(@Approval_Cd,1)
									SET @MSG_ID = 'MSG0000060'
									INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
									EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 2;

									UPDATE TB_R_WORKFLOW 
										SET APPROVED_BYPASS = @NOREG, APPROVED_DT = GETDATE(), IS_APPROVED = 'Y', CHANGED_BY = @NOREG, CHANGED_DT = GETDATE()
									WHERE LEFT(APPROVAL_CD,1) = LEFT(@Approval_Cd,1) AND IS_DISPLAY = 'Y' AND APPROVED_DT IS NULL AND DOCUMENT_NO = @PR_NO AND ITEM_NO = @WRK_PR_ITEM_NO AND DOCUMENT_SEQ <= @Doc_Seq

									SET @MSG = 'Bypass `Checked by Staff` Worklist Data To TB_R_WORKFLOW Success For Document No ' + @PR_NO + 
										   ' And Item No ' + CONVERT(VARCHAR,@WRK_PR_ITEM_NO) + ' And Level Aproval ' + LEFT(@Approval_Cd,1)
									SET @MSG_ID = 'MSG0000060'
									INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
									EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;

									FETCH NEXT FROM db_cursor INTO @Doc_Seq, @Approval_Cd
								END 

								CLOSE db_cursor   
								DEALLOCATE db_cursor


								SET @MSG = 'Insert Worklist Data To TB_R_WORKFLOW Success For Document No ' + @PR_NO + 
										   ' And Item No ' + CONVERT(VARCHAR,@WRK_PR_ITEM_NO)
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
							IF CURSOR_STATUS('global','db_cursor')>=-1
							BEGIN
							 DEALLOCATE db_cursor
							END

							SET @MSG = 'Insert Worklist Data To TB_R_WORKFLOW Failed For Document No ' + @PR_NO + ' And Item No ' + CONVERT(VARCHAR,@WRK_PR_ITEM_NO)
							SET @MSG_ID = 'MSG0000061'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

							SET @MSG = ERROR_MESSAGE()
							SET @MSG_ID = 'EXCEPTION'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

							SET @STATUS = 'FAILED'
							BREAK
						END CATCH
					END

					IF((@WRK_WBS_NO = '') AND (@STATUS = 'SUCCESS'))
					BEGIN
						BEGIN TRY
							SET @MSG = 'WBS No For Document No. ' + @PR_NO + ' Is Empty' + 
									   ' FD Approval Code Will Not Displayed'
							SET @MSG_ID = 'MSG0000062'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
							
								UPDATE TB_R_WORKFLOW 
									SET IS_DISPLAY = 'N' 
									WHERE DOCUMENT_NO = @PR_NO 
										  AND ITEM_NO = @WRK_PR_ITEM_NO 
										  AND SUBSTRING(APPROVAL_CD, 1, 1) = '3'
						END TRY
						BEGIN CATCH
							SET @MSG = 'Update FD Approval Code Display Status Failed'
							SET @MSG_ID = 'MSG0000063'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

							SET @MSG = ERROR_MESSAGE()
							SET @MSG_ID = 'EXCEPTION'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

							SET @STATUS = 'FAILED'
							BREAK
						END CATCH
					END

					IF((@WRK_SOURCE_TYPE = 'ECatalogue') AND (@STATUS = 'SUCCESS')) --e-Catalogue
					BEGIN
						BEGIN TRY
							SET @MSG = 'ECatalogue Condition Workflow For Document No. ' + @PR_NO 
							SET @MSG_ID = 'MSG0000064'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
							
							DECLARE @NEED_APPROVE_COOR CHAR(1),
									@NEED_APPROVE_FD CHAR(1),
									@PR_FLAG  CHAR(1)

							SELECT @NEED_APPROVE_COOR = ISNULL(SYSTEM_VALUE,'N') FROM TB_M_SYSTEM WHERE FUNCTION_ID ='EC' AND SYSTEM_CD = 'COORDINATOR_APPRV'
							SELECT @NEED_APPROVE_FD = ISNULL(SYSTEM_VALUE,'N') FROM TB_M_SYSTEM WHERE FUNCTION_ID ='EC' AND SYSTEM_CD = 'FD_APPRV'
							SET @NEED_APPROVE_COOR = ISNULL(@NEED_APPROVE_COOR,'N')
							SET @NEED_APPROVE_FD = ISNULL(@NEED_APPROVE_FD,'N')

							IF(@NEED_APPROVE_COOR ='Y')
							BEGIN
								SELECT @PR_FLAG = ISNULL(PR_FLAG,'N') FROm TB_M_MATERIAL_NONPART WHERE MAT_NO = @WRK_MAT_NO

								IF(@PR_FLAG ='N')
								BEGIN
									BEGIN TRY
										SET @MSG = 'Flag Coordinator Approval in TB_M_MATERIAL_NONPART For Document No. ' + @PR_NO + ' and Material '+@WRK_MAT_NO+' Is N' + 
											   ' Coordinator Approval Code Will Not Displayed'
										SET @MSG_ID = 'MSG0000065'
										INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
										EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

										IF EXISTS(SELECT 1 FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @PR_NO AND ITEM_NO = @WRK_PR_ITEM_NO AND SUBSTRING(APPROVAL_CD, 1, 1) = '2')
										BEGIN
											SET @MSG = 'Update Cordinator To (N)'
											SET @MSG_ID = 'MSG0000065'
											INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
											EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

											UPDATE TB_R_WORKFLOW 
											SET IS_DISPLAY = 'N' 
											WHERE DOCUMENT_NO = @PR_NO 
													AND ITEM_NO = @WRK_PR_ITEM_NO 
													AND SUBSTRING(APPROVAL_CD, 1, 1) = '2'
										END
										ELSE
										BEGIN
											SET @MSG = 'Workflow Cordinator Not exists'
											SET @MSG_ID = 'MSG0000065'
											INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
											EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
										END
										
									END TRY
									BEGIN CATCH
										SET @MSG = 'Update Coordinator Approval Code Display by MATERIAL Status Failed'
										SET @MSG_ID = 'MSG0000066'
										INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
										EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

										RAISERROR(@MSG, 16, 1)
									END CATCH
								END
								ELSE
								BEGIN
									SET @MSG = 'Flag Coordinator Approval in TB_M_MATERIAL_NONPART For Document No. ' + @PR_NO + ' and Material '+@WRK_MAT_NO+' Is Y' + 
											   ' Coordinator Approval Code Will Be Displayed'
										SET @MSG_ID = 'MSG0000065'
										INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
										EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
								END
							END
							ELSE
							BEGIN
								BEGIN TRY
									SET @MSG = 'Flag Coordinator Approval in TB_M_System For Document No. ' + @PR_NO + ' Is N' + 
										   ' Coordinator Approval Code Will Not Displayed'
									SET @MSG_ID = 'MSG0000067'
									INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
									EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
							
									IF EXISTS(SELECT 1 FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @PR_NO AND ITEM_NO = @WRK_PR_ITEM_NO AND SUBSTRING(APPROVAL_CD, 1, 1) = '2')
									BEGIN
										SET @MSG = 'Update Cordinator To (N)'
										SET @MSG_ID = 'MSG0000065'
										INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
										EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

										UPDATE TB_R_WORKFLOW 
										SET IS_DISPLAY = 'N' 
										WHERE DOCUMENT_NO = @PR_NO 
												AND ITEM_NO = @WRK_PR_ITEM_NO 
												AND SUBSTRING(APPROVAL_CD, 1, 1) = '2'
									END
									ELSE
									BEGIN
										SET @MSG = 'Workflow Cordinator Not exists'
										SET @MSG_ID = 'MSG0000065'
										INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
										EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
									END
								END TRY
								BEGIN CATCH
									SET @MSG = 'Update Coordinator Approval Code Display Status Failed'
									SET @MSG_ID = 'MSG0000068'
									INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
									EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

									RAISERROR(@MSG, 16, 1)
								END CATCH
							END

							IF(@NEED_APPROVE_FD <>'Y')
							BEGIN
								BEGIN TRY
									SET @MSG = 'Flag FD Approval in TB_M_System For Document No. ' + @PR_NO + ' Is N' + 
										   ' FD Approval Code Will Not Displayed'
									SET @MSG_ID = 'MSG0000069'
									INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
									EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

									IF EXISTS(SELECT 1 FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @PR_NO AND ITEM_NO = @WRK_PR_ITEM_NO AND SUBSTRING(APPROVAL_CD, 1, 1) = '3')
									BEGIN
										SET @MSG = 'Update FD To (N)'
										SET @MSG_ID = 'MSG0000069'
										INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
										EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

										UPDATE TB_R_WORKFLOW 
										SET IS_DISPLAY = 'N' 
										WHERE DOCUMENT_NO = @PR_NO 
												AND ITEM_NO = @WRK_PR_ITEM_NO 
												AND SUBSTRING(APPROVAL_CD, 1, 1) = '3'
									END
									ELSE
									BEGIN
										SET @MSG = 'Workflow FD Not exists'
										SET @MSG_ID = 'MSG0000069'
										INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
										EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
									END
								END TRY
								BEGIN CATCH
									SET @MSG = 'Update FD Approval Code Display Status Failed'
									SET @MSG_ID = 'MSG0000070'
									INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
									EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

									RAISERROR(@MSG, 16, 1)
								END CATCH
							END
						END TRY
						BEGIN CATCH
							SET @MSG = 'ECatalogue Condition Workflow For Document No. ' + @PR_NO +' Failed'
							SET @MSG_ID = 'MSG0000071'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

							SET @MSG = ERROR_MESSAGE()
							SET @MSG_ID = 'EXCEPTION'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

							SET @STATUS = 'FAILED'
							BREAK
						END CATCH
					END

					SELECT @WRK_COUNT = COUNT(*) FROM TB_R_WORKFLOW 
							WHERE DOCUMENT_NO = @PR_NO AND 
									ITEM_NO = @WRK_PR_ITEM_NO AND 
									STRUCTURE_ID = @DIVISION_ID AND 
									SUBSTRING(APPROVAL_CD, 1, 1) = '2'
					/*IF((@WRK_COUNT > 0) AND (@STATUS = 'SUCCESS'))
					BEGIN
						BEGIN TRY
							SET @MSG = 'Structure ID of BC DH is same with User Division ID ' + CONVERT(VARCHAR, @DIVISION_ID) + 
									   ', BC Will Not Displayed'
							SET @MSG_ID = 'MSG0000064'
							INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
							EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
						
								UPDATE TB_R_WORKFLOW SET IS_DISPLAY = 'N' 
									WHERE SUBSTRING(APPROVAL_CD, 1, 1) = '2' AND 
											DOCUMENT_NO = @PR_NO AND
											ITEM_NO = @WRK_PR_ITEM_NO
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
							BREAK
						END CATCH
					END*/
				END

				FETCH NEXT FROM worklist_cursor
							INTO 
								@WRK_VAL_CLASS,
								@WRK_PR_ITEM_NO,
								@WRK_PR_NEXT_STATUS,
								@WRK_NEW_FLAG, 
								@WRK_DELETE_FLAG, 
								@WRK_WBS_NO,
								@WRK_AMOUNT,
								@WRK_LAST_AMOUNT,
								@NEW_FLAG,
								@UPDATE_FLAG,
								@DELETE_FLAG,
								@WRK_MAT_NO,
								@WRK_SOURCE_TYPE
			END
		CLOSE worklist_cursor
		DEALLOCATE worklist_cursor
	END

	IF(@STATUS = 'SUCCESS')
	BEGIN
		BEGIN TRY
			SET @MSG = 'Get Approver Data from HR.Portal for Document No. ' + @PR_NO + ' Started'
			SET @MSG_ID = 'MSG0000072'
			INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
			EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
			
			EXEC [dbo].[sp_worklist_getApprovalData] @PR_NO

			SET @MSG = 'Get Approver Data from HR.Portal for Document No. ' + @PR_NO + ' Success'
			SET @MSG_ID = 'MSG0000073'
			INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
			EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
		END TRY
		BEGIN CATCH
			SET @MSG = 'Get Approver Data from HR.Portal for Document No ' + @PR_NO
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
		DECLARE item_cursor CURSOR FOR
			SELECT DISTINCT ITEM_NO FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @PR_NO ORDER BY ITEM_NO ASC
		OPEN item_cursor
		FETCH NEXT FROM item_cursor INTO @WRK_PR_ITEM_NO
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @APPROVED_DT = APPROVED_DT FROM TB_R_WORKFLOW 
				WHERE DOCUMENT_NO = @PR_NO AND ITEM_NO = @WRK_PR_ITEM_NO AND DOCUMENT_SEQ = 1

				BEGIN TRY
					SET @MSG = 'Calculate Interval Started for Document No ' + @PR_NO + ' And Item No ' + CONVERT(VARCHAR, @WRK_PR_ITEM_NO)
					SET @MSG_ID = 'MSG000075'
					INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;

					EXEC [dbo].[sp_worklist_calculateInterval] 
											@PR_NO, 
											@WRK_PR_ITEM_NO, 
											@APPROVED_DT, 
											1

					SET @MSG = 'Calculate Interval Success for Document No ' + @PR_NO + ' And Item No ' + CONVERT(VARCHAR, @WRK_PR_ITEM_NO)
					SET @MSG_ID = 'MSG0000076'
					INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
				END TRY
				BEGIN CATCH	
					SET @MSG = 'Calculate Interval Failed For Document No ' + @PR_NO
					SET @MSG_ID = 'MSG0000077'
					INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

					SET @MSG = ERROR_MESSAGE() 
					SET @MSG_ID = 'EXCEPTION'
					INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;
					
					SET @STATUS = 'FAILED'
					BREAK
				END CATCH	
				FETCH NEXT FROM item_cursor INTO @WRK_PR_ITEM_NO
			END
		CLOSE item_cursor
		DEALLOCATE item_cursor
	END

	IF(@STATUS = 'SUCCESS')
	BEGIN
		BEGIN TRY
			SET @MSG = 'Checking Approval Bypass For Document No ' + @PR_NO + ' Started'
			SET @MSG_ID = 'MSG0000078'
			INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
			EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
		
			EXEC [dbo].[sp_worklist_bypassChecking] 
								@PR_NO, 
								'PR', 
								@PROCESS_ID, 
								@NOREG, 
								@WRK_ORG_ID, 
								@WRK_APPROVER_POSITION, 
								@STATUS OUTPUT

			SET @MSG = 'Checking Approval Bypass For Document No ' + @PR_NO + ' Success'
			SET @MSG_ID = 'MSG0000079'
			INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
			EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
		END TRY
		BEGIN CATCH
			SET @MSG = 'Checking Approval Bypass For Document No ' + @PR_NO + ' Failed'
			SET @MSG_ID = 'MSG0000080'
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
		DECLARE status_cursor CURSOR FOR
			SELECT DISTINCT ITEM_NO FROM TB_R_WORKFLOW WHERE DOCUMENT_NO = @PR_NO ORDER BY ITEM_NO ASC
		OPEN status_cursor
		FETCH NEXT FROM status_cursor INTO @WRK_PR_ITEM_NO
			WHILE @@FETCH_STATUS = 0
			BEGIN
				BEGIN TRY
					SET @MSG = 'Update Status For PR No. ' + @PR_NO + ' and Item No ' + @WRK_PR_ITEM_NO + ' Started'
					SET @MSG_ID = 'MSG0000081'
					INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 1, @USER_ID
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 1;
						
					DECLARE @PR_STATUS CHAR(2) = '', @PR_NEXT_STATUS CHAR(2) = ''

					IF EXISTS(SELECT 1 FROm TB_R_WORKFLOW WHERE DOCUMENT_NO = @PR_NO AND ITEM_NO = @WRK_PR_ITEM_NO AND IS_REJECTED = 'Y')
					BEGIN
						IF NOT EXISTS(SELECT 1 FROm TB_R_WORKFLOW WHERE DOCUMENT_NO = @PR_NO AND ITEM_NO = @WRK_PR_ITEM_NO AND IS_APPROVED = 'Y')
						BEGIN
							SELECT TOP 1 @PR_STATUS = APPROVAL_CD FROM TB_R_WORKFLOW WF1
								WHERE
									WF1.DOCUMENT_NO = @PR_NO
									AND WF1.ITEM_NO = @WRK_PR_ITEM_NO
									AND WF1.IS_APPROVED = 'N'
									AND WF1.IS_DISPLAY = 'Y' 
								ORDER BY WF1.DOCUMENT_SEQ ASC;
						END
						ELSE
						BEGIN
							SELECT TOP 1 @PR_STATUS = APPROVAL_CD FROM TB_R_WORKFLOW WF1
								WHERE
									WF1.DOCUMENT_NO = @PR_NO
									AND WF1.ITEM_NO = @WRK_PR_ITEM_NO
									AND WF1.IS_APPROVED = 'Y'
									AND WF1.IS_DISPLAY = 'Y' 
								ORDER BY WF1.DOCUMENT_SEQ DESC;
						END
					END
					ELSE
					BEGIN
						SELECT TOP 1 @PR_STATUS = APPROVAL_CD FROM TB_R_WORKFLOW WF1
							WHERE
								WF1.DOCUMENT_NO = @PR_NO
								AND WF1.ITEM_NO = @WRK_PR_ITEM_NO
								AND WF1.IS_APPROVED = 'Y'
								AND WF1.IS_DISPLAY = 'Y' 
								AND NOT EXISTS (SELECT 1 FROM TB_R_WORKFLOW WF2 
											WHERE WF2.DOCUMENT_NO =  WF1.DOCUMENT_NO AND WF2.ITEM_NO = WF1.ITEM_NO AND WF2.IS_DISPLAY = 'Y' AND WF2.DOCUMENT_SEQ < WF1.DOCUMENT_SEQ AND APPROVED_DT IS NULL)
							ORDER BY WF1.DOCUMENT_SEQ DESC;
					END

					SELECT TOP 1 @PR_NEXT_STATUS = APPROVAL_CD FROM TB_R_WORKFLOW
						WHERE
							DOCUMENT_NO = @PR_NO
							AND ITEM_NO = @WRK_PR_ITEM_NO
							AND IS_APPROVED = 'N'
							AND IS_DISPLAY = 'Y'
							AND APPROVAL_CD <> @PR_STATUS
						ORDER BY DOCUMENT_SEQ ASC;

					SELECT @PR_STATUS = CASE WHEN(ISNULL(@PR_STATUS, '') = '') THEN '14' ELSE @PR_STATUS END
					SELECT @PR_NEXT_STATUS = CASE WHEN(ISNULL(@PR_NEXT_STATUS, '') = '') THEN '14' ELSE @PR_NEXT_STATUS END

					IF(ISNULL(@PR_NEXT_STATUS, '') = '14' )
					BEGIN
						SELECT @PR_STATUS = '14'
					END

					UPDATE TB_R_PR_ITEM 
						SET PR_STATUS = @PR_STATUS,
							PR_NEXT_STATUS = @PR_NEXT_STATUS
						WHERE PR_NO = @PR_NO AND PR_ITEM_NO = @WRK_PR_ITEM_NO 

					UPDATE TB_H_PR_ITEM 
						SET PR_STATUS = @PR_STATUS,
							PR_NEXT_STATUS = @PR_NEXT_STATUS
						WHERE PR_NO = @PR_NO AND PR_ITEM_NO = @WRK_PR_ITEM_NO AND PROCESS_ID = @PROCESS_ID 

					UPDATE TB_R_WORKFLOW SET APPROVED_DT = NULL
						WHERE
							DOCUMENT_NO = @PR_NO
							AND ITEM_NO = @WRK_PR_ITEM_NO
							AND IS_REJECTED = 'Y'
							AND IS_DISPLAY = 'Y'
							AND APPROVAL_CD >= @PR_NEXT_STATUS

					SET @MSG = 'Update Status For PR No. ' + @PR_NO + ' and Item No ' + @WRK_PR_ITEM_NO + ' with pr status '+@PR_STATUS+ ' and next status '+ @PR_NEXT_STATUS + ' Success' 
					SET @MSG_ID = 'MSG0000082'
					INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'INF', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'INF', @MODULE, @FUNCTION, 2;
				END TRY
				BEGIN CATCH	
					SET @MSG = 'Update Status For PR No. ' + @PR_NO + ' and Item No ' + @WRK_PR_ITEM_NO + ' Failed'
					SET @MSG_ID = 'MSG0000083'
					INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;

					SET @MSG = ERROR_MESSAGE() 
					SET @MSG_ID = 'EXCEPTION'
					INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'ERR', @MSG, @MODULE, @LOCATION, @FUNCTION, 3, @USER_ID
					EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'ERR', @MODULE, @FUNCTION, 3;
					
					SET @STATUS = 'FAILED'
					BREAK
				END CATCH	
				FETCH NEXT FROM status_cursor INTO @WRK_PR_ITEM_NO
			END
		CLOSE status_cursor
		DEALLOCATE status_cursor
	END

	IF(@STATUS = 'SUCCESS')
	BEGIN
		SET @MSG = 'Insert Worklist Success For Document No. ' + @PR_NO
		SET @MSG_ID = 'MSG0000076'
		INSERT INTO @TB_TMP_LOG SELECT @PROCESS_ID, GETDATE(), @MSG_ID, 'SUC', @MSG, @MODULE, @LOCATION, @FUNCTION, 2, @USER_ID
		EXEC dbo.sp_PutLog @MSG, @USER_ID, @LOCATION, @PROCESS_ID , @MSG_ID, 'SUC', @MODULE, @FUNCTION, 2;
	END

SELECT PROCESS_ID, PROCESS_TIME, MESSAGE_ID, MESSAGE_TYPE, MESSAGE_DESC, MODULE_ID, MODULE_DESC, FUNCTION_ID, STATUS_ID, [USER_NAME] FROM @TB_TMP_LOG
END


