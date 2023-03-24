using System;
using System.Collections.Generic;
using GPS.Core;
using System.Configuration;
using System.IO;
using System.Net;
using System.Data;
using GPS.Core.GPSLogService;
using GPS.Core.TDKSimplifier;
using Toyota.Common.Configuration;

namespace POSAPDataImporter
{
    class Import
    {
        public static void ImportDataFromSAP(ILogService logger)
        {
            logger.Info(LogExtensions.Break);
            logger.Info("Process Start");

            string templocation = "";

            try
            {
                #region Download Files
                var repo = new POSAPImportDataRepository(logger);
                string FtpSettings = repo.GetFtpCredential();
                String[] splittedResult = FtpSettings.Split(';');

                if (splittedResult.Length < 3)
                    throw new NullReferenceException("Bug: Ftp Credential is not set right.");

                NetworkCredential cred = new NetworkCredential(splittedResult[1], splittedResult[2]);

                const string module = "0";
                const string function = "001005";
                string Ftplocation = splittedResult[0] + "OUTBOUND/";
                ConfigurationItem tempPathConfig = TDKConfig.GetSystemConfig("TempFilePath") ?? new ConfigurationItem();
                string localLocation = tempPathConfig.Value;
                string archiveLocation = splittedResult[0] + "ARCHIVES/";

                templocation = localLocation; // used in finally statement, delete all files

                DownloadFileFromFTP(Ftplocation, localLocation, cred);
                #endregion

                #region Process Data
                Int64 ProcessId = 0;
                string result = ReadFiles(logger, localLocation, module, function);
                if (result.Split('|')[0] == "SUCCESS")
                    ProcessId = Int64.Parse(result.Split('|')[2]);
                else
                    throw new Exception(result.Split('|')[2]);
                #endregion

                #region Move To Archieve
                MoveFileToArchieve(logger, Ftplocation, localLocation, archiveLocation, cred);
                #endregion

                #region Save Data to TB_R_
                //Note : If import to temporary table is success
                if (result != "0")
                {
                    result = repo.SaveData(ProcessId);
                    if (result != "SUCCESS")
                        throw new Exception(result);
                }
                #endregion
            }
            catch (Exception ex)
            {
                logger.Error(ex);
            }
            finally
            { 
                //Note: Delete all file(s) in temp folder, in case there is some error file(s) that left in temp folder
                if(!String.IsNullOrEmpty(templocation))
                   FileExtension.DeleteAllFile(templocation);
            }
        }

        public static void DownloadFileFromFTP(string FtpLocation, string localLocation, NetworkCredential cred)
        {
            FileExtension.CreateDirectory(localLocation);
            FtpHandler.DownloadAllFiles(FtpLocation, localLocation, cred);
        }

        public static void MoveFileToArchieve(ILogService logger, string Ftplocation, string localLocation, string archiveLocation, NetworkCredential cred)
        {
            String[] listFile = Directory.GetFiles(localLocation);

            int i = 1;
            logger.Info("Move PO SAP file(s) to archieve started");
            foreach (string filename in listFile)
            {
                FtpHandler.Upload(archiveLocation + Path.GetFileName(filename), filename, cred);
                FtpHandler.Delete(Ftplocation + Path.GetFileName(filename), cred);
                File.Delete(filename);
                i++;
            }
            logger.Info("Move data PO SAP file(s) to archieve finished successfully. Moving " + i.ToString() + " file(s)");
        }

        public static string ReadFiles(ILogService logger, string localLocation, string module, string function)
        {
            String[] listfile = Directory.GetFiles(localLocation);
            int totalSuccess = 0;

            try
            {
                if (listfile != null)
                {
                    var repo = new POSAPImportDataRepository(logger);
                    Int64 ProcessId = repo.ImportInit(0, "Import Data PO SAP from SAP started", "SYSTEM", "Import Data PO SAP", null, "INF", module, function, 1);

                    #region Create Data Table 
                    DataTable table = new DataTable();

                    table.Columns.Add("PO_NO");
                    table.Columns.Add("PO_ITEM_NO");
                    table.Columns.Add("FILE_NO");
                    table.Columns.Add("SEQ_NO");
                    table.Columns.Add("VENDOR_CD");
                    table.Columns.Add("VENDOR_NAME");
                    table.Columns.Add("VENDOR_ADDR");
                    table.Columns.Add("VENDOR_POSTAL");
                    table.Columns.Add("VENDOR_CITY");
                    table.Columns.Add("VENDOR_COUNTRY_ID");
                    table.Columns.Add("VENDOR_ATTENTION");
                    table.Columns.Add("VENDOR_TELP");
                    table.Columns.Add("VENDOR_FAX");
                    table.Columns.Add("DLV_NAME");
                    table.Columns.Add("DLV_ADDR");
                    table.Columns.Add("DLV_POSTAL");
                    table.Columns.Add("DLV_CITY");
                    table.Columns.Add("CONTACT_PER");
                    table.Columns.Add("PO_DATE");
                    table.Columns.Add("PO_PAYMENT_TERM");
                    table.Columns.Add("PO_TYPE");
                    table.Columns.Add("PO_CAT");
                    table.Columns.Add("PURCH_GROUP");
                    table.Columns.Add("CURR_CD");
                    table.Columns.Add("AMOUNT");
                    table.Columns.Add("EXCHANGE_RATE");
                    table.Columns.Add("DELETION_FLAG");
                    table.Columns.Add("INCOTERM1");
                    table.Columns.Add("INCOTERM2");
                    table.Columns.Add("INVOICE_FLAG");

                    table.Columns.Add("PR_NO");
                    table.Columns.Add("PR_ITEM_NO");
                    table.Columns.Add("MAT_NO");
                    table.Columns.Add("MAT_DESC");
                    table.Columns.Add("MAT_GRP");
                    table.Columns.Add("VAL_CLASS");
                    table.Columns.Add("DELIVERY_PLAN_DT");
                    table.Columns.Add("PLANT_CD");
                    table.Columns.Add("SLOC_CD");
                    table.Columns.Add("WBS_NO");
                    table.Columns.Add("COST_CENTER");
                    table.Columns.Add("GL_ACCOUNT");
                    table.Columns.Add("ORI_QTY");
                    table.Columns.Add("NEW_QTY");
                    table.Columns.Add("USED_QTY");
                    table.Columns.Add("UOM_CD");
                    table.Columns.Add("PRICE_PER_UOM");
                    table.Columns.Add("ITEM_DELETION_FLAG");
                    table.Columns.Add("TAX_CD");
                    table.Columns.Add("COMP_CD");
                    table.Columns.Add("COMP_RATE");

                    table.Columns.Add("SERV_ITEM");
                    table.Columns.Add("SERV_TEXT");
                    table.Columns.Add("SERV_UNIT");
                    table.Columns.Add("SERV_QTY");
                    table.Columns.Add("SERV_GPRICE");
                    table.Columns.Add("LINE_NO");
                    table.Columns.Add("LINE_TEXT");
                    table.Columns.Add("OUT_TYPE");
                    table.Columns.Add("OUT_MESSAGE");
                    table.Columns.Add("CREATED_BY");
                    table.Columns.Add("CREATED_DT");
                    table.Columns.Add("CHANGED_BY");
                    table.Columns.Add("CHANGED_DT");

                    #endregion

                    int FILE_NO = 1;
                    foreach (var filename in listfile)
                    {
                        try
                        {
                            #region Read file's content and add into data table
                            using (StreamReader reader = new StreamReader(filename))
                            {
                                string RowData;
                                string[] data;

                                int SEQ = 1;
                                while ((RowData = reader.ReadLine()) != null)
                                {
                                    DataRow row = table.NewRow();

                                    data = RowData.Split(new string[] { "\t" }, StringSplitOptions.None);

                                    if (data[0] == "E")
                                        throw new Exception("File not containing data PO");

                                    row["PO_NO"] = data[0];
                                    row["PO_ITEM_NO"] = data[1];
                                    row["FILE_NO"] = FILE_NO;
                                    row["SEQ_NO"] = SEQ;
                                    row["VENDOR_CD"] = data[2] == "" ? "" : Int64.Parse(data[2]).ToString();
                                    row["VENDOR_NAME"] = data[3];
                                    row["VENDOR_ADDR"] = data[4];
                                    row["VENDOR_POSTAL"] = data[5];
                                    row["VENDOR_CITY"] = data[6];
                                    row["VENDOR_COUNTRY_ID"] = data[7];
                                    row["VENDOR_ATTENTION"] = data[8];
                                    row["VENDOR_TELP"] = data[9];
                                    row["VENDOR_FAX"] = data[10];
                                    
                                    row["DLV_NAME"] = data[11];
                                    row["DLV_ADDR"] = data[12];
                                    row["DLV_POSTAL"] = data[13];
                                    row["DLV_CITY"] = data[14];
                                    row["CONTACT_PER"] = data[15];
                                    row["PO_DATE"] = data[16].Contains("-") ? data[16] : data[16].Insert(4, "-").Insert(7, "-");
                                    row["PO_PAYMENT_TERM"] = data[17];
                                    row["PO_TYPE"] = data[18];
                                    row["PO_CAT"] = data[19];
                                    row["PURCH_GROUP"] = data[20];
                                    row["CURR_CD"] = data[21];
                                    row["AMOUNT"] = data[22] == "" ? 0 : Convert.ToDecimal(data[22].Replace(",", "").Trim());
                                    row["EXCHANGE_RATE"] = data[23] == "" ? 0 : Convert.ToDecimal(data[23].Replace(",", ".").Trim());
                                    row["DELETION_FLAG"] = data[24];
                                    row["INCOTERM1"] = data[25];
                                    row["INCOTERM2"] = data[26];
                                    row["CREATED_BY"] = data[27];
                                    row["INVOICE_FLAG"] = data[28];

                                    row["PR_NO"] = data[29];
                                    row["PR_ITEM_NO"] = data[30];
                                    row["MAT_NO"] = data[31];
                                    row["MAT_DESC"] = data[32];
                                    row["MAT_GRP"] = data[33];
                                    row["VAL_CLASS"] = data[34];
                                    row["DELIVERY_PLAN_DT"] = data[35].Contains("-") ? data[35] : data[35].Insert(4, "-").Insert(7, "-");
                                    row["PLANT_CD"] = data[36];
                                    row["SLOC_CD"] = data[37];
                                    row["WBS_NO"] = data[38];
                                    row["COST_CENTER"] = data[39];
                                    row["GL_ACCOUNT"] = data[40];
                                    row["ORI_QTY"] = data[42] == "" ? 0 : Convert.ToDecimal(data[42].Replace(",", "").Trim());
                                    row["NEW_QTY"] = data[42] == "" ? 0 : Convert.ToDecimal(data[42].Replace(",", "").Trim());
                                    //if (data[43] == "0,000") data[43] = "0.000";
                                    //row["USED_QTY"] = data[43] == "" ? 0 : Convert.ToDecimal(data[43].Replace(",", "").Trim());
                                    row["USED_QTY"] = "0.000";
                                    row["UOM_CD"] = data[44];
                                    row["PRICE_PER_UOM"] = data[45] == "" ? 0 : Convert.ToDecimal(data[45].Replace(",", "").Trim());
                                    row["ITEM_DELETION_FLAG"] = data[46];
                                    row["TAX_CD"] = data[47];
                                    row["COMP_CD"] = data[48];
                                    row["COMP_RATE"] = data[49] == "" ? 0 : Convert.ToDecimal(data[49].Replace(",", "").Trim());

                                    row["SERV_ITEM"] = data[50];
                                    row["SERV_TEXT"] = data[51];
                                    row["SERV_UNIT"] = data[52];
                                    row["SERV_QTY"] = data[53] == "" ? 0 : Convert.ToDecimal(data[53].Replace(",", "").Trim());
                                    row["SERV_GPRICE"] = data[54] == "" ? 0 : Convert.ToDecimal(data[54].Replace(",", "").Trim());
                                    row["LINE_NO"] = data[56];
                                    row["LINE_TEXT"] = data[57];
                                    row["OUT_TYPE"] = data[58];
                                    row["OUT_MESSAGE"] = data[59];
                                    row["CREATED_DT"] = DateTime.Now.Date;
                                    row["CHANGED_BY"] = null;
                                    row["CHANGED_DT"] = null;
                                    if (!String.IsNullOrEmpty(data[55])) row["WBS_NO"] = data[55];

                                    table.Rows.Add(row);
                                    SEQ++;
                                }
                                totalSuccess = totalSuccess + 1;
                            }
                            #endregion
                        }
                        catch (Exception ex)
                        {
                            logger.Info("Error Import Data From File " + filename + " : " + ex.Message);
                        }
                        FILE_NO++;
                    }

                    #region Save Temp Data into Database
                    if (totalSuccess > 0)
                    {
                        string msg = repo.SaveTemp(table);
                        if (msg != "SUCCESS")
                            throw new Exception(msg);
                    }
                    #endregion

                    logger.Info("Import Data PO SAP Finished Successfully");
                    return "SUCCESS|" + totalSuccess.ToString() + "|" + ProcessId.ToString();
                }
                else
                {
                    return "ERROR|0|No Data PO SAP to be Imported";
                }
            }
            catch (Exception ex)
            {
                return "ERROR|0|Error import data PO SAP : " + ex.Message;
            }
        }
    }
}
