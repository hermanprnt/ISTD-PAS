using System;
using System.Collections.Generic;
using System.Linq;
using GPS.CommonFunc;
using GPS.Models.Common;
using GPS.ViewModels;
using GPS.ViewModels.Lookup;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class VendorRepository
    {
        public const String DataName = "vendor";

        public sealed class SqlFile
        {
            public const String GetVendorLookupSearchList = "Master/Vendor/GetVendorLookupSearchList";
            public const String GetVendorLookupSearchListCount = "Master/Vendor/GetVendorLookupSearchListCount";
            public const String GetVendorEcatalogueLookupSearchList = "Master/Vendor/GetVendorEcatalogueLookupSearchList";
            public const String GetVendorEcatalogueLookupSearchListCount = "Master/Vendor/GetVendorEcatalogueLookupSearchListCount";

            //add 20200123
            public const String GetVendorLookupSearchListPO = "Master/Vendor/GetVendorLookupSearchListPO";
            public const String GetVendorLookupSearchListCountPO = "Master/Vendor/GetVendorLookupSearchListCountPO";
        }

        private VendorRepository() { }
        private static VendorRepository instance = null;
        public static VendorRepository Instance
        {
            get { return instance ?? (instance = new VendorRepository()); }
        }

        public int CountData(string Param, string VendorCd, string VendorName, string PayMethod, string PayTerm)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                VendorCd,
                VendorName,
                PayMethod,
                PayTerm,
                Param
            };

            int result = db.SingleOrDefault<int>("Master/Vendor/CountData", args);
            db.Close();

            return result;
        }
        //count vendor pr add 20200122
        public int CountDataPr(string Param, string ValClass, string VendorCd, string VendorName, string PayMethod, string PayTerm)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                VendorCd,
                VendorName,
                PayMethod,
                PayTerm,
                Param,
                ValClass
            };

            int result = db.SingleOrDefault<int>("PR/PRCreation/CountData", args);
            db.Close();

            return result;
        }
        //count add vendor pr
        public IEnumerable<Vendor> GetListData(string Param, string VendorCd, string VendorName, string PayMethod, string PayTerm, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                VendorCd,
                VendorName,
                PayMethod,
                PayTerm,
                Param,
                Start = start,
                Length = length
            };

            IEnumerable<Vendor> result = db.Fetch<Vendor>("Master/Vendor/GetData", args);
            
            db.Close();
            return result;
        }
        //start add list vendor for pr creation, 20190926, fajri// edit 20200122
        public IEnumerable<Vendor> GetListDataVenPr(string Param, string ValClass, string VendorCd, string VendorName, string PayMethod, string PayTerm, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                VendorCd,
                VendorName,
                PayMethod,
                PayTerm,
                Param,
                ValClass,
                Start = start,
                Length = length
            };

            IEnumerable<Vendor> result = db.Fetch<Vendor>("PR/PRCreation/GetData", args);

            db.Close();
            return result;
        }
        //end list vendor for pr creation
        public string DeleteData(string VendorCd)
        {
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                dynamic args = new
                { 
                    VendorCd
                };

                db.Execute("Master/Vendor/DeleteData", args);
                return "Data Deleted Successfully";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        public IEnumerable<Vendor> GetVendorData()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<Vendor> result = db.Fetch<Vendor>("Master/GetVendorCD");
            db.Close();
            return result;
        }

        public string SaveData(string flag, Vendor param, string uid)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                dynamic args = new
                {
                    Flag = flag,
                    param.VendorCd,
                    param.SAPVendorID,
                    param.VendorName,
                    param.PaymentMethodCd,
                    param.PaymentTermCd,
                    param.VendorPlant,
                    param.PurchGroup,
                    param.Address,
                    param.City,
                    param.Phone,
                    param.Fax,
                    param.Attention,
                    param.Postal,
                    param.Country,
                    param.Mail,
                    uid
                };
                
                result = db.SingleOrDefault<string>("Master/Vendor/SaveData", args);
                db.Close();                
            }
            catch (Exception ex)
            {
                result = "Error| " + Convert.ToString(ex.Message);
            }
            return result;
        }

        public Vendor GetSelectedData(string VendorCd)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                VendorCd
            };

            var data = db.Fetch<Vendor>("Master/Vendor/GetSelectedData", args);
            db.Close();

            return data.Count == 0 ? new Vendor() : data[0];
        }

        public string GetPlantData(string VendorCd)
        {
            string Plant = "";
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                VendorCd
            };

            var data = db.Fetch<Vendor>("Master/Vendor/GetSelectedData", args);
            db.Close();

            if (data.Count > 0)
            {
                foreach (var item in data)
                {
                    Plant = item.VendorPlant;
                }
            }
            return Plant;
        }

        public string CheckPlantCodeByRegNo(string PlantCd, string RegNo)
        {
            string SetDisablePlant = "FALSE";
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                PlantCd,
                RegNo
            };

            var data = db.Fetch<Vendor>("Master/Vendor/CheckPlantCodeByRegNo", args);
            db.Close();

            if (data.Count > 0)
            {
                foreach (var item in data)
                {
                    SetDisablePlant = item.SetDisablePlant;
                }
            }
            return SetDisablePlant;
        }
        public List<Vendor> GetDownloadData(string VendorCd, string VendorName, string PayTerm, string PayMethod)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                VendorCd,
                VendorName,
                PayMethod,
                PayTerm
            };

            IEnumerable<Vendor> result = db.Fetch<Vendor>("Master/Vendor/GetDownloadData", args);

            db.Close();
            return result.ToList();
        }

        public void InsertTemporary(Vendor data)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                data.VendorCd,
                data.VendorName,
                data.VendorPlant,
                data.SAPVendorID,
                data.PurchGroup,
                data.PaymentMethodCd,
                data.PaymentTermCd,
                data.Address,
                data.City,
                data.Phone,
                data.Fax,
                data.Attention,
                data.Postal,
                data.Country,
                data.Mail,
                data.CreatedBy,
                data.ProcessId,
                data.Row,
                data.ErrorFlag
            };

            IEnumerable<Vendor> result = db.Fetch<Vendor>("Master/Vendor/InsertTemporary", args);

            db.Close();
        }

        public void UploadValidation(Int64 ProcessId, string MessageLoc, string uid)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                ProcessId,
                MessageLoc,
                uid
            };

            db.Execute("Master/Vendor/UploadValidation", args);

            db.Close();
        }

        public Int32 SaveUploadData(Int64 ProcessId, string MessageLoc, string uid)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                ProcessId,
                MessageLoc,
                uid
            };

            int result = db.SingleOrDefault<Int32>("Master/Vendor/SaveUploadData", args);
            db.Close();

            return result;
        }

        public void DeleteTemporary(Int64 ProcessId)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                ProcessId
            };

            db.Execute("Master/Vendor/DeleteTemporary", args);
            db.Close();
        }

        public Int64 GetProcessId(string Message, string MessageLoc, string MessageID, string type, string module, string func, int sts, string uid)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                Message,
                MessageLoc,
                MessageID,
                type,
                module,
                func,
                sts,
                uid
            };

            Int64 newProcessId = db.SingleOrDefault<Int64>("Master/GetProcessId", args);

            return newProcessId;
        }

        public void InsertLog(string Message, string MessageLoc, Int64 ProcessId, string MessageID, string type, string module, string func, int sts, string uid)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                Message,
                MessageLoc,
                ProcessId,
                MessageID,
                type,
                module,
                func,
                sts,
                uid
            };

            db.Execute("Master/InsertLog", args);
        }

        public IList<NameValueItem> GetVendorLookupSearchList(LookupSearchViewModel searchSearchViewModel)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IList<Vendor> result = db.Fetch<Vendor>(SqlFile.GetVendorLookupSearchList, searchSearchViewModel);
            db.Close();

            return result
                .AsNumberedNameValueList(
                    data => data.Number,
                    data => data.VendorName,
                    data => data.VendorCd)
                .ToList();
        }

        public PaginationViewModel GetVendorLookupSearchListPaging(LookupSearchViewModel searchSearchViewModel)
        {
            var model = new PaginationViewModel();
            model.DataName = DataName;
            model.TotalDataCount = GetVendorLookupSearchListCount(searchSearchViewModel);
            model.PageIndex = searchSearchViewModel.CurrentPage;
            model.PageSize = searchSearchViewModel.PageSize;

            return model;
        }

        public PaginationViewModel GetVendorEcatalgueLookupSearchListPaging(LookupCustomSearchViewModel searchSearchViewModel)
        {
            var model = new PaginationViewModel();
            model.DataName = DataName;
            model.TotalDataCount = GetVendorEcatalgueLookupSearchListCount(searchSearchViewModel);
            model.PageIndex = searchSearchViewModel.CurrentPage;
            model.PageSize = searchSearchViewModel.PageSize;

            return model;
        }

        public IList<NameValueItem> GetVendorEcatalgueLookupSearchList(LookupCustomSearchViewModel searchSearchViewModel)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IList<Vendor> result = db.Fetch<Vendor>(SqlFile.GetVendorEcatalogueLookupSearchList, searchSearchViewModel);
            db.Close();

            return result
                .AsNumberedNameValueList(
                    data => data.Number,
                    data => data.VendorName,
                    data => data.VendorCd)
                .ToList();
        }

        private Int32 GetVendorLookupSearchListCount(LookupSearchViewModel searchSearchViewModel)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            Int32 result = db.SingleOrDefault<Int32>(SqlFile.GetVendorLookupSearchListCount, searchSearchViewModel);
            db.Close();

            return result;
        }

        private Int32 GetVendorEcatalgueLookupSearchListCount(LookupCustomSearchViewModel searchSearchViewModel)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            Int32 result = db.SingleOrDefault<Int32>(SqlFile.GetVendorEcatalogueLookupSearchListCount, searchSearchViewModel);
            db.Close();

            return result;
        }

        #region new vendor list PO creation 20200123
        public IList<NameValueItem> GetVendorLookupSearchListPO(LookupSearchViewModel searchSearchViewModel)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IList<Vendor> result = db.Fetch<Vendor>(SqlFile.GetVendorLookupSearchListPO, searchSearchViewModel);
            db.Close();

            return result
                .AsNumberedNameValueList(
                    data => data.Number,
                    data => data.VendorName,
                    data => data.VendorCd)
                .ToList();
        }

        public PaginationViewModel GetVendorLookupSearchListPagingPO(LookupSearchViewModel searchSearchViewModel)
        {
            var model = new PaginationViewModel();
            model.DataName = DataName;
            model.TotalDataCount = GetVendorLookupSearchListCountPO(searchSearchViewModel);
            model.PageIndex = searchSearchViewModel.CurrentPage;
            model.PageSize = searchSearchViewModel.PageSize;

            return model;
        }

        private Int32 GetVendorLookupSearchListCountPO(LookupSearchViewModel searchSearchViewModel)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            Int32 result = db.SingleOrDefault<Int32>(SqlFile.GetVendorLookupSearchListCountPO, searchSearchViewModel);
            db.Close();

            return result;
        }

        #endregion
    }
}