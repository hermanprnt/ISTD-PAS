using System;

namespace GPS.ViewModels
{
    public class SearchViewModel
    {
        public String DateFrom { get; set; }
        public String DateTo { get; set; }
        public String OrderBy { get; set; }
        public Int32 CurrentPage { get; set; }
        public Int32 PageSize { get; set; }
    }
}