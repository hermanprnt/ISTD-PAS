CREATE TYPE ROUTINE_PR_H_TEMP AS TABLE(
    [ROUTINE_NO] [varchar](7) NOT NULL,
	[PR_DESC] [varchar](50) NULL,
	[PR_STATUS] [varchar](2) NOT NULL,
	[PLANT_CD] [varchar](4) NOT NULL,
	[SLOC_CD] [varchar](4) NOT NULL,
	[PR_COORDINATOR] [varchar](6) NOT NULL,
	[DIVISION_ID] [int] NOT NULL,
	[DIVISION_NAME] [varchar](40) NULL,
	[DIVISION_PIC] [varchar](8) NOT NULL,
	[SCH_TYPE] [varchar](1) NOT NULL,
	[SCH_TYPE_DESC] [varchar](10) NOT NULL,
	[SCH_VALUE] [varchar](10) NOT NULL,
	[ACTIVE_FLAG] [varchar](1) NOT NULL,
	[VALID_FROM] datetime NULL,
	[VALID_TO] datetime NULL,
	[PROCESS_ID] [bigint] NOT NULL
)