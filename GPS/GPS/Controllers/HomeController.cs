using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Constants;
using GPS.Models.Common;
using GPS.Models.PRPOApproval;
using GPS.Models.PR.Common;
using Toyota.Common.Web.Platform;
using System.Linq;
using System;
using System.IO;

namespace GPS.Controllers
{
    public class HomeController : PageController
    {
        public HomeController()
        {
            Settings.Title = "Home";
        }

        protected override void Startup()
        {
            Settings.Title = "Home";

            BindHomeNotification();
            BindHomeWorklist();
            BindHomeNotice(this.GetCurrentRegistrationNumber());
            BindHomeTracking(this.GetCurrentRegistrationNumber());
            BindAllDelayedApproval(this.GetCurrentRegistrationNumber());
        }

        #region Bind Methods
        public PartialViewResult GetHomeAnnouncement()
        {
            // Bind data.
            ViewData["HomeAnnouncement"] = AnnouncementRepository.Instance.GetAllData(this.GetCurrentRegistrationNumber());

            return PartialView(CommonPage.HomeAnnouncement);
        }

        private void BindHomeAnnouncement()
        {
            // Bind data.
            ViewData["HomeAnnouncement"] = AnnouncementRepository.Instance.GetAllData(this.GetCurrentRegistrationNumber());
        }

        private void BindHomeNotification()
        {
            // Bind data.
            ViewData["HomeNotification"] = NotificationRepository.Instance.GetNotificationList(this.GetCurrentRegistrationNumber());
        }

        public PartialViewResult GetHomeWorklist()
        {
            // Bind data.
            ViewData["HomeWorklist"] = CommonApprovalRepository.Instance.GetDelayedApproval(this.GetCurrentRegistrationNumber());
            
            return PartialView(CommonPage.HomeWorklist);
        }
        
        private void BindHomeWorklist()
        {
            // Bind data.
            ViewData["HomeWorklist"] = CommonApprovalRepository.Instance.GetDelayedApproval(this.GetCurrentRegistrationNumber());
        }

        public PartialViewResult GetHomeNotice()
        {
            // Bind data.
            string noreg = this.GetCurrentRegistrationNumber();
            ViewData["HomeNotice"] = CommonApprovalRepository.Instance.GetNoticeUnseenList(noreg);

            return PartialView(CommonPage.HomeNotice);
        }

        private void BindHomeNotice(string noreg)
        {
            // Bind data.
            ViewData["HomeNotice"] = CommonApprovalRepository.Instance.GetNoticeUnseenList(noreg);
        }

        public PartialViewResult GetHomeTracking()
        {
            // Bind data.
            string noreg = this.GetCurrentRegistrationNumber();
            ViewData["HomeTracking"] = PRCommonRepository.Instance.GetHomeTracking(noreg);

            return PartialView(CommonPage.HomeNotice);
        }

        public void NotifDownloadAttachment(string file, string DocNo)
        {
            try
            {
                string mainpath = SystemRepository.Instance.GetSystemValue("UPLOAD_FILE_PATH");
                string fullpath = mainpath + SystemRepository.Instance.GetSystemValue("WALL_ANNOUNCEMENT_PATH");

                var attachmentList = AttachmentRepository.Instance.GetAllData(DocNo).ToList();
                var fileData = attachmentList.FirstOrDefault(x => x.FILE_PATH == file);
                var fileName = "";
                if(fileData != null)
                {
                    fileName = fileData.FILE_NAME_ORI;
                }else if(!(new FileInfo(fullpath + file).Exists))
                {
                    throw new Exception("File not found!");
                }

                Response.Clear();
                Response.ContentType = GetMimeType(file);
                Response.AppendHeader("content-disposition", "attachment; filename=\"" + fileName + "\"");
                Response.TransmitFile(fullpath + file);
                Response.End();
            }
            catch(Exception ex)
            {
                var errorFile = PdfFileCreator.GenerateErrorInfoTextFile(ex);
                Response.BinaryWrite(errorFile.FileByteArray);
                Response.ContentType = errorFile.MimeType;
                Response.AddHeader("content-disposition", String.Format("attachment;filename=\"{0}\"", errorFile.Filename));
                Response.AddHeader("Set-Cookie", "fileDownload=true; path=/");
                Response.Flush();
                Response.End();
            }
        }

        private void BindHomeTracking(string noreg)
        {
            // Bind data.
            ViewData["HomeTracking"] = PRCommonRepository.Instance.GetHomeTracking(noreg);
        }

        private void BindAllDelayedApproval(string noreg)
        {
            // Bind data.
            ViewData["HomeAllDelayedApproval"] = CommonApprovalRepository.Instance.GetAllDelayedApproval(this.GetCurrentRegistrationNumber());
        }

        private string GetMimeType(string fileName)
        {
            string mimeType = "application/unknown";
            string ext = System.IO.Path.GetExtension(fileName).ToLower();
            Microsoft.Win32.RegistryKey regKey = Microsoft.Win32.Registry.ClassesRoot.OpenSubKey(ext);
            if (regKey != null && regKey.GetValue("Content Type") != null)
                mimeType = regKey.GetValue("Content Type").ToString();
            return mimeType;
        }
        #endregion
    }
}
