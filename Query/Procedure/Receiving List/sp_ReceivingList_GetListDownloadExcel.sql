SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
IF EXISTS (SELECT * FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].sp_ReceivingList_GetListDownloadExcel') AND type IN ( N'P', N'PC' ))
  DROP PROCEDURE [dbo].sp_ReceivingList_GetListDownloadExcel

GO

CREATE PROCEDURE [dbo].[sp_ReceivingList_GetListDownloadExcel]  
    @receivingNo VARCHAR(11), @receivingDateFrom DATETIME, @receivingDateTo DATETIME, @vendor VARCHAR(4),  
    @poNo VARCHAR(11), @status VARCHAR(3), @user VARCHAR (20),@HeaderText VARCHAR (30), @SAPDocNo VARCHAR (11)  
AS
BEGIN
		-- ===================================================================  
		-- Author  : Asep Syahidin 
		-- Create date : 22/02/2017  
		-- Description : Get Receiving List for Download to excel 
		-- ===================================================================
  
		select 
			gr.MAT_DOC_NO AS [RECEIVING_NO],
			gr.MAT_DOC_ITEM_NO As [RECEIVING_ITEM_NO],
			gr.DOCUMENT_DT AS [RECEIVING_DATE],
			gr.HEADER_TEXT AS [HEADER_TEXT],
			gr.MOVEMENT_QTY As [RECEIVING_QUANTITY],
			po_item.PO_QTY_ORI As [PO_QUANTITY],
			po_item.PO_QTY_REMAIN AS [REMAINING_QUANTITY],
			gr.GR_IR_AMOUNT AS [RECEIVING_AMOUNT],
			po_h.VENDOR_CD AS [VENDOR_CD],
			po_h.VENDOR_NAME AS [VENDOR_NAME],
			st.STATUS_DESC AS [STATUS],
			gr.POSTING_DT AS [POSTING_DATE],
			gr.SAP_MAT_DOC_NO AS [DOCUMENT_NO],
			gr.PO_NO AS [PO_NO],
			gr.PO_ITEM AS [PO_ITEM_NO],
			po_item.PR_NO AS [PR_NO],
			po_item.PO_ITEM_NO AS [PR_ITEM_NO],
			gr.CANCEL_DT AS [CANCEL_DATE],
			gr.CANCEL_REASON AS [CANCEL_REASON]
		FROM TB_R_GR_IR gr
		INNER JOIN TB_R_PO_H po_h ON po_h.PO_NO = gr.PO_NO
		INNER JOIN TB_R_PO_ITEM po_item ON po_item.PO_NO = po_h.PO_NO AND po_item.PO_ITEM_NO = gr.PO_ITEM 
		LEFT JOIN TB_M_STATUS st ON st.STATUS_CD = gr.STATUS_CD AND st.DOC_TYPE = 'GR'
		WHERE gr.COMPONENT_PRICE_CD = 'PB00'  
				AND ISNULL(gr.MAT_DOC_NO, '') LIKE '%' + ISNULL(@receivingNo, '') + '%'  
				AND (ISNULL(po_h.VENDOR_CD, '') LIKE '%' + ISNULL(@vendor, '') + '%'  
					OR ISNULL(po_h.VENDOR_NAME, '') LIKE '%' + ISNULL(@vendor, '') + '%')  
				AND ISNULL(gr.PO_NO, '') LIKE '%' + ISNULL(@poNo, '') + '%'  
				AND ISNULL(gr.HEADER_TEXT, '') LIKE '%' + ISNULL(@HeaderText, '') + '%'  
				AND ISNULL(gr.SAP_MAT_DOC_NO, '') LIKE '%' + ISNULL(@SAPDocNo, '') + '%'  
				AND ISNULL(gr.STATUS_CD, '') LIKE '%' + ISNULL(@status, '') + '%'  
				AND (ISNULL(gr.CREATED_DT, CAST('1753-1-1' AS DATETIME))  
					BETWEEN ISNULL(@receivingDateFrom, CAST('1753-1-1' AS DATETIME))  
					AND DATEADD(MILLISECOND, 86399998, ISNULL(@receivingDateTo, CAST('9999-12-31' AS DATETIME)))  
				) 
		ORDER BY gr.MAT_DOC_NO, gr.CREATED_DT  
END