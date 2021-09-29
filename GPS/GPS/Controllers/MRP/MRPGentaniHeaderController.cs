using System;
using System.IO;
using System.Web.Mvc;
using GPS.Models.Common;
using GPS.CommonFunc;
using GPS.Models.MRP;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;
//using Toyota.Common.Web.UI;
using Toyota.Common.Credential;

namespace GPS.Controllers.MRP
{
    public class MRPGentaniHeaderController : PageController
    {
        ProcessIdRepository processIdRepo = new ProcessIdRepository();   
        string ProcessId = "";
        string USER_ID = "";

        protected override void Startup()
        {            
            Settings.Title = "Material Resource Planning : Gentani Header";           
            ViewData["ListProcUsage"] = MRPGentaniHeaderRepository.Instance.ListProcUsage();
            ViewData["ListHeaderType"] = MRPGentaniHeaderRepository.Instance.ListHeaderType();         
        }

        private void Calldata(int Display, int Page, string ProcUsage, string HeaderType, string HeaderCd, string ValidDt, string Model, string Engine, string Transmission, string DE, string ProdSfx, string Color)
        {
            Paging pg = new Paging(MRPGentaniHeaderRepository.Instance.CountData(ProcUsage, HeaderType, HeaderCd, ValidDt,Model,  Engine,  Transmission,  DE,  ProdSfx,  Color), Page, Display);
            ViewData["Paging"] = pg;
            ViewData["ListGentaniHeader"] = MRPGentaniHeaderRepository.Instance.GetListData(ProcUsage, HeaderType, HeaderCd, ValidDt,Model,  Engine,  Transmission,  DE,  ProdSfx,  Color, pg.StartData, pg.EndData);
        }       

        public ActionResult IsFlagAddEditCopy(string flag)
        {
            ViewData["edit"] = flag;            
            ViewData["ListProcUsage"] = MRPGentaniHeaderRepository.Instance.ListProcUsage();
            ViewData["ListHeaderType"] = MRPGentaniHeaderRepository.Instance.ListHeaderType();          

            return PartialView("_AddEditPopUp");
        }

        public ActionResult GetSingleData(string ProcUsage, string HeaderType, string HeaderCd, string ValidDt)
        {
            return Json(MRPGentaniHeaderRepository.Instance.GetSingleData(ProcUsage, HeaderType, HeaderCd, ValidDt));
        }

        public string GetListHeaderCode(string HeaderType)
        {
            string result = MRPGentaniHeaderRepository.Instance.GetListHeaderCode(HeaderType);
            return result;
        }       
       
        [HttpPost]
        public ActionResult SearchData(int Display, int Page, string USER_NAME, string ProcUsage, string HeaderType, string HeaderCd, string ValidDt,string Model, string Engine, string Transmission, string DE, string ProdSfx, string Color)
        {
            Calldata(Display, Page, ProcUsage, HeaderType, HeaderCd,ValidDt,Model,   Engine,  Transmission,  DE,  ProdSfx,  Color);

            ViewData["USER_NAME"] = USER_NAME;
           
            return PartialView("_Grid");
        }       

        public ActionResult SaveData(string flag, MRPGentaniHeader data)
        {
            string message = "";

            message = MRPGentaniHeaderRepository.Instance.SaveData(flag, data);

            return new JsonResult
            {
                Data = new
                {
                    message = message                    
                }
            };
        }

        public ActionResult DeleteData(string key, string ProcUsage, string HeaderType, string HeaderCd, string ValidDt)
        {
            string message = "";
            try
            {
                message = MRPGentaniHeaderRepository.Instance.DeleteData(key, ProcUsage, HeaderType, HeaderCd, ValidDt);
            }
            catch (Exception e)
            {
                message = e.Message.ToString();
                return Json(message, JsonRequestBehavior.AllowGet);
            }

            return Json(message, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ValidateDownloadData(string ProcUsage, string HeaderType, string HeaderCd, string ValidDt)
        {
            int count = 0;

            count = MRPGentaniHeaderRepository.Instance.CountData(ProcUsage, HeaderType, HeaderCd, ValidDt, null, null, null, null, null, null);

            return Json(count, JsonRequestBehavior.AllowGet);
        }

        public ActionResult DownloadData2(object sender, EventArgs e, string ProcUsage, string HeaderType, string HeaderCd, string ValidDt)
        {
            var data = MRPGentaniHeaderRepository.Instance.GetDownloadData(ProcUsage, HeaderType, HeaderCd, ValidDt);

            string filename = "";
            string filesTmp = HttpContext.Request.MapPath("~/Content/Download/GentaniHeader.xls");
            FileInfo FI = new FileInfo(filesTmp);
            if (FI.Exists)
            {
                FileStream ftmp = new FileStream(filesTmp, FileMode.Open, FileAccess.Read);

                HSSFWorkbook workbook = new HSSFWorkbook(ftmp, true);

                ICellStyle styleContent = workbook.CreateCellStyle();
                styleContent.VerticalAlignment = VerticalAlignment.TOP;
                styleContent.BorderLeft = BorderStyle.THIN;
                styleContent.BorderRight = BorderStyle.THIN;
                styleContent.BorderBottom = BorderStyle.THIN;
                styleContent.Alignment = HorizontalAlignment.CENTER;               

                ISheet sheet = workbook.GetSheet("Sheet1");
                string date = DateTime.Now.ToString("yyyyMMddhhmmss");
                filename = "MRP-GentaniHeader_" + date + ".xls";

                string dateNow = DateTime.Now.ToString("dd-MM-yyyy");
                sheet.GetRow(2).GetCell(2).SetCellValue(this.GetCurrentUsername());
                sheet.GetRow(3).GetCell(2).SetCellValue(dateNow);               

                int row = 7;
                IRow Hrow;
                foreach (var item in data)
                {
                    Hrow = sheet.CreateRow(row);
                   
                    Hrow.CreateCell(1).SetCellValue(item.PROC_USAGE_CD);
                    Hrow.CreateCell(2).SetCellValue(item.GENTANI_HEADER_TYPE);
                    Hrow.CreateCell(3).SetCellValue(item.GENTANI_HEADER_CD);                                     
                    Hrow.CreateCell(4).SetCellValue(item.VALID_DT_FR);
                    Hrow.CreateCell(5).SetCellValue(item.VALID_DT_TO);
                    Hrow.CreateCell(6).SetCellValue(item.CREATED_BY);
                    Hrow.CreateCell(7).SetCellValue(item.CREATED_DT); 
                    Hrow.CreateCell(8).SetCellValue(item.CHANGED_BY); 
                    Hrow.CreateCell(9).SetCellValue(item.CHANGED_DT);
                  
                    Hrow.GetCell(1).CellStyle = styleContent;
                    Hrow.GetCell(2).CellStyle = styleContent;
                    Hrow.GetCell(3).CellStyle = styleContent;
                    Hrow.GetCell(4).CellStyle = styleContent;
                    Hrow.GetCell(5).CellStyle = styleContent;
                    Hrow.GetCell(6).CellStyle = styleContent;
                    Hrow.GetCell(7).CellStyle = styleContent;
                    Hrow.GetCell(8).CellStyle = styleContent;
                    Hrow.GetCell(9).CellStyle = styleContent;                    
                   
                    row++;
                }

                MemoryStream ms = new MemoryStream();
                workbook.Write(ms);
                ftmp.Close();
                Response.BinaryWrite(ms.ToArray());
                Response.ContentType = "application/vnd.ms-excel";
                Response.AddHeader("content-disposition", String.Format("attachment;filename={0}", filename));
            }
           
            ViewData["ListProcUsage"] = MRPGentaniHeaderRepository.Instance.ListProcUsage();
            ViewData["ListHeaderType"] = MRPGentaniHeaderRepository.Instance.ListHeaderType();
            Calldata(10, 1, ProcUsage, HeaderType, HeaderCd, ValidDt, null, null, null, null, null, null);

            return PartialView("_Grid");
        }

        public ActionResult DownloadData(object sender, EventArgs e, string ProcUsage, string HeaderType, string HeaderCd, string ValidDt)
        {
            var data = MRPGentaniHeaderRepository.Instance.GetDownloadData(ProcUsage, HeaderType, HeaderCd, ValidDt);

            string filename = "";
            string filesTmp = HttpContext.Request.MapPath("~/Content/Download/GentaniHeader.xls");
            FileInfo FI = new FileInfo(filesTmp);
            if (FI.Exists)
            {
                FileStream ftmp = new FileStream(filesTmp, FileMode.Open, FileAccess.Read);

                HSSFWorkbook workbook = new HSSFWorkbook(ftmp, true);

                ISheet sheet = workbook.GetSheet("Sheet1");
                string date = DateTime.Now.ToString("yyyyMMddhhmmss");
                filename = "MRP-GentaniHeader_" + date + ".xls";              

                int row = 1;
                IRow Hrow;
                foreach (var item in data)
                {
                    Hrow = sheet.CreateRow(row);

                    Hrow.CreateCell(0).SetCellValue(item.PROC_USAGE_CD);
                    Hrow.CreateCell(1).SetCellValue(item.GENTANI_HEADER_TYPE);
                    Hrow.CreateCell(2).SetCellValue(item.GENTANI_HEADER_CD);
                    Hrow.CreateCell(3).SetCellValue(item.VALID_DT_FR);
                    Hrow.CreateCell(4).SetCellValue(item.VALID_DT_TO);
                    Hrow.CreateCell(5).SetCellValue(item.CREATED_BY);
                    Hrow.CreateCell(6).SetCellValue(item.CREATED_DT);
                    Hrow.CreateCell(7).SetCellValue(item.CHANGED_BY);
                    Hrow.CreateCell(8).SetCellValue(item.CHANGED_DT);                   

                    row++;
                }

                MemoryStream ms = new MemoryStream();
                workbook.Write(ms);
                ftmp.Close();
                Response.BinaryWrite(ms.ToArray());
                Response.ContentType = "application/vnd.ms-excel";
                Response.AddHeader("content-disposition", String.Format("attachment;filename={0}", filename));
            }

            ViewData["ListProcUsage"] = MRPGentaniHeaderRepository.Instance.ListProcUsage();
            ViewData["ListHeaderType"] = MRPGentaniHeaderRepository.Instance.ListHeaderType();
            Calldata(10, 1, ProcUsage, HeaderType, HeaderCd, ValidDt, null, null, null, null, null, null);

            return PartialView("_Grid");
        }

        private byte[] StreamFile(string filename)
        {
            FileStream fs = new FileStream(filename, FileMode.Open, FileAccess.Read);
            byte[] ImageData = new byte[fs.Length];

            fs.Read(ImageData, 0, System.Convert.ToInt32(fs.Length));

            fs.Close();

            return ImageData;
        }

        public FileContentResult DownloadTemplate()
        {
            string filepath = Path.Combine(Server.MapPath("~/Content/Download/Template/MRP_GENTANI_HEADER.xls"));
            byte[] docBytes = StreamFile(filepath);

            return File(docBytes, "application/vmd.ms-excel", "MRP_GENTANI_HEADER.xls");
        }

        public ActionResult CekTemplate()
        {
            string cektemplate = "";

            string filesTmp = HttpContext.Request.MapPath("~/Content/Download/Template/MRP_GENTANI_HEADER.xls");
            FileInfo FI = new FileInfo(filesTmp);
            if (FI.Exists)
                cektemplate = "True";
            else
                cektemplate = "False";

            return Json(cektemplate, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult UploadFile(string UserName)
        {
            MRPGentaniHeader data = new MRPGentaniHeader();
            string resultFilePath = "";
            string savefile = "";
            string message = "";

            ProcessId = "0";// processIdRepo.GetNewProcessId();
            USER_ID = "SYSTEM";            
            string ModuleID = "4";
            string FunctionID = "406001";
            string Status = "0";

            //0 = start
            //1 = proses
            //2 = finish
            //3 = finish with error
            //4 = abnormal
            
            try
            {
                #region                
                IDBContext db = DatabaseManager.Instance.GetContext();

                for (int i = 0; i < Request.Files.Count; i++)
                {
                    var file = Request.Files[i];
                    var filename = Path.GetFileName(file.FileName);
                    savefile = Path.Combine(Server.MapPath("~/Content/UploadFile"), filename);
                    resultFilePath = Path.Combine("~/Content/UploadFile", filename);
                    file.SaveAs(Server.MapPath(resultFilePath));
                }

                // open excel
                FileStream fs = new FileStream(Server.MapPath(resultFilePath), FileMode.OpenOrCreate, FileAccess.ReadWrite);
                HSSFWorkbook wb = new HSSFWorkbook(fs);
                ISheet sheet = wb.GetSheet("Sheet1");
                
                int row = 1;
                int LINE = 2;
                MRPGentaniHeaderRepository.Instance.DELETE_TB_T();
                for (int i = 0; i < sheet.LastRowNum; i++)
                {
                    
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(0).ToString()))
                            data.PROC_USAGE_CD = sheet.GetRow(row).GetCell(0).ToString();
                        else
                            data.PROC_USAGE_CD = "";
                    }
                    catch
                    {
                        data.PROC_USAGE_CD = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(1).ToString()))
                            data.GENTANI_HEADER_TYPE = sheet.GetRow(row).GetCell(1).ToString();
                        else
                            data.GENTANI_HEADER_TYPE = "";
                    }
                    catch
                    {
                        data.GENTANI_HEADER_TYPE = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(2).ToString()))
                            data.GENTANI_HEADER_CD = sheet.GetRow(row).GetCell(2).ToString();
                        else
                            data.GENTANI_HEADER_CD = "";
                    }
                    catch
                    {
                        data.GENTANI_HEADER_CD = "";
                    }
                   

                    if (sheet.GetRow(row).GetCell(3) == null)
                        data.VALID_DT_FR = null;
                    else
                    {
                        data.VALID_DT_FR = sheet.GetRow(row).GetCell(3).ToString();
                        if (data.VALID_DT_FR == "")
                            data.VALID_DT_FR = null;
                    } 

                    if (sheet.GetRow(row).GetCell(4) == null)
                        data.VALID_DT_TO = null;
                    else
                    {
                        data.VALID_DT_TO = sheet.GetRow(row).GetCell(4).ToString();
                        if (data.VALID_DT_TO == "")
                            data.VALID_DT_TO = null;                       
                    }                   
                  
                    MRPGentaniHeaderRepository.Instance.INSERT_TB_T(row, LINE, data);
                    row++;
                    LINE++;
                }

                //LOG start
                //MRPGentaniHeaderRepository.Instance.Log_Header(Convert.ToInt64(ProcessId), ModuleID, FunctionID, Status, UserName);

                message = MRPGentaniHeaderRepository.Instance.UploadToDatabase(UserName, Convert.ToInt64(ProcessId));

                if (System.IO.File.Exists(savefile))
                    System.IO.File.Delete(savefile);
          
                #endregion
            }
            catch (Exception e)
            {
                if (System.IO.File.Exists(savefile))
                    System.IO.File.Delete(savefile);

                message = e.Message.ToString();
                return Json(new { message = "Error|" + message }, JsonRequestBehavior.AllowGet);
            }

            return Json(new { message = message }, JsonRequestBehavior.AllowGet);
        }      
       
    }
}