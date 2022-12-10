﻿using System;
using ScriptEngine.Machine.Contexts;
using ScriptEngine.Machine;

namespace Hik.Communication.Scs.Server
{
    // Хранит информацию о клиенте, которая будет использоваться событием.
    public class ServerClientEventArgs : EventArgs
    {
        // Клиент, связанный с этим событием.
        public IScsServerClient Client { get; private set; }

        // Создает новый объект ServerClientEventArgs.
        // "client" - Клиент, связанный с этим событием
        public ServerClientEventArgs(IScsServerClient client)
        {
            Client = client;
        }
    }
}

namespace oscs
{
    public class ServerClientEventArgs : oscs.EventArgs
    {
        public new CsServerClientEventArgs dll_obj;
        private Hik.Communication.Scs.Server.IScsServerClient client;

        public ServerClientEventArgs(Hik.Communication.Scs.Server.IScsServerClient p1)
        {
            client = p1;
        }

        public ServerClientEventArgs(Hik.Communication.Scs.Server.ServerClientEventArgs args)
        {
            client = args.Client;
        }

        public Hik.Communication.Scs.Server.IScsServerClient Client
        {
            get { return client; }
        }
    }

    [ContextClass("КсСерверКлиентАрг", "CsServerClientEventArgs")]
    public class CsServerClientEventArgs : AutoContext<CsServerClientEventArgs>
    {
        public CsServerClientEventArgs(oscs.ServerClientEventArgs p1)
        {
            ServerClientEventArgs ServerClientEventArgs1 = p1;
            ServerClientEventArgs1.dll_obj = this;
            Base_obj = ServerClientEventArgs1;
        }

        public oscs.ServerClientEventArgs Base_obj;

        
        [ContextProperty("Действие", "EventAction")]
        public ScriptEngine.HostedScript.Library.DelegateAction EventAction
        {
            get { return Base_obj.EventAction; }
            set { Base_obj.EventAction = value; }
        }
        
        [ContextProperty("Клиент", "Client")]
        public CsServerClient Client
        {
            get { return new CsServerClient(Base_obj.Client); }
        }
        
        [ContextProperty("Отправитель", "Sender")]
        public IValue Sender
        {
            get { return Base_obj.Sender.dll_obj; }
        }
        
        
        //endMethods
    }

}//endnamespace
