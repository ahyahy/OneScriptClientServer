using System;
using ScriptEngine.Machine.Contexts;
using ScriptEngine.Machine;
using System.Runtime.Remoting.Proxies;
using Hik.Communication.ScsServices.Communication;
using Hik.Communication.Scs.Server;
using Hik.Communication.Scs.Communication;
using Hik.Communication.Scs.Communication.Messengers;
using Hik.Communication.Scs.Communication.EndPoints;

namespace Hik.Communication.ScsServices.Service
{
    // Реализует IScsServiceClient.
    // Он используется для управления клиентом сервиса и мониторинга за ним.
    internal class ScsServiceClient : IScsServiceClient
    {
        #region Public events

        // Это событие возникает, когда этот клиент отключен от сервера.
        public event EventHandler Disconnected;

        #endregion

        #region Public properties

        // Уникальный идентификатор для этого клиента.
        public long ClientId
        {
            get { return _serverClient.ClientId; }
        }

        // Получает конечную точку удаленного приложения.
        public ScsEndPoint RemoteEndPoint
        {
            get { return _serverClient.RemoteEndPoint; }
        }

        // Получает состояние связи Клиента.
        public CommunicationStates CommunicationState
        {
            get { return _serverClient.CommunicationState; }
        }

        #endregion

        #region Private fields

        // Ссылка на базовый объект IScsServerClient.
        private readonly IScsServerClient _serverClient;

        // Этот объект используется для отправки сообщений клиенту.
        private readonly RequestReplyMessenger<IScsServerClient> _requestReplyMessenger;

        // Последний созданный прокси-объект для вызова удаленных методов.
        private RealProxy _realProxy;

        #endregion

        #region Constructor

        // Создает новый объект ScsServiceClient.
        // "serverClient" - Ссылка на базовый объект IScsServerClient.
        // "requestReplyMessenger" - RequestReplyMessenger для отправки сообщений.
        public ScsServiceClient(IScsServerClient serverClient, RequestReplyMessenger<IScsServerClient> requestReplyMessenger)
        {
            _serverClient = serverClient;
            _serverClient.Disconnected += Client_Disconnected;
            _requestReplyMessenger = requestReplyMessenger;
        }

        #endregion

        #region Public methods

        // Закрывает клиентское соединение.
        public void Disconnect()
        {
            _serverClient.Disconnect();
        }

        // Получает клиентский прокси-интерфейс, который обеспечивает удаленный вызов клиентских методов.
        // "T" - Тип клиентского интерфейса
        // Возврат - Клиентский интерфейс
        public T GetClientProxy<T>() where T : class
        {
            _realProxy = new RemoteInvokeProxy<T, IScsServerClient>(_requestReplyMessenger);
            return (T)_realProxy.GetTransparentProxy();
        }

        #endregion

        #region Private methods

        // Обрабатывает событие отключения объекта _serverClient.
        // "sender" - Источник события.
        // "e" - Аргументы события.
        private void Client_Disconnected(object sender, EventArgs e)
        {
            _requestReplyMessenger.Stop();
            OnDisconnected();
        }

        #endregion

        #region Event raising methods

        // Вызывает событие отключения.
        private void OnDisconnected()
        {
            var handler = Disconnected;
            if (handler != null)
            {
                handler(this, EventArgs.Empty);
            }
        }

        #endregion
    }
}

namespace oscs
{
    public class ServiceClient
    {
        public CsServiceClient dll_obj;
        private Hik.Communication.ScsServices.Client.IScsServiceClient<oscs.IMyService> M_ServiceClient;
        public oscs.IMyService _proxy;

        public ServiceClient(TcpEndPoint p1)
        {
            M_ServiceClient = Hik.Communication.ScsServices.Client.ScsServiceClientBuilder.CreateClient<oscs.IMyService>(p1.M_TcpEndPoint);
            _proxy = M_ServiceClient.ServiceProxy;
            M_ServiceClient.Connected += M_ServiceClient_Connected;
            M_ServiceClient.Disconnected += M_ServiceClient_Disconnected;
            Connected = "";
            Disconnected = "";
        }

        public ServiceClient(ServiceClient p1)
        {
            M_ServiceClient = p1.M_ServiceClient;
            _proxy = M_ServiceClient.ServiceProxy;
            M_ServiceClient.Connected += M_ServiceClient_Connected;
            M_ServiceClient.Disconnected += M_ServiceClient_Disconnected;
            Connected = "";
            Disconnected = "";
        }

        private void M_ServiceClient_Connected(object sender, System.EventArgs e)
        {
            if (dll_obj.Connected != null)
            {
                oscs.EventArgs EventArgs1 = new EventArgs();
                EventArgs1.EventAction = dll_obj.Connected;
                EventArgs1.Sender = this;
                CsEventArgs CsEventArgs1 = new CsEventArgs(EventArgs1);
                OneScriptClientServer.EventQueue.Enqueue(EventArgs1);
            }
        }

        private void M_ServiceClient_Disconnected(object sender, System.EventArgs e)
        {
            if (dll_obj.Disconnected != null)
            {
                oscs.EventArgs EventArgs1 = new oscs.EventArgs();
                EventArgs1.EventAction = dll_obj.Disconnected;
                EventArgs1.Sender = this;
                CsEventArgs CsEventArgs1 = new CsEventArgs(EventArgs1);
                OneScriptClientServer.EventQueue.Enqueue(EventArgs1);
            }
        }

        public string Connected { get; set; }

        public string Disconnected { get; set; }

        public int CommunicationState
        {
            get { return (int)M_ServiceClient.CommunicationState; }
        }

        public void Disconnect()
        {
            M_ServiceClient.Disconnect();
        }

        public void Connect()
        {
            M_ServiceClient.Connect();
        }


        public oscs.IMyService Proxy
        {
            get { return _proxy; }
        }
    }

    [ContextClass("КсПриложениеКлиент", "CsServiceClient")]
    public class CsServiceClient : AutoContext<CsServiceClient>
    {
        public CsServiceClient(CsTcpEndPoint p1)
        {
            oscs.ServiceClient ServiceClient1 = new oscs.ServiceClient(p1.Base_obj);
            ServiceClient1.dll_obj = this;
            Base_obj = ServiceClient1;
        }

        public ServiceClient Base_obj;

        
        [ContextProperty("ПриОтключении", "Disconnected")]
        public ScriptEngine.HostedScript.Library.DelegateAction Disconnected { get; set; }
        
        [ContextProperty("ПриПодключении", "Connected")]
        public ScriptEngine.HostedScript.Library.DelegateAction Connected { get; set; }
        
        [ContextProperty("СостояниеСоединения", "CommunicationState")]
        public int CommunicationState
        {
            get { return (int)Base_obj.CommunicationState; }
        }

        
        [ContextMethod("ВыполнитьНаСервере", "DoAtServer")]
        public IValue DoAtServer(string p1, ScriptEngine.HostedScript.Library.ArrayImpl p2 = null, bool p3 = true)
        {
            if (Base_obj.CommunicationState == (int)Hik.Communication.Scs.Communication.CommunicationStates.Disconnected)
            {
                return null;
            }

            System.Collections.ArrayList array = new System.Collections.ArrayList();
            if (p2 != null)
            {
                array = new System.Collections.ArrayList();
                for (int i = 0; i < p2.Count(); i++)
                {
                    array.Add(OneScriptClientServer.DefineTypeIValue(p2.Get(i)));
                }
            }
            if (p3)
            {
                dynamic res = Base_obj.Proxy.DoAtServerWithResalt(p1, array);
                if (res.GetType() == typeof(System.Byte[]))
                {
                    return new ScriptEngine.HostedScript.Library.Binary.BinaryDataContext(res);
                }
                return ValueFactory.Create(res);
            }
            else
            {
                Base_obj.Proxy.DoAtServer(p1, array);
            }
            return null;
        }

        [ContextMethod("Отключить", "Disconnect")]
        public void Disconnect()
        {
            Base_obj.Disconnect();
        }
					
        [ContextMethod("Подключить", "Connect")]
        public void Connect()
        {
            Base_obj.Connect();
        }
    }
}
