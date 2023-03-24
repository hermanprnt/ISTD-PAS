SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		:		Asep.Syahidin
-- Create date	:		20/01/2017
-- Description	:		Copy Attachement File From PR when Adopt item
-- =============================================
IF EXISTS (SELECT * FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].sp_POCreation_CopyAttachedFilesFromPR') AND type IN ( N'P', N'PC' ))
BEGIN
  DROP PROCEDURE [dbo].sp_POCreation_CopyAttachedFilesFromPR
END
GO
CREATE PROCEDURE [dbo].[sp_POCreation_CopyAttachedFilesFromPR]  
	 @PONo VARCHAR (11),
	 @PRNo VARCHAR (11),  
	 @DocType VARCHAR (5),  
	 @CurrentUser VARCHAR (20),  
	 @ProcessId BIGINT  
AS  
BEGIN  

 DECLARE @@sql varchar(max),
	@@DOC_TYPE varchar(5),
	@@FILE_PATH varchar(max),
	@@FILE_EXTENSION varchar(5),
	@@FILE_NAME_ORI varchar(max),
	@@FILE_SIZE bigint,
	@@CREATED_BY varchar(20), 
	@@CREATED_DT DATETIME,
	@@SEQ int,
	@@foundItem int

SET @@sql = 'Declare  cur_attach CURSOR FOR 
	Select DOC_TYPE, FILE_PATH, FILE_EXTENSION, FILE_NAME_ORI, FILE_SIZE, CREATED_BY, CREATED_DT
		FROM TB_R_ATTACHMENT WHERE DOC_NO = ''' + @PRNo + ''''


if @DocType <> ''
begin
	SET @@sql = @@sql + '
				AND DOC_TYPE = ''' + @DocType + ''' '	
end

execute(@@sql)
SET @@foundItem = (SELECT count(0) from TB_T_PO_ITEM WITH(NOLOCK) where PROCESS_ID=@ProcessId AND PR_NO = @PRNo)

OPEN cur_attach   
FETCH NEXT FROM cur_attach INTO @@DOC_TYPE, @@FILE_PATH, @@FILE_EXTENSION, @@FILE_NAME_ORI, @@FILE_SIZE, @@CREATED_BY, @@CREATED_DT

WHILE @@FETCH_STATUS = 0   
BEGIN   
       SELECT @@SEQ = ISNULL(MAX(SEQ_NO), 0) + 1 FROM TB_T_ATTACHMENT WHERE DOC_NO = @PONo and PROCESS_ID = @ProcessId

	   IF(@@foundItem<=1)
	   BEGIN
		   INSERT INTO TB_T_ATTACHMENT 
				(PROCESS_ID, SEQ_NO, DOC_NO, DOC_TYPE, FILE_PATH, FILE_NAME_ORI, FILE_EXTENSION, FILE_SIZE, DELETE_FLAG, NEW_FLAG, CREATED_BY, CREATED_DT, CHANGED_BY, CHANGED_DT)
				VALUES (@ProcessId, @@SEQ, @PONo,CASE WHEN @@DOC_TYPE <> 'QUOT' THEN 'BID' ELSE @@DOC_TYPE END, @@FILE_PATH, @@FILE_NAME_ORI, @@FILE_EXTENSION, @@FILE_SIZE, 'N', 'Y', @@CREATED_BY, @@CREATED_DT, @CurrentUser, GETDATE())
		END
		

       FETCH NEXT FROM cur_attach INTO  @@DOC_TYPE, @@FILE_PATH, @@FILE_EXTENSION, @@FILE_NAME_ORI, @@FILE_SIZE, @@CREATED_BY, @@CREATED_DT 
END   

CLOSE cur_attach   
DEALLOCATE cur_attach

 Select DOC_TYPE, FILE_PATH, FILE_EXTENSION, FILE_NAME_ORI, FILE_SIZE, CREATED_BY, CREATED_DT
 FROM TB_T_ATTACHMENT WHERE PROCESS_ID = @ProcessId AND  DOC_NO = @PONo AND ISNULL(DELETE_FLAG,'N') <> 'Y'
  
END