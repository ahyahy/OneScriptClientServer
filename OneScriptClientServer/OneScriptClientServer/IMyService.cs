using Hik.Communication.ScsServices.Service;
using System.Collections;

namespace oscs
{
    [ScsService(Version = "1.0.0.0")]
    public interface IMyService
    {
        dynamic DoAtServerWithResalt(string methodName, ArrayList parametersArray = null);
        dynamic DoAtClientWithResalt(string senderClientGuid, string clientGuid, string methodName, ArrayList parametersArray = null);

        void AtClientEntrance(string guid, string clientName, oscs.Collection Tag);
        ClientInfo[] GetClientsList();
        string ToString();
    }
}
