using System;

namespace BudgetDataImporter
{
    public class Schedule
    {
        public String SystemType { get; set; }
        public String SystemCode { get; set; }
        public DateTime Datetime { get; set; }
        public Int32 Span { get; set; }
    }
}