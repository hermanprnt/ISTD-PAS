USE [PAS_DB_QA]
GO
/****** Object:  StoredProcedure [dbo].[sp_POInquiry_GetPoMonitoringList]    Script Date: 10/16/2017 5:21:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_POInquiry_GetPoMonitoringList]
	@start int,
	@length int,
	@pr_no VARCHAR(20) = '',
	@status VARCHAR(20) = '',
	@process_date_f DATETIME = null, 
	@process_date_t DATETIME = null
AS
BEGIN
    SELECT data.*
	FROM 
		(
		SELECT ROW_NUMBER() OVER (ORDER BY ORDER_BY DESC) AS NUMBER, t.* FROM (
			SELECT PR_NO, PR_ITEM_NO, MAT_NO, STATUS, PO_NO, REMARK, PROCESS_DATE, PROCESS_ID, CASE WHEN STATUS ='FAILED' THEN GETDATE() ELSE PROCESS_DATE END AS ORDER_BY 
			FROm TB_R_PO_GENERATE_MONITORING 
			WHERE 
				(ISNULL(PR_NO,'') = ISNULL(@pr_no,'') OR ISNULL(@pr_no,'') = '')
				AND (ISNULL(STATUS,'') = ISNULL(@status,'') OR ISNULL(@status,'') = '')
				AND 1 = CASE WHEN ISNULL(@process_date_f,'') = ''
						THEN 1
						ELSE
							CASE WHEN (CONVERT(DATE,PROCESS_DATE) >= @process_date_f AND CONVERT(DATE,PROCESS_DATE) <= @process_date_t)
							THEN 1
							ELSE 0
							END
						END
			)t
		) data
	WHERE data.NUMBER >= @start AND data.NUMBER <= @length
END