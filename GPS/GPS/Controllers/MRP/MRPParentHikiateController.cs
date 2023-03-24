using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using GPS.Models.Common;
using GPS.CommonFunc;
using GPS.Models.MRP;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;


namespace GPS.Controllers.MRP
{
    public class MRPParentHikiateController : PageController
    {
        ProcessIdRepository processIdRepo = new ProcessIdRepository();
        string ProcessId = "";
        string USER_ID = "";

        protected override void Startup()
        {            
            Settings.Title = "Material Resource Planning : Parent Gentani Hikiate";
            ViewData["ListParentCd"] = MRPParentHikiateRepository.Instance.ListParentCd();
            ViewData["ListProcUsage"] = MRPParentHikiateRepository.Instance.ListProcUsage();
            ViewData["ListHeaderType"] = MRPParentHikiateRepository.Instance.ListHeaderType();            
        }

        private void Calldata(int Display, int Page, string ParentCd, string ProcUsage, string HeaderType, string HeaderCd, string ValidDt,string Model, string Engine, string Trans,
                                                        string DE, string ProdSfx, string Color)
        {
            Paging pg = new Paging(MRPParentHikiateRepository.Instance.CountData(ParentCd,ProcUsage, HeaderType, HeaderCd, ValidDt, Model, Engine, Trans, DE,  ProdSfx,  Color), Page, Display);
            ViewData["Paging"] = pg;
            ViewData["ListParentHikiate"] = MRPParentHikiateRepository.Instance.GetListData(ParentCd,ProcUsage, HeaderType, HeaderCd, ValidDt, Model,  Engine,  Trans,DE,  ProdSfx,  Color, pg.StartData, pg.EndData);
        }       

        public ActionResult IsFlagAddEditCopy(string flag)
        {
            ViewData["edit"] = flag;
            ViewData["ListParentCd"] = MRPParentHikiateRepository.Instance.ListParentCd();
            ViewData["ListProcUsage"] = MRPParentHikiateRepository.Instance.ListProcUsage();
            ViewData["ListHeaderType"] = MRPParentHikiateRepository.Instance.ListHeaderType();          

            return PartialView("_AddEditPopUp");
        }

        public ActionResult GetSingleData(string ParentCd, string ProcUsage,string Model, string HeaderType, string HeaderCd, string ValidDt)
        {
            return Json(MRPParentHikiateRepository.Instance.GetSingleData(ParentCd,ProcUsage,Model, HeaderType, HeaderCd, ValidDt));
        }

        public string GetListHeaderCode(string HeaderType)
        {
            string result = MRPParentHikiateRepository.Instance.GetListHeaderCode(HeaderType);
            return result;
        }       
       
        [HttpPost]
        public ActionResult SearchData(int Display, int Page, string USER_NAME, string ParentCd, string ProcUsage, string HeaderType, string HeaderCd, string ValidDt,string Model, string Engine, string Trans,
                                                        string DE, string ProdSfx, string Color)
        {
            Calldata(Display, Page, ParentCd, ProcUsage, HeaderType, HeaderCd,ValidDt, Model,  Engine,  Trans,DE,  ProdSfx,  Color);

            ViewData["USER_NAME"] = USER_NAME;
           
            return PartialView("_Grid");
        }

        public ContentResult SearchLookup(int Display, int Page, string ParentCd)
        {
            List<MRPParentHikiate> selectParentCd = MRPParentHikiateRepository.Instance.GetListDataParentCd(ParentCd, (((Page - 1) * Display) + 1), (Page * Display)).ToList();
           
            var jsonserializer = new JavaScriptSerializer();
            var json = jsonserializer.Serialize(selectParentCd);

            return Content(json);
        }

        //paging popup
        public ContentResult LookupPaging(string ParentCd, int pageSize)
        {
            int count = 0;
            count = MRPParentHikiateRepository.Instance.CountDataParentCd(ParentCd);

            PagingLookup PG = new PagingLookup();
            List<int> index = new List<int>();

            PG.Length = count;
            PG.CountData = count;

            Double Total = Math.Ceiling((Double)count / (Double)pageSize);
            for (int i = 1; i <= Total; i++)
            {
                index.Add(i);
            }
            PG.IndexList = index;

            var jsonserializer = new JavaScriptSerializer();
            var json = jsonserializer.Serialize(PG);
            return Content(json);
        }

        public ActionResult SaveData(string flag, MRPParentHikiate data)
        {
            string message = "";

            message = MRPParentHikiateRepository.Instance.SaveData(flag, data);

            return new JsonResult
            {
                Data = new
                {
                    message = message                    
                }
            };
        }

        public ActionResult DeleteData(string key, string ParentCd, string ProcUsage, string HeaderType, string HeaderCd, string ValidDt)
        {
            string message = "";
            try
            {
                message = MRPParentHikiateRepository.Instance.DeleteData(key, ParentCd,ProcUsage, HeaderType, HeaderCd, ValidDt);
            }
            catch (Exception e)
            {
                message = e.Message.ToString();
                return Json(message, JsonRequestBehavior.AllowGet);
            }

            return Json(message, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ValidateDownloadData(string ParentCd, string ProcUsage, string HeaderType, string HeaderCd, string ValidDt)
        {
            int count = 0;

            //count = MRPParentHikiateRepository.Instance.CountData(ParentCd, ProcUsage, HeaderType, HeaderCd, ValidDt,string Model, string Engine, string Trans,
              //                                          string DE, string ProdSfx, string Color);

            return Json(count, JsonRequestBehavior.AllowGet);
        }

        public ActionResult DownloadData2(object sender, EventArgs e, string ParentCd, string ProcUsage, string HeaderType, string HeaderCd, string ValidDt)
        {
            var data = MRPParentHikiateRepository.Instance.GetDownloadData(ParentCd,ProcUsage, HeaderType, HeaderCd, ValidDt);

            string filename = "";
            string filesTmp = HttpContext.Request.MapPath("~/Content/Download/ParentHikiate.xls");
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

                ICellStyle styleContent2 = workbook.CreateCellStyle();
                styleContent2.VerticalAlignment = VerticalAlignment.TOP;
                styleContent2.BorderLeft = BorderStyle.THIN;
                styleContent2.BorderRight = BorderStyle.THIN;
                styleContent2.BorderBottom = BorderStyle.THIN;
                styleContent2.Alignment = HorizontalAlignment.RIGHT;

                ICellStyle styleContent3 = workbook.CreateCellStyle();
                styleContent3.VerticalAlignment = VerticalAlignment.TOP;
                styleContent3.BorderLeft = BorderStyle.THIN;
                styleContent3.BorderRight = BorderStyle.THIN;
                styleContent3.BorderBottom = BorderStyle.THIN;
                styleContent3.Alignment = HorizontalAlignment.LEFT;

                ISheet sheet = workbook.GetSheet("Sheet1");
                string date = DateTime.Now.ToString("yyyyMMddhhmmss");
                filename = "MRP-ParentHikiate_" + date + ".xls";

                string dateNow = DateTime.Now.ToString("dd-MM-yyyy");
                sheet.GetRow(2).GetCell(2).SetCellValue(this.GetCurrentUsername());
                sheet.GetRow(3).GetCell(2).SetCellValue(dateNow);               

                int row = 7;
                IRow Hrow;
                foreach (var item in data)
                {
                    Hrow = sheet.CreateRow(row);

                    Hrow.CreateCell(1).SetCellValue(item.PARENT_CD);
                    Hrow.CreateCell(2).SetCellValue(item.PROC_USAGE_CD);
                    Hrow.CreateCell(3).SetCellValue(item.GENTANI_HEADER_TYPE);
                    Hrow.CreateCell(4).SetCellValue(item.GENTANI_HEADER_CD);
                    Hrow.CreateCell(5).SetCellValue(item.MULTIPLY_USAGE);                   
                    Hrow.CreateCell(6).SetCellValue(item.VALID_DT_FR);
                    Hrow.CreateCell(7).SetCellValue(item.VALID_DT_TO);
                    Hrow.CreateCell(8).SetCellValue(item.CREATED_BY);
                    Hrow.CreateCell(9).SetCellValue(item.CREATED_DT); 
                    Hrow.CreateCell(10).SetCellValue(item.CHANGED_BY); 
                    Hrow.CreateCell(11).SetCellValue(item.CHANGED_DT);
                  
                    Hrow.GetCell(1).CellStyle = styleContent;
                    Hrow.GetCell(2).CellStyle = styleContent;
                    Hrow.GetCell(3).CellStyle = styleContent;
                    Hrow.GetCell(4).CellStyle = styleContent;
                    Hrow.GetCell(5).CellStyle = styleContent2;
                    Hrow.GetCell(6).CellStyle = styleContent;
                    Hrow.GetCell(7).CellStyle = styleContent;
                    Hrow.GetCell(8).CellStyle = styleContent;
                    Hrow.GetCell(9).CellStyle = styleContent;
                    Hrow.GetCell(10).CellStyle = styleContent;
                    Hrow.GetCell(11).CellStyle = styleContent;
                   
                    row++;
                }

                MemoryStream ms = new MemoryStream();
                workbook.Write(ms);
                ftmp.Close();
                Response.BinaryWrite(ms.ToArray());
                Response.ContentType = "application/vnd.ms-excel";
                Response.AddHeader("content-disposition", String.Format("attachment;filename={0}", filename));

            }

            ViewData["ListParentCd"] = MRPParentHikiateRepository.Instance.ListParentCd();
            ViewData["ListProcUsage"] = MRPParentHikiateRepository.Instance.ListProcUsage();
            ViewData["ListHeaderType"] = MRPParentHikiateRepository.Instance.ListHeaderType();
            //Calldata(10, 1, ParentCd, ProcUsage, HeaderType, HeaderCd, ValidDt);

            return PartialView("_Grid");
        }

        public ActionResult DownloadData(object sender, EventArgs e, string ParentCd, string ProcUsage, string HeaderType, string HeaderCd, string ValidDt)
        {
            var data = MRPParentHikiateRepository.Instance.GetDownloadData(ParentCd, ProcUsage, HeaderType, HeaderCd, ValidDt);

            string filename = "";
            string filesTmp = HttpContext.Request.MapPath("~/Content/Download/ParentHikiate.xls");
            FileInfo FI = new FileInfo(filesTmp);
            if (FI.Exists)
            {
                FileStream ftmp = new FileStream(filesTmp, FileMode.Open, FileAccess.Read);

                HSSFWorkbook workbook = new HSSFWorkbook(ftmp, true);               

                ISheet sheet = workbook.GetSheet("Sheet1");
                string date = DateTime.Now.ToString("yyyyMMddhhmmss");
                filename = "MRP-ParentHikiate_" + date + ".xls";
             
                int row = 1;
                IRow Hrow;
                foreach (var item in data)
                {
                    Hrow = sheet.CreateRow(row);

                    Hrow.CreateCell(0).SetCellValue(item.PARENT_CD);
                    Hrow.CreateCell(1).SetCellValue(item.PROC_USAGE_CD);
                    Hrow.CreateCell(2).SetCellValue(item.GENTANI_HEADER_TYPE);
                    Hrow.CreateCell(3).SetCellValue(item.GENTANI_HEADER_CD);
                    Hrow.CreateCell(4).SetCellValue(item.MULTIPLY_USAGE);
                    Hrow.CreateCell(5).SetCellValue(item.VALID_DT_FR);
                    Hrow.CreateCell(6).SetCellValue(item.VALID_DT_TO);
                    Hrow.CreateCell(7).SetCellValue(item.CREATED_BY);
                    Hrow.CreateCell(8).SetCellValue(item.CREATED_DT);
                    Hrow.CreateCell(9).SetCellValue(item.CHANGED_BY);
                    Hrow.CreateCell(10).SetCellValue(item.CHANGED_DT);                 

                    row++;
                }

                MemoryStream ms = new MemoryStream();
                workbook.Write(ms);
                ftmp.Close();
                Response.BinaryWrite(ms.ToArray());
                Response.ContentType = "application/vnd.ms-excel";
                Response.AddHeader("content-disposition", String.Format("attachment;filename={0}", filename));

            }

            ViewData["ListParentCd"] = MRPParentHikiateRepository.Instance.ListParentCd();
            ViewData["ListProcUsage"] = MRPParentHikiateRepository.Instance.ListProcUsage();
            ViewData["ListHeaderType"] = MRPParentHikiateRepository.Instance.ListHeaderType();
            //Calldata(10, 1, ParentCd, ProcUsage, HeaderType, HeaderCd, ValidDt);

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
            string filepath = Path.Combine(Server.MapPath("~/Content/Download/Template/MRP_PARENT_HAKIATE.xls"));
            byte[] docBytes = StreamFile(filepath);

            return File(docBytes, "application/vmd.ms-excel", "MRP_PARENT_HAKIATE.xls");
        }

        public ActionResult CekTemplate()
        {
            string cektemplate = "";

            string filesTmp = HttpContext.Request.MapPath("~/Content/Download/Template/MRP_PARENT_HAKIATE.xls");
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
            MRPParentHikiate data = new MRPParentHikiate();
            string resultFilePath = "";
            string savefile = "";
            string message = "";

            ProcessId = "0"; //processIdRepo.GetNewProcessId();
            USER_ID = "SYSTEM";
            string ModuleID = "4";
            string FunctionID = "406001";
            string Status = "0";

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
                MRPParentHikiateRepository.Instance.DELETE_TB_T();
                for (int i = 0; i < sheet.LastRowNum; i++)
                {
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(0).ToString())) 
                            data.PARENT_CD = sheet.GetRow(row).GetCell(0).ToString();
                        else
                            data.PARENT_CD = "";
                    }
                    catch
                    {
                        data.PARENT_CD = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(1).ToString()))
                            data.PROC_USAGE_CD = sheet.GetRow(row).GetCell(1).ToString();
                        else
                            data.PROC_USAGE_CD = "";
                    }
                    catch
                    {
                        data.PROC_USAGE_CD = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(2).ToString()))
                            data.GENTANI_HEADER_TYPE = sheet.GetRow(row).GetCell(2).ToString();
                        else
                            data.GENTANI_HEADER_TYPE = "";
                    }
                    catch
                    {
                        data.GENTANI_HEADER_TYPE = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(3).ToString()))
                            data.GENTANI_HEADER_CD = sheet.GetRow(row).GetCell(3).ToString();
                        else
                            data.GENTANI_HEADER_CD = "";
                    }
                    catch
                    {
                        data.GENTANI_HEADER_CD = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(4).ToString()))
                            data.MULTIPLY_USAGE_STRING = sheet.GetRow(row).GetCell(4).ToString();
                        else
                            data.MULTIPLY_USAGE_STRING = "";
                    }
                    catch
                    {
                        data.MULTIPLY_USAGE_STRING = "";
                    }

                    if (sheet.GetRow(row).GetCell(5) == null)
                        data.VALID_DT_FR = null;
                    else
                    {
                        data.VALID_DT_FR = sheet.GetRow(row).GetCell(5).ToString();
                        if (data.VALID_DT_FR == "")
                            data.VALID_DT_FR = null;
                    } 

                    if (sheet.GetRow(row).GetCell(6) == null)
                        data.VALID_DT_TO = null;
                    else
                    {
                        data.VALID_DT_TO = sheet.GetRow(row).GetCell(6).ToString();
                        if (data.VALID_DT_TO == "")
                            data.VALID_DT_TO = null;                       
                    }                   
                  
                    MRPParentHikiateRepository.Instance.INSERT_TB_T(row, LINE, data);
                    row++;
                    LINE++;
                }

                //LOG start
                //MRPParentHikiateRepository.Instance.Log_Header(Convert.ToInt64(ProcessId), ModuleID, FunctionID, Status, UserName);

                message = MRPParentHikiateRepository.Instance.UploadToDatabase(UserName, Convert.ToInt64(ProcessId));

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