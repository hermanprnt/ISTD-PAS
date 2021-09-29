using System;
using System.Collections.Generic;
using System.Web.Mvc;
using GPS.Models.Common;

namespace GPS.ViewModels
{
    public class DropdownListViewModel
    {
        public String DataName { get; set; }
        public SelectList DataList { get; set; }
        public IEnumerable<NameValueItem> EmbeddedDataList { get; set; }

        public DropdownListViewModel()
        {
            EmbeddedDataList = new List<NameValueItem>();
        }
    }
}