using ScriptEngine.Machine.Contexts;
using ScriptEngine.Machine;
using ScriptEngine.HostedScript.Library;

namespace oscs
{
    public class DoAtServerArgs : oscs.EventArgs
    {
        public new CsDoAtServerArgs dll_obj;
        private string methodName;
        private ArrayImpl parametersArray;

        public DoAtServerArgs(string p1, ArrayImpl p2)
        {
            methodName = p1;
            parametersArray = p2;
        }

        public string MethodName
        {
            get { return methodName; }
            set { methodName = value; }
        }

        public ArrayImpl ParametersArray
        {
            get { return parametersArray; }
            set { parametersArray = value; }
        }
    }

    [ContextClass ("КсВыполнитьНаСервереАрг", "CsDoAtServerArgs")]
    public class CsDoAtServerArgs : AutoContext<CsDoAtServerArgs>
    {
        public CsDoAtServerArgs(DoAtServerArgs p1)
        {
            DoAtServerArgs DoAtServerArgs1 = p1;
            DoAtServerArgs1.dll_obj = this;
            Base_obj = DoAtServerArgs1;
        }

        public DoAtServerArgs Base_obj;
        
        [ContextProperty("Действие", "EventAction")]
        public DelegateAction EventAction
        {
            get { return Base_obj.EventAction; }
            set { Base_obj.EventAction = value; }
        }
        
        [ContextProperty("ИмяМетода", "MethodName")]
        public string MethodName
        {
            get { return Base_obj.MethodName; }
        }

        [ContextProperty("МассивПараметров", "ParametersArray")]
        public ArrayImpl ParametersArray
        {
            get { return Base_obj.ParametersArray; }
        }

        [ContextProperty("Отправитель", "Sender")]
        public IValue Sender
        {
            get { return Base_obj.Sender.dll_obj; }
        }
    }
}
