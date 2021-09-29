SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		:		Asep.Syahidin
-- Create date	:		19/01/2017
-- Description	:		Get List GL Account base on WBS and mapping pattern
-- =============================================
<<<<<<< HEAD
=======
IF EXISTS (SELECT * FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].fnt_GetGLAccountMappingWBSList') AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
BEGIN
  DROP FUNCTION [dbo].fnt_GetGLAccountMappingWBSList
END
GO

>>>>>>> 415cfe0193e34827baf32595e6fd19931bd9b980
CREATE FUNCTION fnt_GetGLAccountMappingWBSList(
	@WBS_NO VARCHAR(40))
RETURNS @returnTable TABLE (
		ID INT IDENTITY(1,1),
		GL_CODE VARCHAR(50)
		)
BEGIN
	DECLARE @WBS_NO_1 VARCHAR(1),
<<<<<<< HEAD
			@WBS_NO_5 VARCHAR(2),
=======
>>>>>>> 415cfe0193e34827baf32595e6fd19931bd9b980
			@WBS_NO_6 VARCHAR(5),
			@PATTERN_VALUE VARCHAR(MAX),
			@PATTERN_MAPPING VARCHAR(2) 
	
	SET @WBS_NO_1 = (SELECT SUBSTRING(Split,1,1) From dbo.SplitString(@WBS_NO, '-') where No = 1)
<<<<<<< HEAD
	SET @WBS_NO_5 = (SELECT SUBSTRING(Split,1,2) From dbo.SplitString(@WBS_NO, '-') where No = 5)
=======
>>>>>>> 415cfe0193e34827baf32595e6fd19931bd9b980
	SET @WBS_NO_6 = (SELECT SUBSTRING(Split,1,5) From dbo.SplitString(@WBS_NO, '-') where No = 6)

	IF exists(Select 1 From TB_M_SYSTEM WITH(NOLOCK) WHERE FUNCTION_ID = 'GLMAP1' AND SYSTEM_CD =  @WBS_NO_1)
	BEGIN
		Select @PATTERN_VALUE = a.SYSTEM_VALUE  
		From TB_M_SYSTEM a WITH(NOLOCK)
		INNER JOIN TB_M_SYSTEM b WITH(NOLOCK) on b.SYSTEM_VALUE = a.SYSTEM_CD AND b.FUNCTION_ID = 'GLMAP1' AND b.SYSTEM_CD =  @WBS_NO_1
			WHERE a.FUNCTION_ID = 'GLMAP' 
		
		Insert into @returnTable
		Select rtrim(ltrim(replace(replace(replace(Split,char(9),' '),char(10),' '),char(13),' ')))  From dbo.SplitString(@PATTERN_VALUE, ';')
	END
	ELSE BEGIN
<<<<<<< HEAD
		IF exists(Select 1 From TB_M_SYSTEM WITH(NOLOCK) WHERE FUNCTION_ID = 'GLMAP2' AND SYSTEM_CD =  @WBS_NO_5) BEGIN 
			Select @PATTERN_VALUE = a.SYSTEM_VALUE  
			From TB_M_SYSTEM a WITH(NOLOCK)
			INNER JOIN TB_M_SYSTEM b WITH(NOLOCK) on b.SYSTEM_VALUE = a.SYSTEM_CD AND b.FUNCTION_ID = 'GLMAP2' AND b.SYSTEM_CD =  @WBS_NO_5
=======
		IF exists(Select 1 From TB_M_SYSTEM WITH(NOLOCK) WHERE FUNCTION_ID = 'GLMAP2' AND SYSTEM_CD =  SUBSTRING(@WBS_NO_6,1,2)) BEGIN 
			Select @PATTERN_VALUE = a.SYSTEM_VALUE  
			From TB_M_SYSTEM a WITH(NOLOCK)
			INNER JOIN TB_M_SYSTEM b WITH(NOLOCK) on b.SYSTEM_VALUE = a.SYSTEM_CD AND b.FUNCTION_ID = 'GLMAP2' AND b.SYSTEM_CD =  SUBSTRING(@WBS_NO_6,1,2)
>>>>>>> 415cfe0193e34827baf32595e6fd19931bd9b980
				WHERE a.FUNCTION_ID = 'GLMAP' 

			Insert into @returnTable
			Select rtrim(ltrim(replace(replace(replace(Split,char(9),' '),char(10),' '),char(13),' ')))  From dbo.SplitString(@PATTERN_VALUE, ';')
		END
		ELSE BEGIN
			Select  TOP 1 @PATTERN_VALUE = ms.SYSTEM_VALUE 
			From TB_M_SYSTEM ms WITH(NOLOCK) 
			INNER JOIN TB_M_GL_WBS_MAPPING wbsMap WITH(NOLOCK) on wbsMap.PATTERN_MAPPING = ms.SYSTEM_CD and wbsMap.WBS_ACC = @WBS_NO_6
			WHERE ms.FUNCTION_ID = 'GLMAP'

			SET @PATTERN_VALUE = ISNULL(@PATTERN_VALUE,'')

			IF (SELECT COUNT(0) From dbo.SplitString(@PATTERN_VALUE, ';'))=2 
			BEGIN
				DECLARE @PATTERN_1 int,
						@PATTERN_2 int

				--REmove return, line feedback 7 whitespace  
				SET @PATTERN_1  = (SELECT CONVERT(INT, SPLIT) FROM dbo.SplitString(@PATTERN_VALUE, ';') WHERE no = 1)
				SET @PATTERN_2  = (SELECT CONVERT(INT, SPLIT) FROM dbo.SplitString(@PATTERN_VALUE, ';') WHERE no = 2)

				Insert into @returnTable
				Select GL_ACCOUNT_CD FROM TB_M_GL_ACCOUNT WHERE LEFT(GL_ACCOUNT_CD,@PATTERN_1) = LEFT(@WBS_NO_6, @PATTERN_1)  AND SUBSTRING(GL_ACCOUNT_CD,6,@PATTERN_2) = SUBSTRING(@WBS_NO_6,@PATTERN_1 + 1,@PATTERN_2)
			END

		END
	END

	RETURN 
END
