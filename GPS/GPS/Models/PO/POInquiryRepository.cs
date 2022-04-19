using System;
using System.Collections.Generic;
using System.Data;
using GPS.CommonFunc;
using GPS.Constants;
using GPS.Core;
using GPS.Core.ViewModel;
using GPS.Models.Common;
using GPS.ViewModels;
using GPS.ViewModels.PO;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;
using System.Linq;
using System.Data.SqlClient;
using System.Text;
using GPS.Models.PRPOApproval;
using GPS.Constants.PRPOApproval;

namespace GPS.Models.PO
{
    public class POInquiryRepository
    {
        public const String ApprovalDataName = "poapproval";

        private readonly IDBContext db;
        public POInquiryRepository()
        {
            db = DatabaseManager.Instance.GetContext();
            db.SetExecutionMode(DBContextExecutionMode.Direct);
        }

        public string IsEmployee(String noreg)
        {
            String query = "EXEC [dbo].[sp_CheckIsEmployee] @noreg";
            string result = db.SingleOrDefault<string>(query, new { noreg = noreg});
            db.Close();

            return result;
        }
		#region : 20190716 : isid.rgl
        //public PurchaseOrder GetByNo(String poNo, String NoReg)
        //{
        //    String query = "EXEC sp_POInquiry_GetByNo @PONo, @NOREG";
        //    PurchaseOrder result = db.SingleOrDefault<PurchaseOrder>(query, new { PONo = poNo, NOREG = NoReg });
        //    db.Close();

        //    return result;
        //}

        public PurchaseOrder GetByNo(String poNo, String NoReg)
        {
            String query = "EXEC sp_POInquiry_GetByNo @PONo, @NOREG";
            PurchaseOrder result = db.SingleOrDefault<PurchaseOrder>(query, new { PONo = poNo, NOREG = NoReg });
            db.Close();

            return result;
        }
        #endregion

        public IList<PurchaseOrder> GetList(PurchaseOrderSearchViewModel searchViewModel)
        {
            String query = "EXEC sp_POInquiry_GetList @PONo, @Vendor, @Status, @CreatedBy, @DateFrom, @DateTo, @PurchasingGroup, @POHeaderText, @OrderBy, @PRNo, @CurrentPage, @PageSize, @ProcChannel";
            IList<PurchaseOrder> result = db.Fetch<PurchaseOrder>(query, searchViewModel);
            db.Close();

            return result;
        }

        public PaginationViewModel GetListPaging(PurchaseOrderSearchViewModel searchViewModel)
        {
            String query = "EXEC sp_POInquiry_GetListCount @PONo, @Vendor, @Status, @CreatedBy, @DateFrom, @DateTo, @PurchasingGroup, @POHeaderText, @PRNo, @ProcChannel";

            var model = new PaginationViewModel();
            model.DataName = POCommonRepository.DataName;
            model.TotalDataCount = db.SingleOrDefault<Int32>(query, searchViewModel);
            model.PageIndex = searchViewModel.CurrentPage;
            model.PageSize = searchViewModel.PageSize;

            db.Close();

            return model;
        }

        public IList<POApprovalInfoViewModel> GetApprovalList(String poNo)
        {
            String query = "EXEC sp_POInquiry_GetApprovalList @PONo";
            IList<POApprovalInfoViewModel> result = db.Fetch<POApprovalInfoViewModel>(query, new { PONo = poNo });
            db.Close();

            return result;
        }

        public ActionResponseViewModel Cancel(ExecProcedureModel execParam, String poNo, String cancelReason)
        {
            #region NewConnection handle timeout (FID.Riani:20220419)
            string Results = "";
            var resultViewModel = Results.AsActionResponseViewModel();
            string constring = DatabaseManager.Instance.GetConnectionDescriptor("Dev").ConnectionString;
            SqlConnection connect = new SqlConnection(constring);
            SqlDataReader reader = null;
            POSaveResult result = new POSaveResult();
            try
            {

                connect.Open();

                SqlCommand sqlSelect = new SqlCommand("[dbo].[sp_POInquiry_Cancel]", connect);
                sqlSelect.CommandType = CommandType.StoredProcedure;
                sqlSelect.CommandTimeout = 180;
                sqlSelect.Parameters.Add("@currentUser", SqlDbType.BigInt).Value = execParam.CurrentUser;
                sqlSelect.Parameters.Add("@processId", SqlDbType.BigInt).Value = execParam.ProcessId;
                sqlSelect.Parameters.Add("@moduleId", SqlDbType.VarChar).Value = execParam.ModuleId;
                sqlSelect.Parameters.Add("@functionId", SqlDbType.Int).Value = execParam.FunctionId;
                sqlSelect.Parameters.Add("@poNo", SqlDbType.VarChar).Value = poNo;
                sqlSelect.Parameters.Add("@cancelReason", SqlDbType.Int).Value = cancelReason;                
                reader = sqlSelect.ExecuteReader();

                while (reader.Read())
                {
                    Results = (reader[0]).ToString();                   
                }

                connect.Close();                
                if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                    throw new InvalidOperationException(resultViewModel.Message);
            }
            catch (Exception e)
            {
                throw new InvalidOperationException(e.Message);
                connect.Close();
            }

            
            #endregion

            #region old
            /*
            String query = "EXEC sp_POInquiry_Cancel @CurrentUser, 0, @ModuleId, @FunctionId, @PONo, @cancelReason";
            String result = db.ExecuteScalar<String>(query, new { execParam.CurrentUser, execParam.ModuleId, execParam.FunctionId, PONo = poNo, cancelReason = cancelReason });
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);
            */
            #endregion
            return resultViewModel;
            
        }

        public ActionResponseViewModel RejectByVendor(String poNo, String currentUser)
        {
            return RejectItemByVendor(poNo, "", currentUser);
        }

        public ActionResponseViewModel RejectItemByVendor(String poNo, String poItem, String currentUser)
        {
            String query = "EXEC sp_POInquiry_RejectByVendor @CurrentUser, @PONo, @poItem";
            String result = db.ExecuteScalar<String>(query, new { CurrentUser = currentUser, PONo = poNo, poItem = poItem });
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }

        public Dictionary<String, DataTable> GetSPKPdfDataTableList(String poNo)
        {
            var dtList = new Dictionary<String, DataTable>();
            String query = "EXEC sp_POCommon_GetSPKDataTable @PONo";
            DataTable dt;
            using (var dda = new DummyDatabaseAgent())
                dt = dda.FetchDataTable(query, new { PONo = poNo });

            dtList.Add("POSPKDataSet", dt);

            return dtList;
        }

        public List<SystemMaster> GetPdfAddressList(String poNo)
        {
            String query = "EXEC sp_POInquiry_GetPdfAddressList @PONo";
            dynamic param = new { PONo = poNo};
            IList<SystemMaster> result = db.Fetch<SystemMaster>(query, param);
            db.Close();

            return result.ToList();
        }

        public Dictionary<String, DataTable> GetPdfDataTableList(String poNo, String signUrlPrefix, string deliveryAddr, string plan_code)
        {
            var dtList = new Dictionary<String, DataTable>();
            dtList.Add("PODataSet", GetDataAsDataTable(poNo, signUrlPrefix, deliveryAddr));
            dtList.Add("POItemAndSubItemDataSet", GetItemSubItemDataList(poNo, deliveryAddr, plan_code));

            return dtList;
        }

        private DataTable GetDataAsDataTable(String poNo, String signUrlPrefix, string deliveryAddr)
        {
            String query = "EXEC sp_POInquiry_GetPdfData @PONo, @SignUrlPrefix, @DeliveryAddress";
            using (var dda = new DummyDatabaseAgent())
                return dda.FetchDataTable(query, new { PONo = poNo, SignUrlPrefix = signUrlPrefix, DeliveryAddress = deliveryAddr });
        }

        private DataTable GetItemSubItemDataList(String poNo, string deliveryAddr, string plan_code)
        {
            String query = "EXEC sp_POInquiry_GetItemSubItemPdfDataList @PONo, @DeliveryAddress, @Plan_Code";
            using (var dda = new DummyDatabaseAgent())
                return dda.FetchDataTable(query, new { PONo = poNo, DeliveryAddress = deliveryAddr, Plan_Code = plan_code });
        }

        public IList<PRPOItem> GetPOItemSearchList(String poNo, Int32 currentPage, Int32 pageSize)
        {
            String query = "EXEC sp_POCommon_GetPOItemSearchList @PONo, @CurrentPage, @PageSize";
            dynamic param = new { PONo = poNo, CurrentPage = currentPage, PageSize = pageSize };
            IList<PRPOItem> result = db.Fetch<PRPOItem>(query, param);
            db.Close();

            return result;
        }

        public IList<PRPOSubItem> GetPOSubItemSearchList(PRPOSubItemSearchViewModel searchViewModel)
        {
            String query = "EXEC sp_POInquiry_GetPOSubItemSearchList @PONo, @POItemNo, @CurrentPage, @PageSize";
            IList<PRPOSubItem> result = db.Fetch<PRPOSubItem>(query, searchViewModel);
            db.Close();

            return result;
        }

        public string UnlockPO(string poNo, string userid)
        {
            String result = db.ExecuteScalar<String>("EXEC sp_POInquiry_Unlock @PONo, @Userid", new { PONo = poNo, Userid = userid });
            db.Close();

            return result;
        }

        public void UpdateLastDownloadingUser(String currentUser, string poNo)
        {
            dynamic args = new
            {
                CurrentUser = currentUser,
                FunctionId = FunctionId.POInquiry,
                ModuleId = ModuleId.PurchaseOrder,
                PONo = poNo
            };
            String result = db.ExecuteScalar<String>("EXEC sp_POInquiry_UpdateLastDownloadingUser @CurrentUser, 0, @ModuleId, @FunctionId, @PONo", args);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);
        }

        public ActionResponseViewModel CancelValidation(ExecProcedureModel execParam, String poNo)
        {
            String query = "EXEC sp_POInquiry_CancelValidation @CurrentUser, 0,  @PONo";
            String result = db.ExecuteScalar<String>(query, new { execParam.CurrentUser, PONo = poNo });
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }

        public string ForceGeneratePObyJob(string currentUser, string registrationNo)
        {
            String query = "EXECUTE [dbo].[sp_Job_ECatalogue_AutoPOCreation] @Feedback OUTPUT, @UserId, @RegNo";
            IDBContext db = DatabaseManager.Instance.GetContext();
            String return_val = "";
            var feedbackValue = "";
            try
            {

                dynamic args = new
                {
                    UserId = currentUser,
                    RegNo = registrationNo,
                    Feedback = ""
                };

                return_val = db.SingleOrDefault<String>(query, args);

                feedbackValue = return_val;

                return feedbackValue;
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
            finally
            {
                db.Close();
            }
        }

        public string ForceGeneratePO(string currentUser, string registrationNo)
        {
            String query = "EXEC sp_POInquiry_ProcessGeneratePO @UserId, @RegNo";
            IDBContext db = DatabaseManager.Instance.GetContext();
            string message = "";
            try
            {
                dynamic args = new
                {
                    UserId= currentUser,
                    RegNo = registrationNo
                };
                message = db.SingleOrDefault<String>(query, args);

                var resultViewModel = message.AsActionResponseViewModel();
                if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                    throw new InvalidOperationException(resultViewModel.Message);

                return resultViewModel.Message;
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
            finally
            {
                db.Close();
            }
        }

        public List<POMonitoring> GetListPROutstanding(string noreg)
        {
            String query = "SELECT PR_NO, PR_ITEM_NO, MAT_NO, VENDOR_CD, VENDOR_NAME, PURCHASING_GROUP_CD, PROC_CHANNEL_CD, DELIVERY_ADDR, STATUS FROM fnt_POGenerate_GetOutstandingList ('" + noreg + "')";
            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                dynamic args = new
                {
                };
                IList<POMonitoring> result = db.Fetch<POMonitoring>(query, args);

                return result.ToList();
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
            finally
            {
                db.Close();
            }
        }

        public List<POMonitoring> GetListPRMonitoringOutstanding(string process_id)
        {
            String query = "select PR_NO, PR_ITEM_NO, MAT_NO, STATUS, REMARK from TB_R_PO_GENERATE_MONITORING WHERE PROCESS_ID = @PROCESS_ID";
            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                dynamic args = new
                {
                    PROCESS_ID = process_id
                };
                IList<POMonitoring> result = db.Fetch<POMonitoring>(query, args);

                return result.ToList();
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
            finally
            {
                db.Close();
            }
        }

        public List<POMonitoring> GetPOMonitoringList(string PRNo, string Status, string DateFrom, string DateTo, string noreg, int pageSize, int page = 1)
        {
            String query = "exec sp_POInquiry_GetPoMonitoringList @Page , @Length, @pr_no, @status, @process_date_f, @process_date_t, @noreg";
            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                dynamic args = new
                {
                    Page = page,
                    Length = pageSize,
                    pr_no = PRNo,
                    status = Status,
                    process_date_f = DateFrom,
                    process_date_t = DateTo,
                    noreg = noreg
                };
                IList<POMonitoring> result = db.Fetch<POMonitoring>(query, args);

                return result.ToList();
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
            finally
            {
                db.Close();
            }
        }

        public int GetPOMonitoringCount(string PRNo, string Status, string DateFrom, string DateTo, string noreg)
        {
            String query = "exec sp_POInquiry_GetPoMonitoringCount @pr_no, @status, @process_date_f, @process_date_t, @noreg";
            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                dynamic args = new
                {
                    pr_no = PRNo,
                    status = Status,
                    process_date_f = DateFrom,
                    process_date_t = DateTo,
                    noreg = noreg
                };
                var result = db.SingleOrDefault<Int32>(query, args);

                return result;
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
            finally
            {
                db.Close();
            }
        }

        public IList<PurchaseOrderApprovalHistory> GetApprovalHistory(String poNo)
        {
            String query = "EXEC sp_POInquiry_GetApprovalHistory @PONo";
            IList<PurchaseOrderApprovalHistory> result = db.Fetch<PurchaseOrderApprovalHistory>(query, new { PONo = poNo });
            db.Close();

            return result;
        }

        public bool isJobGeneratePO_Finished(string processNo)
        {
            String query = "select COUNT(0) from TB_T_JOB_PO_PROCESSING WHERE PROCESS_ID = @PROCESS_ID";

            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                dynamic args = new
                {
                    PROCESS_ID = processNo
                };
                Int32 result = db.SingleOrDefault<Int32>(query, args);

                return result<=0;
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
            finally
            {
                db.Close();
            }
        }

        public string GetFeedbackAutoPoECatalogue(string processId)
        {
            String query = "EXEC sp_POInquiry_GetFeedbackAutoPoECatalogue @ProcessId";
            IDBContext db = DatabaseManager.Instance.GetContext();
            string message = "";
            try
            {
                dynamic args = new
                {
                    ProcessId = processId
                };
                message = db.SingleOrDefault<String>(query, args);

                var resultViewModel = message.AsActionResponseViewModel();
                if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                    throw new InvalidOperationException(resultViewModel.Message);

                return resultViewModel.Message;
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
            finally
            {
                db.Close();
            }
        }

        //20200129 start
        public List<string> getErrorPosting(string poNo)
        {
            //string result = "";
            List<string> result = new List<string>();
            //IList<PurchaseOrder> result = null;
            string msg = "";
            //string query = "SELECT STUFF((SELECT '\n' + US.[ERROR_MESSAGE] "+
            //               "FROM TB_R_ERR_PO US WHERE US.PO_NO = ss.po_no FOR XML PATH('')), 1, 1, '')"+
            //               "[ERROR_MESSAGE] from TB_R_ERR_PO ss where ss.PO_NO = @PONO group by ss.PO_NO";
            IDBContext db = DatabaseManager.Instance.GetContext();

            try
            {
                dynamic args = new
                {
                    PONO = poNo
                };
                result = db.Fetch<string>("POinquiry/errorDetail", args);
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
        //20200129 end
    }
}