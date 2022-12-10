using ScriptEngine.Machine.Contexts;

namespace oscs
{
    public class TcpEndPoint
    {
        public CsTcpEndPoint dll_obj;
        public string ipAddress;
        public Hik.Communication.Scs.Communication.EndPoints.Tcp.ScsTcpEndPoint M_TcpEndPoint;
        public int port;

        public TcpEndPoint(Hik.Communication.Scs.Communication.EndPoints.ScsEndPoint p1)
        {
            Hik.Communication.Scs.Communication.EndPoints.Tcp.ScsTcpEndPoint p2 = (Hik.Communication.Scs.Communication.EndPoints.Tcp.ScsTcpEndPoint)p1;
            M_TcpEndPoint = new Hik.Communication.Scs.Communication.EndPoints.Tcp.ScsTcpEndPoint(p2.IpAddress, p2.TcpPort);
        }

        public TcpEndPoint(oscs.TcpEndPoint p1)
        {
            M_TcpEndPoint = p1.M_TcpEndPoint;
            ipAddress = p1.ipAddress;
            port = p1.port;
        }

        public TcpEndPoint(string p1, int p2)
        {
            M_TcpEndPoint = new Hik.Communication.Scs.Communication.EndPoints.Tcp.ScsTcpEndPoint(p1, p2);
        }

        public string IpAddress
        {
            get { return M_TcpEndPoint.IpAddress; }
            set { M_TcpEndPoint.IpAddress = value; }
        }

        public int TcpPort
        {
            get { return M_TcpEndPoint.TcpPort; }
        }
    }

    [ContextClass ("КсTCPКонечнаяТочка", "CsTcpEndPoint")]
    public class CsTcpEndPoint : AutoContext<CsTcpEndPoint>
    {
        public CsTcpEndPoint(string p1, int p2)
        {
            TcpEndPoint TcpEndPoint1 = new TcpEndPoint(p1, p2);
            TcpEndPoint1.dll_obj = this;
            Base_obj = TcpEndPoint1;
        }

        public CsTcpEndPoint(oscs.TcpEndPoint p1)
        {
            TcpEndPoint TcpEndPoint1 = p1;
            TcpEndPoint1.dll_obj = this;
            Base_obj = TcpEndPoint1;
        }

        public TcpEndPoint Base_obj;
        
        [ContextProperty("IPАдрес", "IpAddress")]
        public string IpAddress
        {
            get { return Base_obj.IpAddress; }
            set { Base_obj.IpAddress = value; }
        }

        [ContextProperty("TCPПорт", "TcpPort")]
        public int TcpPort
        {
            get { return Base_obj.TcpPort; }
        }
        
    }
}
