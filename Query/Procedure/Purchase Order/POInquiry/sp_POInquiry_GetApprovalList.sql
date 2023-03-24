CREATE PROCEDURE sp_POInquiry_GetApprovalList
    @poNo VARCHAR(11) = ''
AS
BEGIN
    DECLARE
        @createdStatus CHAR(2),
        @approvedBySHStatus CHAR(2),
        @approvedByDpHStatus CHAR(2),
        @approvedByDHStatus CHAR(2)
    
    DECLARE @poStatus TABLE ( Idx INT, StatusCode CHAR(2) )

    INSERT INTO @poStatus
    SELECT ROW_NUMBER() OVER (ORDER BY STATUS_CD), STATUS_CD
    FROM TB_M_STATUS WHERE DOC_TYPE = 'PO'
    
    SELECT @createdStatus = StatusCode FROM @poStatus WHERE Idx = 1
    SELECT @approvedBySHStatus = StatusCode FROM @poStatus WHERE Idx = 2
    SELECT @approvedByDpHStatus = StatusCode FROM @poStatus WHERE Idx = 3
    SELECT @approvedByDHStatus = StatusCode FROM @poStatus WHERE Idx = 4

    DECLARE @approvalList TABLE
    (
        DocNo VARCHAR(11), Creator VARCHAR(50), Created VARCHAR(10),
        SHApprover VARCHAR(50), SHPlan VARCHAR(10), SHActual VARCHAR(10), SHPlanLitime INT, SHActualLitime INT,
        DpHApprover VARCHAR(50), DpHPlan VARCHAR(10), DpHActual VARCHAR(10), DpHPlanLitime INT, DpHActualLitime INT,
        DHApprover VARCHAR(50), DHPlan VARCHAR(10), DHActual VARCHAR(10), DHPlanLitime INT, DHActualLitime INT
    )

    INSERT INTO @approvalList
    SELECT DocNo, Creator, dbo.fn_date_format(Created) Created,
    ISNULL(SHApprover, '') SHApprover, dbo.fn_date_format(SHPlan) SHPlan, dbo.fn_date_format(SHActual) SHActual, ISNULL(SHPlanLitime, '') SHPlanLitime, 
    ISNULL(dbo.fn_datediff_workday(Created, SHActual), '') SHActualLitime,
    ISNULL(DpHApprover, '') DpHApprover, dbo.fn_date_format(DpHPlan) DpHPlan, dbo.fn_date_format(DpHActual) DpHActual, ISNULL(DpHPlanLitime, '') DpHPlanLitime,
    ISNULL(dbo.fn_datediff_workday(SHActual, DpHActual), '') DpHActualLitime,
    ISNULL(DHApprover, '') DHApprover, dbo.fn_date_format(DHPlan) DHPlan, dbo.fn_date_format(DHActual) DHActual, ISNULL(DHPlanLitime, '') DHPlanLitime,
    ISNULL(dbo.fn_datediff_workday(DpHActual, DHActual), '') DHActualLitime
    FROM (
        SELECT DOCUMENT_NO DocNo, [Name], [Value] FROM TB_R_WORKFLOW
        CROSS APPLY (
            SELECT 'Creator', APPROVER_NAME WHERE DOCUMENT_NO = @poNo AND IS_DISPLAY = 'Y' AND APPROVAL_CD = @createdStatus
            UNION SELECT 'Created', CAST(APPROVED_DT AS VARCHAR) WHERE DOCUMENT_NO = @poNo AND IS_DISPLAY = 'Y' AND APPROVAL_CD = @createdStatus
            
            UNION SELECT 'SHApprover', APPROVER_NAME WHERE DOCUMENT_NO = @poNo AND IS_DISPLAY = 'Y' AND APPROVAL_CD = @approvedBySHStatus
            UNION SELECT 'SHPlan', CAST(INTERVAL_DATE AS VARCHAR) WHERE DOCUMENT_NO = @poNo AND IS_DISPLAY = 'Y' AND APPROVAL_CD = @approvedBySHStatus
            UNION SELECT 'SHActual', CAST(APPROVED_DT AS VARCHAR) WHERE DOCUMENT_NO = @poNo AND IS_DISPLAY = 'Y' AND APPROVAL_CD = @approvedBySHStatus
            UNION SELECT 'SHPlanLitime', CAST(APPROVAL_INTERVAL AS VARCHAR) WHERE DOCUMENT_NO = @poNo AND IS_DISPLAY = 'Y' AND APPROVAL_CD = @approvedBySHStatus
            UNION SELECT 'SHActualLitime', '' WHERE DOCUMENT_NO = @poNo AND IS_DISPLAY = 'Y' AND APPROVAL_CD = @approvedBySHStatus
            
            UNION SELECT 'DpHApprover', APPROVER_NAME WHERE DOCUMENT_NO = @poNo AND IS_DISPLAY = 'Y' AND APPROVAL_CD = @approvedByDpHStatus
            UNION SELECT 'DpHPlan', CAST(INTERVAL_DATE AS VARCHAR) WHERE DOCUMENT_NO = @poNo AND IS_DISPLAY = 'Y' AND APPROVAL_CD = @approvedByDpHStatus
            UNION SELECT 'DpHActual', CAST(APPROVED_DT AS VARCHAR) WHERE DOCUMENT_NO = @poNo AND IS_DISPLAY = 'Y' AND APPROVAL_CD = @approvedByDpHStatus
            UNION SELECT 'DpHPlanLitime', CAST(APPROVAL_INTERVAL AS VARCHAR) WHERE DOCUMENT_NO = @poNo AND IS_DISPLAY = 'Y' AND APPROVAL_CD = @approvedByDpHStatus
            UNION SELECT 'DpHActualLitime', '' WHERE DOCUMENT_NO = @poNo AND IS_DISPLAY = 'Y' AND APPROVAL_CD = @approvedByDpHStatus
            
            UNION SELECT 'DHApprover', APPROVER_NAME WHERE DOCUMENT_NO = @poNo AND IS_DISPLAY = 'Y' AND APPROVAL_CD = @approvedByDHStatus
            UNION SELECT 'DHPlan', CAST(INTERVAL_DATE AS VARCHAR) WHERE DOCUMENT_NO = @poNo AND IS_DISPLAY = 'Y' AND APPROVAL_CD = @approvedByDHStatus
            UNION SELECT 'DHActual', CAST(APPROVED_DT AS VARCHAR) WHERE DOCUMENT_NO = @poNo AND IS_DISPLAY = 'Y' AND APPROVAL_CD = @approvedByDHStatus
            UNION SELECT 'DHPlanLitime', CAST(APPROVAL_INTERVAL AS VARCHAR) WHERE DOCUMENT_NO = @poNo AND IS_DISPLAY = 'Y' AND APPROVAL_CD = @approvedByDHStatus
            UNION SELECT 'DHActualLitime', '' WHERE DOCUMENT_NO = @poNo AND IS_DISPLAY = 'Y' AND APPROVAL_CD = @approvedByDHStatus
            ) ca ([Name], [Value])
    ) tmp
    PIVOT (
        MAX([Value])
        FOR [Name] IN (
            Creator, Created,
            SHApprover, SHPlan, SHActual, SHPlanLitime, SHActualLitime,
            DpHApprover, DpHPlan, DpHActual, DpHPlanLitime, DpHActualLitime,
            DHApprover, DHPlan, DHActual, DHPlanLitime, DHActualLitime
        )
    ) piv
    
    SELECT *,
    CASE WHEN SHActualLitime > SHPlanLitime THEN 1 ELSE 0 END IsActualSHLate,
    CASE WHEN DpHActualLitime > DpHPlanLitime THEN 1 ELSE 0 END IsActualDpHLate,
    CASE WHEN DHActualLitime > DHPlanLitime THEN 1 ELSE 0 END IsActualDHLate
    FROM @approvalList
END