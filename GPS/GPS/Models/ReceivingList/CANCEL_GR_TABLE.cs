using System.Collections.Generic;

namespace GPS.Common.Data
{
    public class CANCEL_GR_TABLE
    {

        public List<CANCEL_GR_IN> INPUT { get; set; }
        public List<CANCEL_GR_OUT> OUTPUT { get; set; }


        public CANCEL_GR_TABLE()
        {
            INPUT = new List<CANCEL_GR_IN>();
            OUTPUT = new List<CANCEL_GR_OUT>();
          
        }

        public bool isEmpty()
        {
            return ((INPUT == null || INPUT.Count < 1)
                && (OUTPUT == null || OUTPUT.Count < 1));
        }

    }
}
