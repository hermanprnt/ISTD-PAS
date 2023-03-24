using System;

namespace GPS.ViewModels.Lookup
{
    public class LookupViewModel<T> : GenericViewModel<T> where T : class
    {
        public String Title { get; set; }
    }
}