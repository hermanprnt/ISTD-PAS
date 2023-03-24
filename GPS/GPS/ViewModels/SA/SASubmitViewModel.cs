using System;
using System.Collections.Generic;
using GPS.CommonFunc;

namespace GPS.ViewModels.SA
{
    public class SASubmitViewModel
    {
        public String ProcessId { get; set; }
        public String SADocNo { get; set; }
        public IEnumerable<SAItemViewModel> SAList { get; set; }
        public String PostingDateString
        {
            get { return PostingDate == null ? String.Empty : PostingDate.Value.ToStandardFormat(); }
            set { PostingDate = String.IsNullOrEmpty(value) ? (DateTime?)null : value.FromStandardFormat(); }
        }
        public DateTime? PostingDate { get; set; }
        public String ShortText { get; set; }
    }
}