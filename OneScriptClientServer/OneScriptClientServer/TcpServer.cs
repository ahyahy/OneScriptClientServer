using ScriptEngine.Machine.Contexts;
using ScriptEngine.HostedScript.Library;
using System.Collections.Generic;
using Hik.Communication.Scs.Server;
using Hik.Communication.Scs.Communication.EndPoints.Tcp;
using Hik.Communication.Scs.Communication.Channels;
using Hik.Communication.Scs.Communication.Channels.Tcp;
using ScriptEngine.Machine;

namespace Hik.Communication.Scs.Server.Tcp
{
    // Этот класс используется для создания TCP-сервера.
    internal class ScsTcpServer : ScsServerBase
    {
        // Адрес конечной точки сервера для прослушивания входящих подключений.
        private readonly ScsTcpEndPoint _endPoint;

        // Создает новый объект ScsTcpServer.
        // "endPoint" - Адрес конечной точки сервера для прослушивания входящих подключений
        public ScsTcpServer(ScsTcpEndPoint endPoint)
        {
            _endPoint = endPoint;
        }

        // Создает прослушиватель TCP-соединений.
        // Возврат - Созданный объект прослушивателя
        protected override IConnectionListener CreateConnectionListener()
        {
            return new TcpConnectionListener(_endPoint);
        }
    }
}
		
namespace oscs
{
    public class ScsServer
    {
        public CsTcpServer dll_obj;
        public IScsServer M_TcpServer;
        public string ClientConnected { get; set; }
        public string ClientDisconnected { get; set; }

        public ScsServer(int p1)
        {
            ScsTcpEndPoint ScsTcpEndPoint1 = new ScsTcpEndPoint(p1);
            M_TcpServer = ScsServerFactory.CreateServer(ScsTcpEndPoint1);
            M_TcpServer.ClientConnected += M_TcpServer_ClientConnected;
            M_TcpServer.ClientDisconnected += M_TcpServer_ClientDisconnected;
            ClientConnected = "";
            ClientDisconnected = "";
        }

        private void M_TcpServer_ClientDisconnected(object sender, Hik.Communication.Scs.Server.ServerClientEventArgs e)
        {
            if (dll_obj.ClientDisconnected != null)		
            {
                oscs.ServerClientEventArgs ServerClientEventArgs1 = new oscs.ServerClientEventArgs(e);
                ServerClientEventArgs1.EventAction = dll_obj.ClientDisconnected;
                ServerClientEventArgs1.Sender = this;
                ServerClientEventArgs1.Client = new CsServerClient(e.Client);
                CsServerClientEventArgs CsServerClientEventArgs1 = new CsServerClientEventArgs(ServerClientEventArgs1);
                OneScriptClientServer.EventQueue.Enqueue(ServerClientEventArgs1);
            }
        }

        private void M_TcpServer_ClientConnected(object sender, Hik.Communication.Scs.Server.ServerClientEventArgs e)
        {
            if (dll_obj.ClientConnected != null)		
            {
                oscs.ServerClientEventArgs ServerClientEventArgs1 = new oscs.ServerClientEventArgs(e);
                ServerClientEventArgs1.EventAction = dll_obj.ClientConnected;
                ServerClientEventArgs1.Sender = this;
                oscs.CsServerClient CsServerClient1 = new CsServerClient(e.Client);
                CsServerClient1.MessageReceived = OneScriptClientServer.ServerMessageReceived;
                CsServerClient1.MessageSent = OneScriptClientServer.ServerMessageSent;
                ServerClientEventArgs1.Client = CsServerClient1;
                CsServerClientEventArgs CsServerClientEventArgs1 = new CsServerClientEventArgs(ServerClientEventArgs1);
                OneScriptClientServer.EventQueue.Enqueue(ServerClientEventArgs1);
            }
        }

        public void Start()
        {
            M_TcpServer.Start();
        }

        public void Stop()
        {
            M_TcpServer.Stop();
        }
		
        public ArrayImpl Clients
        {
            get
            {
                List<IScsServerClient> list = M_TcpServer.Clients.GetAllItems();
                ArrayImpl arrayImpl = new ArrayImpl();
                for (int i = 0; i < list.Count; i++)
                {
                    arrayImpl.Add(new CsServerClient(list[i]));
                }
                return arrayImpl;
            }
        }
    }

    [ContextClass("КсTCPСервер", "CsTcpServer")]
    public class CsTcpServer : AutoContext<CsTcpServer>
    {
        public CsTcpServer(int p1)
        {
            ScsServer ScsServer1 = new ScsServer(p1);
            ScsServer1.dll_obj = this;
            Base_obj = ScsServer1;
        }

        public CsTcpServer(ScsServer p1)
        {
            Base_obj = p1;
        }

        public oscs.ScsServer Base_obj;

        
        [ContextProperty("Клиенты", "Clients")]
        public ArrayImpl Clients
        {
            get { return Base_obj.Clients; }
        }
        
        [ContextProperty("ПриОтключенииКлиента", "ClientDisconnected")]
        public IValue ClientDisconnected { get; set; }
        
        [ContextProperty("ПриОтправкеСообщения", "MessageSent")]
        public IValue MessageSent
        {
            get { return OneScriptClientServer.ServerMessageSent; }
            set { OneScriptClientServer.ServerMessageSent = value; }
        }
        
        [ContextProperty("ПриПодключенииКлиента", "ClientConnected")]
        public IValue ClientConnected { get; set; }
        
        [ContextProperty("ПриПолученииСообщения", "MessageReceived")]
        public IValue MessageReceived
        {
            get { return OneScriptClientServer.ServerMessageReceived; }
            set { OneScriptClientServer.ServerMessageReceived = value; }
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
