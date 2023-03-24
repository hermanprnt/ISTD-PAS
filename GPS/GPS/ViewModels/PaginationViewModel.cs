using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using GPS.Models.Common;

namespace GPS.ViewModels
{
    public class PaginationViewModel
    {
        public String DataName { get; set; }
        public Int32 TotalDataCount { get; set; }
        public Int32 PageIndex { get; set; }
        public Int32 PageSize { get; set; }

        private Int32 totalPageCount;
        public Int32 TotalPageCount
        {
            get
            {
                if (totalPageCount == 0)
                {
                    Int32 totalPage = (TotalDataCount / PageSize);
                    if (TotalDataCount % PageSize > 0 || totalPage == 0)
                        totalPage += 1;

                    return totalPage;
                }

                return totalPageCount;
            }
            set { totalPageCount = value; }
        }

        // Define maximum number of page range showed.
        // Page range : page showed before and after current page.
        public const Int32 PageRange = 2;

        public static readonly SelectList PageRowCountSelectList = new SelectList(GetPageRowCount(), NameValueItem.NameProperty,
            NameValueItem.ValueProperty, GetPageRowCount().First());

        public static IEnumerable<NameValueItem> GetPageRowCount()
        {
            yield return new NameValueItem("10", "10");
            yield return new NameValueItem("30", "30");
            yield return new NameValueItem("50", "50");
            yield return new NameValueItem("100", "100");
        }

        public static Int32 DefaultPageSize
        {
            get { return Convert.ToInt32(GetPageRowCount().First().Value); }
        }

        public static PaginationViewModel GetDefault(String dataName)
        {
            return new PaginationViewModel { DataName = dataName, PageIndex = 1, PageSize = DefaultPageSize };
        }
    }
}