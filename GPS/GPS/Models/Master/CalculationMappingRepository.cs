using System;
using System.Collections.Generic;
using GPS.Constants.Master;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class CalculationMappingRepository
    {
        private CalculationMappingRepository() { }
        private static CalculationMappingRepository instance = null;

        public static CalculationMappingRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new CalculationMappingRepository();
                }
                return instance;
            }
        }

        #region SELECT LIST
        public IEnumerable<CalculationMapping> GetDataCompPrice()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            IEnumerable<CalculationMapping> result = db.Fetch<CalculationMapping>(MasterSqlFiles.GetCompPrice);
            db.Close();

            return result;
        }

        public IEnumerable<CalculationMapping> GetDataCalculationType()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            IEnumerable<CalculationMapping> result = db.Fetch<CalculationMapping>(MasterSqlFiles.GetCalculationType);
            db.Close();

            return result;
        }

        public IEnumerable<CalculationMapping> GetDataCalculationScheme()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            IEnumerable<CalculationMapping> result = db.Fetch<CalculationMapping>(MasterSqlFiles.GetCalculationSchemaAdd);
            db.Close();

            return result;
        }

        public IEnumerable<CalculationMapping> GetDataPlusMinusFlag()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            IEnumerable<CalculationMapping> result = db.Fetch<CalculationMapping>(MasterSqlFiles.GetPlusMinusFlagAdd);
            db.Close();

            return result;
        }
        #endregion

        #region SEARCH DATA
        public Tuple<List<CalculationMapping>, string> ListData(CalculationMapping param, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<CalculationMapping> result = new List<CalculationMapping>();
            string message = "";
            try
            {
                dynamic args = new
                {
                    CALCULATION_SCHEME_CD = param.CALCULATION_SCHEME_CD,
                    CALCULATION_SCHEME_DESC = param.CALCULATION_SCHEME_DESC,
                    INVENTORY_FLAG = param.INVENTORY_FLAG,
                    ACCRUAL_FLAG_TYPE = param.ACCRUAL_FLAG_TYPE,
                    COMP_PRICE_CD = param.COMP_PRICE_CD,
                    CONDITION_RULE = param.CONDITION_RULE,
                    Start = start,
                    Length = length
                };
                result = db.Fetch<CalculationMapping>(MasterSqlFiles.GetCalculationMappingData, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }

            return new Tuple<List<CalculationMapping>, string>(result, message);
        }

        public Tuple<int, string> CountRetrievedData(CalculationMapping param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            int result = 0;
            string message = "";
            try
            {
                dynamic args = new
                {
                    CALCULATION_SCHEME_CD = param.CALCULATION_SCHEME_CD,
                    CALCULATION_SCHEME_DESC = param.CALCULATION_SCHEME_DESC,
                    INVENTORY_FLAG = param.INVENTORY_FLAG,
                    ACCRUAL_FLAG_TYPE = param.ACCRUAL_FLAG_TYPE,
                    COMP_PRICE_CD = param.COMP_PRICE_CD,
                    CONDITION_RULE = param.CONDITION_RULE
                };

                result = db.SingleOrDefault<int>(MasterSqlFiles.CalculationMappingDataCount, args);
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

        public List<CalculationMapping> GetDetail(string CALCULATION_SCHEME_CD)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<CalculationMapping> result = new List<CalculationMapping>();
            string message = "";
            try
            {
                dynamic args = new
                {
                    CALCULATION_SCHEME_CD = CALCULATION_SCHEME_CD
                };
                result = db.Fetch<CalculationMapping>(MasterSqlFiles.GetCalculationMappingDetail, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }

            return result;
        }
        #endregion

        #region ADD / EDIT DATA
        public CalculationMapping GetSelectedData(string CALCULATION_SCHEME_CD)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            CalculationMapping resultquery = new CalculationMapping();
            try
            {
                dynamic args = new { CALCULATION_SCHEME_CD = CALCULATION_SCHEME_CD };
                resultquery = db.SingleOrDefault<CalculationMapping>(MasterSqlFiles.GetSelectedCalculationMapping, args);
            }
            catch (Exception e)
            {
                resultquery.MESSAGE = e.Message;
            }
            finally { db.Close(); }

            return resultquery;
        }

        public List<CalculationMapping> GetDetailTemp(int setget, string CALCULATION_SCHEME_CD, Int64 PROCESS_ID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<CalculationMapping> result = new List<CalculationMapping>();
            string message = "";
            try
            {
                dynamic args = new
                {
                    SETGET = setget,
                    PROCESS_ID = PROCESS_ID,
                    CALCULATION_SCHEME_CD = CALCULATION_SCHEME_CD
                };
                result = db.Fetch<CalculationMapping>(MasterSqlFiles.GetCalculationMappingTemp, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }

            return result;
        }

        public string DeleteTemp(string USER_ID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string message = "";

            try
            {
                dynamic args = new
                {
                    USER_ID = USER_ID

                };
                message = db.SingleOrDefault<string>(MasterSqlFiles.DeleteCalculationMappingTemp, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }

            return message;
        }

        public Int64 GetProcessId(int isedit, string USER_ID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            Int64 ProcessId = 0;
            string message = "";
            string type = "";

            if (isedit == 0) type = "Add New";
            else type = "Edit";

            string loc = type + " Calculation Mapping";

            try
            {
                dynamic args = new
                {
                    MESSAGE = type + " Calculation Mapping Started",
                    uid = USER_ID,
                    LOC = loc,
                    MESSAGE_ID = "",
                    TYPE = "INF",
                    MODULE = "1",
                    FUNCTION = "114001",
                    STS = ""
                };
                ProcessId = db.SingleOrDefault<Int64>(MasterSqlFiles.GetProcessId, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }

            return ProcessId;
        }

        public string DeleteSelectedItem(Int32 SEQ_NO, Int64 PROCESS_ID)
        {
            string result = "";
            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                dynamic args = new
                {
                    SEQ_NO = SEQ_NO,
                    PROCESS_ID = PROCESS_ID
                };
                result = db.SingleOrDefault<string>(MasterSqlFiles.DeleteSelectedCMTemp, args);
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

        public string SaveDetail(CalculationMapping param, string USER_ID)
        {
            string result = "";
            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                dynamic args = new
                {
                    PROCESS_ID = param.PROCESS_ID,
                    COMP_PRICE_CD = param.COMP_PRICE_CD,
                    ITEM_STATUS = param.ITEM_STATUS,
                    SEQ_NO = param.SEQ_NO,
                    BASE_VALUE_FROM = param.BASE_VALUE_FROM,
                    BASE_VALUE_TO = param.BASE_VALUE_TO,
                    INVENTORY_FLAG = param.INVENTORY_FLAG,
                    QTY_PER_UOM = param.QTY_PER_UOM,
                    CALCULATION_TYPE = param.CALCULATION_TYPE,
                    PLUS_MINUS_FLAG = param.PLUS_MINUS_FLAG,
                    CONDITION_CATEGORY = param.CONDITION_CATEGORY,
                    ACCRUAL_FLAG_TYPE = param.ACCRUAL_FLAG_TYPE,
                    CONDITION_RULE = param.CONDITION_RULE,
                    uid = USER_ID
                };
                result = db.SingleOrDefault<string>(MasterSqlFiles.SaveTempCalculationMapping, args);
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

        /*public Tuple<string, string> SavingValidation(ValuationClass param)
        {
            string status = "SUCCESS";
            string result = "";
            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                dynamic args = new
                {
                    VALUATION_CLASS = param.VALUATION_CLASS,
                };
                result = db.SingleOrDefault<string>(MasterSqlFiles.ValuationClassValidation, args);
                if (result == "") status = "SUCCESS";
                else status = "FAILED";
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
        }*/

        public Tuple<string, string> SavingProcess(CalculationMapping param, int isedit, string username)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";
            string status = "";
            try
            {
                dynamic args = new
                {
                    CALCULATION_SCHEME_CD = param.CALCULATION_SCHEME_CD,
                    CALCULATION_SCHEME_DESC = param.CALCULATION_SCHEME_DESC,
                    PROCESS_ID = param.PROCESS_ID,
                    STATUS = param.STATUS,
                    IS_EDIT = isedit,
                    uid = username
                };
                result = db.SingleOrDefault<string>(MasterSqlFiles.CalculationMappingSavingProcess, args);
                string[] res = result.Split('|');
                if (res[0] == "")
                {
                    status = "SUCCESS";
                    result = res[1];
                }
                else status = "FAILED";
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
        #endregion

    }
}