using System;

namespace GPS.Models.Common
{
    public class UploadValidationInfo
    {
        public String[] AllowedExtensions { get; set; }
        public Int32 AllowedFileSize { get; set; }
    }
}