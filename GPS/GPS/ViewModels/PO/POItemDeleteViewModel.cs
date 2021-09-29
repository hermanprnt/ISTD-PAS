using System;
using GPS.Models.Common;

namespace GPS.ViewModels.PO
{
    public class POItemDeleteViewModel : ExecProcedureModel
    {
        public String PONo { get; set; }
        public Int32 POItemNo { get; set; }
        public Int32 SeqItemNo { get; set; }
    }
}