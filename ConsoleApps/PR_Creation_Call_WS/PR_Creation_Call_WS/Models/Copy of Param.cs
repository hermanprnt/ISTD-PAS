using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PR_Creation_Call_WS.Models
{
    class MessageModel
    {
        public string MsgId { get; set; }
        public string MsgText { get; set; }
        public string MsgType { get; set; }
    }

    class RequestH
    {
        public string DocumentNo { get; set; }
        public IList<RequestD> Item { get; set; }
    }

    class RequestD
    {
        public string DocumentType { get; set; }
        public string Action { get; set; }
        public string System { get; set; }
        public string TestRun { get; set; }
        public string DocumentNo { get; set; }
        public string Closed { get; set; }
        public string DocumentDate { get; set; }
        public string SubmitDate { get; set; }
        public string Requestor { get; set; }
        public string CompanyCode { get; set; }
        public string Currency { get; set; }
        public string CurrencyRate { get; set; }
        public string LineNo { get; set; }
        public string ReferenceDocumentNo { get; set; }
        public string ReferenceDocumentLineItemNo { get; set; }
        public string ItemCode { get; set; }
        public string ItemDescription { get; set; }
        public string PartCategory { get; set; }
        public string InventoryType { get; set; }
        public string MaterialType { get; set; }
        public string SupplierCode { get; set; }
        public string Asset { get; set; }
        public string WBSElement { get; set; }
        public string CostCenter { get; set; }
        public string TotalAmount { get; set; }
        public string Quantity { get; set; }
        public string UOM { get; set; }

        [JsonIgnore]
        public string requestNoDet { get; set; }
    }

    class ResponseH
    {
        public string DocNo { get; set; }
        public IList<ResponseD> Item { get; set; }
    }

    class ResponseD
    {
        public string DocNo { get; set; }
        public string DocLineItemNo { get; set; }
        public string FundCmntDoc { get; set; }
        public string FundCmntDocLineItem { get; set; }
        public string status { get; set; }
        public string message { get; set; }
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
}
