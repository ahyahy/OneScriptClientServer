using System;
using ScriptEngine.Machine.Contexts;
using ScriptEngine.Machine;
using ScriptEngine.HostedScript.Library;
using Hik.Communication.ScsServices.Service;

namespace Hik.Communication.ScsServices.Service
{
    // Хранит информацию о клиенте сервиса, которая будет использоваться событием.
    public class ServiceClientEventArgs : System.EventArgs
    {
        // Клиент, связанный с этим событием.
        public IScsServiceClient Client { get; private set; }

        // Создает новый объект ServiceClientEventArgs.
        // "client" - Клиент, связанный с этим событием.
        public ServiceClientEventArgs(IScsServiceClient client)
        {
            Client = client;
        }
    }
}

namespace oscs
{
    public class ServiceClientEventArgs : oscs.EventArgs
    {
        public new CsServiceClientEventArgs dll_obj;
        private IScsServiceClient client;
        public CsServiceApplicationClient ServiceApplicationClient { get; set; }

        public ServiceClientEventArgs(IScsServiceClient p1)
        {
            client = p1;
        }

        public ServiceClientEventArgs(Hik.Communication.ScsServices.Service.ServiceClientEventArgs args)
        {
            client = args.Client;
        }
		
        public decimal ClientId
        {
            get { return Convert.ToDecimal(client.ClientId); }
        }

        public int CommunicationState
        {
            get { return (int)client.CommunicationState; }
        }
		
        public CsServiceApplicationClient Client
        {
            get { return ServiceApplicationClient; }
        }
    }

    [ContextClass("КсПриложениеКлиентАрг", "CsServiceClientEventArgs")]
    public class CsServiceClientEventArgs : AutoContext<CsServiceClientEventArgs>
    {
        public CsServiceClientEventArgs(oscs.ServiceClientEventArgs p1)
        {
            oscs.ServiceClientEventArgs ServiceClientEventArgs1 = p1;
            ServiceClientEventArgs1.dll_obj = this;
            Base_obj = ServiceClientEventArgs1;
        }

        public CsServiceClientEventArgs(Hik.Communication.ScsServices.Service.ServiceClientEventArgs p1)
        {
            oscs.ServiceClientEventArgs ServiceClientEventArgs1 = new oscs.ServiceClientEventArgs(p1);
            ServiceClientEventArgs1.dll_obj = this;
            Base_obj = ServiceClientEventArgs1;
        }

        public oscs.ServiceClientEventArgs Base_obj;

        
        [ContextProperty("Действие", "EventAction")]
        public DelegateAction EventAction
        {
            get { return Base_obj.EventAction; }
            set { Base_obj.EventAction = value; }
        }
        
        [ContextProperty("Клиент", "Client")]
        public CsServiceApplicationClient Client
        {
            get { return Base_obj.ServiceApplicationClient; }
        }
        
        [ContextProperty("Отправитель", "Sender")]
        public IValue Sender
        {
            get { return Base_obj.Sender.dll_obj; }
        }
        
        
        //endMethods
    }
}
