using ScriptEngine.Machine.Contexts;

namespace oscs
{
    [ContextClass ("КсСостояниеСоединения", "CsCommunicationStates")]
    public class CsCommunicationStates : AutoContext<CsCommunicationStates>
    {
        private int m_connected = (int)Hik.Communication.Scs.Communication.CommunicationStates.Connected; // 0 Соединение подключено.
        private int m_disconnected = (int)Hik.Communication.Scs.Communication.CommunicationStates.Disconnected; // 1 Соединение отключено.

        [ContextProperty("Отключен", "Disconnected")]
        public int Disconnected
        {
        	get { return m_disconnected; }
        }

        [ContextProperty("Подключен", "Connected")]
        public int Connected
        {
        	get { return m_connected; }
        }
    }
}
