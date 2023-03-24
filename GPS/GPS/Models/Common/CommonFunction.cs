namespace GPS.Models.Common
{
    public class CommonFunction
    {
        #region singleton
        private CommonFunction() { }
        private static CommonFunction instance = null;
        public static CommonFunction Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new CommonFunction();
                }
                return instance;
            }
        }
        #endregion singleton

        public string DefaultStringValue()
        {
            return "";
        }

        public int DefaultPage()
        {
            return 1;
        }

        public int DefaultSize()
        {
            return 10;
        }
    }
}