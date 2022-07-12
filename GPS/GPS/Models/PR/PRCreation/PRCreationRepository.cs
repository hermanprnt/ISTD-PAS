using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.PR.PRCreation
{
    public class PRCreationRepository
    {
        public sealed class SqlFile
        {
            public const String _Root_Folder_Creation = "PR/PRCreation/";
            public const String _Root_Folder_Creation_DataList = _Root_Folder_Creation + "DataList/";

            #region PRCREATION GRIDLOOKUP
            public const String ValClassList = _Root_Folder_Creation_DataList + "get_valclassList";
            public const String ValClassCount = _Root_Folder_Creation_DataList + "count_valclassList";
            public const String MatnoList = _Root_Folder_Creation_DataList + "get_matnoList";
            public const String MatnoCount = _Root_Folder_Creation_DataList + "count_matnoList";
            public const String GLAccountList = _Root_Folder_Creation_DataList + "get_glaccountList";
            public const String GLAccountCount = _Root_Folder_Creation_DataList + "count_glaccountList";
            public const String WBSList = _Root_Folder_Creation_DataList + "get_wbsList";
            public const String WBSCount = _Root_Folder_Creation_DataList + "count_wbsList";
            public const String AssetLocList = _Root_Folder_Creation_DataList + "get_assetlocList";
            #endregion

            #region PRCREATION
            public const String CheckLocking = _Root_Folder_Creation + "pr_checkLocking";
            public const String CreationInit = _Root_Folder_Creation + "pr_creationInit";
            public const String GetUserDescription = _Root_Folder_Creation + "get_userDescription";
            public const String PRHeaderEditData = _Root_Folder_Creation + "get_prheaderEditData";
            public const String PRAttachmentEditData = _Root_Folder_Creation + "get_prattachmentEditData";
            public const String LastProcessIDOnTemp = _Root_Folder_Creation + "get_lastprocessIDonTemp";
            public const String PRSavingValidation = _Root_Folder_Creation + "validate_savePR";
            public const String PRSavingInitialValidation = _Root_Folder_Creation + "cek_tb_t_lock";
            public const String PRSavingProcessing = _Root_Folder_Creation + "call_savingProcessing";
            public const String GetErrorLog = _Root_Folder_Creation + "get_errorLog";
            public const String DeletedTempFilesList = _Root_Folder_Creation + "get_deletedTempFiles";
            public const String SavedTempFilesList = _Root_Folder_Creation + "get_savedTempFiles";
            public const String DeleteTempbyUserID = _Root_Folder_Creation + "delete_tempbyUserID";
            public const String DeleteAllTempData = _Root_Folder_Creation + "delete_allTempData";
            #endregion

            #region PRCREATION HEADER
            public const String SavePRHTempData = _Root_Folder_Creation + "insert_prhtempData";
            public const String ValidateEditPRD = _Root_Folder_Creation + "validate_editDetailPR";
            public const String GeneratePRNumber = _Root_Folder_Creation + "generate_PRNo";
            public const String QuotaCalculation = _Root_Folder_Creation + "call_quotaCalculation";
            public const String BudgetCalculation = _Root_Folder_Creation + "call_budgetCalculation";
            #endregion

            #region PRCREATION ITEM
            public const String ItemDetailEditData = _Root_Folder_Creation + "get_itemdetailEditData";
            public const String LastSequenceOnItem = _Root_Folder_Creation + "get_lastsequenceOnItem";
            public const String SaveItemTempData = _Root_Folder_Creation + "insert_itemtempData";
            public const String DeleteItemTempData = _Root_Folder_Creation + "delete_itemtempData";
            public const String CopyTempData = _Root_Folder_Creation + "copy_tempData";
            public const String ListItemTempData = _Root_Folder_Creation + "list_tempData";
            #endregion

            #region PRCREATION SUB ITEM
            public const String LastSequenceOnSubItem = _Root_Folder_Creation + "get_lastsequenceOnSubItem";
            public const String SaveSubItemTempData = _Root_Folder_Creation + "insert_subitemtempData";
            public const String SubItemDetailEditData = _Root_Folder_Creation + "get_subitemdetailEditData";
            public const String DeleteSelectedSubItemTemp = _Root_Folder_Creation + "deleteselected_subitemTemp";
            #endregion

            #region PRCREATION ATTACHMENT
            public const String SaveAttachedFile = _Root_Folder_Creation + "insert_attachedFile";
            public const String PRAttachmentbyType = _Root_Folder_Creation + "get_prattachmentbyType";
            public const String DeleteTempFile = _Root_Folder_Creation + "delete_tempFile";
            #endregion
        }

        private PRCreationRepository() { }
        private static PRCreationRepository instance = null;

        public static PRCreationRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new PRCreationRepository();
                }
                return instance;
            }
        }

        #region GRID LOOKUP
        public IEnumerable<PRCreation> getAssetLocation()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            IEnumerable<PRCreation> result = db.Fetch<PRCreation>(SqlFile.AssetLocList);
            db.Close();

            return result;
        }

        public int CountValClass(PRCreation param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                VALUATION_CLASS_PARAM = param.VALUATION_CLASS_PARAM,
                PR_COORDINATOR = param.PR_COORDINATOR,
                PR_TYPE = param.PR_TYPE
            };
            int result = db.SingleOrDefault<int>(SqlFile.ValClassCount, args);
            db.Close();
            return result;
        }

        public IEnumerable<PRCreation> GetDataValuationClass(PRCreation param, int pageSize, int page)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                VALUATION_CLASS_PARAM = param.VALUATION_CLASS_PARAM,
                PR_COORDINATOR = param.PR_COORDINATOR,
                PR_TYPE = param.PR_TYPE,
                start = page,
                length = pageSize
            };
            IEnumerable<PRCreation> result = db.Fetch<PRCreation>(SqlFile.ValClassList, args);
            db.Close();
            return result;
        }

        public int CountMatnoConst(PRCreation param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                MAT_NUMBER_PARAM = param.MAT_NUMBER_PARAM,
                VALUATION_CLASS = param.VALUATION_CLASS,
                PLANT_CD = param.PLANT_CD,
                PR_COORDINATOR = param.PR_COORDINATOR,
                PR_TYPE = param.PR_TYPE,
                ITEM_TYPE = param.ITEM_TYPE
            };
            int result = db.SingleOrDefault<int>(SqlFile.MatnoCount, args);
            db.Close();
            return result;
        }

        public IEnumerable<PRCreation> GetDataMatNumberConst(PRCreation param, int pageSize, int page)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                MAT_NUMBER_PARAM = param.MAT_NUMBER_PARAM,
                VALUATION_CLASS = param.VALUATION_CLASS,
                PLANT_CD = param.PLANT_CD,
                PR_COORDINATOR = param.PR_COORDINATOR,
                PR_TYPE = param.PR_TYPE,
                ITEM_TYPE = param.ITEM_TYPE,
                start = page,
                length = pageSize
            };
            IEnumerable<PRCreation> result = db.Fetch<PRCreation>(SqlFile.MatnoList, args);
            db.Close();
            return result;
        }

        public int CountGLAccount(PRCreation param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                GL_ACCOUNT_PARAM = param.GL_ACCOUNT_PARAM,
                WBS_NO = param.WBS_NO
            };
            int result = db.SingleOrDefault<int>(SqlFile.GLAccountCount, args);
            db.Close();
            return result;
        }

        public IEnumerable<PRCreation> GetGLAccount(PRCreation param, int pageSize, int page)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                GL_ACCOUNT_PARAM = param.GL_ACCOUNT_PARAM,
                WBS_NO = param.WBS_NO,
                start = page,
                length = pageSize
            };
            IEnumerable<PRCreation> result = db.Fetch<PRCreation>(SqlFile.GLAccountList, args);
            db.Close();
            return result;
        }

        public int CountWBS(PRCreation param, string regno)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                WBS_PARAM = param.WBS_PARAM,
                DIVISION_ID = param.DIVISION_ID,
                PR_COORDINATOR = param.PR_COORDINATOR,
                PR_TYPE = param.PR_TYPE,
                REGNO = regno
            };
            int result = db.SingleOrDefault<int>(SqlFile.WBSCount, args);
            db.Close();
            return result;
        }

        public IEnumerable<PRCreation> GetWBS(PRCreation param, string regno, int pageSize, int page)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                WBS_PARAM = param.WBS_PARAM,
                DIVISION_ID = param.DIVISION_ID,
                PR_COORDINATOR = param.PR_COORDINATOR,
                PR_TYPE = param.PR_TYPE,
                REGNO = regno,
                start = page,
                length = pageSize
            };
            IEnumerable<PRCreation> result = db.Fetch<PRCreation>(SqlFile.WBSList, args);
            db.Close();
            return result;
        }
        //FID.Ridwan: 20220712 --> add wbs no param
        public IEnumerable<PRCreation> GetListDataAssetNo(string Param, string DIVISION_PARAM, string VendorName, string PayMethod, string PayTerm, string wbsno, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                DIVISION_PARAM,
                VendorName,
                PayMethod,
                PayTerm,
                Param,
                wbsno,
                Start = start,
                Length = length
            };

            IEnumerable<PRCreation> result = db.Fetch<PRCreation>("PR/PRCreation/GetDataAssetNo", args);

            db.Close();
            return result;
        }
        //FID.Ridwan: 20220712 --> add wbs no param
        public int CountDataAssetNo(string Param, string DIVISION_PARAM, string VendorName, string PayMethod, string PayTerm, string wbsno)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                DIVISION_PARAM,
                VendorName,
                PayMethod,
                PayTerm,
                Param,
                wbsno
            };

            int result = db.SingleOrDefault<int>("PR/PRCreation/CountDataAssetNo", args);
            db.Close();

            return result;
        }
        #endregion

        #region PR CREATION INITIALIZE
        public Tuple<Int64, string> CheckLocking(string userid)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            Int64 PROCESS_ID = 0;
            string PR_NO = "";

            dynamic args = new
            {
                USERID = userid
            };
            PRCreation data = db.SingleOrDefault<PRCreation>(SqlFile.CheckLocking, args);
            PROCESS_ID = Int64.Parse(data.PROCESS_ID);
            PR_NO = data.PR_NO;

            return new Tuple<Int64, string>(PROCESS_ID, PR_NO);
        }
        
        public Tuple<Int64, string> CreationInit(string userid, string PR_NO, string noreg, string username)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            Int64 PROCESS_ID = 0;
            string message = "";
            try
            {
                dynamic args = new
                {
                    USERID = userid,
                    PR_NO = PR_NO,
                    NOREG = noreg,
                    USERNAME = username
                };
                PROCESS_ID = db.SingleOrDefault<Int64>(SqlFile.CreationInit, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }

            return new Tuple<long, string>(PROCESS_ID, message);
        }

        public PRCreation GetUserDescription(string noreg)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            PRCreation result = new PRCreation();
            try
            {
                dynamic args = new { NOREG = noreg };
                result = db.SingleOrDefault<PRCreation>(SqlFile.GetUserDescription, args);
            }
            catch (Exception e)
            {
                result.MESSAGE = e.Message;
            }
            finally
            {
                db.Close();
            }

            return result;
        }

        public PRCreation GetTempPRH(Int64 ProcessID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            PRCreation resultquery = new PRCreation();
            try
            {
                dynamic args = new { PROCESS_ID = ProcessID };
                resultquery = db.SingleOrDefault<PRCreation>(SqlFile.PRHeaderEditData, args);
            }
            catch (Exception e)
            {
                resultquery.MESSAGE = e.Message;
            }
            finally
            {
                db.Close();
            }
            return resultquery;
        }

        public List<PRCreation> GetTempItem(Int64 ProcessID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<PRCreation> result = new List<PRCreation>();
            try
            {
                dynamic args = new { PROCESS_ID = ProcessID };
                result = db.Fetch<PRCreation>(SqlFile.ItemDetailEditData, args);
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
            finally
            {
                db.Close();
            }
            return result;
        }

        public List<PRCreation> GetTempSubItem(Int64 ProcessID, string ITEM_NO)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<PRCreation> result = new List<PRCreation>();
            try
            {
                dynamic args = new { 
                    PROCESS_ID = ProcessID,
                    ITEM_NO = ITEM_NO
                };
                result = db.Fetch<PRCreation>(SqlFile.SubItemDetailEditData, args);
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
            finally
            {
                db.Close();
            }
            return result;
        }

        public List<PRCreation> GetListItem(Int64 ProcessID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<PRCreation> result = new List<PRCreation>();
            try
            {
                dynamic args = new { PROCESS_ID = ProcessID };
                result = db.Fetch<PRCreation>(SqlFile.ListItemTempData, args);
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
            finally
            {
                db.Close();
            }
            return result;
        }

        public Tuple<List<PRCreation>, string> GetAllTempAttachment(Int64 processid, string prno)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<PRCreation> resultquery = new List<PRCreation>();
            string message = "";
            try
            {
                dynamic args = new { PROCESS_ID = processid, PR_NO = prno };
                resultquery = db.Fetch<PRCreation>(SqlFile.PRAttachmentEditData, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }

            return new Tuple<List<PRCreation>, string>(resultquery, message);
        }

        public string GetLastProcessIDonTemp(string userid)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";

            try
            {
                dynamic args = new { USER_ID = userid };
                result = db.SingleOrDefault<string>(SqlFile.LastProcessIDOnTemp, args);
            }
            catch (Exception e)
            {
                result = "E|" + e.Message;
            }
            finally
            {
                db.Close();
            }

            return result;
        }
        #endregion

        #region SAVING PR
        public Tuple<string, string> InitialValidation(string PROCESS_ID, string type)
        {
            PRCreation resultTable = new PRCreation();
            string status = "SUCCESS";
            string result = "";
            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                dynamic args = new
                {
                    type = type,
                    Process_Id = PROCESS_ID
                };
                resultTable = db.SingleOrDefault<PRCreation>(SqlFile.PRSavingInitialValidation, args);
                result = resultTable.MESSAGE;
                status = resultTable.PROCESS_STATUS;
            }
            catch (Exception e)
            {
                result = e.Message;
                status = "EXCEPTION";
            }
            finally
            {
                db.Close();
            }
            return new Tuple<string, string>(status, result);
        }

        public Tuple<string, string> SavingPRValidation(PRCreation param)
        {
            PRCreation resultTable = new PRCreation();
            string status = "SUCCESS";
            string result = "";
            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                dynamic args = new
                {
                    PLANT_CD = param.PLANT_CD,
                    DELIVERY_DATE = param.DELIVERY_DATE,
                    URGENT_DOC = param.URGENT_DOC,
                    PR_TYPE = param.PR_TYPE,
                    PROCESS_ID = param.PROCESS_ID
                };
                resultTable = db.SingleOrDefault<PRCreation>(SqlFile.PRSavingValidation, args);
                result = resultTable.MESSAGE;
                status = resultTable.PROCESS_STATUS;
            }
            catch (Exception e)
            {
                result = e.Message;
                status = "EXCEPTION";
            }
            finally
            {
                db.Close();
            }
            return new Tuple<string, string>(status, result);
        }
        public Tuple<string, string, int> GeneratePRNumber(string PROCESS_ID, string PR_TYPE, string username)
        {
            string result = "";
            string PR_No = "";
            IDBContext db = DatabaseManager.Instance.GetContext();

            try
            {
                dynamic args = new
                {
                    PROCESS_ID = PROCESS_ID,
                    PR_TYPE = PR_TYPE,
                    USER_ID = username
                };
                PR_No = db.SingleOrDefault<string>(SqlFile.GeneratePRNumber, args);

                if (PR_No != "FAILED")
                    result = "SUCCESS";
                else
                    result = "FAILED";
            }
            catch (Exception ex)
            {
                result = "FAILED";
                PR_No = ex.Message;
            }
            finally
            {
                db.Close();
            }
            return new Tuple<string, string, int>(result, PR_No, 0);
        }

        public Tuple<string, string, int> QuotaProcessing(PRCreation param, string username, string ProcessType)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            PRCreation resultTable = new PRCreation();
            string result = "";
            string status = "";
            try
            {
                dynamic args = new
                {
                    USER_ID = username,
                    PR_NO = param.PR_NO,
                    PROCESS_ID = param.PROCESS_ID,
                    DIVISION_ID = param.DIVISION_ID,
                    PROCESS_TYPE = ProcessType
                };
                resultTable = db.SingleOrDefault<PRCreation>(SqlFile.QuotaCalculation, args);
                result = resultTable.MESSAGE;
                status = resultTable.PROCESS_STATUS;
            }
            catch (Exception e)
            {
                result = e.Message;
                status = "EXCEPTION";
            }
            finally
            {
                db.Close();
            }
            return new Tuple<string, string, int>(status, result, 0);
        }

        public Tuple<string, string, int> BudgetProcessing(PRCreation param, string username, string ProcessType, int TotalRollback)
        {
            #region FID.Ridwan:20211210 -> NewConnection handle timeout
            PRCreation resultTable = new PRCreation();
            string result = "";
            string status = "";
            int total_success = 0;
            string constring = DatabaseManager.Instance.GetConnectionDescriptor("Dev").ConnectionString;
            SqlConnection connect = new SqlConnection(constring);
            SqlDataReader reader = null;

            try
            {

                connect.Open();

                SqlCommand sqlSelect = new SqlCommand("[dbo].[sp_prcreation_budgetProcessing]", connect);
                sqlSelect.CommandType = CommandType.StoredProcedure;
                sqlSelect.CommandTimeout = 180;

                sqlSelect.Parameters.Add("@PROCESS_ID", SqlDbType.VarChar).Value = param.PROCESS_ID;
                sqlSelect.Parameters.Add("@DIVISION", SqlDbType.VarChar).Value = param.DIVISION_ID;
                sqlSelect.Parameters.Add("@PR_NO", SqlDbType.VarChar).Value = param.PR_NO;
                sqlSelect.Parameters.Add("@PR_DESC", SqlDbType.VarChar).Value = param.PR_DESC;
                sqlSelect.Parameters.Add("@USER_ID", SqlDbType.VarChar).Value = username;
                sqlSelect.Parameters.Add("@PROCESS_TYPE", SqlDbType.VarChar).Value = ProcessType;
                sqlSelect.Parameters.Add("@ROW_ROLLBACK", SqlDbType.Int).Value = TotalRollback;
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
            //PRCreation resultTable = new PRCreation();
            //string result = "";
            //string status = "";
            //int total_success = 0;
            //try
            //{
            //    dynamic args = new
            //    {
            //        USER_ID = username,
            //        PR_NO = param.PR_NO,
            //        PR_DESC = param.PR_DESC,
            //        PROCESS_ID = param.PROCESS_ID,
            //        DIVISION_ID = param.DIVISION_ID,
            //        PROCESS_TYPE = ProcessType,
            //        ROW_ROLLBACK = TotalRollback

            //    };
            //    resultTable = db.SingleOrDefault<PRCreation>(SqlFile.BudgetCalculation, args);
            //    result = resultTable.MESSAGE;
            //    status = resultTable.PROCESS_STATUS;
            //    total_success = resultTable.NUMBER_OF_SUCCESS;
            //}
            //catch (Exception e)
            //{
            //    result = e.Message;
            //    status = "EXCEPTION";
            //}
            //finally
            //{
            //    db.Close();
            //}
            #endregion
            
            return new Tuple<string, string, int>(status, result, total_success);
        }

        public Tuple<string, string, int> SavingProcessing(PRCreation param, string type, string username, string noreg)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            PRCreation resultTable = new PRCreation();
            string result = "";
            string status = "";

            try
            {
                dynamic args = new
                {
                    USER_ID = username,
                    NOREG = noreg,
                    PR_NO = param.PR_NO,
                    PROCESS_ID = param.PROCESS_ID,
                    DIVISION_ID = param.DIVISION_ID,

                    PR_TYPE = param.PR_TYPE,
                    PR_DESC = param.PR_DESC,
                    PR_COORDINATOR = param.PR_COORDINATOR,
                    PLANT_CD = param.PLANT_CD,
                    SLOC_CD = param.SLOC_CD,
                    DIVISION_NAME = param.DIVISION_NAME,
                    PROJECT_NO = param.PROJECT_NO,
                    URGENT_DOC = param.URGENT_DOC,
                    MAIN_ASSET_NO = param.MAIN_ASSET_NO,
                    PR_NOTES = param.PR_NOTES,
                    DELIVERY_PLAN_DT = param.DELIVERY_DATE,
                    PR_STATUS = type == "submit" ? "90" : "94",

                    TYPE = type.ToUpper()
                };
                resultTable = db.SingleOrDefault<PRCreation>(SqlFile.PRSavingProcessing, args);
                result = resultTable.MESSAGE;
                status = resultTable.PROCESS_STATUS;
            }
            catch (Exception e)
            {
                result = e.Message;
                status = "EXCEPTION";
            }
            finally
            {
                db.Close();
            }
            return new Tuple<string, string, int>(status, result, 0);
        }

        public PRCreation GetErrorLog(Int64 PROCESS_ID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            PRCreation resultTable = new PRCreation();
            try
            {
                dynamic args = new { PROCESS_ID = PROCESS_ID };
                resultTable = db.SingleOrDefault<PRCreation>(SqlFile.GetErrorLog, args);
            }
            catch (Exception e)
            {
                resultTable.MESSAGE_ID = "EXCEPTION";
                resultTable.MESSAGE_CONTENT = e.Message;
                resultTable.LOCATION = "Get Error Log";
            }
            finally
            {
                db.Close();
            }
            return resultTable;
        }

        public Tuple<List<PRCreation>, string> GetDeletedTempAttachment(string pProcessID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<PRCreation> pr = new List<PRCreation>();
            string msg = "SUCCESS";
            try
            {
                dynamic args = new { PROCESS_ID = pProcessID };
                pr = db.Fetch<PRCreation>(SqlFile.DeletedTempFilesList, args);
            }
            catch (Exception e)
            {
                msg = e.Message;
            }
            finally
            {
                db.Close();
            }

            return new Tuple<List<PRCreation>, string>(pr, msg);
        }

        public Tuple<List<PRCreation>, string> GetAttachedFile(string pProcessID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<PRCreation> pr = new List<PRCreation>();
            string msg = "SUCCESS";

            try
            {
                dynamic args = new { PROCESS_ID = pProcessID };
                pr = db.Fetch<PRCreation>(SqlFile.SavedTempFilesList, args);
            }
            catch (Exception e)
            {
                msg = e.Message;
            }
            finally
            {
                db.Close();
            }

            return new Tuple<List<PRCreation>, string>(pr, msg);
        }

        public string DeleteTempbyUser(string processid, string prno)
        {
            string result = "";
            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                dynamic args = new
                {
                    PROCESS_ID = processid,
                    PR_NO = prno
                };
                result = db.SingleOrDefault<string>(SqlFile.DeleteTempbyUserID, args);
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

        #region TEMP DATA MANAGEMENT

        #region HEADER DATA MANAGEMENT
        public string InsertTempHeader(PRCreation param, string username)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";
            try
            {
                dynamic args = new
                {
                    USERID = username,
                    PROCESS_ID = param.PROCESS_ID,
                    PR_NO = param.PR_NO,
                    PR_DESC = param.PR_DESC,
                    PR_TYPE = param.PR_TYPE,
                    PLANT_CD = param.PLANT_CD,
                    SLOC_CD = param.SLOC_CD,
                    PR_COORDINATOR = param.PR_COORDINATOR,
                    DIVISION_ID = param.DIVISION_ID,
                    DIVISION_NAME = param.DIVISION_NAME,
                    PROJECT_NO = param.PROJECT_NO,
                    URGENT_DOC = param.URGENT_DOC,
                    MAIN_ASSET_NO = param.MAIN_ASSET_NO,
                    PR_NOTES = param.PR_NOTES,
                    DELIVERY_PLAN_DT = param.DELIVERY_DATE
                };
                result = db.SingleOrDefault<string>(SqlFile.SavePRHTempData, args);
            }
            catch (Exception e)
            {
                result = "ERR|" + e.Message;
            }
            finally
            {
                db.Close();
            }
            return result;
        }
        #endregion

        #region ITEM DATA MANAGEMENT
        public string GetLatestSeqItem(string ProcessID, string PR_TYPE)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string no = "0";
            try
            {
                dynamic args = new { PROCESS_ID = ProcessID, PR_TYPE };
                no = db.SingleOrDefault<string>(SqlFile.LastSequenceOnItem, args);
            }
            catch (Exception e)
            {
                no = "0";
            }
            finally
            {
                db.Close();
            }
            return no;
        }
        
        public string InsertTempItem(PRCreation param, string username)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";
            try
            {
                dynamic args = new
                {
                    USERID = username,
                    PROCESS_ID = param.PROCESS_ID,
                    ITEM_NO = param.ITEM_NO,
                    ITEM_CLASS = param.ITEM_CLASS,
                    ITEM_CLASS_DESC = param.ITEM_CLASS_DESC,
                    VALUATION_CLASS = param.VALUATION_CLASS,
                    VALUATION_CLASS_DESC = param.VALUATION_CLASS_DESC,
                    ITEM_TYPE = param.ITEM_TYPE,
                    WBS_NO = param.WBS_NO,
                    WBS_NAME = param.WBS_NAME,
                    COST_CENTER_CD = param.COST_CENTER,
                    GL_ACCOUNT = param.GL_ACCOUNT_CD,
                    MAT_NO = param.MAT_NUMBER,
                    MAT_DESC = param.MAT_DESC,
                    CAR_FAMILY_CD = param.CAR_FAMILY_CD,
                    MAT_GRP_CD = param.MAT_GRP_CD,
                    MAT_TYPE_CD = param.MAT_TYPE_CD,
                    QTY = param.QTY,
                    UOM = param.UOM,
                    CURR = param.CURR,
                    PRICE = param.PRICE,
                    DELIVERY_DATE_ITEM = param.DELIVERY_DATE_ITEM,
                    VENDOR_CD = param.VENDOR_CD,
                    VENDOR_NAME = param.VENDOR_NAME,
                    QUOTA_FLAG = param.QUOTA_FLAG,
                    ASSET_CATEGORY = param.ASSET_CATEGORY_CD,
                    ASSET_CLASS = param.ASSET_CLASS,
                    ASSET_LOCATION = param.ASSET_LOCATION,
                    ASSET_NO = param.ASSET_NO
                };
                result = db.SingleOrDefault<string>(SqlFile.SaveItemTempData, args);
            }
            catch (Exception e)
            {
                result = "ERR|" + e.Message;
            }
            finally
            {
                db.Close();
            }
            return result;
        }

        public string DeleteItem(string PROCESS_ID, string ITEM_NO)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";
            try
            {
                dynamic args = new
                {
                    PROCESS_ID = PROCESS_ID,
                    ITEM_NO = ITEM_NO
                };
                result = db.SingleOrDefault<string>(SqlFile.DeleteItemTempData, args);
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

        public string CopyData(string ITEM_NO, string SUBITEM_NO, string TYPE, string userid, string PROCESS_ID, string NEW_ITEM_NO, string NEW_SUBITEM_NO)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";
            try
            {
                dynamic args = new
                {
                    ITEM_NO = ITEM_NO,
                    SUBITEM_NO = SUBITEM_NO,
                    TYPE = TYPE,
                    USER_ID = userid,
                    PROCESS_ID = PROCESS_ID,
                    NEW_ITEM_NO,
                    NEW_SUBITEM_NO
                };
                result = db.SingleOrDefault<string>(SqlFile.CopyTempData, args);
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

        #region SUB ITEM DATA MANAGEMENT
        public string GetLatestSeqSubItem(string ProcessID, string ITEM_NO, string PR_TYPE)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string no = "0";
            try
            {
                dynamic args = new { PROCESS_ID = ProcessID, ITEM_NO = ITEM_NO, PR_TYPE = PR_TYPE };
                no = db.SingleOrDefault<string>(SqlFile.LastSequenceOnSubItem, args);
            }
            catch (Exception e)
            {
                no = "0";
            }
            finally
            {
                db.Close();
            }
            return no;
        }

        public string InsertTempSubItem(PRCreation param, string username)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";
            try
            {
                dynamic args = new
                {
                    USERID = username,
                    PROCESS_ID = param.PROCESS_ID,
                    SUBITEM_NO = param.SUBITEM_NO,
                    ITEM_NO = param.ITEM_NO,
                    WBS_NO = param.SUBITEM_WBS_NO,
                    COST_CENTER_CD = param.SUBITEM_COST_CENTER,
                    MAT_DESC = param.SUBITEM_MAT_DESC,
                    GL_ACCOUNT = param.SUBITEM_GL_ACCOUNT,
                    SUBITEM_QTY = param.SUBITEM_QTY,
                    SUBITEM_UOM = param.SUBITEM_UOM,
                    PRICE_PER_UOM = param.PRICE_PER_UOM
                };
                result = db.SingleOrDefault<string>(SqlFile.SaveSubItemTempData, args);
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

        public string DeleteSelectedTempSubItem(string PROCESS_ID, string ITEM_NO, string SUBITEM_NO)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";

            try
            {
                dynamic args = new
                {
                    PROCESS_ID = PROCESS_ID,
                    ITEM_NO = ITEM_NO,
                    SUBITEM_NO = SUBITEM_NO
                };
                result = db.SingleOrDefault<string>(SqlFile.DeleteSelectedSubItemTemp, args);
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

        public void DeleteAllTempData(string PROCESS_ID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                PROCESS_ID = PROCESS_ID
            };

            db.Execute(SqlFile.DeleteAllTempData, args);
        }
        #endregion

        #region TEMP FILE MANAGEMENT 
        public string SaveTempAttachment(PRCreation param, string username)
        {
            string result = "";
            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            { 
                dynamic args = new
                {
                    PR_NO = param.PR_NO,
                    USERID = username,
                    DOC_TYPE = param.DOC_TYPE,
                    FILE_PATH = param.FILE_PATH,
                    FILE_PATH_ORI = param.FILE_NAME_ORI,
                    FILE_EXTENSION = param.FILE_EXTENSION,
                    FILE_SIZE = param.FILE_SIZE,
                    PROCESS_ID = param.PROCESS_ID
                };
                result = db.SingleOrDefault<string>(SqlFile.SaveAttachedFile, args);
            }
            catch (Exception ex)
            {
                result = ex.Message;
            }
            finally {
                db.Close();
            }
            return result;
        }

        public Tuple<List<PRCreation>, string> GetTempAttachment(string username, string PR_NO, string DOC_TYPE)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<PRCreation> resultquery = new List<PRCreation>();
            string result = "";

            try
            {
                dynamic args = new {
                    USER_ID = username, 
                    PR_NO = PR_NO, 
                    TYPE = DOC_TYPE 
                };
                resultquery = db.Fetch<PRCreation>(SqlFile.PRAttachmentbyType, args);
            }
            catch (Exception e)
            {
                result = e.Message;
            }
            finally {
                db.Close();
            }

            return new Tuple<List<PRCreation>,string>(resultquery, result);
        }

        public PRCreation DeleteTempFiles(string username, string PR_NO, string SEQ_NO, string PROCESS_ID)
        {
            PRCreation result = new PRCreation();
            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                dynamic args = new
                {
                    PR_NO = PR_NO,
                    USER_ID = username,
                    SEQ_NO = SEQ_NO,
                    PROCESS_ID = PROCESS_ID
                };
                result = db.SingleOrDefault<PRCreation>(SqlFile.DeleteTempFile, args);
            }
            catch (Exception e)
            {
                result.PROCESS_STATUS = "ERR";
                result.MESSAGE_CONTENT = e.Message;
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