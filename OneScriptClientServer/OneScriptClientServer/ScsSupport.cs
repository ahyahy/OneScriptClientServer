﻿using System;
using System.Threading;
using System.Threading.Tasks;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters.Binary;
using System.Runtime.Remoting.Proxies;
using System.Runtime.Remoting.Messaging;
using System.Reflection;
using System.Net;
using System.Net.Sockets;
using System.Linq;
using System.IO;
using System.Collections.Generic;
using Hik.Threading;
using Hik.Communication.ScsServices.Communication;
using Hik.Communication.ScsServices.Communication.Messages;
using Hik.Communication.Scs.Server;
using Hik.Communication.Scs.Server.Tcp;
using Hik.Communication.Scs.Communication;
using Hik.Communication.Scs.Communication.Protocols;
using Hik.Communication.Scs.Communication.Protocols.BinarySerialization;
using Hik.Communication.Scs.Communication.Messengers;
using Hik.Communication.Scs.Communication.Messages;
using Hik.Communication.Scs.Communication.EndPoints;
using Hik.Communication.Scs.Communication.EndPoints.Tcp;
using Hik.Communication.Scs.Communication.Channels;
using Hik.Communication.Scs.Communication.Channels.Tcp;
using Hik.Communication.Scs.Client;
using Hik.Communication.Scs.Client.Tcp;
using Hik.Collections;

#region Server

namespace Hik.Communication.Scs.Server
{
    // Представляет сервер SCS, который используется для приема клиентских подключений и управления ими.
    public interface IScsServer
    {
        // Это событие возникает, когда новый клиент подключается к серверу.
        event EventHandler<ServerClientEventArgs> ClientConnected;

        // Это событие возникает, когда клиент отключается от сервера.
        event EventHandler<ServerClientEventArgs> ClientDisconnected;

        // Получает/устанавливает фабрику протоколов wire для создания объектов IWireProtocol.
        IScsWireProtocolFactory WireProtocolFactory { get; set; }

        // Набор клиентов, подключенных к серверу.
        ThreadSafeSortedList<long, IScsServerClient> Clients { get; }

        // Запускает сервер.
        void Start();

        // Останавливает сервер.
        void Stop();
    }
    //=========================================================================================================================================
    // Этот класс используется для создания SCS-серверов.
    public static class ScsServerFactory
    {
        // Создает новый SCS-сервер, используя конечную точку.
        // "endPoint" - Конечная точка, представляющая адрес сервера
        // Возврат - Созданный TCP-сервер
        public static IScsServer CreateServer(ScsEndPoint endPoint)
        {
            return endPoint.CreateServer();
        }
    }
    //=========================================================================================================================================
    // Предоставляет некоторые функциональные возможности, которые используются серверами.
    internal static class ScsServerManager
    {
        // Используется для установки клиентам автоматического приращения уникального идентификатора.
        private static long _lastClientId;

        // Получает уникальный номер, который будет использоваться в качестве идентификатора клиента.
        public static long GetClientId()
        {
            return Interlocked.Increment(ref _lastClientId);
        }
    }
    //=========================================================================================================================================
    // Этот класс представляет клиента на стороне сервера.
    internal class ScsServerClient : IScsServerClient
    {
        #region Public events

        // Это событие возникает при получении нового сообщения.
        public event EventHandler<MessageEventArgs> MessageReceived;

        // Это событие возникает, когда новое сообщение отправляется без какой-либо ошибки.
        // Это не гарантирует, что сообщение будет должным образом обработано удаленным приложением.
        public event EventHandler<MessageEventArgs> MessageSent;

        // Это событие возникает, когда клиент отключен от сервера.
        public event EventHandler Disconnected;

        #endregion

        #region Public properties

        // Уникальный идентификатор для этого клиента на сервере.
        public long ClientId { get; set; }

        // Получает состояние связи Клиента.
        public CommunicationStates CommunicationState
        {
            get { return _communicationChannel.CommunicationState; }
        }

        // Получает/устанавливает проводной протокол, который используется при чтении и записи сообщений.
        public IScsWireProtocol WireProtocol
        {
            get { return _communicationChannel.WireProtocol; }
            set { _communicationChannel.WireProtocol = value; }
        }

        // Получает конечную точку удаленного приложения.
        public ScsEndPoint RemoteEndPoint
        {
            get { return _communicationChannel.RemoteEndPoint; }
        }

        // Получает время последнего успешно полученного сообщения.
        public DateTime LastReceivedMessageTime
        {
            get { return _communicationChannel.LastReceivedMessageTime; }
        }

        // Получает время последнего успешно отправленного сообщения.
        public DateTime LastSentMessageTime
        {
            get { return _communicationChannel.LastSentMessageTime; }
        }

        #endregion

        #region Private fields

        // Канал связи, который используется клиентом для отправки и получения сообщений.
        private readonly ICommunicationChannel _communicationChannel;

        #endregion

        #region Constructor

        // Создает новый объект ScsClient.
        // "communicationChannel" - Канал связи, который используется клиентом для отправки и получения сообщений
        public ScsServerClient(ICommunicationChannel communicationChannel)
        {
            _communicationChannel = communicationChannel;
            _communicationChannel.MessageReceived += CommunicationChannel_MessageReceived;
            _communicationChannel.MessageSent += CommunicationChannel_MessageSent;
            _communicationChannel.Disconnected += CommunicationChannel_Disconnected;
        }

        #endregion

        #region Public methods

        // Отключается от клиента и закрывает базовый канал связи.
        public void Disconnect()
        {
            _communicationChannel.Disconnect();
        }

        // Отправляет сообщение клиенту.
        // "message" - Сообщение, которое нужно отправить.
        public void SendMessage(IScsMessage message)
        {
            _communicationChannel.SendMessage(message);
        }

        #endregion

        #region Private methods

        // Обрабатывает событие отключения объекта _communicationChannel.
        // "sender" - Источник события.
        // "e" - Аргументы события.
        private void CommunicationChannel_Disconnected(object sender, EventArgs e)
        {
            OnDisconnected();
        }

        // Обрабатывает событие MessageReceived объекта _communicationChannel.
        // "sender" - Источник события.
        // "e" - Аргументы события.
        private void CommunicationChannel_MessageReceived(object sender, MessageEventArgs e)
        {
            var message = e.Message;
            if (message is ScsPingMessage)
            {
                _communicationChannel.SendMessage(new ScsPingMessage { RepliedMessageId = message.MessageId });
                return;
            }

            OnMessageReceived(message);
        }

        // Обрабатывает событие отправки сообщений объекта _communicationChannel.
        // "sender" - Источник события.
        // "e" - Аргументы события.
        private void CommunicationChannel_MessageSent(object sender, MessageEventArgs e)
        {
            OnMessageSent(e.Message);
        }

        #endregion

        #region Event raising methods

        // Вызывает событие отключения.
        private void OnDisconnected()
        {
            var handler = Disconnected;
            if (handler != null)
            {
                handler(this, EventArgs.Empty);
            }
        }

        // Вызывает событие MessageReceived.
        // "message" - Полученное сообщение.
        private void OnMessageReceived(IScsMessage message)
        {
            var handler = MessageReceived;
            if (handler != null)
            {
                handler(this, new MessageEventArgs(message));
            }
        }

        // Вызывает событие messageSent.
        // "message" - Полученное сообщение.
        protected virtual void OnMessageSent(IScsMessage message)
        {
            var handler = MessageSent;
            if (handler != null)
            {
                handler(this, new MessageEventArgs(message));
            }
        }

        #endregion
    }
    //=========================================================================================================================================
    // Этот класс предоставляет базовую функциональность для серверных классов.
    internal abstract class ScsServerBase : IScsServer
    {
        #region Public events

        // Это событие возникает при подключении нового клиента.
        public event EventHandler<ServerClientEventArgs> ClientConnected;

        // Это событие возникает, когда клиент отключается от сервера.
        public event EventHandler<ServerClientEventArgs> ClientDisconnected;

        #endregion

        #region Public properties

        // Получает/устанавливает проводной протокол, который используется при чтении и записи сообщений.
        public IScsWireProtocolFactory WireProtocolFactory { get; set; }

        // Набор клиентов, подключенных к серверу.
        public ThreadSafeSortedList<long, IScsServerClient> Clients { get; private set; }

        #endregion

        #region Private properties

        // Этот объект используется для прослушивания входящих подключений.
        private IConnectionListener _connectionListener;

        #endregion

        #region Constructor

        // Конструктор.
        protected ScsServerBase()
        {
            Clients = new ThreadSafeSortedList<long, IScsServerClient>();
            WireProtocolFactory = WireProtocolManager.GetDefaultWireProtocolFactory();
        }

        #endregion

        #region Public methods

        // Запускает сервер.
        public virtual void Start()
        {
            _connectionListener = CreateConnectionListener();
            _connectionListener.CommunicationChannelConnected += ConnectionListener_CommunicationChannelConnected;
            _connectionListener.Start();
        }

        // Останавливает сервер.
        public virtual void Stop()
        {
            if (_connectionListener != null)
            {
                _connectionListener.Stop();
            }

            foreach (var client in Clients.GetAllItems())
            {
                client.Disconnect();
            }
        }

        #endregion

        #region Protected abstract methods

        // Этот метод реализуется производными классами для создания соответствующего прослушивателя соединений для прослушивания входящих запросов на подключение.
        protected abstract IConnectionListener CreateConnectionListener();

        #endregion

        #region Private methods

        // Обрабатывает событие CommunicationChannelConnected объекта _connectionListener.
        // "sender" - Источник события.
        // "e" - Аргументы события.
        private void ConnectionListener_CommunicationChannelConnected(object sender, CommunicationChannelEventArgs e)
        {
            var client = new ScsServerClient(e.Channel)
            {
                ClientId = ScsServerManager.GetClientId(),
                WireProtocol = WireProtocolFactory.CreateWireProtocol()
            };

            client.Disconnected += Client_Disconnected;
            Clients[client.ClientId] = client;
            OnClientConnected(client);
            e.Channel.Start();
        }

        // Обрабатывает события отключенния всех подключенных клиентов.
        // "sender" - Источник события.
        // "e" - Аргументы события.
        private void Client_Disconnected(object sender, EventArgs e)
        {
            var client = (IScsServerClient)sender;
            Clients.Remove(client.ClientId);
            OnClientDisconnected(client);
        }

        #endregion

        #region Event raising methods

        // Вызывает событие, связанное с клиентом.
        // "client" - Подключенный клиент.
        protected virtual void OnClientConnected(IScsServerClient client)
        {
            var handler = ClientConnected;
            if (handler != null)
            {
                handler(this, new ServerClientEventArgs(client));
            }
        }

        // Вызывает событие ClientDisconnected.
        // "client" - Отключенный клиент.
        protected virtual void OnClientDisconnected(IScsServerClient client)
        {
            var handler = ClientDisconnected;
            if (handler != null)
            {
                handler(this, new ServerClientEventArgs(client));
            }
        }

        #endregion
    }
    //=========================================================================================================================================
    // Представляет клиента с точки зрения сервера.
    public interface IScsServerClient : IMessenger
    {
        // Это событие возникает, когда клиент отключается от сервера.
        event EventHandler Disconnected;

        // Уникальный идентификатор для этого клиента на сервере.
        long ClientId { get; }

        // Получает конечную точку удаленного приложения.
        ScsEndPoint RemoteEndPoint { get; }

        // Получает текущее состояние связи.
        CommunicationStates CommunicationState { get; }

        // Отключается от сервера.
        void Disconnect();
    }
}

#endregion Server

#region Client

namespace Hik.Communication.Scs.Client.Tcp
{
    // Этот класс используется для связи с сервером по протоколу TCP/IP.
    internal class ScsTcpClient : ScsClientBase
    {
        // Адрес конечной точки сервера.
        private readonly ScsTcpEndPoint _serverEndPoint;

        // Создает новый объект ScsTcpClient.
        // serverEndPoint - Адрес конечной точки для подключения к серверу
        public ScsTcpClient(ScsTcpEndPoint serverEndPoint)
        {
            _serverEndPoint = serverEndPoint;
        }

        // Создает канал связи, используя ServerIpAddress и ServerPort.
        // Возвращает готовый канал связи для общения
        protected override ICommunicationChannel CreateCommunicationChannel()
        {
            EndPoint endpoint = null;

            if (IsStringIp(_serverEndPoint.IpAddress))
            {
                endpoint = new IPEndPoint(IPAddress.Parse(_serverEndPoint.IpAddress), _serverEndPoint.TcpPort);
            }
            else
            {
                endpoint = new DnsEndPoint(_serverEndPoint.IpAddress, _serverEndPoint.TcpPort);
            }

            return new TcpCommunicationChannel(
                TcpHelper.ConnectToServer(
                    endpoint,
                    ConnectTimeout
                    ));
        }

        private bool IsStringIp(string address)
        {
            IPAddress ipAddress = null;
            return IPAddress.TryParse(address, out ipAddress);
        }
    }
    //=========================================================================================================================================
    // Этот класс используется для упрощения операций с TCP-сокетами.
    internal static class TcpHelper
    {
        // Этот код используется для подключения к TCP-сокету с опцией тайм-аута.
        // "endPoint" - IP-конечная точка удаленного сервера.
        // "timeoutMs" - Тайм-аут для ожидания подключения.
        // Возвращает объект сокета, подключенный к серверу
        // "SocketException" - Выдает исключение SocketException, если не удается подключиться.
        // "TimeoutException" - Выдает исключение TimeoutException, если не удается подключиться в течение указанного времени ожидания
        public static Socket ConnectToServer(EndPoint endPoint, int timeoutMs)
        {
            var socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            try
            {
                socket.Blocking = false;
                socket.Connect(endPoint);
                socket.Blocking = true;
                return socket;
            }
            catch (SocketException socketException)
            {
                if (socketException.ErrorCode != 10035)
                {
                    socket.Close();
                    throw;
                }

                if (!socket.Poll(timeoutMs * 1000, SelectMode.SelectWrite))
                {
                    socket.Close();
                    throw new TimeoutException("The host failed to connect. Timeout occured.");
                }

                socket.Blocking = true;
                return socket;
            }
        }
    }
    //=========================================================================================================================================
}

namespace Hik.Communication.Scs.Client
{
    // Этот класс используется для автоматического повторного подключения к серверу при отключении.
    // Он периодически пытается повторно подключиться к серверу, пока соединение не будет установлено.
    public class ClientReConnecter : IDisposable
    {
        // Период проверки повторного подключения.
        // По умолчанию: 20 секунд.
        public int ReConnectCheckPeriod
        {
            get { return _reconnectTimer.Period; }
            set { _reconnectTimer.Period = value; }
        }

        // Ссылка на клиентский объект.
        private readonly IConnectableClient _client;

        // Таймер для периодической попытки повторного подключения ro.
        private readonly Hik.Threading.Timer _reconnectTimer;

        // Указывает состояние удаления этого объекта.
        private volatile bool _disposed;

        // Создает новый объект ClientReConnecter.
        // Запускать ClientReConnecter не требуется, поскольку он автоматически запускается при отключении клиента.
        // "client" - Ссылка на клиентский объект.
        // Исключение - "ArgumentNullException" - Выдает исключение ArgumentNullException, если значение client равно null.
        public ClientReConnecter(IConnectableClient client)
        {
            if (client == null)
            {
                throw new ArgumentNullException("client");
            }

            _client = client;
            _client.Disconnected += Client_Disconnected;
            _reconnectTimer = new Hik.Threading.Timer(20000);
            _reconnectTimer.Elapsed += ReconnectTimer_Elapsed;
            _reconnectTimer.Start();
        }

        // Распоряжается этим объектом.
        // Ничего не делает, если уже утилизирован.
        public void Dispose()
        {
            if (_disposed)
            {
                return;
            }

            _disposed = true;
            _client.Disconnected -= Client_Disconnected;
            _reconnectTimer.Stop();
        }

        // Обрабатывает отключенное событие объекта _client.
        // "sender" - Источник события.
        // "e" - Аргументы события.
        private void Client_Disconnected(object sender, EventArgs e)
        {
            _reconnectTimer.Start();
        }

        // Hadles Прошедшее событие _reconnectTimer.
        // "sender" - Источник события.
        // "e" - Аргументы события.
        private void ReconnectTimer_Elapsed(object sender, EventArgs e)
        {
            if (_disposed || _client.CommunicationState == CommunicationStates.Connected)
            {
                _reconnectTimer.Stop();
                return;
            }

            try
            {
                _client.Connect();
                _reconnectTimer.Stop();
            }
            catch
            {
                //No need to catch since it will try to re-connect again
            }
        }
    }
    //=========================================================================================================================================
    // Представляет клиент для серверов SCS.
    public interface IConnectableClient : IDisposable
    {
        // Это событие возникает, когда клиент подключается к серверу.
        event EventHandler Connected;

        // Это событие возникает, когда клиент отключается от сервера.
        event EventHandler Disconnected;

        // Тайм-аут для подключения к серверу (в миллисекундах).
        // Значение по умолчанию: 15 секунд (15000 мс).
        int ConnectTimeout { get; set; }

        // Получает текущее состояние связи.
        CommunicationStates CommunicationState { get; }

        // Подключается к серверу.
        void Connect();

        // Отключается от сервера.
        // Ничего не делает, если уже отключен.
        void Disconnect();
    }
    //=========================================================================================================================================
    // Представляет клиента для подключения к серверу.
    public interface IScsClient : IMessenger, IConnectableClient
    {
        //Не определяет никакого дополнительного элемента
    }
    //=========================================================================================================================================
    // Этот класс предоставляет базовую функциональность для клиентских классов.
    internal abstract class ScsClientBase : IScsClient
    {
        #region Public events

        // Это событие возникает при получении нового сообщения.
        public event EventHandler<MessageEventArgs> MessageReceived;

        // Это событие возникает, когда новое сообщение отправляется без какой-либо ошибки.
        // Это не гарантирует, что сообщение будет должным образом обработано удаленным приложением.
        public event EventHandler<MessageEventArgs> MessageSent;

        // Это событие возникает при подключении.
        public event EventHandler Connected;

        // Это событие возникает, когда клиент отключается от сервера.
        public event EventHandler Disconnected;

        #endregion

        #region Public properties

        // Тайм-аут для подключения к серверу (в миллисекундах).
        // Значение по умолчанию: 15 секунд (15000 мс).
        public int ConnectTimeout { get; set; }

        // Получает/устанавливает проводной протокол, который используется при чтении и записи сообщений.
        public IScsWireProtocol WireProtocol
        {
            get { return _wireProtocol; }
            set
            {
                if (CommunicationState == CommunicationStates.Connected)
                {
                    throw new ApplicationException("Wire protocol can not be changed while connected to server.");
                }

                _wireProtocol = value;
            }
        }
        private IScsWireProtocol _wireProtocol;

        // Получает состояние связи Клиента.
        public CommunicationStates CommunicationState
        {
            get
            {
                return _communicationChannel != null
                           ? _communicationChannel.CommunicationState
                           : CommunicationStates.Disconnected;
            }
        }

        // Получает время последнего успешно полученного сообщения.
        public DateTime LastReceivedMessageTime
        {
            get
            {
                return _communicationChannel != null
                           ? _communicationChannel.LastReceivedMessageTime
                           : DateTime.MinValue;
            }
        }

        // Получает время последнего успешно отправленного сообщения.
        public DateTime LastSentMessageTime
        {
            get
            {
                return _communicationChannel != null
                           ? _communicationChannel.LastSentMessageTime
                           : DateTime.MinValue;
            }
        }

        #endregion

        #region Private fields

        // Значение таймаута по умолчанию для подключения сервера.
        private const int DefaultConnectionAttemptTimeout = 15000; //15 seconds.

        // Канал связи, который используется клиентом для отправки и получения сообщений.
        private ICommunicationChannel _communicationChannel;

        // Этот таймер используется для периодической отправки сообщений PingMessage на сервер.
        private readonly Hik.Threading.Timer _pingTimer;

        #endregion

        #region Constructor

        // Конструктор
        protected ScsClientBase()
        {
            _pingTimer = new Hik.Threading.Timer(30000);
            _pingTimer.Elapsed += PingTimer_Elapsed;
            ConnectTimeout = DefaultConnectionAttemptTimeout;
            WireProtocol = WireProtocolManager.GetDefaultWireProtocol();
        }

        #endregion

        #region Public methods

        // Подключается к серверу.
        public void Connect()
        {
            WireProtocol.Reset();
            _communicationChannel = CreateCommunicationChannel();
            _communicationChannel.WireProtocol = WireProtocol;
            _communicationChannel.Disconnected += CommunicationChannel_Disconnected;
            _communicationChannel.MessageReceived += CommunicationChannel_MessageReceived;
            _communicationChannel.MessageSent += CommunicationChannel_MessageSent;
            _communicationChannel.Start();
            _pingTimer.Start();
            OnConnected();
        }

        // Отключается от сервера.
        // Ничего не делает, если уже отключен.
        public void Disconnect()
        {
            if (CommunicationState != CommunicationStates.Connected)
            {
                return;
            }

            _communicationChannel.Disconnect();
        }

        // Удаляет этот объект и закрывает базовое соединение.
        public void Dispose()
        {
            Disconnect();
        }

        // Отправляет сообщение на сервер.
        // "message" - Сообщение, которое нужно отправить
        // Исключение - "CommunicationStateException" - Выдает исключение CommunicationStateException, если клиент не подключен к серверу.
        public void SendMessage(IScsMessage message)
        {
            if (CommunicationState != CommunicationStates.Connected)
            {
                throw new CommunicationStateException("Client is not connected to the server.");
            }

            _communicationChannel.SendMessage(message);
        }

        #endregion

        #region Abstract methods

        // Этот метод реализуется производными классами для создания соответствующего канала связи.
        // Возврат - Готовый канал связи для общения
        protected abstract ICommunicationChannel CreateCommunicationChannel();

        #endregion

        #region Private methods

        // Обрабатывает событие MessageReceived объекта _communicationChannel.
        // "sender" - Источник события
        // "e" - Аргументы события
        private void CommunicationChannel_MessageReceived(object sender, MessageEventArgs e)
        {
            if (e.Message is ScsPingMessage)
            {
                return;
            }

            OnMessageReceived(e.Message);
        }

        // Handles MessageSent event of _communicationChannel object.
        // Обрабатывает событие отправки сообщений объекта _communicationChannel.
        // "sender" - Источник события
        // "e" - Аргументы события
        private void CommunicationChannel_MessageSent(object sender, MessageEventArgs e)
        {
            OnMessageSent(e.Message);
        }

        // Обрабатывает событие отключения объекта _communicationChannel.
        // "sender">Source of event
        // "e" - Аргументы события.
        private void CommunicationChannel_Disconnected(object sender, EventArgs e)
        {
            _pingTimer.Stop();
            OnDisconnected();
        }

        // Обрабатывает прошедшее событие _pingTimer для отправки сообщений PingMessage на сервер.
        // "sender" - Источник события.
        // "e" - Аргументы события.
        private void PingTimer_Elapsed(object sender, EventArgs e)
        {
            if (CommunicationState != CommunicationStates.Connected)
            {
                return;
            }

            try
            {
                var lastMinute = DateTime.Now.AddMinutes(-1);
                if (_communicationChannel.LastReceivedMessageTime > lastMinute || _communicationChannel.LastSentMessageTime > lastMinute)
                {
                    return;
                }

                _communicationChannel.SendMessage(new ScsPingMessage());
            }
            catch
            {

            }
        }

        #endregion

        #region Event raising methods

        // Вызывает событие Connected.
        protected virtual void OnConnected()
        {
            var handler = Connected;
            if (handler != null)
            {
                handler(this, EventArgs.Empty);
            }
        }

        // Вызывает событие Disconnected.
        protected virtual void OnDisconnected()
        {
            var handler = Disconnected;
            if (handler != null)
            {
                handler(this, EventArgs.Empty);
            }
        }

        // Вызывает событие MessageReceived.
        // "message" - Сообщение.
        protected virtual void OnMessageReceived(IScsMessage message)
        {
            var handler = MessageReceived;
            if (handler != null)
            {
                handler(this, new MessageEventArgs(message));
            }
        }

        // Вызывает событие MessageSent.
        // "message" - Сообщение.
        protected virtual void OnMessageSent(IScsMessage message)
        {
            var handler = MessageSent;
            if (handler != null)
            {
                handler(this, new MessageEventArgs(message));
            }
        }

        #endregion
    }
    //=========================================================================================================================================
    // Этот класс используется для создания клиентов SCS для подключения к серверу SCS.
    public static class ScsClientFactory
    {
        // Создает нового клиента для подключения к серверу с использованием конечной точки.
        // "endpoint" - Конечная точка сервера для его подключения
        // Возврат - Созданный TCP-клиент
        public static IScsClient CreateClient(ScsEndPoint endpoint)
        {
            return endpoint.CreateClient();
        }

        // Создает нового клиента для подключения к серверу с использованием конечной точки.
        // "endpointAddress" - Адрес конечной точки сервера для его подключения
        // Возврат - Созданный TCP-клиент
        public static IScsClient CreateClient(string endpointAddress)
        {
            return CreateClient(ScsEndPoint.CreateEndPoint(endpointAddress));
        }
    }
    //=========================================================================================================================================

}

#endregion Client

#region Communication

namespace Hik.Communication.Scs.Communication.Channels.Tcp
{
    // Этот класс используется для связи с удаленным приложением по протоколу TCP/IP.
    internal class TcpCommunicationChannel : CommunicationChannelBase
    {
        #region Public properties

        // Получает конечную точку удаленного приложения.
        public override ScsEndPoint RemoteEndPoint
        {
            get
            {
                return _remoteEndPoint;
            }
        }
        private readonly ScsTcpEndPoint _remoteEndPoint;

        #endregion

        #region Private fields

        // Размер буфера, который используется для приема байтов из TCP сокета.
        private const int ReceiveBufferSize = 4 * 1024; //4KB

        // Этот буфер используется для приема байтов 
        private readonly byte[] _buffer;

        // Объект сокета для отправки/получения сообщений.
        private readonly Socket _clientSocket;

        // Флаг для управления запуском потока
        private volatile bool _running;

        // Этот объект просто используется для синхронизации потоков (блокировки).
        private readonly object _syncLock;

        #endregion

        #region Constructor

        // Создает новый объект TcpCommunicationChannel.
        // "clientSocket" - Подключенный объект сокета, который используется для обмена данными по сети.
        public TcpCommunicationChannel(Socket clientSocket)
        {
            _clientSocket = clientSocket;
            _clientSocket.NoDelay = true;

            var ipEndPoint = (IPEndPoint)_clientSocket.RemoteEndPoint;
            _remoteEndPoint = new ScsTcpEndPoint(ipEndPoint.Address.ToString(), ipEndPoint.Port);

            _buffer = new byte[ReceiveBufferSize];
            _syncLock = new object();
        }

        #endregion

        #region Public methods

        // Отключается от удаленного приложения и закрывает канал.
        public override void Disconnect()
        {
            if (CommunicationState != CommunicationStates.Connected)
            {
                return;
            }

            _running = false;
            try
            {
                if (_clientSocket.Connected)
                {
                    _clientSocket.Close();
                }

                _clientSocket.Dispose();
            }
            catch
            {

            }

            CommunicationState = CommunicationStates.Disconnected;
            OnDisconnected();
        }

        #endregion

        #region Protected methods

        // Запускает поток для получения сообщений из сокета.
        protected override void StartInternal()
        {
            _running = true;
            _clientSocket.BeginReceive(_buffer, 0, _buffer.Length, 0, new AsyncCallback(ReceiveCallback), null);
        }

        // Отправляет сообщение удаленному приложению.
        // "message" - Сообщение, которое нужно отправить.
        protected override void SendMessageInternal(IScsMessage message)
        {
            // Отправить сообщение
            var totalSent = 0;
            lock (_syncLock)
            {
                // Создайте массив байтов из сообщения в соответствии с текущим протоколом
                var messageBytes = WireProtocol.GetBytes(message);
                // Отправьте все байты в удаленное приложение
                while (totalSent < messageBytes.Length)
                {
                    var sent = _clientSocket.Send(messageBytes, totalSent, messageBytes.Length - totalSent, SocketFlags.None);
                    if (sent <= 0)
                    {
                        throw new CommunicationException("Message could not be sent via TCP socket. Only " + totalSent + " bytes of " + messageBytes.Length + " bytes are sent.");
                    }

                    totalSent += sent;
                }

                LastSentMessageTime = DateTime.Now;
                OnMessageSent(message);
            }
        }

        #endregion

        #region Private methods

        // Этот метод используется в качестве метода обратного вызова в методе BeginReceive _clientSocket.
        // Он извлекает байты из сокера.
        // "ar" - Асинхронный результат вызова.
        private void ReceiveCallback(IAsyncResult ar)
        {
            if (!_running)
            {
                return;
            }

            try
            {
                // Получить количество полученных байтов
                var bytesRead = _clientSocket.EndReceive(ar);
                if (bytesRead > 0)
                {
                    LastReceivedMessageTime = DateTime.Now;

                    // Скопируйте полученные байты в новый массив байтов
                    var receivedBytes = new byte[bytesRead];
                    Array.Copy(_buffer, 0, receivedBytes, 0, bytesRead);

                    // Считывать сообщения в соответствии с текущим проводным протоколом
                    var messages = WireProtocol.CreateMessages(receivedBytes);

                    // Вызвать событие MessageReceived для всех полученных сообщений
                    foreach (var message in messages)
                    {
                        OnMessageReceived(message);
                    }
                }
                else
                {
                    throw new CommunicationException("Tcp socket is closed");
                }

                // Прочитайте больше байтов, если все еще работаете
                if (_running)
                {
                    _clientSocket.BeginReceive(_buffer, 0, _buffer.Length, 0, new AsyncCallback(ReceiveCallback), null);
                }
            }
            catch
            {
                Disconnect();
            }
        }

        #endregion
    }
    //=========================================================================================================================================
    // Этот класс используется для прослушивания и приема входящих запросов на TCP-соединение через TCP-порт.
    internal class TcpConnectionListener : ConnectionListenerBase
    {
        // Адрес конечной точки сервера для прослушивания входящих подключений.
        private readonly ScsTcpEndPoint _endPoint;

        // Серверный сокет для прослушивания входящих запросов на подключение.
        private TcpListener _listenerSocket;

        // Поток для прослушивания сокета
        private Thread _thread;

        // Флаг для управления запуском потока
        private volatile bool _running;

        // Создает новый TcpConnectionListener для данной конечной точки.
        // "endPoint" - Адрес конечной точки сервера для прослушивания входящих подключений.
        public TcpConnectionListener(ScsTcpEndPoint endPoint)
        {
            _endPoint = endPoint;
        }

        // Начинает прослушивать входящие соединения.
        public override void Start()
        {
            StartSocket();
            _running = true;
            _thread = new Thread(DoListenAsThread);
            _thread.Start();
        }

        // Прекращает прослушивание входящих подключений.
        public override void Stop()
        {
            _running = false;
            StopSocket();
        }

        // Начинает прослушивать сокет.
        private void StartSocket()
        {
            _listenerSocket = new TcpListener(System.Net.IPAddress.Any, _endPoint.TcpPort);
            _listenerSocket.Start();
        }

        // Прекращает прослушивание сокета.
        private void StopSocket()
        {
            try
            {
                _listenerSocket.Stop();
            }
            catch
            {

            }
        }

        // Точка входа нити.
        // Этот метод используется потоком для прослушивания входящих запросов.
        private void DoListenAsThread()
        {
            while (_running)
            {
                try
                {
                    var clientSocket = _listenerSocket.AcceptSocket();
                    if (clientSocket.Connected)
                    {
                        OnCommunicationChannelConnected(new TcpCommunicationChannel(clientSocket));
                    }
                }
                catch
                {
                    // Отключитесь, подождите некоторое время и подключите снова.
                    StopSocket();
                    Thread.Sleep(1000);
                    if (!_running)
                    {
                        return;
                    }

                    try
                    {
                        StartSocket();
                    }
                    catch
                    {

                    }
                }
            }
        }
    }
    //=========================================================================================================================================
}

namespace Hik.Communication.Scs.Communication.Channels
{
    // Этот класс обеспечивает базовую функциональность для всех классов каналов связи.
    internal abstract class CommunicationChannelBase : ICommunicationChannel
    {
        #region Public events

        // Это событие возникает при получении нового сообщения.
        public event EventHandler<MessageEventArgs> MessageReceived;

        // Это событие возникает, когда новое сообщение отправляется без какой-либо ошибки.
        // Это не гарантирует, что сообщение будет должным образом обработано удаленным приложением.
        public event EventHandler<MessageEventArgs> MessageSent;

        // Это событие возникает, когда канал связи закрыт.
        public event EventHandler Disconnected;

        #endregion

        #region Public abstract properties

        // Получает конечную точку удаленного приложения.
        public abstract ScsEndPoint RemoteEndPoint { get; }

        #endregion

        #region Public properties

        // Получает текущее состояние связи.
        public CommunicationStates CommunicationState { get; protected set; }

        // Получает время последнего успешно полученного сообщения.
        public DateTime LastReceivedMessageTime { get; protected set; }

        // Получает время последнего успешно отправленного сообщения.
        public DateTime LastSentMessageTime { get; protected set; }

        // Получает/устанавливает проводной протокол, который использует канал.
        // Это свойство должно быть установлено перед первым сообщением.
        public IScsWireProtocol WireProtocol { get; set; }

        #endregion

        #region Constructor

        // Конструктор.
        protected CommunicationChannelBase()
        {
            CommunicationState = CommunicationStates.Disconnected;
            LastReceivedMessageTime = DateTime.MinValue;
            LastSentMessageTime = DateTime.MinValue;
        }

        #endregion

        #region Public abstract methods

        // Отключается от удаленного приложения и закрывает этот канал.
        public abstract void Disconnect();

        #endregion

        #region Public methods

        // Запускает связь с удаленным приложением.
        public void Start()
        {
            StartInternal();
            CommunicationState = CommunicationStates.Connected;
        }

        // Отправляет сообщение удаленному приложению.
        // "message" - Сообщение, которое нужно отправить.
        // Исключение - "ArgumentNullException" - Выдает исключение ArgumentNullException, если сообщение равно null
        public void SendMessage(IScsMessage message)
        {
            if (message == null)
            {
                throw new ArgumentNullException("message");
            }

            SendMessageInternal(message);
        }

        #endregion

        #region Protected abstract methods

        // Действительно запускает связь с удаленным приложением.
        protected abstract void StartInternal();

        // Отправляет сообщение удаленному приложению.
        // Этот метод переопределяется производными классами для реальной отправки в message.
        // "message" - Сообщение, которое нужно отправить.
        protected abstract void SendMessageInternal(IScsMessage message);

        #endregion

        #region Event raising methods

        // Вызывает событие отключения.
        protected virtual void OnDisconnected()
        {
            var handler = Disconnected;
            if (handler != null)
            {
                handler(this, EventArgs.Empty);
            }
        }

        // Вызывает событие MessageReceived.
        // "message" - Полученное сообщение.
        protected virtual void OnMessageReceived(IScsMessage message)
        {
            var handler = MessageReceived;
            if (handler != null)
            {
                handler(this, new MessageEventArgs(message));
            }
        }

        // Вызывает событие messageSent.
        // "message" - Полученное сообщение.
        protected virtual void OnMessageSent(IScsMessage message)
        {
            var handler = MessageSent;
            if (handler != null)
            {
                handler(this, new MessageEventArgs(message));
            }
        }

        #endregion
    }
    //=========================================================================================================================================
    // Хранит информацию о канале связи, который будет использоваться событием.
    internal class CommunicationChannelEventArgs : EventArgs
    {
        // Канал связи, связанный с этим событием.
        public ICommunicationChannel Channel { get; private set; }

        // Создает новый объект CommunicationChannelEventArgs.
        // "channel" - Канал связи, связанный с этим событием.
        public CommunicationChannelEventArgs(ICommunicationChannel channel)
        {
            Channel = channel;
        }
    }
    //=========================================================================================================================================
    // Этот класс предоставляет базовую функциональность для классов прослушивателей связи.
    internal abstract class ConnectionListenerBase : IConnectionListener
    {
        // Это событие возникает при подключении нового канала связи.
        public event EventHandler<CommunicationChannelEventArgs> CommunicationChannelConnected;

        // Начинает прослушивать входящие соединения.
        public abstract void Start();

        // Прекращает прослушивание входящих подключений.
        public abstract void Stop();

        // Вызывает событие CommunicationChannelConnected.
        protected virtual void OnCommunicationChannelConnected(ICommunicationChannel client)
        {
            var handler = CommunicationChannelConnected;
            if (handler != null)
            {
                handler(this, new CommunicationChannelEventArgs(client));
            }
        }
    }
    //=========================================================================================================================================
    // Представляет собой канал связи.
    // Канал связи используется для связи (отправки/получения сообщений) с удаленным приложением.
    internal interface ICommunicationChannel : IMessenger
    {
        // Это событие возникает, когда клиент отключается от сервера.
        event EventHandler Disconnected;

        // Получает конечную точку удаленного приложения.
        ScsEndPoint RemoteEndPoint { get; }

        // Получает текущее состояние связи.
        CommunicationStates CommunicationState { get; }

        // Запускает связь с удаленным приложением.
        void Start();

        // Закрывает мессенджер.
        void Disconnect();
    }
    //=========================================================================================================================================
    // Представляет собой слушателя коммуникации.
    // Прослушиватель соединений используется для приема входящих запросов на подключение клиента.
    internal interface IConnectionListener
    {
        // Это событие возникает при подключении нового канала связи.
        event EventHandler<CommunicationChannelEventArgs> CommunicationChannelConnected;

        // Начинает прослушивать входящие соединения.
        void Start();

        // Прекращает прослушивание входящих подключений.
        void Stop();
    }
    //=========================================================================================================================================

}

namespace Hik.Communication.Scs.Communication.EndPoints.Tcp
{
    // Представляет конечную точку TCP в SCS.
    public sealed class ScsTcpEndPoint : ScsEndPoint
    {
        // Создает новый объект ScsTcpEndPoint с указанным IP-адресом и номером порта.
        // "ipAddress" - IP-адрес сервера
        // "port" - Прослушивание TCP-порта для входящих запросов на подключение на сервере
        public ScsTcpEndPoint(string ipAddress, int port)
        {
            IpAddress = ipAddress;
            TcpPort = port;
        }

        // Создает новую точку ScsTcpEndPoint из строкового адреса.
        // Формат адреса должен быть похож на IPAddress:Port (например: 127.0.0.1:10085).
        // "address" - Адрес конечной точки TCP
        // Возврат - Созданный объект ScsTcpEndpoint
        public ScsTcpEndPoint(string address)
        {
            var splittedAddress = address.Trim().Split(':');
            IpAddress = splittedAddress[0].Trim();
            TcpPort = Convert.ToInt32(splittedAddress[1].Trim());
        }

        // Создает новый объект ScsTcpEndPoint с указанным номером порта.
        // "tcpPort" - Прослушивание TCP-порта для входящих запросов на подключение на сервере
        public ScsTcpEndPoint(int tcpPort)
        {
            TcpPort = tcpPort;
        }

        // IP-адрес сервера.
        public string IpAddress { get; set; }

        // Прослушиваемый TCP-порт для входящих запросов на подключение на сервере.
        public int TcpPort { get; private set; }

        // Создает сервер Scs, который использует эту конечную точку для прослушивания входящих подключений.
        // Возврат - Сервер Scs
        internal override IScsServer CreateServer()
        {
            return new ScsTcpServer(this);
        }

        // Создает Scs-клиент, который использует эту конечную точку для подключения к серверу.
        // Возврат - Клиент Scs
        internal override IScsClient CreateClient()
        {
            return new ScsTcpClient(this);
        }

        // Генерирует строковое представление этого объекта конечной точки.
        // Возврат - Строковое представление этого объекта конечной точки
        public override string ToString()
        {
            return string.IsNullOrEmpty(IpAddress) ? ("tcp://" + TcpPort) : ("tcp://" + IpAddress + ":" + TcpPort);
        }
    }
    //=========================================================================================================================================
}

namespace Hik.Communication.Scs.Communication.EndPoints
{
    // Представляет конечную точку на стороне сервера в SCS.
    public abstract class ScsEndPoint
    {
        // Создайте конечную точку Scs из строки.
        // Адрес должен быть отформатирован как: protocol://address
        // Например: tcp://89.43.104.179:10048 для конечной точки TCP с
        // IP 89.43.104.179 и портом 10048.
        // "endPointAddress" - Адрес для создания конечной точки
        // Возврат - Созданная конечная точка
        public static ScsEndPoint CreateEndPoint(string endPointAddress)
        {
            // Проверьте, является ли адрес конечной точки нулевым.
            if (string.IsNullOrEmpty(endPointAddress))
            {
                throw new ArgumentNullException("endPointAddress");
            }

            // Если протокол не указан, предположим, что TCP.
            var endPointAddr = endPointAddress;
            if (!endPointAddr.Contains("://"))
            {
                endPointAddr = "tcp://" + endPointAddr;
            }

            // Разделить части протокола и адреса.
            var splittedEndPoint = endPointAddr.Split(new[] { "://" }, StringSplitOptions.RemoveEmptyEntries);
            if (splittedEndPoint.Length != 2)
            {
                throw new ApplicationException(endPointAddress + " is not a valid endpoint address.");
            }

            // Разделите конечную точку, найдите протокол и адрес.
            var protocol = splittedEndPoint[0].Trim().ToLower();
            var address = splittedEndPoint[1].Trim();
            switch (protocol)
            {
                case "tcp":
                    return new ScsTcpEndPoint(address);
                default:
                    throw new ApplicationException("Неподдерживаемый протокол " + protocol + " в конечной точке " + endPointAddress);
            }
        }

        // Создает сервер Scs, который использует эту конечную точку для прослушивания входящих подключений.
        // Возврат - Scs Сервер
        internal abstract IScsServer CreateServer();

        // Создает сервер Scs, который использует эту конечную точку для подключения к серверу.
        // Возврат - Scs Клиент
        internal abstract IScsClient CreateClient();
    }
    //=========================================================================================================================================
}

namespace Hik.Communication.Scs.Communication.Messages
{
    // Представляет сообщение, которое отправляется и принимается сервером и клиентом.
    public interface IScsMessage
    {
        // Уникальный идентификатор для этого сообщения. 
        string MessageId { get; }

        // Уникальный идентификатор для этого сообщения. 
        string RepliedMessageId { get; set; }
    }
    //=========================================================================================================================================
    // Это сообщение используется для отправки/получения сообщений ping.
    // Ping-сообщения используются для поддержания соединения между сервером и клиентом.
    [Serializable]
    public sealed class ScsPingMessage : ScsMessage
    {
        // Создает новый объект PingMessage.
        public ScsPingMessage()
        {

        }

        // Создает новый объект ответа PingMessage.
        // "repliedMessageId" - Идентификатор ответившего сообщения, если это ответ на сообщение.
        public ScsPingMessage(string repliedMessageId)
            : this()
        {
            RepliedMessageId = repliedMessageId;
        }

        // Создает строку, представляющую этот объект.
        // Возврат - Строка to представляет этот объект
        public override string ToString()
        {
            return string.IsNullOrEmpty(RepliedMessageId)
                       ? string.Format("ScsPingMessage [{0}]", MessageId)
                       : string.Format("ScsPingMessage [{0}] Replied To [{1}]", MessageId, RepliedMessageId);
        }
    }
    //=========================================================================================================================================
    // Представляет сообщение, которое отправляется и принимается сервером и клиентом.
    // Это базовый класс для всех сообщений.
    [Serializable]
    public class ScsMessage : IScsMessage
    {
        // Уникальный идентификатор для этого сообщения.
        // Значение по умолчанию: Новый идентификатор GUID.
        // Не изменяйте, если вы не хотите вносить низкоуровневые изменения, такие как пользовательские проводные протоколы.
        public string MessageId { get; set; }

        // Это свойство используется, чтобы указать, что это ответное сообщение на сообщение.
        // Это может быть значение null, если это не ответное сообщение.
        public string RepliedMessageId { get; set; }

        // Создает новое ScsMessage.
        public ScsMessage()
        {
            MessageId = Guid.NewGuid().ToString();
        }

        // Создает новый ответ ScsMessage.
        // "repliedMessageId" - Идентификатор ответившего сообщения, если это ответ на сообщение.
        public ScsMessage(string repliedMessageId)
            : this()
        {
            RepliedMessageId = repliedMessageId;
        }

        // Создает строку, представляющую этот объект.
        // Возврат - Строка to представляет этот объект
        public override string ToString()
        {
            return string.IsNullOrEmpty(RepliedMessageId)
                       ? string.Format("ScsMessage [{0}]", MessageId)
                       : string.Format("ScsMessage [{0}] Replied To [{1}]", MessageId, RepliedMessageId);
        }
    }
    //=========================================================================================================================================

    // Это сообщение используется для отправки/получения необработанного массива байтов в качестве данных сообщения.
    [Serializable]
    public class ScsRawDataMessage : ScsMessage
    {
        // Данные сообщения, которые передаются.
        public byte[] MessageData { get; set; }

        // Пустой конструктор по умолчанию.
        public ScsRawDataMessage()
        {

        }

        // Создает новый объект ScsRawDataMessage со свойством MessageData.
        // "messageData" - Данные сообщения, которые передаются.
        public ScsRawDataMessage(byte[] messageData)
        {
            MessageData = messageData;
        }

        // Создает новый объект копию ScsRawDataMessage со свойством MessageData.
        // "messageData" - Данные сообщения, которые передаются.
        // "repliedMessageId" - Идентификатор ответившего сообщения, если это ответ на сообщение.
        public ScsRawDataMessage(byte[] messageData, string repliedMessageId)
            : this(messageData)
        {
            RepliedMessageId = repliedMessageId;
        }

        // Создает строку, представляющую этот объект.
        // Возврат - Строка to представляет этот объект
        public override string ToString()
        {
            var messageLength = MessageData == null ? 0 : MessageData.Length;
            return string.IsNullOrEmpty(RepliedMessageId)
                       ? string.Format("ScsRawDataMessage [{0}]: {1} bytes", MessageId, messageLength)
                       : string.Format("ScsRawDataMessage [{0}] Replied To [{1}]: {2} bytes", MessageId, RepliedMessageId, messageLength);
        }
    }
    //=========================================================================================================================================

    // Это сообщение используется для отправки/получения текста в качестве данных сообщения.
    [Serializable]
    public class ScsTextMessage : ScsMessage
    {
        // Текст сообщения, который передается.
        public string Text { get; set; }

        // Создает новый объект ScsTextMessage.
        public ScsTextMessage()
        {

        }

        // Создает новый объект ScsTextMessage со свойством Text.
        // "text" - Текст сообщения, который передается.
        public ScsTextMessage(string text)
        {
            Text = text;
        }

        // Создает новый объект ScsTextMessage со свойством Text.
        // "text" - Текст сообщения, который передается.
        // "repliedMessageId" - Идентификатор ответившего сообщения, если это ответ на сообщение.
        public ScsTextMessage(string text, string repliedMessageId)
            : this(text)
        {
            RepliedMessageId = repliedMessageId;
        }

        // Создает строку, представляющую этот объект.
        // Возврат - Строка to представляет этот объект
        public override string ToString()
        {
            return string.IsNullOrEmpty(RepliedMessageId)
                       ? string.Format("ScsTextMessage [{0}]: {1}", MessageId, Text)
                       : string.Format("ScsTextMessage [{0}] Replied To [{1}]: {2}", MessageId, RepliedMessageId, Text);
        }
    }
    //=========================================================================================================================================

}

namespace Hik.Communication.Scs.Communication.Messengers
{
    // Представляет объект, который может отправлять и получать сообщения.
    public interface IMessenger
    {
        // Это событие возникает при получении нового сообщения.
        event EventHandler<MessageEventArgs> MessageReceived;

        // Это событие возникает, когда новое сообщение отправляется без какой-либо ошибки.
        // Это не гарантирует, что сообщение будет должным образом обработано удаленным приложением.
        event EventHandler<MessageEventArgs> MessageSent;

        // Получает/устанавливает проводной протокол, который используется при чтении и записи сообщений.
        IScsWireProtocol WireProtocol { get; set; }

        // Получает время последнего успешно полученного сообщения.
        DateTime LastReceivedMessageTime { get; }

        // Получает время последнего успешно отправленного сообщения.
        DateTime LastSentMessageTime { get; }

        // Отправляет сообщение удаленному приложению.
        // "message" - Сообщение, которое нужно отправить.
        void SendMessage(IScsMessage message);
    }
    //=========================================================================================================================================
    // Этот класс добавляет методы SendMessageAndWaitForResponse(...) и SendAndReceiveMessage в IMessenger для синхронного обмена сообщениями в стиле запроса/ответа.
    // Он также добавляет обработку входящих сообщений в очереди.
    // "T" - Тип объекта IMessenger для использования в качестве базового сообщения
    public class RequestReplyMessenger<T> : IMessenger, IDisposable where T : IMessenger
    {
        #region Public events

        // Это событие возникает при получении нового сообщения от базового мессенджера.
        public event EventHandler<MessageEventArgs> MessageReceived;

        // Это событие возникает, когда новое сообщение отправляется без какой-либо ошибки.
        // Это не гарантирует, что сообщение будет должным образом обработано удаленным приложением.
        public event EventHandler<MessageEventArgs> MessageSent;

        #endregion

        #region Public properties

        // Получает/устанавливает проводной протокол, который используется при чтении и записи сообщений.
        public IScsWireProtocol WireProtocol
        {
            get { return Messenger.WireProtocol; }
            set { Messenger.WireProtocol = value; }
        }

        // Получает время последнего успешно полученного сообщения.
        public DateTime LastReceivedMessageTime
        {
            get
            {
                return Messenger.LastReceivedMessageTime;
            }
        }

        // Получает время последнего успешно отправленного сообщения.
        public DateTime LastSentMessageTime
        {
            get
            {
                return Messenger.LastSentMessageTime;
            }
        }

        // Получает базовый объект IMessenger.
        public T Messenger { get; private set; }

        // Значение таймаута в миллисекундах для ожидания получения сообщения с помощью методов SendMessageAndWaitForResponse и SendAndReceiveMessage.
        // Значение по умолчанию: 60000 (1 minute).
        public int Timeout { get; set; }

        #endregion

        #region Private fields

        // Значение тайм-аута по умолчанию.
        private const int DefaultTimeout = 60000;

        // Эти сообщения ожидают ответа, которые используются при вызове SendMessageAndWaitForResponse.
        // Key: MessageID ожидающего сообщения с запросом.
        // Value: Экземпляр WaitingMessage.
        private readonly SortedList<string, WaitingMessage> _waitingMessages;

        // Этот объект используется для последовательной обработки входящих сообщений.
        private readonly SequentialItemProcessor<IScsMessage> _incomingMessageProcessor;

        // Этот объект используется для синхронизации потоков.
        private readonly object _syncObj = new object();

        #endregion

        #region Constructor

        // Создает новый RequestReplyMessenger.
        // "messenger" - Объект IMessenger для использования в качестве базового сообщения.
        public RequestReplyMessenger(T messenger)
        {
            Messenger = messenger;
            messenger.MessageReceived += Messenger_MessageReceived;
            messenger.MessageSent += Messenger_MessageSent;
            _incomingMessageProcessor = new SequentialItemProcessor<IScsMessage>(OnMessageReceived);
            _waitingMessages = new SortedList<string, WaitingMessage>();
            Timeout = DefaultTimeout;
        }

        #endregion

        #region Public methods

        // Запускает мессенджер.
        public virtual void Start()
        {
            _incomingMessageProcessor.Start();
        }

        // Останавливает посыльного.
        // Отменяет все ожидающие потоки в методе SendMessageAndWaitForResponse и останавливает очередь сообщений.
        // Метод SendMessageAndWaitForResponse выдает исключение, если существует поток, ожидающий ответного сообщения.
        // Также останавливает обработку входящих сообщений и удаляет все сообщения в очереди входящих сообщений.
        public virtual void Stop()
        {
            _incomingMessageProcessor.Stop();

            //Импульсные потоки ожидания входящих сообщений, поскольку базовый мессенджер отключен и больше не может получать сообщения.
            lock (_syncObj)
            {
                foreach (var waitingMessage in _waitingMessages.Values)
                {
                    waitingMessage.State = WaitingMessageStates.Cancelled;
                    waitingMessage.WaitEvent.Set();
                }

                _waitingMessages.Clear();
            }
        }

        // Вызывает метод Stop этого объекта.
        public void Dispose()
        {
            Stop();
        }

        // Отправляет сообщение.
        // "message" - Сообщение, которое нужно отправить.
        public void SendMessage(IScsMessage message)
        {
            Messenger.SendMessage(message);
        }

        // Отправляет сообщение и ожидает ответа на это сообщение.
        // Замечание - Ответное сообщение сопоставляется со свойством RepliedMessageId, поэтому, если из удаленного приложения получено какое-либо 
        // другое сообщение (которое не является ответом на отправленное сообщение), оно не рассматривается как ответ и не возвращается как 
        // возвращаемое значение этого метода.
        // Событие MessageReceived не вызывается для ответных сообщений.
        // "message" - сообщение для отправки.
        // Возврат - Ответное сообщение
        public IScsMessage SendMessageAndWaitForResponse(IScsMessage message)
        {
            return SendMessageAndWaitForResponse(message, Timeout);
        }

        // Отправляет сообщение и ожидает ответа на это сообщение.
        // Ответное сообщение сопоставляется со свойством RepliedMessageId, поэтому, если из удаленного приложения получено какое-либо 
        // другое сообщение (которое не является ответом на отправленное сообщение), оно не рассматривается как ответ и не возвращается 
        // как возвращаемое значение этого метода.
        // Событие MessageReceived не вызывается для ответных сообщений.
        // "message" - сообщение для отправки.
        // "timeoutMilliseconds" - Продолжительность тайм-аута в миллисекундах.
        // Возврат - Ответное сообщение
        // Исключение - "TimeoutException" - Выдает исключение TimeoutException, если не удается получить ответное сообщение в значении тайм-аута
        // Исключение - "CommunicationException" - Выдает исключение CommunicationException, если связь завершается неудачей перед ответным сообщением.
        public IScsMessage SendMessageAndWaitForResponse(IScsMessage message, int timeoutMilliseconds)
        {
            //Создайте запись ожидающего сообщения и добавьте в список
            var waitingMessage = new WaitingMessage();
            lock (_syncObj)
            {
                _waitingMessages[message.MessageId] = waitingMessage;
            }

            try
            {
                //Отправить сообщение
                Messenger.SendMessage(message);

                //Дождитесь ответа
                waitingMessage.WaitEvent.Wait(timeoutMilliseconds);

                //Проверьте наличие исключений
                switch (waitingMessage.State)
                {
                    case WaitingMessageStates.WaitingForResponse:
                        throw new TimeoutException("Timeout occured. Can not received response.");
                    case WaitingMessageStates.Cancelled:
                        throw new CommunicationException("Disconnected before response received.");
                }

                //вернуть ответное сообщение
                return waitingMessage.ResponseMessage;
            }
            finally
            {
                //Удалить сообщение из ожидающих сообщений
                lock (_syncObj)
                {
                    if (_waitingMessages.ContainsKey(message.MessageId))
                    {
                        _waitingMessages.Remove(message.MessageId);
                    }
                }
            }
        }

        #endregion

        #region Private methods

        // Обрабатывает событие MessageReceived объекта Messenger.
        // "sender" - Источник события.
        // "e" - Аргументы события.
        private void Messenger_MessageReceived(object sender, MessageEventArgs e)
        {
            //Проверьте, есть ли ожидающий поток для этого сообщения в методе SendMessageAndWaitForResponse
            if (!string.IsNullOrEmpty(e.Message.RepliedMessageId))
            {
                WaitingMessage waitingMessage = null;
                lock (_syncObj)
                {
                    if (_waitingMessages.ContainsKey(e.Message.RepliedMessageId))
                    {
                        waitingMessage = _waitingMessages[e.Message.RepliedMessageId];
                    }
                }

                //Если есть поток, ожидающий этого ответного сообщения, отправьте его импульсом
                if (waitingMessage != null)
                {
                    waitingMessage.ResponseMessage = e.Message;
                    waitingMessage.State = WaitingMessageStates.ResponseReceived;
                    waitingMessage.WaitEvent.Set();
                    return;
                }
            }

            _incomingMessageProcessor.EnqueueMessage(e.Message);
        }

        // Обрабатывает событие messageSent объекта Messenger.
        // "sender" - Источник события.
        // "e" - Аргументы события.
        private void Messenger_MessageSent(object sender, MessageEventArgs e)
        {
            OnMessageSent(e.Message);
        }

        #endregion

        #region Event raising methods

        // Вызывает событие MessageReceived.
        // "message" - Полученное сообщение.
        protected virtual void OnMessageReceived(IScsMessage message)
        {
            var handler = MessageReceived;
            if (handler != null)
            {
                handler(this, new MessageEventArgs(message));
            }
        }

        // Вызывает событие messageSent.
        // "message" - Полученное сообщение.
        protected virtual void OnMessageSent(IScsMessage message)
        {
            var handler = MessageSent;
            if (handler != null)
            {
                handler(this, new MessageEventArgs(message));
            }
        }

        #endregion

        #region WaitingMessage class

        // Этот класс используется для хранения контекста обмена сообщениями для сообщения-запроса до получения ответа.
        private sealed class WaitingMessage
        {
            // Сообщение-ответ на сообщение-запрос (null, если ответ еще не получен).
            public IScsMessage ResponseMessage { get; set; }

            // ManualResetEvent блокирует поток до тех пор, пока не будет получен ответ.
            public ManualResetEventSlim WaitEvent { get; private set; }

            // Состояние сообщения с запросом.
            public WaitingMessageStates State { get; set; }

            // Создает новый объект WaitingMessage.
            public WaitingMessage()
            {
                WaitEvent = new ManualResetEventSlim(false);
                State = WaitingMessageStates.WaitingForResponse;
            }
        }

        // Это перечисление используется для хранения состояния ожидающего сообщения.
        private enum WaitingMessageStates
        {
            // Все еще жду ответа.
            WaitingForResponse,

            // Отправка сообщения отменена.
            Cancelled,

            // Ответ получен должным образом.
            ResponseReceived
        }

        #endregion
    }
    //=========================================================================================================================================

    // Этот класс является оболочкой для IMessenger и используется для синхронизации операции получения сообщений.
    // Это расширяет RequestReplyMessenger.
    // Он подходит для использования в приложениях, которые хотят получать сообщения с помощью синхронизированных вызовов методов вместо асинхронного события MessageReceived.
    public class SynchronizedMessenger<T> : RequestReplyMessenger<T> where T : IMessenger
    {
        #region Public properties

        // Получает/устанавливает емкость очереди входящих сообщений.
        // Никакое сообщение не будет получено от удаленного приложения, если количество сообщений во внутренней очереди превышает это значение.
        // Значение по умолчанию: int.MaxValue (2147483647).
        public int IncomingMessageQueueCapacity { get; set; }

        #endregion

        #region Private fields

        // Очередь, которая используется для хранения получаемых сообщений до тех пор, пока для их получения не будет вызван метод Receive(...).
        private readonly Queue<IScsMessage> _receivingMessageQueue;

        // Этот объект используется для синхронизации/ожидания потоков.
        private readonly ManualResetEventSlim _receiveWaiter;

        // Это логическое значение указывает на состояние выполнения этого класса.
        private volatile bool _running;

        #endregion

        #region Constructors

        // Создает новый объект SynchronizedMessenger.
        // "messenger" - Объект IMessenger, который будет использоваться для отправки /получения сообщений.
        public SynchronizedMessenger(T messenger)
            : this(messenger, int.MaxValue)
        {

        }

        // Создает новый объект SynchronizedMessenger.
        // "messenger" - Объект IMessenger, который будет использоваться для отправки /получения сообщений.
        // "incomingMessageQueueCapacity" - емкость очереди входящих сообщений.
        public SynchronizedMessenger(T messenger, int incomingMessageQueueCapacity)
            : base(messenger)
        {
            _receiveWaiter = new ManualResetEventSlim();
            _receivingMessageQueue = new Queue<IScsMessage>();
            IncomingMessageQueueCapacity = incomingMessageQueueCapacity;
        }

        #endregion

        #region Public methods

        // Запускает мессенджер.
        public override void Start()
        {
            lock (_receivingMessageQueue)
            {
                _running = true;
            }

            base.Start();
        }

        // Останавливает посыльного.
        public override void Stop()
        {
            base.Stop();

            lock (_receivingMessageQueue)
            {
                _running = false;
                _receiveWaiter.Set();
            }
        }

        // Этот метод используется для получения сообщения от удаленного приложения.
        // Он ожидает, пока не будет получено сообщение.
        // Возврат - Полученное сообщение
        public IScsMessage ReceiveMessage()
        {
            return ReceiveMessage(System.Threading.Timeout.Infinite);
        }

        // Этот метод используется для получения сообщения от удаленного приложения.
        // Он ожидает, пока не будет получено сообщение или не наступит тайм-аут.
        // "timeout" - Значение тайм-аута для ожидания, если сообщение не получено.
        // Используйте -1, чтобы ждать бесконечно.
        // Возврат - Полученное сообщение
        // Исключение - "TimeoutException" - Выдает исключение TimeoutException, если происходит тайм-аут
        // Исключение - "Exception" - Выдает исключение, если SynchronizedMessenger останавливается до получения сообщения
        public IScsMessage ReceiveMessage(int timeout)
        {
            while (_running)
            {
                lock (_receivingMessageQueue)
                {
                    //Проверьте, запущен ли SynchronizedMessenger
                    if (!_running)
                    {
                        throw new Exception("SynchronizedMessenger is stopped. Can not receive message.");
                    }

                    //Немедленно получите сообщение, если какое-либо сообщение действительно существует
                    if (_receivingMessageQueue.Count > 0)
                    {
                        return _receivingMessageQueue.Dequeue();
                    }

                    _receiveWaiter.Reset();
                }

                //Дождитесь сообщения
                var signalled = _receiveWaiter.Wait(timeout);

                //Если сигнал не подан, выдайте исключение
                if (!signalled)
                {
                    throw new TimeoutException("Timeout occured. Can not received any message");
                }
            }

            throw new Exception("SynchronizedMessenger is stopped. Can not receive message.");
        }

        // Этот метод используется для получения определенного типа сообщения от удаленного приложения.
        // Он ожидает, пока не будет получено сообщение.
        // Возврат - Полученное сообщение
        public TMessage ReceiveMessage<TMessage>() where TMessage : IScsMessage
        {
            return ReceiveMessage<TMessage>(System.Threading.Timeout.Infinite);
        }

        // Этот метод используется для получения определенного типа сообщения от удаленного приложения.
        // Он ожидает, пока не будет получено сообщение или не наступит тайм-аут.
        // "timeout" - Значение тайм-аута для ожидания, если сообщение не получено.
        // Use -1 to wait indefinitely.
        // Возврат - Полученное сообщение
        public TMessage ReceiveMessage<TMessage>(int timeout) where TMessage : IScsMessage
        {
            var receivedMessage = ReceiveMessage(timeout);
            if (!(receivedMessage is TMessage))
            {
                throw new Exception("Unexpected message received." +
                                    " Expected type: " + typeof(TMessage).Name +
                                    ". Received message type: " + receivedMessage.GetType().Name);
            }

            return (TMessage)receivedMessage;
        }

        #endregion

        #region Protected methods

        // Переопределяет
        protected override void OnMessageReceived(IScsMessage message)
        {
            lock (_receivingMessageQueue)
            {
                if (_receivingMessageQueue.Count < IncomingMessageQueueCapacity)
                {
                    _receivingMessageQueue.Enqueue(message);
                }

                _receiveWaiter.Set();
            }
        }

        #endregion
    }
    //=========================================================================================================================================
}

namespace Hik.Communication.Scs.Communication.Protocols.BinarySerialization
{
    // Протокол связи по умолчанию между сервером и клиентами для отправки и получения сообщения.
    // Он использует двоичную сериализацию .NET для записи и чтения сообщений.
    // 
    // Формат сообщения:
    // [Message Length (4 bytes)][Serialized Message Content]
    // 
    // Если сообщение сериализуется в массив байтов в виде N байт, этот протокол добавляет информацию о размере 4 байт к 
    // заголовку байтов сообщения, так что общая длина составляет (4 + N) байт.
    // 
    // Этот класс может быть получен для изменения сериализатора (по умолчанию: BinaryFormatter). Для этого методы SerializeMessage и 
    // DeserializeMessage должны быть переопределены.
    public class BinarySerializationProtocol : IScsWireProtocol
    {
        #region Private fields

        // Максимальная длина сообщения.
        private const int MaxMessageLength = 128 * 1024 * 1024; //128 Megabytes.

        // Этот объект MemoryStream используется для сбора байтов приема для построения сообщений.
        private MemoryStream _receiveMemoryStream;

        #endregion

        #region Constructor

        // Создает новый экземпляр BinarySerializationProtocol.
        public BinarySerializationProtocol()
        {
            _receiveMemoryStream = new MemoryStream();
        }

        #endregion

        #region IScsWireProtocol implementation

        // Сериализует сообщение в массив байтов для отправки удаленному приложению.
        // Этот метод синхронизирован. Таким образом, только один поток может вызывать его одновременно.
        // "message" - Сообщение, подлежащее сериализации.
        // Исключение - "CommunicationException" - Выдает исключение CommunicationException, если сообщение больше максимально допустимой длины сообщения.
        public byte[] GetBytes(IScsMessage message)
        {
            //Сериализуйте сообщение в массив байтов
            var serializedMessage = SerializeMessage(message);

            //Проверьте длину сообщения
            var messageLength = serializedMessage.Length;
            if (messageLength > MaxMessageLength)
            {
                throw new CommunicationException("Message is too big (" + messageLength + " bytes). Max allowed length is " + MaxMessageLength + " bytes.");
            }

            //Создайте массив байтов, включающий длину сообщения (4 байта) и сериализованное содержимое сообщения
            var bytes = new byte[messageLength + 4];
            WriteInt32(bytes, 0, messageLength);
            Array.Copy(serializedMessage, 0, bytes, 4, messageLength);

            //Возвращает сериализованное сообщение по этому протоколу
            return bytes;
        }

        // Создает сообщения из массива байтов, полученного из удаленного приложения.
        // Массив байтов может содержать только часть сообщения, протокол должен накапливать байты для построения сообщений.
        // 
        // Этот метод синхронизирован. Таким образом, только один поток может вызывать его одновременно.
        // "receivedBytes" - Полученные байты от удаленного приложения.
        // Возврат - Список сообщений.
        // Протокол может генерировать более одного сообщения из массива байтов.
        // Кроме того, если полученных байтов недостаточно для построения сообщения, протокол может вернуть пустой список 
        // (и сохранить байты для объединения со следующим вызовом метода).
        public IEnumerable<IScsMessage> CreateMessages(byte[] receivedBytes)
        {
            // Запишите все полученные байты в _receiveMemoryStream
            _receiveMemoryStream.Write(receivedBytes, 0, receivedBytes.Length);
		
            // Создайте список для сбора сообщений
            var messages = new List<IScsMessage>();
		
            // Прочитайте все доступные сообщения и добавьте в коллекцию сообщений
            while (ReadSingleMessage(messages)) { }
		
            // Список возвращаемых сообщений
            return messages;
        }

        // Этот метод вызывается при сбросе соединения с удаленным приложением (возобновлении соединения или первом подключении).
        // Итак, проводной протокол должен сбросить сам себя.
        public void Reset()
        {
            if (_receiveMemoryStream.Length > 0)
            {
                _receiveMemoryStream = new MemoryStream();
            }
        }

        #endregion

        #region Proptected virtual methods

        // Этот метод используется для сериализации IScsMessage в массив байтов.
        // Этот метод может быть переопределен производными классами для изменения стратегии сериализации.
        // Это пара с методом DeserializeMessage, и они должны быть переопределены вместе.
        // "message" - Сообщение, подлежащее сериализации.
        // Сериализованные байты сообщения.
        // Не включает длину сообщения.
        protected virtual byte[] SerializeMessage(IScsMessage message)
        {
            using (var memoryStream = new MemoryStream())
            {
                new BinaryFormatter().Serialize(memoryStream, message);
                return memoryStream.ToArray();
            }
        }

        // Этот метод используется для десериализации IScsMessage из его байтов.
        // Этот метод может быть переопределен производными классами для изменения стратегии десериализации.
        // Это пара с методом SerializeMessage, и они должны быть переопределены вместе.
        // "bytes" - Байты сообщения, подлежащего десериализации (не включает длину сообщения.
        // Оно состоит из одного целого сообщения).
        // Возврат - Десериализованное сообщение
        protected virtual IScsMessage DeserializeMessage(byte[] bytes)
        {
            //Создайте MemoryStream для преобразования байтов в поток
            using (var deserializeMemoryStream = new MemoryStream(bytes))
            {
                //Идите к началу потока
                deserializeMemoryStream.Position = 0;

                //Десериализуйте сообщение
                var binaryFormatter = new BinaryFormatter
                {
                    AssemblyFormat = System.Runtime.Serialization.Formatters.FormatterAssemblyStyle.Simple,
                    Binder = new DeserializationAppDomainBinder()
                };

                //Верните десериализованное сообщение
                return (IScsMessage)binaryFormatter.Deserialize(deserializeMemoryStream);
            }
        }

        #endregion

        #region Private methods

        // Этот метод пытается прочитать одно сообщение и добавить его в коллекцию сообщений. 
        // "messages" - Коллекция сообщений для сбора сообщений.
        // Возвращает логическое значение, указывающее на то, что при необходимости необходимо повторно вызвать этот метод.
        // Исключение - "CommunicationException" - Выдает исключение CommunicationException, если сообщение больше максимально допустимой длины сообщения.
        private bool ReadSingleMessage(ICollection<IScsMessage> messages)
        {
            //Идите к началу потока
            _receiveMemoryStream.Position = 0;

            //Если поток содержит менее 4 байт, это означает, что мы даже не можем прочитать длину сообщения
            //Итак, верните значение false, чтобы дождаться дополнительных байтов от приложения remore.
            if (_receiveMemoryStream.Length < 4)
            {
                return false;
            }

            //Прочитанная длина сообщения
            var messageLength = ReadInt32(_receiveMemoryStream);
            if (messageLength > MaxMessageLength)
            {
                throw new Exception("Message is too big (" + messageLength + " bytes). Max allowed length is " + MaxMessageLength + " bytes.");
            }

            //Если сообщение имеет нулевую длину (это не должно быть, но хороший подход для его проверки)
            if (messageLength == 0)
            {
                //если больше нет байтов, немедленно верните
                if (_receiveMemoryStream.Length == 4)
                {
                    _receiveMemoryStream = new MemoryStream(); //Clear the stream
                    return false;
                }

                //Создайте новый поток памяти из текущего, за исключением первых 4 байт.
                var bytes = _receiveMemoryStream.ToArray();
                _receiveMemoryStream = new MemoryStream();
                _receiveMemoryStream.Write(bytes, 4, bytes.Length - 4);
                return true;
            }

            //Если все байты сообщения еще не получены, вернитесь, чтобы дождаться дополнительных байтов
            if (_receiveMemoryStream.Length < (4 + messageLength))
            {
                _receiveMemoryStream.Position = _receiveMemoryStream.Length;
                return false;
            }

            //Считайте байты сериализованного сообщения и десериализуйте его
            var serializedMessageBytes = ReadByteArray(_receiveMemoryStream, messageLength);
            messages.Add(DeserializeMessage(serializedMessageBytes));

            //Считывает оставшиеся байты в массив
            var remainingBytes = ReadByteArray(_receiveMemoryStream, (int)(_receiveMemoryStream.Length - (4 + messageLength)));

            //Повторно создайте поток приемной памяти и запишите оставшиеся байты
            _receiveMemoryStream = new MemoryStream();
            _receiveMemoryStream.Write(remainingBytes, 0, remainingBytes.Length);

            //Верните значение true для повторного вызова этого метода, чтобы попытаться прочитать следующее сообщение
            return (remainingBytes.Length > 4);
        }

        // Записывает значение int в массив байтов из начального индекса.
        // "buffer" - Массив байтов для записи значения int.
        // "startIndex" - Начальный индекс массива байтов для записи.
        // "number" - Целочисленное значение для записи.
        private static void WriteInt32(byte[] buffer, int startIndex, int number)
        {
            buffer[startIndex] = (byte)((number >> 24) & 0xFF);
            buffer[startIndex + 1] = (byte)((number >> 16) & 0xFF);
            buffer[startIndex + 2] = (byte)((number >> 8) & 0xFF);
            buffer[startIndex + 3] = (byte)((number) & 0xFF);
        }

        // Десериализует и возвращает сериализованное целое число.
        // Возврат - Десериализованное целое число
        private static int ReadInt32(Stream stream)
        {
            var buffer = ReadByteArray(stream, 4);
            return ((buffer[0] << 24) |
                    (buffer[1] << 16) |
                    (buffer[2] << 8) |
                    (buffer[3])
                   );
        }

        // Считывает массив байтов заданной длины.
        // "stream" - Поток для чтения из.
        // "length" - Длина массива байтов для чтения.
        // Возврат - Считанный массив байтов
        // Исключение - "EndOfStreamException" - Выдает исключение EndOfStreamException, если не удается прочитать из потока.
        private static byte[] ReadByteArray(Stream stream, int length)
        {
            var buffer = new byte[length];
            var totalRead = 0;
            while (totalRead < length)
            {
                var read = stream.Read(buffer, totalRead, length - totalRead);
                if (read <= 0)
                {
                    throw new EndOfStreamException("Can not read from stream! Input stream is closed.");
                }

                totalRead += read;
            }

            return buffer;
        }

        #endregion

        #region Nested classes

        // Этот класс используется при десериализации, чтобы разрешить десериализацию объектов, которые определены
        // в сборках, которые загружаются во время выполнения (например, плагины).
        protected sealed class DeserializationAppDomainBinder : SerializationBinder
        {
            public override Type BindToType(string assemblyName, string typeName)
            {
                var toAssemblyName = assemblyName.Split(',')[0];
                return (from assembly in AppDomain.CurrentDomain.GetAssemblies()
                        where assembly.FullName.Split(',')[0] == toAssemblyName
                        select assembly.GetType(typeName)).FirstOrDefault();
            }
        }

        #endregion
    }
    //=========================================================================================================================================

    // Этот класс используется для создания объектов протокола двоичной сериализации.
    public class BinarySerializationProtocolFactory : IScsWireProtocolFactory
    {
        // Создает новый объект проводного протокола.
        // Возврат - Вновь созданный объект проводного протокола
        public IScsWireProtocol CreateWireProtocol()
        {
            return new BinarySerializationProtocol();
        }
    }
    //=========================================================================================================================================

}

namespace Hik.Communication.Scs.Communication.Protocols
{
    // Представляет собой протокол связи на байтовом уровне между приложениями.
    public interface IScsWireProtocol
    {
        // Сериализует сообщение в массив байтов для отправки удаленному приложению.
        // Этот метод синхронизирован. Таким образом, только один поток может вызывать его одновременно.
        // "message" - Сообщение, подлежащее сериализации.
        byte[] GetBytes(IScsMessage message);

        // Создает сообщения из массива байтов, полученного из удаленного приложения.
        // Массив байтов может содержать только часть сообщения, протокол должен накапливать байты для построения сообщений.
        // Этот метод синхронизирован. Таким образом, только один поток может вызывать его одновременно.
        // "receivedBytes" - Полученные байты от удаленного приложения.
        // Возврат - 
        // Список сообщений.
        // Протокол может генерировать более одного сообщения из массива байтов.
        // Кроме того, если полученных байтов недостаточно для построения сообщения, протокол
        // может возвращать пустой список (и сохранять байты для объединения со следующим вызовом метода).
        IEnumerable<IScsMessage> CreateMessages(byte[] receivedBytes);

        // Этот метод вызывается при сбросе соединения с удаленным приложением (возобновлении соединения или первом подключении).
        // Итак, проводной протокол должен сбросить сам себя.
        void Reset();
    }
    //=========================================================================================================================================

    // Определяет класс Wire Protocol Factory, который используется для создания объектов Wire Protocol.
    public interface IScsWireProtocolFactory
    {
        // Создает новый объект проводного протокола.
        // Возврат - Вновь созданный объект проводного протокола
        IScsWireProtocol CreateWireProtocol();
    }
    //=========================================================================================================================================

    // Этот класс используется для получения протоколов по умолчанию.
    internal static class WireProtocolManager
    {
        // Создает заводской объект проводного протокола по умолчанию, который будет использоваться при обмене приложениями.
        // Возврат - Новый экземпляр проводного протокола по умолчанию
        public static IScsWireProtocolFactory GetDefaultWireProtocolFactory()
        {
            return new BinarySerializationProtocolFactory();
        }

        // Создает объект проводного протокола по умолчанию, который будет использоваться при взаимодействии приложений.
        // Возврат - Новый экземпляр проводного протокола по умолчанию
        public static IScsWireProtocol GetDefaultWireProtocol()
        {
            return new BinarySerializationProtocol();
        }
    }
    //=========================================================================================================================================
}

namespace Hik.Communication.Scs.Communication
{
    // Это приложение выдает ошибку связи.
    [Serializable]
    public class CommunicationException : Exception
    {
        // Конструктор.
        public CommunicationException()
        {

        }

        // Конструктор для сериализации.
        public CommunicationException(SerializationInfo serializationInfo, StreamingContext context)
            : base(serializationInfo, context)
        {

        }

        // Конструктор.
        // "message" - Сообщение об исключении.
        public CommunicationException(string message)
            : base(message)
        {

        }

        // Конструктор.
        // "message" - Сообщение об исключении.
        // "innerException" - Внутреннее исключение.
        public CommunicationException(string message, Exception innerException)
            : base(message, innerException)
        {

        }
    }
    //=========================================================================================================================================

    // Это приложение запускается, если связь не является ожидаемым состоянием.
    [Serializable]
    public class CommunicationStateException : CommunicationException
    {
        // Конструктор.
        public CommunicationStateException()
        {

        }

        // Конструктор для сериализации.
        public CommunicationStateException(SerializationInfo serializationInfo, StreamingContext context)
            : base(serializationInfo, context)
        {

        }

        // Конструктор.
        // "message" - Сообщение об исключении.
        public CommunicationStateException(string message)
            : base(message)
        {

        }

        // Конструктор.
        // "message" - Сообщение об исключении.
        // "innerException" - Внутреннее исключение.
        public CommunicationStateException(string message, Exception innerException)
            : base(message, innerException)
        {

        }
    }
    //=========================================================================================================================================

    // Состояния соединения.
    public enum CommunicationStates
    {
        // Подключен.
        Connected,

        // Отключен.
        Disconnected
    }
    //=========================================================================================================================================
}

#endregion Communication

#region ScsServices

namespace Hik.Communication.ScsServices.Service
{
    // Представляет приложение службы SCS, которое используется для создания службы SCS и управления ею.
    public interface IScsServiceApplication
    {
        // Это событие возникает, когда новый клиент подключается к сервису.
        event EventHandler<ServiceClientEventArgs> ClientConnected;

        // Это событие возникает, когда клиент отключается от службы.
        event EventHandler<ServiceClientEventArgs> ClientDisconnected;

        // Запускает сервисное приложение.
        void Start();

        // Останавливает сервисное приложение.
        void Stop();

        // Добавляет объект службы в это приложение-службу.
        // Для типа интерфейса службы может быть добавлен только один объект службы.
        // "TServiceInterface" - Тип сервисного интерфейса
        // "TServiceClass" - Тип класса обслуживания. Должен быть доставлен из ScsService и должен реализовывать TServiceInterface.
        // "service" - Экземпляр TServiceClass.
        void AddService<TServiceInterface, TServiceClass>(TServiceClass service)
            where TServiceClass : ScsService, TServiceInterface
            where TServiceInterface : class;

        // Удаляет ранее добавленный объект службы из этого приложения-службы.
        // Он удаляет объект в соответствии с типом интерфейса.
        // "TServiceInterface" - Тип сервисного интерфейса
        // Возврат - True: удалено. False: нет объекта службы с этим интерфейсом
        bool RemoveService<TServiceInterface>() where TServiceInterface : class;
    }
    //=========================================================================================================================================

    // Представляет клиента, который использует службу SDS.
    public interface IScsServiceClient
    {
        // Это событие возникает, когда клиент отключен от службы.
        event EventHandler Disconnected;

        // Уникальный идентификатор для этого клиента.
        long ClientId { get; }

        // Получает конечную точку удаленного приложения.
        ScsEndPoint RemoteEndPoint { get; }

        // Получает состояние связи Клиента.
        CommunicationStates CommunicationState { get; }

        // Закрывает клиентское соединение.
        void Disconnect();

        // Получает клиентский прокси-интерфейс, который обеспечивает удаленный вызов клиентских методов.
        // "T" - Тип клиентского интерфейса
        // Возврат - Клиентский интерфейс
        T GetClientProxy<T>() where T : class;
    }
    //=========================================================================================================================================

    // Базовый класс для всех служб, обслуживаемых IScsServiceApplication.
    // Класс должен быть производным от ScsService, чтобы служить в качестве службы SCS.
    public abstract class ScsService
    {
        // Текущий клиент для потока, который вызвал метод обслуживания.
        [ThreadStatic]
        private static IScsServiceClient _currentClient;

        // Это свойство является потокобезопасным, если возвращает правильный клиент, когда 
        // вызывается в сервисном методе, если метод вызывается системой SCS,
        // иначе выдает исключение.
        protected internal IScsServiceClient CurrentClient
        {
            get
            {
                if (_currentClient == null)
                {
                    throw new Exception("Client channel can not be obtained. CurrentClient property must be called by the thread which runs the service method.");
                }

                return _currentClient;
            }

            internal set
            {
                _currentClient = value;
            }
        }
    }
    //=========================================================================================================================================

    // Реализует IScsServiceApplication и обеспечивает всю функциональность.
    internal class ScsServiceApplication : IScsServiceApplication
    {
        #region Public events

        // Это событие возникает, когда новый клиент подключается к сервису.
        public event EventHandler<ServiceClientEventArgs> ClientConnected;

        // Это событие возникает, когда клиент отключается от службы.
        public event EventHandler<ServiceClientEventArgs> ClientDisconnected;

        #endregion

        #region Private fields

        // Базовый объект IScsServer для приема клиентских подключений и управления ими.
        private readonly IScsServer _scsServer;

        // Объекты пользовательского сервиса, которые используются для вызова входящих запросов на вызов метода.
        // Key: Имя типа интерфейса службы.
        // Value: Объект обслуживания.
        private readonly ThreadSafeSortedList<string, ServiceObject> _serviceObjects;

        // Все подключенные клиенты к сервису.
        // Key: Уникальный идентификатор клиента Id.
        // Value: Ссылка на клиента.
        private readonly ThreadSafeSortedList<long, IScsServiceClient> _serviceClients;

        #endregion

        #region Constructors

        // Создает новый объект ScsServiceApplication.
        // "scsServer" - Базовый объект IScsServer для приема клиентских подключений и управления ими.
        // Исключение - "ArgumentNullException" - Выдает исключение ArgumentNullException, если аргумент scsServer равен null
        public ScsServiceApplication(IScsServer scsServer)
        {
            if (scsServer == null)
            {
                throw new ArgumentNullException("scsServer");
            }

            _scsServer = scsServer;
            _scsServer.ClientConnected += ScsServer_ClientConnected;
            _scsServer.ClientDisconnected += ScsServer_ClientDisconnected;
            _serviceObjects = new ThreadSafeSortedList<string, ServiceObject>();
            _serviceClients = new ThreadSafeSortedList<long, IScsServiceClient>();
        }

        #endregion

        #region Public methods

        // Запускает сервисное приложение.
        public void Start()
        {
            _scsServer.Start();
        }

        // Останавливает сервисное приложение.
        public void Stop()
        {
            _scsServer.Stop();
        }

        // Добавляет объект службы в это приложение-службу.
        // Для типа интерфейса службы может быть добавлен только один объект службы.
        // "TServiceInterface" - Тип сервисного интерфейса
        // "TServiceClass" - Тип класса обслуживания. Должен быть доставлен из ScsService и должен реализовывать TServiceInterface.
        // "service" - Экземпляр TServiceClass.
        // Исключение - "ArgumentNullException" - Выдает исключение ArgumentNullException, если аргумент службы равен null
        // Исключение - "Exception" - Выдает исключение, если служба уже добавлена ранее
        public void AddService<TServiceInterface, TServiceClass>(TServiceClass service)
            where TServiceClass : ScsService, TServiceInterface
            where TServiceInterface : class
        {
            if (service == null)
            {
                throw new ArgumentNullException("service");
            }

            var type = typeof(TServiceInterface);
            if (_serviceObjects[type.Name] != null)
            {
                throw new Exception("Service '" + type.Name + "' is already added before.");
            }

            _serviceObjects[type.Name] = new ServiceObject(type, service);
        }

        // Удаляет ранее добавленный объект службы из этого приложения-службы.
        // Он удаляет объект в соответствии с типом интерфейса.
        // "TServiceInterface">Service interface type</typeparam>
        // Возврат - True: удален. False: нет объекта обслуживания с этим интерфейсом
        public bool RemoveService<TServiceInterface>()
            where TServiceInterface : class
        {
            return _serviceObjects.Remove(typeof(TServiceInterface).Name);
        }

        #endregion

        #region Private methods

        // Обрабатывает событие ClientConnected объекта _scsServer.
        // "sender" - Источник события.
        // "e" - Аргументы события.
        private void ScsServer_ClientConnected(object sender, ServerClientEventArgs e)
        {
            var requestReplyMessenger = new RequestReplyMessenger<IScsServerClient>(e.Client);
            requestReplyMessenger.MessageReceived += Client_MessageReceived;
            requestReplyMessenger.Start();

            var serviceClient = ScsServiceClientFactory.CreateServiceClient(e.Client, requestReplyMessenger);
            _serviceClients[serviceClient.ClientId] = serviceClient;
            OnClientConnected(serviceClient);
        }

        // Обрабатывает событие ClientDisconnected объекта _scsServer.
        // "sender" - Источник события.
        // "e" - Аргументы события.
        private void ScsServer_ClientDisconnected(object sender, ServerClientEventArgs e)
        {
            var serviceClient = _serviceClients[e.Client.ClientId];
            if (serviceClient == null)
            {
                return;
            }

            _serviceClients.Remove(e.Client.ClientId);
            OnClientDisconnected(serviceClient);
        }

        // Обрабатывает события MessageReceived всех клиентов, оценивает каждое сообщение, находит соответствующий объект службы и вызывает соответствующий метод.
        // "sender" - Источник события.
        // "e" - Аргументы события.
        private void Client_MessageReceived(object sender, MessageEventArgs e)
        {
            //Получить объект RequestReplyMessenger (отправитель события) для получения клиента
            var requestReplyMessenger = (RequestReplyMessenger<IScsServerClient>)sender;

            //Отправьте сообщение в ScsRemoteInvokeMessage и проверьте его
            var invokeMessage = e.Message as ScsRemoteInvokeMessage;
            if (invokeMessage == null)
            {
                return;
            }

            try
            {
                //Получить объект клиента
                var client = _serviceClients[requestReplyMessenger.Messenger.ClientId];
                if (client == null)
                {
                    requestReplyMessenger.Messenger.Disconnect();
                    return;
                }

                //Получить объект обслуживания
                var serviceObject = _serviceObjects[invokeMessage.ServiceClassName];
                if (serviceObject == null)
                {
                    SendInvokeResponse(requestReplyMessenger, invokeMessage, null, new ScsRemoteException("There is no service with name '" + invokeMessage.ServiceClassName + "'"));
                    return;
                }

                //Метод вызова
                try
                {
                    object returnValue;
                    //Установите для клиента значение service, чтобы пользовательская служба могла получить client
                    //в сервисном методе, использующем свойство CurrentClient.
                    serviceObject.Service.CurrentClient = client;
                    try
                    {
                        returnValue = serviceObject.InvokeMethod(invokeMessage.MethodName, invokeMessage.Parameters);
                    }
                    finally
                    {
                        //Установите CurrentClient равным null с момента завершения вызова метода
                        serviceObject.Service.CurrentClient = null;
                    }

                    //Отправить вызов метода, возвращающий значение клиенту
                    SendInvokeResponse(requestReplyMessenger, invokeMessage, returnValue, null);
                }
                catch (TargetInvocationException ex)
                {
                    var innerEx = ex.InnerException;
                    SendInvokeResponse(requestReplyMessenger, invokeMessage, null, new ScsRemoteException(innerEx.Message + Environment.NewLine + "Service Version: " + serviceObject.ServiceAttribute.Version, innerEx));
                    return;
                }
                catch (Exception ex)
                {
                    SendInvokeResponse(requestReplyMessenger, invokeMessage, null, new ScsRemoteException(ex.Message + Environment.NewLine + "Service Version: " + serviceObject.ServiceAttribute.Version, ex));
                    return;
                }
            }
            catch (Exception ex)
            {
                SendInvokeResponse(requestReplyMessenger, invokeMessage, null, new ScsRemoteException("An error occured during remote service method call.", ex));
                return;
            }
        }

        // Отправляет ответ удаленному приложению, которое вызвало метод службы.
        // "client" - Клиент, отправивший сообщение invoke.
        // "requestMessage" - Сообщение с запросом.
        // "returnValue" - Возвращаемое значение для отправки.
        // "exception" - Исключение для отправки.
        private static void SendInvokeResponse(IMessenger client, IScsMessage requestMessage, object returnValue, ScsRemoteException exception)
        {
            try
            {
                client.SendMessage(
                    new ScsRemoteInvokeReturnMessage
                    {
                        RepliedMessageId = requestMessage.MessageId,
                        ReturnValue = returnValue,
                        RemoteException = exception
                    });
            }
            catch
            {

            }
        }

        // Вызывает событие, связанное с клиентом.
        private void OnClientConnected(IScsServiceClient client)
        {
            var handler = ClientConnected;
            if (handler != null)
            {
                handler(this, new ServiceClientEventArgs(client));
            }
        }

        // Вызывает событие ClientDisconnected.
        private void OnClientDisconnected(IScsServiceClient client)
        {
            var handler = ClientDisconnected;
            if (handler != null)
            {
                handler(this, new ServiceClientEventArgs(client));
            }
        }

        #endregion

        #region ServiceObject class

        // Представляет объект пользовательского сервиса.
        // Он используется для вызова методов объекта ScsService.
        private sealed class ServiceObject
        {
            // Объект службы, который используется для вызова методов на.
            public ScsService Service { get; private set; }

            // Атрибут ScsService класса объекта Service.
            public ScsServiceAttribute ServiceAttribute { get; private set; }

            // В этой коллекции хранится список всех методов объекта service.
            // Key: Имя метода
            // Value: Информация о методе. 
            private readonly SortedList<string, MethodInfo> _methods;

            // Создает новый ServiceObject.
            // "serviceInterfaceType" - Тип интерфейса сервиса.
            // "service" - Объект службы, который используется для вызова методов на.
            public ServiceObject(Type serviceInterfaceType, ScsService service)
            {
                Service = service;
                var classAttributes = serviceInterfaceType.GetCustomAttributes(typeof(ScsServiceAttribute), true);
                if (classAttributes.Length <= 0)
                {
                    throw new Exception("Service interface (" + serviceInterfaceType.Name + ") must has ScsService attribute.");
                }

                ServiceAttribute = classAttributes[0] as ScsServiceAttribute;
                _methods = new SortedList<string, MethodInfo>();
                foreach (var methodInfo in serviceInterfaceType.GetMethods())
                {
                    _methods.Add(methodInfo.Name, methodInfo);
                }
            }

            // Вызывает метод объекта Service.
            // "methodName" - Имя метода для вызова.
            // "parameters" - Параметры метода.
            // Возврат - Возвращаемое значение метода
            public object InvokeMethod(string methodName, params object[] parameters)
            {
                //Проверьте, существует ли метод с именем methodName
                if (!_methods.ContainsKey(methodName))
                {
                    throw new Exception("There is not a method with name '" + methodName + "' in service class.");
                }

                //Метод получения
                var method = _methods[methodName];

                //Invoke method and return invoke result
                return method.Invoke(Service, parameters);
            }
        }

        #endregion
    }
    //=========================================================================================================================================

    // Любой класс интерфейса службы SCS должен иметь этот атрибут.
    [AttributeUsage(AttributeTargets.Interface | AttributeTargets.Class)]
    public class ScsServiceAttribute : Attribute
    {
        // Служебная версия. Это свойство может быть использовано для указания версии кода.
        // Это значение отправляется клиентскому приложению при возникновении исключения, поэтому клиентское приложение может знать, что версия сервиса изменена.
        // Значение по умолчанию: NO_VERSION.
        public string Version { get; set; }

        // Создает новый объект ScsServiceAttribute.
        public ScsServiceAttribute()
        {
            Version = "NO_VERSION";
        }
    }
    //=========================================================================================================================================

    // Этот класс используется для создания приложений ScsService.
    public static class ScsServiceBuilder
    {
        // Создает новое приложение-службу SCS, используя конечную точку.
        // "endPoint" - Конечная точка, представляющая адрес службы.
        // Возврат - Созданное приложение службы SCS
        public static IScsServiceApplication CreateService(ScsEndPoint endPoint)
        {
            return new ScsServiceApplication(ScsServerFactory.CreateServer(endPoint));
        }
    }
    //=========================================================================================================================================

    // Реализует IScsServiceClient.
    // Он используется для управления клиентом сервиса и мониторинга за ним.
    internal class ScsServiceClient : IScsServiceClient
    {
        #region Public events

        // Это событие возникает, когда этот клиент отключен от сервера.
        public event EventHandler Disconnected;

        #endregion

        #region Public properties

        // Уникальный идентификатор для этого клиента.
        public long ClientId
        {
            get { return _serverClient.ClientId; }
        }

        // Получает конечную точку удаленного приложения.
        public ScsEndPoint RemoteEndPoint
        {
            get { return _serverClient.RemoteEndPoint; }
        }

        // Получает состояние связи Клиента.
        public CommunicationStates CommunicationState
        {
            get
            {
                return _serverClient.CommunicationState;
            }
        }

        #endregion

        #region Private fields

        // Ссылка на базовый объект IScsServerClient.
        private readonly IScsServerClient _serverClient;

        // Этот объект используется для отправки сообщений клиенту.
        private readonly RequestReplyMessenger<IScsServerClient> _requestReplyMessenger;

        // Последний созданный прокси-объект для вызова удаленных методов.
        private RealProxy _realProxy;

        #endregion

        #region Constructor

        // Создает новый объект ScsServiceClient.
        // "serverClient" - Ссылка на базовый объект IScsServerClient.
        // "requestReplyMessenger" - RequestReplyMessenger для отправки сообщений.
        public ScsServiceClient(IScsServerClient serverClient, RequestReplyMessenger<IScsServerClient> requestReplyMessenger)
        {
            _serverClient = serverClient;
            _serverClient.Disconnected += Client_Disconnected;
            _requestReplyMessenger = requestReplyMessenger;
        }

        #endregion

        #region Public methods

        // Закрывает клиентское соединение.
        public void Disconnect()
        {
            _serverClient.Disconnect();
        }

        // Получает клиентский прокси-интерфейс, который обеспечивает удаленный вызов клиентских методов.
        // "T" - Тип клиентского интерфейса
        // Возврат - Клиентский интерфейс
        public T GetClientProxy<T>() where T : class
        {
            _realProxy = new RemoteInvokeProxy<T, IScsServerClient>(_requestReplyMessenger);
            return (T)_realProxy.GetTransparentProxy();
        }

        #endregion

        #region Private methods

        // Обрабатывает событие отключения объекта _serverClient.
        // "sender" - Источник события.
        // "e" - Аргументы события.
        private void Client_Disconnected(object sender, EventArgs e)
        {
            _requestReplyMessenger.Stop();
            OnDisconnected();
        }

        #endregion

        #region Event raising methods

        // Вызывает событие отключения.
        private void OnDisconnected()
        {
            var handler = Disconnected;
            if (handler != null)
            {
                handler(this, EventArgs.Empty);
            }
        }

        #endregion
    }
    //=========================================================================================================================================

    // Этот класс используется для создания объектов service client, которые используются на стороне сервера.
    internal static class ScsServiceClientFactory
    {
        // Создает новый объект клиента службы, который используется на стороне сервера.
        // "serverClient" - Базовый серверный клиентский объект.
        // "requestReplyMessenger" - Объект RequestReplyMessenger для отправки/получения сообщений через ServerClient.
        public static IScsServiceClient CreateServiceClient(IScsServerClient serverClient, RequestReplyMessenger<IScsServerClient> requestReplyMessenger)
        {
            return new ScsServiceClient(serverClient, requestReplyMessenger);
        }
    }
    //=========================================================================================================================================

    // Хранит информацию о клиенте сервиса, которая будет использоваться событием.
    public class ServiceClientEventArgs : EventArgs
    {
        // Клиент, связанный с этим событием.
        public IScsServiceClient Client { get; private set; }

        // Создает новый объект ServiceClientEventArgs.
        // "client" - Клиент, связанный с этим событием.
        public ServiceClientEventArgs(IScsServiceClient client)
        {
            Client = client;
        }
    }
    //=========================================================================================================================================
}

namespace Hik.Communication.ScsServices.Communication.Messages
{
    // Представляет удаленное исключение SCS.
    // Это исключение используется для отправки исключения из приложения в другое приложение.
    [Serializable]
    public class ScsRemoteException : Exception
    {
        // Конструктор.
        public ScsRemoteException()
        {

        }

        // Конструктор.
        public ScsRemoteException(SerializationInfo serializationInfo, StreamingContext context)
            : base(serializationInfo, context)
        {

        }

        // Конструктор.
        // "message" - Сообщение об исключении.
        public ScsRemoteException(string message)
            : base(message)
        {

        }

        // Конструктор.
        // "message" - Сообщение об исключении.
        // "innerException" - Внутреннее исключение.
        public ScsRemoteException(string message, Exception innerException)
            : base(message, innerException)
        {

        }
    }
    //=========================================================================================================================================

    // Это сообщение отправляется для вызова метода удаленного приложения.
    [Serializable]
    public class ScsRemoteInvokeMessage : ScsMessage
    {
        // Имя класса службы удаления.
        public string ServiceClassName { get; set; }

        // Способ вызова удаленного приложения.
        public string MethodName { get; set; }

        // Параметры метода.
        public object[] Parameters { get; set; }

        // Представляет этот объект в виде строки.
        // Возврат - Строковое представление этого объекта
        public override string ToString()
        {
            return string.Format("ScsRemoteInvokeMessage: {0}.{1}(...)", ServiceClassName, MethodName);
        }
    }
    //=========================================================================================================================================

    // Это сообщение отправляется в качестве ответного сообщения на ScsRemoteInvokeMessage.
    // Он используется для отправки возвращаемого значения вызова метода.
    [Serializable]
    public class ScsRemoteInvokeReturnMessage : ScsMessage
    {
        // Возвращаемое значение вызова удаленного метода.
        public object ReturnValue { get; set; }

        // Если во время вызова метода возникло какое-либо исключение, это поле содержит объект исключения.
        // Если исключения не произошло, это поле равно нулю.
        public ScsRemoteException RemoteException { get; set; }

        // Представляет этот объект в виде строки.
        // Возврат - Строковое представление этого объекта
        public override string ToString()
        {
            return string.Format("ScsRemoteInvokeReturnMessage: Returns {0}, Exception = {1}", ReturnValue, RemoteException);
        }
    }
    //=========================================================================================================================================
}

namespace Hik.Communication.ScsServices.Communication
{
    // Этот класс расширяет RemoteInvokeProxy, чтобы обеспечить механизм автоматического подключения/ отключения, 
    // если клиент не подключен к серверу при вызове сервисного метода.
    // "TProxy" - Тип прокси-класса/интерфейса
    // "TMessenger" - Тип объекта messenger, который используется для отправки/получения сообщений
    internal class AutoConnectRemoteInvokeProxy<TProxy, TMessenger> : RemoteInvokeProxy<TProxy, TMessenger> where TMessenger : IMessenger
    {
        // Ссылка на объект клиента, который используется для подключения/отключения.
        private readonly IConnectableClient _client;

        // Создает новый объект AutoConnectRemoteInvokeProxy.
        // "clientMessenger" - Объект Messenger, который используется для отправки/получения сообщений.
        // "client" - Ссылка на объект клиента, который используется для подключения/отключения.
        public AutoConnectRemoteInvokeProxy(RequestReplyMessenger<TMessenger> clientMessenger, IConnectableClient client)
            : base(clientMessenger)
        {
            _client = client;
        }

        // Переопределяет вызовы сообщений и преобразует их в сообщения удаленному приложению.
        // "msg" - Сообщение о вызове метода (из базового класса RealProxy)
        // Возврат - Вызов метода возвращает сообщение (базовому классу RealProxy)
        public override IMessage Invoke(IMessage msg)
        {
            if (_client.CommunicationState == CommunicationStates.Connected)
            {
                //If already connected, behave as base class (RemoteInvokeProxy).
                return base.Invoke(msg);
            }

            //Подключитесь, вызовите метод и, наконец, отключитесь
            _client.Connect();
            try
            {
                return base.Invoke(msg);
            }
            finally
            {
                _client.Disconnect();
            }
        }
    }
    //=========================================================================================================================================

    // Этот класс используется для создания динамического прокси-сервера для вызова удаленных методов.
    // Он переводит вызовы методов в обмен сообщениями.
    // "TProxy" - Тип прокси-класса/интерфейса
    // "TMessenger" - Тип объекта messenger, который используется для отправки/получения сообщений
    internal class RemoteInvokeProxy<TProxy, TMessenger> : RealProxy where TMessenger : IMessenger
    {
        // Объект Messenger, который используется для отправки/получения сообщений.
        private readonly RequestReplyMessenger<TMessenger> _clientMessenger;

        // Создает новый объект RemoteInvokeProxy.
        // "clientMessenger" - Объект Messenger, который используется для отправки/получения сообщений.
        public RemoteInvokeProxy(RequestReplyMessenger<TMessenger> clientMessenger)
            : base(typeof(TProxy))
        {
            _clientMessenger = clientMessenger;
        }

        // Переопределяет вызовы сообщений и преобразует их в сообщения удаленному приложению.
        // "msg" - Сообщение о вызове метода (из базового класса RealProxy)
        // Возврат - Вызов метода возвращает сообщение (базовому классу RealProxy)
        public override IMessage Invoke(IMessage msg)
        {
            var message = msg as IMethodCallMessage;
            if (message == null)
            {
                return null;
            }

            var requestMessage = new ScsRemoteInvokeMessage
            {
                ServiceClassName = typeof(TProxy).Name,
                MethodName = message.MethodName,
                Parameters = message.InArgs
            };

            var responseMessage = _clientMessenger.SendMessageAndWaitForResponse(requestMessage) as ScsRemoteInvokeReturnMessage;
            if (responseMessage == null)
            {
                return null;
            }

            return responseMessage.RemoteException != null
                       ? new ReturnMessage(responseMessage.RemoteException, message)
                       : new ReturnMessage(responseMessage.ReturnValue, null, 0, message.LogicalCallContext, message);
        }
    }
    //=========================================================================================================================================
}

namespace Hik.Communication.ScsServices.Client
{
    // Представляет клиента службы, который использует службу SCS.
    // "T" - Тип сервисного интерфейса
    public interface IScsServiceClient<out T> : IConnectableClient where T : class
    {
        // Ссылка на прокси-сервер службы для вызова методов удаленного обслуживания.
        T ServiceProxy { get; }

        // Значение тайм-аута при вызове сервисного метода.
        // Если тайм-аут возникает до завершения вызова удаленного метода, генерируется исключение.
        // Используйте -1 для отсутствия тайм-аута (ожидание неопределенное).
        // Значение по умолчанию: 60000 (1 minute).
        int Timeout { get; set; }
    }
    //=========================================================================================================================================

    // Представляет клиента службы, который использует службу SCS.
    // "T" - Тип сервисного интерфейса
    internal class ScsServiceClient<T> : IScsServiceClient<T> where T : class
    {
        #region Public events

        // Это событие возникает, когда клиент подключается к серверу.
        public event EventHandler Connected;

        // Это событие возникает, когда клиент отключается от сервера.
        public event EventHandler Disconnected;

        #endregion

        #region Public properties

        // Тайм-аут для подключения к серверу (в миллисекундах).
        // Значение по умолчанию: 15 seconds (15000 ms).
        public int ConnectTimeout
        {
            get { return _client.ConnectTimeout; }
            set { _client.ConnectTimeout = value; }
        }

        // Получает текущее состояние связи.
        public CommunicationStates CommunicationState
        {
            get { return _client.CommunicationState; }
        }

        // Ссылка на прокси-сервер службы для вызова методов удаленного обслуживания.
        public T ServiceProxy { get; private set; }

        // Значение тайм-аута при вызове сервисного метода.
        // Если тайм-аут возникает до завершения вызова удаленного метода, генерируется исключение.
        // Используйте -1 для отсутствия тайм-аута (ожидание неопределенное).
        // Значение по умолчанию: 60000 (1 minute).
        public int Timeout
        {
            get { return _requestReplyMessenger.Timeout; }
            set { _requestReplyMessenger.Timeout = value; }
        }

        #endregion

        #region Private fields

        // Базовый объект IScsClient для связи с сервером.
        private readonly IScsClient _client;

        // Объект Messenger для отправки/получения сообщений через _client.
        private readonly RequestReplyMessenger<IScsClient> _requestReplyMessenger;

        // Этот объект используется для создания прозрачного прокси-сервера для вызова удаленных методов на сервере.
        private readonly AutoConnectRemoteInvokeProxy<T, IScsClient> _realServiceProxy;

        // Клиентский объект, который используется для вызова метода, вызывается на стороне клиента.
        // Может быть нулевым, если у клиента нет методов, которые должны быть вызваны сервером.
        private readonly object _clientObject;

        #endregion

        #region Constructor

        // Создает новый объект ScsServiceClient.
        // "client" - Базовый объект IScsClient для связи с сервером.
        // "clientObject" - Клиентский объект, который используется для вызова метода, вызывается на стороне клиента.
        // Может быть нулевым, если у клиента нет методов, которые должны быть вызваны сервером.
        public ScsServiceClient(IScsClient client, object clientObject)
        {
            _client = client;
            _clientObject = clientObject;

            _client.Connected += Client_Connected;
            _client.Disconnected += Client_Disconnected;

            _requestReplyMessenger = new RequestReplyMessenger<IScsClient>(client);
            _requestReplyMessenger.MessageReceived += RequestReplyMessenger_MessageReceived;

            _realServiceProxy = new AutoConnectRemoteInvokeProxy<T, IScsClient>(_requestReplyMessenger, this);
            ServiceProxy = (T)_realServiceProxy.GetTransparentProxy();
        }

        #endregion

        #region Public methods

        // Подключается к серверу.
        public void Connect()
        {
            _client.Connect();
        }

        // Отключается от сервера.
        // Ничего не делает, если уже отключен.
        public void Disconnect()
        {
            _client.Disconnect();
        }

        // Вызывает метод разъединения.
        public void Dispose()
        {
            Disconnect();
        }

        #endregion

        #region Private methods

        // Обрабатывает событие MessageReceived мессенджера.
        // Он получает сообщения от сервера и вызывает соответствующий метод.
        // "sender" - Источник события.
        // "e" - Аргументы события.
        private void RequestReplyMessenger_MessageReceived(object sender, MessageEventArgs e)
        {
            //Отправьте сообщение в ScsRemoteInvokeMessage и проверьте его
            var invokeMessage = e.Message as ScsRemoteInvokeMessage;
            if (invokeMessage == null)
            {
                return;
            }

            //Проверьте объект клиента.
            if (_clientObject == null)
            {
                SendInvokeResponse(invokeMessage, null, new ScsRemoteException("Client does not wait for method invocations by server."));
                return;
            }

            //Вызовите метод
            object returnValue;
            try
            {
                var type = _clientObject.GetType();
                var method = type.GetMethod(invokeMessage.MethodName);
                returnValue = method.Invoke(_clientObject, invokeMessage.Parameters);
            }
            catch (TargetInvocationException ex)
            {
                var innerEx = ex.InnerException;
                SendInvokeResponse(invokeMessage, null, new ScsRemoteException(innerEx.Message, innerEx));
                return;
            }
            catch (Exception ex)
            {
                SendInvokeResponse(invokeMessage, null, new ScsRemoteException(ex.Message, ex));
                return;
            }

            //Отправить возвращаемое значение
            SendInvokeResponse(invokeMessage, returnValue, null);
        }

        // Отправляет ответ удаленному приложению, которое вызвало метод службы.
        // "requestMessage" - Сообщение с запросом.
        // "returnValue" - Возвращаемое значение для отправки.
        // "exception" - Исключение для отправки.
        private void SendInvokeResponse(IScsMessage requestMessage, object returnValue, ScsRemoteException exception)
        {
            try
            {
                _requestReplyMessenger.SendMessage(
                    new ScsRemoteInvokeReturnMessage
                    {
                        RepliedMessageId = requestMessage.MessageId,
                        ReturnValue = returnValue,
                        RemoteException = exception
                    });
            }
            catch
            {

            }
        }

        // Обрабатывает подключенное событие объекта _client.
        // "sender" - Источник объекта.
        // "e" - Аргументы события.
        private void Client_Connected(object sender, EventArgs e)
        {
            _requestReplyMessenger.Start();
            OnConnected();
        }

        // Обрабатывает отключенное событие объекта _client.
        // "sender" - Источник объекта.
        // "e" - Event arguments.
        private void Client_Disconnected(object sender, EventArgs e)
        {
            _requestReplyMessenger.Stop();
            OnDisconnected();
        }

        #endregion

        #region Private methods

        // Вызывает связанное событие.
        private void OnConnected()
        {
            var handler = Connected;
            if (handler != null)
            {
                handler(this, EventArgs.Empty);
            }
        }

        // Вызывает событие отключения.
        private void OnDisconnected()
        {
            var handler = Disconnected;
            if (handler != null)
            {
                handler(this, EventArgs.Empty);
            }
        }

        #endregion
    }
    //=========================================================================================================================================

    // Этот класс используется для создания клиентов-служб для удаленного вызова методов службы SCS.
    public class ScsServiceClientBuilder
    {
        // Создает клиента для подключения к службе SCS.
        // "T" - Тип сервисного интерфейса для удаленного вызова метода
        // "endpoint" - Конечная точка сервера
        // "clientObject" - Объект на стороне клиента, который обрабатывает вызовы удаленных методов от сервера к клиенту.
        // Может быть нулевым, если у клиента нет методов, которые должны быть вызваны сервером
        // Возврат - Созданный клиентский объект для подключения к серверу
        public static IScsServiceClient<T> CreateClient<T>(ScsEndPoint endpoint, object clientObject = null) where T : class
        {
            return new ScsServiceClient<T>(endpoint.CreateClient(), clientObject);
        }

        // Создает клиента для подключения к службе SCS.
        // "T" - Тип сервисного интерфейса для удаленного вызова метода
        // "endpointAddress" - Адрес конечной точки сервера
        // "clientObject" - Объект на стороне клиента, который обрабатывает вызовы удаленных методов от сервера к клиенту.
        // Может быть нулевым, если у клиента нет методов, которые должны быть вызваны сервером
        // Возврат - Созданный клиентский объект для подключения к серверу
        public static IScsServiceClient<T> CreateClient<T>(string endpointAddress, object clientObject = null) where T : class
        {
            return CreateClient<T>(ScsEndPoint.CreateEndPoint(endpointAddress), clientObject);
        }
    }
    //=========================================================================================================================================
}

#endregion ScsServices

#region Threading

namespace Hik.Threading
{
    // Этот класс используется для последовательной многопоточной обработки элементов.
    // "TItem" - Тип элемента для обработки
    public class SequentialItemProcessor<TItem>
    {
        #region Private fields

        // Делегат метода, который вызывается для фактической обработки элементов.
        private readonly Action<TItem> _processMethod;

        // Очередь элементов. Используется для последовательной обработки элементов.
        private readonly Queue<TItem> _queue;

        // Ссылка на текущую задачу, которая обрабатывает элемент в методе ProcessItem.
        private Task _currentProcessTask;

        // Указывает состояние обработки элемента.
        private bool _isProcessing;

        // Логическое значение для управления запуском SequentialItemProcessor.
        private bool _isRunning;

        // Объект для синхронизации потоков.
        private readonly object _syncObj = new object();

        #endregion

        #region Constructor

        // Создает новый объект SequentialItemProcessor.
        // "processMethod" - Делегат метода, который вызывается для фактической обработки элементов.
        public SequentialItemProcessor(Action<TItem> processMethod)
        {
            _processMethod = processMethod;
            _queue = new Queue<TItem>();
        }

        #endregion

        #region Public methods

        // Добавляет элемент в очередь для обработки элемента.
        // "item" - Элемент для добавления в очередь.
        public void EnqueueMessage(TItem item)
        {
            //Добавьте элемент в очередь и при необходимости запустите новую задачу
            lock (_syncObj)
            {
                if (!_isRunning)
                {
                    return;
                }

                _queue.Enqueue(item);

                if (!_isProcessing)
                {
                    _currentProcessTask = Task.Factory.StartNew(ProcessItem);
                }
            }
        }

        // Запускает обработку элементов.
        public void Start()
        {
            _isRunning = true;
        }

        // Останавливает обработку элементов и ожидает остановки текущего элемента.
        public void Stop()
        {
            _isRunning = false;

            //Очистить все входящие сообщения
            lock (_syncObj)
            {
                _queue.Clear();
            }

            //Проверьте, есть ли сообщение, которое сейчас обрабатывается
            if (!_isProcessing)
            {
                return;
            }

            //Дождитесь завершения текущей задачи обработки
            try
            {
                _currentProcessTask.Wait();
            }
            catch
            {

            }
        }

        #endregion

        #region Private methods

        // Этот метод выполняется в новой отдельной задаче (потоке) для обработки элементов в очереди.
        private void ProcessItem()
        {
            //Попробуйте получить элемент из очереди, чтобы обработать его.
            TItem itemToProcess;
            lock (_syncObj)
            {
                if (!_isRunning || _isProcessing)
                {
                    return;
                }

                if (_queue.Count <= 0)
                {
                    return;
                }

                _isProcessing = true;
                itemToProcess = _queue.Dequeue();
            }

            //Обработайте элемент (вызвав делегат _processMethod)
            _processMethod(itemToProcess);

            //Обработайте следующий элемент, если он доступен
            lock (_syncObj)
            {
                _isProcessing = false;
                if (!_isRunning || _queue.Count <= 0)
                {
                    return;
                }

                //Начните новую задачу
                _currentProcessTask = Task.Factory.StartNew(ProcessItem);
            }
        }

        #endregion
    }
    //=========================================================================================================================================

    // Этот класс представляет собой таймер, который периодически выполняет некоторые задачи.
    public class Timer
    {
        #region Public events

        // Это событие периодически вызывается в соответствии с периодом таймера.
        public event EventHandler Elapsed;

        #endregion

        #region Public fields

        // Период выполнения задания таймера (в миллисекундах).
        public int Period { get; set; }

        // Указывает, вызывает ли таймер прошедшее событие при методе запуска таймера один раз.
        // По умолчанию: False.
        public bool RunOnStart { get; set; }

        #endregion

        #region Private fields

        // Этот таймер используется для выполнения задачи через определенные промежутки времени.
        private readonly System.Threading.Timer _taskTimer;

        // Указывает, запущен ли таймер или остановлен.
        private volatile bool _running;

        // Указывает, что независимо от того, выполняется ли задача или _taskTimer находится в спящем режиме.
        // Это поле используется для ожидания выполнения задач при остановке таймера.
        private volatile bool _performingTasks;

        #endregion

        #region Constructors

        // Создает новый таймер.
        // "period" - Период выполнения задания таймера (в миллисекундах)
        public Timer(int period)
            : this(period, false)
        {

        }

        // Создает новый таймер.
        // "period" - Период выполнения задания таймера (в миллисекундах)
        // "runOnStart" - Указывает, вызывает ли таймер прошедшее событие при методе запуска таймера один раз.
        public Timer(int period, bool runOnStart)
        {
            Period = period;
            RunOnStart = runOnStart;
            _taskTimer = new System.Threading.Timer(TimerCallBack, null, Timeout.Infinite, Timeout.Infinite);
        }

        #endregion

        #region Public methods

        // Запускает таймер.
        public void Start()
        {
            _running = true;
            _taskTimer.Change(RunOnStart ? 0 : Period, Timeout.Infinite);
        }

        // Останавливает таймер.
        public void Stop()
        {
            lock (_taskTimer)
            {
                _running = false;
                _taskTimer.Change(Timeout.Infinite, Timeout.Infinite);
            }
        }

        // Ожидает остановки службы.
        public void WaitToStop()
        {
            lock (_taskTimer)
            {
                while (_performingTasks)
                {
                    Monitor.Wait(_taskTimer);
                }
            }
        }

        #endregion

        #region Private methods

        // Этот метод вызывается _taskTimer.
        // "state" - Неиспользованный аргумент.
        private void TimerCallBack(object state)
        {
            lock (_taskTimer)
            {
                if (!_running || _performingTasks)
                {
                    return;
                }

                _taskTimer.Change(Timeout.Infinite, Timeout.Infinite);
                _performingTasks = true;
            }

            try
            {
                if (Elapsed != null)
                {
                    Elapsed(this, new EventArgs());
                }
            }
            catch
            {

            }
            finally
            {
                lock (_taskTimer)
                {
                    _performingTasks = false;
                    if (_running)
                    {
                        _taskTimer.Change(Period, Timeout.Infinite);
                    }

                    Monitor.Pulse(_taskTimer);
                }
            }
        }

        #endregion
    }
    //=========================================================================================================================================
}

#endregion Threading

#region Collections

namespace Hik.Collections
{
    // Этот класс используется для хранения элементов на основе ключа-значения потокобезопасным способом.
    // Он использует System.Collections.Generic.SortedList изнутри.
    // "TK" - Тип ключа
    // "TV" - Тип значения
    public class ThreadSafeSortedList<TK, TV>
    {
        // Получает/добавляет/заменяет элемент по ключу.
        // "key" - Ключ для получения/установки значения
        // Возврат - Элемент, связанный с этим ключом
        public TV this[TK key]
        {
            get
            {
                _lock.EnterReadLock();
                try
                {
                    return _items.ContainsKey(key) ? _items[key] : default(TV);
                }
                finally
                {
                    _lock.ExitReadLock();
                }
            }

            set
            {
                _lock.EnterWriteLock();
                try
                {
                    _items[key] = value;
                }
                finally
                {
                    _lock.ExitWriteLock();
                }
            }
        }

        // Получает количество элементов в коллекции.
        public int Count
        {
            get
            {
                _lock.EnterReadLock();
                try
                {
                    return _items.Count;
                }
                finally
                {
                    _lock.ExitReadLock();
                }
            }
        }

        // Внутренняя коллекция для хранения предметов.
        protected readonly SortedList<TK, TV> _items;

        // Используется для синхронизации доступа к списку _items.
        protected readonly ReaderWriterLockSlim _lock;

        // Создает новый объект ThreadSafeSortedList.
        public ThreadSafeSortedList()
        {
            _items = new SortedList<TK, TV>();
            _lock = new ReaderWriterLockSlim(LockRecursionPolicy.NoRecursion);
        }

        // Проверяет, содержит ли коллекция специальный ключ.
        // "key" - Ключ для проверки
        // Возврат - True; если коллекция содержит данный ключ
        public bool ContainsKey(TK key)
        {
            _lock.EnterReadLock();
            try
            {
                return _items.ContainsKey(key);
            }
            finally
            {
                _lock.ExitReadLock();
            }
        }

        // Проверяет, содержит ли коллекция определенный элемент.
        // "item" - Элемент для проверки
        // Возврат - True; если коллекция содержит данный элемент
        public bool ContainsValue(TV item)
        {
            _lock.EnterReadLock();
            try
            {
                return _items.ContainsValue(item);
            }
            finally
            {
                _lock.ExitReadLock();
            }
        }

        // Удаляет элемент из коллекции.
        // "key" - Ключ элемента для удаления
        public bool Remove(TK key)
        {
            _lock.EnterWriteLock();
            try
            {
                if (!_items.ContainsKey(key))
                {
                    return false;
                }

                _items.Remove(key);
                return true;
            }
            finally
            {
                _lock.ExitWriteLock();
            }
        }

        // Получает все предметы в коллекции.
        // Возврат - Список элементов
        public List<TV> GetAllItems()
        {
            _lock.EnterReadLock();
            try
            {
                return new List<TV>(_items.Values);
            }
            finally
            {
                _lock.ExitReadLock();
            }
        }

        // Удаляет все элементы из списка.
        public void ClearAll()
        {
            _lock.EnterWriteLock();
            try
            {
                _items.Clear();
            }
            finally
            {
                _lock.ExitWriteLock();
            }
        }

        // Получает, затем удаляет все элементы в коллекции.
        // Возврат - Список элементов
        public List<TV> GetAndClearAllItems()
        {
            _lock.EnterWriteLock();
            try
            {
                var list = new List<TV>(_items.Values);
                _items.Clear();
                return list;
            }
            finally
            {
                _lock.ExitWriteLock();
            }
        }
    }
    //=========================================================================================================================================
}

#endregion Collections		
