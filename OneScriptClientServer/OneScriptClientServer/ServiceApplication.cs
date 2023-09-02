using System;
using Hik.Communication.Scs.Communication.EndPoints.Tcp;
using Hik.Communication.ScsServices.Service;
using ScriptEngine.Machine.Contexts;
using ScriptEngine.Machine;
using ScriptEngine.HostedScript.Library;
using ScriptEngine.HostedScript.Library.Binary;
using System.Reflection;
using System.Collections;
using System.Collections.Generic;
using Hik.Communication.ScsServices.Communication.Messages;
using Hik.Communication.Scs.Server;
using Hik.Communication.Scs.Communication.Messengers;
using Hik.Communication.Scs.Communication.Messages;
using Hik.Collections;
using Hik.Communication.Scs.Communication;

namespace Hik.Communication.ScsServices.Service
{
    // Реализует IScsServiceApplication и обеспечивает всю функциональность.
    internal class ScsServiceApplication : IScsServiceApplication
    {
        // Это событие возникает, когда новый клиент подключается к сервису.
        public event EventHandler<ServiceClientEventArgs> ClientConnected;

        // Это событие возникает, когда клиент отключается от службы.
        public event EventHandler<ServiceClientEventArgs> ClientDisconnected;

        // Базовый объект IScsServer для приема клиентских подключений и управления ими.
        private readonly IScsServer _scsServer;

        // Объекты пользовательского сервиса, которые используются для вызова входящих запросов на вызов метода.
        // Key: Имя типа интерфейса службы.
        // Value: Объект обслуживания.
        private readonly ThreadSafeSortedList<string, ServiceObject> _serviceObjects;

        // Все подключенные клиенты к сервису.
        // Key: Уникальный идентификатор клиента Id.
        // Value: Ссылка на клиента.
        private readonly ThreadSafeSortedList<long, IScsServiceClient> _serviceClients;

        // Создает новый объект ScsServiceApplication.
        // "scsServer" - Базовый объект IScsServer для приема клиентских подключений и управления ими.
        // Исключение - "ArgumentNullException" - Выдает исключение ArgumentNullException, если аргумент scsServer равен null
        public ScsServiceApplication(IScsServer scsServer)
        {
            if (scsServer == null)
            {
                throw new ArgumentNullException("scsServer");
            }

            _scsServer = scsServer;
            _scsServer.ClientConnected += ScsServer_ClientConnected;
            _scsServer.ClientDisconnected += ScsServer_ClientDisconnected;
            _serviceObjects = new ThreadSafeSortedList<string, ServiceObject>();
            _serviceClients = new ThreadSafeSortedList<long, IScsServiceClient>();
        }
		
        public ThreadSafeSortedList<long, IScsServiceClient> Clients
        {
            get { return _serviceClients; }
        }

        // Запускает сервисное приложение.
        public void Start()
        {
            _scsServer.Start();
        }

        // Останавливает сервисное приложение.
        public void Stop()
        {
            _scsServer.Stop();
        }

        // Добавляет объект службы в это приложение-службу.
        // Для типа интерфейса службы может быть добавлен только один объект службы.
        // "TServiceInterface" - Тип сервисного интерфейса
        // "TServiceClass" - Тип класса обслуживания. Должен быть доставлен из ScsService и должен реализовывать TServiceInterface.
        // "service" - Экземпляр TServiceClass.
        // Исключение - "ArgumentNullException" - Выдает исключение ArgumentNullException, если аргумент службы равен null
        // Исключение - "Exception" - Выдает исключение, если служба уже добавлена ранее
        public void AddService<TServiceInterface, TServiceClass>(TServiceClass service)
            where TServiceClass : ScsService, TServiceInterface
            where TServiceInterface : class
        {
            if (service == null)
            {
                throw new ArgumentNullException("service");
            }

            var type = typeof(TServiceInterface);
            if (_serviceObjects[type.Name] != null)
            {
                throw new Exception("Service '" + type.Name + "' is already added before.");
            }

            _serviceObjects[type.Name] = new ServiceObject(type, service);
        }

        // Удаляет ранее добавленный объект службы из этого приложения-службы.
        // Он удаляет объект в соответствии с типом интерфейса.
        // "TServiceInterface">Service interface type</typeparam>
        // Возврат - True: удален. False: нет объекта обслуживания с этим интерфейсом
        public bool RemoveService<TServiceInterface>()
            where TServiceInterface : class
        {
            return _serviceObjects.Remove(typeof(TServiceInterface).Name);
        }

        // Обрабатывает событие ClientConnected объекта _scsServer.
        // "sender" - Источник события.
        // "e" - Аргументы события.
        private void ScsServer_ClientConnected(object sender, ServerClientEventArgs e)
        {
            var requestReplyMessenger = new RequestReplyMessenger<IScsServerClient>(e.Client);
            requestReplyMessenger.MessageReceived += Client_MessageReceived;
            requestReplyMessenger.Start();

            var serviceClient = ScsServiceClientFactory.CreateServiceClient(e.Client, requestReplyMessenger);
            _serviceClients[serviceClient.ClientId] = serviceClient;

            // Вызывать событие ClientConnected будем не здесь.
            // OnClientConnected(serviceClient);
        }

        // Обрабатывает событие ClientDisconnected объекта _scsServer.
        // "sender" - Источник события.
        // "e" - Аргументы события.
        private void ScsServer_ClientDisconnected(object sender, ServerClientEventArgs e)
        {
            var serviceClient = _serviceClients[e.Client.ClientId];
            if (serviceClient == null)
            {
                return;
            }

            _serviceClients.Remove(e.Client.ClientId);
            OnClientDisconnected(serviceClient);
        }

        // Обрабатывает события MessageReceived всех клиентов, оценивает каждое сообщение, находит соответствующий объект службы и вызывает соответствующий метод.
        // "sender" - Источник события.
        // "e" - Аргументы события.
        private void Client_MessageReceived(object sender, MessageEventArgs e)
        {
            // Получить объект RequestReplyMessenger (отправитель события) для получения клиента.
            var requestReplyMessenger = (RequestReplyMessenger<IScsServerClient>)sender;

            // Отправьте сообщение в ScsRemoteInvokeMessage и проверьте его.
            var invokeMessage = e.Message as ScsRemoteInvokeMessage;
            if (invokeMessage == null)
            {
                return;
            }

            try
            {
                // Получить объект клиента.
                var client = _serviceClients[requestReplyMessenger.Messenger.ClientId];
                if (client == null)
                {
                    requestReplyMessenger.Messenger.Disconnect();
                    return;
                }

                // Получить объект обслуживания.
                var serviceObject = _serviceObjects[invokeMessage.ServiceClassName];
                if (serviceObject == null)
                {
                    SendInvokeResponse(requestReplyMessenger, invokeMessage, null, new ScsRemoteException("There is no service with name '" + invokeMessage.ServiceClassName + "'"));
                    return;
                }

                // Метод вызова.
                try
                {
                    object returnValue;
                    // Установите для клиента значение service, чтобы пользовательская служба могла получить client
                    // в сервисном методе, использующем свойство CurrentClient.
                    serviceObject.Service.CurrentClient = client;
                    try
                    {
                        string str1 = "";
                        for (int i = 0; i < invokeMessage.Parameters.Length; i++)
                        {
                            str1 = str1 + invokeMessage.Parameters[i] + System.Environment.NewLine;
                        }

                        returnValue = serviceObject.InvokeMethod(invokeMessage.MethodName, invokeMessage.Parameters);

                        if (invokeMessage.MethodName == "AtClientEntrance")
                        {
                            // А теперь вызовем событие ClientConnected.
                            OnClientConnected(client);
                        }
                    }
                    finally
                    {
                        // Установите CurrentClient равным null с момента завершения вызова метода.
                        serviceObject.Service.CurrentClient = null;
                    }

                    // Отправить вызов метода, возвращающий значение клиенту.
                    SendInvokeResponse(requestReplyMessenger, invokeMessage, returnValue, null);
                }
                catch (TargetInvocationException ex)
                {
                    var innerEx = ex.InnerException;
                    SendInvokeResponse(requestReplyMessenger, invokeMessage, null, new ScsRemoteException(innerEx.Message + Environment.NewLine + "1Service Version: " + serviceObject.ServiceAttribute.Version, innerEx));
                    return;
                }
                catch (Exception ex)
                {
                    SendInvokeResponse(requestReplyMessenger, invokeMessage, null, new ScsRemoteException(ex.Message + Environment.NewLine + "2Service Version: " + serviceObject.ServiceAttribute.Version, ex));
                    return;
                }
            }
            catch (Exception ex)
            {
                SendInvokeResponse(requestReplyMessenger, invokeMessage, null, new ScsRemoteException("An error occured during remote service method call.", ex));
                return;
            }
        }

        // Отправляет ответ удаленному приложению, которое вызвало метод службы.
        // "client" - Клиент, отправивший сообщение invoke.
        // "requestMessage" - Сообщение с запросом.
        // "returnValue" - Возвращаемое значение для отправки.
        // "exception" - Исключение для отправки.
        private static void SendInvokeResponse(IMessenger client, IScsMessage requestMessage, object returnValue, ScsRemoteException exception)
        {
            try
            {
                client.SendMessage(
                    new ScsRemoteInvokeReturnMessage
                    {
                        RepliedMessageId = requestMessage.MessageId,
                        ReturnValue = returnValue,
                        RemoteException = exception
                    });
            }
            catch { }
        }

        // Вызывает событие, связанное с клиентом.
        private void OnClientConnected(IScsServiceClient client)
        {
            var handler = ClientConnected;
            if (handler != null)
            {
                handler(this, new ServiceClientEventArgs(client));
            }
        }

        // Вызывает событие ClientDisconnected.
        private void OnClientDisconnected(IScsServiceClient client)
        {
            var handler = ClientDisconnected;
            if (handler != null)
            {
                handler(this, new ServiceClientEventArgs(client));
            }
        }

        // Представляет объект пользовательского сервиса.
        // Он используется для вызова методов объекта ScsService.
        private sealed class ServiceObject
        {
            // Объект службы, который используется для вызова методов.
            public ScsService Service { get; private set; }

            // Атрибут ScsService класса объекта Service.
            public ScsServiceAttribute ServiceAttribute { get; private set; }

            // В этой коллекции хранится список всех методов объекта service.
            // Key: Имя метода
            // Value: Информация о методе. 
            private readonly SortedList<string, System.Reflection.MethodInfo> _methods;

            // Создает новый ServiceObject.
            // "serviceInterfaceType" - Тип интерфейса сервиса.
            // "service" - Объект службы, который используется для вызова методов на.
            public ServiceObject(Type serviceInterfaceType, ScsService service)
            {
                Service = service;
                var classAttributes = serviceInterfaceType.GetCustomAttributes(typeof(ScsServiceAttribute), true);
                if (classAttributes.Length <= 0)
                {
                    throw new Exception("Service interface (" + serviceInterfaceType.Name + ") must has ScsService attribute.");
                }

                ServiceAttribute = classAttributes[0] as ScsServiceAttribute;
                _methods = new SortedList<string, System.Reflection.MethodInfo>();
                foreach (var methodInfo in serviceInterfaceType.GetMethods())
                {
                    _methods.Add(methodInfo.Name, methodInfo);
                }
            }

            // Вызывает метод объекта Service.
            // "methodName" - Имя метода для вызова.
            // "parameters" - Параметры метода.
            // Возврат - Возвращаемое значение метода.
            public object InvokeMethod(string methodName, params object[] parameters)
            {
                // Проверьте, существует ли метод с именем methodName.
                if (!_methods.ContainsKey(methodName))
                {
                    throw new Exception("There is not a method with name '" + methodName + "' in service class.");
                }

                // Метод получения.
                var method = _methods[methodName];

                // Вызвать метод и вернуть результат вызова.
                return method.Invoke(Service, parameters);
            }
        }
    }
}

namespace oscs
{
    public class ServiceApplication
    {
        public CsServiceApplication dll_obj;
        private IScsServiceApplication M_ServiceApplication;
        public string ClientConnected { get; set; }
        public string ClientDisconnected { get; set; }
        private MyService _proxy;

        public ServiceApplication(ScsTcpEndPoint p1)
        {
            // Создайте приложение-службу, которое работает на TCP-порту.
            M_ServiceApplication = ScsServiceBuilder.CreateService(p1);

            // Создайте MyService и добавьте его в сервисное приложение.
            _proxy = new MyService();
            M_ServiceApplication.AddService<IMyService, MyService>(_proxy);

            M_ServiceApplication.ClientConnected += M_ServiceApplication_ClientConnected;
            M_ServiceApplication.ClientDisconnected += M_ServiceApplication_ClientDisconnected;
            ClientConnected = "";
            ClientDisconnected = "";
        }

        private void M_ServiceApplication_ClientDisconnected(object sender, Hik.Communication.ScsServices.Service.ServiceClientEventArgs e)
        {
            if (dll_obj.ClientDisconnected != null)
            {
                oscs.ServiceClientEventArgs ServiceClientEventArgs1 = new oscs.ServiceClientEventArgs(e.Client);
                ServiceClientEventArgs1.EventAction = dll_obj.ClientDisconnected;
                ServiceClientEventArgs1.Sender = this;
                ServiceClientEventArgs1.ServiceApplicationClient = e.Client.dll_obj;
                CsServiceClientEventArgs CsServiceClientEventArgs1 = new CsServiceClientEventArgs(ServiceClientEventArgs1);
                OneScriptClientServer.EventQueue.Enqueue(ServiceClientEventArgs1);
            }
        }

        private void M_ServiceApplication_ClientConnected(object sender, Hik.Communication.ScsServices.Service.ServiceClientEventArgs e)
        {
            if (dll_obj.ClientConnected != null)
            {
                oscs.ServiceClientEventArgs ServiceClientEventArgs1 = new oscs.ServiceClientEventArgs(e.Client);
                ServiceClientEventArgs1.EventAction = dll_obj.ClientConnected;
                ServiceClientEventArgs1.Sender = this;
                ServiceClientEventArgs1.ServiceApplicationClient = e.Client.dll_obj;
                CsServiceClientEventArgs CsServiceClientEventArgs1 = new CsServiceClientEventArgs(ServiceClientEventArgs1);
                OneScriptClientServer.EventQueue.Enqueue(ServiceClientEventArgs1);
            }
        }

        public void Start()
        {
            M_ServiceApplication.Start();
        }

        public void Stop()
        {
            M_ServiceApplication.Stop();
        }
		
        public MyService Proxy
        {
            get { return _proxy; }
        }
		
        public ArrayImpl Clients
        {
            get
            {
                List<IScsServiceClient> list = M_ServiceApplication.Clients.GetAllItems();
                ArrayImpl arrayImpl = new ArrayImpl();
                for (int i = 0; i < list.Count; i++)
                {
                    arrayImpl.Add(list[i].dll_obj);
                }
                return arrayImpl;
            }
        }
    }

    [ContextClass("КсПриложениеСервис", "CsServiceApplication")]
    public class CsServiceApplication : AutoContext<CsServiceApplication>
    {
        public dynamic resalt;

        public CsServiceApplication(int p1, IRuntimeContextInstance p2)
        {
            ScsTcpEndPoint ScsTcpEndPoint1 = new ScsTcpEndPoint(p1);
            ServiceApplication ServiceApplication1 = new ServiceApplication(ScsTcpEndPoint1);
            ServiceApplication1.dll_obj = this;
            Base_obj = ServiceApplication1;
            this.ChangedMethodName += CsServiceApplication_ChangedMethodName;
            OneScriptClientServer.CurrentServiceApplication = this;
            Script = p2;
        }
		
        private object _lock = new object();
        private void CsServiceApplication_ChangedMethodName(object sender, System.EventArgs e)
        {
            lock (_lock)
            {
                DelegateAction action = DelegateAction.Create(OneScriptClientServer.CurrentServiceApplication.Script, OneScriptClientServer.CurrentServiceApplication.MethodName);
                OneScriptClientServer.CurrentServiceApplication.resalt = "92b55f72-41f9-4b03-8d64-01c7bd10325f";
                oscs.DoAtServerArgs DoAtServerArgs1 = new DoAtServerArgs(OneScriptClientServer.CurrentServiceApplication.MethodName, OneScriptClientServer.CurrentServiceApplication.ParametersArray);
                DoAtServerArgs1.EventAction = action;
                DoAtServerArgs1.Sender = this;
                CsDoAtServerArgs CsDoAtServerArgs1 = new CsDoAtServerArgs(DoAtServerArgs1);
                OneScriptClientServer.EventQueue.Enqueue(DoAtServerArgs1);

                OneScriptClientServer.CurrentServiceApplication.MethodName = null;
                OneScriptClientServer.CurrentServiceApplication.ParametersArray = null;
            }
        }

        public event System.EventHandler ChangedMethodName;
        protected void OnChangedMethodName()
        {
            if (ChangedMethodName != null)
            {
                ChangedMethodName(OneScriptClientServer.CurrentServiceApplication, System.EventArgs.Empty);
            }
        }

        private string methodName = null;
        public string MethodName
        {
            get { return methodName; }
            set
            {
                methodName = value;
                if (value != null)
                {
                    OnChangedMethodName();
                }
            }
        }

        private ArrayImpl parametersArray;
        public ArrayImpl ParametersArray
        {
            get { return parametersArray; }
            set { parametersArray = value; }
        }

        private IRuntimeContextInstance script = null;
        public IRuntimeContextInstance Script
        {
            get { return script; }
            set { script = value; }
        }

        public ServiceApplication Base_obj;

        
        [ContextProperty("Клиенты", "Clients")]
        public ArrayImpl Clients
        {
            get { return Base_obj.Proxy.Clients; }
        }
        
        [ContextProperty("ПриОтключенииКлиента", "ClientDisconnected")]
        public IValue ClientDisconnected { get; set; }
        
        [ContextProperty("ПриПодключенииКлиента", "ClientConnected")]
        public IValue ClientConnected { get; set; }
        
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
        
        
        [ContextMethod("ВыполнитьНаКлиенте", "DoAtClient")]
        public IValue DoAtClient(string p1, string p2, ArrayImpl p3 = null)
        {
            ArrayImpl ArrayImpl1 = Base_obj.Proxy.Clients;

            foreach (CsServiceApplicationClient item in ArrayImpl1)
            {
                if (item.CommunicationState == (int)CommunicationStates.Disconnected)
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

                dynamic res = item.ClientProxy.DoAtClientWithResalt(p1, p2, array);
                if (res.GetType() == typeof(System.Byte[]))
                {
                    return new BinaryDataContext(res);
                }
                return ValueFactory.Create(res);
            }
            return null;
        }

        [ContextMethod("Начать", "Start")]
        public void Start()
        {
            Base_obj.Start();
        }
					
        [ContextMethod("Остановить", "Stop")]
        public void Stop()
        {
            Base_obj.Stop();
        }
    }
}
