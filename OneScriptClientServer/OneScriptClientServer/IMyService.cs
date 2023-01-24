using Hik.Communication.ScsServices.Service;

namespace oscs
{
    [ScsService]
    public interface IMyService
    {
        void DoAtServer(string str, System.Collections.ArrayList parametersArray = null);
        dynamic DoAtServerWithResalt(string str, System.Collections.ArrayList parametersArray = null);
        string ToString();
    }
}
