using System;
using System.Collections.Generic;
using GPS.Core;
using GPS.Models.Common;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.PR
{
    public class WallAnnouncementRepository { 
        public sealed class SqlFile
        {
            public const String _Root_Folder_Status = "WallAnnouncement/";
            public const String _GetLookupRecipientSupplierList = _Root_Folder_Status + "GetLookupRecipientSupplier";
            public const String _GetLookupRecipientNonSupplierList = _Root_Folder_Status + "GetLookupRecipientNonSupplier";
            public const String _SubmitRecipient = _Root_Folder_Status + "SubmitRecipient";
        }

        private WallAnnouncementRepository() { }
        private static WallAnnouncementRepository instance = null;

        public static WallAnnouncementRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new WallAnnouncementRepository();
                }
                return instance;
            }
        }

        public List<NameValueItem> GetLookupRecipientSupplier()
        {
            IDBContext db = DatabaseManager.Instance.GetContext("SecurityCenter");
            List<NameValueItem> resultquery = new List<NameValueItem>();

            dynamic args = new
            {
            };
            resultquery = db.Fetch<NameValueItem>(SqlFile._GetLookupRecipientSupplierList, args);
            db.Close();

            return resultquery;
        }

        public List<NameValueItem> GetLookupRecipientNonSupplier()
        {
            IDBContext db = DatabaseManager.Instance.GetContext("SecurityCenter");
            List<NameValueItem> resultquery = new List<NameValueItem>();

            dynamic args = new
            {
            };
            resultquery = db.Fetch<NameValueItem>(SqlFile._GetLookupRecipientNonSupplierList, args);
            db.Close();

            return resultquery;
        }

        public string SubmitRecipient(string Rec_Supplier, String Rec_NonSupplier, DateTime ValidFrom, DateTime ValidTo, String Contents, List<FileContentType> files, string currentUser, string currentRegNo)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            var AttchList = ConvertToString(files);
            dynamic args = new
            {
                RecipientSupplierList = Rec_Supplier,
                RecipientNonSupplierList = Rec_NonSupplier,
                ValidFrom = ValidFrom,
                ValidTo = ValidTo,
                Description = Contents,
                CurrentUser = currentUser,
                CurrentRegNo = currentRegNo,
                AttachmentList = AttchList
            };
            String resultquery = db.SingleOrDefault<string>(SqlFile._SubmitRecipient, args);
            db.Close();

            var resultViewModel = resultquery.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == Core.ViewModel.ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultquery;
        }

        private string ConvertToString(List<FileContentType> files)
        {
            string result = "";

            foreach (var file in files)
            {
                result = result + file.FILE_NAME+";"+file.ORI_FILE_NAME+";"+file.FILE_EXTENTION+";"+file.FILE_SIZE.ToString()+"|";
            }

            return result;
        }
    }
}