using System;
using ScriptEngine.Machine.Contexts;

namespace oscs
{
    public class DateTimeMessage
    {
        public CsDateTimeMessage dll_obj;
        public Hik.Communication.Scs.Communication.Messages.ScsDateTimeMessage M_DateTimeMessage;

        public DateTimeMessage()
        {
            M_DateTimeMessage = new Hik.Communication.Scs.Communication.Messages.ScsDateTimeMessage();
        }

        public DateTimeMessage(DateTime p1)
        {
            M_DateTimeMessage = new Hik.Communication.Scs.Communication.Messages.ScsDateTimeMessage(p1);
        }

        public DateTimeMessage(Hik.Communication.Scs.Communication.Messages.ScsDateTimeMessage p1)
        {
            M_DateTimeMessage = p1;
        }

        public DateTime DateVal
        {
            get { return M_DateTimeMessage.DateVal; }
            set { M_DateTimeMessage.DateVal = value; }
        }

        public Hik.Communication.Scs.Communication.Messages.ScsDateTimeMessage M_Obj
        {
            get { return M_DateTimeMessage; }
        }

        public string MessageId
        {
            get { return M_DateTimeMessage.MessageId; }
        }

        public string RepliedMessageId
        {
            get { return M_DateTimeMessage.RepliedMessageId; }
        }
    }

    [ContextClass ("КсСообщениеДата", "CsDateTimeMessage")]
    public class CsDateTimeMessage : AutoContext<CsDateTimeMessage>
    {
        public CsDateTimeMessage(System.DateTime p1)
        {
            DateTimeMessage DateTimeMessage1 = new DateTimeMessage(p1);
            DateTimeMessage1.dll_obj = this;
            Base_obj = DateTimeMessage1;
        }

        public CsDateTimeMessage()
        {
            DateTimeMessage DateTimeMessage1 = new DateTimeMessage();
            DateTimeMessage1.dll_obj = this;
            Base_obj = DateTimeMessage1;
        }
		
        public CsDateTimeMessage(DateTimeMessage p1)
        {
            DateTimeMessage DateTimeMessage1 = p1;
            DateTimeMessage1.dll_obj = this;
            Base_obj = DateTimeMessage1;
        }

        public DateTimeMessage Base_obj;
        
        [ContextProperty("Дата", "DateVal")]
        public DateTime DateVal
        {
            get { return Base_obj.DateVal; }
            set { Base_obj.DateVal = value; }
        }

        [ContextProperty("Идентификатор", "MessageId")]
        public string MessageId
        {
            get { return Base_obj.MessageId; }
        }
        
    }
}
