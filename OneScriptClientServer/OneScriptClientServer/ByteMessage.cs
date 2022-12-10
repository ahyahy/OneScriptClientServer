using ScriptEngine.Machine.Contexts;

namespace oscs
{
    public class ByteMessage
    {
        public CsByteMessage dll_obj;
        public Hik.Communication.Scs.Communication.Messages.ScsRawDataMessage M_ByteMessage;

        public ByteMessage(byte[] p1 = null)
        {
            M_ByteMessage = new Hik.Communication.Scs.Communication.Messages.ScsRawDataMessage(p1);
        }

        public ByteMessage(Hik.Communication.Scs.Communication.Messages.ScsRawDataMessage p1)
        {
            M_ByteMessage = p1;
        }

        public Hik.Communication.Scs.Communication.Messages.ScsRawDataMessage M_Obj
        {
            get { return M_ByteMessage; }
        }

        public byte[] MessageData
        {
            get { return M_ByteMessage.MessageData; }
            set { M_ByteMessage.MessageData = value; }
        }

        public string MessageId
        {
            get { return M_ByteMessage.MessageId; }
        }

        public string RepliedMessageId
        {
            get { return M_ByteMessage.RepliedMessageId; }
        }
    }

    [ContextClass ("КсСообщениеБайты", "CsByteMessage")]
    public class CsByteMessage : AutoContext<CsByteMessage>
    {
        public CsByteMessage(ScriptEngine.HostedScript.Library.Binary.BinaryDataContext p1)
        {
            ByteMessage ByteMessage1 = new ByteMessage();
            ByteMessage1.dll_obj = this;
            Base_obj = ByteMessage1;
            ByteMessage1.MessageData = p1.Buffer;
        }
        public CsByteMessage()
        {
            ByteMessage ByteMessage1 = new ByteMessage();
            ByteMessage1.dll_obj = this;
            Base_obj = ByteMessage1;
        }
		
        public CsByteMessage(oscs.ByteMessage p1)
        {
            ByteMessage ByteMessage1 = p1;
            ByteMessage1.dll_obj = this;
            Base_obj = ByteMessage1;
        }

        public ByteMessage Base_obj;
        
        [ContextProperty("Данные", "MessageData")]
        public ScriptEngine.HostedScript.Library.Binary.BinaryDataContext MessageData
        {
            get { return new ScriptEngine.HostedScript.Library.Binary.BinaryDataContext(Base_obj.MessageData); }
            set { Base_obj.MessageData = ((ScriptEngine.HostedScript.Library.Binary.BinaryDataContext)value).Buffer; }
        }
        
        [ContextProperty("Идентификатор", "MessageId")]
        public string MessageId
        {
            get { return Base_obj.MessageId; }
        }
        
    }
}
