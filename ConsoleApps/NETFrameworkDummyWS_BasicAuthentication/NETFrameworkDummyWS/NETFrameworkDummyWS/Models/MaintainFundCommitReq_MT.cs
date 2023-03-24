using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Xml.Serialization;

namespace NETFrameworkDummyWS.Models
{
    [Serializable()]
    [XmlRoot]
    public class MaintainFundCommitReq_MT
    {
        [XmlElementAttribute("MaintainFundCommitReq_MT")]
        public REQUEST REQUEST { get; set; }
    }
    public class REQUEST
    {
        [XmlElementAttribute("document")]
        public doc doc { get; set; }
    }
    public class doc
    {
        [XmlElementAttribute("doc_type")]
        public string doc_type { get; set; }

        [XmlElementAttribute("action")]
        public string action { get; set; }

        [XmlElementAttribute("system")]
        public string system { get; set; }
        [XmlElementAttribute("test_run")]
        public string test_run { get; set; }
        [XmlElementAttribute("doc_no")]
        public string doc_no { get; set; }
        [XmlElementAttribute("closed")]
        public string closed { get; set; }
        [XmlElementAttribute("doc_date")]
        public string doc_date { get; set; }
        [XmlElementAttribute("submit_date")]
        public string submit_date { get; set; }
        [XmlElementAttribute("requestor")]
        public string requestor { get; set; }
        [XmlElementAttribute("company_code")]
        public string company_code { get; set; }
        [XmlElementAttribute("currency")]
        public string currency { get; set; }
        [XmlElementAttribute("currency_rate")]
        public string currency_rate { get; set; }
        [XmlElementAttribute("item")]
        public List<item> itm { get; set; }
    }
    public class item
    {
        [XmlElementAttribute("line_no")]
        public string line_no { get; set; }

        [XmlElementAttribute("closed2")]
        public string closed2 { get; set; }

        [XmlElementAttribute("ref_doc_no")]
        public string ref_doc_no { get; set; }

        [XmlElementAttribute("ref_doc_line_item_no")]
        public string ref_doc_line_item_no { get; set; }

        [XmlElementAttribute("item_code")]
        public string item_code { get; set; }

        [XmlElementAttribute("item_description")]
        public string item_description { get; set; }

        [XmlElementAttribute("part_category")]
        public string part_category { get; set; }

        [XmlElementAttribute("inventory_type")]
        public string inventory_type { get; set; }

        [XmlElementAttribute("material_type")]
        public string material_type { get; set; }

        [XmlElementAttribute("supplier_code")]
        public string supplier_code { get; set; }

        [XmlElementAttribute("asset")]
        public string asset { get; set; }

        [XmlElementAttribute("wbs_element")]
        public string wbs_element { get; set; }

        [XmlElementAttribute("cost_center_charger")]
        public string cost_center_charger { get; set; }

        [XmlElementAttribute("total_amount")]
        public string total_amount { get; set; }

        [XmlElementAttribute("quantity")]
        public string quantity { get; set; }

        [XmlElementAttribute("uom")]
        public string uom { get; set; }

        [XmlElementAttribute("gl_account")]
        public string gl_account { get; set; }

        [XmlElementAttribute("journal_source")]
        public string journal_source { get; set; }
    }
}