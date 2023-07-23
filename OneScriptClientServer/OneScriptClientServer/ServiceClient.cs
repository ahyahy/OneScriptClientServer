using System;
using System.Runtime.Remoting.Proxies;
using ScriptEngine.Machine;
using ScriptEngine.Machine.Contexts;
using ScriptEngine.HostedScript.Library;
using ScriptEngine.HostedScript.Library.Binary;
using Hik.Communication.ScsServices.Communication;
using Hik.Communication.Scs.Server;
using Hik.Communication.Scs.Communication;
using Hik.Communication.Scs.Communication.Messengers;
using Hik.Communication.Scs.Communication.EndPoints;
using Hik.Communication.ScsServices.Client;
using System.Collections;
using System.Collections.Generic;

namespace Hik.Communication.ScsServices.Service
{
    // Реализует IScsServiceClient.
    // Он используется для управления клиентом сервиса и мониторинга за ним.
    internal class ScsServiceClient : IScsServiceClient
    {
        public oscs.CsServiceApplicationClient dll_obj { get; set; }
        // Гуид для этого клиента. Он будет установлен при получении сервером сообщения от клиента в момент подключения.
        public string ClientGuid { get; set; }

        // Это событие возникает при отключении клиента от сервера.
        public event EventHandler Disconnected;

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

        // Ссылка на базовый объект IScsServerClient.
        private readonly IScsServerClient _serverClient;

        // Этот объект используется для отправки сообщений клиенту.
        private readonly RequestReplyMessenger<IScsServerClient> _requestReplyMessenger;

        // Последний созданный прокси-объект для вызова удаленных методов.
        private RealProxy _realProxy;

        // Создает новый объект ScsServiceClient.
        // "serverClient" - Ссылка на базовый объект IScsServerClient.
        // "requestReplyMessenger" - RequestReplyMessenger для отправки сообщений.
        public ScsServiceClient(IScsServerClient serverClient, RequestReplyMessenger<IScsServerClient> requestReplyMessenger)
        {
            _serverClient = serverClient;
            _serverClient.Disconnected += Client_Disconnected;
            _requestReplyMessenger = requestReplyMessenger;
        }

        // Закрывает клиентское соединение.
        public void Disconnect()
        {
            _serverClient.Disconnect();
        }

        // Получает клиентский прокси-интерфейс, который обеспечивает удаленный вызов клиентских методов.
        public T GetClientProxy<T>() where T : class
        {
            _realProxy = new RemoteInvokeProxy<T, IScsServerClient>(_requestReplyMessenger);
            return (T)_realProxy.GetTransparentProxy();
        }

        // Обрабатывает событие отключения объекта _serverClient.
        private void Client_Disconnected(object sender, EventArgs e)
        {
            _requestReplyMessenger.Stop();
            OnDisconnected();
        }

        // Вызывает событие отключения.
        private void OnDisconnected()
        {
            var handler = Disconnected;
            if (handler != null)
            {
                handler(this, EventArgs.Empty);
            }
        }
    }
}
		
namespace oscs
{
    public class ServiceClient
    {
        public CsServiceClient dll_obj;
        private IScsServiceClient<IMyService> M_ServiceClient;
        public IMyService _proxy;
        private string guid = null;
        private string clientName;
        private oscs.Collection tag = new Collection();

        // Объект, который обрабатывает вызовы удаленных методов с сервера.
        // Он реализует контракт IMyClient.
        private MyClient _myClient;

        public ServiceClient(TcpEndPoint p1)
        {
            // Создайте MyClient для обработки удаленных вызовов методов сервером.
            _myClient = new MyClient();

            M_ServiceClient = ScsServiceClientBuilder.CreateClient<IMyService>(p1.M_TcpEndPoint, _myClient);
            _proxy = M_ServiceClient.ServiceProxy;
            M_ServiceClient.Connected += M_ServiceClient_Connected;
            M_ServiceClient.Disconnected += M_ServiceClient_Disconnected;
            Connected = "";
            Disconnected = "";
            Guid = System.Guid.NewGuid().ToString();
        }

        public string Guid
        {
            get { return guid; }
            set
            {
                if (guid == null)
                {
                    guid = value;
                }
            }
        }

        private void M_ServiceClient_Connected(object sender, System.EventArgs e)
        {
            try
            {
                // Передадим данные этого клиента клиенту на стороне сервера приложений.
                M_ServiceClient.ServiceProxy.AtClientEntrance(this.Guid, this.ClientName, this.Tag);
            }
            catch
            {
                Disconnect();
                System.Windows.Forms.MessageBox.Show("Не удается войти на сервер. Пожалуйста, попробуйте еще раз позже.");
            }

            if (dll_obj.Connected != null)
            {
                try
                {
                    dll_obj.Connected.CallAsProcedure(0, null);
                }
                catch { }
            }
        }

        private void M_ServiceClient_Disconnected(object sender, System.EventArgs e)
        {
            if (dll_obj.Disconnected != null)
            {
                try
                {
                    dll_obj.Disconnected.CallAsProcedure(0, null);
                }
                catch { }
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

        public IMyService Proxy
        {
            get { return _proxy; }
        }
		
        public string ClientName
        {
            get { return clientName; }
            set { clientName = value; }
        }
		
        public oscs.Collection Tag
        {
            get { return tag; }
            set { tag = value; }
        }
    }

    [ContextClass("КсПриложениеКлиент", "CsServiceClient")]
    public class CsServiceClient : AutoContext<CsServiceClient>
    {
        public dynamic resalt;

        public CsServiceClient(CsTcpEndPoint p1, IRuntimeContextInstance p2)
        {
            ServiceClient ServiceClient1 = new ServiceClient(p1.Base_obj);
            ServiceClient1.dll_obj = this;
            Base_obj = ServiceClient1;
            this.ChangedMethodName += CsServiceClient_ChangedMethodName;
            OneScriptClientServer.CurrentServiceClient = this;
            Script = p2;
        }

        private void CsServiceClient_ChangedMethodName(object sender, System.EventArgs e)
        {
            CsServiceClient sc = (CsServiceClient)sender;

            DelegateAction action = DelegateAction.Create(sc.Script, sc.MethodName);
            sc.resalt = "7b7540f9-27e6-4e4a-a0b1-8012ac6e5737";
            DoAtClientArgs DoAtClientArgs1 = new DoAtClientArgs(sc.MethodName, sc.ParametersArray);
            DoAtClientArgs1.EventAction = action;
            DoAtClientArgs1.Sender = this;
            CsDoAtClientArgs CsDoAtClientArgs1 = new CsDoAtClientArgs(DoAtClientArgs1);
            OneScriptClientServer.EventQueue.Enqueue(DoAtClientArgs1);

            sc.MethodName = null;
            sc.ParametersArray = null;

            while (sc.Resalt.AsString() == "7b7540f9-27e6-4e4a-a0b1-8012ac6e5737")
            {
                System.Threading.Thread.Sleep(17);
            }
        }

        public event System.EventHandler ChangedMethodName;
        protected void OnChangedMethodName()
        {
            if (ChangedMethodName != null)
            {
                ChangedMethodName(OneScriptClientServer.CurrentServiceClient, System.EventArgs.Empty);
            }
        }

        private object _lock = new object();
        private string methodName = null;
        public string MethodName
        {
            get
            {
                lock (_lock)
                {
                    return methodName;
                }
            }
            set
            {
                lock (_lock)
                {
                    methodName = value;
                    if (value != null)
                    {
                        OnChangedMethodName();
                    }
                }
            }
        }

        private object _lock2 = new object();
        private ArrayImpl parametersArray;
        public ArrayImpl ParametersArray
        {
            get
            {
                lock (_lock2)
                {
                    return parametersArray;
                }
            }
            set
            {
                lock (_lock2)
                {
                    parametersArray = value;
                }
            }
        }

        private IRuntimeContextInstance script = null;
        public IRuntimeContextInstance Script
        {
            get { return script; }
            set { script = value; }
        }

        public ServiceClient Base_obj;

        
        [ContextProperty("ГуидКлиента", "ClientGuid")]
        public string ClientGuid
        {
            get { return Base_obj.Guid; }
        }

        [ContextProperty("ИмяКлиента", "ClientName")]
        public string ClientName
        {
            get { return Base_obj.ClientName; }
            set { Base_obj.ClientName = value; }
        }

        [ContextProperty("Метка", "Tag")]
        public StructureImpl Tag
        {
            get
            {
                StructureImpl StructureImpl1 = new StructureImpl();
                oscs.Collection tag = Base_obj.Tag;
                foreach (KeyValuePair<string, object> DictionaryEntry in tag)
                {
                    if (DictionaryEntry.Value.GetType() == typeof(System.Byte[]))
                    {
                        StructureImpl1.Insert(DictionaryEntry.Key, new BinaryDataContext((System.Byte[])DictionaryEntry.Value));
                    }
                    else
                    {
                        StructureImpl1.Insert(DictionaryEntry.Key, ValueFactory.Create((dynamic)DictionaryEntry.Value));
                    }
                }
                return StructureImpl1;
            }
            set
            {
                oscs.Collection tag = Base_obj.Tag;
                foreach (KeyAndValueImpl item in value)
                {
                    if (item.Value.GetType() == typeof(ScriptEngine.Machine.Values.StringValue) ||
                        item.Value.GetType() == typeof(ScriptEngine.Machine.Values.NumberValue) ||
                        item.Value.GetType() == typeof(ScriptEngine.Machine.Values.BooleanValue) ||
                        item.Value.GetType() == typeof(ScriptEngine.Machine.Values.DateValue) ||
                        item.Value.GetType() == typeof(BinaryDataContext))
                    {
                        tag.Add(OneScriptClientServer.RedefineIValue(item.Key), OneScriptClientServer.RedefineIValue(item.Value));
                    }
                    else
                    {
                        tag.Add(OneScriptClientServer.RedefineIValue(item.Key), item.Value.GetType().ToString());
                    }
                }
            }
        }

        [ContextProperty("ПриОтключении", "Disconnected")]
        public DelegateAction Disconnected { get; set; }
        
        [ContextProperty("ПриПодключении", "Connected")]
        public DelegateAction Connected { get; set; }
        
        [ContextProperty("Результат", "Resalt")]
        public IValue Resalt
        {
            get
            {
                if (resalt.GetType() == typeof(System.Byte[]))
                {
                    return new BinaryDataContext(resalt);
                }
                return ValueFactory.Create(resalt);
            }
            set { resalt = OneScriptClientServer.RedefineIValue(value); }
        }
        
        [ContextProperty("СостояниеСоединения", "CommunicationState")]
        public int CommunicationState
        {
            get { return (int)Base_obj.CommunicationState; }
        }

        
        [ContextMethod("ВыполнитьНаКлиенте", "DoAtClient")]
        public IValue DoAtClient(string p1, string p2, ArrayImpl p3 = null)
        {
            if (Base_obj.CommunicationState == (int)CommunicationStates.Disconnected)
            {
                return null;
            }
				
            ArrayList array = new ArrayList();
            if (p3 != null)
            {
                array = new ArrayList();
                for (int i = 0; i < p3.Count(); i++)
                {
                    array.Add(OneScriptClientServer.RedefineIValue(p3.Get(i)));
                }
            }

            dynamic res = Base_obj.Proxy.DoAtClientWithResalt(this.ClientGuid, p1, p2, array);
            if (res.GetType() == typeof(System.Byte[]))
            {
                return new BinaryDataContext(res);
            }
            return ValueFactory.Create(res);
        }

        [ContextMethod("ВыполнитьНаСервере", "DoAtServer")]
        public IValue DoAtServer(string p1, ArrayImpl p2 = null)
        {
            if (Base_obj.CommunicationState == (int)CommunicationStates.Disconnected)
            {
                return null;
            }

            ArrayList array = new ArrayList();
            if (p2 != null)
            {
                array = new ArrayList();
                for (int i = 0; i < p2.Count(); i++)
                {
                    array.Add(OneScriptClientServer.RedefineIValue(p2.Get(i)));
                }
            }

            dynamic res = Base_obj.Proxy.DoAtServerWithResalt(p1, array);
            if (res.GetType() == typeof(System.Byte[]))
            {
                return new BinaryDataContext(res);
            }
            return ValueFactory.Create(res);
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



        //=======================================
        private object _lock3 = new object();
        [ContextMethod("ПолучитьИнформациюКлиентов", "GetClientsInfo")]
        public ArrayImpl GetClientsInfo()
        {
            //ArrayImpl arrayImpl = new ArrayImpl();
            //lock (_lock3)
            //{
            //    ClientInfo[] array = Base_obj.Proxy.GetClientsList();
            //    for (int i = 0; i < array.Length; i++)
            //    {
            //        ClientInfo ClientInfo1 = (ClientInfo)array[i];
            //        CsClientInfo CsClientInfo1 = new CsClientInfo(ClientInfo1.ClientGuid, ClientInfo1.ClientName, ClientInfo1.Tag);
            //        arrayImpl.Add(CsClientInfo1);
            //    }
            //}
            //return arrayImpl;



            ClientInfo[] array = Base_obj.Proxy.GetClientsList();
            ArrayImpl arrayImpl = new ArrayImpl();
            for (int i = 0; i < array.Length; i++)
            {
                ClientInfo ClientInfo1 = (ClientInfo)array[i];
                CsClientInfo CsClientInfo1 = new CsClientInfo(ClientInfo1.ClientGuid, ClientInfo1.ClientName, ClientInfo1.Tag);
                arrayImpl.Add(CsClientInfo1);
            }
            return arrayImpl;
        }

        //endMethods
    }
}
