declare @@prItemNo varchar(10), @@wbsNo varchar(40), @@itemClass varchar(2)

select @@prItemNo = REPLICATE('0', 5-LEN(@ITEM_NO)) + @ITEM_NO

SELECT @@itemClass = ITEM_CLASS 
	FROM TB_R_PR_ITEM 
	WHERE PR_NO = @PR_NO AND PR_ITEM_NO = @@prItemNo

if(@@itemClass = 'M')
begin
	select @@wbsNo = wbs_no from tb_r_pr_item where pr_no = @PR_NO and pr_item_no = @@prItemNo
end
else
begin
	select @@wbsNo = a.wbs_no 
	from TB_R_PR_SUBITEM a inner join TB_R_PR_ITEM b on a.PR_NO=b.PR_NO and a.PR_ITEM_NO=b.PR_ITEM_NO 
	where a.PR_NO = @PR_NO AND a.PR_ITEM_NO = @@prItemNo
end

select count(pr_item_no)
from tb_r_pr_item
where pr_no = @PR_NO and pr_item_no != @@prItemNo and wbs_no = @@wbsNo and open_qty > 0 and open_qty < pr_qty