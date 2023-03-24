using System;
using GPS.Models.PO;

namespace GPS.ViewModels.PO
{
    public class POItemConditionViewModel : GenericViewModel<POItemCondition>
    {
        public String PONo { get; set; }
        public String POItemNo { get; set; }
        public String SeqItemNo { get; set; }
        public String ValuationClass { get; set; }
        public Decimal Qty { get; set; }
    }
}