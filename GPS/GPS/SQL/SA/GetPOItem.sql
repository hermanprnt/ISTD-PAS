SELECT
    ROW_NUMBER() OVER (ORDER BY CASt(poi.PO_QTY_REMAIN AS FLOAT) DESC) Number,
    poi.PO_NO,
    poi.PO_ITEM_NO,
    poi.MAT_NO,
    poi.MAT_DESC ,
    CAST(poi.PO_QTY_ORI AS FLOAT) AS PO_QTY_ORI,
    CAST(poi.PO_QTY_USED AS FLOAT) AS PO_QTY_USED,
    CAST(poi.PO_QTY_REMAIN AS FLOAT) AS PO_QTY_REMAIN,
    poi.UOM,
    [dbo].[fn_date_format](poi.DELIVERY_PLAN_DT) as DELIVERY_PLAN_DT ,
    poi.PRICE_PER_UOM ,
    poi.[LOCAL_AMOUNT] AS ORI_AMOUNT ,
    sloc.SLOC_NAME ,
    plnt.PLANT_NAME,
    CAST((SUM(posi.PO_QTY_USED)/SUM(posi.PO_QTY_ORI))*100 AS INT) PRECENTAGE
FROM TB_R_PO_SUBITEM posi
JOIN TB_R_PO_ITEM poi ON posi.PO_ITEM_NO = poi.PO_ITEM_NO AND posi.PO_NO = poi.PO_NO
JOIN TB_R_PO_H poh ON poi.PO_NO = poh.PO_NO
LEFT JOIN TB_M_PLANT plnt ON poi.PLANT_CD = plnt.PLANT_CD
LEFT JOIN TB_M_SLOC sloc ON poi.PLANT_CD = sloc.PLANT_CD AND poi.SLOC_CD = sloc.SLOC_CD
WHERE poi.PO_NO = @PO and ITEM_CLASS = 'S'
GROUP BY
    poi.PO_NO,
    poi.PO_ITEM_NO,
    poi.MAT_NO,
    poi.MAT_DESC,
    CAST(poi.PO_QTY_ORI AS FLOAT),
    CAST(poi.PO_QTY_USED AS FLOAT),
    CAST(poi.PO_QTY_REMAIN AS FLOAT),
    poi.UOM,
    [dbo].[fn_date_format](poi.DELIVERY_PLAN_DT),
    poi.PRICE_PER_UOM,
    poi.[LOCAL_AMOUNT],
    sloc.SLOC_NAME,
    plnt.PLANT_NAME