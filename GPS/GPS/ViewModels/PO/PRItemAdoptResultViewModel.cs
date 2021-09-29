using System;
using System.Linq;
using GPS.Models.PO;

namespace GPS.ViewModels.PO
{
    public class PRItemAdoptResultViewModel : GenericViewModel<PRPOItem>
    {
        public Boolean AreThereAnyUrgentPR { get { return DataList.Any(item => item.IsUrgent); } }
        public Boolean AreThereAnyServiceItem { get { return DataList.Any(item => item.IsService); } }
        public Boolean IsFromEcatalogue { get { return DataList.Any(item => item.IsEcatalogue); } }
    }
}