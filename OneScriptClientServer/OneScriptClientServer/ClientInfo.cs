using System;
using ScriptEngine.Machine;
using ScriptEngine.Machine.Contexts;
using ScriptEngine.HostedScript.Library;
using ScriptEngine.HostedScript.Library.Binary;
using System.Collections.Generic;

namespace oscs
{
    [Serializable]
    public class ClientInfo
    {
        public string ClientGuid { get; set; }
        public string ClientName { get; set; }
        public oscs.Collection Tag { get; set; }

        public ClientInfo(string p1, string p2, oscs.Collection p3)
        {
            ClientGuid = p1;
            ClientName = p2;
            Tag = p3;
        }
    }

    [ContextClass("КсИнформацияКлиента", "CsClientInfo")]
    public class CsClientInfo : AutoContext<CsClientInfo>
    {
        private oscs.Collection tag;

        public CsClientInfo(string clientGuid, string clientName, oscs.Collection collection)
        {
            ClientInfo ClientInfo1 = new ClientInfo(clientGuid, clientName, collection);
            ClientGuid = clientGuid;
            ClientName = clientName;
            tag = new oscs.Collection(collection);
        }
        
        [ContextProperty("ГуидКлиента", "ClientGuid")]
        public string ClientGuid { get; set; }

        [ContextProperty("ИмяКлиента", "ClientName")]
        public string ClientName { get; set; }

        [ContextProperty("Метка", "Tag")]
        public StructureImpl Tag
        {
            get
            {
                StructureImpl StructureImpl1 = new StructureImpl();
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
        }
    }
}
