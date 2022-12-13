using System;
using ScriptEngine.Machine.Contexts;
using ScriptEngine.Machine;
using System.Reflection;

namespace oscs
{
    [ContextClass ("КлиентСерверДляОдноСкрипта", "OneScriptClientServer")]
    public class OneScriptClientServer : AutoContext<OneScriptClientServer>
    {
        private static CsCommunicationStates cs_CommunicationStates = new CsCommunicationStates();
        public static IValue Event = null;
        public static ScriptEngine.HostedScript.Library.DelegateAction EventAction = null;
        public static System.Collections.ArrayList EventQueue = new System.Collections.ArrayList();
        public static bool goOn = true;
        public static ScriptEngine.HostedScript.Library.DelegateAction ServerMessageReceived;
        public static ScriptEngine.HostedScript.Library.DelegateAction ServerMessageSent;

        [ScriptConstructor]
        public static IRuntimeContextInstance Constructor()
        {
            return new OneScriptClientServer();
        }

        public OneScriptClientServer Base_obj;
        
        [ContextProperty("АргументыСобытия", "EventArgs")]
        public IValue EventArgs
        {
            get { return Event; }
        }
        
        [ContextProperty("Отправитель", "Sender")]
        public IValue Sender
        {
            get { return OneScriptClientServer.RevertObj(((dynamic)Event).Base_obj.Sender); }
        }
        
        [ContextProperty("Продолжать", "GoOn")]
        public bool GoOn
        {
            get { return goOn; }
            set { goOn = value; }
        }

        [ContextProperty("СостояниеСоединения", "CommunicationStates")]
        public CsCommunicationStates CommunicationStates
        {
            get { return cs_CommunicationStates; }
        }
        
        [ContextMethod("TCPКлиент", "TcpClient")]
        public CsTcpClient TcpClient(CsTcpEndPoint p1)
        {
            return new CsTcpClient(p1);
        }

        [ContextMethod("TCPКонечнаяТочка", "TcpEndPoint")]
        public CsTcpEndPoint TcpEndPoint(string p1, int p2)
        {
            return new CsTcpEndPoint(p1, p2);
        }

        [ContextMethod("TCPСервер", "TcpServer")]
        public CsTcpServer TcpServer(int p1)
        {
            return new CsTcpServer(p1);
        }

        [ContextMethod("ПолучитьСобытие", "DoEvents")]
        public ScriptEngine.HostedScript.Library.DelegateAction DoEvents()
        {
            while (EventQueue.Count == 0)
            {
                System.Threading.Thread.Sleep(10);
            }
            return EventHandling();
        }

        public static ScriptEngine.HostedScript.Library.DelegateAction EventHandling()
        {
            dynamic EventArgs1 = (dynamic)EventQueue[0];
            Event = EventArgs1.dll_obj;
            EventAction = EventArgs1.EventAction;
            EventQueue.RemoveAt(0);
            return EventAction;
        }

        [ContextMethod("СообщениеБайты", "ByteMessage")]
        public CsByteMessage ByteMessage(ScriptEngine.HostedScript.Library.Binary.BinaryDataContext p1 = null)
        {
            return new CsByteMessage(p1);
        }

        [ContextMethod("СообщениеТекст", "TextMessage")]
        public CsTextMessage TextMessage(string p1)
        {
            return new CsTextMessage(p1);
        }

        [ContextMethod("СообщениеЧисло", "NumberMessage")]
        public CsNumberMessage NumberMessage(IValue p1 = null)
        {
            return new CsNumberMessage(p1);
        }

        [ContextMethod("СообщениеАрг", "MessageEventArgs")]
        public CsMessageEventArgs MessageEventArgs()
        {
        	return (CsMessageEventArgs)Event;
        }
        
        [ContextMethod("СерверКлиентАрг", "ServerClientEventArgs")]
        public CsServerClientEventArgs ServerClientEventArgs()
        {
        	return (CsServerClientEventArgs)Event;
        }
        
        public static IValue RevertObj(dynamic initialObject) 
        {
            //ScriptEngine.Machine.Values.NullValue NullValue1;
            //ScriptEngine.Machine.Values.BooleanValue BooleanValue1;
            //ScriptEngine.Machine.Values.DateValue DateValue1;
            //ScriptEngine.Machine.Values.NumberValue NumberValue1;
            //ScriptEngine.Machine.Values.StringValue StringValue1;

            //ScriptEngine.Machine.Values.GenericValue GenericValue1;
            //ScriptEngine.Machine.Values.TypeTypeValue TypeTypeValue1;
            //ScriptEngine.Machine.Values.UndefinedValue UndefinedValue1;

            try
            {
                if (initialObject == null)
                {
                    return (IValue)null;
                }
            }
            catch { }

            try
            {
                string str_initialObject = initialObject.GetType().ToString();
            }
            catch
            {
                return (IValue)null;
            }

            dynamic Obj1 = null;
            string str1 = initialObject.GetType().ToString();
            try
            {
                Obj1 = initialObject.dll_obj;
            }
            catch { }
            if (Obj1 != null)
            {
                return (IValue)Obj1;
            }

            try
            {
                Obj1 = initialObject.M_Object.dll_obj;
            }
            catch { }
            if (Obj1 != null)
            {
                return (IValue)Obj1;
            }

            try // если initialObject не из пространства имен oscs, то есть Уровень1
            {
                if (!str1.Contains("oscs."))
                {
                    string str2 = "oscs.Cs" + str1.Substring(str1.LastIndexOf(".") + 1);
                    System.Type TestType = System.Type.GetType(str2, false, true);
                    object[] args = { initialObject };
                    Obj1 = Activator.CreateInstance(TestType, args);
                }
            }
            catch { }
            if (Obj1 != null)
            {
                return (IValue)Obj1;
            }

            try // если initialObject из пространства имен oscs, то есть Уровень2
            {
                if (str1.Contains("oscs."))
                {
                    string str3 = str1.Replace("oscs.", "oscs.Cs");
                    System.Type TestType = System.Type.GetType(str3, false, true);
                    object[] args = { initialObject };
                    Obj1 = Activator.CreateInstance(TestType, args);
                }
            }
            catch { }
            if (Obj1 != null)
            {
                return (IValue)Obj1;
            }

            string str4 = null;
            try
            {
                str4 = initialObject.SystemType.Name;
            }
            catch
            {
                if ((str1 == "System.String") ||
                (str1 == "System.Decimal") ||
                (str1 == "System.Int32") ||
                (str1 == "System.Boolean") ||
                (str1 == "System.DateTime"))
                {
                    return (IValue)ValueFactory.Create(initialObject);
                }
                else if (str1 == "System.Byte")
                {
                    int vOut = Convert.ToInt32(initialObject);
                    return (IValue)ValueFactory.Create(vOut);
                }
                else if (str1 == "System.DBNull")
                {
                    string vOut = Convert.ToString(initialObject);
                    return (IValue)ValueFactory.Create(vOut);
                }
            }
			
            if (str4 == "Неопределено")
            {
                return (IValue)null;
            }
            if (str4 == "Булево")
            {
                return (IValue)initialObject;
            }
            if (str4 == "Дата")
            {
                return (IValue)initialObject;
            }
            if (str4 == "Число")
            {
                return (IValue)initialObject;
            }
            if (str4 == "Строка")
            {
                return (IValue)initialObject;
            }
            return (IValue)initialObject;
        }
			
        public static dynamic DefineTypeIValue(dynamic p1)
        {
            if (p1.GetType() == typeof(ScriptEngine.Machine.Values.StringValue))
            {
                return p1.AsString();
            }
            else if (p1.GetType() == typeof(ScriptEngine.Machine.Values.NumberValue))
            {
                return p1.AsNumber();
            }
            else if (p1.GetType() == typeof(ScriptEngine.Machine.Values.BooleanValue))
            {
                return p1.AsBoolean();
            }
            else if (p1.GetType() == typeof(ScriptEngine.Machine.Values.DateValue))
            {
                return p1.AsDate();
            }
            else
            {
                return p1;
            }
        }
    }
}
