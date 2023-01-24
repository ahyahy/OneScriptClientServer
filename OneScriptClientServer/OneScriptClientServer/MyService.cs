using Hik.Communication.ScsServices.Service;
using ScriptEngine.Machine;

namespace oscs
{
    public class MyService : ScsService, IMyService
    {

        public void DoAtServer(string str, System.Collections.ArrayList parametersArray = null)
        {
            ScriptEngine.HostedScript.Library.ArrayImpl arrayImpl = null;
            if (parametersArray != null)
            {
                arrayImpl = new ScriptEngine.HostedScript.Library.ArrayImpl();
                for (int i = 0; i < parametersArray.Count; i++)
                {
                    dynamic val = (dynamic)parametersArray[i];
                    if (val.GetType() == typeof(System.Byte[]))
                    {
                        var binaryDataContext = new ScriptEngine.HostedScript.Library.Binary.BinaryDataContext(val);
                        arrayImpl.Add(binaryDataContext);
                    }
                    else
                    {
                        IValue ival = ValueFactory.Create(val);
                        arrayImpl.Add(ival);
                    }
                }
            }

            oscs.OneScriptClientServer.CurrentServiceApplication.ParametersArray = arrayImpl;
            oscs.OneScriptClientServer.CurrentServiceApplication.ReturnResult = false;
            oscs.OneScriptClientServer.CurrentServiceApplication.MethodName = str;
        }

        public dynamic DoAtServerWithResalt(string str, System.Collections.ArrayList parametersArray = null)
        {
            ScriptEngine.HostedScript.Library.ArrayImpl arrayImpl = null;
            if (parametersArray != null)
            {
                arrayImpl = new ScriptEngine.HostedScript.Library.ArrayImpl();
                for (int i = 0; i < parametersArray.Count; i++)
                {
                    dynamic val = (dynamic)parametersArray[i];
                    if (val.GetType() == typeof(System.Byte[]))
                    {
                        var binaryDataContext = new ScriptEngine.HostedScript.Library.Binary.BinaryDataContext(val);
                        arrayImpl.Add(binaryDataContext);
                    }
                    else
                    {
                        IValue ival = ValueFactory.Create(val);
                        arrayImpl.Add(ival);
                    }
                }
            }

            oscs.OneScriptClientServer.CurrentServiceApplication.ParametersArray = arrayImpl;
            oscs.OneScriptClientServer.CurrentServiceApplication.ReturnResult = true;
            oscs.OneScriptClientServer.CurrentServiceApplication.MethodName = str;

            while (oscs.OneScriptClientServer.CurrentServiceApplication.resalt.ToString() == "92b55f72-41f9-4b03-8d64-01c7bd10325f")
            {
                System.Threading.Thread.Sleep(17);
            }
            return OneScriptClientServer.DefineTypeIValue(oscs.OneScriptClientServer.CurrentServiceApplication.Resalt);
        }

        public override string ToString()
        {
            return base.ToString();
        }
    }
}
