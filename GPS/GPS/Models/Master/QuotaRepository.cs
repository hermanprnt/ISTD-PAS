using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class QuotaRepository
    {

        private QuotaRepository() { }
        private static QuotaRepository instance = null;
        public static QuotaRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new QuotaRepository();
                }
                return instance;
            }
        }

        #region COMMON LIST
        public IEnumerable<Quota> GetListType()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<Quota> listType = db.Fetch<Quota>("Quota/GetListValuationClass");
            db.Close();
            return listType;
        }

        public string GetListWBS(string DivisionID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";
            dynamic args = new
            {
                DivisionID = DivisionID
            };
            List<Quota> resultquery = db.Fetch<Quota>("Quota/GetListWBS", args);
            foreach (var item in resultquery)
            {
                result = result + item.WBS_NO + ";" + item.WBS_NO + "|";
            }
            db.Close();
            return result;
        }

        public string GetListPeriode(string CONSUME_MONTH)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";
            dynamic args = new
            {
                CONSUME_MONTH = CONSUME_MONTH
            };
            List<QuotaDetail> resultquery = db.Fetch<QuotaDetail>("Quota/GetListPeriode", args);
            foreach (var item in resultquery)
            {
                result = result + item.CONSUME_MONTH + ";" + item.CONSUME_MONTH2 + "|";
            }
            db.Close();
            return result;
        }

        public string GetListSourceOrderType(string DIVISION_ID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";
            dynamic args = new
            {
                DIVISION_ID = DIVISION_ID
            };
            List<QuotaDetail> resultquery = db.Fetch<QuotaDetail>("Quota/GetListSourceOrderType", args);
            foreach (var item in resultquery)
            {
                result = result + item.TYPE + ";" + item.TYPE_DESCRIPTION + "|";
            }
            db.Close();
            return result;
        }
        #endregion

        #region DELETE MASTER
        public String DeleteData(String Key)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();

                foreach (String data in Key.Split(','))
                {
                    String[] cols = data.Split(';');

                    result = db.SingleOrDefault<string>("Quota/DeleteData", new { DivisionID = cols[0], QuotaType = cols[1] });
                }
                db.Close();
            }
            catch (Exception ex)
            {
                result = "Error| " + Convert.ToString(ex.Message);
            }

            return result;
        }
        #endregion

        /*public IEnumerable<QuotaDetail> GetDataMatNumber(string matno, string matdesc, string car, string type, string grp, string val, int pageSize, int page)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                MAT_NO = matno,
                MAT_DESC = matdesc,
                CAR = car,
                TYPE = type,
                GRP = grp,
                VALUATION = val,
                start = page,
                length = pageSize
            };
            IEnumerable<QuotaDetail> result = db.Fetch<QuotaDetail>("Quota/GetAllMatNo", args);
            db.Close();
            return result;
        }

        public int CountMatno(string matno, string matdesc, string car, string type, string grp, string val, string purchasing)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                MAT_NO = matno,
                MAT_DESC = matdesc,
                CAR = car,
                TYPE = type,
                GRP = grp,
                VALUATION = val,
                PURCHASING = purchasing
            };
            int result = db.SingleOrDefault<int>("Quota/CountMaterial", args);
            db.Close();
            return result;
        }*/

        #region GENERATE QUOTA
        public string GenerateQuota(string Years, string USER_ID)
        {
            string result = "";

            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                NOW_DATE = Years.Trim(),
                USER_ID = USER_ID
            };
            result = db.SingleOrDefault<string>("Quota/GenerateQuota", args);
            db.Close();

            return result;
        }

        public string GenerateQuotaConfirm(string Years, string USER_ID)
        {
            string result = "";

            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                NOW_DATE = Years.Trim(),
                USER_ID = USER_ID
            };
            result = db.SingleOrDefault<string>("Quota/GenerateQuotaConfirm", args);
            db.Close();

            return result;
        }
        #endregion

        #region ADD / EDIT
        public string SaveData(string flag, Quota quota, string userid)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                dynamic args = new
                {
                    Flag = flag,
                    DivisionId = quota.DIVISION_ID,
                    DivisionName = quota.DIVISION_NAME,
                    WBS = quota.WBS_NO,
                    QuotaType = quota.QUOTA_TYPE,
                    TypeDescription = quota.TYPE_DESCRIPTION,
                    OrderCoord = quota.ORDER_COORD2,
                    OrderCoordName = quota.ORDER_COORD_NAME,
                    Ammount = Convert.ToDecimal(quota.QUOTA_AMOUNT2.Replace(",", "")),
                    AmmountTol = Convert.ToDecimal(quota.QUOTA_AMOUNT_TOL2.Replace(",", "")),
                    UserId = userid
                };
                result = db.SingleOrDefault<string>("Quota/SaveData", args);

                db.Close();
            }
            catch (Exception err)
            {
                result = "Error| " + Convert.ToString(err.Message);
            }
            return result;
        }

        public Quota GetSingleDataQuota(string DivisionID, string QuotaType)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                DivisionID = DivisionID,
                QuotaType = QuotaType
            };

            Quota result = db.SingleOrDefault<Quota>("Quota/GetSingleQuota", args);

            result.QUOTA_AMOUNT2 = string.Format("{0:N0}", result.QUOTA_AMOUNT);
            result.QUOTA_AMOUNT_TOL2 = string.Format("{0:N0}", result.QUOTA_AMOUNT_TOL);

            db.Close();
            return result;
        }

        public QuotaDetail GetSingleDataQuotaTrans(string DivisionID, string QuotaType, string ConsumeMonth)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                DivisionID = DivisionID,
                QuotaType = QuotaType,
                ConsumeMonth = ConsumeMonth
            };

            QuotaDetail result = db.SingleOrDefault<QuotaDetail>("Quota/GetSingleQuotaTrans", args);

            result.QUOTA_AMOUNT2 = String.Format("{0:#,0.00}", result.QUOTA_AMOUNT);
            result.ADDITIONAL_AMOUNT2 = String.Format("{0:#,0.00}", result.ADDITIONAL_AMOUNT);
            result.USAGE_AMOUNT2 = String.Format("{0:#,0.00}", result.USAGE_AMOUNT);
            result.REMAINING2 = String.Format("{0:#,0.00}", result.REMAINING);
            result.TOLERANCE2 = String.Format("{0:#,0.00}", result.TOLERANCE);

            db.Close();
            return result;
        }
        #endregion

        #region ADDITIONAL / TOLERANCE
        public string SubmitTolerance(string DivisionID, string QuotaType, string ConsumeMonth, string Tolerance, string Userid)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                dynamic args = new
                {
                    DivisionID = DivisionID,
                    QuotaType = QuotaType,
                    ConsumeMonth = ConsumeMonth,
                    Tolerance = Convert.ToDecimal(Tolerance.Replace(",", "")),
                    Userid = Userid
                };
                result = db.SingleOrDefault<string>("Quota/SubmitTolerance", args);

                db.Close();
            }
            catch (Exception err)
            {
                result = "Error| " + Convert.ToString(err.Message);
            }
            return result;
        }

        public string SubmitAdditonal(string DivisionID, string QuotaType, string ConsumeMonth, string AmountTransfer, string SourcePeriode, string SourceOrderType, string Userid)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                dynamic args = new
                {
                    DivisionID = DivisionID,
                    QuotaType = QuotaType,
                    ConsumeMonth = ConsumeMonth,
                    AmountTransfer = Convert.ToDecimal(AmountTransfer.Replace(",", "")),
                    SourcePeriode = SourcePeriode,
                    SourceOrderType = SourceOrderType,
                    Userid = Userid
                };
                result = db.SingleOrDefault<string>("Quota/SubmitAdditional", args);

                db.Close();
            }
            catch (Exception err)
            {
                result = "Error| " + Convert.ToString(err.Message);
            }
            return result;
        }

        public string ConfirmAdditional(string DOC_NO, int SEQ_NO, string CONFIRM_FLAG, decimal Amount,string DIVISION_ID, string DT_MONTH, string DST_TYPE, string Userid)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                dynamic args = new
                {
                    DOC_NO = DOC_NO,
                    SEQ_NO = SEQ_NO,
                    CONFIRM_FLAG = CONFIRM_FLAG,
                    Amount = Amount,
                    DIVISION_ID = DIVISION_ID,
                    DT_MONTH = DT_MONTH,
                    DST_TYPE = DST_TYPE,
                    Userid = Userid
                };
                result = db.SingleOrDefault<string>("Quota/ConfirmAdditional", args);

                db.Close();
            }
            catch (Exception err)
            {
                result = "Error| " + Convert.ToString(err.Message);
            }
            return result;
        }

        public string ConfirmAdditionalCancel(string DOC_NO, int SEQ_NO, string CONFIRM_FLAG, decimal Amount, string DIVISION_ID, string DT_MONTH, string DST_TYPE, string Userid)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                dynamic args = new
                {
                    DOC_NO = DOC_NO,
                    SEQ_NO = SEQ_NO,
                    CONFIRM_FLAG = CONFIRM_FLAG,
                    Amount = Amount,
                    DIVISION_ID = DIVISION_ID,
                    DT_MONTH = DT_MONTH,
                    DST_TYPE = DST_TYPE,
                    Userid = Userid
                };
                result = db.SingleOrDefault<string>("Quota/ConfirmAdditionalCancel", args);

                db.Close();
            }
            catch (Exception err)
            {
                result = "Error| " + Convert.ToString(err.Message);
            }
            return result;
        }
        #endregion

        #region UPLOAD
        public int DELETE_TB_T()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            int result = db.Execute("Quota/DELETE_TB_T");
            db.Close();

            return result;
        }

        public int INSERT_TB_T(int row, int LINE, Quota data)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                row = row,
                LINE = LINE,
                DIVISION_ID = data.DIVISION_ID2,
                DIVISION_NAME = data.DIVISION_NAME,
                WBS_NO = data.WBS_NO,
                QUOTA_TYPE = data.QUOTA_TYPE,
                TYPE_DESCRIPTION = data.TYPE_DESCRIPTION,
                ORDER_COORD = data.ORDER_COORD2,
                ORDER_COORD_NAME = data.ORDER_COORD_NAME,
                QUOTA_AMOUNT = data.QUOTA_AMOUNT2,
                QUOTA_AMOUNT_TOL = data.QUOTA_AMOUNT_TOL2
            };

            int result = db.Execute("Quota/INSERT_TB_T", args);
            db.Close();

            return result;
        }

        public string UploadToDatabase(string UserName, Int64 PROCESS_ID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                USER_ID = UserName,
                PROCESS_ID = PROCESS_ID
            };

            string Message = db.SingleOrDefault<string>("Quota/UploadData", args);
            db.Close();

            return Message;
        }
        #endregion
    }
}