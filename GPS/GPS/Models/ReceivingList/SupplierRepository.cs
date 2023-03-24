using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.ReceivingList
{
    public class SupplierRepository
    {
        public sealed class SqlFile
        {
            public const String _Root_Folder = "ReceivingList/";

            public const String CountData = _Root_Folder + "CountSupplier";
            public const String GetData = _Root_Folder + "GetSupplier";
        }

        private SupplierRepository() { }
        private static SupplierRepository instance = null;

        public static SupplierRepository Instance
        {
            get
            {
                if(instance==null)
                {
                    instance = new SupplierRepository();
                }
                return instance;
            }
        }

        public Supplier GetDataByID(string TAX_INVOICE_NO, string REPLACEMENT_FG)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                TAX_INVOICE_NO = TAX_INVOICE_NO,
                REPLACEMENT_FG = REPLACEMENT_FG
            };

            Supplier result = db.SingleOrDefault<Supplier>("SUPPLIER_GetByID", args);
            db.Close();

            //result.NPWP = HelperRepository.Instance.GenNPWPFormat(result.NPWP);
            return result;
        }

        //public bool InsertData(VAT_IN_ScanBarcode data, string Username, string SuppCode)
        //{
        //    if(SuppCode=="1000")
        //    {
        //        SuppCode = "";
        //    }
        //    bool status = false;
        //    IDBContext db = DatabaseManager.Instance.GetContext();
        //    dynamic args = new
        //    {
        //        TAX_INVOICE_NO = data.noFaktur,
        //        REPLACEMENT_FG = data.fgPengganti,
        //        SUPPLIER_CODE = SuppCode,
        //        NAME = data.NamaPenjual,
        //        NPWP = data.NPWPPenjual,
        //        ADDRESS = data.AlamatPenjual,
        //        CREATED_DT = DateTime.Now,
        //        CHANGED_DT = DateTime.Now,
        //        CREATED_BY = Username,
        //        CHANGED_BY = Username
        //    };

        //    try
        //    {
        //        int result = db.Execute("Supplier_InsertData", args);
        //        db.Close();
        //        status = true;
        //        return status;
        //    }
        //    catch (Exception)
        //    {
        //        db.Close();
        //        status = false;
        //        return status;
        //    }
        //}

        public List<string> GetAllSupplier()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {

            };

            List<string> result = db.Fetch<string>("Supplier_GetAll", args);
            db.Close();
            return result;
        }

        public int countSupplier(string parameter)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Parameter = parameter
            };
            return db.SingleOrDefault<int>(SqlFile.CountData, args);
        }

        public List<Supplier> GetSupplier(string parameter, int fromnumber, int tonumber)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Parameter = parameter,
                NumberFrom = fromnumber,
                NumberTo = tonumber
            };

            List<Supplier> result = db.Fetch<Supplier>(SqlFile.GetData, args);
            db.Close();
            return result;
        }

        public int countSupplier(string param1, string param2)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Parameter1 = param1,
                Parameter2 = param2
            };
            return db.SingleOrDefault<int>("CountSupplierParam2", args);
        }

        public List<Supplier> GetSupplier(string param1, string param2, int fromnumber, int tonumber)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Parameter1 = param1,
                Parameter2 = param2,
                NumberFrom = fromnumber,
                NumberTo = tonumber
            };

            List<Supplier> result = db.Fetch<Supplier>("GetSupplierParam2", args);
            db.Close();
            return result;
        }

        //public AjaxResult SaveData(Supplier supplier, string NoReg)
        //{
        //    IDBContext db = DatabaseManager.Instance.GetContext();
        //    AjaxResult ajaxResult = new AjaxResult();

        //    try
        //    {
        //        dynamic args = new
        //        {
        //            SUPPLIER_CD = supplier.SUPPLIER_CD,
        //            SUPPLIER_NAME = supplier.SUPPLIER_NAME,
        //            PKP_FLAG = supplier.PKP_FLAG,
        //            EDIT_AMOUNT_FLAG = supplier.EDIT_AMOUNT_FLAG,
        //            PPN_RATE = supplier.PPN_RATE,
        //            CREATED_BY = "The Noob",
        //        };

        //        db.Execute("InsertSupplier", args);

        //        ajaxResult.Result = AjaxResult.VALUE_SUCCESS;

        //    }
        //    catch (Exception ex)
        //    {
        //        ajaxResult.Result = AjaxResult.VALUE_ERROR;
        //        ajaxResult.ErrMesgs = new String[] { 
        //                            string.Format("{0} = {1}", ex.GetType().FullName, ex.Message), 
        //        };
        //    }
        //    finally
        //    {
        //        db.Close();
        //    }

        //    return ajaxResult;
        //}

        public Supplier GetBySupplierId(string supplierId)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                SupplierId = supplierId
            };

            Supplier result =
                db.SingleOrDefault<Supplier>("GetSupplierById", args);

            db.Close();

            return result;
        }

        public Supplier GetBySupplierCd(string supplierCd)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                SupplierCd = supplierCd
            };

            Supplier result =
                db.SingleOrDefault<Supplier>("GetSupplierByCd", args);

            db.Close();

            return result;
        }

        //public AjaxResult EditData(Supplier supplier)
        //{
        //    IDBContext db = DatabaseManager.Instance.GetContext();
        //    AjaxResult ajaxResult = new AjaxResult();

        //    try
        //    {
        //        dynamic args = new
        //        {
        //            SUPPLIER_ID = supplier.SUPPLIER_ID,
        //            SUPPLIER_CD = supplier.SUPPLIER_CD,
        //            SUPPLIER_NAME = supplier.SUPPLIER_NAME,
        //            PKP_FLAG = supplier.PKP_FLAG,
        //            EDIT_AMOUNT_FLAG = supplier.EDIT_AMOUNT_FLAG,
        //            PPN_RATE = supplier.PPN_RATE,
        //            CHANGED_BY = "The noob"
        //        };

        //        db.Execute("UpdateSupplier", args);

        //        ajaxResult.Result = AjaxResult.VALUE_SUCCESS;

        //    }
        //    catch (Exception ex)
        //    {
        //        ajaxResult.Result = AjaxResult.VALUE_ERROR;
        //        ajaxResult.ErrMesgs = new String[] { 
        //                            string.Format("{0} = {1}", ex.GetType().FullName, ex.Message), 
        //        };
        //    }
        //    finally
        //    {
        //        db.Close();
        //    }

        //    return ajaxResult;
        //}

        //public AjaxResult DeleteData(List<Supplier> supplierList)
        //{
        //    Console.Write("Delete Supplier Repo");
        //    int result = 1;
        //    IDBContext db = DatabaseManager.Instance.GetContext();

        //    AjaxResult ajaxResult = new AjaxResult();

        //    try
        //    {
        //        foreach (Supplier item in supplierList)
        //        {
        //            dynamic args = new
        //            {
        //                SUPPLIER_CD = item.SUPPLIER_CD
        //            };

        //            result = db.Execute("DeleteSupplier", args);

        //            ajaxResult.Result = AjaxResult.VALUE_SUCCESS;

        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        ajaxResult.Result = AjaxResult.VALUE_ERROR;
        //        ajaxResult.ErrMesgs = new String[] { 
        //                            string.Format("{0} = {1}", ex.GetType().FullName, ex.Message), 
        //        };
        //    }
        //    finally
        //    {
        //        db.Close();
        //    }

        //    return ajaxResult;
        //}
    }
}