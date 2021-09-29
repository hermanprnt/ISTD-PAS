using System;
using System.Collections.Specialized;

namespace GPS.ViewModels
{
    public class GridColumn
    {
        public String Header { get; set; }
        public String Width { get; set; }
        public String Css { get; set; }
        public Boolean IsHidden { get; set; }
        public String StringFormat { get; set; }
        public NameValueCollection EmbeddedDataList { get; set; }
    }
}