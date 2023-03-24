CREATE TYPE [dbo].[CALC_COMP_PRICE] AS TABLE(
    [SeqNo][INT] NOT NULL,
    [Category][CHAR](1) NOT NULL,
    [CalcType][INT] NOT NULL,
    [CompPriceCode][VARCHAR](50) NOT NULL,
    [BaseFrom][INT] NOT NULL,
    [BaseTo][INT] NULL,
    [PlusMinus][INT] NOT NULL,
    [Rate][DECIMAL](18, 4) NOT NULL,
    [AccrualType][CHAR](1) NOT NULL,
    [ConditionRule][CHAR](1) NOT NULL,
    [CompType][CHAR](1) NOT NULL,
    [Qty][INT] NOT NUTLL,
    [QtyPerUOM][INT] NOT NULL,
    [Result][DECIMAL](36, 4) NOT NULL
)