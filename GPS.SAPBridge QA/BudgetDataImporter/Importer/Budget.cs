using System;
using System.Collections.Generic;
using System.Linq;

namespace BudgetDataImporter
{
    class Budget
    {
        public String WBS_NO { get; set; }
        public String ORIGINAL_WBS_NO { get; set; }
        public String WBS_YEAR { get; set; }
        public String CURRENCY { get; set; }
        public Double INITIAL_AMOUNT { get; set; }
        public Double INITIAL_RATE { get; set; }
        public Double INITIAL_BUDGET { get; set; }
        public Double ADJUSTED_BUDGET { get; set; }
        public Double REMAINING_BUDGET_ACTUAL { get; set; }
        public Double REMAINING_BUDGET_INITIAL_RATE { get; set; }
        public Double BUDGET_CONSUME_GR_SA { get; set; }
        public Double BUDGET_CONSUME_INITIAL_RATE { get; set; }
        public Double BUDGET_COMMITMENT_PR_PO { get; set; }
        public Double BUDGET_COMMITMENT_INITIAL_RATE { get; set; }
    }
}
