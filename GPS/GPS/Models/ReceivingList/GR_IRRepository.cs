using System;
using System.Collections.Generic;
using System.Linq;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;
using GPS.Common.Data;
using GPS.Core;
using GPS.Core.ViewModel;
using GPS.ViewModels.ReceivingList;

namespace GPS.Models.ReceivingList
{
    public class GR_IRRepository
    {
        private GR_IRRepository() { }

        #region Singleton
        private static GR_IRRepository instance = null;
        public static GR_IRRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new GR_IRRepository();
                }
                return instance;
            }
        }
        #endregion

        public int countGR_IR_DATA(string poNoSearch, string receivingDateSearch,
            string supplierSearch, string poDateSearch, string matDocNoSearch, string statusSearch)
        {
            string receivingDateSearchFrom = "";
            string receivingDateSearchTo = "";
            if (receivingDateSearch != null && !"".Equals(receivingDateSearch))
            {
                string[] receivingDateSearchArray = receivingDateSearch.Split('-');
                receivingDateSearchFrom = receivingDateSearchArray[0].Trim();
                receivingDateSearchTo = receivingDateSearchArray[1].Trim();
            }

            string poDateSearchFrom = "";
            string poDateSearchTo = "";
            if (poDateSearch != null && !"".Equals(poDateSearch))
            {
                string[] poDateSearchArray = poDateSearch.Split('-');
                poDateSearchFrom = poDateSearchArray[0].Trim();
                poDateSearchTo = poDateSearchArray[1].Trim();
            }

            if (supplierSearch != null && !"".Equals(supplierSearch))
            {
                string[] supplierSearchArray = supplierSearch.Split(';');

                for (int i = 0; i < supplierSearchArray.Count(); i++)
                {
                    if (i == 0)
                    {
                        supplierSearch = "'" + supplierSearchArray[i] + "'";
                    }
                    else
                    {
                        supplierSearch = supplierSearch + ",'" + supplierSearchArray[i] + "'";
                    }
                }
            }

            if (statusSearch != null && !"".Equals(statusSearch))
            {
                string[] statusSearchArray = statusSearch.Split(';');

                for (int i = 0; i < statusSearchArray.Count(); i++)
                {
                    if (i == 0)
                    {
                        statusSearch = "'" + statusSearchArray[i] + "'";
                    }
                    else
                    {
                        statusSearch = statusSearch + ",'" + statusSearchArray[i] + "'";
                    }
                }
            }

            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                RECEIVING_DATE_FROM = receivingDateSearchFrom,
                RECEIVING_DATE_TO = receivingDateSearchTo,
                PO_DATE_FROM = poDateSearchFrom,
                PO_DATE_TO = poDateSearchTo,
                PO_NO = poNoSearch,
                SUPPLIER = supplierSearch,
                MATDOC_NO = matDocNoSearch,
                STATUS = statusSearch
            };
            return db.SingleOrDefault<int>("CountGR_IR_DATA", args);
        }

        public List<GR_IR_DATA> GetGR_IR_DATA(string poNoSearch, string receivingDateSearch,
            string supplierSearch, string poDateSearch, string matDocNoSearch, string statusSearch,
            int fromNumber, int toNumber)
        {
            string receivingDateSearchFrom = "";
            string receivingDateSearchTo = "";
            if (receivingDateSearch != null && !"".Equals(receivingDateSearch))
            {
                string[] receivingDateSearchArray = receivingDateSearch.Split('-');
                receivingDateSearchFrom = receivingDateSearchArray[0].Trim();
                receivingDateSearchTo = receivingDateSearchArray[1].Trim();
            }

            string poDateSearchFrom = "";
            string poDateSearchTo = "";
            if (poDateSearch != null && !"".Equals(poDateSearch))
            {
                string[] poDateSearchArray = poDateSearch.Split('-');
                poDateSearchFrom = poDateSearchArray[0].Trim();
                poDateSearchTo = poDateSearchArray[1].Trim();
            }

            if (supplierSearch != null && !"".Equals(supplierSearch))
            {
                string[] supplierSearchArray = supplierSearch.Split(';');

                for (int i = 0; i < supplierSearchArray.Count(); i++)
                {
                    if (i == 0)
                    {
                        supplierSearch = "'" + supplierSearchArray[i] + "'";
                    }
                    else
                    {
                        supplierSearch = supplierSearch + ",'" + supplierSearchArray[i] + "'";
                    }
                }
            }

            if (statusSearch != null && !"".Equals(statusSearch))
            {
                string[] statusSearchArray = statusSearch.Split(';');

                for (int i = 0; i < statusSearchArray.Count(); i++)
                {
                    if (i == 0)
                    {
                        statusSearch = "'" + statusSearchArray[i] + "'";
                    }
                    else
                    {
                        statusSearch = statusSearch + ",'" + statusSearchArray[i] + "'";
                    }
                }
            }

            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                RECEIVING_DATE_FROM = receivingDateSearchFrom,
                RECEIVING_DATE_TO = receivingDateSearchTo,
                PO_DATE_FROM = poDateSearchFrom,
                PO_DATE_TO = poDateSearchTo,
                PO_NO = poNoSearch,
                SUPPLIER = supplierSearch,
                MATDOC_NO = matDocNoSearch,
                STATUS = statusSearch,
                NumberFrom = fromNumber.ToString(),
                NumberTo = toNumber.ToString()
            };

            List<GR_IR_DATA> result = db.Fetch<GR_IR_DATA>("GetGR_IR_DATA", args);
            db.Close();
            return result;
        }


        public List<GR_IR_DATA> GetGR_IR_Notif(string vendCode)
        {

            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                VEND_CODE = vendCode
            };

            List<GR_IR_DATA> result = db.Fetch<GR_IR_DATA>("GetGR_IR_Notif", args);
            db.Close();
            return result;
        }


        public List<GR_IR_DATA> GetGR_IR_DATA_Detail(string matDocNoSearch)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                MATDOC_NO = matDocNoSearch
            };

            List<GR_IR_DATA> result = db.Fetch<GR_IR_DATA>("GetGR_IR_DATA_DETAIL", args);
            db.Close();
            return result;
        }

        //public AjaxResult SaveData(GR_IR_DATA data, string NoReg)
        //{
        //    IDBContext db = DatabaseManager.Instance.GetContext();
        //    AjaxResult ajaxResult = new AjaxResult();


        //    if (!"".Equals(data.REF_DOC)) {
        //        data.GR_STATUS = "CANCEL";
        //    }


        //    if ("102".Equals(data.MOV_TYPE))
        //    {
        //        data.MATDOC_QTY = data.MATDOC_QTY * -1;
        //        data.MATDOC_AMOUNT = data.MATDOC_AMOUNT * -1;
        //    }

        //    try
        //    {
        //        dynamic args = new
        //        {
        //            PO_NUMBER = data.PO_NUMBER,
        //            PO_ITEM = data.PO_ITEM,
        //            MATDOC_YEAR = data.MATDOC_YEAR,
        //            MATDOC_NUMBER = data.MATDOC_NUMBER,
        //            MATDOC_ITEM = data.MATDOC_ITEM,
        //            MATDOC_DATE = data.MATDOC_DATE,
        //            SPC_STOCK = data.SPC_STOCK,
        //            MATDOC_AMOUNT = data.MATDOC_AMOUNT,
        //            VEND_CODE = data.VEND_CODE,
        //            PURCHDOC_PRICE = data.PURCHDOC_PRICE,
        //            MAT_NUMBER = data.MAT_NUMBER,
        //            MAT_DESCR = data.MAT_DESCR,
        //            PLANT_CODE = data.PLANT_CODE,
        //            SLOC_CODE = data.SLOC_CODE,
        //            MATDOC_UNIT = data.MATDOC_UNIT,
        //            CANCEL = data.CANCEL,
        //            ORI_MAT_NUMBER = data.ORI_MAT_NUMBER,
        //            MATDOC_CURRENCY = data.MATDOC_CURRENCY,
        //            MATDOC_QTY = data.MATDOC_QTY,
        //            TAX_CODE = data.TAX_CODE,
        //            PO_DATE = data.PO_DATE,
        //            HEADER_TEXT = data.HEADER_TEXT,
        //            IR_NO = data.IR_NO,
        //            MOV_TYPE = data.MOV_TYPE,
        //            REF_DOC = data.REF_DOC,
        //            USRID = data.USRID,

        //            GR_STATUS = data.GR_STATUS
        //        };

        //        db.Execute("InsertGRIRFromSAP", args);

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

        //public List<GR_IR_REF> CheckGRAlreadyProcess(string poNumber, string poItem, string vendorCode, string matDocNumber)
        //{
        //    IDBContext db = DatabaseManager.Instance.GetContext();
        //    List<GR_IR_REF> result = new List<GR_IR_REF>();

        //    dynamic args = new
        //    {
        //        PO_NUMBER = poNumber,
        //        PO_ITEM = poItem,
        //        VEND_CODE = vendorCode,
        //        MATDOC_NUMBER = matDocNumber
        //    };

        //    result = db.Fetch<GR_IR_REF>("GetGRAlreadyProcess", args);

        //    db.Close();

        //    return result;
        //}

        //public AjaxResult UpdateGRStatus(string matDocNumber, string grStatus, string Noreg)
        //{
        //    IDBContext db = DatabaseManager.Instance.GetContext();
        //    AjaxResult ajaxResult = new AjaxResult();

        //    try
        //    {
        //        dynamic args = new
        //        {
        //            MATDOC_NUMBER = matDocNumber ,
        //            GR_STATUS = grStatus,
        //            UPDATED_BY = Noreg
        //        };

        //        db.Execute("UpdateGrStatus", args);

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

        //public List<GR_IR_REF> GetNewDataGR(string cancelType)
        //{
        //    IDBContext db = DatabaseManager.Instance.GetContext();
        //    List<GR_IR_REF> result = new List<GR_IR_REF>();

        //    dynamic args = new
        //    {
        //        CANCEL_TYPE = cancelType
        //    };

        //    if ("FULL".Equals(cancelType))
        //    {
        //        result = db.Fetch<GR_IR_REF>("GetRefDocGRCancel", args);
        //    }
        //    else if ("PARTIAL".Equals(cancelType))
        //    {
        //       result = db.Fetch<GR_IR_REF>("GetNewDataWithoutCancelRef", args);
        //    }

        //    db.Close();

        //    return result;
        //}


        //public AjaxResult UpdateCancelGRInitial(string RefDoc, string CancelDocNo, string notifFlag, string NoReg)
        //{
        //    IDBContext db = DatabaseManager.Instance.GetContext();
        //    AjaxResult ajaxResult = new AjaxResult();
        //    try
        //    {
        //        dynamic args = new
        //        {
        //            REF_DOC = RefDoc,  // where condition
        //            CANCEL_DOC_NO = CancelDocNo,  // Value yang akan diisi
        //            NOTIF_FLAG = notifFlag,
        //            UPDATED_BY = NoReg
        //        };

        //        db.Execute("UpdateCancelGRInitial", args);

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

        public ActionResponseViewModel SaveCancelGR(CancelGRSAViewModel viewModel)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            db.SetExecutionMode(DBContextExecutionMode.Direct);
            String result = db.ExecuteScalar<String>("EXEC sp_ReceivingList_CancelGRSA @CurrentUser, @CurrentRegNo, @ProcessId, @ModuleId, @FunctionId, @MatDoc, @CancelDate, @CancelReason", viewModel);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }

        public ActionResponseViewModel ValidateCancelGR(CancelGRSAViewModel viewModel)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            db.SetExecutionMode(DBContextExecutionMode.Direct);
            String result = db.ExecuteScalar<String>("EXEC sp_ReceivingList_ValidateCancelGRSA @CurrentUser, @MatDoc, @ProcessId", viewModel);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }
    }
}