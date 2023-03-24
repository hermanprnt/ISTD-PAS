using System;
using System.Collections.Generic;

namespace GPS.Models.Master
{
    public class DivisionModel
    {
        public Division param { get; set; }
        public IEnumerable<Division> data { get; set; }

        private DivisionModel()
        {
            param = new Division();
            data = new List<Division>();
        }
    }

    public class Division
    {
        public String Division_ID { get; set; }
        public String Division_NAME { get; set; }
    }

    public class EmployeeModel
    {
        public string NO_REG { get; set; }
    }
}