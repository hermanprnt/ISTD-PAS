﻿CREATE TYPE APPROVAL_TEMP AS TABLE(
	[ROW_INDEX] [INT] NOT NULL IDENTITY(1,1),
	[ORG_ID] [VARCHAR](11) NULL,
	[POSITION_LEVEL] [INT] NULL,
	[FUNCTION_ID] [varchar](6) NULL
)