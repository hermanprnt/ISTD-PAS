using System.Collections.Generic;
using GPS.Models.Common;
using Toyota.Common.Credential;

namespace GPS.ViewModels
{
    public class GenericViewModel<T> where T : class
    {
        public User CurrentUser { get; set; }
        public IList<T> DataList { get; set; }
        public PaginationViewModel GridPaging { get; set; }
    }
}