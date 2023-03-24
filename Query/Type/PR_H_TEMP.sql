CREATE TYPE PR_H_TEMP AS TABLE(
    [PR_NO] [varchar](11) NOT NULL,
    [DOC_DT] [date] NOT NULL,
    [PR_DESC] [varchar](50) NULL,
    [PR_TYPE] [varchar](2) NULL,
    [PLANT_CD] [varchar](4) NOT NULL,
    [SLOC_CD] [varchar](4) NOT NULL,
    [PR_COORDINATOR] [varchar](6) NOT NULL,
    [DIVISION_ID] [int] NOT NULL,
    [DIVISION_NAME] [varchar](40) NULL,
    [PR_STATUS] [varchar](2) NOT NULL,
    [PROJECT_NO] [varchar](25) NULL,
    [URGENT_DOC] [varchar](1) NOT NULL,
    [MAIN_ASSET] [varchar](15) NULL,
    [PR_NOTES] [varchar](500) NULL,
    [DELIVERY_PLAN_DT] [date] NULL,
    [PROCESS_ID] [bigint] NOT NULL
);