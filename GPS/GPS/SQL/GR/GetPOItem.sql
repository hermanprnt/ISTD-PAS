    SELECT
        poi.PO_NO,
        ROW_NUMBER() OVER (ORDER BY poi.PO_QTY_REMAIN DESC) Number,
        poi.PO_ITEM_NO,
        poi.MAT_NO ,
        poi.MAT_DESC ,
        poi.PO_QTY_ORI ,
        PO_QTY_USED,
        PO_QTY_REMAIN,
        poi.UOM,
        convert(varchar(10),poi.DELIVERY_PLAN_DT,110 )as DELIVERY_PLAN_DT ,
        poi.PRICE_PER_UOM ,
        poi.ORI_AMOUNT ,
        sloc.SLOC_NAME ,
        plnt.PLANT_NAME
    FROM TB_R_PO_ITEM poi
    JOIN TB_R_PO_H poh ON poi.PO_NO = poh.PO_NO
    LEFT JOIN TB_M_PLANT plnt ON poi.PLANT_CD = plnt.PLANT_CD
    LEFT JOIN TB_M_SLOC sloc ON poi.PLANT_CD = sloc.PLANT_CD AND poi.SLOC_CD = sloc.SLOC_CD
    WHERE poi.PO_NO = @PO and ITEM_CLASS='M'