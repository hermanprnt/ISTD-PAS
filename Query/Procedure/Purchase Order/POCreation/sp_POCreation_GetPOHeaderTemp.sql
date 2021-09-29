ALTER PROCEDURE sp_POCreation_GetPOHeaderTemp
    @processId BIGINT
AS
BEGIN
    SELECT DISTINCT
        poht.PO_NO PONo,
        poht.VENDOR_CD VendorCode,
        poht.VENDOR_NAME VendorName,
        poht.COUNTRY VendorCountry,
        poht.POSTAL_CODE VendorPostal,
        poht.PHONE VendorPhone,
        poht.FAX VendorFax,
        poht.PURCHASING_GRP_CD PurchasingGroup,
        ISNULL(poht.NEW_CURR_CD, poht.ORI_CURR_CD) Currency,
        poht.ORI_EXCHANGE_RATE ExchangeRate,
        poht.ORI_AMOUNT Amount,
        poht.DOC_DT PODate,
        poht.PO_DESC POHeaderText,
        CASE WHEN ISNULL(poht.SPK_NO, '') = '' THEN 0 ELSE 1 END HasSPK,
        CASE WHEN ISNULL(poh.SYSTEM_SOURCE, 'GPS') = 'GPS' THEN 1 ELSE 0 END IsFromGPS,
		ISNULL(poht.PO_NOTE1, '') Note1,
		ISNULL(poht.PO_NOTE2, '') Note2,
		ISNULL(poht.PO_NOTE3, '') Note3,
		ISNULL(poht.PO_NOTE4, '') Note4,
		ISNULL(poht.PO_NOTE5, '') Note5,
		ISNULL(poht.PO_NOTE6, '') Note6,
		ISNULL(poht.PO_NOTE7, '') Note7,
		ISNULL(poht.PO_NOTE8, '') Note8,
		ISNULL(poht.PO_NOTE9, '') Note9,
		ISNULL(poht.PO_NOTE10, '') Note10,
		tabid.FILE_PATH BidFilePath,
		tabid.FILE_NAME_ORI BidOriFilePath,
		tabid.FILE_PATH QuotFilePath,
		tabid.FILE_NAME_ORI QuotOriFilePath
    FROM TB_T_PO_H poht 
	LEFT JOIN TB_R_PO_H poh ON ISNULL(poht.PO_NO, '') = poh.PO_NO
	LEFT JOIN (Select TOP 1 PROCESS_ID, FILE_PATH, FILE_NAME_ORI from TB_T_ATTACHMENT where PROCESS_ID = @processId AND DELETE_FLAG <> 'Y' AND DOC_TYPE = 'BID' Order by PROCESS_ID, SEQ_NO) tabid ON poht.PROCESS_ID = tabid.PROCESS_ID 
	LEFT JOIN (Select TOP 1 PROCESS_ID,  FILE_PATH, FILE_NAME_ORI from TB_T_ATTACHMENT where PROCESS_ID = @processId AND DELETE_FLAG <> 'Y' AND DOC_TYPE = 'QUOT' Order by PROCESS_ID, SEQ_NO) taquot ON poht.PROCESS_ID = taquot.PROCESS_ID
    WHERE poht.PROCESS_ID = @processId
END