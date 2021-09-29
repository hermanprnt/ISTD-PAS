CREATE PROCEDURE [dbo].[sp_PurchasingGroup_GetByCode]
    @procChannelCode VARCHAR(4), @code VARCHAR(3)
AS
BEGIN
    SELECT
    '1' DataNo,
    coor.COORDINATOR_CD PurchasingGroupCode,
    coor.COORDINATOR_DESC [Description],
    coor.PROC_CHANNEL_CD ProcChannelCode,
    pc.PROC_CHANNEL_DESC ProcChannelDesc,
    coor.CREATED_BY CreatedBy,
    coor.CREATED_DT CreatedDate,
    coor.CHANGED_BY ChangedBy,
    coor.CHANGED_DT ChangedDate
    FROM TB_M_COORDINATOR coor
    JOIN TB_M_PROCUREMENT_CHANNEL pc ON coor.PROC_CHANNEL_CD = pc.PROC_CHANNEL_CD
    WHERE coor.PROC_CHANNEL_CD = @procChannelCode AND coor.COORDINATOR_CD = @code AND coor.COOR_FUNCTION = 'PG'
END