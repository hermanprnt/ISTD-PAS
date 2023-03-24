namespace GPS.Models.Master
{
    public class QuotaDetailRepository
    {
        private QuotaDetailRepository() { }
        private static QuotaDetailRepository instance = null;
        public static QuotaDetailRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new QuotaDetailRepository();
                }
                return instance;
            }
        }
    }
}