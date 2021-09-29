CREATE PROCEDURE [dbo].[sp_PurchasingGroup_GetList]
AS
BEGIN
    SELECT
    coor.COORDINATOR_CD PurchasingGroupCode,
    coor.COORDINATOR_DESC [Description],
    coor.PROC_CHANNEL_CD ProcChannelCode,
    pc.PROC_CHANNEL_DESC ProcChannelDesc
    FROM TB_M_COORDINATOR coor
    JOIN TB_M_PROCUREMENT_CHANNEL pc ON coor.PROC_CHANNEL_CD = pc.PROC_CHANNEL_CD
    WHERE coor.COOR_FUNCTION = 'PG'
END