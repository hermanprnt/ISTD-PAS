using GPS.CommonFunc;
using GPS.Models;
using GPS.Models.Common;
using GPS.Models.PR;
using System;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.Mvc;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.PR
{
    public class WallAnnouncementController : PageController
    {
        public const String _WallAnnouncementController = "/WallAnnouncement/";
        public const String _LookupRecipientSupplier = _WallAnnouncementController + "LookupRecipientSupplier";
        public const String _LookupRecipientNonSupplier = _WallAnnouncementController + "LookupRecipientNonSupplier";
        public const String _SubmitData = _WallAnnouncementController + "SubmitData";

        protected override void Startup()
        {
            Settings.Title = "Wall Announcement";
        }

        public ActionResult LookupRecipientSupplier()
        {
            try
            {
                var listData = WallAnnouncementRepository.Instance.GetLookupRecipientSupplier();
                return new JsonResult() { Data = new { ResultType = "S", Content = listData }, JsonRequestBehavior = JsonRequestBehavior.AllowGet };
            }
            catch (Exception ex)
            {
                return new JsonResult() { Data = new { ResultType = "E", Content = "Error:" + ex.Message }, JsonRequestBehavior = JsonRequestBehavior.AllowGet };
            }
        }

        [HttpPost]
        public ActionResult SubmitData(string Rec_Supplier, String Rec_NonSupplier,  String ValidFrom, String ValidTo, String Contents, HttpPostedFileBase[] files)
        {
            var DOC_TYPE = "ATTCH";
            List<FileContentType> fileAttachment = new List<FileContentType>();
            string mainpath = SystemRepository.Instance.GetSystemValue("UPLOAD_FILE_PATH");
            string fullpath = mainpath + SystemRepository.Instance.GetSystemValue("WALL_ANNOUNCEMENT_PATH");

            try
            {
                
                DateTime dtmValidFrom = ConvertToDate(ValidFrom);
                DateTime dtmValidTo = ConvertToDate(ValidTo);

                if(!Directory.Exists(fullpath))
                {
                    Directory.CreateDirectory(fullpath);
                }

                if(files==null)
                {
                    files = new HttpPostedFileBase[] { };
                }
                foreach (var file in files)
                {
                    string filename = DOC_TYPE + "_" + DateTime.Now.ToString("ddMMyyyyHHmmssffff") + Path.GetExtension(file.FileName);

                    var newpath = fullpath + filename;
                    fileAttachment.Add(new FileContentType() { FILE_NAME = filename, ORI_FILE_NAME = file.FileName, FILE_EXTENTION = Path.GetExtension(file.FileName), FILE_SIZE = file.ContentLength });

                    file.SaveAs(newpath);
                }

                WallAnnouncementRepository.Instance.SubmitRecipient(Rec_Supplier, Rec_NonSupplier, dtmValidFrom, dtmValidTo, Contents, fileAttachment, this.GetCurrentUsername(), this.GetCurrentRegistrationNumber());

                return new JsonResult() { Data = new { ResultType = "S", Content = "" }, JsonRequestBehavior = JsonRequestBehavior.AllowGet };
            }
            catch (Exception ex)
            {
                foreach(var file in fileAttachment)
                {
                    FileInfo fi = new FileInfo(fullpath + file.FILE_NAME);
                    if(fi.Exists)
                    {
                        fi.Delete();
                    }
                }
                return new JsonResult() { Data = new { ResultType = "E", Content = "Error:" + ex.Message }, JsonRequestBehavior = JsonRequestBehavior.AllowGet };
            }
        }

        private DateTime ConvertToDate(string dateTime)
        {
            if (dateTime.Length>0)
            {
                string[] datePart = dateTime.Split('.');
                int year = Int32.Parse(datePart[2]);
                int month = Int32.Parse(datePart[1]);
                int day = Int32.Parse(datePart[0]);
                return new DateTime(year, month, day);
            }

            return new DateTime(1900,01,01);
        }

        public ActionResult LookupRecipientNonSupplier()
        {
            try
            {
                var listData = WallAnnouncementRepository.Instance.GetLookupRecipientNonSupplier();
                return new JsonResult() { Data = new { ResultType = "S", Content = listData }, JsonRequestBehavior = JsonRequestBehavior.AllowGet };
            }
            catch (Exception ex)
            {
                return new JsonResult() { Data = new { ResultType = "E", Content = "Error:" + ex.Message }, JsonRequestBehavior = JsonRequestBehavior.AllowGet };
            }
        }
    }
}