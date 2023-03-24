using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using GPS.Models;
using GPS.Models.Common;
using GPS.Models.Master;
using NPOI.HSSF.UserModel;
using Toyota.Common.Web.Platform;
using GPS.CommonFunc;
using GPS.Constants;

namespace GPS.Controllers.Master
{
    public class SourceListController : PageController
    {
        //
        // GET: /SourceList/

        protected override void Startup()
        {
            Settings.Title = "Source List Master Screen";
            Calldata(10, 1, null, null, null, null, null, null, null, null);
            ViewData["VendorCD"] = VendorRepository.Instance.GetVendorData();
            ViewData["MaterialNo"] = SourceListRepository.Instance.GetMaterial();
        }

        public string GetListMatNo()
        {
            string result = SourceListRepository.Instance.GetListMatNo();
            return result;
        }

        public string GetListVendorCd()
        {
            string result = SourceListRepository.Instance.GetListVendorCd();
            return result;
        }

        private byte[] StreamFile(string filename)
        {
            FileStream fs = new FileStream(filename, FileMode.Open, FileAccess.Read);
            byte[] ImageData = new byte[fs.Length];

            fs.Read(ImageData, 0, Convert.ToInt32(fs.Length));

            fs.Close();

            return ImageData;
        }

        public FileContentResult DownloadTemplate()
        {
            string filepath = Path.Combine(Server.MapPath(ReportPath.TemplateSourceList));
            byte[] docBytes = StreamFile(filepath);

            return File(docBytes, "application/vmd.ms-excel", "SOURCELIST.xls");
        }

        public ActionResult CekTemplate()
        {
            string cektemplate = "";

            string filesTmp = HttpContext.Request.MapPath("~/Content/Download/Template/SOURCELIST.xls");
            FileInfo FI = new FileInfo(filesTmp);
            if (FI.Exists)
                cektemplate = "True";
            else
                cektemplate = "False";

            return Json(cektemplate, JsonRequestBehavior.AllowGet);
        }

        #region GETDATA

        private void Calldata(int Display, int Page, string mat_no, string vendor_cd, string valid_from, string valid_to,
                                            string created_by, string created_dt, string changed_by, string changed_dt)
        {
            Paging pg = new Paging(SourceListRepository.Instance.CountData(mat_no, vendor_cd, valid_from, valid_to, created_by, created_dt, changed_by, changed_dt), Page, Display);
            ViewData["Paging"] = pg;
            List<SourceList> list = SourceListRepository.Instance.GetData(pg.StartData, pg.EndData, mat_no, vendor_cd, valid_from, valid_to, created_by, created_dt, changed_by, changed_dt);
            ViewData["ListSourceList"] = list;
        }

        #endregion

        public ActionResult onGetData(string mat_no, string vendor_cd, string valid_from, string valid_to, string created_by,
                                        string created_dt, string changed_by, string changed_dt, int Display, int Page)
        {
            Calldata(Display, Page, mat_no, vendor_cd, valid_from, valid_to, created_by, created_dt, changed_by, changed_dt);

            return PartialView("_ViewTable");
        }


        //for save data
        public ActionResult SaveData(SourceList sl)
        {
            string message = "";
            try
            {
                message = SourceListRepository.Instance.SaveData(sl,this.GetCurrentUsername());
                //message = "Material <strong>" + sl.MAT_NO + "</strong>, save successfully";
            }
            catch (Exception e)
            {
                message = "Error|" + e.Message.ToString();
            }
            return Json(message, JsonRequestBehavior.AllowGet);
        }

        public ActionResult DeleteSourceList(string MAT_NO)
        {
            string valid = SourceListRepository.Instance.DeleteDataValidation(MAT_NO.Split('|')[0], MAT_NO.Split('|')[1]);

            if (valid == "")
            {
                String deleteResult =
                    CommonController.DeleteData(this, MAT_NO, id =>
                    {
                        var splittedId = id.Split('|');
                        return SourceListRepository.Instance.DeleteData(splittedId[0], splittedId[1]);
                    });

                if (deleteResult.Contains("You must checked"))
                    return PartialView("_ViewTable");

                return Content(deleteResult + " deleted");
            }
            else return Content("Error|" + valid);
        }

        //get single data (FOR UPDATE)
        public ActionResult GetSingleData(string mat_no)
        {
            var splittedId = mat_no.Split('|');
            return Json(SourceListRepository.Instance.GetSingleData(splittedId[0], splittedId[1]));
        }

        //for download data
        public void DownloadReport(int Page, int Display, string mat_no, string vendor_cd, string valid_from, string valid_to,
                                                            string created_by, string created_dt, string changed_by, string changed_dt)
        {
            Paging pg = new Paging(SourceListRepository.Instance.CountData(mat_no, vendor_cd, valid_from, valid_to, created_by, created_dt, changed_by, changed_dt), Page, Display);
            ViewData["Paging"] = pg;

            List<SourceList> List = SourceListRepository.Instance.GetData(pg.StartData, pg.CountData, mat_no, vendor_cd, valid_from, valid_to, created_by, created_dt, changed_by, changed_dt).ToList();

            var workboook = new HSSFWorkbook();

            string FileName = string.Format("SourceList.xls", DateTime.Now).Replace("/", "-");//for file name

            List<string[]> ListArr = new List<string[]>();//array for choose data
            String[] header = new string[6] {  "Material No", "Vendor Code", "Valid From", 
                                                "Valid To", "Created By","Created Date" };//for header name
            ListArr.Add(header);

            //choose data for show in report
            foreach (SourceList obj in List)
            {
                String[] myArr = new string[6] 
                { 
                    obj.MAT_NO ,
                    obj.VENDOR_CD ,
                    obj.VALID_DT_FROM.ToString() ,
                    obj.VALID_DT_TO.ToString(),
                    obj.CREATED_BY,
                    obj.CREATED_DT,
                };
                ListArr.Add(myArr);
            }
            workboook = CommonDownload.Instance.CreateExcelSheet(ListArr, "SourceList");//call function execute report
            using (var exportData = new MemoryStream())//binding to streamreader
            {
                workboook.Write(exportData);
                Response.ClearContent();
                Response.Buffer = true;
                Response.ContentType = "application/ms-excel";
                Response.AddHeader("Content-Disposition", string.Format("attachment;filename={0}", FileName));
                Response.BinaryWrite(exportData.GetBuffer());
                Response.Flush();
                Response.End();
            }
        }

        [HttpPost]
        public String GetSourceListUploadFileExtensions()
        {
            try
            {
                List<String> uploadFileExt = SystemRepository.Instance.GetSystemValue("SOURCE_LIST_FILE_EXTS").Split(',').ToList();
                return new JavaScriptSerializer().Serialize(uploadFileExt);
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize("Error: " + ex.Message);
            }
        }


        [HttpPost]
        public ActionResult UploadExcel(HttpPostedFileBase excelFile)
        {
            try
            {
                string result = SourceListRepository.Instance.SaveSourceListUploadFile(excelFile.FileName, excelFile.ContentLength, excelFile.InputStream, this.GetCurrentUsername());
                return Json(result);
            }
            catch (Exception ex)
            {
                return Json("Error: " + ex.Message);
            }
        }


    }
}
