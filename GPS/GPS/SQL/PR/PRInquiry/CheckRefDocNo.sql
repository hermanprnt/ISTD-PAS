select count(distinct left(a.reference_doc_no, 10))
from [BMS_DB].[BMS_DB].[dbo].[TB_R_BUDGET_CONTROL_D] a
inner join tb_r_pr_item b on left(a.reference_doc_no, 10) = b.pr_no
where left(a.reference_doc_no, 10) = @PR_NO and action_type = 'COMMIT_CREATE'