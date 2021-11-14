SELECT DOCUMENT_TYPE doc_type
	,ACTION action
	,SYSTEM system
	,TEST_RUN test_run
	,DOCUMENT_NO doc_no
	,CLOSED closed
	,DOCUMENT_DT doc_date
	,SUBMIT_DT submit_date
	,REQUESTOR requestor
	,COMPANY_CD company_code
	,CURRENCY currency
	,CURRENCY_RATE currency_rate
	,LINE_NO line_no
	,'' closed2
	,REFERENCE_NO ref_doc_no
	,REFERENCE_LINE_NO ref_doc_line_item_no
	,ITEM_CD item_code
	,ITEM_DESCRIPTION item_description
	,PART_CATEGORY part_category
	,INVENTORY_TYPE inventory_type
	,MATERIAL_TYPE material_type
	,SUPPLIER_CD supplier_code
	,ISNULL(ASSET_NO,'') asset
	,WBS_ELEMENT wbs_element
	,COST_CENTER_CD cost_center_changer
	,TOTAL_AMOUNT total_amount
	,QUANTITY quantity
	,UOM uom
FROM TB_H_FUND_COMMITMENT_REQUEST
WHERE PROCESS_ID = @ProcessId

--EXEC PR_CREATION_GET_PARAM_WS @ProcessId