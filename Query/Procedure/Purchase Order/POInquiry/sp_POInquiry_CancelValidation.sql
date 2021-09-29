CREATE PROCEDURE [dbo].[sp_POInquiry_CancelValidation]  
    @currentUser VARCHAR(50),  
    @processId BIGINT,   
    @poNo VARCHAR(11)  
AS  
BEGIN  
    DECLARE  
        @message VARCHAR(MAX),  
        @@EXIST INT

		SET @message = 'S|PO Cancelation succesfully pass for validation'
		SELECT @@EXIST = COUNT(1) 
							FROM TB_R_PO_H h
							INNER JOIN TB_R_PO_ITEM i ON i.PO_NO = h.PO_NO
						WHERE h.PO_NO = @poNo AND ISNULL(i.PO_QTY_USED, 0) <> 0 and i.ITEM_CLASS='M'

		IF(@@EXIST <= 0)
		BEGIN
			SELECT  @@EXIST = COUNT(1) 
					FROM TB_R_PO_H h
					INNER JOIN TB_R_PO_ITEM i ON i.PO_NO = h.PO_NO
					INNER JOIN TB_R_PO_SUBITEM si on si.PO_NO = h.PO_NO and si.PO_ITEM_NO = i.PO_ITEM_NO
				WHERE h.PO_NO = @poNo AND ISNULL(si.PO_QTY_USED, 0) <> 0 and i.ITEM_CLASS='S'
		END

		IF(@@EXIST > 0)
		BEGIN
			SELECT @message = 'E|Document No <b>' + @poNo + '</b> cannot be cancelled. There is item(s) that already created into GR/SA.'
		END


		SELECT @message  
END