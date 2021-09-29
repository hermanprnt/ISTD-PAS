using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using GPS.Models.Common;

namespace GPS.ViewModels
{
    public class GridPagingViewModel
    {
        public String Id { get; set; }
        public Int32 TotalDataCount { get; set; }
        public Int32 CurrentPage { get; set; }
        public Int32 PageSize { get; set; }

        public Int32 TotalPage
        {
            get
            {
                Int32 totalPage = TotalDataCount/PageSize;
                if (TotalDataCount%PageSize > 0 || totalPage == 0)
                    totalPage += 1;

                return totalPage;
            }
        }

        public IEnumerable<Int32> PageIndex
        {
            get
            {
                var idxList = new List<Int32>();
                for (int idx = CurrentPage - 1; idx <= CurrentPage + 1; idx++)
                    idxList.Add(idx);
                idxList.RemoveAll(idx => idx < 1 || idx > TotalPage);

                return idxList;
            }
        }
    }
}