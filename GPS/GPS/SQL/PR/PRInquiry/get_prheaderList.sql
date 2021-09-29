/*** Select Data based on search criteria				***/
/** Created By      : Reggy Budiana						**/
/** Created Date    : 03/02/2015						**/
/** Changed By      : -									**/
/** Changed Date    : -									**/
/*  Used In         : + PRCreationRepository/ListData	*/

EXEC [dbo].[sp_prinquiry_getListPRH]
@PR_NO,
@PR_TYPE,
@VENDOR_CD,
@PLANT_CD,
@SLOC_CD,
@DIVISION_CD,
@DATEFROM,
@DATETO,
@PROJECT_NO,
@PR_STATUS_FLAG,
@PR_STATUS_DESC,
@PR_DESC,
@PR_COORDINATOR,
@WBS_NO,
@DETAIL_STS,
@CREATED_BY,
@ORDER_BY,
@PO_NO,
@PROCUREMENT_CHANNEL,
@Start,
@Length