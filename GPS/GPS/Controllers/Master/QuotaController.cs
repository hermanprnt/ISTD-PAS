using System;
using System.Collections.Generic;
using GPS.Constants;
using System.Web.Mvc;
using System.IO;
using GPS.CommonFunc;
using GPS.Models.Common;
using GPS.Models.Master;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;

namespace GPS.Controllers.Master
{
    public class QuotaController : PageController
    {
        public QuotaController()
        {
            Settings.Title = "Quota Master";
        }

        public static SelectList SelectType()
        {
            return QuotaRepository.Instance
                    .GetListType()
                    .AsSelectList(ty => ty.TYPE_DESCRIPTION, ty => ty.QUOTA_TYPE);
        }

        public string GetListWBS(string DivisionID)
        {
            string result = QuotaRepository.Instance.GetListWBS(DivisionID);
            return result;
        }  

        private void CallHeaderData(int Display = 10, int Page = 1, string division_name=null, string wbs = null, string type=null, string ord_coord=null)
        {
            Paging pg = new Paging(CountHeaderData(division_name, wbs,type, ord_coord), Page, Display);
            ViewData["PagingQuotaMaster"] = pg; 
            List<Quota> list = GetHeaderData(pg.StartData, pg.EndData, division_name, wbs,type, ord_coord);
            ViewData["ListQuotaMaster"] = list;
        }

        private int CountHeaderData(string division_name, string wbs, string type, string ord_coord)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
               
                DIVISION_NAME = division_name,
                WBS_NO = wbs,
                TYPE = type,               
                ORD_COORD = ord_coord,
            };
            int count = db.SingleOrDefault<int>("Quota/CountTotalQuotaMaster", args);
            db.Close();
            return count;
        }

        private List<Quota> GetHeaderData(int start, int end, string division_name, string wbs, string type, string ord_coord)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Start = start,
                End = end,
                DIVISION_NAME = division_name,
                WBS_NO = wbs,
                TYPE = type,                
                ORD_COORD = ord_coord,

            };
            List<Quota> list = db.Fetch<Quota>("Quota/ReadQuotaMaster", args);
            db.Close();
            return list;
        }

        public ActionResult onGetData(string search="",int Display = 10, int Page=1, string division_name=null, string wbs = null,string type=null, string ord_coord=null)
        {
            if (search == "Y")
            {
                CallHeaderData(Display, Page, division_name,wbs, type, ord_coord);
                return PartialView("_QuotaGrid");
            }
            else
            {
                return PartialView("_QuotaGrid");
            }
        }                  

        public ActionResult IsFlagAddEditCopy(string flag)
        {
            ViewData["edit"] = flag;

            return PartialView("_PopUpAddHeader");
        }

        public ActionResult GetSingleData(string DivisionID, string QuotaType)
        {
            return Json(QuotaRepository.Instance.GetSingleDataQuota(DivisionID, QuotaType));
        }

        public ActionResult DeleteQuota(string Key)
        {           
            string message = "";
            try
            {
                message = QuotaRepository.Instance.DeleteData(Key);
            }
            catch (Exception e)
            {
                message = e.Message.ToString();
                return Json("Error|" + message, JsonRequestBehavior.AllowGet);
            }

            return Json(message, JsonRequestBehavior.AllowGet);
        }

        //for save data
        public ActionResult SaveQuotaMaster(string flag, Quota quota)
        {           
            string message = "";

            message = QuotaRepository.Instance.SaveData(flag, quota, this.GetCurrentUsername());

            return new JsonResult
            {
                Data = new
                {
                    message = message
                }
            };
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
            string filepath = Path.Combine(Server.MapPath(ReportPath.TemplateQuota));
            byte[] docBytes = StreamFile(filepath);

            return File(docBytes, "application/vmd.ms-excel", "QUOTA.xls");
        }

        public ActionResult CekTemplate()
        {
            string cektemplate = "";

            string filesTmp = HttpContext.Request.MapPath("~/Content/Download/Template/Quota.xls");
            FileInfo FI = new FileInfo(filesTmp);
            if (FI.Exists)
                cektemplate = "True";
            else
                cektemplate = "False";

            return Json(cektemplate, JsonRequestBehavior.AllowGet);
        }

        public ActionResult DownloadData(string division_id,string wbs, string type, string ord_coord)
        {
            var data = GetDownloadData(division_id,wbs, type, ord_coord);

            string filename = "";
            string filesTmp = HttpContext.Request.MapPath("~/Content/Download/Quota.xls");
            FileInfo FI = new FileInfo(filesTmp);
            if (FI.Exists)
            {
                FileStream ftmp = new FileStream(filesTmp, FileMode.Open, FileAccess.Read);

                HSSFWorkbook workbook = new HSSFWorkbook(ftmp, true);

                ISheet sheet = workbook.GetSheet("Sheet1");
                string date = DateTime.Now.ToString("yyyyMMddhhmmss");
                filename = "Quota_" + date + ".xls";

                int row = 1;
                IRow Hrow;
                foreach (var item in data)
                {
                    Hrow = sheet.CreateRow(row);

                    Hrow.CreateCell(0).SetCellValue(item.DIVISION_NAME);
                    Hrow.CreateCell(1).SetCellValue(item.WBS_NO);
                    Hrow.CreateCell(2).SetCellValue(item.TYPE_DESCRIPTION);
                    Hrow.CreateCell(3).SetCellValue(item.ORDER_COORD_NAME);
                    Hrow.CreateCell(4).SetCellValue(string.Format("{0:N0}", item.QUOTA_AMOUNT));
                    Hrow.CreateCell(5).SetCellValue(string.Format("{0:N0}", item.QUOTA_AMOUNT_TOL));
                    Hrow.CreateCell(6).SetCellValue(item.CREATED_BY);
                    Hrow.CreateCell(7).SetCellValue(item.CREATED_DT);
                    Hrow.CreateCell(8).SetCellValue(item.CHANGED_BY);
                    Hrow.CreateCell(9).SetCellValue(item.CHANGED_DT);

                    row++;
                }

                MemoryStream ms = new MemoryStream();
                workbook.Write(ms);
                ftmp.Close();
                Response.BinaryWrite(ms.ToArray());
                Response.ContentType = "application/vnd.ms-excel";
                Response.AddHeader("content-disposition", String.Format("attachment;filename={0}", filename));
            }

            CallHeaderData(10, 1, null, null, null,null);

            return PartialView("_QuotaGrid");
        }

        public IEnumerable<Quota> GetDownloadData(string division_id,string wbs, string type, string ord_coord)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                DIVISION_ID = division_id,
                WBS_NO = wbs,
                TYPE = type,
                ORD_COORD = ord_coord
            };

            IEnumerable<Quota> result = db.Fetch<Quota>("Quota/DownloadData", args);
            db.Close();
            return result;
        }

        [HttpPost]
        public ActionResult UploadFile()
        {
            Quota data = new Quota();
            string resultFilePath = "";
            string savefile = "";
            string message = "";

            string ProcessId = "0";
            string UserName = this.GetCurrentUsername();          

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
                QuotaRepository.Instance.DELETE_TB_T();
                for (int i = 0; i < sheet.LastRowNum; i++)
                {

                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(0).ToString()))
                            data.DIVISION_ID2 = sheet.GetRow(row).GetCell(0).ToString();
                        else
                            data.DIVISION_ID2 = "";
                    }
                    catch
                    {
                        data.DIVISION_ID2 = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(1).ToString()))
                            data.DIVISION_NAME = sheet.GetRow(row).GetCell(1).ToString();
                        else
                            data.DIVISION_NAME = "";
                    }
                    catch
                    {
                        data.DIVISION_NAME = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(2).ToString()))
                            data.WBS_NO = sheet.GetRow(row).GetCell(2).ToString();
                        else
                            data.WBS_NO = "";
                    }
                    catch
                    {
                        data.WBS_NO = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(3).ToString()))
                            data.QUOTA_TYPE = sheet.GetRow(row).GetCell(3).ToString();
                        else
                            data.QUOTA_TYPE = "";
                    }
                    catch
                    {
                        data.QUOTA_TYPE = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(4).ToString()))
                            data.TYPE_DESCRIPTION = sheet.GetRow(row).GetCell(4).ToString();
                        else
                            data.TYPE_DESCRIPTION = "";
                    }
                    catch
                    {
                        data.TYPE_DESCRIPTION = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(5).ToString()))
                            data.ORDER_COORD2 = sheet.GetRow(row).GetCell(5).ToString();
                        else
                            data.ORDER_COORD2 = "";
                    }
                    catch
                    {
                        data.ORDER_COORD2 = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(6).ToString()))
                            data.ORDER_COORD_NAME = sheet.GetRow(row).GetCell(6).ToString();
                        else
                            data.ORDER_COORD_NAME = "";
                    }
                    catch
                    {
                        data.ORDER_COORD_NAME = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(7).ToString()))
                            data.QUOTA_AMOUNT2 = sheet.GetRow(row).GetCell(7).ToString();
                        else
                            data.QUOTA_AMOUNT2 = "";
                    }
                    catch
                    {
                        data.QUOTA_AMOUNT2 = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(8).ToString()))
                            data.QUOTA_AMOUNT_TOL2 = sheet.GetRow(row).GetCell(8).ToString();
                        else
                            data.QUOTA_AMOUNT_TOL2 = "";
                    }
                    catch
                    {
                        data.QUOTA_AMOUNT_TOL2 = "";
                    }

                    QuotaRepository.Instance.INSERT_TB_T(row, LINE, data);
                    row++;
                    LINE++;
                }


                message = QuotaRepository.Instance.UploadToDatabase(UserName, Convert.ToInt64(ProcessId));

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

        public ActionResult GenerateData(string Years)
        {
            string message = "";

            try
            {
                message = QuotaRepository.Instance.GenerateQuota(Years, this.GetCurrentUsername());
            }
            catch (Exception e)
            {
                message = e.Message.ToString();
                return Json(new { message = "Error|" + message }, JsonRequestBehavior.AllowGet);
            }

            return new JsonResult
            {
                Data = new
                {
                    message = message
                }
            };
        }

        public ActionResult GenerateDataConfirm(string Years)
        {
            string message = "";

            try
            {
                message = QuotaRepository.Instance.GenerateQuotaConfirm(Years, this.GetCurrentUsername());
            }
            catch (Exception e)
            {
                message = e.Message.ToString();
                return Json(new { message = "Error|" + message }, JsonRequestBehavior.AllowGet);
            }

            return new JsonResult
            {
                Data = new
                {
                    message = message
                }
            };
        }
    }
}