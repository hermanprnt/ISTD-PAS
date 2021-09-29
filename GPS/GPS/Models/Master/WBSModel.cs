using System;
using System.Collections.Generic;

namespace GPS.Models.Master
{
    public class WBSModel
    {
        public WBS param { get; set; }
        public IEnumerable<WBS> data { get; set; }

        private WBSModel()
        {
            param = new WBS();
            data = new List<WBS>();
        }
    }

    public class WBS
    {
        public Int32 DataNo { get; set; }
        public String WBS_NO { get; set; }
        public String WBS_NAME { get; set; }
    }
}