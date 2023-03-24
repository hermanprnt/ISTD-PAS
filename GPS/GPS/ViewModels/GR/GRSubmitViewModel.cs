using System;
using System.Collections.Generic;
using GPS.CommonFunc;

namespace GPS.ViewModels.GR
{
    public class GRSubmitViewModel
    {
        public String ProcessId { get; set; }
        public IEnumerable<GRItemViewModel> GRList { get; set; }
        public String PostingDateString
        {
            get { return PostingDate == null ? String.Empty : PostingDate.Value.ToStandardFormat(); }
            set { PostingDate = String.IsNullOrEmpty(value) ? (DateTime?)null : value.FromStandardFormat(); }
        }
        public DateTime? PostingDate { get; set; }
        public String ShortText { get; set; }
    }
}