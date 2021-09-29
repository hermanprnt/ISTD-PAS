declare @@prItemNo varchar(10)
select @@prItemNo = REPLICATE('0', 5-LEN(@ITEM_NO)) + @ITEM_NO

select OPEN_QTY, ISNULL(CANCEL_QTY, 0), USED_QTY 
from tb_r_pr_item 
where pr_no = @PR_NO and pr_item_no = @@prItemNo