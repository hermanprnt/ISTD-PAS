using System;
using GPS.Models.Master;

namespace GPS.ViewModels.Master
{
    public class PurchasingGroupSearchViewModel : SearchViewModel
    {
        public String Code { get; set; }
        public String Desc { get; set; }
    }
}