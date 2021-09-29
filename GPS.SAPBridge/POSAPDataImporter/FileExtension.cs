using System;
using System.Collections.Generic;
using System.IO;

namespace POSAPDataImporter
{
    class FileExtension
    {
        //Generate New File
        public static void CreateFile(string filepath)
        {
            StreamWriter streamWriter = new StreamWriter(filepath);
            streamWriter.Close();
        }

        //Appended new Line into File
        public static void WriteToFile(string content, string filepath)
        {
            StreamWriter streamWriter = File.Exists(filepath) ?
                                        File.AppendText(filepath) :
                                        new StreamWriter(filepath);
            streamWriter.WriteLine(content);
            streamWriter.Close();
        }

        //Bulk Write into File
        public static void BulkWriteToFile(IList<string> content, string filepath)
        {
            StreamWriter streamWriter = new StreamWriter(filepath);
            streamWriter.Close();

            File.WriteAllLines(filepath, content, System.Text.Encoding.Default);
        }

        //Cut and Paste File
        public static void MovingFile(string SourcesPath, string DestinationPath)
        {
            if (!Directory.Exists(DestinationPath))
                Directory.CreateDirectory(DestinationPath);

            if (Directory.Exists(SourcesPath))
            {
                string[] files = Directory.GetFiles(SourcesPath);

                foreach (string s in files)
                {
                    File.Move(s, System.IO.Path.Combine(DestinationPath,
                                           System.IO.Path.GetFileName(s)));
                }
            }
        }

        public static void MoveFile(string FilePath, string DestinationPath)
        {
            if (!Directory.Exists(DestinationPath))
                Directory.CreateDirectory(DestinationPath);

            if (Directory.Exists(DestinationPath))
            {
                File.Move(FilePath, System.IO.Path.Combine(DestinationPath,
                                              System.IO.Path.GetFileName(FilePath)));
            }
        }

        //Create Directory
        public static void CreateDirectory(string path)
        {
            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);
        }

        //Check File Existence
        public static bool FileExists(string path, string filename)
        {
            bool isExists = false;
            if (Directory.Exists(path))
            {
                string[] files = Directory.GetFiles(path);

                foreach (var s in files)
                {
                    if (TrimmedPrefix(Path.GetFileName(s)) == TrimmedPrefix(filename))
                    {
                        isExists = true;
                    }
                }
            }
            return isExists;
        }

        private static string TrimmedPrefix(string filename)
        {
            string[] Trimmed = filename.Split('.');
            return Trimmed[0];
        }

        public static List<string> ReadLines(string filepath)
        {
            List<string> lines = new List<string>();
            foreach (var line in File.ReadAllLines(filepath))
            {
                lines.Add(line);
            }
            return lines;
        }

        // Delete all File
        public static void DeleteAllFile(string filepath)
        {
            String[] listfile = Directory.GetFiles(filepath);

            foreach (var filename in listfile)
            {
                File.Delete(filename);
            }
        }
    }
}
