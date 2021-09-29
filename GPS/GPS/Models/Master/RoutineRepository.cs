using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class RoutineRepository
    {
        public sealed class SqlFile
        {
            public const String _Root_Folder = "Master/Routine/";

            #region COMMON
            public const String PICList = _Root_Folder + "get_picList";
            public const String PICCount = _Root_Folder + "count_picList";
            public const String ValClassList = "PR/PRCreation/DataList/get_valclassList";
            public const String ValClassCount = "PR/PRCreation/DataList/count_valclassList";
            public const String MatnoList = "PR/PRCreation/DataList/get_matnoList";
            public const String MatnoCount = "PR/PRCreation/DataList/count_matnoList";
            public const String GLAccountList = "PR/PRCreation/DataList/get_glaccountList";
            public const String GLAccountCount = "PR/PRCreation/DataList/count_glaccountList";
            public const String WBSList = "PR/PRCreation/DataList/get_wbsList";
            public const String WBSCount = "PR/PRCreation/DataList/count_wbsList";
            public const String CostCenterList = "PR/PRCreation/DataList/get_costcenterList";
            #endregion

            #region CREATION
            public const String CreationInit = _Root_Folder + "routine_creationInit";
            public const String GetUserDescription = _Root_Folder + "get_userDescription";
            public const String GenerateRoutineNumber = _Root_Folder + "generate_routineNo";
            public const String RoutineSavingProcessing = _Root_Folder + "call_savingProcessing";

            public const String RoutineHeaderEditData = _Root_Folder + "get_routineheaderEditData";
            public const String ItemDetailEditData = "PR/PRCreation/get_itemdetailEditData";
            public const String SubItemDetailEditData = "PR/PRCreation/get_subitemdetailEditData";

            public const String LastSequenceOnItem = "PR/PRCreation/get_lastsequenceOnItem";
            public const String SaveItemTempData = "PR/PRCreation/insert_itemtempData";
            public const String DeleteItemTempData = "PR/PRCreation/delete_itemtempData";
            public const String DeleteTempbyUserID = _Root_Folder + "delete_tempbyUserID";

            public const String LastSequenceOnSubItem = "PR/PRCreation/get_lastsequenceOnSubItem";
            public const String SaveSubItemTempData = "PR/PRCreation/insert_subitemtempData";
            public const String DeleteSelectedSubItemTemp = "PR/PRCreation/deleteselected_subitemTemp";

            public const String GetErrorLog = "PR/PRCreation/get_errorLog";
            #endregion

            #region INQUIRY
            public const String GetInquiryList = _Root_Folder + "get_inquiryList";
            public const String InquiryListCount = _Root_Folder + "count_inquiryList";
            public const String EditValidation = _Root_Folder + "editRoutine_validation";
            public const String DetailRoutineHeader = _Root_Folder + "get_detailRoutineH";
            public const String DetailRoutineItem = _Root_Folder + "get_detailRoutineItem";
            public const String RoutineItemCount = _Root_Folder + "count_detailRoutineItem";
            public const String DetailRoutineSubItem = _Root_Folder + "get_detailRoutineSubitem";
            #endregion
        }

        private RoutineRepository() { }
        private static readonly RoutineRepository instance = null;

        public static RoutineRepository Instance
        {
            get { return instance ?? new RoutineRepository(); }
        }

        #region COMMON LIST
        public IEnumerable<Routine> GetDataCostCenter(int pDIV)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new { DIVISION_ID = pDIV };
            IEnumerable<Routine> resultquery = db.Fetch<Routine>(SqlFile.CostCenterList, args);
            db.Close();
            return resultquery;
        }
        #endregion

        #region GRID LOOKUP
        public int CountPIC(Routine param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                DIVISION_ID = param.DIVISION_ID,
                PIC_PARAM = param.PIC_PARAM
            };
            int result = db.SingleOrDefault<int>(SqlFile.PICCount, args);
            db.Close();
            return result;
        }
        
        public IEnumerable<Routine> GetPIC(Routine param, int pageSize, int page)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                DIVISION_ID = param.DIVISION_ID,
                PIC_PARAM = param.PIC_PARAM,
                start = page,
                length = pageSize
            };
            IEnumerable<Routine> result = db.Fetch<Routine>(SqlFile.PICList, args);
            db.Close();
            return result;
        }

        public int CountValClass(Routine param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                VALUATION_CLASS_PARAM = param.VALUATION_CLASS_PARAM,
                PR_COORDINATOR = param.PR_COORDINATOR,
                PR_TYPE = "RT"
            };
            int result = db.SingleOrDefault<int>(SqlFile.ValClassCount, args);
            db.Close();
            return result;
        }

        public IEnumerable<Routine> GetDataValuationClass(Routine param, int pageSize, int page)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                VALUATION_CLASS_PARAM = param.VALUATION_CLASS_PARAM,
                PR_COORDINATOR = param.PR_COORDINATOR,
                PR_TYPE = "RT",
                start = page,
                length = pageSize
            };
            IEnumerable<Routine> result = db.Fetch<Routine>(SqlFile.ValClassList, args);
            db.Close();
            return result;
        }

        public int CountMatnoConst(Routine param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                MAT_NUMBER_PARAM = param.MAT_NUMBER_PARAM,
                VALUATION_CLASS = param.VALUATION_CLASS,
                PR_COORDINATOR = param.PR_COORDINATOR,
                PR_TYPE = "RT",
                ITEM_TYPE = param.ITEM_TYPE
            };
            int result = db.SingleOrDefault<int>(SqlFile.MatnoCount, args);
            db.Close();
            return result;
        }

        public IEnumerable<Routine> GetDataMatNumberConst(Routine param, int pageSize, int page)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                MAT_NUMBER_PARAM = param.MAT_NUMBER_PARAM,
                VALUATION_CLASS = param.VALUATION_CLASS,
                PR_COORDINATOR = param.PR_COORDINATOR,
                PR_TYPE = "RT",
                ITEM_TYPE = param.ITEM_TYPE,
                start = page,
                length = pageSize
            };
            IEnumerable<Routine> result = db.Fetch<Routine>(SqlFile.MatnoList, args);
            db.Close();
            return result;
        }

        public int CountGLAccount(Routine param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                GL_ACCOUNT_PARAM = param.GL_ACCOUNT_PARAM,
                PLANT = param.PLANT_CD,
                WBS_NO = param.WBS_NO,
                COST_CENTER = param.COST_CENTER,
                DIVISION_ID = param.DIVISION_ID
            };
            int result = db.SingleOrDefault<int>(SqlFile.GLAccountCount, args);
            db.Close();
            return result;
        }

        public IEnumerable<Routine> GetGLAccount(Routine param, int pageSize, int page)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                GL_ACCOUNT_PARAM = param.GL_ACCOUNT_PARAM,
                PLANT = param.PLANT_CD,
                WBS_NO = param.WBS_NO,
                COST_CENTER = param.COST_CENTER,
                DIVISION_ID = param.DIVISION_ID,
                start = page,
                length = pageSize
            };
            IEnumerable<Routine> result = db.Fetch<Routine>(SqlFile.GLAccountList, args);
            db.Close();
            return result;
        }

        public int CountWBS(Routine param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                WBS_PARAM = param.WBS_PARAM,
                DIVISION_ID = param.DIVISION_ID,
                PR_COORDINATOR = param.PR_COORDINATOR,
                PR_TYPE = "RT"
            };
            int result = db.SingleOrDefault<int>(SqlFile.WBSCount, args);
            db.Close();
            return result;
        }

        public IEnumerable<Routine> GetWBS(Routine param, int pageSize, int page)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                WBS_PARAM = param.WBS_PARAM,
                DIVISION_ID = param.DIVISION_ID,
                PR_COORDINATOR = param.PR_COORDINATOR,
                PR_TYPE = "RT",
                start = page,
                length = pageSize
            };
            IEnumerable<Routine> result = db.Fetch<Routine>(SqlFile.WBSList, args);
            db.Close();
            return result;
        }
        #endregion

        #region ROUTINE INQUIRY
        public Tuple<List<Routine>, string> ListData(Routine param, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<Routine> result = new List<Routine>();
            string message = "";
            try
            {
                dynamic args = new
                {
                    ROUTINE_NO = param.ROUTINE_NO,
                    DESCRIPTION = param.PR_DESC,
                    PR_COORDINATOR = param.PR_COORDINATOR,
                    DIVISION_CD = param.DIVISION_ID,
                    SCH_TYPE = param.SCH_TYPE,
                    VALID_DATEFROM = param.VALID_FROM,
                    VALID_DATETO = param.VALID_TO,
                    VENDOR_CD = param.VENDOR_CD,
                    PLANT_CD = param.PLANT_CD,
                    SLOC_CD = param.SLOC_CD,
                    WBS_NO = param.WBS_NO,
                    CREATED_BY = param.CREATED_BY,
                    Start = start,
                    Length = length
                };
                result = db.Fetch<Routine>(SqlFile.GetInquiryList, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }

            return new Tuple<List<Routine>, string>(result, message);
        }

        public Tuple<int, string> CountRetrievedPRData(Routine param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            int result = 0;
            string message = "";
            try
            {
                dynamic args = new
                {
                    ROUTINE_NO = param.ROUTINE_NO,
                    DESCRIPTION = param.PR_DESC,
                    PR_COORDINATOR = param.PR_COORDINATOR,
                    DIVISION_CD = param.DIVISION_ID.ToString(),
                    SCH_TYPE = param.SCH_TYPE,
                    VALID_DATEFROM = param.VALID_FROM,
                    VALID_DATETO = param.VALID_TO,
                    VENDOR_CD = param.VENDOR_CD,
                    PLANT_CD = param.PLANT_CD,
                    SLOC_CD = param.SLOC_CD,
                    WBS_NO = param.WBS_NO,
                    CREATED_BY = param.CREATED_BY
                };

                result = db.SingleOrDefault<int>(SqlFile.InquiryListCount, args);
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

        public string EditRoutine(string ROUTINE_NO, string userid, string noreg)
        {
            string result = "";
            IDBContext db = DatabaseManager.Instance.GetContext();

            try
            {
                dynamic args = new
                {
                    ROUTINE_NO = ROUTINE_NO,
                    USER_ID = userid,
                    NOREG = noreg
                };
                result = db.SingleOrDefault<string>(SqlFile.EditValidation, args);
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

        #region INQUIRY DETAIL
        public Routine GetDetailRoutineH(string ROUTINE_NO)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            Routine resultquery = new Routine();
            try
            {
                dynamic args = new { ROUTINE_NO = ROUTINE_NO };
                resultquery = db.SingleOrDefault<Routine>(SqlFile.DetailRoutineHeader, args);
            }
            catch (Exception e)
            {
                resultquery.MESSAGE = e.Message;
            }
            finally { db.Close(); }

            return resultquery;
        }

        public Tuple<List<Routine>, string> GetDetailRoutineItem(string ROUTINE_NO, int pageSize, int page)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<Routine> resultquery = new List<Routine>();
            string message = "";

            try
            {
                dynamic args = new
                {
                    ROUTINE_NO = ROUTINE_NO,
                    start = page,
                    length = pageSize
                };
                resultquery = db.Fetch<Routine>(SqlFile.DetailRoutineItem, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally { db.Close(); }

            return new Tuple<List<Routine>, string>(resultquery, message);
        }

        public Tuple<int, string> CountRoutineItem(string routineno)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string message = "";
            int result = 0;
            try
            {
                dynamic args = new { ROUTINE_NO = routineno };
                result = db.SingleOrDefault<int>(SqlFile.RoutineItemCount, args);
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

        public List<Routine> GetDetailRoutineSubItem(string ROUTINE_NO, string ROUTINE_ITEM_NO)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<Routine> resultquery = new List<Routine>();
            string message = "";

            try
            {
                dynamic args = new
                {
                    ROUTINE_NO = ROUTINE_NO,
                    ROUTINE_ITEM_NO = ROUTINE_ITEM_NO
                };
                resultquery = db.Fetch<Routine>(SqlFile.DetailRoutineSubItem, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally { db.Close(); }

            return resultquery;
        }
        #endregion

        #region ROUTINE CREATION INITIALIZATION
        public Tuple<Int64, string> CreationInit(string userid, string ROUTINE_NO, string noreg, string username)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            Int64 PROCESS_ID = 0;
            string message = "";
            try
            {
                dynamic args = new
                {
                    USERID = userid,
                    ROUTINE_NO = ROUTINE_NO,
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

        public Routine GetUserDescription(string noreg)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            Routine result = new Routine();
            try
            {
                dynamic args = new { NOREG = noreg };
                result = db.SingleOrDefault<Routine>(SqlFile.GetUserDescription, args);
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
        #endregion

        #region TEMP DATA MANAGEMENT
        public Routine GetTempRoutineH(string ROUTINE_NO)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            Routine resultquery = new Routine();
            try
            {
                dynamic args = new { ROUTINE_NO = ROUTINE_NO };
                resultquery = db.SingleOrDefault<Routine>(SqlFile.RoutineHeaderEditData, args);
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

        public Tuple<string, string, int> GenerateRoutineNumber(string PROCESS_ID, string username)
        {
            string result = "";
            string ROUTINE_NO = "";
            IDBContext db = DatabaseManager.Instance.GetContext();

            try
            {
                dynamic args = new
                {
                    PROCESS_ID = PROCESS_ID,
                    USER_ID = username
                };
                ROUTINE_NO = db.SingleOrDefault<string>(SqlFile.GenerateRoutineNumber, args);

                if (ROUTINE_NO != "FAILED")
                    result = "SUCCESS";
                else
                    result = "FAILED";
            }
            catch (Exception ex)
            {
                result = "FAILED";
                ROUTINE_NO = ex.Message;
            }
            finally
            {
                db.Close();
            }
            return new Tuple<string, string, int>(result, ROUTINE_NO, 0);
        }

        public Tuple<string, string, int> SavingProcessing(Routine param, string username, string noreg)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            Routine resultTable = new Routine();
            string result = "";
            string status = "";

            try
            {
                dynamic args = new
                {
                    USER_ID = username,
                    NOREG = noreg,
                    ROUTINE_NO = param.ROUTINE_NO,
                    PROCESS_ID = param.PROCESS_ID,
                    DIVISION_ID = param.DIVISION_ID,
                    DIVISION_NAME = param.DIVISION_NAME,
                    DIVISION_PIC = param.DIVISION_PIC,
                    PR_DESC = param.PR_DESC,
                    PR_COORDINATOR = param.PR_COORDINATOR,
                    PLANT_CD = param.PLANT_CD,
                    SLOC_CD = param.SLOC_CD,
                    SCH_TYPE = param.SCH_TYPE,
                    SCH_TYPE_DESC = param.SCH_TYPE_DESC,
                    SCH_VALUE = param.SCH_VALUE,
                    PR_STATUS = "94",
                    ACTIVE_FLAG = param.ACTIVE_FLAG,
                    VALID_FROM = param.VALID_FROM,
                    VALID_TO = param.VALID_TO
                };
                resultTable = db.SingleOrDefault<Routine>(SqlFile.RoutineSavingProcessing, args);
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

        public List<Routine> GetTempItem(Int64 ProcessID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<Routine> result = new List<Routine>();
            try
            {
                dynamic args = new { PROCESS_ID = ProcessID };
                result = db.Fetch<Routine>(SqlFile.ItemDetailEditData, args);
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

        public string GetLatestSeqItem(string ProcessID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string no = "";
            try
            {
                dynamic args = new { PROCESS_ID = ProcessID, PR_TYPE = "RT" };
                no = db.SingleOrDefault<string>(SqlFile.LastSequenceOnItem, args);
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
            finally
            {
                db.Close();
            }
            return no;
        }

        public string InsertTempItem(Routine param, string username)
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
                    DELIVERY_DATE_ITEM = String.Empty,
                    VENDOR_CD = param.VENDOR_CD,
                    VENDOR_NAME = param.VENDOR_NAME,
                    QUOTA_FLAG = param.QUOTA_FLAG,
                    ASSET_CATEGORY = 'X',
                    ASSET_CLASS = 'X',
                    ASSET_LOCATION = 'X',
                    ASSET_NO = 'X'
                };
                result = db.SingleOrDefault<string>(SqlFile.SaveItemTempData, args);
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

        public string DeleteItem(string PROCESS_ID, string ITEM_NO)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";
            try
            {
                dynamic args = new
                {
                    PROCESS_ID = PROCESS_ID,
                    ITEM_NO = ITEM_NO,
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

        public List<Routine> GetTempSubItem(Int64 ProcessID, string ITEM_NO)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<Routine> result = new List<Routine>();
            try
            {
                dynamic args = new
                {
                    PROCESS_ID = ProcessID,
                    ITEM_NO = ITEM_NO
                };
                result = db.Fetch<Routine>(SqlFile.SubItemDetailEditData, args);
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

        public string GetLatestSeqSubItem(string ProcessID, string ITEM_NO)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string no = "";
            try
            {
                dynamic args = new { PROCESS_ID = ProcessID, ITEM_NO = ITEM_NO, PR_TYPE = "RT" };
                no = db.SingleOrDefault<string>(SqlFile.LastSequenceOnSubItem, args);
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
            finally
            {
                db.Close();
            }
            return no;
        }

        public string InsertTempSubItem(Routine param, string username)
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

        public string DeleteTempbyUser(string processid)
        {
            string result = "";
            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                dynamic args = new
                {
                    PROCESS_ID = processid
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

        #region LOGGING
        public Routine GetErrorLog(Int64 PROCESS_ID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            Routine resultTable = new Routine();
            try
            {
                dynamic args = new { PROCESS_ID = PROCESS_ID };
                resultTable = db.SingleOrDefault<Routine>(SqlFile.GetErrorLog, args);
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
        #endregion

    }
}