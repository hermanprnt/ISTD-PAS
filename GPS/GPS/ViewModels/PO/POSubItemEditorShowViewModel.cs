using System;

namespace GPS.ViewModels.PO
{
    public class POSubItemEditorShowViewModel
    {
        public String ProcessId { get; set; }
        /*public String PRNo { get; set; }
        public String PRItemNo { get; set; }
        public String PRSubItemNo { get; set; }*/
        public String PONo { get; set; }
        public Int32 POItemNo { get; set; }
        public Int32 SeqItemNo { get; set; }
        public Int32 DataNo { get; set; }
        public String DataName { get; set; } 
    }
}