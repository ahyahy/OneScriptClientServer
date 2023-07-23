using ScriptEngine.Machine;
using ScriptEngine.HostedScript.Library;
using ScriptEngine.HostedScript.Library.Binary;
using System.Collections;

namespace oscs
{
    // Этот класс реализует IMyClient, который используется для вызова сервером.
    public class MyClient : IMyClient
    {
        // Создает новый клиент.
        public MyClient()
        {
        }

        public dynamic DoAtClientWithResaltFromServer(string clientGuid, string methodName, ArrayList parametersArray = null)
        {
            ArrayImpl arrayImpl = null;
            if (parametersArray != null)
            {
                arrayImpl = new ArrayImpl();
                for (int i = 0; i < parametersArray.Count; i++)
                {
                    dynamic val = (dynamic)parametersArray[i];
                    if (val.GetType() == typeof(System.Byte[]))
                    {
                        var binaryDataContext = new BinaryDataContext(val);
                        arrayImpl.Add(binaryDataContext);
                    }
                    else
                    {
                        IValue ival = ValueFactory.Create(val);
                        arrayImpl.Add(ival);
                    }
                }
            }

            OneScriptClientServer.CurrentServiceClient.ParametersArray = arrayImpl;
            OneScriptClientServer.CurrentServiceClient.MethodName = methodName;

            return OneScriptClientServer.RedefineIValue(OneScriptClientServer.CurrentServiceClient.Resalt);
        }

        public dynamic DoAtClientWithResalt(string clientGuid, string methodName, ArrayList parametersArray = null)
        {
            ArrayImpl arrayImpl = null;
            if (parametersArray != null)
            {
                arrayImpl = new ArrayImpl();
                for (int i = 0; i < parametersArray.Count; i++)
                {
                    dynamic val = (dynamic)parametersArray[i];
                    if (val.GetType() == typeof(System.Byte[]))
                    {
                        var binaryDataContext = new BinaryDataContext(val);
                        arrayImpl.Add(binaryDataContext);
                    }
                    else
                    {
                        IValue ival = ValueFactory.Create(val);
                        arrayImpl.Add(ival);
                    }
                }
            }

            OneScriptClientServer.CurrentServiceClient.ParametersArray = arrayImpl;
            OneScriptClientServer.CurrentServiceClient.MethodName = methodName;

            while (OneScriptClientServer.CurrentServiceClient.resalt.ToString() == "7b7540f9-27e6-4e4a-a0b1-8012ac6e5737")
            {
                System.Threading.Thread.Sleep(17);
            }
            return OneScriptClientServer.RedefineIValue(OneScriptClientServer.CurrentServiceClient.Resalt);
        }
    }
}
