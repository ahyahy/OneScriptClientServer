using ScriptEngine.Machine.Contexts;
using ScriptEngine.Machine;

namespace oscs
{
    [ContextClass ("КсДействие", "CsAction")]
    public class CsAction : AutoContext<CsAction>
    {
        public CsAction(IRuntimeContextInstance script, string methodName)
        {
            Script = script;
            MethodName = methodName;
        }
        
        [ContextProperty("ИмяМетода", "MethodName")]
        public string MethodName { get; set; }
        
        [ContextProperty("Сценарий", "Script")]
        public IRuntimeContextInstance Script { get; set; }
        
    }
}
