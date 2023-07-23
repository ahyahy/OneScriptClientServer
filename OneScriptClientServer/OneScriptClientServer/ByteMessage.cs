using ScriptEngine.Machine.Contexts;
using ScriptEngine.HostedScript.Library.Binary;
using Hik.Communication.Scs.Communication.Messages;

namespace oscs
{
    public class ByteMessage
    {
        public CsByteMessage dll_obj;
        public ScsRawDataMessage M_ByteMessage;

        public ByteMessage(byte[] p1 = null)
        {
            M_ByteMessage = new ScsRawDataMessage(p1);
        }

        public ByteMessage(ScsRawDataMessage p1)
        {
            M_ByteMessage = p1;
        }

        public ScsRawDataMessage M_Obj
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
        public CsByteMessage(BinaryDataContext p1)
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
		
        public CsByteMessage(ByteMessage p1)
        {
            ByteMessage ByteMessage1 = p1;
            ByteMessage1.dll_obj = this;
            Base_obj = ByteMessage1;
        }

        public ByteMessage Base_obj;
        
        [ContextProperty("Данные", "MessageData")]
        public BinaryDataContext MessageData
        {
            get { return new BinaryDataContext(Base_obj.MessageData); }
            set { Base_obj.MessageData = ((BinaryDataContext)value).Buffer; }
        }
        
        [ContextProperty("Идентификатор", "MessageId")]
        public string MessageId
        {
            get { return Base_obj.MessageId; }
        }
    }
}
