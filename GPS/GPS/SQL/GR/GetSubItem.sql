SELECT
      [MAT_NO]
      ,[MAT_DESC]
      ,[PO_QTY_ORI]
      ,[PO_QTY_USED]
      ,[UOM]
      ,[PRICE_PER_UOM]
      ,[LOCAL_AMOUNT] as ORI_AMOUNT
  FROM [dbo].[TB_R_PO_SUBITEM] where
  [PO_NO]=@PO and [PO_ITEM_NO]=@ITEM_NO