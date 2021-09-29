using System;
using System.Collections.Generic;
using GPS.Constants.Master;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class ValuationClassRepository
    {
        private ValuationClassRepository() { }
        private static ValuationClassRepository instance = null;

        public static ValuationClassRepository Instance
        {
            get { return instance ?? (instance = new ValuationClassRepository()); }
        }

        #region SELECT LIST
        public IEnumerable<ValuationClass> GetListValuationClass()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<ValuationClass> result = db.Fetch<ValuationClass>("Master/Material/GetAllValuationClass");
            db.Close();
            return result;
        }
        #endregion

        #region SEARCH VALUATION CLASS
        public Tuple<List<ValuationClass>, string> ListData(ValuationClass param, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<ValuationClass> result = new List<ValuationClass>();
            string message = "";
            try
            {
                dynamic args = new
                {
                    VALUATION_CLASS = param.VALUATION_CLASS,
                    VALUATION_CLASS_DESC = param.VALUATION_CLASS_DESC,
                    AREA_DESC = param.AREA_DESC,
                    PROCUREMENT_TYPE = param.PROCUREMENT_TYPE,
                    PURCHASING_GROUP_CD = param.PURCHASING_GROUP_CD,
                    CALCULATION_SCHEME_CD = param.CALCULATION_SCHEME_CD,
                    FD_GROUP_CD = param.FD_GROUP_CD,
                    PR_COORDINATOR = param.PR_COORDINATOR,
                    Start = start,
                    Length = length
                };
                result = db.Fetch<ValuationClass>(MasterSqlFiles.GetValuationClassData, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }

            return new Tuple<List<ValuationClass>, string>(result, message);
        }

        public Tuple<int, string> CountRetrievedData(ValuationClass param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            int result = 0;
            string message = "";
            try
            {
                dynamic args = new
                {
                    VALUATION_CLASS = param.VALUATION_CLASS,
                    VALUATION_CLASS_DESC = param.VALUATION_CLASS_DESC,
                    AREA_DESC = param.AREA_DESC,
                    PROCUREMENT_TYPE = param.PROCUREMENT_TYPE,
                    PURCHASING_GROUP_CD = param.PURCHASING_GROUP_CD,
                    CALCULATION_SCHEME_CD = param.CALCULATION_SCHEME_CD,
                    FD_GROUP_CD = param.FD_GROUP_CD,
                    PR_COORDINATOR = param.PR_COORDINATOR
                };

                result = db.SingleOrDefault<int>(MasterSqlFiles.ValuationDataCount, args);
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

        public IEnumerable<ValuationClass> GetDataByFreeParam(string param, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<ValuationClass> result = new List<ValuationClass>();

            dynamic args = new
            {
                PARAM = param,
                start = start,
                length = length
            };
            result = db.Fetch<ValuationClass>(MasterSqlFiles.GetValClassFreeParam, args);
            db.Close();

            return result;
        }

        public int CountDataByFreeParam(string param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            int result = 0;
            dynamic args = new
            {
                PARAM = param
            };
            result = db.SingleOrDefault<int>(MasterSqlFiles.CountValClassFreeParam, args);
            db.Close();
            return result;
        }
        #endregion

        #region ADD / EDIT DATA
        public ValuationClass GetSelectedData(string VALUATION_CLASS, string PR_TYPE)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            ValuationClass resultquery = new ValuationClass();
            try
            {
                dynamic args = new { VALUATION_CLASS, PR_TYPE };
                resultquery = db.SingleOrDefault<ValuationClass>(MasterSqlFiles.GetSelectedValuationClass, args);
            }
            catch (Exception e)
            {
                resultquery.MESSAGE = e.Message;
            }
            finally { db.Close(); }

            return resultquery;
        }

        public Tuple<string, string> SavingValidation(ValuationClass param)
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
        }

        public Tuple<string, string> SavingProcess(ValuationClass param, int isedit, string username)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";
            string status = "";
            try
            {
                dynamic args = new
                {
                    param.VALUATION_CLASS,
                    param.VALUATION_CLASS_DESC,
                    param.AREA_DESC,
                    param.ITEM_CLASS,//add by khanif hanafi 17-07-2019
                    param.PR_COORDINATOR_CD,//add by khanif hanafi 17-07-2019
                    param.PROCUREMENT_TYPE,
                    param.PURCHASING_GROUP_CD,
                    param.FD_GROUP_CD,
                    param.MATL_GROUP,
                    param.CALCULATION_SCHEME_CD,
                    param.STATUS,
                    IS_EDIT = isedit,
                    USER_ID = username
                };
                result = db.SingleOrDefault<string>(MasterSqlFiles.ValuationClassSavingProcess, args);
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
        }
        #endregion

        #region ACTIVE / INACTIVE
        public string ActiveInactive(string newstatus, string VALUATION_CLASS)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";

            try
            {
                dynamic args = new
                {
                    status = newstatus,
                    VALUATION_CLASS = VALUATION_CLASS
                };
                result = db.SingleOrDefault<string>(MasterSqlFiles.ActiveInactiveValuationClass, args);
                return result;
            }
            catch (Exception ex) 
            {
                return "EXCEPTION|" + ex.Message;
            }
        }
        #endregion

    }
}