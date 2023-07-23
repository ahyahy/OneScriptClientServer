using System.Collections;

namespace oscs
{
    // Этот интерфейс определяет методы клиента.
    // Определенные методы вызываются сервером.
    public interface IMyClient
    {
        dynamic DoAtClientWithResalt(string clientGuid, string methodName, ArrayList parametersArray = null);
        dynamic DoAtClientWithResaltFromServer(string clientGuid, string methodName, ArrayList parametersArray = null);
    }
}
