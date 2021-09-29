using System;

namespace GPS.Models.Master
{
    public class Currency
    {
        public String CURR_CD { get; set; }
        public Decimal EXCHANGE_RATE { get; set; }
        public DateTime VALID_DT_FROM { get; set; }
        public DateTime VALID_DT_TO { get; set; }
    }
}