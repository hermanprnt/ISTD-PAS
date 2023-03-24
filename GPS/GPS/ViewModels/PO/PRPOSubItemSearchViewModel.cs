using System;

namespace GPS.ViewModels.PO
{
    public class PRPOSubItemSearchViewModel : SearchViewModel
    {
        public String ProcessId { get; set; }
        public String PRNo { get; set; }
        public String PRItemNo { get; set; }
        public String PRSubItemNo { get; set; }
        public String PONo { get; set; }
        public String POItemNo { get; set; }
        public String SeqItemNo { get; set; }
        public String DataName { get; set; }

        public String ActionOrigin { get; set; }        //added : 20190722 : isid.rgl
    }
}