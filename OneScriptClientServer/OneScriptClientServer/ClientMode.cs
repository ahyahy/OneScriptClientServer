using ScriptEngine.Machine.Contexts;

namespace oscs
{
    [ContextClass ("КсРежимКлиента", "CsClientMode")]
    public class CsClientMode : AutoContext<CsClientMode>
    {
        private int m_none = 0; // 0 Клиент является экземпляром класса из библиотеки OneScriptClientServer.
        private int m_native = 1; // 1 Клиент является экземпляром класса <B>TCPСоединение&nbsp;/&nbsp;TCPConnection</B> из библиотеки односкрипта.
        private int m_browser = 2; // 2 Подключение к серверу из какого либо браузера по протоколу http.

        [ContextProperty("Браузер", "Browser")]
        public int Browser
        {
        	get { return m_browser; }
        }

        [ContextProperty("Нативный", "Native")]
        public int Native
        {
        	get { return m_native; }
        }

        [ContextProperty("Отсутствие", "None")]
        public int None
        {
        	get { return m_none; }
        }
    }
}
