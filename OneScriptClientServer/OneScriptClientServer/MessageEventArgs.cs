using System;
using ScriptEngine.Machine.Contexts;
using ScriptEngine.Machine;
using ScriptEngine.HostedScript.Library;
using Hik.Communication.Scs.Communication.Messages;

namespace Hik.Communication.Scs.Communication.Messages
{
    // Сохраняет сообщение, которое будет использоваться событием.
    public class MessageEventArgs : System.EventArgs
    {
        // Объект сообщение, связанный с этим событием.
        public IScsMessage Message { get; private set; }

        // Создает новый объект MessageEventArgs.
        // "message" - Объект сообщение, связанный с этим событием.
        public MessageEventArgs(IScsMessage message)
        {
            Message = message;
        }
    }
}

namespace oscs
{
    public class MessageEventArgs : oscs.EventArgs
    {
        public new CsMessageEventArgs dll_obj;
        private IScsMessage message;

        public MessageEventArgs(IScsMessage p1)
        {
            message = p1;
        }

        public MessageEventArgs(Hik.Communication.Scs.Communication.Messages.MessageEventArgs args)
        {
            message = args.Message;
        }

        public dynamic Message
        {
            get
            {
                dynamic Obj1 = null;
                string str1 = message.GetType().ToString();
                string str2 = "oscs." + (str1.Substring(str1.LastIndexOf(".") + 1).Replace("Scs", "").Replace("RawDataMessage", "ByteMessage"));
                System.Type TestType = System.Type.GetType(str2, false, true);
                object[] args = { message };
                Obj1 = Activator.CreateInstance(TestType, args);
                return Obj1;
            }
        }
    }

    [ContextClass("КсСообщениеАрг", "CsMessageEventArgs")]
    public class CsMessageEventArgs : AutoContext<CsMessageEventArgs>
    {
        public CsMessageEventArgs(oscs.MessageEventArgs p1)
        {
            oscs.MessageEventArgs MessageEventArgs1 = p1;
            MessageEventArgs1.dll_obj = this;
            Base_obj = MessageEventArgs1;
        }

        public oscs.MessageEventArgs Base_obj;

        
        [ContextProperty("Действие", "EventAction")]
        public IValue EventAction
        {
            get { return Base_obj.EventAction; }
            set { Base_obj.EventAction = value; }
        }
        
        [ContextProperty("Отправитель", "Sender")]
        public IValue Sender
        {
            get { return Base_obj.Sender.dll_obj; }
        }
        
        [ContextProperty("Сообщение", "Message")]
        public IValue Message
        {
            get
            {
                dynamic Obj1 = null;
                string str1 = Base_obj.Message.GetType().ToString();
                string str2 = "oscs.Cs" + str1.Substring(str1.LastIndexOf(".") + 1);
                System.Type TestType = System.Type.GetType(str2, false, true);
                object[] args = { Base_obj.Message };
                Obj1 = Activator.CreateInstance(TestType, args);
                return Obj1;
            }
        }
        
        
        //endMethods
    }
}
