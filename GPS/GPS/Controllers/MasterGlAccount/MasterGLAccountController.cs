using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Toyota.Common.Web.Platform;
using GPS.Models.GLACCOUNT;
using GPS.Models.Common;
using Toyota.Common.Database;
using Toyota.Common.Credential;
using GPS.CommonFunc;
using System.IO;
using GPS.Models;
using NPOI.HSSF.UserModel;

namespace GPS.Controllers.MasterGlAccount
{
    public class MasterGLAccountController : PageController
    {
        //
        // GET: /MasterGLAccount/
        IDBContext db = DatabaseManager.Instance.GetContext();
        protected override void Startup()
        {
            Settings.Title = "Master GL Account";   
        }

        public ActionResult SearchData (masterGLAccount data,int currentPage, int recordPerpage){

            try
            {
                doSearch(data, currentPage, recordPerpage);
            }
            catch (Exception e)
            { 
                
            }
            return PartialView("_GridView");
        }

        private void doSearch(masterGLAccount data, int currentPage, int recordPerpage)
        {
            Paging pg = new Paging(MasterGlAccountRepo.Instance.SearchData(data,db), currentPage, recordPerpage);
            ViewData["paging"] = pg;
            
            IList<masterGLAccount> Result =  MasterGlAccountRepo.Instance.GetListdata(data,db, pg.StartData, pg.EndData);
            ViewData["ListGLAccount"] = Result;
            
        }

        public ActionResult SaveData(masterGLAccount data, String gscreen)
        {

            String message = MasterGlAccountRepo.Instance.SaveData(data, gscreen, this.GetCurrentUsername());

            return new JsonResult { Data = new { message } };
            
        }

        public ActionResult DeleteData(String key)
        {
            string message = "";

            try 
            {
                message = MasterGlAccountRepo.Instance.DeleteData(key, this.GetCurrentUsername());
            }catch(Exception ex)
            {
                message = ex.Message.ToString();
                return Json("Error|" + message, JsonRequestBehavior.AllowGet);
            }

            return Json(message, JsonRequestBehavior.AllowGet);
        }

        public void DownloadReport(string GL_ACCOUNT_CD, string GL_ACCOUNT_DESC, string PLANT_CD, int currentPage, int recordPerPage)
        {
            Paging pg = new Paging(MasterGlAccountRepo.Instance.CountData(GL_ACCOUNT_CD,GL_ACCOUNT_DESC, PLANT_CD),currentPage,recordPerPage);
            ViewData["Paging"] = pg;
            List<masterGLAccount> List = MasterGlAccountRepo.Instance.GetData(
                GL_ACCOUNT_CD, GL_ACCOUNT_DESC, PLANT_CD, currentPage, recordPerPage).ToList();
            var workboook = new HSSFWorkbook();
            string FileName = string.Format("GL_Account_Master_" + DateTime.Now.ToString("yyyyMMddhhmmss") + ".xls", DateTime.Now).Replace("/", "-");//for file name
            List<string[]> ListArr = new List<string[]>();//array for choose data
            String[] header = new string[7] {  "GL Account Code", "GL Account Description",
                                                "Plant Code","Created By", "Created Date", "Changed By",
                                                "Changed Date"};//for header name
            ListArr.Add(header);
            //choose data for show in report
            foreach (masterGLAccount obj in List)
            {
                String[] myArr = new string[7]
                {
                    obj.GL_ACCOUNT_CD ,
                    obj.GL_ACCOUNT_DESC ,
                    obj.PLANT_CD ,
                    obj.CREATED_BY ,
                    obj.CREATED_DT ,
                    obj.CHANGED_BY ,
                    obj.CHANGED_DT
                };
                ListArr.Add(myArr);
            }
            workboook = CommonDownload.Instance.CreateExcelSheet(ListArr, "GLAccountMaster");//call function execute report
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
    }
}
