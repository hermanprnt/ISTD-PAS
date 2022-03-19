using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace FCManagementTools.Models
{
    class MessageModel
    {
        public string MsgId { get; set; }
        public string MsgText { get; set; }
        public string MsgType { get; set; }
    }
    public class DataRequest
    {
        public string H1 { get; set; }
        public string H2 { get; set; }
        public string H3 { get; set; }
        public string PROCESS_ID { get; set; }
        public string HEADER_NO { get; set; }
        public string DOCUMENT_TYPE { get; set; }
        public string ACTION { get; set; }
        public string SYSTEM { get; set; }
        public string TEST_RUN { get; set; }
        public string DOCUMENT_NO { get; set; }
        public string CLOSED { get; set; }
        public string DOCUMENT_DT { get; set; }
        public string SUBMIT_DT { get; set; }
        public string REQUESTOR { get; set; }
        public string COMPANY_CD { get; set; }
        public string CURRENCY { get; set; }
        public string CURRENCY_RATE { get; set; }
        public string LINE_NO { get; set; }
        public string CLOSED2 { get; set; }
        public string REFERENCE_NO { get; set; }
        public string REFERENCE_LINE_NO { get; set; }
        public string ITEM_CD { get; set; }
        public string ITEM_DESCRIPTION { get; set; }
        public string PART_CATEGORY { get; set; }
        public string INVENTORY_TYPE { get; set; }
        public string MATERIAL_TYPE { get; set; }
        public string SUPPLIER_CD { get; set; }
        public string ASSET_NO { get; set; }
        public string WBS_ELEMENT { get; set; }
        public string COST_CENTER_CD { get; set; }
        public string TOTAL_AMOUNT { get; set; }
        public string QUANTITY { get; set; }
        public string UOM { get; set; }
        public string JOURNAL_SOURCE { get; set; }
        public string GL_ACCOUNT { get; set; }
        public string PROCESSED_BY { get; set; }
        public string PROCESSED_DT { get; set; }
        public string FLAG { get; set; }
    }
    public class DataHeader
    {
        public string PROCESS_ID { get; set; }
        public string HEADER_NO { get; set; }
        public string DOCUMENT_TYPE { get; set; }
        public string ACTION { get; set; }
        public string SYSTEM { get; set; }
        public string TEST_RUN { get; set; }
        public string DOCUMENT_NO { get; set; }
        public string CLOSED { get; set; }
        public string DOCUMENT_DT { get; set; }
        public string SUBMIT_DT { get; set; }
        public string REQUESTOR { get; set; }
        public string COMPANY_CD { get; set; }
        public string CURRENCY { get; set; }
        public string CURRENCY_RATE { get; set; }
        public string FLAG { get; set; }
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
        [XmlElement(ElementName = "doc_no", Namespace = "")]
        public string doc_no { get; set; }
        [XmlElement(ElementName = "doc_line_item_no", Namespace = "")]
        public string doc_line_item_no { get; set; }
        [XmlElement(ElementName = "fund_cmmt_doc", Namespace = "")]
        public string fund_cmmt_doc { get; set; }
        [XmlElement(ElementName = "fund_cmmt_doc_line_item", Namespace = "")]
        public string fund_cmmt_doc_line_item { get; set; }
        [XmlElement(ElementName = "msg_type", Namespace = "")]
        public string msg_type { get; set; }
        [XmlElement(ElementName = "msg_id", Namespace = "")]
        public string msg_id { get; set; }
        [XmlElement(ElementName = "msg_no", Namespace = "")]
        public string msg_no { get; set; }
        [XmlElement(ElementName = "msg", Namespace = "")]
        public string msg { get; set; }
    }
    [XmlRoot(ElementName = "MaintainFundCommitResp_MT", Namespace = "http://toyota.com/th/projectsystem/fund")]
    public class MaintainFundCommitResp_MT
    {
        [XmlElement(ElementName = "RESPONSE", Namespace = "")]
        public RESPONSE RESPONSE { get; set; }
    }
    [XmlRoot]
    public class RESPONSE
    {
        [XmlElement(ElementName = "document", Namespace = "")]
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
