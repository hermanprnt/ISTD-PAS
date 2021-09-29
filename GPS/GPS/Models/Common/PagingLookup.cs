using System.Collections.Generic;

namespace GPS.Models.Common
{
    public class PagingLookup
    {
        public int CountData { get; set; }
        public int Start { get; set; }
        public int End { get; set; }
        public int Length { get; set; }
        public List<int> IndexList { get; set; }
    }
}
