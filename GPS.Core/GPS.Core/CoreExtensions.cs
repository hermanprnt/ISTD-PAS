using System;
using System.Linq;
using System.Text;
using GPS.Core.ViewModel;

namespace GPS.Core
{
    public static class CoreExtensions
    {
        public static ActionResponseViewModel AsActionResponseViewModel(this String resultString)
        {
            String[] splittedResult = new[] { resultString.Substring(0, 1), resultString.Substring(2, resultString.Length - 2) };
            String[] responseTypeList = new[] { ActionResponseViewModel.Info, ActionResponseViewModel.Warning, ActionResponseViewModel.Error, ActionResponseViewModel.Success };
            if (!responseTypeList.Contains(splittedResult[0]))
                throw new ArgumentException("resultString is bad formatted.");

            var viewModel = new ActionResponseViewModel();
            viewModel.ResponseType = splittedResult[0];
            viewModel.Message = splittedResult[1]
                .Replace(ActionResponseViewModel.Tab, "\t")
                .Replace(ActionResponseViewModel.NewLine, Environment.NewLine);

            return viewModel;
        }

        public static ActionResponseViewModel AsActionResponseViewModel(this Exception ex)
        {
            var viewModel = new ActionResponseViewModel();
            viewModel.ResponseType = ActionResponseViewModel.Error;
            viewModel.Message = ex.Message;

            return viewModel;
        }
    }
}