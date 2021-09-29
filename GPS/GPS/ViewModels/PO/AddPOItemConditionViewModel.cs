﻿using System;

namespace GPS.ViewModels.PO
{
    public class AddPOItemConditionViewModel
    {
        public String PONo { get; set; }
        public String POItemNo { get; set; }
        public String SeqItemNo { get; set; }
        public Int32 SeqNo { get; set; }
        public String CompPriceCode { get; set; }
        public String ConditionType { get; set; }
        public Decimal CompPriceRate { get; set; }
        public Decimal ExchangeRate { get; set; }
        public String Currency { get; set; }
        public Int32 QtyPerUOM { get; set; }
        public Decimal Qty { get; set; }
    }
}