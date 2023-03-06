using System;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Master;
using Toyota.Common.Web.Platform;
using GPS.Models.Common;

namespace GPS.Controllers.Master
{
    public class PlantController : PageController
    {
        public PlantController()
        {
            Settings.Title = "Plant Master";

        }

        protected override void Startup() 
        {
        }

        #region SEARCH
        private void Calldata(int Display, int Page, string PlantCd, string PlantName)
        {
            Paging pg = new Paging(PlantRepository.Instance.CountData(PlantCd, PlantName), Page, Display);
            ViewData["Paging"] = pg;
            ViewData["ListPlant"] = PlantRepository.Instance.getListData(PlantCd, PlantName, pg.StartData, pg.EndData);
        }

        [HttpPost]
        public ActionResult SearchData(int Display, int Page, string PlantCd, string PlantName)
        {
            Calldata(Display, Page, PlantCd, PlantName);
            return PartialView("_plantGrid");
        }
        #endregion

        #region CRUD
        public ActionResult GetSingleData(string isNew, string PlantCd)
        {
            if (isNew == "Y")
                ViewData["PlantData"] = new Plant();
            else
                ViewData["PlantData"] = PlantRepository.Instance.GetCurrentRowData(PlantCd);

            return PartialView("_AddEditPopUp");
        }

        public string SavingData(Plant plant, string editFlag)
        {
            string message = "";
            
            try
            {
                PlantRepository.Instance.savingDataPlant(plant, editFlag, this.GetCurrentUsername());
            }
            catch (Exception ex)
            {
                message = "Error : " + ex.Message;
            }

            return message;
        }

        public string DeleteData(string PlantCd)
        {
            string message = "";

            try
            {
                PlantRepository.Instance.DeletePlant(PlantCd);
            }
            catch (Exception ex)
            {
                message = "Error : " + ex.ToString();
            }

            return message;
        }
        #endregion

        #region COMMON LIST
        public static SelectList PlantSelectList 
        {
            get
            {
                return PlantRepository.Instance
                    .GetPlantList()
                    .AsSelectList(plant => plant.PLANT_CD + " - " + plant.PLANT_NAME, plant => plant.PLANT_CD);
            }
        }
        #endregion

        //add by fid.ahmad 20-02-2023
        #region COMMON LIST

        public static SelectList PlantSelectListByDivisionId(String RegNo, String PlantBefore)
        {
            return PlantRepository.Instance
                     .GetPlantListByDivisionId(RegNo, PlantBefore)
                     .AsSelectList(plant => plant.PLANT_CD + " - " + plant.PLANT_NAME, plant => plant.PLANT_CD);

        }
        #endregion
    }
}