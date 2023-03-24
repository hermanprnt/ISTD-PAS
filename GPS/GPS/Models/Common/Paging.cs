using System;
using System.Collections.Generic;

namespace GPS.Models.Common
{
    public class Paging
    {
        public int Length;

        private int p;
        public int CountData { get; set; }
        public int StartData { get; set; }
        public int EndData { get; set; }
        public int PositionPage { get; set; }
        public int DataPerPage { get; set; }
        public double CountPage { get; set; }
        public List<int> IndexList { get; set; }
        public int First { get; set; }
        public int Last { get; set; }
        public int Next { get; set; }
        public int Prev { get; set; }

        public Paging(int countdata, int positionpage, int dataperpage)
        {
            List<int> list = new List<int>();
            EndData = positionpage * dataperpage;
            CountData = countdata;
            PositionPage = positionpage;
            DataPerPage = dataperpage;
            StartData = (positionpage - 1) * dataperpage + 1;

            if (countdata % dataperpage != 0)
            {
                CountPage = Math.Truncate((double)countdata / dataperpage) + 1;
            }
            else
            {
                CountPage = Math.Round((double)countdata / dataperpage);
            }
            First = 1;
            Last = (int)CountPage;
            Next = positionpage < (int)CountPage ? positionpage + 1 : (int)CountPage;
            Prev = positionpage == 1 ? 1 : positionpage - 1;
        }


        public Paging(int p)
        {
            // TODO: Complete member initialization
            this.p = p;
        }

    }
}
