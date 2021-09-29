CREATE TABLE [dbo].[TB_T_JOB_PO_PROCESSING](
	[PROCESS_ID] BIGINT NOT NULL,
	[STATUS] VARCHAR(50) NOT NULL,
	[PONO] [VARCHAR](10) NULL,
	[USER_ID] [varchar](50) NOT NULL,
	[RELATED_PROCESS_ID] BIGINT NOT NULL,
	[MODULE] [varchar](3) NOT NULL,
	[FUNCTION] [varchar](6) NOT NULL,
	[PURCHASING_GRP] [varchar](5) NOT NULL,
	[EXCHANGE_RATE] DECIMAL(7,2) NOT NULL,
	[IS_SPKCREATED] BIT NOT NULL DEFAULT 0,
	[IS_DRAFT] BIT NOT NULL DEFAULT 0,
	[CLONE_PONO] [varchar](11) NULL,
	[REGNO] [varchar](30) NULL,
	[CREATED_BY] [varchar](20) NOT NULL,
	[CREATED_DT] [datetime] NOT NULL,
	[CHANGED_BY] [varchar](20) NULL,
	[CHANGED_DT] [datetime] NULL,
) ON [PRIMARY]

GO





