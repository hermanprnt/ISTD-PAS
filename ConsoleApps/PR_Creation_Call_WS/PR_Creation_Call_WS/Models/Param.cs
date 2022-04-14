using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace PR_Creation_Call_WS.Models
{
    class MessageModel
    {
        public string MsgId { get; set; }
        public string MsgText { get; set; }
        public string MsgType { get; set; }
    }

    class SystemMasterModel
    {
        public string SystemValue { get; set; }
    }

    [System.Xml.Serialization.XmlRoot("ns0:MaintainFundCommitReq_MT")]
    public class MaintainFundCommitReq_MT
    {
        public PAS_Document REQUEST { get; set; }
    }
    public class PAS_Document
    {
        public PAS_Header document { get; set; }
    }
    public class PAS_Header
    {
        public string doc_type { get; set; }
        public string action { get; set; }
        public string system { get; set; }
        public string test_run { get; set; }
        public string doc_no { get; set; }
        public string closed { get; set; }
        public string doc_date { get; set; }
        public string submit_date { get; set; }
        public string requestor { get; set; }
        public string company_code { get; set; }
        public string currency { get; set; }
        public string currency_rate { get; set; }
        [XmlElement("item")]
        public List<item> item { get; set; }
    }
    public class item
    {
        [XmlIgnore]
        public string doc_type { get; set; }
        [XmlIgnore]
        public string action { get; set; }
        [XmlIgnore]
        public string system { get; set; }
        [XmlIgnore]
        public string test_run { get; set; }
        [XmlIgnore]
        public string doc_no { get; set; }
        [XmlIgnore]
        public string closed { get; set; }
        [XmlIgnore]
        public string doc_date { get; set; }
        [XmlIgnore]
        public string submit_date { get; set; }
        [XmlIgnore]
        public string requestor { get; set; }
        [XmlIgnore]
        public string company_code { get; set; }
        [XmlIgnore]
        public string currency { get; set; }
        [XmlIgnore]
        public string currency_rate { get; set; }

        public string line_no { get; set; }
        public string closed2 { get; set; }
        public string ref_doc_no { get; set; }
        public string ref_doc_line_item_no { get; set; }
        public string item_code { get; set; }
        public string item_description { get; set; }
        public string part_category { get; set; }
        public string inventory_type { get; set; }
        public string material_type { get; set; }
        public string supplier_code { get; set; }
        public string asset { get; set; }
        public string wbs_element { get; set; }
        public string cost_center_charger { get; set; }
        public string total_amount { get; set; }
        public string quantity { get; set; }
        public string uom { get; set; }
        public string journal_source { get; set; }
        public string gl_account { get; set; }

        [XmlIgnore]
        public string retXML { get; set; }
    }

    public class document
    {
        public string doc_no { get; set; }
        public string doc_line_item_no { get; set; }
        public string fund_cmmt_doc { get; set; }
        public string fund_cmmt_doc_line_item { get; set; }
        public string msg_type { get; set; }
        public string msg_id { get; set; }
        public string msg_no { get; set; }
        public string msg { get; set; }
    }
    public class MaintainFundCommitResp_MT
    {
        public RESPONSE RESPONSE { get; set; }
    }
    [System.Xml.Serialization.XmlRoot("MaintainFundCommitResp_MT")]
    public class RESPONSE
    {
        public List<document> document { get; set; }
    }

    class FCResponse
    {
        public string PROCESS_ID { get; set; }
        public string ROW_NO { get; set; }
        public string DOCUMENT_NO { get; set; }
        public string DOCUMENT_LINE_ITEM_NO { get; set; }
        public string FUND_DOCUMENT_DOC_NO { get; set; }
        public string FUND_DOCUMENT_DOC_LINE_ITEM { get; set; }
        public string MESSAGE_TYPE { get; set; }
        public string MESSAGE_ID { get; set; }
        public string MESSAGE_NO { get; set; }
        public string MESSAGE_MESSAGE { get; set; }
        public string PROCESSED_BY { get; set; }
        public string PROCESSED_DT { get; set; }
    }

    public class Lookby
    {
        public string ProcessId { get; set; }
        public string Action { get; set; }
        public string Priority { get; set; }
        public string Variable { get; set; }
    }
}
