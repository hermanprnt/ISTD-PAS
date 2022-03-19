using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Xml.Serialization;

namespace NETFrameworkDummyWS.Models
{
    [XmlRoot("ns0:MaintainFundCommitResp_MT", Namespace = "http://www.cpandl.com",IsNullable = true)]
    public class MaintainFundCommitResp_MT
    {
        public List<document> RESPONSE { get; set; }
    }
    public class document
    {
        public string H2 { get; set; }
        public string H3 { get; set; }
        public string doc_no { get; set; }
        public string doc_line_item_no { get; set; }
        public string fund_cmmt_doc { get; set; }
        public string fund_cmmt_doc_line_item { get; set; }
        public string msg_type { get; set; }
        public string msg_id { get; set; }
        public string msg_no { get; set; }
        public string msg { get; set; }
    }
}