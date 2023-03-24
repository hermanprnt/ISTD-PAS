select count(distinct b.po_no)
from tb_r_pr_item a 
inner join tb_r_po_h b on a.po_no = b.po_no
where a.pr_no = @PR_NO