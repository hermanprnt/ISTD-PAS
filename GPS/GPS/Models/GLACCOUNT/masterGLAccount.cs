using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace GPS.Models.GLACCOUNT
{
    public class masterGLAccount
    {
        public int RowNo {get;set;}
        public string GL_ACCOUNT_CD { get; set; }
        public string GL_ACCOUNT_DESC { get; set; }
        public string PLANT_CD { get; set; }
        public string CREATED_BY { get; set; }
        public string CREATED_DT { get; set; }
        public string CHANGED_BY { get; set; }
        public string CHANGED_DT { get; set; }

    }
}