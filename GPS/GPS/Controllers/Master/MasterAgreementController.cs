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

namespace GPS.Controllers.Master
{
    public class MasterAgreementController : PageController
    {
        #region List Of Controller Method
        public sealed class Action
        {
            

        }
        #endregion

        public MasterAgreementController()
        {
            Settings.Title = "Master Agreement No Screen";
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
            ViewData["edit"] = flag;
            ViewData["MasterAgreementData"] = flag == "0"
                ? new MasterAgreement()
                : MasterAgreementRepository.Instance.GetSelectedData(VendorCode);

            return PartialView("_AddEditPopUp");
        }

        private void Calldata(int Display, int Page, string VendorCode, string VendorName, string AgreementNo, string Status)
        {
            Paging pg = new Paging(MasterAgreementRepository.Instance.CountData(VendorCode, VendorName, AgreementNo, Status), Page, Display);
            ViewData["Paging"] = pg;
            ViewData["ListMasterAgreement"] = MasterAgreementRepository.Instance.GetListData(VendorCode, VendorName, AgreementNo, Status, pg.StartData, pg.EndData);
        }

        [HttpPost]
        public ActionResult SearchData(int Display, int Page, string VendorCode, string VendorName, string AgreementNo, string Status)
        {
            Calldata(Display, Page, VendorCode, VendorName, AgreementNo, Status);
            return PartialView("_Grid");
        }

        /// <summary>
        /// INSERT DATA TO TB_M_AGREEMENT_NO
        /// </summary>
        public ActionResult SaveData(String flag, String vendorcd, String vendornm, String purchasinggrp, String buyer, String agreementno, String startdate, String expdate,String status,String nextaction)
        {
            startdate = conversiDate(startdate);
            expdate = conversiDate(expdate);
            //String message = "";
            String message = MasterAgreementRepository.Instance.SaveData(flag, vendorcd, vendornm, purchasinggrp, buyer, agreementno, startdate, expdate,status,nextaction, this.GetCurrentUsername());

            return new JsonResult { Data = new { message } };
        }

        public ActionResult DeleteData(String key)
        {
            string message = "";

            try
            {
                message = MasterAgreementRepository.Instance.DeleteData(key, this.GetCurrentUsername());
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
            return MasterAgreementRepository.Instance
                .GetSTSAgreement()
                .AsSelectList(div => div.SYSTEM_CD + " - " + div.SYSTEM_VALUE,
                    div => div.SYSTEM_CD);
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
