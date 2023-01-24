using ScriptEngine.Machine.Contexts;
using ScriptEngine.Machine;

namespace oscs
{
    public class DoAtServerArgs : oscs.EventArgs
    {
        public new CsDoAtServerArgs dll_obj;
        private string methodName;
        private ScriptEngine.HostedScript.Library.ArrayImpl parametersArray;
        private bool returnResult;

        public DoAtServerArgs(string p1, ScriptEngine.HostedScript.Library.ArrayImpl p2, bool p3)
        {
            methodName = p1;
            parametersArray = p2;
            returnResult = p3;
        }

        public string MethodName
        {
            get { return methodName; }
            set { methodName = value; }
        }

        public ScriptEngine.HostedScript.Library.ArrayImpl ParametersArray
        {
            get { return parametersArray; }
            set { parametersArray = value; }
        }

        public bool ReturnResult
        {
            get { return returnResult; }
            set { returnResult = value; }
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

        public oscs.DoAtServerArgs Base_obj;
        
        [ContextProperty("ВернутьРезультат", "ReturnResult")]
        public bool ReturnResult
        {
            get { return Base_obj.ReturnResult; }
        }

        [ContextProperty("Действие", "EventAction")]
        public ScriptEngine.HostedScript.Library.DelegateAction EventAction
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
        public ScriptEngine.HostedScript.Library.ArrayImpl ParametersArray
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
