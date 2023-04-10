using System;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Common;
using GPS.Models.Master;
using Toyota.Common.Web.Platform;
using System.Text.RegularExpressions;
using System.IO;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using System.Collections.Generic;
using GPS.Core.ViewModel;
using GPS.Core;

namespace GPS.Controllers.Master
{
    public class MasterDueDilligenceController : PageController
    {
        #region List Of Controller Method
        public sealed class Action
        {
            

        }
        #endregion

        public MasterDueDilligenceController()
        {
            Settings.Title = "Master Due Dilligence Screen";
        }

        protected override void Startup()
        {
            ViewData["FI_YEAR"] = SystemRepository.Instance.GetSystemValue("FI_YEAR");

            int DIVISION_ID = DivisionRepository.Instance.GetUserDivision(this.GetCurrentRegistrationNumber());
            TempData["DIVISION_ID"] = DIVISION_ID;
        }

        #region ark.herman 23/3/2023
        public ActionResult IsFlagEditAdd(String flag, String VendorCode)
        {
            ViewData["REG_NO"] = this.GetCurrentRegistrationNumber();
            ViewData["edit"] = flag;
            ViewData["MasterDueDilligenceData"] = flag == "0"
                ? new MasterDueDilligence()
                : MasterDueDilligenceRepository.Instance.GetSelectedData(VendorCode);

            return PartialView("_AddEditPopUp");
        }

        private void Calldata(int Display, int Page, string VendorCode, string VendorName, string AgreementNo, string Status)
        {
            Paging pg = new Paging(MasterDueDilligenceRepository.Instance.CountData(VendorCode, VendorName, AgreementNo, Status), Page, Display);
            ViewData["Paging"] = pg;
            ViewData["ListMasterDueDilligence"] = MasterDueDilligenceRepository.Instance.GetListData(VendorCode, VendorName, AgreementNo, Status, pg.StartData, pg.EndData);
        }

        [HttpPost]
        public ActionResult SearchData(int Display, int Page, string VendorCode, string VendorName, string AgreementNo, string Status)
        {
            Calldata(Display, Page, VendorCode, VendorName, AgreementNo, Status);
            return PartialView("_Grid");
        }
       

        public JsonResult GetVendorOnChange(string vendor)
        {
            return Json(MasterDueDilligenceRepository.Instance.GetVendorSelected(vendor));
        }

        /// <summary>
        /// INSERT DATA TO TB_M_AGREEMENT_NO
        /// </summary>
        [HttpPost]
        public ActionResult SaveData(String flag, String vendorcd, String vendornm, String status,String plan, String vldddfrom, String vldddto)
        {
            vldddfrom = conversiDate(vldddfrom);
            vldddto = conversiDate(vldddto);
            //String message = "";
            String message = MasterDueDilligenceRepository.Instance.SaveData(flag, vendorcd, vendornm, status, plan,vldddfrom, vldddto,this.GetCurrentUsername());

            return new JsonResult { Data = new { message } };
        }

        public ActionResult DeleteData(String key)
        {
            string message = "";

            try
            {
                message = MasterDueDilligenceRepository.Instance.DeleteData(key, this.GetCurrentUsername());
            }
            catch (Exception e)
            {
                message = e.Message.ToString();
                return Json("Error|" + message, JsonRequestBehavior.AllowGet);
            }

            return Json(message, JsonRequestBehavior.AllowGet);
        }


        public static SelectList GetStatusList()
        {
            return MasterDueDilligenceRepository.Instance
                .GetSTSDueDilligence()
                .AsSelectList(div => div.SYSTEM_CD + " - " + div.SYSTEM_VALUE,
                    div => div.SYSTEM_CD);
        }

        public static SelectList PlantSelectList()
        {
            return PlantRepository.Instance
                .GetPlantList()
                .AsSelectList(plant => plant.PLANT_CD + " - " + plant.PLANT_NAME, plant => plant.PLANT_CD);

        }

        protected string conversiDate(string tgl)
        {
            string result = "";
            string[] dt = null;

            if (tgl != "")
            {
                dt = tgl.Split('.');
                tgl = dt[2] + "-" + dt[1] + "-" + dt[0];

                result = tgl;
            }
            return result;
        }

        #endregion
    }
}
