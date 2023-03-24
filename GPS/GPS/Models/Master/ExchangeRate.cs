using System;
using System.Collections.Generic;

namespace GPS.Models.Master
{
    public class ExchangeRateModel
    {
        public ExchangeRate param { get; set; }
        public IEnumerable<ExchangeRate> data { get; set; }

        private ExchangeRateModel()
        {
            param = new ExchangeRate();
            data = new List<ExchangeRate>();
        }
    }

    public class ExchangeRate
    {
        public int Number { get; set; }
        public String CURR_CD { get; set; }
        public String EXCHANGE_RATE { get; set; }
        public String VALID_DT_FROM { get; set; }
        public String VALID_DT_TO { get; set; }
        public String FOREX_TYPE { get; set; }
        public String RELEASED_FLAG { get; set; }
        public String DECIMAL_FORMAT { get; set; }

        public String CREATED_BY { get; set; }
        public String CREATED_DT { get; set; }
        public String CHANGED_BY { get; set; }
        public String CHANGED_DT { get; set; }
    }
}