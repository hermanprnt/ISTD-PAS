using System;

namespace GPS.Constants
{
    public sealed class CommonDisplayMessage
    {
        public const String NoData = "No Data to Display";
        public const String DateTimePlaceholder = "dd.mm.yyyy";
        public const String DateRangePlaceholder = "dd.mm.yyyy - dd.mm.yyyy";
        public const String FileExtNotAllowed = "Sorry, file with type <strong>{0}</strong> is not allowed, allowed extensions are: {1}."; // TODO: moved from PR message
        public const String FileSizeNotAllowed = "Sorry, file <strong>{0}</strong> size (<strong>{1} MB</strong>) is reaching limit, {2} filesize for <strong>{3}</strong> are: <strong>{4} MB</strong>"; // TODO: moved from PR message
    }
}