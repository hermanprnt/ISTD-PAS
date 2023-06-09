USE [PAS_DB_QA]
GO
/****** Object:  StoredProcedure [dbo].[sp_ItemList_GetList]    Script Date: 12/18/2017 11:21:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_SOPFileInquiry_GetList]
	@Module VARCHAR(100),
	@Start int,
	@Length int
AS
BEGIN
	SELECT * FROM
	(
		SELECT ROW_NUMBER() OVER (ORDER BY DOCUMENT_ID ASC) NO, 
			[DOCUMENT_ID], 
			[FILE_NAME], 
			[FILE_NAME_ORI], 
			[FILE_DESC], 
			[FILE_EXTENSION],
			CASE WHEN LOWER([FILE_EXTENSION]) = '.pdf' THEN 'pdf.png'
				WHEN LOWER([FILE_EXTENSION]) = '.ppt' OR LOWER([FILE_EXTENSION]) = '.pptx'  THEN 'ppt.png'
				WHEN LOWER([FILE_EXTENSION]) = '.txt' THEN 'txt.png'
				WHEN LOWER([FILE_EXTENSION]) = '.xls' OR LOWER([FILE_EXTENSION]) = '.xlsx' THEN 'xls.png'
				WHEN LOWER([FILE_EXTENSION]) = '.doc' OR LOWER([FILE_EXTENSION]) = '.docx'  THEN 'doc.png'
				WHEN LOWER([FILE_EXTENSION]) = '.zip' OR LOWER([FILE_EXTENSION]) = '.rar'  THEN 'zip.png'
				WHEN LOWER([FILE_EXTENSION]) = '.jpg' OR LOWER([FILE_EXTENSION]) = '.bmp' OR LOWER([FILE_EXTENSION]) = '.png' OR LOWER([FILE_EXTENSION]) = '.gif'  OR LOWER([FILE_EXTENSION]) = '.jpeg' THEN 'img.png'
				ELSE
					 'unknow.png'
				END
			AS [IMG_FILE_EXTENSION],
			[FILE_SIZE],
			CASE WHEN FILE_SIZE >= 1048576 THEN CAST(CAST((FILE_SIZE/1048576.0)AS decimal(18,2)) AS varchar)+' MB' ELSE CAST(CAST((FILE_SIZE/1024.0)AS decimal(18,2)) AS varchar)+' KB' END FILE_SIZE_STR,
			CREATED_BY,
			CREATED_DT
		FROM TB_M_SOP_DOCUMENT WHERE DOC_TYPE = @Module
	) AS TB
	WHERE NO BETWEEN @Start AND @Length

END