using NETFrameworkDummyWS.App_Start;
using NETFrameworkDummyWS.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Web.Configuration;
using System.Web.Http;
using System.Xml;
using System.Xml.Linq;
using System.Xml.Serialization;

namespace NETFrameworkDummyWS.Controllers
{

    public class FCPASPOController : ApiController
    {
        //[Authorize]
        [BasicAuthentication]
        // POST api/values
        public XElement Postdoc([FromBody] XmlElement value)
        {
            var context = new DbContext(ConfigurationManager.ConnectionStrings["FAMSWSConnection"].ConnectionString);
            var serializer = new XmlSerializer(typeof(REQUEST));
            REQUEST result;
            using (TextReader reader = new StringReader(value.InnerXml))//value.OuterXml
            {
                result = (REQUEST)serializer.Deserialize(reader);
            }
            List<document> response = new List<document>();
            MaintainFundCommitResp_MT RESULTS = new MaintainFundCommitResp_MT();
            int hit = 0;
            foreach (var item in result.doc.itm)
            {
                document data = new document();
                string sql = @"select 'RESPONSE' as H2,'document' as H3, ISNULL(DOCUMENT_LINE_ITEM_NO, '') doc_line_item_no,
                                ISNULL(FUND_DOCUMENT_DOC_NO, '') fund_cmmt_doc,
                                ISNULL(FUND_DOCUMENT_DOC_LINE_ITEM, '') fund_cmmt_doc_line_item,
                                ISNULL(MSG,'') AS msg,
								ISNULL(MSG_ID,'') AS msg_id,
								ISNULL(MSG_NO,'') AS msg_no,
								ISNULL(MSG_TYPE,'') AS msg_type
                                From TB_T_FC_RESPONSE WHERE DOCUMENT_NO='" + result.doc.doc_no + "' AND DOCUMENT_LINE_ITEM_NO='" + result.doc.itm[hit].line_no + "'";
                data = context.Database.SqlQuery<document>(sql).OrderByDescending(x => x.fund_cmmt_doc_line_item).FirstOrDefault();
                if (data != null)
                {

                    response.Add(new document()
                    {
                        H2 = data.H2,
                        H3 = data.H3,
                        doc_no = result.doc.doc_no,
                        doc_line_item_no = result.doc.itm[hit].line_no,
                        fund_cmmt_doc = data.fund_cmmt_doc,
                        fund_cmmt_doc_line_item = data.fund_cmmt_doc_line_item,
                        msg_type = data.msg_type,
                        msg_id = data.msg_id,
                        msg_no = data.msg_no,
                        msg = data.msg
                    }); ;
                }
                hit++;
            }

            string XE_doc_no = WebConfigurationManager.AppSettings["doc_no"];
            string XE_doc_line_item_no = WebConfigurationManager.AppSettings["doc_line_item_no"];
            string XE_fund_cmmt_doc = WebConfigurationManager.AppSettings["fund_cmmt_doc"];
            string XE_fund_cmmt_doc_line_item = WebConfigurationManager.AppSettings["fund_cmmt_doc_line_item"];
            string XE_msg_type = WebConfigurationManager.AppSettings["msg_type"];
            string XE_msg_id = WebConfigurationManager.AppSettings["msg_id"];
            string XE_msg_no = WebConfigurationManager.AppSettings["msg_no"];
            string XE_msg = WebConfigurationManager.AppSettings["msg"];

            string xmlns = WebConfigurationManager.AppSettings["WSNamespace"];
            string prefix = WebConfigurationManager.AppSettings["WSPrefix"];
            XNamespace aw = xmlns;
            XElement doc =
                new XElement(aw + "MaintainFundCommitResp_MT", new XAttribute(XNamespace.Xmlns + prefix, xmlns),
                new XElement(response.FirstOrDefault().H2,
                (
                        from items in response
                        select new XElement(response.FirstOrDefault().H3,
                            new XElement(XE_doc_no, items.doc_no),
                            new XElement(XE_doc_line_item_no, items.doc_line_item_no),
                            new XElement(XE_fund_cmmt_doc, items.fund_cmmt_doc),
                            new XElement(XE_fund_cmmt_doc_line_item, items.fund_cmmt_doc_line_item),
                            new XElement(XE_msg_type, items.msg_type),
                            new XElement(XE_msg_id, items.msg_id),
                            new XElement(XE_msg_no, items.msg_no),
                            new XElement(XE_msg, items.msg)))));
            
            return doc;
        }
    }
}
