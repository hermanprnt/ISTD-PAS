select count(*) 
from tb_r_pr_item a
inner join tb_r_pr_h b on a.pr_no = b.pr_no
where b.pr_no = @PR_NO
