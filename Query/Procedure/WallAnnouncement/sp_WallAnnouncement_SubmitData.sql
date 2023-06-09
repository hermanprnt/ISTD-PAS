USE [PAS_DB_QA]
GO
/****** Object:  StoredProcedure [dbo].[sp_WallAnnouncement_SubmitData]    Script Date: 12/18/2017 6:13:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_WallAnnouncement_SubmitData]
	@RecipientSupplierList VARCHAR(MAX),
	@RecipientNonSupplierList VARCHAR(MAX),
	@ValidFrom DateTime,
	@ValidTo DateTime,
	@Description VARCHAR(MAX),
	@currentUser VARCHAR(50),
	@currentRegno VARCHAR(50),
	@attachmentList VARCHAR(MAX)
AS
BEGIN
	BEGIN TRY
		DECLARE 
        @tmpLog LOG_TEMP,
        @processId BIGINT,
        @message VARCHAR(MAX) = '',
		@moduleId VARCHAR(3) = '1',
		@functionId VARCHAR(6) = '116001',
        @actionName VARCHAR(50) = 'Wall Announcement',
		@attachmentInfo VARCHAR(MAX) = ''

		DECLARE @regno VARCHAR(50), @Notification_Subject VARCHAR(100), @Notification_Content VARCHAR(MAX), @userName VARCHAR(100), @mailAddr VARCHAR(100), @notice_grp_id VARCHAR(11), @linkDownload VARCHAR(200)

		EXEC dbo.sp_PutLog 'I|Post Wall Announcement Start', @currentUser, @actionName, @processId OUTPUT, 'START', 'INF', @moduleId, @functionId, 0

		BEGIN TRAN
		DECLARE @Title VARCHAR(100) = '',
				@Postdate DATETIME =GETDATE()

		DECLARE @RECIPIENT_TBL AS TABLE (ID int IDENTITY(1,1), Regno VARCHAR(50), Type_Recipient VARCHAR(30), EMAIL VARCHAR(50))
		DECLARE @FILE_ATTCH_TBL AS TABLE(ID int IDENTITY(1,1), FILENAME VARCHAR(500), ORI_FILENAME VARCHAR(500), EXT VARCHAR(10), SIZE INT)

		SELECT @Notification_Subject = NOTIFICATION_SUBJECT, @Notification_Content = NOTIFICATION_CONTENT FROm TB_M_NOTIFICATION_CONTENT WHERE FUNCTION_ID ='91001'
		SELECT @linkDownload = SYSTEM_VALUE FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'MAIL' AND SYSTEM_CD = 'LINK_WALL_ANNOUNCEMENT'

		BEGIN --SPLIT_REC
			SET @message = 'I|Split Recipient: Start' 
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SPLIT_RECP', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

			INSERT INTO @RECIPIENT_TBL(Regno, Type_Recipient)
			SELECT DISTINCT item, 'SUP' FROM dbo.fnSplit(@RecipientSupplierList, ';')

			INSERT INTO @RECIPIENT_TBL(Regno, Type_Recipient)
			SELECT DISTINCT item, 'INTERN' FROM dbo.fnSplit(@RecipientNonSupplierList, ';')

			SET @message = 'I|Split Recipient: End' 
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SPLIT_RECP', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
		END

		BEGIN --VALIDATION
			SET @message = 'I|Validation Segment: Start' 
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'VALID', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

			IF((SELECT COUNT(0)FROM @RECIPIENT_TBL)<=0 )
			BEGIN
				SET @message = 'At least one Recipient must be set.'
				RAISERROR(@message, 16, 1)
			END

			IF(ISNULL(@ValidFrom, CONVERT(DATETIME, '1900-01-01'))= CONVERT(DATETIME, '1900-01-01'))
			BEGIN
				SET @message = 'Valid Date From must be set.'
				RAISERROR(@message, 16, 1)
			END

			IF(ISNULL(@ValidTo, CONVERT(DATETIME, '1900-01-01'))= CONVERT(DATETIME, '1900-01-01'))
			BEGIN
				SET @message = 'Valid Date To must be set.'
				RAISERROR(@message, 16, 1)
			END

			IF(ISNULL(@Description, '')= '')
			BEGIN
				SET @message = 'Announcement Content must be set.'
				RAISERROR(@message, 16, 1)
			END

			SET @message = 'I|Validation Segment: End' 
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'VALID', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
		END

		IF(LEN(@attachmentList)>0)
		BEGIN --SPLIT_ATTC
			SET @attachmentInfo = '<br/>- - - - - - <br/><i>Please open : <br/><ul>'

			SET @message = 'I|Split Attachment: Start' 
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SPLIT_ATTC', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

			DECLARE @temp_attc AS TABLE(ID int IDENTITY(1,1), VALUE_DATA VARCHAR(MAX))

			INSERT INTO @temp_attc 
			SELECT item FROM dbo.fnSplit(@attachmentList, '|')

			DECLARE @IdxAttc INT = 1, @ValueData VARCHAR(MAX), @listAttcCount INT = (SELECT COUNT(ID) FROM @temp_attc)
			WHILE @IdxAttc <= @listAttcCount
			BEGIN
				SELECT @ValueData = VALUE_DATA FROM @temp_attc WHERE ID = @IdxAttc
				
				INSERT INTO @FILE_ATTCH_TBL([FILENAME], ORI_FILENAME, EXT, SIZE)
				SELECT (SELECT Split FROM dbo.SplitString(@ValueData, ';') WHERE No = 1), (SELECT Split FROM dbo.SplitString(@ValueData, ';') WHERE No = 2), (SELECT Split FROM dbo.SplitString(@ValueData, ';') WHERE No = 3), (SELECT Split FROM dbo.SplitString(@ValueData, ';') WHERE No = 4)

				SET @attachmentInfo = @attachmentInfo + '<li><a href='''+@linkDownload+'/NotifDownloadAttachment?file='+(SELECT Split FROM dbo.SplitString(@ValueData, ';') WHERE No = 1)+'&DocNo=[#DOCNO]'' target=''_blank''>'+(SELECT Split FROM dbo.SplitString(@ValueData, ';') WHERE No = 2)+'</a></li>'

				SET @IdxAttc = @IdxAttc + 1
			END

			SET @attachmentInfo = @attachmentInfo + '</ul></i>'

			SET @message = 'I|Split Attachment: End' 
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'SPLIT_ATTC', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
		END

		BEGIN --UPD_MAIL
			SET @message = 'I|Update Mail: Start' 
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'UPD_MAIL', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

			UPDATE temp
				SET EMAIL = emp.MAIL
			FROM @RECIPIENT_TBL temp
			INNER JOIN TB_R_SYNCH_EMPLOYEE emp ON emp.NOREG = temp.Regno

			SET @message = 'I|Update Mail: End' 
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'UPD_MAIL', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
		END

		SET @Title = 'You''ve got a Announcment from ' + @currentUser

		BEGIN --INS_NTC_H
			SET @message = 'I|Insert into TB_H_NOTIFICATION: Start' 
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INS_NTC_H', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

			INSERT INTO TB_H_NOTIFICATION (TITLE, CONTENT, AUTHOR, [PROCESS_ID], CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT, VALID_FROM, VALID_TO )
			SELECT @Title, @Description, @currentUser, @processId, @currentRegno, GETDATE(), NULL, NULL, @ValidFrom, @ValidTo 

			SET @message = 'I|Insert into TB_H_NOTIFICATION: end' 
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INS_NTC_H', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
		END

		select @notice_grp_id =RIGHT(REPLICATE('0', 11) + LEFT(NOTIFICATION_GRP_ID, 11), 11)  FROM TB_H_NOTIFICATION WHERE [PROCESS_ID] = @processId

		SET @attachmentInfo = REPLACE(@attachmentInfo,'[#DOCNO]',@notice_grp_id)
		SET @Description = @Description + @attachmentInfo

		BEGIN --INS_ATTC
			SET @message = 'I|Insert into TB_R_ATTACHMENT: Start' 
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INS_ATTC', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

			INSERT INTO TB_R_ATTACHMENT (DOC_NO, SEQ_NO, DOC_SOURCE, DOC_TYPE, FILE_PATH, FILE_NAME_ORI, FILE_EXTENSION, FILE_SIZE, PROCESS_ID, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT)
			SELECT @notice_grp_id, ROW_NUMBER() OVER (ORDER BY @processId ASC), 'WALL',	'ATTCH', [FILENAME], ORI_FILENAME, EXT, SIZE, @processId, @currentUser, GETDATE(), NULL, NULL
			FROM @FILE_ATTCH_TBL

			SET @message = 'I|Insert into TB_R_ATTACHMENT: end' 
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INS_ATTC', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
		END

		BEGIN --INS_NTC
			SET @message = 'I|Insert into TB_R_NOTIFICATION: Start' 
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INS_NTC', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

			INSERT INTO TB_R_NOTIFICATION (NOTIFICATION_GRP_ID, TITLE, CONTENT, AUTHOR, RECIPIENT, PRIORITY, ACTION_URL, POST_DATE, READ_FLAG, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT, VALID_FROM, VALID_TO )
			SELECT @notice_grp_id, @Title, @Description, @currentRegno, a.Regno, 1, '#', @Postdate, 0, @currentUser, GETDATE(), NULL, NULL, @ValidFrom, @ValidTo 
			FROM @RECIPIENT_TBL a

			SET @message = 'I|Insert into TB_R_NOTIFICATION: end' 
			INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'INS_NTC', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)
		END

		DECLARE @Idx INT = 1, @listCount INT = (SELECT COUNT(ID) FROM @RECIPIENT_TBL)
		WHILE @Idx <= @listCount
		BEGIN
			SELECT @regno = Regno, @mailAddr = EMAIL FROM @RECIPIENT_TBL WHERE ID = @Idx

			SET @Notification_Content = REPLACE(@Notification_Content, '@Content', @Description)


			IF EXISTS(SELECT 1 FROM @RECIPIENT_TBL WHERE ID = @Idx AND ISNULL(EMAIL,'')<>'')
			BEGIN
				SELECT TOP 1 @userName = PERSONNEL_NAME FROm TB_R_SYNCH_EMPLOYEE WHERE NOREG = @regno

				SET @message = 'I|Send mail to '+@userName+' mail '+@mailAddr+' : Start' 
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MAIL', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

				EXEC [dbo].[sp_announcement_sendmail]
								@regno,
								@Notification_Subject,
								@Notification_Content,
								@message OUTPUT
						
				IF(@message <> 'SUCCESS')
				BEGIN
					RAISERROR(@message, 16, 1)
				END

				SET @message = 'I|Send mail : End' 
				INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'MAIL', 'INF', @message, @moduleId, @actionName, @functionId, 1, @currentUser)

			END

			SET @Idx = @Idx + 1
		END

		SET @message = 'I|Post Wall Announcement Finished'
		INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'END', 'INF', @message, @moduleId, @actionName, @functionId, 2, @currentUser)

		SET @message = 'S|'

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN

		SET @message = 'E|' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE()
        INSERT INTO @tmpLog VALUES (@processId, GETDATE(), 'ERR', 'ERR', @message, @moduleId, @actionName, @functionId, 3, @currentUser)

	END CATCH

	EXEC SP_PUTLOG_TEMP @tmpLog

	SELECT @message
END