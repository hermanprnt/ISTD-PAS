using System;
using GPS.Models.Common;

namespace GPS.Models
{
    public class CommonUploadRepository
    {
        private CommonUploadRepository() { }
        private static CommonUploadRepository instance = null;
        public static CommonUploadRepository Instance
        {
            get { return instance ?? (instance = new CommonUploadRepository()); }
        }

        public UploadValidationInfo GetDataUploadValidationInfo()
        {
            String extSystemValue = SystemRepository.Instance.GetUploadDataFileExtension();
            String sizeSystemValue = SystemRepository.Instance.GetUploadFileSizeLimit();

            return new UploadValidationInfo
            {
                AllowedExtensions = extSystemValue.ToLowerInvariant().Split(','),
                AllowedFileSize = Convert.ToInt32(sizeSystemValue)
            };
        }

        public UploadValidationInfo GetDocumentUploadValidationInfo()
        {
            String extSystemValue = SystemRepository.Instance.GetUploadDocumentFileExtension();
            String sizeSystemValue = SystemRepository.Instance.GetUploadFileSizeLimit();

            return new UploadValidationInfo
            {
                AllowedExtensions = extSystemValue.ToLowerInvariant().Split(','),
                AllowedFileSize = Convert.ToInt32(sizeSystemValue)
            };
        }
    }
}