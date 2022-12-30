using System;
using ScriptEngine.Machine.Contexts;
using ScriptEngine.Machine;

namespace oscs
{
    public class ServerClient
    {
        public CsServerClient dll_obj;
        public Hik.Communication.Scs.Server.IScsServerClient M_ServerClient;

        public ServerClient(Hik.Communication.Scs.Server.IScsServerClient p1)
        {
            M_ServerClient = p1;
            M_ServerClient.Disconnected += M_ServerClient_Disconnected;
            M_ServerClient.MessageReceived += M_ServerClient_MessageReceived;
            M_ServerClient.MessageSent += M_ServerClient_MessageSent;
            Disconnected = "";
            MessageReceived = "";
            MessageSent = "";
        }

        public decimal ClientId
        {
            get { return Convert.ToDecimal(M_ServerClient.ClientId); }
        }

        public int CommunicationState
        {
            get { return (int)M_ServerClient.CommunicationState; }
        }

        public string Disconnected { get; set; }

        public string MessageReceived { get; set; }

        public string MessageSent { get; set; }

        public oscs.TcpEndPoint RemoteEndPoint
        {
            get { return new TcpEndPoint(M_ServerClient.RemoteEndPoint); }
        }

        public void Disconnect()
        {
            M_ServerClient.Disconnect();
        }

        private void M_ServerClient_Disconnected(object sender, System.EventArgs e)
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

        private void M_ServerClient_MessageReceived(object sender, Hik.Communication.Scs.Communication.Messages.MessageEventArgs e)
        {
            if (dll_obj.MessageReceived != null)		
            {
                oscs.MessageEventArgs MessageEventArgs1 = new MessageEventArgs(e.Message);
                MessageEventArgs1.EventAction = dll_obj.MessageReceived;
                MessageEventArgs1.Sender = this;
                CsMessageEventArgs CsMessageEventArgs1 = new CsMessageEventArgs(MessageEventArgs1);
                OneScriptClientServer.EventQueue.Enqueue(MessageEventArgs1);
            }
        }

        private void M_ServerClient_MessageSent(object sender, Hik.Communication.Scs.Communication.Messages.MessageEventArgs e)
        {
            if (dll_obj.MessageSent != null)		
            {
                oscs.MessageEventArgs MessageEventArgs1 = new MessageEventArgs(e.Message);
                MessageEventArgs1.EventAction = dll_obj.MessageSent;
                MessageEventArgs1.Sender = this;
                CsMessageEventArgs CsMessageEventArgs1 = new CsMessageEventArgs(MessageEventArgs1);
                OneScriptClientServer.EventQueue.Enqueue(MessageEventArgs1);
            }
        }

        public void SendMessage(Hik.Communication.Scs.Communication.Messages.IScsMessage p1)
        {
            M_ServerClient.SendMessage(p1);
        }
    }

    [ContextClass ("КсСерверКлиент", "CsServerClient")]
    public class CsServerClient : AutoContext<CsServerClient>
    {
        public CsServerClient(Hik.Communication.Scs.Server.IScsServerClient p1)
        {
            oscs.ServerClient ServerClient1 = new oscs.ServerClient(p1);
            ServerClient1.dll_obj = this;
            Base_obj = ServerClient1;
        }
		
        public ScriptEngine.HostedScript.Library.DelegateAction MessageSent { get; set; }

        public ScriptEngine.HostedScript.Library.DelegateAction MessageReceived { get; set; }

        public oscs.ServerClient Base_obj;
        
        [ContextProperty("ИдентификаторКлиента", "ClientId")]
        public decimal ClientId
        {
            get { return Base_obj.ClientId; }
        }
        
        [ContextProperty("ПриОтключении", "Disconnected")]
        public ScriptEngine.HostedScript.Library.DelegateAction Disconnected { get; set; }
        
        [ContextProperty("СостояниеСоединения", "CommunicationState")]
        public int CommunicationState
        {
            get { return (int)Base_obj.CommunicationState; }
        }

        [ContextProperty("УдаленнаяКонечнаяТочка", "RemoteEndPoint")]
        public CsTcpEndPoint RemoteEndPoint
        {
            get { return (CsTcpEndPoint)OneScriptClientServer.RevertObj(Base_obj.RemoteEndPoint); }
        }
        
        [ContextMethod("Отключить", "Disconnect")]
        public void Disconnect()
        {
            Base_obj.Disconnect();
        }
					
        [ContextMethod("ОтправитьСообщение", "SendMessage")]
        public void SendMessage(IValue p1)
        {
            Base_obj.SendMessage(((dynamic)p1).Base_obj.M_Obj);
        }
    }
}
