using ScriptEngine.Machine.Contexts;

namespace oscs
{
    public class TextMessage
    {
        public CsTextMessage dll_obj;
        public Hik.Communication.Scs.Communication.Messages.ScsTextMessage M_TextMessage;

        public TextMessage(Hik.Communication.Scs.Communication.Messages.ScsTextMessage p1)
        {
            M_TextMessage = p1;
        }

        public TextMessage(string p1 = null)
        {
            M_TextMessage = new Hik.Communication.Scs.Communication.Messages.ScsTextMessage(p1);
        }

        public Hik.Communication.Scs.Communication.Messages.ScsTextMessage M_Obj
        {
            get { return M_TextMessage; }
        }

        public string MessageId
        {
            get { return M_TextMessage.MessageId; }
        }

        public string RepliedMessageId
        {
            get { return M_TextMessage.RepliedMessageId; }
        }

        public string Text
        {
            get { return M_TextMessage.Text; }
            set { M_TextMessage.Text = value; }
        }
    }

    [ContextClass ("КсСообщениеТекст", "CsTextMessage")]
    public class CsTextMessage : AutoContext<CsTextMessage>
    {
        public CsTextMessage(string p1 = null)
        {
            TextMessage TextMessage1 = new TextMessage(p1);
            TextMessage1.dll_obj = this;
            Base_obj = TextMessage1;
        }
		
        public CsTextMessage(TextMessage p1)
        {
            TextMessage TextMessage1 = p1;
            TextMessage1.dll_obj = this;
            Base_obj = TextMessage1;
        }

        public TextMessage Base_obj;
        
        [ContextProperty("Идентификатор", "MessageId")]
        public string MessageId
        {
            get { return Base_obj.MessageId; }
        }

        [ContextProperty("Текст", "Text")]
        public string Text
        {
            get { return Base_obj.Text; }
            set { Base_obj.Text = value; }
        }
        
    }
}
