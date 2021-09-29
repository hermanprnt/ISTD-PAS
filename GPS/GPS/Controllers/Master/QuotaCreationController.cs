using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using GPS.CommonFunc;
using GPS.Models.Common;
using GPS.Models.Master;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.Master
{
    public class QuotaCreationController : PageController
    {
        public void GetQuotaNo(string Quota_No)
        {
            Session["QUOTANO"] = Quota_No;
        }

        protected override void Startup()
        {
            try
            {
                bool isexist = Session["QUOTANO"] != null;

                if (!isexist) Session["QUOTANO"] = 0;
                string param = Session["QUOTANO"].ToString();
                ViewData["GetHeader"] = QuotaRepository.Instance.GetSingleData(param);
                ViewData["QuotaListDetail"] = QuotaRepository.Instance.GetQuotaDetailList(param);
            }
            catch (Exception e)
            {
                e.ToString(); 
            }
        }

        public QuotaCreationController()
        {
            Settings.Title = "Quota Creation";
            //ViewData["ListDivision"] = QuotaRepository.Instance.GetListDivision();
        }

        public ContentResult getMaterialNo(string matno, string matdesc, string car, string type, string grp, string val, int pageSize = 1, int page = 1)
        {
            List<QuotaDetail> selectMatno = QuotaRepository.Instance.GetDataMatNumber(matno, matdesc, car, type, grp, val, (page * pageSize), (((page - 1) * pageSize) + 1)).ToList();
            var jsonserializer = new JavaScriptSerializer();
            var json = jsonserializer.Serialize(selectMatno);
            return Content(json);
        }

        //paging popup
        public ContentResult LookupPaging(string valcd, string valdesc, string matno, string matdesc, string car, string type, string grp,
                                          string glcd, string gldesc, string plant, int pageSize, string lookup, string val, string prno,
                                          string purchasing)
        {
            int count = 0;
            count = QuotaRepository.Instance.CountMatno(matno, matdesc, car, type, grp, val, purchasing);


            PagingModel PG = new PagingModel();
            List<int> index = new List<int>();

            PG.Length = count;
            PG.CountData = count;

            Double Total = Math.Ceiling((Double)count / (Double)pageSize);
            for (int i = 1; i <= Total; i++)
            {
                index.Add(i);
            }
            PG.IndexList = index;
            var jsonserializer = new JavaScriptSerializer();
            var json = jsonserializer.Serialize(PG);
            return Content(json);
        }

        //for save detail
        public string SaveDetail(string aQuotaNo, string aMonth, string aMatNo, string aMatDesc, decimal aQuota = 0, decimal aUsage = 0, decimal aAdditionalQuota = 0)
        {
            string message = "";
            try
            {
                QuotaDetail qd = new QuotaDetail();
                qd.QUOTA_NO = aQuotaNo;
                qd.MONTH = aMonth;
                qd.MAT_NO = aMatNo;
                qd.MAT_DESC = aMatDesc;
                qd.QUOTA = aQuota;
                qd.USAGE = aUsage;
                qd.ADDITIONAL_QUOTA = aAdditionalQuota;

                if (QuotaRepository.Instance.CountDataDetail(aQuotaNo, aMonth, aMatNo) == 0)
                {
                    string result = QuotaRepository.Instance.InsertDetail(qd, this.GetCurrentUsername());
                    if (result == "SUCCESS")
                    {
                        message = "Save Success for Material Number "+aMatNo+" in Month "+aMonth+"";
                    }
                    else
                    {
                        message = "Failed";
                    }
                }
                else
                {
                    message = "Data already saved";
                }
            }
            catch (Exception e)
            {
                message = e.Message.ToString();
            }
            return message;
        }

        public ActionResult GetDetailList(string quota_no)
        {
            ViewData["QuotaListDetail"] = QuotaRepository.Instance.GetQuotaDetailList(quota_no);
            base.Index();
            return PartialView("_QuotaDetailList");
        }

        public string DeleteQuota(string QUOTA_NO, string MONTH, string MAT_NO)
        {
            string message = "";
            try
            {
                if (QuotaRepository.Instance.CekUsageDetail(QUOTA_NO, MONTH, MAT_NO) > 0)
                {
                    message = "Delete data by selected record is fail : <strong>Usage</strong> is Not 0";
                }
                else
                {
                    string result = QuotaRepository.Instance.DeleteQuotaDetail(QUOTA_NO, MONTH, MAT_NO, this.GetCurrentUsername());
                    if (result == "SUCCESS")
                    {
                        message = "Delete data by selected record is success";
                    }
                    else
                    {
                        message = "Delete data by selected record is fail";
                    }
                }
            }
            catch (Exception e)
            {
                message = e.Message.ToString();
            }
            return message;
        }
    }
}


