using System;
using System.Collections.Generic;

namespace GPS.ViewModels.PO
{
    public class POItemAdoptViewModel
    {
        public IEnumerable<PRItemAdoptViewModel> PRItemAdoptList { get; set; }
        public String ProcessId { get; set; }
        public String PONo { get; set; }
        public String Currency { get; set; }
    }
}