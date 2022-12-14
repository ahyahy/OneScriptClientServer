using ScriptEngine.Machine.Contexts;

namespace oscs
{
    public class BoolMessage
    {
        public CsBoolMessage dll_obj;
        public Hik.Communication.Scs.Communication.Messages.ScsBoolMessage M_BoolMessage;

        public BoolMessage()
        {
            M_BoolMessage = new Hik.Communication.Scs.Communication.Messages.ScsBoolMessage();
        }

        public BoolMessage(Hik.Communication.Scs.Communication.Messages.ScsBoolMessage p1)
        {
            M_BoolMessage = p1;
        }

        public BoolMessage(System.Boolean p1)
        {
            M_BoolMessage = new Hik.Communication.Scs.Communication.Messages.ScsBoolMessage(p1);
        }

        public System.Boolean BoolVal
        {
            get { return M_BoolMessage.BoolVal; }
            set { M_BoolMessage.BoolVal = value; }
        }

        public Hik.Communication.Scs.Communication.Messages.ScsBoolMessage M_Obj
        {
            get { return M_BoolMessage; }
        }

        public string MessageId
        {
            get { return M_BoolMessage.MessageId; }
        }

        public string RepliedMessageId
        {
            get { return M_BoolMessage.RepliedMessageId; }
        }
    }

    [ContextClass ("КсСообщениеБулево", "CsBoolMessage")]
    public class CsBoolMessage : AutoContext<CsBoolMessage>
    {
        public CsBoolMessage(System.Boolean p1)
        {
            BoolMessage BoolMessage1 = new BoolMessage(p1);
            BoolMessage1.dll_obj = this;
            Base_obj = BoolMessage1;
        }

        public CsBoolMessage()
        {
            BoolMessage BoolMessage1 = new BoolMessage();
            BoolMessage1.dll_obj = this;
            Base_obj = BoolMessage1;
        }
		
        public CsBoolMessage(BoolMessage p1)
        {
            BoolMessage BoolMessage1 = p1;
            BoolMessage1.dll_obj = this;
            Base_obj = BoolMessage1;
        }

        public BoolMessage Base_obj;
        
        [ContextProperty("Булево", "BoolVal")]
        public bool BoolVal
        {
            get { return Base_obj.BoolVal; }
            set { Base_obj.BoolVal = value; }
        }

        [ContextProperty("Идентификатор", "MessageId")]
        public string MessageId
        {
            get { return Base_obj.MessageId; }
        }
        
    }
}
