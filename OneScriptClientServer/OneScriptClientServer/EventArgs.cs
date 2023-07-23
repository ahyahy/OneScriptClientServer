using ScriptEngine.Machine.Contexts;
using ScriptEngine.Machine;
using ScriptEngine.HostedScript.Library;

namespace oscs
{
    public class EventArgs
    {
        public CsEventArgs dll_obj;
        public DelegateAction EventAction;
        public dynamic Sender;

        public EventArgs()
        {
            Sender = null;
            EventAction = null;
        }
    }

    [ContextClass ("КсАргументыСобытия", "CsEventArgs")]
    public class CsEventArgs : AutoContext<CsEventArgs>
    {
        public CsEventArgs()
        {
            EventArgs EventArgs1 = new EventArgs();
            EventArgs1.dll_obj = this;
            Base_obj = EventArgs1;
        }
		
        public CsEventArgs(EventArgs p1)
        {
            EventArgs EventArgs1 = p1;
            EventArgs1.dll_obj = this;
            Base_obj = EventArgs1;
        }
        
        public EventArgs Base_obj;
        
        [ContextProperty("Действие", "EventAction")]
        public DelegateAction EventAction
        {
            get { return Base_obj.EventAction; }
            set { Base_obj.EventAction = value; }
        }
        
        [ContextProperty("Отправитель", "Sender")]
        public IValue Sender
        {
            get { return OneScriptClientServer.RevertObj(Base_obj.Sender); }
        }
    }
}
