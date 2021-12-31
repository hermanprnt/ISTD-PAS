using System;
using System.Collections.Generic;
using GPS.Models.Common;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;
using GPS.Core;
using GPS.Core.ViewModel;
using System.Data.SqlClient;
using System.Data;

namespace GPS.Models.PR.PRInquiry
{
    public class PRInquiryRepository
    {
        public sealed class SqlFile
        {
            public const String _Root_Folder_Inquiry = "PR/PRInquiry/";

            #region PR INQUIRY
            public const String PRHeaderList = _Root_Folder_Inquiry + "get_prheaderList";
            public const String PRHeaderCount = _Root_Folder_Inquiry + "count_prheaderList";
            public const String PRDownloadExcel = _Root_Folder_Inquiry + "get_prdownloadexcelList";
            public const String ForceGeneratePO = _Root_Folder_Inquiry + "forceGeneratePO";
            #endregion

            #region VIEW DETAIL PR
            public const String DetailPRHeader = _Root_Folder_Inquiry + "get_detailPRH";
            public const String DetailPRItem = _Root_Folder_Inquiry + "get_detailPRItem";
            public const String DetailPRSubItem = _Root_Folder_Inquiry + "get_detailPRSubItem";
            public const String PRItemCount = _Root_Folder_Inquiry + "count_prdetailItemList";
            public const String DetailPRAttachment = _Root_Folder_Inquiry + "get_detailPRAttachment";
            public const String ApprovalDivision = _Root_Folder_Inquiry + "get_approvalDivision";
            public const String ApprovalCoordinator = _Root_Folder_Inquiry + "get_approvalCoordinator";
            public const String ApprovalFinance = _Root_Folder_Inquiry + "get_approvalFinance";
            public const String ApprovalCount = _Root_Folder_Inquiry + "count_approval";
            public const String WorklistHistoryData = _Root_Folder_Inquiry + "get_worklisthistory_data";
            public const String WorklistHistoryCount = _Root_Folder_Inquiry + "count_worklisthistory_data";
            #endregion
            public const String ChkPO = _Root_Folder_Inquiry + "CheckPO"; // 20191015
            public const String ChkDocRefNo = _Root_Folder_Inquiry + "CheckRefDocNo"; // 20191015
            public const String ChkPRItemNo = _Root_Folder_Inquiry + "CheckPRItemNo"; // 20191024
            public const String GetAllPRItemNo = _Root_Folder_Inquiry + "GetAllPRItemNo"; //20191024
            public const String UpdateCancelRem = _Root_Folder_Inquiry + "UpdateCancelRem"; //20191121
            public const String CommitRem = _Root_Folder_Inquiry + "CommitRemBudget";//20191125
            public const String ChkPrDetail = _Root_Folder_Inquiry + "CheckPrDetail";//20191125
            public const String AnPrItem = _Root_Folder_Inquiry + "AnotherPrItem";//20191125

            #region EDIT PR
            public const String EditPRHeader = _Root_Folder_Inquiry + "call_validationeditPR";
            #endregion

            #region UNLOCK PR
            public const String UnlockPR = _Root_Folder_Inquiry + "unlock_pr";
            #endregion

            #region CANCEL PR
            public const String CancelValidation = _Root_Folder_Inquiry + "cancel_validationPR";
            public const String CancelInit = _Root_Folder_Inquiry + "init_cancelPR";
            public const String CancelBudget = _Root_Folder_Inquiry + "cancel_budgetPR";
            public const String CancelQuota = _Root_Folder_Inquiry + "cancel_quotaPR";
            public const String CancelPR = _Root_Folder_Inquiry + "do_cancelPR";
            public const String GetCancelReason = _Root_Folder_Inquiry + "get_prcancelreason";
            public const String DeleteRem = _Root_Folder_Inquiry + "cancel_budgetPRrem";//20191016 for cancel remaining budget
            #endregion
        }

        private PRInquiryRepository() { }
        private static PRInquiryRepository instance = null;

        public static PRInquiryRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new PRInquiryRepository();
                }
                return instance;
            }
        }

        #region DETAIL PR
        public Tuple<int, string> CountPRItem(string prno)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string message = "";
            int result = 0;
            try
            {
                dynamic args = new { PR_NO = prno };
                result = db.SingleOrDefault<int>(SqlFile.PRItemCount, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }
            return new Tuple<int,string>(result, message);
        }

        public Tuple<int, string> CountApprovalData(string prno)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string message = "";
            int result = 0;
            try
            {
                dynamic args = new { PR_NO = prno };
                result = db.SingleOrDefault<int>(SqlFile.ApprovalCount, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }
            return new Tuple<int, string>(result, message);
        }

        public PRInquiry GetDetailPRH(string PRNO)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            PRInquiry resultquery = new PRInquiry();
            try
            {
                dynamic args = new { PR_NO = PRNO };
                resultquery = db.SingleOrDefault<PRInquiry>(SqlFile.DetailPRHeader, args);
            }
            catch (Exception e)
            {
                resultquery.MESSAGE = e.Message;
            }
            finally { db.Close(); }

            return resultquery;
        }

        public Tuple<List<PRInquiry>, string> GetDetailPRItem(string PRNO, int pageSize, int page)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<PRInquiry> resultquery = new List<PRInquiry>();
            string message = "";

            try
            {
                dynamic args = new
                {
                    PR_NO = PRNO,
                    start = page,
                    length = pageSize
                };
                resultquery = db.Fetch<PRInquiry>(SqlFile.DetailPRItem, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally { db.Close(); }

            return new Tuple<List<PRInquiry>, string>(resultquery, message);
        }

        public List<PRInquiry> GetDetailPRSubItem(string PR_NO, string PR_ITEM_NO)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<PRInquiry> resultquery = new List<PRInquiry>();
            string message = "";

            try
            {
                dynamic args = new
                {
                    PR_NO = PR_NO,
                    PR_ITEM_NO = PR_ITEM_NO
                };
                resultquery = db.Fetch<PRInquiry>(SqlFile.DetailPRSubItem, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally { db.Close(); }

            return resultquery;
        }

        public Tuple<List<PRInquiry>, string> GetDetailAttachment(string PRNO)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<PRInquiry> resultquery = new List<PRInquiry>();
            string message = "";
            try
            {
                dynamic args = new { PR_NO = PRNO };
                resultquery = db.Fetch<PRInquiry>(SqlFile.DetailPRAttachment, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }

            return new Tuple<List<PRInquiry>, string>(resultquery, message);
        }

        public Tuple<List<Worklist>, string> GetApproval(string type, string PRNO, int pageSize, int page)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<Worklist> resultquery = new List<Worklist>();
            string message = "";
            string sqlfile = "";

            try
            {
                switch (type)
                {
                    case "Division": {
                        sqlfile = SqlFile.ApprovalDivision;
                        break;
                    }
                    case "Coordinator":{
                        sqlfile = SqlFile.ApprovalCoordinator;
                        break;
                    }
                    case "Finance": {
                        sqlfile = SqlFile.ApprovalFinance;
                        break;
                    }
                }

                dynamic args = new
                {
                    PR_NO = PRNO,
                    start = page,
                    length = pageSize
                };
                resultquery = db.Fetch<Worklist>(sqlfile, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally { db.Close(); }

            return new Tuple<List<Worklist>, string>(resultquery, message);
        }
        #endregion

        #region SEARCH PR
        public Tuple<List<PRInquiry>, string> ListData(PRInquiry param, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<PRInquiry> result = new List<PRInquiry>();
            string message = "";
            try
            {
                dynamic args = new
                {
                    PR_NO = param.PR_NO == null ? "" : param.PR_NO,
                    param.PR_TYPE,
                    param.VENDOR_CD,
                    param.PLANT_CD,
                    param.SLOC_CD,
                    DIVISION_CD = param.DIVISION_ID,
                    DATEFROM = param.DOC_DATE_FROM_STRING,
                    DATETO = param.DOC_DATE_TO_STRING,
                    param.PROJECT_NO,
                    PR_STATUS_FLAG = param.PR_STATUS,
                    PR_STATUS_DESC = param.PR_STATUS_DESC,
                    param.PR_DESC,
                    param.PR_COORDINATOR,
                    param.WBS_NO,
                    DETAIL_STS = param.PR_DETAIL_STS,
                    param.CREATED_BY,
                    param.ORDER_BY,
                    Start = start,
                    Length = length,
                    PO_NO = param.PO_NO == null ? "" : param.PO_NO,
                    PROCUREMENT_CHANNEL = param.PROCUREMENT_CHANNEL
                };
                result = db.Fetch<PRInquiry>(SqlFile.PRHeaderList, args);
            }
            catch(Exception e) {
                message = e.Message;
            }
            finally { 
                db.Close();
            }

            return new Tuple<List<PRInquiry>,string>(result, message);
        }

        public Tuple<int, string> CountRetrievedPRData(PRInquiry param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            int result = 0;
            string message = "";
            try
            {
                dynamic args = new
                {
                    PR_NO = param.PR_NO,
                    PR_TYPE = param.PR_TYPE,
                    VENDOR_CD = param.VENDOR_CD,
                    PLANT_CD = param.PLANT_CD,
                    SLOC_CD = param.SLOC_CD,
                    DIVISION_CD = param.DIVISION_ID,
                    DATEFROM = param.DOC_DATE_FROM_STRING,
                    DATETO = param.DOC_DATE_TO_STRING,
                    PROJECT_NO = param.PROJECT_NO,
                    PR_STATUS_FLAG = param.PR_STATUS,
                    PR_STATUS_DESC = param.PR_STATUS_DESC,
                    PR_DESC = param.PR_DESC,
                    PR_COORDINATOR = param.PR_COORDINATOR,
                    WBS_NO = param.WBS_NO,
                    DETAIL_STS = param.PR_DETAIL_STS,
                    CREATED_BY = param.CREATED_BY,
                    PO_NO = param.PO_NO == null ? "" : param.PO_NO,
                    PROCUREMENT_CHANNEL = param.PROCUREMENT_CHANNEL
                };

                result = db.SingleOrDefault<int>(SqlFile.PRHeaderCount, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }
            return new Tuple<int,string>(result, message);
        }
        #endregion

        #region EDIT PR
        public string EditPR(string PR_NO, string userid, string noreg)
        {
            string result = "";
            IDBContext db = DatabaseManager.Instance.GetContext();

            try
            {
                dynamic args = new
                {
                    PR_NO = PR_NO,
                    USER_ID = userid,
                    NOREG = noreg
                };
                result = db.SingleOrDefault<string>(SqlFile.EditPRHeader, args);
            }
            catch (Exception e)
            {
                result = e.Message;
            }
            finally
            {
                db.Close();
            }

            return result;
        }
        #endregion

        #region UNLOCK PR
        public string UnlockPR(string PR_NO, string PROCESS_ID, string userid)
        {
            string result = "";
            IDBContext db = DatabaseManager.Instance.GetContext();

            try
            {
                dynamic args = new
                {
                    PR_NO = PR_NO,
                    PROCESS_ID = PROCESS_ID,
                    USER_ID = userid
                };
                result = db.SingleOrDefault<string>(SqlFile.UnlockPR, args);
            }
            catch (Exception e)
            {
                result = e.Message;
            }
            finally
            {
                db.Close();
            }

            return result;
        }
        #endregion

        #region CANCEL PR
        public string CancelValidation(string PR_NO, string userid, string noreg)
        {
            string result = "";
            IDBContext db = DatabaseManager.Instance.GetContext();

            try
            {
                dynamic args = new
                {
                    PR_NO = PR_NO,
                    USER_ID = userid,
                    NOREG = noreg
                };
                result = db.SingleOrDefault<string>(SqlFile.CancelValidation, args);
            }
            catch (Exception e)
            {
                result = e.Message;
            }
            finally
            {
                db.Close();
            }

            return result;
        }

        public Tuple<string, string, int> CancelInit(string PR_NO, string userid, string username)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string status = "";
            string message = "";

            try
            {
                dynamic args = new
                {
                    PR_NO = PR_NO,
                    USER_ID = userid,
                    USERNAME = username
                };
                PRInquiry result = db.SingleOrDefault<PRInquiry>(SqlFile.CancelInit, args);
                status = result.PROCESS_STATUS;
                message = result.MESSAGE;
            }
            catch (Exception e)
            {
                status = "ERROR";
                message = e.Message;
            }
            finally
            {
                db.Close();
            }

            return new Tuple<string, string, int>(status, message, 1);
        }

        public Tuple<string, string, int> CancelBudget(string PROCESS_ID, string PR_NO, string userid, string processType, int row)
        {
            #region FID.Ridwan:20211210 -> NewConnection handle timeout
            string result = "";
            string status = "";
            int total_success = 0;
            string constring = DatabaseManager.Instance.GetConnectionDescriptor("Dev").ConnectionString;
            SqlConnection connect = new SqlConnection(constring);
            SqlDataReader reader = null;

            try
            {

                connect.Open();

                SqlCommand sqlSelect = new SqlCommand("[dbo].[sp_prinquiry_cancelBudgetProcessing]", connect);
                sqlSelect.CommandType = CommandType.StoredProcedure;
                sqlSelect.CommandTimeout = 180;

                sqlSelect.Parameters.Add("@PROCESS_ID", SqlDbType.VarChar).Value = PROCESS_ID;
                sqlSelect.Parameters.Add("@PR_NO", SqlDbType.VarChar).Value = PR_NO;
                sqlSelect.Parameters.Add("@USER_ID", SqlDbType.VarChar).Value = userid;
                sqlSelect.Parameters.Add("@PROCESS_TYPE", SqlDbType.VarChar).Value = processType;
                sqlSelect.Parameters.Add("@ROW_ROLLBACK", SqlDbType.Int).Value = row;
                sqlSelect.Parameters.Add("@TriggerType", SqlDbType.VarChar).Value = "SC";

                reader = sqlSelect.ExecuteReader();

                while (reader.Read())
                {
                    result = (reader[0]).ToString();
                    status = (reader[1]).ToString();
                    total_success = Convert.ToInt32(reader[2]);
                }

                connect.Close();
            }
            catch (Exception e)
            {
                result = e.Message;
                status = "EXCEPTION";
                connect.Close();
            }


            #endregion

            #region remark
            //IDBContext db = DatabaseManager.Instance.GetContext();
            //string status = "";
            //string message = "";
            //int total_success = 0;

            //try
            //{
            //    dynamic args = new
            //    {
            //        PROCESS_ID = PROCESS_ID,
            //        PR_NO = PR_NO,
            //        USER_ID = userid,
            //        PROCESS_TYPE = processType,
            //        ROW_ROLLBACK = row
            //    };
            //    PRInquiry result = db.SingleOrDefault<PRInquiry>(SqlFile.CancelBudget, args);
            //    status = result.PROCESS_STATUS;
            //    message = result.MESSAGE;
            //    total_success = result.NUMBER_OF_SUCCESS;
            //}
            //catch (Exception e)
            //{
            //    status = "ERROR";
            //    message = e.Message;
            //}
            //finally
            //{
            //    db.Close();
            //}
            #endregion

            return new Tuple<string, string, int>(status, result, total_success);
        }

        public Tuple<string, string, int> CancelQuota(string PROCESS_ID, string PR_NO, string userid, string ProcessType)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string message = "";
            string status = "";
            try
            {
                dynamic args = new
                {
                    USER_ID = userid,
                    PROCESS_ID = PROCESS_ID,
                    PR_NO = PR_NO,
                    PROCESS_TYPE = ProcessType
                };
                PRInquiry result = db.SingleOrDefault<PRInquiry>(SqlFile.CancelQuota, args);
                message = result.MESSAGE;
                status = result.PROCESS_STATUS;
            }
            catch (Exception e)
            {
                message = e.Message;
                status = "EXCEPTION";
            }
            finally
            {
                db.Close();
            }
            return new Tuple<string, string, int>(status, message, 0);
        }

        public Tuple<string, string, int> CancelPR(string PROCESS_ID, string PR_NO, string userid, string CANCEL_REASON)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string message = "";
            string status = "";
            try
            {
                dynamic args = new
                {
                    USER_ID = userid,
                    PROCESS_ID = PROCESS_ID,
                    PR_NO = PR_NO,
                    CANCEL_REASON = CANCEL_REASON
                };
                PRInquiry result = db.SingleOrDefault<PRInquiry>(SqlFile.CancelPR, args);
                message = result.MESSAGE;
                status = result.PROCESS_STATUS;
            }
            catch (Exception e)
            {
                message = e.Message;
                status = "EXCEPTION";
            }
            finally
            {
                db.Close();
            }
            return new Tuple<string, string, int>(status, message, 0);
        }
        #endregion

        #region Downlaod Excel
        public Tuple<List<PRInquiryExcel>, string> ListDownloadExcel(PRInquiry param, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<PRInquiryExcel> result = new List<PRInquiryExcel>();
            string message = "";
            try
            {
                dynamic args = new
                {
                    PR_NO = param.PR_NO == null ? "" : param.PR_NO,
                    param.PR_TYPE,
                    param.VENDOR_CD,
                    param.PLANT_CD,
                    param.SLOC_CD,
                    DIVISION_CD = param.DIVISION_ID,
                    DATEFROM = param.DOC_DATE_FROM_STRING,
                    DATETO = param.DOC_DATE_TO_STRING,
                    param.PROJECT_NO,
                    PR_STATUS_FLAG = param.PR_STATUS,
                    PR_STATUS_DESC = param.PR_STATUS_DESC,
                    param.PR_DESC,
                    param.PR_COORDINATOR,
                    param.WBS_NO,
                    DETAIL_STS = param.PR_DETAIL_STS,
                    param.CREATED_BY,
                    param.ORDER_BY,
                    PO_NO = param.PO_NO == null ? "" : param.PO_NO,
                    PROCUREMENT_CHANNEL = param.PROCUREMENT_CHANNEL,
                    LIMITCOUNT = length
                };
                result = db.Fetch<PRInquiryExcel>(SqlFile.PRDownloadExcel, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }

            return new Tuple<List<PRInquiryExcel>, string>(result, message);
        }
        #endregion

        public string GetPRCancelReason(string PR_NO)
        {
            string result = "";
            IDBContext db = DatabaseManager.Instance.GetContext();

            try
            {
                dynamic args = new
                {
                    PR_NO = PR_NO
                };
                result = db.SingleOrDefault<string>(SqlFile.GetCancelReason, args);
            }
            catch (Exception e)
            {
                result = e.Message;
            }
            finally
            {
                db.Close();
            }

            return result;
        }

        public Tuple<List<WorklistHistory>, string> GetWorklistHistory(string PRNO, int pageSize, int page)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<WorklistHistory> resultquery = new List<WorklistHistory>();
            string message = "";

            try
            {
                dynamic args = new
                {
                    DOC_NO = PRNO,
                    start = page,
                    length = pageSize
                };
                resultquery = db.Fetch<WorklistHistory>(SqlFile.WorklistHistoryData, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally { db.Close(); }

            return new Tuple<List<WorklistHistory>, string>(resultquery, message);
        }

        public Tuple<int, string> CountWorklistHistory(string prno)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string message = "";
            int result = 0;
            try
            {
                dynamic args = new { DOC_NO = prno };
                result = db.SingleOrDefault<int>(SqlFile.WorklistHistoryCount, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }
            return new Tuple<int, string>(result, message);
        }

        #region Cancel Remain Budget
        //20191014
        public int ChkPONo(string pPR_NO)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            int result = 0;
            string msg = "";
            try
            {
                dynamic args = new { PR_NO = pPR_NO };
                result = db.SingleOrDefault<int>(SqlFile.ChkPO, args);
            }
            catch (Exception ex)
            {
                msg = ex.Message;
            }
            finally
            {
                db.Close();
            }
            return result;
        }

        //20191015
        public int ChkRefDocNo(string pPR_NO)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            int result = 0;
            string msg = "";

            try
            {
                dynamic args = new { PR_NO = pPR_NO };
                result = db.SingleOrDefault<int>(SqlFile.ChkDocRefNo, args);
            }
            catch (Exception ex)
            {
                msg = ex.Message;
            }
            finally
            {
                db.Close();
            }
            return result;
        }

        //20191016
        public Tuple<string, string, int> CancelBudgetRem(string PROCESS_ID, string PR_NO, string ITEM_NO, string userid, string processType, int row)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string status = "";
            string message = "";
            int total_success = 0;

            try
            {
                dynamic args = new
                {
                    PROCESS_ID = PROCESS_ID,
                    PR_NO = PR_NO,
                    ITEM_NO = ITEM_NO,
                    USER_ID = userid,
                    PROCESS_TYPE = processType,
                    ROW_ROLLBACK = row
                };
                PRInquiry result = db.SingleOrDefault<PRInquiry>(SqlFile.DeleteRem, args);
                status = result.PROCESS_STATUS;
                message = result.MESSAGE;
                total_success = result.NUMBER_OF_SUCCESS;
            }
            catch (Exception e)
            {
                status = "ERROR";
                message = e.Message;
            }
            finally
            {
                db.Close();
            }

            return new Tuple<string, string, int>(status, message, total_success);
        }

        //20191024
        public int ChkPRItemNo(string pPR_NO)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            int result = 0;
            string msg = "";

            try
            {
                dynamic args = new { PR_NO = pPR_NO };
                result = db.SingleOrDefault<int>(SqlFile.ChkPRItemNo, args);
            }
            catch (Exception ex)
            {
                msg = ex.Message;
            }
            finally
            {
                db.Close();
            }

            return result;
        }

        //20191024
        //public List<PRInquiry> GetAllPRItem(string pPR_NO, string itemNo)
        //{
        //    IDBContext db = DatabaseManager.Instance.GetContext();
        //    List<PRInquiry> resultquery = new List<PRInquiry>();
        //    string msg = "";

        //    try
        //    {
        //        dynamic args = new { PR_NO = pPR_NO, ITEM_NO = itemNo};
        //        resultquery = db.Fetch<PRInquiry>(SqlFile.GetAllPRItemNo, args);
        //    }
        //    catch (Exception ex)
        //    {
        //        msg = ex.Message;
        //    }
        //    finally
        //    {
        //        db.Close();
        //    }

        //    return resultquery;
        //}

        //20191121
        public string UpdateCancelRem(string PRNO, string ITEM_NO, string userId)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";
            string msg = "";
            try
            {
                dynamic args = new { PR_NO = PRNO, ITEM_NO = ITEM_NO, USER_ID = userId };
                result = db.SingleOrDefault<string>(SqlFile.UpdateCancelRem, args);
            }
            catch (Exception e)
            {
                msg = e.Message;
            }
            finally { db.Close(); }

            return result;
        }

        //20191125
        public Tuple<string, string, int> CommitBudgetRemain(string processId, string prNo, string itemNo, string userId, string processType, int row)
        {
            string status = "";
            string message = "";
            int total_success = 0;
            IDBContext db = DatabaseManager.Instance.GetContext();

            try
            {
                dynamic args = new
                {
                    PROCESS_ID = processId,
                    PR_NO = prNo,
                    ITEM_NO = itemNo,
                    USER_ID = userId,
                    PROCESS_TYPE = processType,
                    ROW_ROLLBACK = row
                };
                PRInquiry result = db.SingleOrDefault<PRInquiry>(SqlFile.CommitRem, args);
                status = result.PROCESS_STATUS;
                message = result.MESSAGE;
                total_success = result.NUMBER_OF_SUCCESS;
            }
            catch(Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }
            return new Tuple<string, string, int>(status, message, total_success);
        }

        //20191125
        public List<PRInquiry> chkPrDetail(string prNo, string itemNo)
        {
            List<PRInquiry> resultquery = new List<PRInquiry>();
            string msg = "";
            IDBContext db = DatabaseManager.Instance.GetContext();

            try
            {
                dynamic args = new { PR_NO = prNo, ITEM_NO = itemNo };
                resultquery = db.Fetch<PRInquiry>(SqlFile.ChkPrDetail, args);
            }
            catch (Exception e)
            {
                msg = e.Message;
            }
            finally
            {
                db.Close();
            }

            return resultquery;
        }

        //20191125
        public int AnotherPrItem(string prNo, string itemNo)
        {
            int result = 0;
            string msg = "";
            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                dynamic args = new { PR_NO = prNo, ITEM_NO = itemNo };
                result = db.SingleOrDefault<int>(SqlFile.AnPrItem, args);
            }
            catch (Exception e)
            {
                msg = e.Message;
            }
            finally
            {
                db.Close();
            }
            return result;
        }
        #endregion
    }
}