using ScriptEngine.Machine.Contexts;
using Hik.Communication.ScsServices.Service;

namespace oscs
{

    [ContextClass("КсПриложениеСервисКлиент", "CsServiceApplicationClient")]
    public class CsServiceApplicationClient : AutoContext<CsServiceApplicationClient>
    {
        public IScsServiceClient Client { get; set; }
        public string clientGuid;
        public IMyClient ClientProxy { get; set; }

        public CsServiceApplicationClient(IScsServiceClient client)
        {
            Client = client;
        }
        
        [ContextProperty("ГуидКлиента", "ClientGuid")]
        public string ClientGuid
        {
            get { return clientGuid; }
        }

        [ContextProperty("ИдентификаторКлиента", "ClientId")]
        public decimal ClientId
        {
            get { return Client.ClientId; }
        }

        [ContextProperty("СостояниеСоединения", "CommunicationState")]
        public int CommunicationState
        {
            get { return (int)Client.CommunicationState; }
        }

        
        [ContextMethod("Отключить", "Disconnect")]
        public void Disconnect()
        {
            Client.Disconnect();
        }

        //endMethods
    }
}
