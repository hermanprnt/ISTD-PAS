using System;

namespace GPS.ViewModels.PO
{
    public class UrgentSPKSearchViewModel : SearchViewModel
    {
        public String PRNo { get; set; }
        public String PRStatus { get; set; }
        public String SPKNo { get; set; }
        public String SPKDateFrom { get; set; }
        public String SPKDateTo { get; set; }
    }
}