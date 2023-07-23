using Hik.Communication.ScsServices.Service;
using ScriptEngine.Machine;
using ScriptEngine.HostedScript.Library.Binary;
using System.Collections.Generic;
using ScriptEngine.HostedScript.Library;
using Hik.Communication.Scs.Communication;
using System.Collections;
using Hik.Collections;

namespace oscs
{
    public class MyService : ScsService, IMyService
    {
        private object _lock = new object();
        private object _lock2 = new object();

        // Список всех подключенных клиентов.
        private readonly ThreadSafeSortedList<long, MyClient> _clients;

        // Конструктор.
        public MyService()
        {
            _clients = new ThreadSafeSortedList<long, MyClient>();
        }
		
        public ClientInfo[] GetClientsList()
        {
            List<MyClient> list = _clients.GetAllItems();
            ClientInfo[] array = new ClientInfo[list.Count];
            for (int i = 0; i < list.Count; i++)
            {
                MyClient item = list[i];
                ClientInfo ClientInfo1 = new ClientInfo(item.Guid, item.ClientName, item.Tag);
                array[i] = ClientInfo1;
            }
            return array;
        }

        public dynamic DoAtClientWithResalt(string senderClientGuid, string clientGuid, string methodName, ArrayList parametersArray = null)
        {
            ArrayImpl ArrayImpl1 = this.Clients;

            foreach (CsServiceApplicationClient item in ArrayImpl1)
            {
                if (item.CommunicationState != (int)CommunicationStates.Disconnected)
                {
                    if (senderClientGuid == item.ClientGuid)
                    {
                        continue;
                    }

                    if (clientGuid == item.ClientGuid)
                    {
                        return item.ClientProxy.DoAtClientWithResaltFromServer(item.ClientGuid, methodName, parametersArray);
                    }
                }
            }
            return null;
        }

        public dynamic DoAtServerWithResalt(string methodName, ArrayList parametersArray = null)
        {
            ArrayImpl arrayImpl = null;
            if (parametersArray != null)
            {
                arrayImpl = new ArrayImpl();
                for (int i = 0; i < parametersArray.Count; i++)
                {
                    dynamic val = (dynamic)parametersArray[i];
                    if (val.GetType() == typeof(System.Byte[]))
                    {
                        var binaryDataContext = new BinaryDataContext(val);
                        arrayImpl.Add(binaryDataContext);
                    }
                    else
                    {
                        IValue ival = ValueFactory.Create(val);
                        arrayImpl.Add(ival);
                    }
                }
            }

            lock (_lock2)
            {
                OneScriptClientServer.CurrentServiceApplication.ParametersArray = arrayImpl;
                OneScriptClientServer.CurrentServiceApplication.MethodName = methodName;

                while (OneScriptClientServer.CurrentServiceApplication.resalt.ToString() == "92b55f72-41f9-4b03-8d64-01c7bd10325f")
                {
                    System.Threading.Thread.Sleep(17);
                }
            }

            return OneScriptClientServer.RedefineIValue(OneScriptClientServer.CurrentServiceApplication.Resalt);
        }

        public override string ToString()
        {
            return base.ToString();
        }

        public ArrayImpl Clients
        {
            get
            {
                List<MyClient> list = _clients.GetAllItems();
                ArrayImpl arrayImpl = new ArrayImpl();
                for (int i = 0; i < list.Count; i++)
                {
                    arrayImpl.Add(list[i].Client.dll_obj);
                }
                return arrayImpl;
            }
        }

        // Используется при подключении клиента.
        public void AtClientEntrance(string guid, string clientName, oscs.Collection tag)
        {
            // Получите ссылку на текущего клиента, который вызывает этот метод.
            var client = CurrentClient;

            // Получите прокси-объект для вызова методов клиента.
            var clientProxy = client.GetClientProxy<IMyClient>();

            CsServiceApplicationClient CsServiceApplicationClient1 = new CsServiceApplicationClient(client);
            client.dll_obj = CsServiceApplicationClient1;
            CsServiceApplicationClient1.clientGuid = guid;
            CsServiceApplicationClient1.ClientProxy = clientProxy;

            // Создайте клиента и сохраните его в коллекции.
            var myClient = new MyClient(client, clientProxy, guid, clientName, tag);
            _clients[client.ClientId] = myClient;

            // Зарегистрируйтесь на событие Disconnected, чтобы узнать, когда пользовательское соединение закрыто.
            client.Disconnected += Client_Disconnected;
        }

        // Обрабатывает событие отключения всех клиентов.
        private void Client_Disconnected(object sender, System.EventArgs e)
        {
            // Получить объект клиента.
            var client = (IScsServiceClient)sender;

            // Выполните выход из системы. Таким образом, если клиент не вызывал метод выхода перед закрытием, мы выполняем выход автоматически.
            AtClientExit(client.ClientId);
        }

        // Используется для выхода клиента.
        // Клиент может не вызывать этот метод при выходе из системы (в случае сбоя приложения),
        // он также будет автоматически отключен при сбое соединения между клиентом и сервером.
        public void AtClientExit(long clientId)
        {
            // Получить клиента из списка клиентов, если его нет в списке, не продолжать.
            var client = _clients[clientId];
            if (client == null)
            {
                return;
            }

            // Удалить клиента из списка клиентов.
            _clients.Remove(client.Client.ClientId);

            // Отменить регистрацию на событие отключения (на самом деле не требуется).
            client.Client.Disconnected -= Client_Disconnected;
        }

        // Этот класс используется для хранения информации для подключенного клиента.
        public sealed class MyClient
        {
            // Ссылка на клиента Scs.
            public IScsServiceClient Client { get; private set; }

            // Прокси-объект для вызова удаленных методов клиента приложения.
            public IMyClient ClientProxy { get; private set; }

            // Уникальный идентификатор клиента приложения.
            public string Guid { get; private set; }

            // Имя клиента приложения.
            public string ClientName { get; private set; }

            // Дополнительные данные.
            public oscs.Collection Tag { get; private set; }

            // Создает новый объект MyClient.
            public MyClient(IScsServiceClient client, IMyClient clientProxy, string guid, string clientName, oscs.Collection tag)
            {
                Client = client;
                ClientProxy = clientProxy;
                Guid = guid;
                ClientName = clientName;
                Tag = tag;
            }
        }
    }
}
