using ScriptEngine.Machine.Contexts;
using ScriptEngine.Machine;
using ScriptEngine.HostedScript.Library;

namespace oscs
{
    public class DoAtClientArgs : oscs.EventArgs
    {
        public new CsDoAtClientArgs dll_obj;
        private string methodName;
        private ArrayImpl parametersArray;

        public DoAtClientArgs(string p1, ArrayImpl p2)
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

    [ContextClass ("КсВыполнитьНаКлиентеАрг", "CsDoAtClientArgs")]
    public class CsDoAtClientArgs : AutoContext<CsDoAtClientArgs>
    {
        public CsDoAtClientArgs(DoAtClientArgs p1)
        {
            DoAtClientArgs DoAtClientArgs1 = p1;
            DoAtClientArgs1.dll_obj = this;
            Base_obj = DoAtClientArgs1;
        }

        public DoAtClientArgs Base_obj;
        
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
