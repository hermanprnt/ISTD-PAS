using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class ExchangeRateRepository
    {
        public sealed class SqlFile
        {
            public const String _Root_Folder = "Master/ExchangeRate/";

            public const String _GetReleasedFlag = _Root_Folder + "GetReleasedFlag";
            public const String _CountData = _Root_Folder + "CountData";
            public const String _GetData = _Root_Folder + "ReadExchangeRate";
            public const String _GetSingleData = _Root_Folder + "GetSingleData";

            public const String _UpdateData = _Root_Folder + "UpdateExchangeRate";
            public const String _InsertData = _Root_Folder + "InsertExchangeRate";
            public const String _DeleteData = _Root_Folder + "DeleteData";
            public const String _SaveUploadData = _Root_Folder + "SaveUploadedData";

            public const String _CheckDay = _Root_Folder + "CheckDay";
            public const String _CheckData = _Root_Folder + "CheckData";
            public const String _CheckValidDt = _Root_Folder + "CheckValidDtFrom";
            public const String _DeleteValidation = _Root_Folder + "ValidationDelete";

        }

        private ExchangeRateRepository() { }

        #region Singleton
        private static ExchangeRateRepository instance = null;
        public static ExchangeRateRepository Instance
        {
            get { return instance ?? (instance = new ExchangeRateRepository()); }
        }
        #endregion

        #region Data Methods
        public IEnumerable<ExchangeRate> GetReleasedFlag()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<ExchangeRate> result = db.Fetch<ExchangeRate>(SqlFile._GetReleasedFlag);
            db.Close();
            return result;
        }
        #endregion

        #region Get Data
        public int CountData(string curr_cd, string exchange_rate, string valid_dt_from, string valid_dt_to, string forex_type, string released_flag, bool isValidOnly)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Currency = curr_cd,
                ExchangeRate = exchange_rate,
                DateFrom = valid_dt_from,
                DateTo = valid_dt_to,
                ForexType = forex_type,
                ReleaseFlag = released_flag,
                IsValidOnly = isValidOnly
            };
            int count = db.SingleOrDefault<int>(SqlFile._CountData, args);
            db.Close();
            return count;
        }

        public List<ExchangeRate> GetData(int start, int end, string curr_cd, string exchange_rate, string valid_dt_from, string valid_dt_to, string forex_type, string released_flag, bool isValidOnly)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Start = start,
                End = end,
                Currency = curr_cd,
                ExchangeRate = exchange_rate,
                DateFrom = valid_dt_from,
                DateTo = valid_dt_to,
                ForexType = forex_type,
                ReleaseFlag = released_flag,
                IsValidOnly = isValidOnly
            };
            List<ExchangeRate> list = db.Fetch<ExchangeRate>(SqlFile._GetData, args);
            db.Close();
            return list;
        }

        public ExchangeRate GetSingleData(string curr_cd, string released_flag)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                CURR_CD = curr_cd,
                RELEASED_FLAG = released_flag
            };

            ExchangeRate result = db.SingleOrDefault<ExchangeRate>(SqlFile._GetSingleData, args);
            db.Close();
            return result;
        }
        #endregion

        #region CRUD
        public int UptodateData(ExchangeRate er, string uid)
        {
            int result = 0;
            if (CheckDay(er.CURR_CD, er.CREATED_DT) == 1)
            {
                result = -1;
            }
            else 
            {
                if (CheckValid(er.CURR_CD, er.VALID_DT_TO) == 1)
                {
                    if (CheckValidFrom(er.CURR_CD, er.VALID_DT_FROM) == 1)
                    {
                        IDBContext db = DatabaseManager.Instance.GetContext();

                        dynamic args = new
                        {
                            CURR_CD = er.CURR_CD,
                            VALID_DT_FROM = er.VALID_DT_FROM,
                            uid = uid
                        };
                        result = db.Execute(SqlFile._UpdateData, args);
                        db.Close();

                        IDBContext db2 = DatabaseManager.Instance.GetContext();

                        dynamic args2 = new
                        {
                            CURR_CD = er.CURR_CD,
                            EXCHANGE_RATE = er.EXCHANGE_RATE,
                            VALID_DT_FROM = er.VALID_DT_FROM,
                            uid = uid
                        };
                        result = db.Execute(SqlFile._InsertData, args2);
                        db.Close();
                        result = 1;
                    }
                    else result = -2;
                }
                else
                {
                    IDBContext db = DatabaseManager.Instance.GetContext();
                    dynamic args = new
                    {
                        CURR_CD = er.CURR_CD,
                        EXCHANGE_RATE = er.EXCHANGE_RATE,
                        VALID_DT_FROM = er.VALID_DT_FROM
                    };
                    result = db.Execute(SqlFile._InsertData, args);
                    db.Close();
                    result = 1;
                }
            }
            return result;
        }

        public int DeleteData(string currcode, string valid_dt_from, string valid_dt_to, string uid)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                CURR_CD = currcode,
                VALID_DT_FROM = valid_dt_from,
                VALID_DT_TO = valid_dt_to,
                USER_ID = uid
            };

            int result = db.SingleOrDefault<int>(SqlFile._DeleteData, args);
            db.Close();

            return result;
        }
        #endregion

        #region Validation
        public int CheckDay(string curr_cd, string create_dt)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                CURR_CD = curr_cd,
                CREATED_DT = create_dt
            };
            int count = db.SingleOrDefault<int>(SqlFile._CheckDay, args);
            db.Close();
            return count;
        }

        public int CheckValid(string curr_cd, string valid_dt_to)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                CURR_CD = curr_cd,
                VALID_DT_FROM = valid_dt_to
            };
            int count = db.SingleOrDefault<int>(SqlFile._CheckData, args);
            db.Close();
            return count;
        }

        public int CheckValidFrom(string curr_cd, string valid_dt_from)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                CURR_CD = curr_cd,
                VALID_DT_FROM = valid_dt_from
            };
            int result = db.SingleOrDefault<int>(SqlFile._CheckValidDt, args);
            db.Close();
            return result;
        }

        public string DeleteDataValidation(string currcode, string valid_dt_from, string valid_dt_to)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                CURR_CD = currcode,
                VALID_DT_FROM = valid_dt_from,
                VALID_DT_TO = valid_dt_to
            };

            string result = db.SingleOrDefault<string>(SqlFile._DeleteValidation, args);
            db.Close();

            return result;
        }
        #endregion

        #region Upload Data
        public string SaveUploadedData(ExchangeRate param, string username)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                param.CURR_CD,
                param.EXCHANGE_RATE,
                param.FOREX_TYPE,
                param.VALID_DT_FROM,
                param.VALID_DT_TO,
                param.RELEASED_FLAG,
                param.DECIMAL_FORMAT,
                USER_ID = username
            };

            string result = db.SingleOrDefault<string>(SqlFile._SaveUploadData, args);
            db.Close();

            return result;
        }
        #endregion
    }
}