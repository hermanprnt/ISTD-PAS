using GPS.ViewModels;
using DropdownListViewModel = GPS.ViewModels.DropdownListViewModel;

namespace GPS.Models.PO
{
    
    public class PRItemSearchResult
    {
        public GenericViewModel<PRPOItem> GridDataList { get; set; }
        public DropdownListViewModel SlocDataList { get; set; }
    }
}