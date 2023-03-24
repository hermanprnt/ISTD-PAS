using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Constants;
using GPS.Core;
using GPS.Core.ViewModel;
using GPS.Models;
using GPS.Models.Common;
using GPS.Models.Master;
using NPOI.HSSF.UserModel;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;
using GPS.ViewModels.Lookup;
using GPS.ViewModels.Master;

namespace GPS.Controllers.Master
{
    public class MaterialController : PageController
    {
        public sealed class Action
        {
            public const String MaterialImageUpdate = "/Material/UpdateImageEmpty";
            public const String UploadNewImage = "/Material/UploadNewImage";
            public const String GetUploadValidationInfo = "/Material/GetUploadValidationInfo";
            public const String GetUploadImageValidationInfo = "/Material/GetUploadImageValidationInfo";
            public const String Upload = "/Material/Upload";
            public const String GetLookupValClass = "/Material/getValuationClass";
            public const String GetLookupValClassGrid = "/Material/getValuationClassGrid";
        }

        public sealed class Partial
        {
            public const String UpdateImage = "_PopUpUpdateImage";
        }

        protected override void Startup()
        {
            Settings.Title = "Material Master";

            Calldata(10, 1, null, null, null, null, null, null, null, null, null);

            var execParam = new ExecProcedureModel();
            execParam.CurrentUser = this.GetCurrentUsername();
            execParam.ModuleId = ModuleId.MasterData;
            execParam.FunctionId = FunctionId.Material;
            execParam.ProcessId = MaterialRepository.Instance.Initial(execParam);
            ViewData["ProcessId"] = execParam.ProcessId;
        }

        #region COMMON LIST
        public static SelectList SelectCarFamily()
        {
            return CarFamilyRepository.Instance
                    .GetAllData()
                    .AsSelectList(cf => cf.CAR_FAMILY_CD + " - " + cf.CAR_FAMILY_NAME, cf => cf.CAR_FAMILY_CD);
        }

        public static SelectList SelectConsignment()
        {
            return ItemConsignmentRepository.Instance
                    .GetAllData()
                    .AsSelectList(cg => cg.CONSIGNMENT_DESC, cg => cg.CONSIGNMENT_CD);
        }

        public static SelectList SelectMatType()
        {
            return MaterialTypeRepository.Instance
                    .GetAllData()
                    .AsSelectList(mt => mt.MAT_TYPE_NAME, mt => mt.MAT_TYPE_CD);
        }

        public static SelectList SelectMatGroup()
        {
            return MaterialGroupRepository.Instance
                    .GetAllData()
                    .AsSelectList(mg => mg.MAT_GRP_DESC, mg => mg.MAT_GRP_CD);
        }

        public static SelectList SelectUOM()
        {
            return UnitOfMeasureRepository.Instance
                    .GetAllData()
                    .AsSelectList(uom => uom.UNIT_OF_MEASURE_DESC, uom => uom.UNIT_OF_MEASURE_CD);
        }

        public static SelectList SelectProcurementUsage()
        {
            return ProcurementUsageRepository.Instance
                    .GetAllData()
                    .AsSelectList(pu => pu.PROC_USAGE_CD + " - " + pu.DESCRIPTION, pu => pu.PROC_USAGE_CD);
        }

        public static SelectList SelectValuationClass()
        {
            return ValuationClassRepository.Instance
                    .GetListValuationClass()
                    .AsSelectList(vc => vc.VALUATION_CLASS_DESC, vc => vc.VALUATION_CLASS);
        }

        public ActionResult getValuationClass(string PARAM, int pageSize = 10, int page = 1)
        {
            BindValuationClass(PARAM, pageSize, page);
            return PartialView("_LookupValuationClass");
        }

        public ActionResult getValuationClassGrid(string PARAM, int pageSize = 10, int page = 1)
        {
            BindValuationClass(PARAM, pageSize, page);
            return PartialView("_LookupValuationClassGrid");
        }

        private void BindValuationClass(string searchparam, int pageSize = 10, int page = 1)
        {

            ViewData["ValClass"] = ValuationClassRepository.Instance.GetDataByFreeParam(searchparam, page, pageSize);
            ViewData["Paging"] = CountIndex(ValuationClassRepository.Instance.CountDataByFreeParam(searchparam), pageSize, page);
            ViewData["FUNC"] = "getValClassGrid";
        }
        #endregion

        private Paging CountIndex(int count, int length, int page)
        {
            Paging PG = new Paging(count, page, length);
            List<int> index = new List<int>();

            PG.Length = count;
            PG.CountData = count;
            Double Total = Math.Ceiling((Double)count / (Double)length);

            for (int i = 1; i <= Total; i++) { index.Add(i); }
            PG.IndexList = index;
            return PG;
        }

        public ActionResult IsFlagAddEdit(string kelas, string IsFlagAddEdit)
        {
            ViewData["edit"] = IsFlagAddEdit;

            return PartialView("_PopUpMaterial");
        }

        //for on get data first paging
         [HttpPost]
        public ActionResult onGetData(string search, string kelas, string mat_no, string mat_desc, string uom, string mrp_type,
                                      string valuation_class, string proc_usage, string asset_flag, string quota_flag, int Display, int Page)
        {
            if (search == YesNoFlag.Yes)
            {
                Calldata(Display, Page,kelas, mat_no, mat_desc, uom, mrp_type, valuation_class, proc_usage, asset_flag, quota_flag);
            }
            return PartialView("_ViewTable");
        }

        //for save data
        public string SaveData(string Kelas,Material mat)
        {
            string message = "";
            try
            {
                var execute = MaterialRepository.Instance.SaveData(Kelas, mat, 1, this.GetCurrentUsername());
                if (execute.Item2 == "SUCCESS")
                {
                    message = "True|Material No <strong>" + mat.MaterialNo + "</strong>, save successfully";
                }
                else
                {
                    message = "False|" + execute.Item2;
                }
            }
            catch (Exception e)
            {
                message = "Error|" + e.Message.ToString();
            }
            return message;
        }

        //get a data
        public ActionResult GetSingleData(string kelas, string mat_no)
        {
            kelas = kelas.Substring(0, 1); //Class data that sent by javascript is Class desc, substring for get class cd
            return Json(MaterialRepository.Instance.GetSingleData(kelas, mat_no));
        }

        public ActionResult DeleteData(string kelas, string mat_no)
        {
            string message = "";
            try
            {
                MaterialRepository.Instance.DeleteData(kelas, mat_no, this.GetCurrentUsername());
                message = "Delete success";
            }
            catch (Exception e)
            {
                message = e.Message.ToString();
            }
            return Json(message, JsonRequestBehavior.AllowGet);
        }

        //for delete material
        public string DeleteMaterial(string MAT_NO)
        {
            string message = "";
            int Deleted = 0;
            List<string> List = new List<string>();
            if (!string.IsNullOrEmpty(MAT_NO))
            {
                string[] sum = MAT_NO.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                foreach (string Mat_No in sum)
                {
                    try
                    {
                        string kelas = Mat_No.Split(';')[1].Substring(0, 1);
                        var result = MaterialRepository.Instance.DeleteData(kelas, Mat_No.Split(';')[0], this.GetCurrentUsername());
                        if (result == "SUCCESS")
                            ++Deleted;
                    }
                    catch (Exception e)
                    {
                        List.Add(e.Message);
                    }
                }
            }
            if (Deleted > 0 && List.Count < 1)
            {
                message = Deleted.ToString() + " data";
            }
            else if (Deleted < 1 && List.Count < 1)
            {
                message = Deleted.ToString() + " data";
            }
            else
            {
                message = Deleted.ToString() + " data";
            }
            return message;
        }

        //for call data
        private void Calldata(int Display, int Page,string kelas, string mat_no, string mat_desc, string uom,
                              string mrp_type, string valuation_class, string proc_usage, string asset_flag, string quota_flag)
        {
            Paging pg = new Paging(MaterialRepository.Instance.CountData(kelas,mat_no, mat_desc, uom, mrp_type, valuation_class,proc_usage, asset_flag, quota_flag), Page, Display);
            ViewData["Paging"] = pg;
            List<Material> list = MaterialRepository.Instance.GetData(pg.StartData, pg.EndData, kelas, mat_no, mat_desc, uom, mrp_type, valuation_class, proc_usage, asset_flag, quota_flag);
            ViewData["ListMaterial"] = list;
        }

        //for download
        public void DownloadReport(string kelas, int Display, int Page, string mat_no, string mat_desc, string uom, string mrp_type,
                                   string valuation_class, string proc_usage, string asset_flag, string quota_flag)
        {
            Paging pg = new Paging(MaterialRepository.Instance.CountData(kelas, mat_no, mat_desc, uom, mrp_type, valuation_class, proc_usage, asset_flag, quota_flag), Page, Display);
            ViewData["Paging"] = pg;
            List<Material> List = MaterialRepository.Instance.GetData(pg.StartData, pg.CountData, kelas, mat_no, mat_desc, uom, mrp_type, valuation_class, proc_usage, asset_flag, quota_flag).ToList();
            var workboook = new HSSFWorkbook();
            string FileName = string.Format("Material_" + DateTime.Now.ToString("yyyyMMddhhmmss")+ ".xls", DateTime.Now).Replace("/", "-");//for file name
            List<string[]> ListArr = new List<string[]>();//array for choose data
            String[] header = new string[21] {  "Material Number", "Material Description",
                                                "Material Type","Material Group", "UOM", "Valuation Class",
                                                "MRP Type",  "Car Family",  "Consignment", "Proc. Usage",
                                                "Reorder Point", "Reorder Method", "Delivery Time",
                                                "Daily Consumption", "Min Stock", "Max Stock", "Pcs Per Kanban",
                                                "MRP Flag", "Stock Flag", "Asset Flag", "Quota Flag"};//for header name
            ListArr.Add(header);
            //choose data for show in report
            foreach (Material obj in List)
            {
                String[] myArr = new string[21]
                {
                    obj.MaterialNo ,
                    obj.MaterialDesc ,
                    obj.MaterialTypeCode ,
                    obj.MaterialGroupCode ,
                    obj.UOM ,
                    obj.ValuationClass ,
                    obj.MRPType ,
                    obj.CarFamilyCode ,
                    obj.ConsignmentCode,
                    obj.ProcUsageCode,
                    obj.ReOrderValue.ToString() ,
                    obj.ReOrderMethod ,
                    obj.StandardDelivTime.ToString(),
                    obj.AvgDailyConsump.ToString(),
                    obj.MinStock.ToString(),
                    obj.MaxStock.ToString(),
                    obj.PcsPerKanban.ToString(),
                    obj.MRPFlag ,
                    obj.StockFlag ,
                    obj.AssetFlag ,
                    obj.QuotaFlag
                };
                ListArr.Add(myArr);
            }
            workboook = CommonDownload.Instance.CreateExcelSheet(ListArr, "Material");//call function execute report
            using (var exportData = new MemoryStream())//binding to streamreader
            {
                workboook.Write(exportData);
                Response.ClearContent();
                Response.Buffer = true;
                Response.ContentType = "application/ms-excel";
                Response.AddHeader("Content-Disposition", string.Format("attachment;filename={0}", FileName));
                Response.BinaryWrite(exportData.GetBuffer());
                Response.Flush();
                Response.End();
            }
        }

        //download template for upload
        public void DownloadTemplate()
        {
            CommonController.DownloadTemplate(this, "~/Content/Download/Template/Material.xls");
        }

        [HttpPost]
        public ActionResult GetUploadValidationInfo()
        {
            try
            {
                UploadValidationInfo info = CommonUploadRepository.Instance.GetDataUploadValidationInfo();
                return Json(info);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult GetUploadImageValidationInfo()
        {
            try
            {
                UploadValidationInfo info = CommonUploadRepository.Instance.GetDocumentUploadValidationInfo();
                return Json(info);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult Upload(HttpPostedFileBase uploadedFile, String processId)
        {
            try
            {
                MaterialRepository.Instance.SaveMaterialUploadFile(uploadedFile.FileName, uploadedFile.ContentLength, uploadedFile.InputStream, this.GetCurrentUsername(), processId);

                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = "File " + uploadedFile.FileName + " is uploaded successfully." });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult OpenMaterialLookup(MaterialLookupSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new LookupViewModel<Material>();
                viewModel.Title = "Material";
                viewModel.DataList = MaterialRepository.Instance.GetMaterialLookupList(searchViewModel);
                viewModel.GridPaging = MaterialRepository.Instance.GetMaterialLookupListPaging(searchViewModel);

                return PartialView(LookupPage.MaterialLookup, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult SearchMaterialLookup(MaterialLookupSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new LookupViewModel<Material>();
                viewModel.Title = "Material";
                viewModel.DataList = MaterialRepository.Instance.GetMaterialLookupList(searchViewModel);
                viewModel.GridPaging = MaterialRepository.Instance.GetMaterialLookupListPaging(searchViewModel);

                return PartialView(LookupPage.MaterialLookupGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult UpdateImageEmpty(String matNo)
        {
            try
            {
                MaterialImageViewModel viewModel = MaterialRepository.Instance.GetMaterialImage(matNo);
                return PartialView(Partial.UpdateImage, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult UploadNewImage(HttpPostedFileBase uploadedFile, String processId, String matNo)
        {
            try
            {
                MaterialRepository.Instance.SaveMaterialUploadImage(uploadedFile.FileName, uploadedFile.ContentLength, uploadedFile.InputStream, this.GetCurrentUsername(), processId, matNo);

                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = "Material image is changed to " + uploadedFile.FileName });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }
    }
}