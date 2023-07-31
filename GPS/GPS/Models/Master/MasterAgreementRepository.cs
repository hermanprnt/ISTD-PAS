using System;
using System.Collections.Generic;
using System.Security.Principal;
using System.Web.Mvc;
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

        public IEnumerable<MasterAgreement> GetListData(string VendorCode, string VendorName, string AgreementNo, string Status,
            int start, int length,string DateFrom,string DateTo)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                VendorCode,
                VendorName,
                AgreementNo,
                Status,
                Start = start,
                Length = length,
                DateFrom,
                DateTo
            };

            IEnumerable<MasterAgreement> result = db.Fetch<MasterAgreement>("Master/MasterAgreement/GetData", args);

            db.Close();
            return result;
        }
        public int CountData(string VendorCode, string VendorName, string AgreementNo, string Status, string DateFrom, string DateTo)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            int result = db.SingleOrDefault<int>("Master/MasterAgreement/CountData", new { VendorCode, VendorName, AgreementNo, Status,DateFrom,DateTo });
            db.Close();

            return result;
        }

        public String SaveData(String flag,MasterAgreement NewAgreement,String filename, String uid)
        {


            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                dynamic args = new
                {
                    Flag = flag,
                    VendorCode = NewAgreement.VENDOR_CODE,
                    VendorName = NewAgreement.VENDOR_NAME,
                    PurchasingGrp = NewAgreement.PURCHASING_GROUP,
                    Buyer = NewAgreement.BUYER,
                    Agreementno = NewAgreement.AGREEMENT_NO,
                    Startdate = NewAgreement.START_DATE,
                    Expdate = NewAgreement.EXP_DATE,
                    Status = NewAgreement.STATUS,
                    Amount = NewAgreement.AMOUNT,
                    Nextaction = NewAgreement.NEXT_ACTION,
                    mailbuyer = NewAgreement.EMAIL_BUYER,
                    mailsh = NewAgreement.EMAIL_SH,
                    maildph = NewAgreement.EMAIL_DPH,
                    maillegal = NewAgreement.EMAIL_LEGAL,
                    identity = NewAgreement.ID,
                    UId = uid,
                    filename
                };

                result = db.SingleOrDefault<string>("Master/MasterAgreement/SaveData", args);
                db.Close();
            }
            catch (Exception ex)
            {
                result = "Error| " + Convert.ToString(ex.Message);
            }

            return result;
        }
      

        public string SaveUploadedData(MasterAgreement param, string username)
        {

            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                vendorCd = param.VENDOR_CODE,
                purchasingGroup = param.PURCHASING_GROUP,
                buyer = param.BUYER,
                agreementNo = param.AGREEMENT_NO,
                startDate = param.START_DATE,
                expDate = param.EXP_DATE,
                nextAction = param.NEXT_ACTION,
                amount = param.AMOUNT,
                mailbuyer = param.EMAIL_BUYER,
                mailsh = param.EMAIL_SH,
                maildph = param.EMAIL_DPH,
                maillegal = param.EMAIL_LEGAL,

                UId = username
            };

            string result = db.SingleOrDefault<string>("Master/MasterAgreement/SaveUploadedData", args);
            db.Close();

            return result;
        }
        public MasterAgreement GetSelectedData(String VendorCode,String AgreementNo,String ExpDate,String Identity)
        {
            ExpDate = conversiDate(ExpDate);

            IDBContext db = DatabaseManager.Instance.GetContext();

            var data = db.SingleOrDefault<MasterAgreement>("Master/MasterAgreement/GetSelectedData", 
                new { VendorCode,AgreementNo,ExpDate , Identity });
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

                    result = db.SingleOrDefault<string>("Master/MasterAgreement/DeleteData", 
                        new { 
                                VendorCode = cols[0],
                                Agreement_No = cols[1],
                                Identity = cols[2],
                                UId = uid 
                        });
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
