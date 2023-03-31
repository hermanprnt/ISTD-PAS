using System;
using System.Collections.Generic;
using System.Web.Mvc;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class MasterDueDilligenceRepository
    {
        public sealed class SqlFile
        {
            public const String GetList = "Master/CostCenter/GetList";
            public const String SaveUploadData = "Master/CostCenter/SaveUploadedData";


            #region added : 20190614 : isid.rgl
            public const String GetListAll = "Master/CostCenter/GetListAll";
            #endregion
        }

        private MasterDueDilligenceRepository() { }
        private static MasterDueDilligenceRepository instance = null;
        public static MasterDueDilligenceRepository Instance
        {
            get { return instance ?? (instance = new MasterDueDilligenceRepository()); }
        }

        #region Ark.Herman
        public IEnumerable<StatusAgreement> GetSTSDueDilligence(String noReg = "")
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                NO_REG = noReg
            };

            IEnumerable<StatusAgreement> result = db.Fetch<StatusAgreement>("Master/GetSTSDueDilligence", args);

            db.Close();
            return result;
        }

        public IEnumerable<MasterDueDilligence> GetListData(string VendorCode, string VendorName, string AgreementNo, string Status, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                VendorCode,
                VendorName,
                AgreementNo,
                Status,
                Start = start,
                Length = length
            };

            IEnumerable<MasterDueDilligence> result = db.Fetch<MasterDueDilligence>("Master/MasterDueDilligence/GetData", args);

            db.Close();
            return result;
        }

        public String SaveData(String flag, String vendorcd, String vendornm, String status,String plan, String vldddfrom,
            String vldddto, String agreementno, String vldagreementfrom, String vldagreementto, String uid)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                dynamic args = new
                {
                    Flag = flag,
                    vendorcd,
                    plan,
                    vendornm,
                    status,
                    vldddfrom,
                    vldddto,
                    agreementno,
                    vldagreementfrom,
                    vldagreementto,
                    uid
                };

                result = db.SingleOrDefault<string>("Master/MasterDueDilligence/SaveData", args);
                db.Close();
            }
            catch (Exception ex)
            {
                result = "Error| " + Convert.ToString(ex.Message);
            }

            return result;
        }
        public int CountData(string VendorCode, string VendorName, string AgreementNo, string Status)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            int result = db.SingleOrDefault<int>("Master/MasterDueDilligence/CountData", new { VendorCode, VendorName, AgreementNo, Status });
            db.Close();

            return result;
        }

        public MasterDueDilligence GetSelectedData(String VendorCode)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            var data = db.SingleOrDefault<MasterDueDilligence>("Master/MasterDueDilligence/GetSelectedData", new { VendorCode });
            db.Close();

            return data;
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

                    result = db.SingleOrDefault<string>("Master/MasterDueDilligence/DeleteData", new { vendorcd = cols[0], uid });
                }
                db.Close();
            }
            catch (Exception ex)
            {
                result = "Error| " + Convert.ToString(ex.Message);
            }

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

        #endregion

    }
}
