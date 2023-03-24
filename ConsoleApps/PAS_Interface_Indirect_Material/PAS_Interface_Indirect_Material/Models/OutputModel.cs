using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PAS_Interface_Indirect_Material.Models
{
    class OutputModel
    {
        public bool Status { get; set; }
        public object Data { get; set; }
        public object Message { get; set; }
        public OutputModel() { }

        public OutputModel(bool _status = false, object _data = null, object _message = null)
        {
            Status = _status;
            Data = _data;
            Message = _message;
        }

        public void SetOutput(bool _status = false, object _data = null, object _message = null)
        {
            Status = _status;
            Data = _data;
            Message = _message;
        }
    }
}
