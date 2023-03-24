using System;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Common;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.Master
{
    public class SystemController : PageController
    {
       
        protected override void Startup()
        {            
            Settings.Title = "System Master";            
        }

        #region COMMON LIST
        public static SelectList GetSystemValue(string functionId)
        {
            return SystemRepository.Instance
                    .GetByFunctionId(functionId)
                    .AsSelectList(sys => sys.Value, sys => sys.Code);
        }
        #endregion

        #region SEARCH DATA
        private void Calldata(int Display, int Page, string Code, string Value)
        {
            Paging pg = new Paging(SystemRepository.Instance.CountData(Code, Value), Page, Display);
            ViewData["Paging"] = pg;
            ViewData["SystemMaster"] = SystemRepository.Instance.GetListData(Code, Value, pg.StartData, pg.EndData);
        }

        [HttpPost]
        public ActionResult SearchData(string Search,int Display, int Page, string Code, string Value)
        {
            if (Search =="Y")
            {
                Calldata(Display, Page, Code, Value);
            }

            return PartialView("_Grid");
        }          

        public ActionResult GetSingleData(string FunctionID, string Code)
        {
            return Json(SystemRepository.Instance.GetSingleData(FunctionID, Code));
        }
        #endregion

        #region CRUD DATA
        public ActionResult SaveData(string flag, SystemMaster data)
        {
            string message = "";

            message = SystemRepository.Instance.SaveData(flag, data, this.GetCurrentUsername());

            return new JsonResult
            {
                Data = new
                {
                    message = message                    
                }
            };
        }

        public ActionResult DeleteData(string key)
        {
            string message = "";
            try
            {
                message = SystemRepository.Instance.DeleteData(key);
            }
            catch (Exception e)
            {
                message = e.Message.ToString();
                return Json("Error|" + message, JsonRequestBehavior.AllowGet);
            }

            return Json(message, JsonRequestBehavior.AllowGet);
        }
        #endregion

    }
}