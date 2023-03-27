using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class MasterAgreementRepository
    {
        public sealed class SqlFile
        {
            public const String GetList = "Master/CostCenter/GetList";
            public const String SaveUploadData = "Master/CostCenter/SaveUploadedData";


            #region added : 20190614 : isid.rgl
            public const String GetListAll = "Master/CostCenter/GetListAll";
            #endregion
        }

        private MasterAgreementRepository() { }
        private static MasterAgreementRepository instance = null;
        public static MasterAgreementRepository Instance
        {
            get { return instance ?? (instance = new MasterAgreementRepository()); }
        }

        #region Ark.Herman
        public IEnumerable<StatusAgreement> GetSTSAgreement(String noReg = "")
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                NO_REG = noReg
            };

            IEnumerable<StatusAgreement> result = db.Fetch<StatusAgreement>("Master/GetSTSAgreement", args);

            db.Close();
            return result;
        }



        #endregion

        public int CountData(string Division, string CostCenter)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            int result = db.SingleOrDefault<int>("Master/CostCenter/CountData", new { Division, CostCenter });
            db.Close();

            return result;
        }

        public IEnumerable<CostCenter> GetListData(string Division, string CostCenter, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Division,
                CostCenter,
                Start = start,
                Length = length
            };

            IEnumerable<CostCenter> result = db.Fetch<CostCenter>("Master/CostCenter/GetData", args);
            
            db.Close();
            return result;
        }

        protected string conversiDate(string tgl)
        {
            string result = "";
            string[] dt = null;

            if (tgl != "")
            {
                dt = tgl.Split('.');
                tgl = dt[2] + "-" + dt[1] + "-" + dt[0];

                result = tgl;
            }
            return result;
        }

        public String DeleteData(String Key, String uid)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                
                foreach (String data in Key.Split(','))
                {
                    String[] cols = data.Split(';');
                    cols[1] = conversiDate(cols[1]);
                    cols[2] = conversiDate(cols[2]);

                    result = db.SingleOrDefault<string>("Master/CostCenter/DeleteData", new { CostCenterCode = cols[0], ValidFrom = cols[1], ValidTo = cols[2], UId = uid });
                }
                db.Close(); 
            }
            catch (Exception ex)
            {
                result = "Error| " + Convert.ToString(ex.Message);
            }

            return result;
        }

        public String SaveData(String flag, String costCenterGroupCode, String costCenterCode, String description, String Division, String RespPerson, String validFrom, String validTo, String uid)
        {
            string result = "";            
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                dynamic args = new
                {
                    Flag = flag,
                    CostCenterCode = costCenterCode,
                    Description = description,
                    Division,
                    RespPerson,
                    UId = uid,
                    ValidFrom = validFrom,
                    ValidTo = validTo
                };
               
                result = db.SingleOrDefault<string>("Master/CostCenter/SaveData", args);
                db.Close();               
            }
            catch (Exception ex)
            {
                result = "Error| " + Convert.ToString(ex.Message);
            }

            return result;
        }

        public CostCenter GetSelectedData(String costCenterCode,String ValidFrom)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            var data = db.SingleOrDefault<CostCenter>("Master/CostCenter/GetSelectedData", new { CostCenterCode = costCenterCode, ValidFrom = ValidFrom });
            db.Close();

            return data;
        }

        public IList<CostCenter> GetList(String currentRegNo)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IList<CostCenter> result = db.Fetch<CostCenter>(SqlFile.GetList, new { CurrentRegNo = currentRegNo });
            db.Close();

            return result;
        }
        #region added : 20190614 : isid.rgl
        public IList<CostCenter> GetListAll()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IList<CostCenter> result = db.Fetch<CostCenter>(SqlFile.GetListAll);
            db.Close();

            return result;
        }
        #endregion
        #region Upload Data
        public string SaveUploadedData(CostCenter param, string username)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                param.CostCenterCd,
                param.CostCenterDesc,
                param.RespPerson,
                param.Division,
                ValidDtFrom = conversiDate(param.ValidDtFrom),
                UId = username
            };

            string result = db.SingleOrDefault<string>(SqlFile.SaveUploadData, args);
            db.Close();

            return result;
        }
        #endregion

        public List<CostCenter> GetData(string CostCenterCd, string Division, int currentPage, int recordPerPage)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Start = currentPage,
                Length = recordPerPage,
                CostCenter = CostCenterCd,
                Division = Division,
                
                //CreateBy = createdBy,
                //CreateDate = createdDt,
                //ChangeBy = changedBy,
                //ChangeDate = changedDt
            };
            List<CostCenter> list = db.Fetch<CostCenter>("Master/CostCenter/GetData", args);
            db.Close();
            return list;
        }
    }
}