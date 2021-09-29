using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class PlantRepository
    {
        private PlantRepository() { }
        private static readonly PlantRepository instance = null;
        public static PlantRepository Instance
        {
            get { return instance ?? new PlantRepository(); }
        }

        #region SEARCH
        public IEnumerable<Plant> getListData(string PlantCd, string PlantName, int Start, int Length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                PlantCd,
                PlantName,
                Start,
                Length
            };

            IEnumerable<Plant> result = db.Fetch<Plant>("Master/Plant/getPlantData", args);

            return result;
        }

        public int CountData(string PlantCd, string PlantName)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                PlantCd,
                PlantName
            };

            int result = db.SingleOrDefault<int>("Master/Plant/CountData", args);
            db.Close();

            return result;
        }
        #endregion

        #region CRUD
        public Plant GetCurrentRowData(string PlantCd)
        {
            Plant result;
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                PlantCd = PlantCd
            };
            result = db.SingleOrDefault<Plant>("Master/Plant/GetSingleCurrentRowData", args);
            return result;
        }

        public int savingDataPlant(Plant plant, string isedit, string userid)
        {
            int result;
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                plant.PLANT_CD,
                plant.PLANT_NAME,
                isedit,
                userid
            };

            result =  db.Execute("Master/Plant/savingDataPlant", args);
            
            db.Close();
            return result;
        }

        public void DeletePlant(string PlantCd) 
        { 
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                PlantCd
            };

            db.Execute("Master/Plant/DeleteData", args);
            db.Close();
        }
        #endregion

        #region COMMON LIST
        public IEnumerable<Plant> GetPlantList()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<Plant> result = db.Fetch<Plant>("Master/GetAllPlant");
            db.Close();

            return result;
        }
        #endregion
    }
}