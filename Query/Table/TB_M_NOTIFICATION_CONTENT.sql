/****** Object:  Table [dbo].[TB_M_NOTIFICATION_CONTENT]    Script Date: 11/16/2017 5:48:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TB_M_NOTIFICATION_CONTENT](
	[FUNCTION_ID] [int] NOT NULL,
	[NOTIFICATION_METHOD] [int] NOT NULL,
	[NOTIFICATION_SUBJECT] [text] NOT NULL,
	[NOTIFICATION_CONTENT] [varchar](max) NOT NULL,
	[CREATED_BY] [varchar](20) NOT NULL,
	[CREATED_DT] [datetime] NOT NULL,
	[CHANGED_BY] [varchar](20) NULL,
	[CHANGED_DT] [datetime] NULL,
CONSTRAINT [PK_TB_M_NOTIFICATION] PRIMARY KEY CLUSTERED 
(
	[FUNCTION_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO


