using System;
using System.Collections.Generic;
using System.Linq;
using NPOI.SS.UserModel;
using NPOI.HSSF.UserModel;
using GPS.Common.Data;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;
using System.IO;
using GPS.ViewModels.Master;

namespace GPS.Models.ReceivingList
{
    public class ReceivingListRepository
    {
        public sealed class SqlFile
        {
            public const String _Root_Folder = "ReceivingList/";

            public const String CountReceivingList = _Root_Folder + "CountReceivingList";
            public const String CountReceivingListDetail = _Root_Folder + "CountReceivingListDetail";
            public const String GetReceivingList = _Root_Folder + "GetReceivingList";
            public const String GetDetailReceivingList = _Root_Folder + "GetReceivingListDetail";
            public const String GetDataDetail = _Root_Folder +  "GetGR_IR_DATA_DETAIL";
            public const String GetDataExcel = _Root_Folder + "GetGR_IR_DATAExcel";
            public const String ApproveGR = _Root_Folder + "ApproveGR";
            public const String GetStatus = _Root_Folder + "GetStatusGR";
            public const String GetDownloadExcel = _Root_Folder + "GetDownloadExcel";
            public const String errorPostingDetail = _Root_Folder + "errorPostingDetail";//20191127
            public const String GetReceivingListUpload = _Root_Folder + "GetReceivingListUpload";//20230705 -> Enchanced Vision Project
            public const String DeleteGRAttachment = _Root_Folder + "DeleteGRAttachment";//20230705 -> Enchanced Vision Project
            public const String UpdateGRAttachment = _Root_Folder + "UpdateGRAttachment";//20230705 -> Enchanced Vision Project
            public const String GetAttachByid = _Root_Folder + "GetAttachByid";//20230705 -> Enchanced Vision Project
            public const String UploadInit = _Root_Folder + "UploadInit";//20230705 -> Enchanced Vision Project
            public const String concurencyChecking = _Root_Folder + "concurencyChecking";//20230705 -> Enchanced Vision Project
        }

        private ReceivingListRepository() { }

        #region Singleton
        private static ReceivingListRepository instance = null;
        public static ReceivingListRepository Instance
        {
            get { return instance ?? (instance = new ReceivingListRepository()); }
        }
        #endregion

        //public int countReceivingList(string poNoSearch, string supplierSearch, string poDateSearch, string statusSearch)
        public int countReceivingList(ReceivingListSearchViewModel viewModel)
        {
            /*string poDateSearchFrom = "";
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
            }*/

            IDBContext db = DatabaseManager.Instance.GetContext();
            /*dynamic args = new
            {
                PO_NO = poNoSearch,
                SUPPLIER = supplierSearch,
                STATUS = statusSearch,
                PO_DT_FROM = poDateSearchFrom,
                PO_DT_TO = poDateSearchTo
            };*/
            db.Close();
            return db.SingleOrDefault<int>(SqlFile.CountReceivingList, viewModel);
        }

        //public List<ReceivingList> GetReceivingList(string poNoSearch, string supplierSearch, string poDateSearch, string statusSearch, int fromNumber, int toNumber)
        public IList<ReceivingList> GetReceivingList(ReceivingListSearchViewModel viewModel)
        {
            /*string poDateSearchFrom = "";
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
            }*/

            IDBContext db = DatabaseManager.Instance.GetContext();
            /*dynamic args = new
            {
                PO_DT_FROM = poDateSearchFrom,
                PO_DT_TO = poDateSearchTo,
                PO_NO = poNoSearch,
                SUPPLIER = supplierSearch,
                STATUS = statusSearch,
                NumberFrom = fromNumber.ToString(),
                NumberTo = toNumber.ToString()
            };*/

            IList<ReceivingList> result = db.Fetch<ReceivingList>(SqlFile.GetReceivingList, viewModel);
            db.Close();
            return result;
        }


        public int countReceivingListDetail(String receivingNo)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                receivingNo = receivingNo
            };

            db.Close();
            return db.SingleOrDefault<int>(SqlFile.CountReceivingListDetail, args);
        }


        public List<ReceivingListDetail> GetGR_IR_DATA_Detail(string matDocNoSearch)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                MATDOC_NO = matDocNoSearch
            };

            List<ReceivingListDetail> result = db.Fetch<ReceivingListDetail>(SqlFile.GetDataDetail, args);
            db.Close();
            return result;
        }


        public IList<ReceivingListDetail> GetReceivingListDetail(String receivingNo)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IList<ReceivingListDetail> result = db.Fetch<ReceivingListDetail>(SqlFile.GetDetailReceivingList, new { ReceivingNo = receivingNo });
            db.Close();
            return result;
        }

        public string ApproveGR(string poNumber, string poItem,
            string poDate, string vendCode, string grStatus, string invoiceId, string NoReg)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";

            try
            {
                dynamic args = new
                {
                    PO_NUMBER = poNumber,
                    PO_ITEM = poItem,
                    PO_DATE = poDate,
                    VEND_CODE = vendCode,
                    GR_STATUS = grStatus,
                    INVOICE_ID = invoiceId,
                    UPDATED_BY = "user",
                    UPDATED_DT = DateTime.Now
                };

                db.Execute(SqlFile.ApproveGR, args);
                result = "SUCCESS|";
            }
            catch (Exception ex)
            {
                result = "ERR|" + ex.Message;
            }
            finally
            {
                db.Close();
            }

            return result;
        }

        //public List<string> GetInvoiceReceivingSort(string field, string sort)
        //{
        //    List<String> result = new List<String>();

        //    List<InvoiceReceiving> returnResult = new List<InvoiceReceiving>();
        //    switch (field)
        //    {
        //        case "CERTIFICATE_ID":
        //            returnResult = ((sort == "asc" || sort == "none") ? tempIR.OrderBy(o => o.CERTIFICAT_ID).ToList() : tempIR.OrderByDescending(o => o.CERTIFICAT_ID).ToList());
        //            break;
        //        case "SUPPLIER_CODE":
        //            returnResult = ((sort == "asc" || sort == "none") ? tempIR.OrderBy(o => o.SUPPLIER_CODE).ToList() : tempIR.OrderByDescending(o => o.SUPPLIER_CODE).ToList());
        //            break;
        //        case "SUPPLIER_NAME":
        //            returnResult = ((sort == "asc" || sort == "none") ? tempIR.OrderBy(o => o.SUPPLIER_NAME).ToList() : tempIR.OrderByDescending(o => o.SUPPLIER_NAME).ToList());
        //            break;
        //        case "INVOICE_NO":
        //            returnResult = ((sort == "asc" || sort == "none") ? tempIR.OrderBy(o => o.INVOICE_NO).ToList() : tempIR.OrderByDescending(o => o.INVOICE_NO).ToList());
        //            break;
        //        case "CURRENCY":
        //            returnResult = ((sort == "asc" || sort == "none") ? tempIR.OrderBy(o => o.CURRENCY).ToList() : tempIR.OrderByDescending(o => o.CURRENCY).ToList());
        //            break;
        //        case "INVOICE_AMOUNT":
        //            returnResult = ((sort == "asc" || sort == "none") ? tempIR.OrderBy(o => o.INVOICE_AMOUNT).ToList() : tempIR.OrderByDescending(o => o.INVOICE_AMOUNT).ToList());
        //            break;
        //        case "INVOICE_TAX_NO":
        //            returnResult = ((sort == "asc" || sort == "none") ? tempIR.OrderBy(o => o.INVOICE_TAX_NO).ToList() : tempIR.OrderByDescending(o => o.INVOICE_TAX_NO).ToList());
        //            break;
        //        case "INVOICE_TAX_AMOUNT":
        //            returnResult = ((sort == "asc" || sort == "none") ? tempIR.OrderBy(o => o.INVOICE_TAX_AMOUNT).ToList() : tempIR.OrderByDescending(o => o.INVOICE_TAX_AMOUNT).ToList());
        //            break;
        //        case "SUBMIT_DATE":
        //            returnResult = ((sort == "asc" || sort == "none") ? tempIR.OrderBy(o => o.SUBMIT_DATE).ToList() : tempIR.OrderByDescending(o => o.SUBMIT_DATE).ToList());
        //            break;
        //        case "SUBMIT_BY":
        //            returnResult = ((sort == "asc" || sort == "none") ? tempIR.OrderBy(o => o.SUBMIT_BY).ToList() : tempIR.OrderByDescending(o => o.SUBMIT_BY).ToList());
        //            break;
        //        case "RECEIVE_STATUS":
        //            returnResult = ((sort == "asc" || sort == "none") ? tempIR.OrderBy(o => o.RECEIVE_STATUS).ToList() : tempIR.OrderByDescending(o => o.RECEIVE_STATUS).ToList());
        //            break;
        //    }

        //    foreach (InvoiceReceiving item in returnResult)
        //    {
        //        result.Add("<tr>" +
        //                    "<td width=\"160px\" class=\"text-left\">" + item.CERTIFICAT_ID + "" +
        //                    "</td>" +
        //                    "<td width=\"80px\" class=\"text-center\">" + item.SUPPLIER_CODE + "" +
        //                    "</td>" +
        //                    "<td width=\"200px\" class=\"text-left ellipsis\" style=\"max-width: 201px;\">" + item.SUPPLIER_NAME + "" +
        //                    "</td>" +
        //                    "<td width=\"100px\" class=\"text-center\">" + item.INVOICE_NO + "" +
        //                    "</td>" +
        //                    "<td width=\"75px\" class=\"text-center\">" + item.CURRENCY + "" +
        //                    "</td>" +
        //                    "<td width=\"110px\" class=\"text-right\">" + item.INVOICE_AMOUNT.ToString("N0") + "" +
        //                    "</td>" +
        //                    "<td width=\"100px\" class=\"text-center\">" + item.INVOICE_TAX_NO + "" +
        //                    "</td>" +
        //                    "<td width=\"100px\" class=\"text-right\">" + item.INVOICE_TAX_AMOUNT.ToString("N0") + "" +
        //                    "</td>" +
        //                    "<td width=\"100px\" class=\"text-center\">" + (item.SUBMIT_DATE != DateTime.MinValue ? item.SUBMIT_DATE.ToString("dd.MM.yyyy") : "") + "" +
        //                    "</td>" +
        //                    "<td width=\"100px\" class=\"text-center\">" + item.SUBMIT_BY + "" +
        //                    "</td>" +
        //                    "<td width=\"100px\" class=\"text-left\">" + item.RECEIVE_STATUS + "" +
        //                    "</td>" +
        //                    "<td class=\"text-center\">" + item.NOTICE + "" +
        //                    "</td>" +
        //                "</tr>");
        //    }

        //    return result;
        //}


        public List<GR_IR_DATA> GetReceivingListExcel(string poNoSearch, string supplierSearch, string poDateSearch, string statusSearch)
        {
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
                PO_DT_FROM = poDateSearchFrom,
                PO_DT_TO = poDateSearchTo,
                PO_NO = poNoSearch,
                SUPPLIER = supplierSearch,
                STATUS = statusSearch
            };

            List<GR_IR_DATA> result = db.Fetch<GR_IR_DATA>(SqlFile.GetDataExcel, args);
            db.Close();
            return result;
        }


        public byte[] GenerateDownloadFile(List<GR_IR_DATA> receivingList)
        {
            byte[] result = null;
            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                result = CreateFile(receivingList);
            }
            finally
            {
                db.Close();
            }

            return result;
        }

        private byte[] CreateFile(List<GR_IR_DATA> receivingList)
        {
            if (receivingList == null)
                throw new ArgumentNullException("Data source cannot be null!!!");

            Dictionary<string, string> headers = null;
            ISheet sheet;
            HSSFWorkbook workbook = null;
            byte[] result;
            int startRow = 0;

            workbook = new HSSFWorkbook();
            sheet = workbook.CreateSheet("Receiving List");

            IDataFormat dataFormat = workbook.CreateDataFormat();
            short dateTimeFormat = dataFormat.GetFormat("dd/MM/yyyy HH:mm:ss");

            ICellStyle cellStyleData = workbook.CreateCellStyle();
            ICellStyle cellStyleHeader = workbook.CreateCellStyle();
            
            sheet.FitToPage = false;

            // write header manually
            headers = new Dictionary<string, string>();
            
            WriteDetail(sheet, startRow, cellStyleHeader, cellStyleData, receivingList);

            using (MemoryStream buffer = new MemoryStream())
            {
                workbook.Write(buffer);
                result = buffer.GetBuffer();
            }

            workbook = null;

            return result;
        }

        private void WriteDetail(
                    ISheet sheet,
                    int startRow,
                    ICellStyle cellStyleHeader,
                    ICellStyle cellStyleData,
                    List<GR_IR_DATA> receivingList)
        {
            int rowIdx = startRow;
            int colHeader = 0;

            IRow Hrow = sheet.CreateRow(rowIdx);

            // Assign data
            Hrow.CreateCell(colHeader++).SetCellValue("PO No");
            Hrow.CreateCell(colHeader++).SetCellValue("PO Date");
            Hrow.CreateCell(colHeader++).SetCellValue("Header Text");
            Hrow.CreateCell(colHeader++).SetCellValue("Receiving Date");
            Hrow.CreateCell(colHeader++).SetCellValue("Supplier Code");
            Hrow.CreateCell(colHeader++).SetCellValue("Material Doc No");
            Hrow.CreateCell(colHeader++).SetCellValue("IR Doc No");
            Hrow.CreateCell(colHeader++).SetCellValue("Status");
            Hrow.CreateCell(colHeader++).SetCellValue("Plant");
            Hrow.CreateCell(colHeader++).SetCellValue("Movement Type");
            Hrow.CreateCell(colHeader++).SetCellValue("Cancel Doc No");
            Hrow.CreateCell(colHeader++).SetCellValue("User ID");
            Hrow.CreateCell(colHeader++).SetCellValue("Invoice ID");

            // Set cell style
            colHeader = 0;
            Hrow.GetCell(colHeader++).CellStyle = cellStyleHeader;
            Hrow.GetCell(colHeader++).CellStyle = cellStyleHeader;
            Hrow.GetCell(colHeader++).CellStyle = cellStyleHeader;
            Hrow.GetCell(colHeader++).CellStyle = cellStyleHeader;
            Hrow.GetCell(colHeader++).CellStyle = cellStyleHeader;
            Hrow.GetCell(colHeader++).CellStyle = cellStyleHeader;
            Hrow.GetCell(colHeader++).CellStyle = cellStyleHeader;
            Hrow.GetCell(colHeader++).CellStyle = cellStyleHeader;
            Hrow.GetCell(colHeader++).CellStyle = cellStyleHeader;
            Hrow.GetCell(colHeader++).CellStyle = cellStyleHeader;
            Hrow.GetCell(colHeader++).CellStyle = cellStyleHeader;
            Hrow.GetCell(colHeader++).CellStyle = cellStyleHeader;
            Hrow.GetCell(colHeader++).CellStyle = cellStyleHeader;

            rowIdx = 2;
            foreach (GR_IR_DATA item in receivingList)
            {
                WriteDetailSingleData(cellStyleData, item, sheet, rowIdx++);
            }
        }


        private void WriteDetailSingleData(
          ICellStyle cellStyle,
          GR_IR_DATA item,
          ISheet sheet,
          int rowIndex)
        {
            IRow row = sheet.CreateRow(rowIndex);
            int col = 0;

            // Assign Data
            row.CreateCell(col++).SetCellValue(item.PO_NUMBER);
            row.CreateCell(col++).SetCellValue(item.PO_DATE.HasValue ? item.PO_DATE.Value.ToString("dd.MM.yyyy") : string.Empty);
            row.CreateCell(col++).SetCellValue(item.HEADER_TEXT);
            row.CreateCell(col++).SetCellValue(item.MATDOC_DATE.HasValue ? item.MATDOC_DATE.Value.ToString("dd.MM.yyyy") : string.Empty);
            row.CreateCell(col++).SetCellValue(item.VEND_CODE);
            row.CreateCell(col++).SetCellValue(item.MATDOC_NUMBER);
            row.CreateCell(col++).SetCellValue(item.IR_NO);
            row.CreateCell(col++).SetCellValue(item.GR_STATUS);
            row.CreateCell(col++).SetCellValue(item.PLANT_CODE);
            row.CreateCell(col++).SetCellValue(item.MOV_TYPE);
            row.CreateCell(col++).SetCellValue(item.CANCEL_DOC_NO);
            row.CreateCell(col++).SetCellValue(item.USRID);
            row.CreateCell(col++).SetCellValue(item.INVOICE_ID);

            // Set Cell Style
            col = 0;
            row.GetCell(col++).CellStyle = cellStyle;
            row.GetCell(col++).CellStyle = cellStyle;
            row.GetCell(col++).CellStyle = cellStyle;
            row.GetCell(col++).CellStyle = cellStyle;
            row.GetCell(col++).CellStyle = cellStyle;
            row.GetCell(col++).CellStyle = cellStyle;
            row.GetCell(col++).CellStyle = cellStyle;
            row.GetCell(col++).CellStyle = cellStyle;
            row.GetCell(col++).CellStyle = cellStyle;
            row.GetCell(col++).CellStyle = cellStyle;
            row.GetCell(col++).CellStyle = cellStyle;
            row.GetCell(col++).CellStyle = cellStyle;
            row.GetCell(col++).CellStyle = cellStyle;
        }

        public List<ReceivingList> GetStatus()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            var result = db.Fetch<ReceivingList>(SqlFile.GetStatus);

            db.Close();
            return result.ToList();
        }

        public IList<ReceivingListDownloadExcel> GetDownloadExcel(ReceivingListSearchViewModel viewModel)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            IList<ReceivingListDownloadExcel> result = db.Fetch<ReceivingListDownloadExcel>(SqlFile.GetDownloadExcel, viewModel);
            db.Close();
            return result;
        }

        //20191127
        public List<string> getErrorPosting(string receivingNo)
        {
            List<string> result = new List<string>();

            string msg = "";
            IDBContext db = DatabaseManager.Instance.GetContext();

            try
            {
                dynamic args = new
                {
                    ReceivingNo = receivingNo
                };
                result = db.Fetch<string>(SqlFile.errorPostingDetail, args);
            }
            catch (Exception e)
            {
                msg = e.Message;
            }
            finally
            {
                db.Close();
            }
            return result;
        }

        //20230705 -> Enchanced Vision Project
        public int concurencyChecking(string receivingNo, string changeDtParam)
        {
            int result = 0;

            string msg = "";
            IDBContext db = DatabaseManager.Instance.GetContext();

            try
            {
                dynamic args = new
                {
                    ReceivingNo = receivingNo,
                    ChangeDtParam = changeDtParam
                };
                result = db.SingleOrDefault<int>(SqlFile.concurencyChecking, args);
            }
            catch (Exception e)
            {
                msg = e.Message;
            }
            finally
            {
                db.Close();
            }
            return result;
        }

        public Tuple<Int64, string> UploadInit(string userid)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            Int64 PROCESS_ID = 0;
            string message = "";
            try
            {
                dynamic args = new
                {
                    USERID = userid
                };
                PROCESS_ID = db.SingleOrDefault<Int64>(SqlFile.UploadInit, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }

            return new Tuple<long, string>(PROCESS_ID, message);
        }


        public IList<ReceivingListUpload> GetReceivingListUpload(String receivingNo)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IList<ReceivingListUpload> result = db.Fetch<ReceivingListUpload>(SqlFile.GetReceivingListUpload, new { ReceivingNo = receivingNo });
            db.Close();
            return result;
        }

        public String DeleteGRAttachment(String RcvNo)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();

                result = db.SingleOrDefault<string>(SqlFile.DeleteGRAttachment, new { RcvNo = RcvNo });
                
                db.Close();
            }
            catch (Exception ex)
            {
                result = "Error| " + Convert.ToString(ex.Message);
            }

            return result;
        }

        public string UpdateGRAttachment(String RcvNo, int type, string Path, string FileName, string username)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";

            try
            {
                dynamic args = new
                {
                    RcvNo = RcvNo,
                    Type = type,
                    Path = Path,
                    FileName = FileName,
                    UpdateBy = username
                };

                result = db.SingleOrDefault<string>(SqlFile.UpdateGRAttachment, args);
                //db.Execute(SqlFile.UpdateGRAttachment, args);
                //result = "SUCCESS|" + result;
            }
            catch (Exception ex)
            {
                result = "ERR|" + ex.Message;
            }
            finally
            {
                db.Close();
            }

            return result;
        }

        public ReceivingListUpload GetAttachByid(String rcvNo, int type)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            ReceivingListUpload result = db.Fetch<ReceivingListUpload>(SqlFile.GetAttachByid, new { rcvNo = rcvNo, Type = type }).FirstOrDefault();
            db.Close();
            return result;
        }

    }
}