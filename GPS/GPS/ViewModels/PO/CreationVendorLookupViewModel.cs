using GPS.Models.Common;
using GPS.ViewModels.Lookup;

namespace GPS.ViewModels.PO
{
    public class CreationVendorLookupViewModel : LookupViewModel<NameValueItem>
    {
        public NameValueItem OneTimeVendor { get; set; }
    }
}