﻿using ScriptEngine.Machine.Contexts;
using ScriptEngine.Machine;
using Hik.Communication.Scs.Communication.Messages;

namespace oscs
{
    public class NumberMessage
    {
        public CsNumberMessage dll_obj;
        public ScsNumberMessage M_NumberMessage;

        public NumberMessage()
        {
            M_NumberMessage = new ScsNumberMessage();
        }

        public NumberMessage(decimal p1)
        {
            M_NumberMessage = new ScsNumberMessage(p1);
        }

        public NumberMessage(ScsNumberMessage p1)
        {
            M_NumberMessage = p1;
        }

        public ScsNumberMessage M_Obj
        {
            get { return M_NumberMessage; }
        }

        public string MessageId
        {
            get { return M_NumberMessage.MessageId; }
        }

        public decimal Number
        {
            get { return M_NumberMessage.Number; }
            set { M_NumberMessage.Number = value; }
        }

        public string RepliedMessageId
        {
            get { return M_NumberMessage.RepliedMessageId; }
        }
    }

    [ContextClass ("КсСообщениеЧисло", "CsNumberMessage")]
    public class CsNumberMessage : AutoContext<CsNumberMessage>
    {
        public CsNumberMessage(IValue p1)
        {
            NumberMessage NumberMessage1 = new NumberMessage(p1.AsNumber());
            NumberMessage1.dll_obj = this;
            Base_obj = NumberMessage1;
        }

        public CsNumberMessage()
        {
            NumberMessage NumberMessage1 = new NumberMessage();
            NumberMessage1.dll_obj = this;
            Base_obj = NumberMessage1;
        }

        public CsNumberMessage(NumberMessage p1)
        {
            NumberMessage NumberMessage1 = p1;
            NumberMessage1.dll_obj = this;
            Base_obj = NumberMessage1;
        }

        public NumberMessage Base_obj;
        
        [ContextProperty("Идентификатор", "MessageId")]
        public string MessageId
        {
            get { return Base_obj.MessageId; }
        }

        [ContextProperty("Число", "Number")]
        public decimal Number
        {
            get { return Base_obj.Number; }
            set { Base_obj.Number = value; }
        }
    }
}
