using ScriptEngine.Machine.Contexts;

namespace oscs
{
    public class PingMessage
    {
        public CsPingMessage dll_obj;
        public Hik.Communication.Scs.Communication.Messages.ScsPingMessage M_PingMessage;

        public PingMessage()
        {
            M_PingMessage = new Hik.Communication.Scs.Communication.Messages.ScsPingMessage();
        }

        public PingMessage(Hik.Communication.Scs.Communication.Messages.ScsPingMessage p1)
        {
            M_PingMessage = p1;
        }

        public Hik.Communication.Scs.Communication.Messages.ScsPingMessage M_Obj
        {
            get { return M_PingMessage; }
        }

        public string MessageId
        {
            get { return M_PingMessage.MessageId; }
        }

        public string RepliedMessageId
        {
            get { return M_PingMessage.RepliedMessageId; }
        }
    }

    [ContextClass ("КсСообщениеПинг", "CsPingMessage")]
    public class CsPingMessage : AutoContext<CsPingMessage>
    {
        public CsPingMessage()
        {
            PingMessage PingMessage1 = new PingMessage();
            PingMessage1.dll_obj = this;
            Base_obj = PingMessage1;
        }
		
        public CsPingMessage(PingMessage p1)
        {
            PingMessage PingMessage1 = p1;
            PingMessage1.dll_obj = this;
            Base_obj = PingMessage1;
        }
        
        public PingMessage Base_obj;
        
        [ContextProperty("Идентификатор", "MessageId")]
        public string MessageId
        {
            get { return Base_obj.MessageId; }
        }

        [ContextProperty("ИдентификаторОтвета", "RepliedMessageId")]
        public string RepliedMessageId
        {
            get { return Base_obj.RepliedMessageId; }
        }
        
    }
}
