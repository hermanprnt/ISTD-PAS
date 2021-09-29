using System;
using System.Collections.Generic;

namespace GPS.Models.Master
{
    public class StatusModel
    {
        public Status param { get; set; }
        public IEnumerable<Status> data { get; set; }

        private StatusModel()
        {
            param = new Status();
            data = new List<Status>();
        }
    }

    public class Status
    {
        public String STATUS_CD { get; set; }
        public String STATUS_DESC { get; set; }
    }
}