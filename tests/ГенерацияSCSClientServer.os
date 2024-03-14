// Скрипт читает файлы справки в C:\444\OSClientServerRu\ и создает *.cs файлы в каталоге C:\444\ВыгрузкаКлиентСервера\
// Из каталога C:\444\ВыгрузкаКлиентСервера\ файлы *.cs можно скопировать в каталог проекта.

Перем СтрДирективы, СтрШапка, СтрРазделОбъявленияПеременных, СтрКонструктор, СтрBase_obj, СтрСвойства, СтрМетоды, СтрПодвал, СтрВыгрузкиПеречислений;
Перем СтрРазделОбъявленияПеременныхДляПеречисления, СтрСвойстваДляПеречисления, СтрМетодовСистема, СписокСтрМетодовСистема;
Перем СписокЗамен, ИменаКалассовПеречислений;

Перем КаталогСправки, КаталогВыгрузки;

Функция ОтобратьФайлы(Фильтр)
	// Фильтр = Класс Конструктор Члены Свойства Свойство Методы Метод Перечисление
	М_Фильтр = Новый Массив;
	ВыбранныеФайлы = НайтиФайлы(КаталогСправки, "*.html", Истина);
	Найдено1 = 0;
	Для А = 0 По ВыбранныеФайлы.ВГраница() Цикл
		ТекстДок = Новый ТекстовыйДокумент;
		ТекстДок.Прочитать(ВыбранныеФайлы[А].ПолноеИмя);
		Стр = ТекстДок.ПолучитьТекст();
		М = СтрНайтиМежду(Стр, "<H1 class=dtH1", "/H1>", , );
		Если М.Количество() > 0 Тогда
			СтрЗаголовка= М[0];
			Если (СтрНайти(СтрЗаголовка, Фильтр + "<") > 0) или (СтрНайти(СтрЗаголовка, Фильтр + " <") > 0) Тогда
				Найдено1 = Найдено1 + 1;
				// // // Сообщить("================================================================================================");
				// // // Сообщить("" + ВыбранныеФайлы[А].ПолноеИмя + "=" + СтрЗаголовка);
				// Сообщить("" + СтрЗаголовка);
				М_Фильтр.Добавить(ВыбранныеФайлы[А].ПолноеИмя);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Сообщить("Найдено1 (" + Фильтр + ") = " + Найдено1);
	Возврат М_Фильтр;
КонецФункции

Функция РазобратьСтроку(Строка, Разделитель)
	Стр = СтрЗаменить(Строка, Разделитель, Символы.ПС);
	М = Новый Массив;
	Если ПустаяСтрока(Стр) Тогда
		Возврат М;
	КонецЕсли;
	Для Ч = 1 По СтрЧислоСтрок(Стр) Цикл
		М.Добавить(СтрПолучитьСтроку(Стр, Ч));
	КонецЦикла;
	Возврат М;
КонецФункции

Процедура СортироватьСтрРазделОбъявленияПеременных()//в строке СтрРазделОбъявленияПеременных должно быть не меньше трёх слов разделенных двумя пробелами
	СписокСортировки = Новый СписокЗначений;
	Для Счетчик = 1 По СтрЧислоСтрок(СтрРазделОбъявленияПеременных) Цикл
		ТекСтрока = СтрПолучитьСтроку(СтрРазделОбъявленияПеременных, Счетчик);
		ТекСтрокаДляРазбора = ТекСтрока;
		ТекСтрокаДляРазбора = СтрЗаменить(ТекСтрокаДляРазбора, "static ", "");
		М = РазобратьСтроку(СокрЛП(ТекСтрокаДляРазбора), " ");
		Если М.Количество() > 2 Тогда
			СписокСортировки.Добавить(М[2], ТекСтрока);
		КонецЕсли;
	КонецЦикла;
	СтрРазделОбъявленияПеременных = "";
	СписокСортировки.СортироватьПоЗначению();
	Для А = 0 По СписокСортировки.Количество() - 1 Цикл
		СтрРазделОбъявленияПеременных = СтрРазделОбъявленияПеременных + СписокСортировки.Получить(А).Представление + Символы.ПС;
	КонецЦикла;
КонецПроцедуры

Процедура СортироватьСтрРазделОбъявленияПеременныхДляПеречисления()
	СписокСортировки = Новый СписокЗначений;
	Для Счетчик = 1 По СтрЧислоСтрок(СтрРазделОбъявленияПеременныхДляПеречисления) Цикл
		ТекСтрока = СтрПолучитьСтроку(СтрРазделОбъявленияПеременныхДляПеречисления, Счетчик);
		Если Не (СокрЛП(ТекСтрока) = "") Тогда
			М = РазобратьСтроку(СокрЛП(ТекСтрока), " ");
			ЗначениеСортировки = М[6];
			ЗначениеСортировки = СтрЗаменить(ЗначениеСортировки, ";", "");
			ЗначениеСортировки = Число(ЗначениеСортировки);
			СписокСортировки.Добавить(ЗначениеСортировки, ТекСтрока);
		КонецЕсли;
	КонецЦикла;
	СтрРазделОбъявленияПеременныхДляПеречисления = "" + Символы.ПС;
	СписокСортировки.СортироватьПоЗначению();
	Для А = 0 По СписокСортировки.Количество() - 1 Цикл
		Если А = (СписокСортировки.Количество() - 1) Тогда
			СтрРазделОбъявленияПеременныхДляПеречисления = СтрРазделОбъявленияПеременныхДляПеречисления + СписокСортировки.Получить(А).Представление;
		Иначе
			СтрРазделОбъявленияПеременныхДляПеречисления = СтрРазделОбъявленияПеременныхДляПеречисления + СписокСортировки.Получить(А).Представление + Символы.ПС;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры//СортироватьСтрРазделОбъявленияПеременныхДляПеречисления

Функция Директивы(ИмяКонтекстКлассаАнгл)
	Если ИмяКонтекстКлассаАнгл = "OneScriptClientServer" Тогда
		Стр = 
		"using System;
		|using ScriptEngine.Machine.Contexts;
		|using ScriptEngine.Machine;
		|using ScriptEngine.HostedScript.Library;
		|using ScriptEngine.HostedScript.Library.Binary;
		|using System.Collections.Concurrent;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "Action" Тогда
		Стр = 
		"using ScriptEngine.Machine.Contexts;
		|using ScriptEngine.Machine;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "TcpServer" Тогда
		Стр = 
		"using ScriptEngine.Machine.Contexts;
		|using ScriptEngine.HostedScript.Library;
		|using System.Collections.Generic;
		|using Hik.Communication.Scs.Server;
		|using Hik.Communication.Scs.Communication.EndPoints.Tcp;
		|using Hik.Communication.Scs.Communication.Channels;
		|using Hik.Communication.Scs.Communication.Channels.Tcp;
		|using ScriptEngine.Machine;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "TcpClient" Тогда
		Стр = 
		"using ScriptEngine.Machine.Contexts;
		|using ScriptEngine.Machine;
		|using ScriptEngine.HostedScript.Library;
		|using Hik.Communication.Scs.Communication.Messages;
		|using Hik.Communication.Scs.Client;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "ClientInfo" Тогда
		Стр = 
		"using System;
		|using ScriptEngine.Machine;
		|using ScriptEngine.Machine.Contexts;
		|using ScriptEngine.HostedScript.Library;
		|using ScriptEngine.HostedScript.Library.Binary;
		|using System.Collections.Generic;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "Collection" Тогда
		Стр = 
		"using System;
		|using System.Collections.Generic;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "ServerClient" Тогда
		Стр = 
		"using System;
		|using ScriptEngine.Machine.Contexts;
		|using ScriptEngine.Machine;
		|using ScriptEngine.HostedScript.Library;
		|using Hik.Communication.Scs.Communication.Messages;
		|using Hik.Communication.Scs.Server;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "MessageEventArgs" Тогда
		Стр = 
		"using System;
		|using ScriptEngine.Machine.Contexts;
		|using ScriptEngine.Machine;
		|using ScriptEngine.HostedScript.Library;
		|using Hik.Communication.Scs.Communication.Messages;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "DateTimeMessage" 
		Тогда
		Стр = 
		"using System;
		|using ScriptEngine.Machine.Contexts;
		|using Hik.Communication.Scs.Communication.Messages;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "ScsSupport"  Тогда
		Стр = 
		"using System;
		|using System.Threading;
		|using System.Threading.Tasks;
		|using System.Runtime.Serialization;
		|using System.Runtime.Serialization.Formatters.Binary;
		|using System.Runtime.Remoting.Proxies;
		|using System.Runtime.Remoting.Messaging;
		|using System.Reflection;
		|using System.Net;
		|using System.Net.Sockets;
		|using System.Linq;
		|using System.IO;
		|using System.Collections.Generic;
		|using Hik.Threading;
		|using Hik.Communication.ScsServices.Communication;
		|using Hik.Communication.ScsServices.Communication.Messages;
		|using Hik.Communication.Scs.Server;
		|using Hik.Communication.Scs.Server.Tcp;
		|using Hik.Communication.Scs.Communication;
		|using Hik.Communication.Scs.Communication.Protocols;
		|using Hik.Communication.Scs.Communication.Protocols.BinarySerialization;
		|using Hik.Communication.Scs.Communication.Messengers;
		|using Hik.Communication.Scs.Communication.Messages;
		|using Hik.Communication.Scs.Communication.EndPoints;
		|using Hik.Communication.Scs.Communication.EndPoints.Tcp;
		|using Hik.Communication.Scs.Communication.Channels;
		|using Hik.Communication.Scs.Communication.Channels.Tcp;
		|using Hik.Communication.Scs.Client;
		|using Hik.Communication.Scs.Client.Tcp;
		|using Hik.Collections;
		|using System.Text;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "ServerClientEventArgs" Тогда
		Стр = 
		"using System;
		|using ScriptEngine.Machine.Contexts;
		|using ScriptEngine.Machine;
		|using ScriptEngine.HostedScript.Library;
		|using Hik.Communication.Scs.Server;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "ServiceClientEventArgs" Тогда
		Стр = 
		"using System;
		|using ScriptEngine.Machine.Contexts;
		|using ScriptEngine.Machine;
		|using ScriptEngine.HostedScript.Library;
		|using Hik.Communication.ScsServices.Service;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "DoAtServerArgs" Тогда
		Стр = 
		"using ScriptEngine.Machine.Contexts;
		|using ScriptEngine.Machine;
		|using ScriptEngine.HostedScript.Library;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "DoAtClientArgs" Тогда
		Стр = 
		"using ScriptEngine.Machine.Contexts;
		|using ScriptEngine.Machine;
		|using ScriptEngine.HostedScript.Library;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "IMyService" Тогда
		Стр = 
		"using Hik.Communication.ScsServices.Service;
		|using System.Collections;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "MyService" 
		Тогда
		Стр = 
		"using Hik.Communication.ScsServices.Service;
		|using ScriptEngine.Machine;
		|using ScriptEngine.HostedScript.Library.Binary;
		|using System.Collections.Generic;
		|using ScriptEngine.HostedScript.Library;
		|using Hik.Communication.Scs.Communication;
		|using System.Collections;
		|using Hik.Collections;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "IMyClient" 
		Тогда
		Стр = 
		"using System.Collections;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "MyClient" 
		Тогда
		Стр = 
		"using ScriptEngine.Machine;
		|using ScriptEngine.HostedScript.Library;
		|using ScriptEngine.HostedScript.Library.Binary;
		|using System.Collections;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "ServiceApplication" Тогда
		Стр = 
		"using System;
		|using Hik.Communication.Scs.Communication.EndPoints.Tcp;
		|using Hik.Communication.ScsServices.Service;
		|using ScriptEngine.Machine.Contexts;
		|using ScriptEngine.Machine;
		|using ScriptEngine.HostedScript.Library;
		|using ScriptEngine.HostedScript.Library.Binary;
		|using System.Reflection;
		|using System.Collections;
		|using System.Collections.Generic;
		|using Hik.Communication.ScsServices.Communication.Messages;
		|using Hik.Communication.Scs.Server;
		|using Hik.Communication.Scs.Communication.Messengers;
		|using Hik.Communication.Scs.Communication.Messages;
		|using Hik.Collections;
		|using Hik.Communication.Scs.Communication;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "ServiceClient" Тогда
		Стр = 
		"using System;
		|using System.Runtime.Remoting.Proxies;
		|using ScriptEngine.Machine;
		|using ScriptEngine.Machine.Contexts;
		|using ScriptEngine.HostedScript.Library;
		|using ScriptEngine.HostedScript.Library.Binary;
		|using Hik.Communication.ScsServices.Communication;
		|using Hik.Communication.Scs.Server;
		|using Hik.Communication.Scs.Communication;
		|using Hik.Communication.Scs.Communication.Messengers;
		|using Hik.Communication.Scs.Communication.EndPoints;
		|using Hik.Communication.ScsServices.Client;
		|using System.Collections;
		|using System.Collections.Generic;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "ServiceApplicationClient" Тогда
		Стр = 
		"using ScriptEngine.Machine.Contexts;
		|using Hik.Communication.ScsServices.Service;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "CommunicationStates" или 
		ИмяКонтекстКлассаАнгл = "ClientMode" Тогда
		Стр = 
		"using ScriptEngine.Machine.Contexts;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "TextMessage" 
		или ИмяКонтекстКлассаАнгл = "BoolMessage" 
		Тогда
		Стр = 
		"using ScriptEngine.Machine.Contexts;
		|using Hik.Communication.Scs.Communication.Messages;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "TcpEndPoint" Тогда
		Стр = 
		"using ScriptEngine.Machine.Contexts;
		|using Hik.Communication.Scs.Communication.EndPoints;
		|using Hik.Communication.Scs.Communication.EndPoints.Tcp;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "ByteMessage" Тогда
		Стр = 
		"using ScriptEngine.Machine.Contexts;
		|using ScriptEngine.HostedScript.Library.Binary;
		|using Hik.Communication.Scs.Communication.Messages;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "NumberMessage" Тогда
		Стр = 
		"using ScriptEngine.Machine.Contexts;
		|using ScriptEngine.Machine;
		|using Hik.Communication.Scs.Communication.Messages;
		|
		|";
		Возврат Стр;
	ИначеЕсли ИмяКонтекстКлассаАнгл = "EventArgs" Тогда
		Стр = 
		"using ScriptEngine.Machine.Contexts;
		|using ScriptEngine.Machine;
		|using ScriptEngine.HostedScript.Library;
		|
		|";
		Возврат Стр;
	Иначе
		Стр = 
		"using System;
		|using ScriptEngine.Machine.Contexts;
		|using ScriptEngine.Machine;
		|using System.Threading;
		|using System.Threading.Tasks;
		|using System.Runtime.Serialization;
		|using System.Runtime.Serialization.Formatters.Binary;
		|using System.Runtime.Remoting.Proxies;
		|using System.Runtime.Remoting.Messaging;
		|using System.Reflection;
		|using System.Net;
		|using System.Net.Sockets;
		|using System.Linq;
		|using System.IO;
		|using System.Collections.Generic;
		|using Hik.Threading;
		|using Hik.Communication.ScsServices.Communication;
		|using Hik.Communication.ScsServices.Communication.Messages;
		|using Hik.Communication.Scs.Server;
		|using Hik.Communication.Scs.Server.Tcp;
		|using Hik.Communication.Scs.Communication;
		|using Hik.Communication.Scs.Communication.Protocols;
		|using Hik.Communication.Scs.Communication.Protocols.BinarySerialization;
		|using Hik.Communication.Scs.Communication.Messengers;
		|using Hik.Communication.Scs.Communication.Messages;
		|using Hik.Communication.Scs.Communication.EndPoints;
		|using Hik.Communication.Scs.Communication.EndPoints.Tcp;
		|using Hik.Communication.Scs.Communication.Channels;
		|using Hik.Communication.Scs.Communication.Channels.Tcp;
		|using Hik.Communication.Scs.Client;
		|using Hik.Communication.Scs.Client.Tcp;
		|using Hik.Collections;
		|
		|";
		Возврат Стр;
		
		
	КонецЕсли;
КонецФункции//Директивы

Функция Шапка(ИмяКонтекстКлассаАнгл, ИмяКонтекстКлассаРус)
	Стр = "";
	Если ИмяКонтекстКлассаАнгл = "OneScriptClientServer" Тогда
		Стр = Стр + 
		"
		|    [ContextClass(""" + ИмяКонтекстКлассаРус + """, """ + ИмяКонтекстКлассаАнгл + """)]
		|    public class " + ИмяКонтекстКлассаАнгл + " : AutoContext<" + ИмяКонтекстКлассаАнгл + ">
		|    {";
	Иначе
		Стр = Стр + 
		"
		|    [ContextClass(""Кс" + ИмяКонтекстКлассаРус + """, ""Cs" + ИмяКонтекстКлассаАнгл + """)]
		|    public class Cs" + ИмяКонтекстКлассаАнгл + " : AutoContext<Cs" + ИмяКонтекстКлассаАнгл + ">
		|    {";
	КонецЕсли;
	Возврат Стр;
КонецФункции

Функция РазделОбъявленияПеременных(ИмяФайлаЧленов, ИмяКласса)
	Если ИмяКласса = "OneScriptClientServer" Тогда
		Стр = 
		"        public static IValue Event = null;
		|        public static int thirdPartyClientMode;
		|        public static IValue EventAction = null;
		|        public static IValue ServerMessageReceived;
		|        public static IValue ServerMessageSent;
		|        public static ConcurrentQueue<dynamic> EventQueue = new ConcurrentQueue<dynamic>();
		|        public static CsServiceApplication CurrentServiceApplication = null;
		|        public static CsServiceClient CurrentServiceClient = null;
		|        public static bool goOn = true;";
	ИначеЕсли ИмяКласса = "ServiceApplicationClient" Тогда
		Стр = 
		"        public IScsServiceClient Client { get; set; }
		|        public IMyClient ClientProxy { get; set; }";
		
		
		
		
	Иначе
		Стр = "";
	КонецЕсли;
	Возврат Стр;
КонецФункции//РазделОбъявленияПеременных

Функция Конструктор(ИмяФайлаЧленов, ИмяКласса)
	Если ИмяКласса = "OneScriptClientServer" Тогда
		Стр = 
		"        [ScriptConstructor]
		|        public static IRuntimeContextInstance Constructor()
		|        {
		|            thirdPartyClientMode = cs_ClientMode.None;
		|            return new OneScriptClientServer();
		|        }//end_constr
		|";
	ИначеЕсли ИмяКласса = "Action" Тогда
		Стр = 
		"        public CsAction(IRuntimeContextInstance script, string methodName)
		|        {
		|            Script = script;
		|            MethodName = methodName;
		|        }//end_constr
		|";
	ИначеЕсли ИмяКласса = "ByteMessage" Тогда
		Стр = 
		"        public CsByteMessage(BinaryDataContext p1)
		|        {
		|            ByteMessage ByteMessage1 = new ByteMessage();
		|            ByteMessage1.dll_obj = this;
		|            Base_obj = ByteMessage1;
		|            ByteMessage1.MessageData = p1.Buffer;
		|        }//end_constr
		|		
		|        public CsByteMessage()
		|        {
		|            ByteMessage ByteMessage1 = new ByteMessage();
		|            ByteMessage1.dll_obj = this;
		|            Base_obj = ByteMessage1;
		|        }//end_constr
		|		
		|        public CsByteMessage(ByteMessage p1)
		|        {
		|            ByteMessage ByteMessage1 = p1;
		|            ByteMessage1.dll_obj = this;
		|            Base_obj = ByteMessage1;
		|        }//end_constr
		|";
	ИначеЕсли ИмяКласса = "ServiceClient" Тогда
		Стр = 
		"        public CsServiceClient(CsTcpEndPoint p1, IRuntimeContextInstance p2)
		|        {
		|            ServiceClient ServiceClient1 = new ServiceClient(p1.Base_obj);
		|            ServiceClient1.dll_obj = this;
		|            Base_obj = ServiceClient1;
		|            this.ChangedMethodName += CsServiceClient_ChangedMethodName;
		|            OneScriptClientServer.CurrentServiceClient = this;
		|            Script = p2;
		|        }//end_constr
		|
		|        private void CsServiceClient_ChangedMethodName(object sender, System.EventArgs e)
		|        {
		|            CsServiceClient sc = (CsServiceClient)sender;
		|
		|            DelegateAction action = DelegateAction.Create(sc.Script, sc.MethodName);
		|            sc.resalt = ""7b7540f9-27e6-4e4a-a0b1-8012ac6e5737"";
		|            DoAtClientArgs DoAtClientArgs1 = new DoAtClientArgs(sc.MethodName, sc.ParametersArray);
		|            DoAtClientArgs1.EventAction = action;
		|            DoAtClientArgs1.Sender = this;
		|            CsDoAtClientArgs CsDoAtClientArgs1 = new CsDoAtClientArgs(DoAtClientArgs1);
		|            OneScriptClientServer.EventQueue.Enqueue(DoAtClientArgs1);
		|
		|            sc.MethodName = null;
		|            sc.ParametersArray = null;
		|
		|            while (sc.Resalt.AsString() == ""7b7540f9-27e6-4e4a-a0b1-8012ac6e5737"")
		|            {
		|                System.Threading.Thread.Sleep(17);
		|            }
		|        }
		|
		|        public event System.EventHandler ChangedMethodName;
		|        protected void OnChangedMethodName()
		|        {
		|            if (ChangedMethodName != null)
		|            {
		|                ChangedMethodName(OneScriptClientServer.CurrentServiceClient, System.EventArgs.Empty);
		|            }
		|        }
		|
		|        private object _lock = new object();
		|        private string methodName = null;
		|        public string MethodName
		|        {
		|            get
		|            {
		|                lock (_lock)
		|                {
		|                    return methodName;
		|                }
		|            }
		|            set
		|            {
		|                lock (_lock)
		|                {
		|                    methodName = value;
		|                    if (value != null)
		|                    {
		|                        OnChangedMethodName();
		|                    }
		|                }
		|            }
		|        }
		|
		|        private object _lock2 = new object();
		|        private ArrayImpl parametersArray;
		|        public ArrayImpl ParametersArray
		|        {
		|            get
		|            {
		|                lock (_lock2)
		|                {
		|                    return parametersArray;
		|                }
		|            }
		|            set
		|            {
		|                lock (_lock2)
		|                {
		|                    parametersArray = value;
		|                }
		|            }
		|        }
		|
		|        private IRuntimeContextInstance script = null;
		|        public IRuntimeContextInstance Script
		|        {
		|            get { return script; }
		|            set { script = value; }
		|        }
		|";
	ИначеЕсли ИмяКласса = "ServiceApplicationClient" Тогда
		Стр = 
		"        public CsServiceApplicationClient(IScsServiceClient client)
		|        {
		|            Client = client;
		|        }//end_constr
		|";
	ИначеЕсли ИмяКласса = "ServiceApplication" Тогда
		Стр = 
		"        public CsServiceApplication(int p1, IRuntimeContextInstance p2)
		|        {
		|            ScsTcpEndPoint ScsTcpEndPoint1 = new ScsTcpEndPoint(p1);
		|            ServiceApplication ServiceApplication1 = new ServiceApplication(ScsTcpEndPoint1);
		|            ServiceApplication1.dll_obj = this;
		|            Base_obj = ServiceApplication1;
		|            this.ChangedMethodName += CsServiceApplication_ChangedMethodName;
		|            OneScriptClientServer.CurrentServiceApplication = this;
		|            Script = p2;
		|        }//end_constr
		|		
		|        private object _lock = new object();
		|        private void CsServiceApplication_ChangedMethodName(object sender, System.EventArgs e)
		|        {
		|            lock (_lock)
		|            {
		|                DelegateAction action = DelegateAction.Create(OneScriptClientServer.CurrentServiceApplication.Script, OneScriptClientServer.CurrentServiceApplication.MethodName);
		|                OneScriptClientServer.CurrentServiceApplication.resalt = ""92b55f72-41f9-4b03-8d64-01c7bd10325f"";
		|                oscs.DoAtServerArgs DoAtServerArgs1 = new DoAtServerArgs(OneScriptClientServer.CurrentServiceApplication.MethodName, OneScriptClientServer.CurrentServiceApplication.ParametersArray);
		|                DoAtServerArgs1.EventAction = action;
		|                DoAtServerArgs1.Sender = this;
		|                CsDoAtServerArgs CsDoAtServerArgs1 = new CsDoAtServerArgs(DoAtServerArgs1);
		|                OneScriptClientServer.EventQueue.Enqueue(DoAtServerArgs1);
		|
		|                OneScriptClientServer.CurrentServiceApplication.MethodName = null;
		|                OneScriptClientServer.CurrentServiceApplication.ParametersArray = null;
		|            }
		|        }
		|
		|        public event System.EventHandler ChangedMethodName;
		|        protected void OnChangedMethodName()
		|        {
		|            if (ChangedMethodName != null)
		|            {
		|                ChangedMethodName(OneScriptClientServer.CurrentServiceApplication, System.EventArgs.Empty);
		|            }
		|        }
		|
		|        private string methodName = null;
		|        public string MethodName
		|        {
		|            get { return methodName; }
		|            set
		|            {
		|                methodName = value;
		|                if (value != null)
		|                {
		|                    OnChangedMethodName();
		|                }
		|            }
		|        }
		|
		|        private ArrayImpl parametersArray;
		|        public ArrayImpl ParametersArray
		|        {
		|            get { return parametersArray; }
		|            set { parametersArray = value; }
		|        }
		|
		|        private IRuntimeContextInstance script = null;
		|        public IRuntimeContextInstance Script
		|        {
		|            get { return script; }
		|            set { script = value; }
		|        }
		|";
	ИначеЕсли ИмяКласса = "DateTimeMessage" Тогда
		Стр = 
		"        public CsDateTimeMessage(System.DateTime p1)
		|        {
		|            DateTimeMessage DateTimeMessage1 = new DateTimeMessage(p1);
		|            DateTimeMessage1.dll_obj = this;
		|            Base_obj = DateTimeMessage1;
		|        }//end_constr
		|
		|        public CsDateTimeMessage()
		|        {
		|            DateTimeMessage DateTimeMessage1 = new DateTimeMessage();
		|            DateTimeMessage1.dll_obj = this;
		|            Base_obj = DateTimeMessage1;
		|        }//end_constr
		|		
		|        public CsDateTimeMessage(DateTimeMessage p1)
		|        {
		|            DateTimeMessage DateTimeMessage1 = p1;
		|            DateTimeMessage1.dll_obj = this;
		|            Base_obj = DateTimeMessage1;
		|        }//end_constr
		|";
	ИначеЕсли ИмяКласса = "BoolMessage" Тогда
		Стр = 
		"        public CsBoolMessage(System.Boolean p1)
		|        {
		|            BoolMessage BoolMessage1 = new BoolMessage(p1);
		|            BoolMessage1.dll_obj = this;
		|            Base_obj = BoolMessage1;
		|        }//end_constr
		|
		|        public CsBoolMessage()
		|        {
		|            BoolMessage BoolMessage1 = new BoolMessage();
		|            BoolMessage1.dll_obj = this;
		|            Base_obj = BoolMessage1;
		|        }//end_constr
		|		
		|        public CsBoolMessage(BoolMessage p1)
		|        {
		|            BoolMessage BoolMessage1 = p1;
		|            BoolMessage1.dll_obj = this;
		|            Base_obj = BoolMessage1;
		|        }//end_constr
		|";
	ИначеЕсли ИмяКласса = "NumberMessage" Тогда
		Стр = 
		"        public CsNumberMessage(IValue p1)
		|        {
		|            NumberMessage NumberMessage1 = new NumberMessage(p1.AsNumber());
		|            NumberMessage1.dll_obj = this;
		|            Base_obj = NumberMessage1;
		|        }//end_constr
		|
		|        public CsNumberMessage()
		|        {
		|            NumberMessage NumberMessage1 = new NumberMessage();
		|            NumberMessage1.dll_obj = this;
		|            Base_obj = NumberMessage1;
		|        }//end_constr
		|
		|        public CsNumberMessage(NumberMessage p1)
		|        {
		|            NumberMessage NumberMessage1 = p1;
		|            NumberMessage1.dll_obj = this;
		|            Base_obj = NumberMessage1;
		|        }//end_constr
		|";
	ИначеЕсли ИмяКласса = "TextMessage" Тогда
		Стр = 
		"        public CsTextMessage(string p1 = null)
		|        {
		|            TextMessage TextMessage1 = new TextMessage(p1);
		|            TextMessage1.dll_obj = this;
		|            Base_obj = TextMessage1;
		|        }//end_constr
		|		
		|        public CsTextMessage(TextMessage p1)
		|        {
		|            TextMessage TextMessage1 = p1;
		|            TextMessage1.dll_obj = this;
		|            Base_obj = TextMessage1;
		|        }//end_constr
		|";
	ИначеЕсли ИмяКласса = "TcpClient" Тогда
		Стр = 
		"        public CsTcpClient(CsTcpEndPoint p1)
		|        {
		|            TcpClient TcpClient1 = new TcpClient(p1.Base_obj);
		|            TcpClient1.dll_obj = this;
		|            Base_obj = TcpClient1;
		|        }//end_constr
		|";
	ИначеЕсли ИмяКласса = "ClientInfo" Тогда
		Стр = 
		"        public CsClientInfo(string clientGuid, string clientName, oscs.Collection collection)
		|        {
		|            ClientInfo ClientInfo1 = new ClientInfo(clientGuid, clientName, collection);
		|            ClientGuid = clientGuid;
		|            ClientName = clientName;
		|            tag = new oscs.Collection(collection);
		|        }//end_constr
		|";
	ИначеЕсли ИмяКласса = "TcpEndPoint" Тогда
		Стр = 
		"        public CsTcpEndPoint(string p1, int p2)
		|        {
		|            TcpEndPoint TcpEndPoint1 = new TcpEndPoint(p1, p2);
		|            TcpEndPoint1.dll_obj = this;
		|            Base_obj = TcpEndPoint1;
		|        }//end_constr
		|
		|        public CsTcpEndPoint(TcpEndPoint p1)
		|        {
		|            TcpEndPoint TcpEndPoint1 = p1;
		|            TcpEndPoint1.dll_obj = this;
		|            Base_obj = TcpEndPoint1;
		|        }//end_constr
		|";
	ИначеЕсли ИмяКласса = "ServerClient" Тогда
		Стр = 
		"        public CsServerClient(IScsServerClient p1)
		|        {
		|            oscs.ServerClient ServerClient1 = new oscs.ServerClient(p1);
		|            ServerClient1.dll_obj = this;
		|            Base_obj = ServerClient1;
		|        }//end_constr
		|		
		|        public IValue MessageSent { get; set; }
		|
		|        public IValue MessageReceived { get; set; }
		|";
	ИначеЕсли ИмяКласса = "TcpServer" Тогда
		Стр = 
		"        public CsTcpServer(int p1)
		|        {
		|            ScsServer ScsServer1 = new ScsServer(p1);
		|            ScsServer1.dll_obj = this;
		|            Base_obj = ScsServer1;
		|        }//end_constr
		|
		|        public CsTcpServer(ScsServer p1)
		|        {
		|            Base_obj = p1;
		|        }//end_constr
		|";
	ИначеЕсли ИмяКласса = "ServerClientEventArgs" Тогда
		Стр = 
		"        public CsServerClientEventArgs(oscs.ServerClientEventArgs p1)
		|        {
		|            oscs.ServerClientEventArgs ServerClientEventArgs1 = p1;
		|            ServerClientEventArgs1.dll_obj = this;
		|            Base_obj = ServerClientEventArgs1;
		|        }//end_constr
		|";
	ИначеЕсли ИмяКласса = "MessageEventArgs" Тогда
		Стр = 
		"        public CsMessageEventArgs(oscs.MessageEventArgs p1)
		|        {
		|            oscs.MessageEventArgs MessageEventArgs1 = p1;
		|            MessageEventArgs1.dll_obj = this;
		|            Base_obj = MessageEventArgs1;
		|        }//end_constr
		|";
	ИначеЕсли ИмяКласса = "DoAtServerArgs" Тогда
		Стр = 
		"        public CsDoAtServerArgs(DoAtServerArgs p1)
		|        {
		|            DoAtServerArgs DoAtServerArgs1 = p1;
		|            DoAtServerArgs1.dll_obj = this;
		|            Base_obj = DoAtServerArgs1;
		|        }//end_constr
		|";
	ИначеЕсли ИмяКласса = "DoAtClientArgs" Тогда
		Стр = 
		"        public CsDoAtClientArgs(DoAtClientArgs p1)
		|        {
		|            DoAtClientArgs DoAtClientArgs1 = p1;
		|            DoAtClientArgs1.dll_obj = this;
		|            Base_obj = DoAtClientArgs1;
		|        }//end_constr
		|";
	ИначеЕсли ИмяКласса = "ServiceClientEventArgs" Тогда
		Стр = 
		"        public CsServiceClientEventArgs(oscs.ServiceClientEventArgs p1)
		|        {
		|            oscs.ServiceClientEventArgs ServiceClientEventArgs1 = p1;
		|            ServiceClientEventArgs1.dll_obj = this;
		|            Base_obj = ServiceClientEventArgs1;
		|        }//end_constr
		|
		|        public CsServiceClientEventArgs(Hik.Communication.ScsServices.Service.ServiceClientEventArgs p1)
		|        {
		|            oscs.ServiceClientEventArgs ServiceClientEventArgs1 = new oscs.ServiceClientEventArgs(p1);
		|            ServiceClientEventArgs1.dll_obj = this;
		|            Base_obj = ServiceClientEventArgs1;
		|        }//end_constr
		|";
		
		
		
		
		
		
		
		
		
		

	Иначе
		Стр = 
		"        public Cs" + ИмяКласса + "()
		|        {
		|            " + ИмяКласса + " " + ИмяКласса + "1 = new " + ИмяКласса + "();
		|            " + ИмяКласса + "1.dll_obj = this;
		|            Base_obj = " + ИмяКласса + "1;
		|        }//end_constr
		|		
		|        public Cs" + ИмяКласса + "(" + ИмяКласса + " p1)
		|        {
		|            " + ИмяКласса + " " + ИмяКласса + "1 = p1;
		|            " + ИмяКласса + "1.dll_obj = this;
		|            Base_obj = " + ИмяКласса + "1;
		|        }//end_constr
		|        ";
	КонецЕсли;
	Возврат Стр;
КонецФункции//Конструктор

Функция Base_obj(ИмяКласса)
	Если ИмяКласса = "TcpServer" Тогда
		Стр = 
		"        public oscs.ScsServer Base_obj;
		|";
		Возврат Стр;
	ИначеЕсли ИмяКласса = "Action" Тогда
		Стр = "";
		Возврат Стр;
	ИначеЕсли ИмяКласса = "ServerClientEventArgs" Тогда
		Стр = 
		"        public oscs.ServerClientEventArgs Base_obj;
		|";
		Возврат Стр;
	ИначеЕсли ИмяКласса = "MessageEventArgs" Тогда
		Стр = 
		"        public oscs.MessageEventArgs Base_obj;
		|";
		Возврат Стр;
	ИначеЕсли ИмяКласса = "ServerClient" Тогда
		Стр = 
		"        public oscs.ServerClient Base_obj;
		|";
		Возврат Стр;
	ИначеЕсли ИмяКласса = "ServiceClientEventArgs" Тогда
		Стр = 
		"        public oscs.ServiceClientEventArgs Base_obj;
		|";
		Возврат Стр;
	ИначеЕсли ИмяКласса = "DoAtServerArgs" Тогда
		Стр = 
		"        public DoAtServerArgs Base_obj;
		|";
		Возврат Стр;
	ИначеЕсли ИмяКласса = "DoAtClientArgs" Тогда
		Стр = 
		"        public DoAtClientArgs Base_obj;
		|";
		Возврат Стр;
	ИначеЕсли ИмяКласса = "ServiceApplicationClient" Тогда
		Стр = "";
		Возврат Стр;
	ИначеЕсли ИмяКласса = "ClientInfo" Тогда
		Стр = "";
		Возврат Стр;
		
		
		
		
		
		
		
		
	// ИначеЕсли ИмяКласса = "" Тогда
		// Стр = 
		// "        public Aga.Controls.Tree.NodeControls. Base_obj;
		// |";
		// Возврат Стр;
		
	КонецЕсли;
	Стр = 
	"        public " + ИмяКласса + " Base_obj;
	|";
	Возврат Стр;
КонецФункции//Base_obj

Функция Свойства(ИмяФайлаЧленов, ИмяКонтекстКлассаАнгл)
	ТекстДок = Новый ТекстовыйДокумент;
	ТекстДок.Прочитать(КаталогСправки + "\OSClientServer.html");
	Стр = ТекстДок.ПолучитьТекст();
	//находим текст таблицы
	СтрТаблица = СтрНайтиМежду(Стр, "<H3 class=dtH3>Перечисления</H3>", "</TBODY></TABLE>", Ложь, );
	// Сообщить("==================" + СтрТаблица[0]);
	СписокСтрПеречислений = Новый СписокЗначений;
	Если СтрТаблица.Количество() > 0 Тогда
		Массив1 = СтрНайтиМежду(СтрТаблица[0], "<TD width=""50%""><A href", "</A></TD>", , );
		// Сообщить("Массив1.Количество = " + Массив1.Количество());
		Если Массив1.Количество() > 0 Тогда
			Для А = 0 По Массив1.ВГраница() Цикл
				СтрХ = Массив1[А];
				// Сообщить("=СтрХ=================" + СтрХ);
				СтрХ = СтрЗаменить(СтрХ, "&nbsp;", " ");
				ПеречислениеАнгл = СтрНайтиМежду(СтрХ, "(", ")", , )[0];
				СписокСтрПеречислений.Добавить(ПеречислениеАнгл);
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
	СтрПеречислений = "";
	СписокСтрПеречислений.СортироватьПоЗначению();
	Для А = 0 По СписокСтрПеречислений.Количество() - 1 Цикл
		Если А = (СписокСтрПеречислений.Количество() - 1) Тогда
			СтрПеречислений = СтрПеречислений + СписокСтрПеречислений.Получить(А).Значение;
		Иначе
			СтрПеречислений = СтрПеречислений + СписокСтрПеречислений.Получить(А).Значение + ",";
		КонецЕсли;
	КонецЦикла;
	
	М_СтрПеречислений = РазобратьСтроку(СтрПеречислений, ",");
	
	ТекстДокЧленов = Новый ТекстовыйДокумент;
	КаталогНаДиске = Новый Файл(ИмяФайлаЧленов);
    Если Не (КаталогНаДиске.Существует()) Тогда
        Стр = 
		"        //Свойства============================================================" + Символы.ПС;
			
		Возврат Стр;
	КонецЕсли;
	ТекстДокЧленов.Прочитать(ИмяФайлаЧленов);
	СтрТекстДокЧленов = ТекстДокЧленов.ПолучитьТекст();
	Если Не (СтрНайтиМежду(СтрТекстДокЧленов, "<H4 class=dtH4>Свойства</H4>", "</TBODY></TABLE>", Ложь, ).Количество() > 0) Тогда
		Стр = 
		"        //Свойства============================================================" + Символы.ПС;
		Возврат Стр;
	КонецЕсли;
	СтрТаблицаЧленов = СтрНайтиМежду(СтрТекстДокЧленов, "<H4 class=dtH4>Свойства</H4>", "</TBODY></TABLE>", Ложь, )[0];
	Массив1 = СтрНайтиМежду(СтрТаблицаЧленов, "<TR vAlign=top>", "</TD></TR>", Ложь, );
	// Сообщить("Массив1.Количество()=" + Массив1.Количество());
	Если Массив1.Количество() > 0 Тогда
		Стр = "        //Свойства============================================================" + Символы.ПС;
		Для А = 0 По Массив1.ВГраница() Цикл
			//найдем первую ячейку строки таблицы
			М07 = СтрНайтиМежду(Массив1[А], "<TD width=""50%"">", "</TD>", Ложь, );
			СтрХ = М07[0];
			СтрХ = СтрЗаменить(СтрХ, "&nbsp;", " ");
			
			ИмяФайлаСвойства = КаталогСправки + "\" + СтрНайтиМежду(СтрХ, "<A href=""", """>", , )[0];
			ТекстДокСвойства = Новый ТекстовыйДокумент;
			ТекстДокСвойства.Прочитать(ИмяФайлаСвойства);
			СтрТекстДокСвойства = ТекстДокСвойства.ПолучитьТекст();
			СтрРаздела = СтрНайтиМежду(СтрТекстДокСвойства, "<H4 class=dtH4>Использование</H4>", "<H4 class=dtH4>Значение</H4>", , )[0];
			СтрИспользование = СтрНайтиМежду(СтрРаздела, "<P>", "</P>", , )[0];

			СвойствоАнгл = СтрНайтиМежду(СтрХ, "(", ")", , )[0];
			СвойствоРус = СтрНайтиМежду(СтрХ, ".html"">", " (", , )[0];
			Если (СвойствоРус = "Отправитель") и (ИмяКонтекстКлассаАнгл = "OneScriptClientServer") Тогда
				Стр = Стр +
				"        [ContextProperty(""Отправитель"", ""Sender"")]
				|        public IValue Sender
				|        {
				|            get { return OneScriptClientServer.RevertObj(((dynamic)Event).Base_obj.Sender); }
				|        }
				|        
				|";
			ИначеЕсли (СвойствоРус = "РежимСтороннегоКлиента") и (ИмяКонтекстКлассаАнгл = "OneScriptClientServer") Тогда
				Стр = Стр +
				"        [ContextProperty(""РежимСтороннегоКлиента"", ""ThirdPartyClientMode"")]
				|        public int ThirdPartyClientMode
				|        {
				|            get { return thirdPartyClientMode; }
				|            set { thirdPartyClientMode = value; }
				|        }
				|        
				|";
			ИначеЕсли (СвойствоРус = "Сценарий") и (ИмяКонтекстКлассаАнгл = "Action") Тогда
				Стр = Стр +
				"        [ContextProperty(""Сценарий"", ""Script"")]
				|        public IRuntimeContextInstance Script { get; set; }
				|        
				|";
			ИначеЕсли (СвойствоРус = "ИмяМетода") и (ИмяКонтекстКлассаАнгл = "Action") Тогда
				Стр = Стр +
				"        [ContextProperty(""ИмяМетода"", ""MethodName"")]
				|        public string MethodName { get; set; }
				|        
				|";
			ИначеЕсли (СвойствоРус = "Результат") и (ИмяКонтекстКлассаАнгл = "ServiceClient") Тогда
				СтрРазделОбъявленияПеременных = СтрРазделОбъявленияПеременных + Символы.ПС +
				"        public dynamic resalt;";
				Стр = Стр +
				"        [ContextProperty(""Результат"", ""Resalt"")]
				|        public IValue Resalt
				|        {
				|            get
				|            {
				|                if (resalt.GetType() == typeof(System.Byte[]))
				|                {
				|                    return new BinaryDataContext(resalt);
				|                }
				|                return ValueFactory.Create(resalt);
				|            }
				|            set { resalt = OneScriptClientServer.RedefineIValue(value); }
				|        }
				|        
				|";
			ИначеЕсли (СвойствоРус = "Результат") и (ИмяКонтекстКлассаАнгл = "ServiceApplication") Тогда
				СтрРазделОбъявленияПеременных = СтрРазделОбъявленияПеременных + Символы.ПС +
				"        public dynamic resalt;";
				Стр = Стр +
				"        [ContextProperty(""Результат"", ""Resalt"")]
				|        public IValue Resalt
				|        {
				|            get
				|            {
				|                if (resalt.GetType() == typeof(System.Byte[]))
				|                {
				|                    return new BinaryDataContext(resalt);
				|                }
				|                return ValueFactory.Create(resalt);
				|            }
				|            set { resalt = OneScriptClientServer.RedefineIValue(value); }
				|        }
				|        
				|";
			ИначеЕсли (СвойствоРус = "Отправитель") и (ИмяКонтекстКлассаАнгл = "EventArgs") Тогда
				Стр = Стр +
				"        [ContextProperty(""Отправитель"", ""Sender"")]
				|        public IValue Sender
				|        {
				|            get { return OneScriptClientServer.RevertObj(Base_obj.Sender); }
				|        }
				|        
				|";
			ИначеЕсли (СвойствоРус = "Клиенты") и (ИмяКонтекстКлассаАнгл = "TcpServer") Тогда
				Стр = Стр +
				"        [ContextProperty(""Клиенты"", ""Clients"")]
				|        public ArrayImpl Clients
				|        {
				|            get { return Base_obj.Clients; }
				|        }
				|        
				|";
			ИначеЕсли (СвойствоРус = "Клиенты") и (ИмяКонтекстКлассаАнгл = "ServiceApplication") Тогда
				Стр = Стр +
				"        [ContextProperty(""Клиенты"", ""Clients"")]
				|        public ArrayImpl Clients
				|        {
				|            get { return Base_obj.Proxy.Clients; }
				|        }
				|        
				|";
			ИначеЕсли (СвойствоРус = "ИдентификаторКлиента") и (ИмяКонтекстКлассаАнгл = "ServerClient") Тогда
				Стр = Стр +
				"        [ContextProperty(""ИдентификаторКлиента"", ""ClientId"")]
				|        public decimal ClientId
				|        {
				|            get { return Base_obj.ClientId; }
				|        }
				|        
				|";
			ИначеЕсли (СвойствоРус = "АргументыСобытия") и (ИмяКонтекстКлассаАнгл = "OneScriptClientServer") Тогда
				Стр = Стр +
				"        [ContextProperty(""АргументыСобытия"", ""EventArgs"")]
				|        public IValue EventArgs
				|        {
				|            get { return Event; }
				|        }
				|        
				|";
			ИначеЕсли (СвойствоРус = "Продолжать") и (ИмяКонтекстКлассаАнгл = "OneScriptClientServer") Тогда
				Стр = Стр +
				"        [ContextProperty(""Продолжать"", ""GoOn"")]
				|        public bool GoOn
				|        {
				|            get { return goOn; }
				|            set { goOn = value; }
				|        }
				|        
				|";
			ИначеЕсли (СвойствоРус = "ПриПолученииСообщения" ) и (ИмяКонтекстКлассаАнгл = "TcpServer") Тогда
				Стр = Стр +
				"        [ContextProperty(""ПриПолученииСообщения"", ""MessageReceived"")]
				|        public IValue MessageReceived
				|        {
				|            get { return OneScriptClientServer.ServerMessageReceived; }
				|            set { OneScriptClientServer.ServerMessageReceived = value; }
				|        }
				|        
				|";
			ИначеЕсли (СвойствоРус = "ПриОтправкеСообщения" ) и (ИмяКонтекстКлассаАнгл = "TcpServer") Тогда
				Стр = Стр +
				"        [ContextProperty(""ПриОтправкеСообщения"", ""MessageSent"")]
				|        public IValue MessageSent
				|        {
				|            get { return OneScriptClientServer.ServerMessageSent; }
				|            set { OneScriptClientServer.ServerMessageSent = value; }
				|        }
				|        
				|";
			ИначеЕсли СвойствоРус = "ПриПодключенииКлиента" 
				или СвойствоРус = "ПриОтключенииКлиента" 
				или СвойствоРус = "ПриОтключении" 
				или СвойствоРус = "ПриПодключении" 
				или СвойствоРус = "ПриПолученииСообщения" 
				или СвойствоРус = "ПриОтправкеСообщения" 
				Тогда
				Стр = Стр +
				"        [ContextProperty(""" + СвойствоРус + """, """ + СвойствоАнгл + """)]
				|        public IValue " + СвойствоАнгл + " { get; set; }
				|        
				|";
			ИначеЕсли СвойствоРус = "Действие" Тогда
				Стр = Стр +
				"        [ContextProperty(""Действие"", ""EventAction"")]
				|        public IValue EventAction
				|        {
				|            get { return Base_obj.EventAction; }
				|            set { Base_obj.EventAction = value; }
				|        }
				|        
				|";
			ИначеЕсли СвойствоРус = "Отправитель" Тогда
				Стр = Стр +
				"        [ContextProperty(""Отправитель"", ""Sender"")]
				|        public IValue Sender
				|        {
				|            get { return Base_obj.Sender.dll_obj; }
				|        }
				|        
				|";
			ИначеЕсли (СвойствоРус = "Данные") и (ИмяКонтекстКлассаАнгл = "ByteMessage") Тогда
				Стр = Стр +
				"        [ContextProperty(""Данные"", ""MessageData"")]
				|        public BinaryDataContext MessageData
				|        {
				|            get { return new BinaryDataContext(Base_obj.MessageData); }
				|            set { Base_obj.MessageData = ((BinaryDataContext)value).Buffer; }
				|        }
				|        
				|";
			ИначеЕсли (СвойствоРус = "Клиент") и (ИмяКонтекстКлассаАнгл = "ServerClientEventArgs") Тогда
				Стр = Стр +
				"        [ContextProperty(""Клиент"", ""Client"")]
				|        public CsServerClient Client
				|        {
				|            get { return Base_obj.Client; }
				|        }
				|        
				|";
			ИначеЕсли (СвойствоРус = "Клиент") и (ИмяКонтекстКлассаАнгл = "ServiceClientEventArgs") Тогда
				Стр = Стр +
				"        [ContextProperty(""Клиент"", ""Client"")]
				|        public CsServiceApplicationClient Client
				|        {
				|            get { return Base_obj.ServiceApplicationClient; }
				|        }
				|        
				|";
			ИначеЕсли (СвойствоРус = "Сообщение") и (ИмяКонтекстКлассаАнгл = "MessageEventArgs") Тогда
				Стр = Стр +
				"        [ContextProperty(""Сообщение"", ""Message"")]
				|        public IValue Message
				|        {
				|            get
				|            {
				|                dynamic Obj1 = null;
				|                string str1 = Base_obj.Message.GetType().ToString();
				|                string str2 = ""oscs.Cs"" + str1.Substring(str1.LastIndexOf(""."") + 1);
				|                System.Type TestType = System.Type.GetType(str2, false, true);
				|                object[] args = { Base_obj.Message };
				|                Obj1 = Activator.CreateInstance(TestType, args);
				|                return Obj1;
				|            }
				|        }
				|        
				|";
			ИначеЕсли (СвойствоРус = "Число") и (ИмяКонтекстКлассаАнгл = "NumberMessage") Тогда
				Стр = Стр +
				"        [ContextProperty(""Число"", ""Number"")]
				|        public decimal Number
				|        {
				|            get { return Base_obj.Number; }
				|            set { Base_obj.Number = value; }
				|        }
				|        
				|";
			ИначеЕсли (СвойствоРус = "МассивПараметров") и (ИмяКонтекстКлассаАнгл = "DoAtServerArgs") Тогда
				Стр = Стр +
				"        [ContextProperty(""МассивПараметров"", ""ParametersArray"")]
				|        public ArrayImpl ParametersArray
				|        {
				|            get { return Base_obj.ParametersArray; }
				|        }
				|
				|";
			ИначеЕсли (СвойствоРус = "МассивПараметров") и (ИмяКонтекстКлассаАнгл = "DoAtClientArgs") Тогда
				Стр = Стр +
				"        [ContextProperty(""МассивПараметров"", ""ParametersArray"")]
				|        public ArrayImpl ParametersArray
				|        {
				|            get { return Base_obj.ParametersArray; }
				|        }
				|
				|";
			ИначеЕсли (СвойствоРус = "ГуидКлиента") и (ИмяКонтекстКлассаАнгл = "ServiceApplicationClient") Тогда
				СтрРазделОбъявленияПеременных = СтрРазделОбъявленияПеременных + Символы.ПС +
				"        public string clientGuid;";
				Стр = Стр +
				"        [ContextProperty(""ГуидКлиента"", ""ClientGuid"")]
				|        public string ClientGuid
				|        {
				|            get { return clientGuid; }
				|        }
				|
				|";
			ИначеЕсли (СвойствоРус = "ИдентификаторКлиента") и (ИмяКонтекстКлассаАнгл = "ServiceApplicationClient") Тогда
				Стр = Стр +
				"        [ContextProperty(""ИдентификаторКлиента"", ""ClientId"")]
				|        public decimal ClientId
				|        {
				|            get { return Client.ClientId; }
				|        }
				|
				|";
			ИначеЕсли (СвойствоРус = "СостояниеСоединения") и (ИмяКонтекстКлассаАнгл = "ServiceApplicationClient") Тогда
				Стр = Стр +
				"        [ContextProperty(""СостояниеСоединения"", ""CommunicationState"")]
				|        public int CommunicationState
				|        {
				|            get { return (int)Client.CommunicationState; }
				|        }
				|
				|";
			ИначеЕсли (СвойствоРус = "ГуидКлиента") и (ИмяКонтекстКлассаАнгл = "ServiceClient") Тогда
				Стр = Стр +
				"        [ContextProperty(""ГуидКлиента"", ""ClientGuid"")]
				|        public string ClientGuid
				|        {
				|            get { return Base_obj.Guid; }
				|        }
				|
				|";
			ИначеЕсли (СвойствоРус = "ГуидКлиента") и (ИмяКонтекстКлассаАнгл = "ClientInfo") Тогда
				Стр = Стр +
				"        [ContextProperty(""ГуидКлиента"", ""ClientGuid"")]
				|        public string ClientGuid { get; set; }
				|
				|";
			ИначеЕсли (СвойствоРус = "ИмяКлиента") и (ИмяКонтекстКлассаАнгл = "ClientInfo") Тогда
				Стр = Стр +
				"        [ContextProperty(""ИмяКлиента"", ""ClientName"")]
				|        public string ClientName { get; set; }
				|
				|";
			ИначеЕсли (СвойствоРус = "Метка") и (ИмяКонтекстКлассаАнгл = "ServiceClient") Тогда
				Стр = Стр +
				"        [ContextProperty(""Метка"", ""Tag"")]
				|        public StructureImpl Tag
				|        {
				|            get
				|            {
				|                StructureImpl StructureImpl1 = new StructureImpl();
				|                oscs.Collection tag = Base_obj.Tag;
				|                foreach (KeyValuePair<string, object> DictionaryEntry in tag)
				|                {
				|                    if (DictionaryEntry.Value.GetType() == typeof(System.Byte[]))
				|                    {
				|                        StructureImpl1.Insert(DictionaryEntry.Key, new BinaryDataContext((System.Byte[])DictionaryEntry.Value));
				|                    }
				|                    else
				|                    {
				|                        StructureImpl1.Insert(DictionaryEntry.Key, ValueFactory.Create((dynamic)DictionaryEntry.Value));
				|                    }
				|                }
				|                return StructureImpl1;
				|            }
				|            set
				|            {
				|                oscs.Collection tag = Base_obj.Tag;
				|                foreach (KeyAndValueImpl item in value)
				|                {
				|                    if (item.Value.GetType() == typeof(ScriptEngine.Machine.Values.StringValue) ||
				|                        item.Value.GetType() == typeof(ScriptEngine.Machine.Values.NumberValue) ||
				|                        item.Value.GetType() == typeof(ScriptEngine.Machine.Values.BooleanValue) ||
				|                        item.Value.GetType() == typeof(ScriptEngine.Machine.Values.DateValue) ||
				|                        item.Value.GetType() == typeof(BinaryDataContext))
				|                    {
				|                        tag.Add(OneScriptClientServer.RedefineIValue(item.Key), OneScriptClientServer.RedefineIValue(item.Value));
				|                    }
				|                    else
				|                    {
				|                        tag.Add(OneScriptClientServer.RedefineIValue(item.Key), item.Value.GetType().ToString());
				|                    }
				|                }
				|            }
				|        }
				|
				|";
			ИначеЕсли (СвойствоРус = "Метка") и (ИмяКонтекстКлассаАнгл = "ClientInfo") Тогда
				СтрРазделОбъявленияПеременных = СтрРазделОбъявленияПеременных + Символы.ПС +
				"        private oscs.Collection tag;";
				Стр = Стр +
				"        [ContextProperty(""Метка"", ""Tag"")]
				|        public StructureImpl Tag
				|        {
				|            get
				|            {
				|                StructureImpl StructureImpl1 = new StructureImpl();
				|                foreach (KeyValuePair<string, object> DictionaryEntry in tag)
				|                {
				|                    if (DictionaryEntry.Value.GetType() == typeof(System.Byte[]))
				|                    {
				|                        StructureImpl1.Insert(DictionaryEntry.Key, new BinaryDataContext((System.Byte[])DictionaryEntry.Value));
				|                    }
				|                    else
				|                    {
				|                        StructureImpl1.Insert(DictionaryEntry.Key, ValueFactory.Create((dynamic)DictionaryEntry.Value));
				|                    }
				|                }
				|                return StructureImpl1;
				|            }
				|        }
				|
				|";
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
			Иначе	
				//находим ТипВозвращаемогоЗначения
				СтрРаздела = СтрНайтиМежду(СтрТекстДокСвойства, "<H4 class=dtH4>Значение</H4>", "<H4 class=dtH4>Примечание</H4>", , )[0];
				СтрЗначение = СтрНайтиМежду(СтрРаздела, "<P>", "</P>", , )[0];
				М09 = СтрНайтиМежду(СтрЗначение, "(", ")", , );
				Если М09.Количество() > 0 Тогда
					ТипВозвращаемогоЗначения = М09[0];
				Иначе
					ТипВозвращаемогоЗначения = СтрЗаменить(СтрЗначение, "Тип: ", "");
				КонецЕсли;
				// Сообщить(ТипВозвращаемогоЗначения);
				// // // // Строка.
				// // // // Число.
				// // // // Булево.
				// // // // Дата.
				// // // // Произвольный.
				ВозвратГет = "хххх";
				ВозвратСет = "хххх";
				Комментарий = "//";
				Если ТипВозвращаемогоЗначения = "Число." Тогда
					ТипВозвращаемогоЗначения = "int";
					ВозвратГет = "    get { return Base_obj." + СвойствоАнгл + "; }";
					ВозвратСет = "    set { Base_obj." + СвойствоАнгл + " = value; }";
					Комментарий = "";
				ИначеЕсли ТипВозвращаемогоЗначения = "Строка." Тогда
					ТипВозвращаемогоЗначения = "string";
					ВозвратГет = "    get { return Base_obj." + СвойствоАнгл + "; }";
					ВозвратСет = "    set { Base_obj." + СвойствоАнгл + " = value; }";
					Комментарий = "";
				ИначеЕсли ТипВозвращаемогоЗначения = "Булево." Тогда
					ТипВозвращаемогоЗначения = "bool";
					ВозвратГет = "    get { return Base_obj." + СвойствоАнгл + "; }";
					ВозвратСет = "    set { Base_obj." + СвойствоАнгл + " = value; }";
					Комментарий = "";
				ИначеЕсли ТипВозвращаемогоЗначения = "Дата." Тогда
					ТипВозвращаемогоЗначения = "DateTime";
					ВозвратГет = "    get { return Base_obj." + СвойствоАнгл + "; }";
					ВозвратСет = "    set { Base_obj." + СвойствоАнгл + " = value; }";
					Комментарий = "";
				ИначеЕсли ТипВозвращаемогоЗначения = "Произвольный." Тогда
					ТипВозвращаемогоЗначения = "dynamic";
					ВозвратГет = "    get { return Base_obj." + СвойствоАнгл + "; }";
					ВозвратСет = "    set { Base_obj." + СвойствоАнгл + " = value; }";
					
				Иначе // ТипВозвращаемогоЗначения это экземпляр класса
					Комментарий = "";
					ШаблонДляГетСет = "ОбщийШаблон";
					Если Не (М_СтрПеречислений.Найти(ТипВозвращаемогоЗначения) = Неопределено) Тогда //ТипВозвращаемогоЗначения это перечисление
						ТипВозвращаемогоЗначения = "int";
						ШаблонДляГетСет = "ШаблонДляПеречисления";
					ИначеЕсли ТипВозвращаемогоЗначения = "GridColumnStylesCollection" или //ТипВозвращаемогоЗначения это не перечисление
							ТипВозвращаемогоЗначения = "TreeNodeCollection" или
							ТипВозвращаемогоЗначения = "ListViewSubItemCollection" или
							ТипВозвращаемогоЗначения = "ListViewItemCollection" или
							ТипВозвращаемогоЗначения = "ListViewCheckedItemCollection" или
							ТипВозвращаемогоЗначения = "ListViewColumnHeaderCollection" или
							ТипВозвращаемогоЗначения = "ListViewSelectedItemCollection" или
							ТипВозвращаемогоЗначения = "ListBoxObjectCollection" или
							ТипВозвращаемогоЗначения = "ListBoxSelectedIndexCollection" или
							ТипВозвращаемогоЗначения = "ImageCollection" или
							ТипВозвращаемогоЗначения = "GridItemCollection" или
							ТипВозвращаемогоЗначения = "DataRowCollection" или
							ТипВозвращаемогоЗначения = "DataColumnCollection" или
							ТипВозвращаемогоЗначения = "DataTableCollection" или
							ТипВозвращаемогоЗначения = "ToolBarButtonCollection" или
							ТипВозвращаемогоЗначения = "MenuItemCollection" или
							ТипВозвращаемогоЗначения = "TabPageCollection" или
							ТипВозвращаемогоЗначения = "ControlCollection" или
							ТипВозвращаемогоЗначения = "DockPaddingEdges" или
							ТипВозвращаемогоЗначения = "Padding" или
							ТипВозвращаемогоЗначения = "LinkCollection" или
							ТипВозвращаемогоЗначения = "StatusBarPanelCollection" или
							ТипВозвращаемогоЗначения = "GridTableStylesCollection" Тогда
						ТипВозвращаемогоЗначения = "Cs" + ТипВозвращаемогоЗначения;
						ШаблонДляГетСет = "ШаблонДляКоллекций";
					ИначеЕсли (ТипВозвращаемогоЗначения = "Color") Тогда
						ТипВозвращаемогоЗначения = "Cs" + ТипВозвращаемогоЗначения;
						Если (ИмяКонтекстКлассаАнгл = "Color") или
							(ИмяКонтекстКлассаАнгл = "FontDialog") Тогда
							ШаблонДляГетСет = "ОбщийШаблон";
						Иначе
							ШаблонДляГетСет = "ШаблонДляНекоторыхКлассов";
						КонецЕсли;
					ИначеЕсли (ТипВозвращаемогоЗначения = "Rectangle") Тогда
						ТипВозвращаемогоЗначения = "Cs" + ТипВозвращаемогоЗначения;
						Если (ИмяКонтекстКлассаАнгл = "ToolBarButton") Тогда
							ШаблонДляГетСет = "ОбщийШаблон";
						ИначеЕсли (Прав(ИмяКонтекстКлассаАнгл, 4) <> "Args") Тогда
							ШаблонДляГетСет = "ШаблонДляНекоторыхКлассов";
						КонецЕсли;
					ИначеЕсли (ТипВозвращаемогоЗначения = "ImageList") Тогда
						ТипВозвращаемогоЗначения = "Cs" + ТипВозвращаемогоЗначения;
						ШаблонДляГетСет = "ОбщийШаблон";
					ИначеЕсли (ТипВозвращаемогоЗначения = "Icon") или
							(ТипВозвращаемогоЗначения = "Font") Тогда
						ТипВозвращаемогоЗначения = "Cs" + ТипВозвращаемогоЗначения;
						ШаблонДляГетСет = "ШаблонДляКлассовЧерезHashtable";
					Иначе
						ТипВозвращаемогоЗначения = "Cs" + ТипВозвращаемогоЗначения;
					КонецЕсли;
					
					Если ШаблонДляГетСет = "ШаблонДляКоллекций" Тогда
						// gridColumnStyles = new CsGridColumnStylesCollection(Base_obj.GridColumnStyles);
						// public CsGridColumnStylesCollection gridColumnStyles;
						// [ContextProperty("СтилиКолонкиСеткиДанных", "GridColumnStyles")]
						// public CsGridColumnStylesCollection GridColumnStyles
						// {
							// get { return gridColumnStyles; }
						// }
						ПриватСвойство = НРег(Лев(СвойствоАнгл, 1)) + Сред(СвойствоАнгл, 2);
						СтрРазделОбъявленияПеременных = СтрРазделОбъявленияПеременных + Символы.ПС +
						"        private " + ТипВозвращаемогоЗначения + " " + ПриватСвойство + ";";
						СтрКонструктор = СтрЗаменить(СтрКонструктор, 
						"        }//end_constr"
						, 
						"            " + ПриватСвойство + " = new " + ТипВозвращаемогоЗначения + "(Base_obj." + СвойствоАнгл + ");
						|        }//end_constr"
						);
						ВозвратГет = "    " + Комментарий + "get { return " + ПриватСвойство + "; }";
						ВозвратСет = "    " + Комментарий + "set { " + ПриватСвойство + " = new " + ТипВозвращаемогоЗначения + "(value.Base_obj); }";
					ИначеЕсли ШаблонДляГетСет = "ШаблонДляНекоторыхКлассов" Тогда
						// backColor = new CsColor(Base_obj.BackColor);
						// public CsColor backColor;
						// public CsColor BackColor
						// {
							// get { return backColor; }
							// set
							// {
								// backColor = value;
								// Base_obj.BackColor = value.Base_obj;
							// }
						// }
						ПриватСвойство = НРег(Лев(СвойствоАнгл, 1)) + Сред(СвойствоАнгл, 2);
						СтрРазделОбъявленияПеременных = СтрРазделОбъявленияПеременных + Символы.ПС +
						"        private " + ТипВозвращаемогоЗначения + " " + ПриватСвойство + ";";
						СтрКонструктор = СтрЗаменить(СтрКонструктор, 
						"        }//end_constr"
						, 
						"            " + ПриватСвойство + " = new " + ТипВозвращаемогоЗначения + "(Base_obj." + СвойствоАнгл + ");
						|        }//end_constr"
						);
						ВозвратГет = "    " + Комментарий + "get { return " + ПриватСвойство + "; }";
						ВозвратСет = "    " + Комментарий + "set 
						|            {
						|                " + ПриватСвойство + " = value;
						|                Base_obj." + СвойствоАнгл + " = value.Base_obj;
						|            }";
					ИначеЕсли ШаблонДляГетСет = "ШаблонДляКлассовЧерезHashtable" Тогда
						// get
						// {
							// return (ClIcon)OneScriptClientServer.RevertObj(Base_obj.Icon, "StatusBarPanel.Значок");
						// }
						// set
						// {
							// Base_obj.Icon = value.Base_obj;
							// Base_obj.Icon.dll_obj = value;
						// }
						ВозвратГет = "    " + Комментарий + "get { return (" + ТипВозвращаемогоЗначения + ")OneScriptClientServer.RevertObj(Base_obj." + СвойствоАнгл + "); }";
						ВозвратСет = "    " + Комментарий + "set 
						|            {
						|                Base_obj." + СвойствоАнгл + " = value.Base_obj; 
						|                Base_obj." + СвойствоАнгл + ".dll_obj = value;
						|            }";
					ИначеЕсли ШаблонДляГетСет = "ШаблонДляПеречисления" Тогда
						// get { return (int)Base_obj.TextAlign; }
						// set { Base_obj.TextAlign = value; }
						ВозвратГет = "    get { return (int)Base_obj." + СвойствоАнгл + "; }";          
						ВозвратСет = "    set { Base_obj." + СвойствоАнгл + " = value; }";
					ИначеЕсли ШаблонДляГетСет = "ОбщийШаблон" Тогда
						// get { return (ClDataGridCell)OneScriptClientServer.RevertObj(Base_obj.CurrentCell); }
						// set { Base_obj.Bounds = value.Base_obj; }
						ВозвратГет = "    " + Комментарий + "get { return (" + ТипВозвращаемогоЗначения + ")OneScriptClientServer.RevertObj(Base_obj." + СвойствоАнгл + "); }";
						ВозвратСет = "    " + Комментарий + "set { Base_obj." + СвойствоАнгл + " = value.Base_obj; }";
					КонецЕсли;
				КонецЕсли;

				Стр = Стр +
				"        " + Комментарий + "[ContextProperty(""" + СвойствоРус + """, """ + СвойствоАнгл + """)]" + Символы.ПС + 
				"        " + Комментарий + "public " + ТипВозвращаемогоЗначения + " " + СвойствоАнгл + Символы.ПС + 
				"        " + Комментарий + "{" + Символы.ПС;
				//находим есть ли set get
				Если СтрИспользование = "Чтение и запись." Тогда
					Стр = Стр +
					"        " + Комментарий + ВозвратГет + Символы.ПС +
					"        " + Комментарий + ВозвратСет + Символы.ПС;
				Иначе
					Стр = Стр +
					"        " + Комментарий + ВозвратГет + Символы.ПС;
				КонецЕсли;
				Стр = Стр +
				"        " + Комментарий + "}" + Символы.ПС + Символы.ПС;
			КонецЕсли;
		КонецЦикла;
	Иначе
		Стр = 
		"        //Свойства============================================================" + Символы.ПС;
	КонецЕсли;
	
	Возврат Стр;
КонецФункции//Свойства

Функция ПеречисленияКакСвойства(ИмяФайлаЧленов)
	Если Не (ИмяФайлаЧленов = КаталогСправки + "\OSClientServer.OneScriptClientServerMembers.html") Тогда
		Возврат "";
	КонецЕсли;
	
	СписокПереч2 = Новый СписокЗначений;
	
	ТекстДок = Новый ТекстовыйДокумент;
	ТекстДок.Прочитать(КаталогСправки + "\OSClientServer.html");
	Стр = ТекстДок.ПолучитьТекст();
	//находим строку таблицы
	М_СтрТаблПереч = СтрНайтиМежду(Стр, "<H3 class=dtH3>Перечисления</H3>", "</TBODY></TABLE>", Ложь, );
	Если М_СтрТаблПереч.Количество() > 0 Тогда
		СтрТаблПереч = СтрНайтиМежду(Стр, "<H3 class=dtH3>Перечисления</H3>", "</TBODY></TABLE>", Ложь, )[0];
		М48 = СтрНайтиМежду(СтрТаблПереч, "<TR vAlign=top>" + Символы.ПС + "    <TD", "</TD></TR>", Ложь, );
		Для А61 = 0 По М48.ВГраница() Цикл
			СтрТабл = М48[А61];
			СтрТабл = СтрЗаменить(СтрТабл, "&nbsp;", " ");
			// Сообщить("-СтрТабл-----------------------");
			// Сообщить("" + СтрТабл);
			Предст2 = СтрНайтиМежду(СтрТабл, ".html"">", " ", , )[0];
			Знач2 = СтрНайтиМежду(СтрТабл, "(", ")", , )[0];
			СписокПереч2.Добавить(Знач2, Предст2);
		КонецЦикла;
	КонецЕсли;
	Стр = "" + Символы.ПС;
	Для А = 0 По СписокПереч2.Количество() - 1 Цикл
		// Сообщить("" + СписокПереч2.Получить(А).Представление + " -- " + СписокПереч2.Получить(А).Значение);
		Знач3 = СписокПереч2.Получить(А).Значение;
		Предст3 = СписокПереч2.Получить(А).Представление;
		// Сообщить("Знач3 - " + Знач3 + " Предст3 - " + Предст3);
		
		// Если Предст3 = "РежимСтороннегоКлиента" Тогда
			// СтрРазделОбъявленияПеременных = СтрРазделОбъявленияПеременных + Символы.ПС +
			// "        public static int cs_ThirdPartyClientMode = 0;";
		// Иначе
			СтрРазделОбъявленияПеременных = СтрРазделОбъявленияПеременных + Символы.ПС +
			"        private static Cs" + Знач3 + " cs_" + Знач3 + " = new Cs" + Знач3 + "();";
			Стр = Стр + Символы.ПС + 
			"        [ContextProperty(""" + Предст3 + """, """ + Знач3 + """)]
			|        public Cs" + Знач3 + " " + Знач3 + "
			|        {
			|            get { return cs_" + Знач3 + "; }
			|        }" + Символы.ПС;
		// КонецЕсли;
	КонецЦикла;
		Стр = Стр + Символы.ПС;
	Возврат Стр;
	
КонецФункции//ПеречисленияКакСвойства

Функция Методы(ИмяФайлаЧленов, ИмяКонтекстКлассаАнгл)
	ТекстДокЧленов = Новый ТекстовыйДокумент;
	КаталогНаДиске = Новый Файл(ИмяФайлаЧленов);
    Если Не (КаталогНаДиске.Существует()) Тогда
        Стр = 
		"        //Методы============================================================" + Символы.ПС;
		Возврат Стр;
	КонецЕсли;
	ТекстДокЧленов.Прочитать(ИмяФайлаЧленов);
	СтрТекстДокЧленов = ТекстДокЧленов.ПолучитьТекст();
	Если Не (СтрНайтиМежду(СтрТекстДокЧленов, "<H4 class=dtH4>Методы</H4>", "</TBODY></TABLE>", Ложь, ).Количество() > 0) Тогда
		Стр = 
		"        //Методы============================================================" + Символы.ПС;
		Возврат Стр;
	КонецЕсли;
	СтрТаблицаЧленов = СтрНайтиМежду(СтрТекстДокЧленов, "<H4 class=dtH4>Методы</H4>", "</TBODY></TABLE>", Ложь, )[0];
	Массив1 = СтрНайтиМежду(СтрТаблицаЧленов, "<TR vAlign=top>", "</TD></TR>", Ложь, );
	//переберем строки таблицы
	Если Массив1.Количество() > 0 Тогда
		Стр = "        //Методы============================================================" + Символы.ПС;
		Для А = 0 По Массив1.ВГраница() Цикл
			//найдем первую ячейку строки таблицы
			М07 = СтрНайтиМежду(Массив1[А], "<TD width=""50%"">", "</TD>", Ложь, );
			СтрХ = М07[0];
			СтрХ = СтрЗаменить(СтрХ, "&nbsp;", " ");
			МетодАнгл = СтрНайтиМежду(СтрХ, "(", ")", , )[0];
			// // // Сообщить("-ИмяФайлаЧленов---------------------------");
			// // // Сообщить("" + ИмяФайлаЧленов);
			// // // Сообщить("-МетодАнгл---------------------------");
			// // // Сообщить("" + МетодАнгл);
			МетодРус = СтрНайтиМежду(СтрХ, ".html"">", " (", , )[0];
			Если (МетодРус = "TCPСервер") и (ИмяКонтекстКлассаАнгл = "OneScriptClientServer") Тогда
				Стр = Стр +
				"        [ContextMethod(""TCPСервер"", ""TcpServer"")]
				|        public CsTcpServer TcpServer(int p1)
				|        {
				|            return new CsTcpServer(p1);
				|        }
				|
				|";
			ИначеЕсли (МетодРус = "Действие") и (ИмяКонтекстКлассаАнгл = "OneScriptClientServer") Тогда
				Стр = Стр +
				"        [ContextMethod(""Действие"", ""Action"")]
				|        public CsAction Action(IRuntimeContextInstance script, string methodName)
				|        {
				|            return new CsAction(script, methodName);
				|        }
				|
				|";
			ИначеЕсли (МетодРус = "TCPКонечнаяТочка") и (ИмяКонтекстКлассаАнгл = "OneScriptClientServer") Тогда
				Стр = Стр +
				"        [ContextMethod(""TCPКонечнаяТочка"", ""TcpEndPoint"")]
				|        public CsTcpEndPoint TcpEndPoint(string p1, int p2)
				|        {
				|            return new CsTcpEndPoint(p1, p2);
				|        }
				|
				|";
			ИначеЕсли (МетодРус = "TCPКлиент") и (ИмяКонтекстКлассаАнгл = "OneScriptClientServer") Тогда
				Стр = Стр +
				"        [ContextMethod(""TCPКлиент"", ""TcpClient"")]
				|        public CsTcpClient TcpClient(CsTcpEndPoint p1)
				|        {
				|            return new CsTcpClient(p1);
				|        }
				|
				|";
			ИначеЕсли (МетодРус = "СообщениеТекст") и (ИмяКонтекстКлассаАнгл = "OneScriptClientServer") Тогда
				Стр = Стр +
				"        [ContextMethod(""СообщениеТекст"", ""TextMessage"")]
				|        public CsTextMessage TextMessage(string p1)
				|        {
				|            return new CsTextMessage(p1);
				|        }
				|
				|";
			ИначеЕсли (МетодРус = "СообщениеБайты") и (ИмяКонтекстКлассаАнгл = "OneScriptClientServer") Тогда
				Стр = Стр +
				"        [ContextMethod(""СообщениеБайты"", ""ByteMessage"")]
				|        public CsByteMessage ByteMessage(BinaryDataContext p1 = null)
				|        {
				|            return new CsByteMessage(p1);
				|        }
				|
				|";
			ИначеЕсли (МетодРус = "СообщениеЧисло") и (ИмяКонтекстКлассаАнгл = "OneScriptClientServer") Тогда
				Стр = Стр +
				"        [ContextMethod(""СообщениеЧисло"", ""NumberMessage"")]
				|        public CsNumberMessage NumberMessage(IValue p1 = null)
				|        {
				|            return new CsNumberMessage(p1);
				|        }
				|
				|";
			ИначеЕсли (МетодРус = "СообщениеБулево") и (ИмяКонтекстКлассаАнгл = "OneScriptClientServer") Тогда
				Стр = Стр +
				"        [ContextMethod(""СообщениеБулево"", ""BoolMessage"")]
				|        public CsBoolMessage BoolMessage(IValue p1 = null)
				|        {
				|            if (p1 != null)
				|            {
				|                return new CsBoolMessage(p1.AsBoolean());
				|            }
				|            return new CsBoolMessage();
				|        }
				|
				|";
			ИначеЕсли (МетодРус = "СообщениеДата") и (ИмяКонтекстКлассаАнгл = "OneScriptClientServer") Тогда
				Стр = Стр +
				"        [ContextMethod(""СообщениеДата"", ""DateTimeMessage"")]
				|        public CsDateTimeMessage DateTimeMessage(IValue p1 = null)
				|        {
				|            if (p1 != null)
				|            {
				|                return new CsDateTimeMessage(p1.AsDate());
				|            }
				|            return new CsDateTimeMessage();
				|        }
				|
				|";
			ИначеЕсли (МетодРус = "ОтправитьСообщение") и 
				(ИмяКонтекстКлассаАнгл = "TcpClient" или 
				ИмяКонтекстКлассаАнгл = "ServerClient") Тогда
				Стр = Стр +
				"        [ContextMethod(""ОтправитьСообщение"", ""SendMessage"")]
				|        public void SendMessage(IValue p1)
				|        {
				|            Base_obj.SendMessage(((dynamic)p1).Base_obj.M_Obj);
				|        }
				|
				|";
			ИначеЕсли (МетодРус = "ПолучитьСобытие") и (ИмяКонтекстКлассаАнгл = "OneScriptClientServer") Тогда
				Стр = Стр +
				"        [ContextMethod(""ПолучитьСобытие"", ""DoEvents"")]
				|        public DelegateAction DoEvents()
				|        {
				|            while (EventQueue.Count == 0)
				|            {
				|                System.Threading.Thread.Sleep(7);
				|            }
				|
				|            IValue Action1 = EventHandling();
				|            if (Action1.GetType() == typeof(CsAction))
				|            {
				|                return DelegateAction.Create(((CsAction)Action1).Script, ((CsAction)Action1).MethodName);
				|            }
				|            return (DelegateAction)Action1;
				|        }
				|
				|        public static IValue EventHandling()
				|        {
				|            dynamic EventArgs1;
				|            EventQueue.TryDequeue(out EventArgs1);
				|            Event = EventArgs1.dll_obj;
				|            EventAction = EventArgs1.EventAction;
				|            return EventAction;
				|        }
				|
				|";
			ИначеЕсли (МетодРус = "ПриложениеСервис") и (ИмяКонтекстКлассаАнгл = "OneScriptClientServer") Тогда
				Стр = Стр +
				"        [ContextMethod(""ПриложениеСервис"", ""ServiceApplication"")]
				|        public CsServiceApplication ServiceApplication(int p1, IRuntimeContextInstance p2)
				|        {
				|            return new CsServiceApplication(p1, p2);
				|        }
				|
				|";
			ИначеЕсли (МетодРус = "ПриложениеКлиент") и (ИмяКонтекстКлассаАнгл = "OneScriptClientServer") Тогда
				Стр = Стр +
				"        [ContextMethod(""ПриложениеКлиент"", ""ServiceClient"")]
				|        public CsServiceClient ServiceClient(CsTcpEndPoint p1, IRuntimeContextInstance p2)
				|        {
				|            return new CsServiceClient(p1, p2);
				|        }
				|
				|";
			ИначеЕсли (МетодРус = "ВыполнитьНаСервереАрг") и (ИмяКонтекстКлассаАнгл = "OneScriptClientServer") Тогда
				Стр = Стр +
				"        [ContextMethod(""ВыполнитьНаСервереАрг"", ""DoAtServerArgs"")]
				|        public CsDoAtServerArgs DoAtServerArgs()
				|        {
				|            return (CsDoAtServerArgs)Event;
				|        }
				|
				|";
			ИначеЕсли (МетодРус = "ВыполнитьНаКлиентеАрг") и (ИмяКонтекстКлассаАнгл = "OneScriptClientServer") Тогда
				Стр = Стр +
				"        [ContextMethod(""ВыполнитьНаКлиентеАрг"", ""DoAtClientArgs"")]
				|        public CsDoAtClientArgs DoAtClientArgs()
				|        {
				|            return (CsDoAtClientArgs)Event;
				|        }
				|
				|";
			ИначеЕсли (МетодРус = "ВыполнитьНаСервере") и (ИмяКонтекстКлассаАнгл = "ServiceClient") Тогда
				Стр = Стр +
				"        [ContextMethod(""ВыполнитьНаСервере"", ""DoAtServer"")]
				|        public IValue DoAtServer(string p1, ArrayImpl p2 = null)
				|        {
				|            if (Base_obj.CommunicationState == (int)CommunicationStates.Disconnected)
				|            {
				|                return null;
				|            }
				|
				|            ArrayList array = new ArrayList();
				|            if (p2 != null)
				|            {
				|                array = new ArrayList();
				|                for (int i = 0; i < p2.Count(); i++)
				|                {
				|                    array.Add(OneScriptClientServer.RedefineIValue(p2.Get(i)));
				|                }
				|            }
				|
				|            dynamic res = Base_obj.Proxy.DoAtServerWithResalt(p1, array);
				|            if (res.GetType() == typeof(System.Byte[]))
				|            {
				|                return new BinaryDataContext(res);
				|            }
				|            return ValueFactory.Create(res);
				|        }
				|
				|";
			ИначеЕсли (МетодРус = "ВыполнитьНаКлиенте") и (ИмяКонтекстКлассаАнгл = "ServiceClient") Тогда
				Стр = Стр +
				"        [ContextMethod(""ВыполнитьНаКлиенте"", ""DoAtClient"")]
				|        public IValue DoAtClient(string p1, string p2, ArrayImpl p3 = null)
				|        {
				|            if (Base_obj.CommunicationState == (int)CommunicationStates.Disconnected)
				|            {
				|                return null;
				|            }
				|				
				|            ArrayList array = new ArrayList();
				|            if (p3 != null)
				|            {
				|                array = new ArrayList();
				|                for (int i = 0; i < p3.Count(); i++)
				|                {
				|                    array.Add(OneScriptClientServer.RedefineIValue(p3.Get(i)));
				|                }
				|            }
				|
				|            dynamic res = Base_obj.Proxy.DoAtClientWithResalt(this.ClientGuid, p1, p2, array);
				|            if (res.GetType() == typeof(System.Byte[]))
				|            {
				|                return new BinaryDataContext(res);
				|            }
				|            return ValueFactory.Create(res);
				|        }
				|
				|";
			ИначеЕсли (МетодРус = "ВыполнитьНаКлиенте") и (ИмяКонтекстКлассаАнгл = "ServiceApplication") Тогда
				Стр = Стр +
				"        [ContextMethod(""ВыполнитьНаКлиенте"", ""DoAtClient"")]
				|        public IValue DoAtClient(string p1, string p2, ArrayImpl p3 = null)
				|        {
				|            ArrayImpl ArrayImpl1 = Base_obj.Proxy.Clients;
				|
				|            foreach (CsServiceApplicationClient item in ArrayImpl1)
				|            {
				|                if (item.CommunicationState == (int)CommunicationStates.Disconnected)
				|                {
				|                    return null;
				|                }
				|
				|                ArrayList array = new ArrayList();
				|                if (p3 != null)
				|                {
				|                    array = new ArrayList();
				|                    for (int i = 0; i < p3.Count(); i++)
				|                    {
				|                        array.Add(OneScriptClientServer.RedefineIValue(p3.Get(i)));
				|                    }
				|                }
				|
				|                dynamic res = item.ClientProxy.DoAtClientWithResalt(p1, p2, array);
				|                if (res.GetType() == typeof(System.Byte[]))
				|                {
				|                    return new BinaryDataContext(res);
				|                }
				|                return ValueFactory.Create(res);
				|            }
				|            return null;
				|        }
				|
				|";
			ИначеЕсли (МетодРус = "Отключить") и (ИмяКонтекстКлассаАнгл = "ServiceApplicationClient") Тогда
				Стр = Стр +
				"        [ContextMethod(""Отключить"", ""Disconnect"")]
				|        public void Disconnect()
				|        {
				|            Client.Disconnect();
				|        }
				|
				|";
			ИначеЕсли (МетодРус = "ПолучитьИнформациюКлиентов") и (ИмяКонтекстКлассаАнгл = "ServiceClient") Тогда
				Стр = Стр +
				"        [ContextMethod(""ПолучитьИнформациюКлиентов"", ""GetClientsInfo"")]
				|        public ArrayImpl GetClientsInfo()
				|        {
				|            ClientInfo[] array = Base_obj.Proxy.GetClientsList();
				|            ArrayImpl arrayImpl = new ArrayImpl();
				|            for (int i = 0; i < array.Length; i++)
				|            {
				|                ClientInfo ClientInfo1 = (ClientInfo)array[i];
				|                CsClientInfo CsClientInfo1 = new CsClientInfo(ClientInfo1.ClientGuid, ClientInfo1.ClientName, ClientInfo1.Tag);
				|                arrayImpl.Add(CsClientInfo1);
				|            }
				|            return arrayImpl;
				|        }
				|
				|";
				
				
				
				
				
				
				
				
				
				
				
				
				
				
			Иначе
				ИмяФайлаМетода = КаталогСправки + "\" + СтрНайтиМежду(СтрХ, "<A href=""", """>", , )[0];
				ТекстДокМетода = Новый ТекстовыйДокумент;
				ТекстДокМетода.Прочитать(ИмяФайлаМетода);
				СтрТекстДокМетода = ТекстДокМетода.ПолучитьТекст();
				// Сообщить("===================================================");
				// Сообщить("ИмяФайлаМетода = " + ИмяФайлаМетода);
				// Сообщить("СтрТекстДокМетода = " + СтрТекстДокМетода);
				СтрРаздела = СтрНайтиМежду(СтрТекстДокМетода, "<H4 class=dtH4>Параметры</H4>", "<H4 class=dtH4>Возвращаемое значение</H4>", , )[0];
				// <H4 class=dtH4>Параметры</H4>
				// <DL>
				// <DT><I>ИмяФайла</I> (обязательный)</DT>
				// <DD>Тип: Строка.</DD>
				// <DD>Строка, содержащая имя файла для сохранения этого объекта <A href="OneScriptClientServer.Image.html">Изображение&nbsp;(Image)</A>.</DD>
				
				// <DT><I>Формат</I> (необязательный)</DT>
				// <DD>Тип: <A href="OneScriptClientServer.ImageFormat.html">ФорматИзображения&nbsp;(ImageFormat)</A>.</DD>
				// <DD>Объект <A href="OneScriptClientServer.ImageFormat.html">ФорматИзображения&nbsp;(ImageFormat)</A> для этого 
				// объекта <A href="OneScriptClientServer.Image.html">Изображение&nbsp;(Image)</A>.</DD></DL>
				// <H4 class=dtH4>Возвращаемое значение</H4>
				М06 = СтрНайтиМежду(СтрРаздела, "<DT><I>", "</DD>", Ложь, );//Строка содержит параметр и тип параметра
				СтрПараметровВСкобках = "(";
				СтрПараметровВСкобках2 = "(";
				Для А01 = 0 По М06.ВГраница() Цикл
					М10 = СтрНайтиМежду(М06[А01], "<DD>", "</DD>", , );//Строка содержит тип параметра
					// Тип: Строка.
					// Тип: Число.
					// Тип: Булево.
					// Тип: Дата.
					// Тип: Произвольный.
					// Тип: Массив.
					// Тип: Строка; <A href="OneScriptClientServer.ColumnHeader.html">Колонка&nbsp;(ColumnHeader)</A>.
					// Тип: Строка; Число.
					// Тип: Строка; Число; <A href="OneScriptClientServer.DataColumn.html">КолонкаДанных&nbsp;(DataColumn)</A>.
					ТипПараметраВСкобках = "хххх";
					Если М10.Количество() > 0 Тогда
						// Сообщить("" + М10[0]);
						М11 = СтрНайтиМежду(М06[А01], "(", ")", , );
						Если М11.Количество() > 1 Тогда
							ТипПараметраВСкобках = "Cs" + М11[1];
							// если ТипПараметраВСкобках является перечислением, меняем его на int
							Если ИменаКалассовПеречислений.НайтиПоЗначению(ТипПараметраВСкобках) = Неопределено Тогда
							Иначе
								ТипПараметраВСкобках = "int";
							КонецЕсли;
						Иначе
							Если М10[0] = "Тип: Строка." Тогда
								ТипПараметраВСкобках = "string";
							ИначеЕсли М10[0] = "Тип: Число." Тогда
								ТипПараметраВСкобках = "int";
							ИначеЕсли М10[0] = "Тип: Булево." Тогда
								ТипПараметраВСкобках = "bool";
							ИначеЕсли М10[0] = "Тип: Дата." Тогда
								ТипПараметраВСкобках = "DateTime";	
							ИначеЕсли М10[0] = "Тип: Произвольный." Тогда
								ТипПараметраВСкобках = "IValue";
							ИначеЕсли М10[0] = "Тип: Массив." Тогда
								ТипПараметраВСкобках = "dynamic";	
							ИначеЕсли СтрНайти(М10[0], ";") > 0 Тогда
								ТипПараметраВСкобках = "dynamic";
							Иначе
								Сообщить("Не хватает типа " + М10[0]);
								ЗавершитьРаботу(5);
							КонецЕсли;
						КонецЕсли;
					КонецЕсли;
					
					Если А01 = М06.ВГраница() Тогда
						Если СтрНайти(ТипПараметраВСкобках, "Cs") > 0 Тогда
							СтрПараметровВСкобках = СтрПараметровВСкобках + ТипПараметраВСкобках + " p" + Строка(А01 + 1);
							СтрПараметровВСкобках2 = СтрПараметровВСкобках2 + "p" + Строка(А01 + 1) + ".Base_obj";
						Иначе
							СтрПараметровВСкобках = СтрПараметровВСкобках + ТипПараметраВСкобках + " p" + Строка(А01 + 1);
							СтрПараметровВСкобках2 = СтрПараметровВСкобках2 + "p" + Строка(А01 + 1);
						КонецЕсли;
					Иначе
						Если СтрНайти(ТипПараметраВСкобках, "Cs") > 0 Тогда
							СтрПараметровВСкобках = СтрПараметровВСкобках + ТипПараметраВСкобках + " p" + Строка(А01 + 1) + ", ";
							СтрПараметровВСкобках2 = СтрПараметровВСкобках2 + "p" + Строка(А01 + 1) + ".Base_obj, ";
						Иначе
							СтрПараметровВСкобках = СтрПараметровВСкобках + ТипПараметраВСкобках + " p" + Строка(А01 + 1) + ", ";
							СтрПараметровВСкобках2 = СтрПараметровВСкобках2 + "p" + Строка(А01 + 1) + ", ";
						КонецЕсли;
					КонецЕсли;
					
				КонецЦикла;
				СтрПараметровВСкобках =СтрПараметровВСкобках + ")";
				СтрПараметровВСкобках2 =СтрПараметровВСкобках2 + ")";
				
				//найдем возвращаемое методом значение
				ВозвращаемоеМетодомЗначение = СтрНайтиМежду(СтрТекстДокМетода, "<H4 class=dtH4>Возвращаемое значение</H4>", "<H4 class=dtH4>Описание</H4>", , )[0];
				ВозвращаемоеМетодомЗначение = СтрНайтиМежду(ВозвращаемоеМетодомЗначение, "<P>", "</P>", , )[0];
				// Сообщить("" + МетодАнгл + " == " + ВозвращаемоеМетодомЗначение);
				// Сообщить("" + ВозвращаемоеМетодомЗначение);
				// Тип: Строка.
				// Тип: Число.
				// Тип: Булево.
				// Тип: Дата.
				// Тип: Произвольный.
				// Тип: <A href="OneScriptClientServer.Application.html">Приложение&nbsp;(Application)</A>.
				Комментарий = "//";
				Ретён = "return Base_obj." + МетодАнгл;
				Если СтрНайтиМежду(ВозвращаемоеМетодомЗначение, "(", ")", , ).Количество() > 0 Тогда // это класс
					ВозвращаемоеМетодомЗначение = "Cs" + СтрНайтиМежду(ВозвращаемоеМетодомЗначение, "(", ")", , )[0];
					Ретён = "return new " + ВозвращаемоеМетодомЗначение;
					//раскомментим если ВозвращаемоеМетодомЗначение равно
					Если (ВозвращаемоеМетодомЗначение = "ClPoint") или 
						(ВозвращаемоеМетодомЗначение = "ClDictionaryEntry") или 
						
						(ВозвращаемоеМетодомЗначение = "ClGraphics") Тогда
						Комментарий = "";
					КонецЕсли;
				ИначеЕсли ВозвращаемоеМетодомЗначение = "Тип: Строка." Тогда
					ВозвращаемоеМетодомЗначение = "string";
					Комментарий = "";
				ИначеЕсли ВозвращаемоеМетодомЗначение = "Тип: Число." Тогда
					ВозвращаемоеМетодомЗначение = "int";
					Комментарий = "";
				ИначеЕсли ВозвращаемоеМетодомЗначение = "Тип: Булево." Тогда
					ВозвращаемоеМетодомЗначение = "bool";
					Комментарий = "";
				ИначеЕсли ВозвращаемоеМетодомЗначение = "Тип: Дата." Тогда
					ВозвращаемоеМетодомЗначение = "DateTime";
					Комментарий = "";
				ИначеЕсли ВозвращаемоеМетодомЗначение = "Тип: Произвольный." Тогда
					ВозвращаемоеМетодомЗначение = "IValue";
				ИначеЕсли СтрНайти(ВозвращаемоеМетодомЗначение,";") > 0 Тогда
					ВозвращаемоеМетодомЗначение = "dynamic";
				ИначеЕсли СокрЛП(ВозвращаемоеМетодомЗначение) = "" Тогда
					ВозвращаемоеМетодомЗначение = "void";
					Комментарий = "";
				Иначе
					Сообщить("Не хватает ВозвращаемоеМетодомЗначение " + М10[0]);
					ЗавершитьРаботу(4);
				КонецЕсли;
			
				Если ВозвращаемоеМетодомЗначение = "void" Тогда
					Если СтрПараметровВСкобках = "()" Тогда
						// [ContextMethod("ЗавершитьОбновление", "EndUpdate")]
						// public void EndUpdate()
						// {
						//	   Base_obj.EndUpdate();
						// }
						СтрХвост = 
						"        " + Комментарий + "[ContextMethod(""" + МетодРус + """, """ + МетодАнгл + """)]
						|        " + Комментарий + "public void " + МетодАнгл + "()
						|        " + Комментарий + "{
						|        " + Комментарий + "    Base_obj." + МетодАнгл + "();
						|        " + Комментарий + "}
						|					
						|";
						// Сообщить("СтрХвост = " + СтрХвост);
						Стр = Стр + СтрХвост;
					Иначе
						// [ContextMethod("ЗагрузитьФайл", "LoadFile")]
						// public void LoadFile(string p1, ClRichTextBoxStreamType p2)
						// {
						// 	Base_obj.LoadFile(p1, p2.Base_obj);
						// }
						СтрХвост = 
						"        " + Комментарий + "[ContextMethod(""" + МетодРус + """, """ + МетодАнгл + """)]
						|        " + Комментарий + "public void " + МетодАнгл + СтрПараметровВСкобках + "
						|        " + Комментарий + "{
						|        " + Комментарий + "    Base_obj." + МетодАнгл + СтрПараметровВСкобках2 + ";
						|        " + Комментарий + "}" + Символы.ПС +Символы.ПС;
						// Сообщить("СтрХвост = " + СтрХвост);
						Стр = Стр + СтрХвост;
					КонецЕсли;
				ИначеЕсли ВозвращаемоеМетодомЗначение = "string" или 
					ВозвращаемоеМетодомЗначение = "int" или 
					ВозвращаемоеМетодомЗначение = "bool" или 
					ВозвращаемоеМетодомЗначение = "DateTime" Тогда // это простые типы
					Если СтрПараметровВСкобках = "()" Тогда
						// [ContextMethod("ПрочитатьДоКонца", "ReadToEnd")]
						// public string ReadToEnd()
						// {
						// 		return Base_obj.ReadToEnd();
						// }					
						СтрХвост = 
						"        " + Комментарий + "[ContextMethod(""" + МетодРус + """, """ + МетодАнгл + """)]
						|        " + Комментарий + "public " + ВозвращаемоеМетодомЗначение + " " + МетодАнгл + "()
						|        " + Комментарий + "{
						|        " + Комментарий + "    " + Ретён + СтрПараметровВСкобках2 + ";
						|        " + Комментарий + "}" + Символы.ПС +Символы.ПС;
						// Сообщить("СтрХвост = " + СтрХвост);
						Стр = Стр + СтрХвост;
					Иначе
						// [ContextMethod("Найти", "Seek")]
						// public int Seek(int p1, int p2)
						// {
						// 	return Base_obj.Seek(p1, p2);
						// }
						СтрХвост = 
						"        " + Комментарий + "[ContextMethod(""" + МетодРус + """, """ + МетодАнгл + """)]
						|        " + Комментарий + "public " + ВозвращаемоеМетодомЗначение + " " + МетодАнгл + СтрПараметровВСкобках + "
						|        " + Комментарий + "{
						|        " + Комментарий + "    " + Ретён + СтрПараметровВСкобках2 + ";
						|        " + Комментарий + "}" + Символы.ПС +Символы.ПС;
						// Сообщить("СтрХвост = " + СтрХвост);
						Стр = Стр + СтрХвост;
					КонецЕсли;
				ИначеЕсли СтрНайти(ВозвращаемоеМетодомЗначение, "Cs") > 0 Тогда // это класс
					Если СтрПараметровВСкобках = "()" Тогда
						// [ContextMethod("Форма", "Form")]
						// public CsForm Form()
						// {
						// 	return new CsForm();
						// }
						СтрХвост = 
						"        " + Комментарий + "[ContextMethod(""" + МетодРус + """, """ + МетодАнгл + """)]
						|        " + Комментарий + "public " + ВозвращаемоеМетодомЗначение + " " + МетодАнгл + "()
						|        " + Комментарий + "{
						|        " + Комментарий + "    " + Ретён + "();
						|        " + Комментарий + "}" + Символы.ПС +Символы.ПС;
						// Сообщить("СтрХвост = " + СтрХвост);
						Стр = Стр + СтрХвост;
					Иначе
						//[ContextMethod("Вставить", "Insert")]
						//public CsListViewItem Insert(int p1, ClListViewItem p2)
						//{
						//    return new CsListViewItem(p1, p2.Base_obj);
						//}						
						СтрХвост = 
						"        " + Комментарий + "[ContextMethod(""" + МетодРус + """, """ + МетодАнгл + """)]
						|        " + Комментарий + "public " + ВозвращаемоеМетодомЗначение + " " + МетодАнгл + СтрПараметровВСкобках + "
						|        " + Комментарий + "{
						|        " + Комментарий + "    " + Ретён + СтрПараметровВСкобках2 + ";
						|        " + Комментарий + "}" + Символы.ПС +Символы.ПС;
						// Сообщить("СтрХвост = " + СтрХвост);
						Стр = Стр + СтрХвост;
					КонецЕсли;
				Иначе // до сюда не должны дойти, все варианты учтены
					Стр = Стр + 
					"        " + Комментарий + "[ContextMethod(""" + МетодРус + """, """ + МетодАнгл + """)]" + Символы.ПС +
					"        " + Комментарий + "public void " + МетодАнгл + "()" + Символы.ПС +
					"        " + Комментарий + "{" + Символы.ПС;
					Если Не (ВозвращаемоеМетодомЗначение = "void") Тогда
						Стр = Стр + 
						"        " + Комментарий + "    " + Ретён + СтрПараметровВСкобках2 + ";" + Символы.ПС;
					Иначе
						Стр = Стр + 
						"        " + Комментарий + "    Base_obj." + МетодАнгл + СтрПараметровВСкобках2 + ";" + Символы.ПС;
					КонецЕсли;
					Стр = Стр + 
					"        " + Комментарий + "}" + Символы.ПС +Символы.ПС;
				КонецЕсли;
			КонецЕсли;
			
			
		КонецЦикла;
	Иначе
		Стр = 
		"        //Методы============================================================" + Символы.ПС;
	КонецЕсли;
	
	
	Возврат Стр;
КонецФункции//Методы

Функция Подвал()
	Стр = 
	"    }//endClass";
	Возврат Стр;
КонецФункции

Функция СтрНайтиМежду(СтрПараметр, Фрагмент1 = Неопределено, Фрагмент2 = Неопределено, ИсключитьФрагменты = Истина, БезНаложения = Истина)
	//Стр - исходная строка
	//Фрагмент1 - подстрока поиска от которой ведем поиск
	//Фрагмент2 - подстрока поиска до которой ведем поиск
	//ИсключитьФрагменты - не включать Фрагмент1 и Фрагмент2 в результат
	//БезНаложения - в результат не будут включены участки, содержащие другие найденные участки, удовлетворяющие переданным параметрам
	//функция возвращает массив строк
	Стр = СтрПараметр;
	М = Новый Массив;
	Если (Фрагмент1 <> Неопределено) и (Фрагмент2 = Неопределено) Тогда
		Позиция = Найти(Стр, Фрагмент1);
		Пока Позиция > 0 Цикл
			М.Добавить(?(ИсключитьФрагменты, Сред(Стр, Позиция + СтрДлина(Фрагмент1)), Сред(Стр, Позиция)));
			Стр = Сред(Стр, Позиция + 1);
			Позиция = Найти(Стр, Фрагмент1);
		КонецЦикла;
	ИначеЕсли (Фрагмент1 = Неопределено) и (Фрагмент2 <> Неопределено) Тогда
		Позиция = Найти(Стр, Фрагмент2);
		СуммаПозиций = Позиция;
		Пока Позиция > 0 Цикл
			М.Добавить(?(ИсключитьФрагменты, Сред(Стр, 1, СуммаПозиций - 1), Сред(Стр, 1, СуммаПозиций - 1 + СтрДлина(Фрагмент2))));
			Позиция = Найти(Сред(Стр, СуммаПозиций + 1), Фрагмент2);
			СуммаПозиций = СуммаПозиций + Позиция;
		КонецЦикла;
	ИначеЕсли (Фрагмент1 <> Неопределено) и (Фрагмент2 <> Неопределено) Тогда
		Позиция = Найти(Стр, Фрагмент1);
		Пока Позиция > 0 Цикл
			Стр2 = ?(ИсключитьФрагменты, Сред(Стр, Позиция + СтрДлина(Фрагмент1)), Сред(Стр, Позиция));
			Позиция2 = Найти(Стр2, Фрагмент2);
			СуммаПозиций2 = Позиция2;
			Пока Позиция2 > 0 Цикл
				Если БезНаложения Тогда
					Если Найти(Сред(Стр2, 1, СуммаПозиций2 - 1), Фрагмент2) = 0 Тогда
						М.Добавить("" + ?(ИсключитьФрагменты, Сред(Стр2, 1, СуммаПозиций2 - 1), Сред(Стр2, 1, СуммаПозиций2 - 1 + СтрДлина(Фрагмент2))));
					КонецЕсли;
				Иначе
					М.Добавить("" + ?(ИсключитьФрагменты, Сред(Стр2, 1, СуммаПозиций2 - 1), Сред(Стр2, 1, СуммаПозиций2 - 1 + СтрДлина(Фрагмент2))));
				КонецЕсли;
				Позиция2 = Найти(Сред(Стр2, СуммаПозиций2 + 1), Фрагмент2);
				СуммаПозиций2 = СуммаПозиций2 + Позиция2;
			КонецЦикла;
			Стр = Сред(Стр, Позиция + 1);
			Позиция = Найти(Стр, Фрагмент1);
		КонецЦикла;
	КонецЕсли;
	
	Возврат М;
КонецФункции//СтрНайтиМежду

Процедура ВыгрузкаДляCS()
	Таймер = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	ИменаКалассовПеречислений = Новый СписокЗначений;
	ОтобранныеПеречисления = ОтобратьФайлы("Перечисление");
	Для А = 0 По ОтобранныеПеречисления.ВГраница() Цикл
		СтрКлассПеречисления = "" + ОтобранныеПеречисления[А];
		СтрКлассПеречисления = СтрЗаменить(СтрКлассПеречисления, КаталогСправки + "\OSClientServer.", "Cs");
		СтрКлассПеречисления = СтрЗаменить(СтрКлассПеречисления, ".html", "");
		ИменаКалассовПеречислений.Добавить(СтрКлассПеречисления);
	КонецЦикла;
	// Сообщить("Количество = " + ИменаКалассовПеречислений.Количество());
	// Для А = 0 По ИменаКалассовПеречислений.Количество() - 1 Цикл
		// Сообщить("" + ИменаКалассовПеречислений.Получить(А).Значение);
	// КонецЦикла;
	
	УдалитьФайлы(КаталогВыгрузки, "*.cs");
	
	СоздатьФайлCs("EventArgs");
	СоздатьФайлCs("TcpServer");
	СоздатьФайлCs("ServerClient");
	СоздатьФайлCs("ServerClientEventArgs");
	СоздатьФайлCs("ScsSupport");
	СоздатьФайлCs("TcpEndPoint");
	СоздатьФайлCs("TcpClient");
	СоздатьФайлCs("ByteMessage");
	СоздатьФайлCs("TextMessage");
	СоздатьФайлCs("MessageEventArgs");
	СоздатьФайлCs("NumberMessage");
	СоздатьФайлCs("DateTimeMessage");
	СоздатьФайлCs("BoolMessage");
	СоздатьФайлCs("ServiceApplication");
	СоздатьФайлCs("ServiceClient");
	СоздатьФайлCs("ServiceClientEventArgs");
	СоздатьФайлCs("DoAtServerArgs");
	СоздатьФайлCs("IMyService");
	СоздатьФайлCs("MyService");
	СоздатьФайлCs("DoAtClientArgs");
	СоздатьФайлCs("ServiceApplicationClient");
	СоздатьФайлCs("IMyClient");
	СоздатьФайлCs("MyClient");
	СоздатьФайлCs("ClientInfo");
	СоздатьФайлCs("Collection");
	
	
	
	СписокЗамен = Новый СписокЗначений;
	
	ТекстДок = Новый ТекстовыйДокумент;
	ТекстДок.Прочитать(КаталогСправки + "\OSClientServer.OneScriptClientServerMethods.html");
	Стр = ТекстДок.ПолучитьТекст();
	Массив1 = СтрНайтиМежду(Стр, "<TR vAlign=top>", "</TD></TR>", Ложь, );
	Если Массив1.Количество() > 0 Тогда
		СтрМетодовСистема = "";
		Для А = 0 По Массив1.ВГраница() Цикл
			М07 = СтрНайтиМежду(Массив1[А], "<TD width=""50%"">", "</TD>", Ложь, );
			СтрХ = М07[0];
			СтрХ = СтрЗаменить(СтрХ, "&nbsp;", " ");
			МетодАнгл = СтрНайтиМежду(СтрХ, "(", ")", , )[0];
			МетодРус = СтрНайтиМежду(СтрХ, ".html"">", " (", , )[0];
			Если А = Массив1.ВГраница() Тогда
				СтрМетодовСистема = СтрМетодовСистема + МетодРус + " (" + МетодАнгл + ")";
			Иначе
				СтрМетодовСистема = СтрМетодовСистема + МетодРус + " (" + МетодАнгл + "),";
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	СписокСтрМетодовСистема = Новый СписокЗначений;
	М15 = РазобратьСтроку(СтрМетодовСистема, ",");
	Для А = 0 По М15.ВГраница() Цикл
		СписокСтрМетодовСистема.Добавить(СтрНайтиМежду(М15[А], "(", ")", , )[0]);
	КонецЦикла;
	// Сообщить("СписокСтрМетодовСистема.Количество = " + СписокСтрМетодовСистема.Количество());
	
	СписокФайлов = Новый СписокЗначений;
	ВыбранныеФайлы = ОтобратьФайлы("Класс");
	Для А = 0 По ВыбранныеФайлы.ВГраница() Цикл
		
		Если ВыбранныеФайлы[А] = "C:\444\OSClientServerRu\OSClientServerRu.ййййййййййййй.html" Тогда
			Продолжить;
		КонецЕсли;
		
		ТекстДок = Новый ТекстовыйДокумент;
		ТекстДок.Прочитать(ВыбранныеФайлы[А]);
		Стр = ТекстДок.ПолучитьТекст();
		СтрЗаголовка = СтрНайтиМежду(Стр, "<H1 class=dtH1", "/H1>", , )[0];
		М01 = СтрНайтиМежду(СтрЗаголовка, "(", ")", , );
		Стр33 = СтрЗаголовка;
		Стр33 = СтрЗаменить(Стр33, "&nbsp;", " ");
		Стр33 = СтрЗаменить(Стр33, ">", "");
		М08 = РазобратьСтроку(Стр33, " ");
		
		// КаталогВыгрузки + "\"
		// КаталогВыгрузки + \"
		
		ИмяФайлаВыгрузки = КаталогВыгрузки + "\" + М01[0] + ".cs";
		
		ИмяКонтекстКлассаАнгл = М01[0];
		ИмяКонтекстКлассаРус = М08[0];
		// находим имя файла членов
		ИмяФайлаЧленов = КаталогСправки + "\OSClientServer." + М01[0] + "Members.html";
		СтрДирективы = Директивы(ИмяКонтекстКлассаАнгл);
		СтрШапка = Шапка(ИмяКонтекстКлассаАнгл, ИмяКонтекстКлассаРус);
		СтрРазделОбъявленияПеременных = РазделОбъявленияПеременных(ИмяФайлаЧленов, М01[0]);
		СтрКонструктор = Конструктор(ИмяФайлаЧленов, М01[0]);
		СтрBase_obj = Base_obj(ИмяКонтекстКлассаАнгл);
		СтрСвойства = Свойства(ИмяФайлаЧленов, ИмяКонтекстКлассаАнгл);
		СтрПеречисленияКакСвойства = ПеречисленияКакСвойства(ИмяФайлаЧленов);
		СтрМетоды = Методы(ИмяФайлаЧленов, ИмяКонтекстКлассаАнгл);
		СтрПодвал = Подвал();
		
		СортироватьСтрРазделОбъявленияПеременных();
		СтрВыгрузки = "";
		СтрВыгрузки = СтрВыгрузки + СтрШапка + Символы.ПС;
		СтрВыгрузки = СтрВыгрузки + СтрРазделОбъявленияПеременных + Символы.ПС;
		СтрВыгрузки = СтрВыгрузки + СтрКонструктор + Символы.ПС;
		СтрВыгрузки = СтрВыгрузки + СтрBase_obj + Символы.ПС;
		СтрВыгрузки = СтрВыгрузки + СтрСвойства;
		СтрВыгрузки = СтрВыгрузки + "        //endProperty" + Символы.ПС;
		СтрВыгрузки = СтрВыгрузки + СтрПеречисленияКакСвойства;
		СтрВыгрузки = СтрВыгрузки + СтрМетоды;
		СтрВыгрузки = СтрВыгрузки + "        //endMethods" + Символы.ПС;
		СтрВыгрузки = СтрВыгрузки + СтрПодвал + Символы.ПС;
		
		//если это класс ИмяКонтекстКлассаАнгл = OneScriptClientServer 
		// тогда нужно дозаписать методы создания экземпляров каждого класса если он ещё отсутствует в СтрВыгрузки
		Если ИмяКонтекстКлассаАнгл = "OneScriptClientServer" Тогда
			ВыбранныеФайлы_2 = ОтобратьФайлы("Класс");
			Для А_2 = 0 По ВыбранныеФайлы_2.ВГраница() Цикл
				ТекстДок_2 = Новый ТекстовыйДокумент;
				ТекстДок_2.Прочитать(ВыбранныеФайлы_2[А_2]);
				Стр_2 = ТекстДок_2.ПолучитьТекст();
				СтрЗаголовка_2 = СтрНайтиМежду(Стр_2, "<H1 class=dtH1", "/H1>", , )[0];
				М01_2 = СтрНайтиМежду(СтрЗаголовка_2, "(", ")", , );
				Стр33_2 = СтрЗаголовка_2;
				Стр33_2 = СтрЗаменить(Стр33_2, "&nbsp;", " ");
				Стр33_2 = СтрЗаменить(Стр33_2, ">", "");
				М08_2 = РазобратьСтроку(Стр33_2, " ");
				ИмяКонтекстКлассаАнгл = М01_2[0];
				ИмяКонтекстКлассаРус = М08_2[0];
				
				// для классов - аргументов свои правила
				Если Прав(ИмяКонтекстКлассаАнгл, 4) = "Args" Тогда
					Если Не (ИмяКонтекстКлассаАнгл = "EventArgs") Тогда
						ПодстрокаПоиска = 
						"        //endMethods";
						ПодстрокаЗамены = 
						"        [ContextMethod(""" + ИмяКонтекстКлассаРус + """, """ + ИмяКонтекстКлассаАнгл + """)]
						|        public Cs" + ИмяКонтекстКлассаАнгл + " " + ИмяКонтекстКлассаАнгл + "()
						|        {
						|        	return (Cs" + ИмяКонтекстКлассаАнгл + ")Event;
						|        }
						|        
						|        //endMethods";
						СтрВыгрузки = СтрЗаменить(СтрВыгрузки, ПодстрокаПоиска, ПодстрокаЗамены);
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
			
			//добавим методы в oscs.OneScriptClientServer
			ПодстрокаПоиска = 
			"        //endMethods";
			ПодстрокаЗамены = 
			"        public static IValue RevertObj(dynamic initialObject) 
			|        {
			|            //ScriptEngine.Machine.Values.NullValue NullValue1;
			|            //ScriptEngine.Machine.Values.BooleanValue BooleanValue1;
			|            //ScriptEngine.Machine.Values.DateValue DateValue1;
			|            //ScriptEngine.Machine.Values.NumberValue NumberValue1;
			|            //ScriptEngine.Machine.Values.StringValue StringValue1;
			|
			|            //ScriptEngine.Machine.Values.GenericValue GenericValue1;
			|            //ScriptEngine.Machine.Values.TypeTypeValue TypeTypeValue1;
			|            //ScriptEngine.Machine.Values.UndefinedValue UndefinedValue1;
			|
			|            try
			|            {
			|                if (initialObject == null)
			|                {
			|                    return (IValue)null;
			|                }
			|            }
			|            catch { }
			|
			|            try
			|            {
			|                string str_initialObject = initialObject.GetType().ToString();
			|            }
			|            catch
			|            {
			|                return (IValue)null;
			|            }
			|
			|            dynamic Obj1 = null;
			|            string str1 = initialObject.GetType().ToString();
			|            try
			|            {
			|                Obj1 = initialObject.dll_obj;
			|            }
			|            catch { }
			|            if (Obj1 != null)
			|            {
			|                return (IValue)Obj1;
			|            }
			|
			|            try
			|            {
			|                Obj1 = initialObject.M_Object.dll_obj;
			|            }
			|            catch { }
			|            if (Obj1 != null)
			|            {
			|                return (IValue)Obj1;
			|            }
			|
			|            try // если initialObject не из пространства имен oscs, то есть Уровень1
			|            {
			|                if (!str1.Contains(""oscs.""))
			|                {
			|                    string str2 = ""oscs.Cs"" + str1.Substring(str1.LastIndexOf(""."") + 1);
			|                    System.Type TestType = System.Type.GetType(str2, false, true);
			|                    object[] args = { initialObject };
			|                    Obj1 = Activator.CreateInstance(TestType, args);
			|                }
			|            }
			|            catch { }
			|            if (Obj1 != null)
			|            {
			|                return (IValue)Obj1;
			|            }
			|
			|            try // если initialObject из пространства имен oscs, то есть Уровень2
			|            {
			|                if (str1.Contains(""oscs.""))
			|                {
			|                    string str3 = str1.Replace(""oscs."", ""oscs.Cs"");
			|                    System.Type TestType = System.Type.GetType(str3, false, true);
			|                    object[] args = { initialObject };
			|                    Obj1 = Activator.CreateInstance(TestType, args);
			|                }
			|            }
			|            catch { }
			|            if (Obj1 != null)
			|            {
			|                return (IValue)Obj1;
			|            }
			|
			|            string str4 = null;
			|            try
			|            {
			|                str4 = initialObject.SystemType.Name;
			|            }
			|            catch
			|            {
			|                if ((str1 == ""System.String"") ||
			|                (str1 == ""System.Decimal"") ||
			|                (str1 == ""System.Int32"") ||
			|                (str1 == ""System.Boolean"") ||
			|                (str1 == ""System.DateTime""))
			|                {
			|                    return (IValue)ValueFactory.Create(initialObject);
			|                }
			|                else if (str1 == ""System.Byte"")
			|                {
			|                    int vOut = Convert.ToInt32(initialObject);
			|                    return (IValue)ValueFactory.Create(vOut);
			|                }
			|                else if (str1 == ""System.DBNull"")
			|                {
			|                    string vOut = Convert.ToString(initialObject);
			|                    return (IValue)ValueFactory.Create(vOut);
			|                }
			|            }
			|			
			|            if (str4 == ""Неопределено"")
			|            {
			|                return (IValue)null;
			|            }
			|            if (str4 == ""Булево"")
			|            {
			|                return (IValue)initialObject;
			|            }
			|            if (str4 == ""Дата"")
			|            {
			|                return (IValue)initialObject;
			|            }
			|            if (str4 == ""Число"")
			|            {
			|                return (IValue)initialObject;
			|            }
			|            if (str4 == ""Строка"")
			|            {
			|                return (IValue)initialObject;
			|            }
			|            return (IValue)initialObject;
			|        }
			|			
			|        public static dynamic RedefineIValue(dynamic p1)
			|        {
			|            if (p1.GetType() == typeof(ScriptEngine.Machine.Values.StringValue))
			|            {
			|                return p1.AsString();
			|            }
			|            else if (p1.GetType() == typeof(ScriptEngine.Machine.Values.NumberValue))
			|            {
			|                return p1.AsNumber();
			|            }
			|            else if (p1.GetType() == typeof(ScriptEngine.Machine.Values.BooleanValue))
			|            {
			|                return p1.AsBoolean();
			|            }
			|            else if (p1.GetType() == typeof(ScriptEngine.Machine.Values.DateValue))
			|            {
			|                return p1.AsDate();
			|            }
			|            else if (p1.GetType() == typeof(BinaryDataContext))
			|            {
			|                return p1.Buffer;
			|            }
			|            else
			|            {
			|                return p1;
			|            }
			|        }
			|			
			|        //endMethods";
			СтрВыгрузки = СтрЗаменить(СтрВыгрузки, ПодстрокаПоиска, ПодстрокаЗамены);
		КонецЕсли;
		
		//последние исправления СтрВыгрузки
		// // // ПодстрокаПоиска = "public CsDataType DataType";
		// // // ПодстрокаЗамены = "public new CsDataType DataType";
		// // // СтрВыгрузки = СтрЗаменить(СтрВыгрузки, ПодстрокаПоиска, ПодстрокаЗамены);
		
		Файл1 = Новый Файл(ИмяФайлаВыгрузки);
		Если Не (Файл1.Существует()) Тогда
			ЗаписьТекста1 = Новый ЗаписьТекста();
			ЗаписьТекста1.Открыть(ИмяФайлаВыгрузки,,,);
			Если ИмяФайлаВыгрузки = КаталогВыгрузки + "\OneScriptClientServer.cs" Тогда // Директивы для OneScriptClientServer.cs задаются здесь
				Стр88 = 
				"using System;
				|using ScriptEngine.Machine.Contexts;
				|using ScriptEngine.Machine;
				|using ScriptEngine.HostedScript.Library;
				|using ScriptEngine.HostedScript.Library.Binary;
				|using System.Collections.Concurrent;
				|
				|";
			Иначе
				Стр88 = Директивы(ИмяКонтекстКлассаАнгл);
			КонецЕсли;
			Стр88 = Стр88 + 
			"namespace oscs
			|{
			|}//endnamespace
			|";
			ЗаписьТекста1.Записать(Стр88);
			ЗаписьТекста1.Закрыть();
		Иначе

		КонецЕсли;
		
		//не создаем класса с префиксом Cs (остается только класс второго уровня)
		Если Не (
			ИмяКонтекстКлассаАнгл = "ButtonBase" или 
			ИмяКонтекстКлассаАнгл = "UpDownBase" или 
			ИмяКонтекстКлассаАнгл = "Component" или 
			ИмяКонтекстКлассаАнгл = "ScrollableControl" или 
			ИмяКонтекстКлассаАнгл = "Control" или 
			ИмяКонтекстКлассаАнгл = "CollectionBase" или 
			ИмяКонтекстКлассаАнгл = "Brush" или 
			ИмяКонтекстКлассаАнгл = "ScrollBar" или 
			ИмяКонтекстКлассаАнгл = "ListControl" или 
			ИмяКонтекстКлассаАнгл = "TextBoxBase" или 
			ИмяКонтекстКлассаАнгл = "Image" или 
			ИмяКонтекстКлассаАнгл = "CommonDialog" или 
			ИмяКонтекстКлассаАнгл = "DataGridColumnStyle" или 
			ИмяКонтекстКлассаАнгл = "FileDialog" или 
			ИмяКонтекстКлассаАнгл = "DataGridViewBand" или 
			ИмяКонтекстКлассаАнгл = "ContainerControl")
		
		Тогда //дописываем в файл класс с префиксом Cs (класс третьего уровня) для классов
			ЧтениеТекста1 = Новый ЧтениеТекста(ИмяФайлаВыгрузки);
			Стр77 = ЧтениеТекста1.Прочитать();
			ЧтениеТекста1.Закрыть();
			
			ПодстрокаПоиска = "}//endnamespace";
			ПодстрокаЗамены = СтрВыгрузки + Символы.ПС + "}//endnamespace";
			Стр77 = СтрЗаменить(Стр77, ПодстрокаПоиска, ПодстрокаЗамены);
			
			ЗаписьТекста1 = Новый ЗаписьТекста();
			ЗаписьТекста1.Открыть(ИмяФайлаВыгрузки,,,);
			ЗаписьТекста1.Записать(Стр77);
			ЗаписьТекста1.Закрыть();
		КонецЕсли;
	КонецЦикла;
	//===============================================================================================================================
	ВыбранныеФайлы = ОтобратьФайлы("Перечисление");
	Для А = 0 По ВыбранныеФайлы.ВГраница() Цикл
		ТекстДок = Новый ТекстовыйДокумент;
		ТекстДок.Прочитать(ВыбранныеФайлы[А]);
		Стр = ТекстДок.ПолучитьТекст();
		СтрЗаголовка= СтрНайтиМежду(Стр, "<H1 class=dtH1", "/H1>", , )[0];
		М01 = СтрНайтиМежду(СтрЗаголовка, "(", ")", , );
		СтрЗаголовка = СтрЗаменить(СтрЗаголовка, "&nbsp;", " ");
		Стр33 = СтрНайтиМежду(СтрЗаголовка, ">", " Перечисление<", , )[0];
		Стр33 = СтрЗаменить(Стр33, "&nbsp;", " ");
		Стр33 = СтрЗаменить(Стр33, ">", "");
		М08 = РазобратьСтроку(Стр33, " ");
		ИмяФайлаВыгрузки = КаталогВыгрузки + "\" + М01[0] + ".cs";
		ИмяКонтекстКлассаАнгл = М01[0];
		ИмяКонтекстКлассаРус = М08[0];
		// Сообщить("====" + ИмяКонтекстКлассаАнгл);

		
		//находим текст таблицы
		СтрТаблица = СтрНайтиМежду(Стр, "</TH></TR>" + Символы.ПС + "  <TR vAlign=top>", "</TBODY></TABLE>", Ложь, );
		СтрТаблицыПеречисления = СтрНайтиМежду(СтрТаблица[0], "<TR vAlign=top>", "</TD></TR>", Ложь, );
		СтрРазделОбъявленияПеременныхДляПеречисления = "";
		СтрСвойстваДляПеречисления = "";
		Для А02 = 0 По СтрТаблицыПеречисления.ВГраница() Цикл
			М12 = СтрНайтиМежду(СтрТаблицыПеречисления[А02], "<TD>", "</TD>", , );
			М14 = СтрНайтиМежду(М12[0], "<B>", "</B>", , );
			М13 = РазобратьСтроку(СтрЗаменить(М14[0], "&nbsp;", " "), " ");
			ИмяПеречАнгл = М01[0];
			ИмяПеречРус = М08[0];
			ИмяЧленаАнгл = М13[1];
			// Сообщить("==" + ИмяЧленаАнгл);
			// если здесь ошибка, тогда возможно есть лишний пробел в одном из значений перечисления
			ИмяЧленаАнгл = СтрНайтиМежду(ИмяЧленаАнгл, "(", ")", , )[0];
			ИмяЧленаРус = М13[0];
			ОписаниеЧлена = М12[1];
			Пока СтрЧислоВхождений(ОписаниеЧлена, Символы.ПС) > 0 Цикл
				ОписаниеЧлена = СтрЗаменить(ОписаниеЧлена, Символы.ПС, " ");
			КонецЦикла;
			Пока СтрЧислоВхождений(ОписаниеЧлена, Символы.Таб) > 0 Цикл
				ОписаниеЧлена = СтрЗаменить(ОписаниеЧлена, Символы.Таб, " ");
			КонецЦикла;
			Пока СтрЧислоВхождений(ОписаниеЧлена, "  ") > 0 Цикл
				ОписаниеЧлена = СтрЗаменить(ОписаниеЧлена, "  ", " ");
			КонецЦикла;
			ЗначениеЧлена = М12[2];
			// Сообщить("--------------");
			// Сообщить("ИмяПеречРус = " + ИмяПеречРус);
			// Сообщить("ИмяПеречАнгл = " + ИмяПеречАнгл);
			// Сообщить("ИмяЧленаРус = " + ИмяЧленаРус);
			// Сообщить("ИмяЧленаАнгл = " + ИмяЧленаАнгл);
			// Сообщить("ОписаниеЧлена = " + ОписаниеЧлена);
			// Сообщить("ЗначениеЧлена = " + ЗначениеЧлена);
			
			СоставнаяСтр = ИмяЧленаАнгл;
			СоставнаяСтр = НРег(Лев(СоставнаяСтр, 1)) + Сред(СоставнаяСтр, 2);
			// private int strikeout = (int)FontStyle.Strikeout; // 8 Зачеркнутый шрифт.
			Если ИмяКонтекстКлассаАнгл = "CommunicationStates" Тогда
				ИмяКонтекстКлассаАнгл1 = "Hik.Communication.Scs.Communication." + ИмяКонтекстКлассаАнгл;
			Иначе
				ИмяКонтекстКлассаАнгл1 = ИмяКонтекстКлассаАнгл;
			КонецЕсли;
			Если ИмяКонтекстКлассаАнгл = "ClientMode" Тогда // это перечисление собственное (не от микрософт)
				СтрРазделОбъявленияПеременныхДляПеречисления = СтрРазделОбъявленияПеременныхДляПеречисления + Символы.ПС + 
				"        private int m_" + СоставнаяСтр + " = " + ЗначениеЧлена + "; // " + ЗначениеЧлена + " " + ОписаниеЧлена;
				
				СтрСвойстваДляПеречисления = СтрСвойстваДляПеречисления + Символы.ПС + 
				"        [ContextProperty(""" + ИмяЧленаРус + """, """ + ИмяЧленаАнгл + """)]
				|        public int " + ИмяЧленаАнгл + "
				|        {
				|        	get { return m_" + СоставнаяСтр + "; }
				|        }" + ?(А02 = СтрТаблицыПеречисления.ВГраница(), "", Символы.ПС);
			Иначе
				СтрРазделОбъявленияПеременныхДляПеречисления = СтрРазделОбъявленияПеременныхДляПеречисления + Символы.ПС + 
				"        private int m_" + СоставнаяСтр + " = (int)" + ИмяКонтекстКлассаАнгл1 + "." + ИмяЧленаАнгл + "; // " + ЗначениеЧлена + " " + ОписаниеЧлена;
				
				СтрСвойстваДляПеречисления = СтрСвойстваДляПеречисления + Символы.ПС + 
				"        [ContextProperty(""" + ИмяЧленаРус + """, """ + ИмяЧленаАнгл + """)]
				|        public int " + ИмяЧленаАнгл + "
				|        {
				|        	get { return m_" + СоставнаяСтр + "; }
				|        }" + ?(А02 = СтрТаблицыПеречисления.ВГраница(), "", Символы.ПС);
			КонецЕсли;
		КонецЦикла;
		
		//последние исправления СтрСвойстваДляПеречисления
		ПодстрокаПоиска = "(int)System.Environment.SpecialFolder.SystemDirectory;";
		ПодстрокаЗамены = "(int)System.Environment.SpecialFolder.System;";
		СтрРазделОбъявленияПеременныхДляПеречисления = СтрЗаменить(СтрРазделОбъявленияПеременныхДляПеречисления, ПодстрокаПоиска, ПодстрокаЗамены);
		
		СтрВыгрузкиПеречисленийШапка = Директивы(ИмяКонтекстКлассаАнгл);
		СтрВыгрузкиПеречислений = СтрВыгрузкиПеречисленийШапка + Символы.ПС + 
		"
		|namespace oscs
		|{
		|    [ContextClass(""Кс" + ИмяКонтекстКлассаРус + """, ""Cs" + ИмяКонтекстКлассаАнгл + """)]
		|    public class Cs" + ИмяКонтекстКлассаАнгл + " : AutoContext<Cs" + ИмяКонтекстКлассаАнгл + ">
		|    {";
		СортироватьСтрРазделОбъявленияПеременныхДляПеречисления();
		СтрВыгрузкиПеречислений = СтрВыгрузкиПеречислений + СтрРазделОбъявленияПеременныхДляПеречисления + Символы.ПС;
		СтрВыгрузкиПеречислений = СтрВыгрузкиПеречислений + СтрСвойстваДляПеречисления + Символы.ПС;
		СтрВыгрузкиПеречислений = СтрВыгрузкиПеречислений + Символы.ПС + 
		"    }//endClass" + Символы.ПС + 
		"}//endnamespace";
	
		ТекстДокПеречислений = Новый ТекстовыйДокумент;
		ТекстДокПеречислений.УстановитьТекст(СтрВыгрузкиПеречислений);
		ТекстДокПеречислений.Записать(ИмяФайлаВыгрузки);
		
	КонецЦикла;
	
	// СписокЗамен.СортироватьПоЗначению();
	// Сообщить("=СписокЗамен========================================================");
	// Для А = 0 По СписокЗамен.Количество() - 1 Цикл
		// Сообщить("" + СписокЗамен.Получить(А).Значение);
	// КонецЦикла;
	

	
	Сообщить("Выполнено за: " + ((ТекущаяУниверсальнаяДатаВМиллисекундах()-Таймер)/1000)/60 + " мин." + " " + ТекущаяДата());
КонецПроцедуры//ВыгрузкаДляCS

Процедура СоздатьФайлCs(ИмяФайлаCs)
	СтрВыгрузки = Директивы(ИмяФайлаCs);
	Если Ложь Тогда
	// ИначеЕсли ИмяФайлаCs = "" Тогда
		// СтрВыгрузки = СтрВыгрузки + 
		// "namespace oscs
		// |{
		
		// |    }//endClass
		// |}//endnamespace
		// |";
		// ТекстДокХХХ = Новый ТекстовыйДокумент;
		// ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		// ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
		
		
		
	
		
		
		
		
		
		
		
		
		
	ИначеЕсли ИмяФайлаCs = "Collection" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace oscs
		|{
		|    [Serializable]
		|    public class Collection
		|    {
		|        private Dictionary<string, object> M_Collection;
		|
		|        public Collection()
		|        {
		|            M_Collection = new Dictionary<string, object>();
		|        }
		|
		|        public Collection(Dictionary<string, object> p1)
		|        {
		|            M_Collection = p1;
		|        }
		|
		|        public Collection(oscs.Collection p1)
		|        {
		|            M_Collection = p1.M_Collection;
		|        }
		|
		|        public int Count
		|        {
		|            get
		|            {
		|                int count = 0;
		|                foreach (KeyValuePair<string, object>  DictionaryEntry in M_Collection)
		|                {
		|                    count = count + 1;
		|                }
		|                return count;
		|            }
		|        }
		|
		|        public object this[string index]
		|        {
		|            get { return M_Collection[index]; }
		|        }
		|
		|        public System.Collections.IEnumerator GetEnumerator()
		|        {
		|            return M_Collection.GetEnumerator();
		|        }
		|
		|        public void Add(string key, object item)
		|        {
		|            M_Collection.Add(key, item);
		|        }
		|
		|        public void Remove(string index)
		|        {
		|            M_Collection.Remove(index);
		|        }
		|    }//endClass
		|}//endnamespace
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "ClientInfo" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace oscs
		|{
		|    [Serializable]
		|    public class ClientInfo
		|    {
		|        public string ClientGuid { get; set; }
		|        public string ClientName { get; set; }
		|        public oscs.Collection Tag { get; set; }
		|
		|        public ClientInfo(string p1, string p2, oscs.Collection p3)
		|        {
		|            ClientGuid = p1;
		|            ClientName = p2;
		|            Tag = p3;
		|        }
		|    }//endClass
		|}//endnamespace
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "MyClient" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace oscs
		|{
		|    // Этот класс реализует IMyClient, который используется для вызова сервером.
		|    public class MyClient : IMyClient
		|    {
		|        // Создает новый клиент.
		|        public MyClient()
		|        {
		|        }
		|
		|        public dynamic DoAtClientWithResaltFromServer(string clientGuid, string methodName, ArrayList parametersArray = null)
		|        {
		|            ArrayImpl arrayImpl = null;
		|            if (parametersArray != null)
		|            {
		|                arrayImpl = new ArrayImpl();
		|                for (int i = 0; i < parametersArray.Count; i++)
		|                {
		|                    dynamic val = (dynamic)parametersArray[i];
		|                    if (val.GetType() == typeof(System.Byte[]))
		|                    {
		|                        var binaryDataContext = new BinaryDataContext(val);
		|                        arrayImpl.Add(binaryDataContext);
		|                    }
		|                    else
		|                    {
		|                        IValue ival = ValueFactory.Create(val);
		|                        arrayImpl.Add(ival);
		|                    }
		|                }
		|            }
		|
		|            OneScriptClientServer.CurrentServiceClient.ParametersArray = arrayImpl;
		|            OneScriptClientServer.CurrentServiceClient.MethodName = methodName;
		|
		|            return OneScriptClientServer.RedefineIValue(OneScriptClientServer.CurrentServiceClient.Resalt);
		|        }
		|
		|        public dynamic DoAtClientWithResalt(string clientGuid, string methodName, ArrayList parametersArray = null)
		|        {
		|            ArrayImpl arrayImpl = null;
		|            if (parametersArray != null)
		|            {
		|                arrayImpl = new ArrayImpl();
		|                for (int i = 0; i < parametersArray.Count; i++)
		|                {
		|                    dynamic val = (dynamic)parametersArray[i];
		|                    if (val.GetType() == typeof(System.Byte[]))
		|                    {
		|                        var binaryDataContext = new BinaryDataContext(val);
		|                        arrayImpl.Add(binaryDataContext);
		|                    }
		|                    else
		|                    {
		|                        IValue ival = ValueFactory.Create(val);
		|                        arrayImpl.Add(ival);
		|                    }
		|                }
		|            }
		|
		|            OneScriptClientServer.CurrentServiceClient.ParametersArray = arrayImpl;
		|            OneScriptClientServer.CurrentServiceClient.MethodName = methodName;
		|
		|            while (OneScriptClientServer.CurrentServiceClient.resalt.ToString() == ""7b7540f9-27e6-4e4a-a0b1-8012ac6e5737"")
		|            {
		|                System.Threading.Thread.Sleep(17);
		|            }
		|            return OneScriptClientServer.RedefineIValue(OneScriptClientServer.CurrentServiceClient.Resalt);
		|        }
		|    }
		|}
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "IMyClient" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace oscs
		|{
		|    // Этот интерфейс определяет методы клиента.
		|    // Определенные методы вызываются сервером.
		|    public interface IMyClient
		|    {
		|        dynamic DoAtClientWithResalt(string clientGuid, string methodName, ArrayList parametersArray = null);
		|        dynamic DoAtClientWithResaltFromServer(string clientGuid, string methodName, ArrayList parametersArray = null);
		|    }
		|}
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "ServiceApplicationClient" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace oscs
		|{
		|}//endnamespace
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "DoAtClientArgs" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace oscs
		|{
		|    public class DoAtClientArgs : oscs.EventArgs
		|    {
		|        public new CsDoAtClientArgs dll_obj;
		|        private string methodName;
		|        private ArrayImpl parametersArray;
		|
		|        public DoAtClientArgs(string p1, ArrayImpl p2)
		|        {
		|            methodName = p1;
		|            parametersArray = p2;
		|        }
		|
		|        public string MethodName
		|        {
		|            get { return methodName; }
		|            set { methodName = value; }
		|        }
		|
		|        public ArrayImpl ParametersArray
		|        {
		|            get { return parametersArray; }
		|            set { parametersArray = value; }
		|        }
		|    }//endClass
		|}//endnamespace
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "MyService" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace oscs
		|{
		|    public class MyService : ScsService, IMyService
		|    {
		|        private object _lock = new object();
		|        private object _lock2 = new object();
		|
		|        // Список всех подключенных клиентов.
		|        private readonly ThreadSafeSortedList<long, MyClient> _clients;
		|
		|        // Конструктор.
		|        public MyService()
		|        {
		|            _clients = new ThreadSafeSortedList<long, MyClient>();
		|        }
		|		
		|        public ClientInfo[] GetClientsList()
		|        {
		|            List<MyClient> list = _clients.GetAllItems();
		|            ClientInfo[] array = new ClientInfo[list.Count];
		|            for (int i = 0; i < list.Count; i++)
		|            {
		|                MyClient item = list[i];
		|                ClientInfo ClientInfo1 = new ClientInfo(item.Guid, item.ClientName, item.Tag);
		|                array[i] = ClientInfo1;
		|            }
		|            return array;
		|        }
		|
		|        public dynamic DoAtClientWithResalt(string senderClientGuid, string clientGuid, string methodName, ArrayList parametersArray = null)
		|        {
		|            ArrayImpl ArrayImpl1 = this.Clients;
		|
		|            foreach (CsServiceApplicationClient item in ArrayImpl1)
		|            {
		|                if (item.CommunicationState != (int)CommunicationStates.Disconnected)
		|                {
		|                    if (senderClientGuid == item.ClientGuid)
		|                    {
		|                        continue;
		|                    }
		|
		|                    if (clientGuid == item.ClientGuid)
		|                    {
		|                        return item.ClientProxy.DoAtClientWithResaltFromServer(item.ClientGuid, methodName, parametersArray);
		|                    }
		|                }
		|            }
		|            return null;
		|        }
		|
		|        public dynamic DoAtServerWithResalt(string methodName, ArrayList parametersArray = null)
		|        {
		|            ArrayImpl arrayImpl = null;
		|            if (parametersArray != null)
		|            {
		|                arrayImpl = new ArrayImpl();
		|                for (int i = 0; i < parametersArray.Count; i++)
		|                {
		|                    dynamic val = (dynamic)parametersArray[i];
		|                    if (val.GetType() == typeof(System.Byte[]))
		|                    {
		|                        var binaryDataContext = new BinaryDataContext(val);
		|                        arrayImpl.Add(binaryDataContext);
		|                    }
		|                    else
		|                    {
		|                        IValue ival = ValueFactory.Create(val);
		|                        arrayImpl.Add(ival);
		|                    }
		|                }
		|            }
		|
		|            lock (_lock2)
		|            {
		|                OneScriptClientServer.CurrentServiceApplication.ParametersArray = arrayImpl;
		|                OneScriptClientServer.CurrentServiceApplication.MethodName = methodName;
		|
		|                while (OneScriptClientServer.CurrentServiceApplication.resalt.ToString() == ""92b55f72-41f9-4b03-8d64-01c7bd10325f"")
		|                {
		|                    System.Threading.Thread.Sleep(17);
		|                }
		|            }
		|
		|            return OneScriptClientServer.RedefineIValue(OneScriptClientServer.CurrentServiceApplication.Resalt);
		|        }
		|
		|        public override string ToString()
		|        {
		|            return base.ToString();
		|        }
		|
		|        public ArrayImpl Clients
		|        {
		|            get
		|            {
		|                List<MyClient> list = _clients.GetAllItems();
		|                ArrayImpl arrayImpl = new ArrayImpl();
		|                for (int i = 0; i < list.Count; i++)
		|                {
		|                    arrayImpl.Add(list[i].Client.dll_obj);
		|                }
		|                return arrayImpl;
		|            }
		|        }
		|
		|        // Используется при подключении клиента.
		|        public void AtClientEntrance(string guid, string clientName, oscs.Collection tag)
		|        {
		|            // Получите ссылку на текущего клиента, который вызывает этот метод.
		|            var client = CurrentClient;
		|
		|            // Получите прокси-объект для вызова методов клиента.
		|            var clientProxy = client.GetClientProxy<IMyClient>();
		|
		|            CsServiceApplicationClient CsServiceApplicationClient1 = new CsServiceApplicationClient(client);
		|            client.dll_obj = CsServiceApplicationClient1;
		|            CsServiceApplicationClient1.clientGuid = guid;
		|            CsServiceApplicationClient1.ClientProxy = clientProxy;
		|
		|            // Создайте клиента и сохраните его в коллекции.
		|            var myClient = new MyClient(client, clientProxy, guid, clientName, tag);
		|            _clients[client.ClientId] = myClient;
		|
		|            // Зарегистрируйтесь на событие Disconnected, чтобы узнать, когда пользовательское соединение закрыто.
		|            client.Disconnected += Client_Disconnected;
		|        }
		|
		|        // Обрабатывает событие отключения всех клиентов.
		|        private void Client_Disconnected(object sender, System.EventArgs e)
		|        {
		|            // Получить объект клиента.
		|            var client = (IScsServiceClient)sender;
		|
		|            // Выполните выход из системы. Таким образом, если клиент не вызывал метод выхода перед закрытием, мы выполняем выход автоматически.
		|            AtClientExit(client.ClientId);
		|        }
		|
		|        // Используется для выхода клиента.
		|        // Клиент может не вызывать этот метод при выходе из системы (в случае сбоя приложения),
		|        // он также будет автоматически отключен при сбое соединения между клиентом и сервером.
		|        public void AtClientExit(long clientId)
		|        {
		|            // Получить клиента из списка клиентов, если его нет в списке, не продолжать.
		|            var client = _clients[clientId];
		|            if (client == null)
		|            {
		|                return;
		|            }
		|
		|            // Удалить клиента из списка клиентов.
		|            _clients.Remove(client.Client.ClientId);
		|
		|            // Отменить регистрацию на событие отключения (на самом деле не требуется).
		|            client.Client.Disconnected -= Client_Disconnected;
		|        }
		|
		|        // Этот класс используется для хранения информации для подключенного клиента.
		|        public sealed class MyClient
		|        {
		|            // Ссылка на клиента Scs.
		|            public IScsServiceClient Client { get; private set; }
		|
		|            // Прокси-объект для вызова удаленных методов клиента приложения.
		|            public IMyClient ClientProxy { get; private set; }
		|
		|            // Уникальный идентификатор клиента приложения.
		|            public string Guid { get; private set; }
		|
		|            // Имя клиента приложения.
		|            public string ClientName { get; private set; }
		|
		|            // Дополнительные данные.
		|            public oscs.Collection Tag { get; private set; }
		|
		|            // Создает новый объект MyClient.
		|            public MyClient(IScsServiceClient client, IMyClient clientProxy, string guid, string clientName, oscs.Collection tag)
		|            {
		|                Client = client;
		|                ClientProxy = clientProxy;
		|                Guid = guid;
		|                ClientName = clientName;
		|                Tag = tag;
		|            }
		|        }
		|    }
		|


		|}
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "IMyService" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace oscs
		|{
		|    [ScsService(Version = ""1.0.0.0"")]
		|    public interface IMyService
		|    {
		|        dynamic DoAtServerWithResalt(string methodName, ArrayList parametersArray = null);
		|        dynamic DoAtClientWithResalt(string senderClientGuid, string clientGuid, string methodName, ArrayList parametersArray = null);
		|
		|        void AtClientEntrance(string guid, string clientName, oscs.Collection Tag);
		|        ClientInfo[] GetClientsList();
		|        string ToString();
		|    }
		|}
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "DoAtServerArgs" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace oscs
		|{
		|    public class DoAtServerArgs : oscs.EventArgs
		|    {
		|        public new CsDoAtServerArgs dll_obj;
		|        private string methodName;
		|        private ArrayImpl parametersArray;
		|
		|        public DoAtServerArgs(string p1, ArrayImpl p2)
		|        {
		|            methodName = p1;
		|            parametersArray = p2;
		|        }
		|
		|        public string MethodName
		|        {
		|            get { return methodName; }
		|            set { methodName = value; }
		|        }
		|		
		|        public ArrayImpl ParametersArray
		|        {
		|            get { return parametersArray; }
		|            set { parametersArray = value; }
		|        }
		|    }//endClass
		|}//endnamespace
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "ServiceClientEventArgs" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace Hik.Communication.ScsServices.Service
		|{
		|    // Хранит информацию о клиенте сервиса, которая будет использоваться событием.
		|    public class ServiceClientEventArgs : System.EventArgs
		|    {
		|        // Клиент, связанный с этим событием.
		|        public IScsServiceClient Client { get; private set; }
		|
		|        // Создает новый объект ServiceClientEventArgs.
		|        // ""client"" - Клиент, связанный с этим событием.
		|        public ServiceClientEventArgs(IScsServiceClient client)
		|        {
		|            Client = client;
		|        }
		|    }
		|}
		|
		|namespace oscs
		|{
		|    public class ServiceClientEventArgs : oscs.EventArgs
		|    {
		|        public new CsServiceClientEventArgs dll_obj;
		|        private IScsServiceClient client;
		|        public CsServiceApplicationClient ServiceApplicationClient { get; set; }
		|
		|        public ServiceClientEventArgs(IScsServiceClient p1)
		|        {
		|            client = p1;
		|        }
		|
		|        public ServiceClientEventArgs(Hik.Communication.ScsServices.Service.ServiceClientEventArgs args)
		|        {
		|            client = args.Client;
		|        }
		|		
		|        public decimal ClientId
		|        {
		|            get { return Convert.ToDecimal(client.ClientId); }
		|        }
		|
		|        public int CommunicationState
		|        {
		|            get { return (int)client.CommunicationState; }
		|        }
		|		
		|        public CsServiceApplicationClient Client
		|        {
		|            get { return ServiceApplicationClient; }
		|        }
		|    }//endClass
		|}//endnamespace
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "ServiceClient" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace Hik.Communication.ScsServices.Service
		|{
		|    // Реализует IScsServiceClient.
		|    // Он используется для управления клиентом сервиса и мониторинга за ним.
		|    internal class ScsServiceClient : IScsServiceClient
		|    {
		|        public oscs.CsServiceApplicationClient dll_obj { get; set; }
		|        // Гуид для этого клиента. Он будет установлен при получении сервером сообщения от клиента в момент подключения.
		|        public string ClientGuid { get; set; }
		|
		|        // Это событие возникает при отключении клиента от сервера.
		|        public event EventHandler Disconnected;
		|
		|        // Уникальный идентификатор для этого клиента.
		|        public long ClientId
		|        {
		|            get { return _serverClient.ClientId; }
		|        }
		|
		|        // Получает конечную точку удаленного приложения.
		|        public ScsEndPoint RemoteEndPoint
		|        {
		|            get { return _serverClient.RemoteEndPoint; }
		|        }
		|
		|        // Получает состояние связи Клиента.
		|        public CommunicationStates CommunicationState
		|        {
		|            get { return _serverClient.CommunicationState; }
		|        }
		|
		|        // Ссылка на базовый объект IScsServerClient.
		|        private readonly IScsServerClient _serverClient;
		|
		|        // Этот объект используется для отправки сообщений клиенту.
		|        private readonly RequestReplyMessenger<IScsServerClient> _requestReplyMessenger;
		|
		|        // Последний созданный прокси-объект для вызова удаленных методов.
		|        private RealProxy _realProxy;
		|
		|        // Создает новый объект ScsServiceClient.
		|        // ""serverClient"" - Ссылка на базовый объект IScsServerClient.
		|        // ""requestReplyMessenger"" - RequestReplyMessenger для отправки сообщений.
		|        public ScsServiceClient(IScsServerClient serverClient, RequestReplyMessenger<IScsServerClient> requestReplyMessenger)
		|        {
		|            _serverClient = serverClient;
		|            _serverClient.Disconnected += Client_Disconnected;
		|            _requestReplyMessenger = requestReplyMessenger;
		|        }
		|
		|        // Закрывает клиентское соединение.
		|        public void Disconnect()
		|        {
		|            _serverClient.Disconnect();
		|        }
		|
		|        // Получает клиентский прокси-интерфейс, который обеспечивает удаленный вызов клиентских методов.
		|        public T GetClientProxy<T>() where T : class
		|        {
		|            _realProxy = new RemoteInvokeProxy<T, IScsServerClient>(_requestReplyMessenger);
		|            return (T)_realProxy.GetTransparentProxy();
		|        }
		|
		|        // Обрабатывает событие отключения объекта _serverClient.
		|        private void Client_Disconnected(object sender, EventArgs e)
		|        {
		|            _requestReplyMessenger.Stop();
		|            OnDisconnected();
		|        }
		|
		|        // Вызывает событие отключения.
		|        private void OnDisconnected()
		|        {
		|            var handler = Disconnected;
		|            if (handler != null)
		|            {
		|                handler(this, EventArgs.Empty);
		|            }
		|        }
		|    }
		|}
		|		
		|namespace oscs
		|{
		|    public class ServiceClient
		|    {
		|        public CsServiceClient dll_obj;
		|        private IScsServiceClient<IMyService> M_ServiceClient;
		|        public IMyService _proxy;
		|        private string guid = null;
		|        private string clientName;
		|        private oscs.Collection tag = new Collection();
		|
		|        // Объект, который обрабатывает вызовы удаленных методов с сервера.
		|        // Он реализует контракт IMyClient.
		|        private MyClient _myClient;
		|
		|        public ServiceClient(TcpEndPoint p1)
		|        {
		|            // Создайте MyClient для обработки удаленных вызовов методов сервером.
		|            _myClient = new MyClient();
		|
		|            M_ServiceClient = ScsServiceClientBuilder.CreateClient<IMyService>(p1.M_TcpEndPoint, _myClient);
		|            _proxy = M_ServiceClient.ServiceProxy;
		|            M_ServiceClient.Connected += M_ServiceClient_Connected;
		|            M_ServiceClient.Disconnected += M_ServiceClient_Disconnected;
		|            Connected = """";
		|            Disconnected = """";
		|            Guid = System.Guid.NewGuid().ToString();
		|        }
		|
		|        public string Guid
		|        {
		|            get { return guid; }
		|            set
		|            {
		|                if (guid == null)
		|                {
		|                    guid = value;
		|                }
		|            }
		|        }
		|
		|        private void M_ServiceClient_Connected(object sender, System.EventArgs e)
		|        {
		|            try
		|            {
		|                // Передадим данные этого клиента клиенту на стороне сервера приложений.
		|                M_ServiceClient.ServiceProxy.AtClientEntrance(this.Guid, this.ClientName, this.Tag);
		|            }
		|            catch
		|            {
		|                Disconnect();
		|                Console.Write(""Не удается войти на сервер. Пожалуйста, попробуйте еще раз позже."");
		|            }
		|
		|            if (dll_obj.Connected != null)
		|            {
		|                IValue Action1 = dll_obj.Connected;
		|                if (Action1 != null)
		|                {
		|                    if (Action1.GetType() == typeof(CsAction))
		|                    {
		|                        ReflectorContext reflector = new ReflectorContext();
		|                        try
		|                        {
		|                            reflector.CallMethod(((CsAction)Action1).Script, ((CsAction)Action1).MethodName, null);
		|                        }
		|                        catch { }
		|                    }
		|                    else
		|                    {
		|                        try
		|                        {
		|                            ((DelegateAction)Action1).CallAsProcedure(0, null);
		|                        }
		|                        catch { }
		|                    }
		|                }
		|            }
		|        }
		|
		|        private void M_ServiceClient_Disconnected(object sender, System.EventArgs e)
		|        {
		|            IValue Action1 = dll_obj.Disconnected;
		|            if (Action1 != null)
		|            {
		|                if (Action1.GetType() == typeof(CsAction))
		|                {
		|                    ReflectorContext reflector = new ReflectorContext();
		|                    try
		|                    {
		|                        reflector.CallMethod(((CsAction)Action1).Script, ((CsAction)Action1).MethodName, null);
		|                    }
		|                    catch { }
		|                }
		|                else
		|                {
		|                    try
		|                    {
		|                        ((DelegateAction)Action1).CallAsProcedure(0, null);
		|                    }
		|                    catch { }
		|                }
		|            }
		|        }
		|
		|        public string Connected { get; set; }
		|
		|        public string Disconnected { get; set; }
		|
		|        public int CommunicationState
		|        {
		|            get { return (int)M_ServiceClient.CommunicationState; }
		|        }
		|
		|        public void Disconnect()
		|        {
		|            M_ServiceClient.Disconnect();
		|        }
		|
		|        public void Connect()
		|        {
		|            M_ServiceClient.Connect();
		|        }
		|
		|        public IMyService Proxy
		|        {
		|            get { return _proxy; }
		|        }
		|		
		|        public string ClientName
		|        {
		|            get { return clientName; }
		|            set { clientName = value; }
		|        }
		|		
		|        public oscs.Collection Tag
		|        {
		|            get { return tag; }
		|            set { tag = value; }
		|        }
		|    }//endClass
		|}//endnamespace
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "ServiceApplication" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace Hik.Communication.ScsServices.Service
		|{
		|    // Реализует IScsServiceApplication и обеспечивает всю функциональность.
		|    internal class ScsServiceApplication : IScsServiceApplication
		|    {
		|        // Это событие возникает, когда новый клиент подключается к сервису.
		|        public event EventHandler<ServiceClientEventArgs> ClientConnected;
		|
		|        // Это событие возникает, когда клиент отключается от службы.
		|        public event EventHandler<ServiceClientEventArgs> ClientDisconnected;
		|
		|        // Базовый объект IScsServer для приема клиентских подключений и управления ими.
		|        private readonly IScsServer _scsServer;
		|
		|        // Объекты пользовательского сервиса, которые используются для вызова входящих запросов на вызов метода.
		|        // Key: Имя типа интерфейса службы.
		|        // Value: Объект обслуживания.
		|        private readonly ThreadSafeSortedList<string, ServiceObject> _serviceObjects;
		|
		|        // Все подключенные клиенты к сервису.
		|        // Key: Уникальный идентификатор клиента Id.
		|        // Value: Ссылка на клиента.
		|        private readonly ThreadSafeSortedList<long, IScsServiceClient> _serviceClients;
		|
		|        // Создает новый объект ScsServiceApplication.
		|        // ""scsServer"" - Базовый объект IScsServer для приема клиентских подключений и управления ими.
		|        // Исключение - ""ArgumentNullException"" - Выдает исключение ArgumentNullException, если аргумент scsServer равен null
		|        public ScsServiceApplication(IScsServer scsServer)
		|        {
		|            if (scsServer == null)
		|            {
		|                throw new ArgumentNullException(""scsServer"");
		|            }
		|
		|            _scsServer = scsServer;
		|            _scsServer.ClientConnected += ScsServer_ClientConnected;
		|            _scsServer.ClientDisconnected += ScsServer_ClientDisconnected;
		|            _serviceObjects = new ThreadSafeSortedList<string, ServiceObject>();
		|            _serviceClients = new ThreadSafeSortedList<long, IScsServiceClient>();
		|        }
		|		
		|        public ThreadSafeSortedList<long, IScsServiceClient> Clients
		|        {
		|            get { return _serviceClients; }
		|        }
		|
		|        // Запускает сервисное приложение.
		|        public void Start()
		|        {
		|            _scsServer.Start();
		|        }
		|
		|        // Останавливает сервисное приложение.
		|        public void Stop()
		|        {
		|            _scsServer.Stop();
		|        }
		|
		|        // Добавляет объект службы в это приложение-службу.
		|        // Для типа интерфейса службы может быть добавлен только один объект службы.
		|        // ""TServiceInterface"" - Тип сервисного интерфейса
		|        // ""TServiceClass"" - Тип класса обслуживания. Должен быть доставлен из ScsService и должен реализовывать TServiceInterface.
		|        // ""service"" - Экземпляр TServiceClass.
		|        // Исключение - ""ArgumentNullException"" - Выдает исключение ArgumentNullException, если аргумент службы равен null
		|        // Исключение - ""Exception"" - Выдает исключение, если служба уже добавлена ранее
		|        public void AddService<TServiceInterface, TServiceClass>(TServiceClass service)
		|            where TServiceClass : ScsService, TServiceInterface
		|            where TServiceInterface : class
		|        {
		|            if (service == null)
		|            {
		|                throw new ArgumentNullException(""service"");
		|            }
		|
		|            var type = typeof(TServiceInterface);
		|            if (_serviceObjects[type.Name] != null)
		|            {
		|                throw new Exception(""Service '"" + type.Name + ""' is already added before."");
		|            }
		|
		|            _serviceObjects[type.Name] = new ServiceObject(type, service);
		|        }
		|
		|        // Удаляет ранее добавленный объект службы из этого приложения-службы.
		|        // Он удаляет объект в соответствии с типом интерфейса.
		|        // ""TServiceInterface"">Service interface type</typeparam>
		|        // Возврат - True: удален. False: нет объекта обслуживания с этим интерфейсом
		|        public bool RemoveService<TServiceInterface>()
		|            where TServiceInterface : class
		|        {
		|            return _serviceObjects.Remove(typeof(TServiceInterface).Name);
		|        }
		|
		|        // Обрабатывает событие ClientConnected объекта _scsServer.
		|        // ""sender"" - Источник события.
		|        // ""e"" - Аргументы события.
		|        private void ScsServer_ClientConnected(object sender, ServerClientEventArgs e)
		|        {
		|            var requestReplyMessenger = new RequestReplyMessenger<IScsServerClient>(e.Client);
		|            requestReplyMessenger.MessageReceived += Client_MessageReceived;
		|            requestReplyMessenger.Start();
		|
		|            var serviceClient = ScsServiceClientFactory.CreateServiceClient(e.Client, requestReplyMessenger);
		|            _serviceClients[serviceClient.ClientId] = serviceClient;
		|
		|            // Вызывать событие ClientConnected будем не здесь.
		|            // OnClientConnected(serviceClient);
		|        }
		|
		|        // Обрабатывает событие ClientDisconnected объекта _scsServer.
		|        // ""sender"" - Источник события.
		|        // ""e"" - Аргументы события.
		|        private void ScsServer_ClientDisconnected(object sender, ServerClientEventArgs e)
		|        {
		|            var serviceClient = _serviceClients[e.Client.ClientId];
		|            if (serviceClient == null)
		|            {
		|                return;
		|            }
		|
		|            _serviceClients.Remove(e.Client.ClientId);
		|            OnClientDisconnected(serviceClient);
		|        }
		|
		|        // Обрабатывает события MessageReceived всех клиентов, оценивает каждое сообщение, находит соответствующий объект службы и вызывает соответствующий метод.
		|        // ""sender"" - Источник события.
		|        // ""e"" - Аргументы события.
		|        private void Client_MessageReceived(object sender, MessageEventArgs e)
		|        {
		|            // Получить объект RequestReplyMessenger (отправитель события) для получения клиента.
		|            var requestReplyMessenger = (RequestReplyMessenger<IScsServerClient>)sender;
		|
		|            // Отправьте сообщение в ScsRemoteInvokeMessage и проверьте его.
		|            var invokeMessage = e.Message as ScsRemoteInvokeMessage;
		|            if (invokeMessage == null)
		|            {
		|                return;
		|            }
		|
		|            try
		|            {
		|                // Получить объект клиента.
		|                var client = _serviceClients[requestReplyMessenger.Messenger.ClientId];
		|                if (client == null)
		|                {
		|                    requestReplyMessenger.Messenger.Disconnect();
		|                    return;
		|                }
		|
		|                // Получить объект обслуживания.
		|                var serviceObject = _serviceObjects[invokeMessage.ServiceClassName];
		|                if (serviceObject == null)
		|                {
		|                    SendInvokeResponse(requestReplyMessenger, invokeMessage, null, new ScsRemoteException(""There is no service with name '"" + invokeMessage.ServiceClassName + ""'""));
		|                    return;
		|                }
		|
		|                // Метод вызова.
		|                try
		|                {
		|                    object returnValue;
		|                    // Установите для клиента значение service, чтобы пользовательская служба могла получить client
		|                    // в сервисном методе, использующем свойство CurrentClient.
		|                    serviceObject.Service.CurrentClient = client;
		|                    try
		|                    {
		|                        string str1 = """";
		|                        for (int i = 0; i < invokeMessage.Parameters.Length; i++)
		|                        {
		|                            str1 = str1 + invokeMessage.Parameters[i] + System.Environment.NewLine;
		|                        }
		|
		|                        returnValue = serviceObject.InvokeMethod(invokeMessage.MethodName, invokeMessage.Parameters);
		|
		|                        if (invokeMessage.MethodName == ""AtClientEntrance"")
		|                        {
		|                            // А теперь вызовем событие ClientConnected.
		|                            OnClientConnected(client);
		|                        }
		|                    }
		|                    finally
		|                    {
		|                        // Установите CurrentClient равным null с момента завершения вызова метода.
		|                        serviceObject.Service.CurrentClient = null;
		|                    }
		|
		|                    // Отправить вызов метода, возвращающий значение клиенту.
		|                    SendInvokeResponse(requestReplyMessenger, invokeMessage, returnValue, null);
		|                }
		|                catch (TargetInvocationException ex)
		|                {
		|                    var innerEx = ex.InnerException;
		|                    SendInvokeResponse(requestReplyMessenger, invokeMessage, null, new ScsRemoteException(innerEx.Message + Environment.NewLine + ""1Service Version: "" + serviceObject.ServiceAttribute.Version, innerEx));
		|                    return;
		|                }
		|                catch (Exception ex)
		|                {
		|                    SendInvokeResponse(requestReplyMessenger, invokeMessage, null, new ScsRemoteException(ex.Message + Environment.NewLine + ""2Service Version: "" + serviceObject.ServiceAttribute.Version, ex));
		|                    return;
		|                }
		|            }
		|            catch (Exception ex)
		|            {
		|                SendInvokeResponse(requestReplyMessenger, invokeMessage, null, new ScsRemoteException(""An error occured during remote service method call."", ex));
		|                return;
		|            }
		|        }
		|
		|        // Отправляет ответ удаленному приложению, которое вызвало метод службы.
		|        // ""client"" - Клиент, отправивший сообщение invoke.
		|        // ""requestMessage"" - Сообщение с запросом.
		|        // ""returnValue"" - Возвращаемое значение для отправки.
		|        // ""exception"" - Исключение для отправки.
		|        private static void SendInvokeResponse(IMessenger client, IScsMessage requestMessage, object returnValue, ScsRemoteException exception)
		|        {
		|            try
		|            {
		|                client.SendMessage(
		|                    new ScsRemoteInvokeReturnMessage
		|                    {
		|                        RepliedMessageId = requestMessage.MessageId,
		|                        ReturnValue = returnValue,
		|                        RemoteException = exception
		|                    });
		|            }
		|            catch { }
		|        }
		|
		|        // Вызывает событие, связанное с клиентом.
		|        private void OnClientConnected(IScsServiceClient client)
		|        {
		|            var handler = ClientConnected;
		|            if (handler != null)
		|            {
		|                handler(this, new ServiceClientEventArgs(client));
		|            }
		|        }
		|
		|        // Вызывает событие ClientDisconnected.
		|        private void OnClientDisconnected(IScsServiceClient client)
		|        {
		|            var handler = ClientDisconnected;
		|            if (handler != null)
		|            {
		|                handler(this, new ServiceClientEventArgs(client));
		|            }
		|        }
		|
		|        // Представляет объект пользовательского сервиса.
		|        // Он используется для вызова методов объекта ScsService.
		|        private sealed class ServiceObject
		|        {
		|            // Объект службы, который используется для вызова методов.
		|            public ScsService Service { get; private set; }
		|
		|            // Атрибут ScsService класса объекта Service.
		|            public ScsServiceAttribute ServiceAttribute { get; private set; }
		|
		|            // В этой коллекции хранится список всех методов объекта service.
		|            // Key: Имя метода
		|            // Value: Информация о методе. 
		|            private readonly SortedList<string, System.Reflection.MethodInfo> _methods;
		|
		|            // Создает новый ServiceObject.
		|            // ""serviceInterfaceType"" - Тип интерфейса сервиса.
		|            // ""service"" - Объект службы, который используется для вызова методов на.
		|            public ServiceObject(Type serviceInterfaceType, ScsService service)
		|            {
		|                Service = service;
		|                var classAttributes = serviceInterfaceType.GetCustomAttributes(typeof(ScsServiceAttribute), true);
		|                if (classAttributes.Length <= 0)
		|                {
		|                    throw new Exception(""Service interface ("" + serviceInterfaceType.Name + "") must has ScsService attribute."");
		|                }
		|
		|                ServiceAttribute = classAttributes[0] as ScsServiceAttribute;
		|                _methods = new SortedList<string, System.Reflection.MethodInfo>();
		|                foreach (var methodInfo in serviceInterfaceType.GetMethods())
		|                {
		|                    _methods.Add(methodInfo.Name, methodInfo);
		|                }
		|            }
		|
		|            // Вызывает метод объекта Service.
		|            // ""methodName"" - Имя метода для вызова.
		|            // ""parameters"" - Параметры метода.
		|            // Возврат - Возвращаемое значение метода.
		|            public object InvokeMethod(string methodName, params object[] parameters)
		|            {
		|                // Проверьте, существует ли метод с именем methodName.
		|                if (!_methods.ContainsKey(methodName))
		|                {
		|                    throw new Exception(""There is not a method with name '"" + methodName + ""' in service class."");
		|                }
		|
		|                // Метод получения.
		|                var method = _methods[methodName];
		|
		|                // Вызвать метод и вернуть результат вызова.
		|                return method.Invoke(Service, parameters);
		|            }
		|        }
		|    }
		|}
		|
		|namespace oscs
		|{
		|    public class ServiceApplication
		|    {
		|        public CsServiceApplication dll_obj;
		|        private IScsServiceApplication M_ServiceApplication;
		|        public string ClientConnected { get; set; }
		|        public string ClientDisconnected { get; set; }
		|        private MyService _proxy;
		|
		|        public ServiceApplication(ScsTcpEndPoint p1)
		|        {
		|            // Создайте приложение-службу, которое работает на TCP-порту.
		|            M_ServiceApplication = ScsServiceBuilder.CreateService(p1);
		|
		|            // Создайте MyService и добавьте его в сервисное приложение.
		|            _proxy = new MyService();
		|            M_ServiceApplication.AddService<IMyService, MyService>(_proxy);
		|
		|            M_ServiceApplication.ClientConnected += M_ServiceApplication_ClientConnected;
		|            M_ServiceApplication.ClientDisconnected += M_ServiceApplication_ClientDisconnected;
		|            ClientConnected = """";
		|            ClientDisconnected = """";
		|        }
		|
		|        private void M_ServiceApplication_ClientDisconnected(object sender, Hik.Communication.ScsServices.Service.ServiceClientEventArgs e)
		|        {
		|            if (dll_obj.ClientDisconnected != null)
		|            {
		|                oscs.ServiceClientEventArgs ServiceClientEventArgs1 = new oscs.ServiceClientEventArgs(e.Client);
		|                ServiceClientEventArgs1.EventAction = dll_obj.ClientDisconnected;
		|                ServiceClientEventArgs1.Sender = this;
		|                ServiceClientEventArgs1.ServiceApplicationClient = e.Client.dll_obj;
		|                CsServiceClientEventArgs CsServiceClientEventArgs1 = new CsServiceClientEventArgs(ServiceClientEventArgs1);
		|                OneScriptClientServer.EventQueue.Enqueue(ServiceClientEventArgs1);
		|            }
		|        }
		|
		|        private void M_ServiceApplication_ClientConnected(object sender, Hik.Communication.ScsServices.Service.ServiceClientEventArgs e)
		|        {
		|            if (dll_obj.ClientConnected != null)
		|            {
		|                oscs.ServiceClientEventArgs ServiceClientEventArgs1 = new oscs.ServiceClientEventArgs(e.Client);
		|                ServiceClientEventArgs1.EventAction = dll_obj.ClientConnected;
		|                ServiceClientEventArgs1.Sender = this;
		|                ServiceClientEventArgs1.ServiceApplicationClient = e.Client.dll_obj;
		|                CsServiceClientEventArgs CsServiceClientEventArgs1 = new CsServiceClientEventArgs(ServiceClientEventArgs1);
		|                OneScriptClientServer.EventQueue.Enqueue(ServiceClientEventArgs1);
		|            }
		|        }
		|
		|        public void Start()
		|        {
		|            M_ServiceApplication.Start();
		|        }
		|
		|        public void Stop()
		|        {
		|            M_ServiceApplication.Stop();
		|        }
		|		
		|        public MyService Proxy
		|        {
		|            get { return _proxy; }
		|        }
		|		
		|        public ArrayImpl Clients
		|        {
		|            get
		|            {
		|                List<IScsServiceClient> list = M_ServiceApplication.Clients.GetAllItems();
		|                ArrayImpl arrayImpl = new ArrayImpl();
		|                for (int i = 0; i < list.Count; i++)
		|                {
		|                    arrayImpl.Add(list[i].dll_obj);
		|                }
		|                return arrayImpl;
		|            }
		|        }
		|    }//endClass
		|}//endnamespace
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "DateTimeMessage" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace oscs
		|{
		|    public class DateTimeMessage
		|    {
		|        public CsDateTimeMessage dll_obj;
		|        public ScsDateTimeMessage M_DateTimeMessage;
		|
		|        public DateTimeMessage()
		|        {
		|            M_DateTimeMessage = new ScsDateTimeMessage();
		|        }
		|
		|        public DateTimeMessage(DateTime p1)
		|        {
		|            M_DateTimeMessage = new ScsDateTimeMessage(p1);
		|        }
		|
		|        public DateTimeMessage(ScsDateTimeMessage p1)
		|        {
		|            M_DateTimeMessage = p1;
		|        }
		|
		|        public ScsDateTimeMessage M_Obj
		|        {
		|            get { return M_DateTimeMessage; }
		|        }
		|
		|        public string MessageId
		|        {
		|            get { return M_DateTimeMessage.MessageId; }
		|        }
		|
		|        public DateTime DateVal
		|        {
		|            get { return M_DateTimeMessage.DateVal; }
		|            set { M_DateTimeMessage.DateVal = value; }
		|        }
		|
		|        public string RepliedMessageId
		|        {
		|            get { return M_DateTimeMessage.RepliedMessageId; }
		|        }
		|    }//endClass
		|}//endnamespace
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "BoolMessage" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace oscs
		|{
		|    public class BoolMessage
		|    {
		|        public CsBoolMessage dll_obj;
		|        public ScsBoolMessage M_BoolMessage;
		|
		|        public BoolMessage()
		|        {
		|            M_BoolMessage = new ScsBoolMessage();
		|        }
		|
		|        public BoolMessage(System.Boolean p1)
		|        {
		|            M_BoolMessage = new ScsBoolMessage(p1);
		|        }
		|
		|        public BoolMessage(ScsBoolMessage p1)
		|        {
		|            M_BoolMessage = p1;
		|        }
		|
		|        public ScsBoolMessage M_Obj
		|        {
		|            get { return M_BoolMessage; }
		|        }
		|
		|        public string MessageId
		|        {
		|            get { return M_BoolMessage.MessageId; }
		|        }
		|
		|        public System.Boolean BoolVal
		|        {
		|            get { return M_BoolMessage.BoolVal; }
		|            set { M_BoolMessage.BoolVal = value; }
		|        }
		|
		|        public string RepliedMessageId
		|        {
		|            get { return M_BoolMessage.RepliedMessageId; }
		|        }
		|    }//endClass
		|}//endnamespace
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "NumberMessage" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace oscs
		|{
		|    public class NumberMessage
		|    {
		|        public CsNumberMessage dll_obj;
		|        public ScsNumberMessage M_NumberMessage;
		|
		|        public NumberMessage(decimal p1)
		|        {
		|            M_NumberMessage = new ScsNumberMessage(p1);
		|        }
		|
		|        public NumberMessage(ScsNumberMessage p1)
		|        {
		|            M_NumberMessage = p1;
		|        }
		|
		|        public NumberMessage()
		|        {
		|            M_NumberMessage = new ScsNumberMessage();
		|        }
		|
		|        public ScsNumberMessage M_Obj
		|        {
		|            get { return M_NumberMessage; }
		|        }
		|
		|        public decimal Number
		|        {
		|            get { return M_NumberMessage.Number; }
		|            set { M_NumberMessage.Number = value; }
		|        }
		|
		|        public string MessageId
		|        {
		|            get { return M_NumberMessage.MessageId; }
		|        }
		|
		|        public string RepliedMessageId
		|        {
		|            get { return M_NumberMessage.RepliedMessageId; }
		|        }
		|    }//endClass
		|}//endnamespace
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "TextMessage" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace oscs
		|{
		|    public class TextMessage
		|    {
		|        public CsTextMessage dll_obj;
		|        public ScsTextMessage M_TextMessage;
		|
		|        public TextMessage(string p1 = null)
		|        {
		|            M_TextMessage = new ScsTextMessage(p1);
		|        }
		|
		|        public TextMessage(ScsTextMessage p1)
		|        {
		|            M_TextMessage = p1;
		|        }
		|
		|        public string Text
		|        {
		|            get { return M_TextMessage.Text; }
		|            set { M_TextMessage.Text = value; }
		|        }
		|
		|        public string MessageId
		|        {
		|            get { return M_TextMessage.MessageId; }
		|        }
		|
		|        public string RepliedMessageId
		|        {
		|            get { return M_TextMessage.RepliedMessageId; }
		|        }
		|		
		|        public ScsTextMessage M_Obj
		|        {
		|            get { return M_TextMessage; }
		|        }
		|    }//endClass
		|}//endnamespace
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "ByteMessage" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace oscs
		|{
		|    public class ByteMessage
		|    {
		|        public CsByteMessage dll_obj;
		|        public ScsRawDataMessage M_ByteMessage;
		|
		|        public ByteMessage(byte[] p1 = null)
		|        {
		|            M_ByteMessage = new ScsRawDataMessage(p1);
		|        }
		|
		|        public ByteMessage(ScsRawDataMessage p1)
		|        {
		|            M_ByteMessage = p1;
		|        }
		|
		|        public ScsRawDataMessage M_Obj
		|        {
		|            get { return M_ByteMessage; }
		|        }
		|
		|        public byte[] MessageData
		|        {
		|            get { return M_ByteMessage.MessageData; }
		|            set { M_ByteMessage.MessageData = value; }
		|        }
		|
		|        public string MessageId
		|        {
		|            get { return M_ByteMessage.MessageId; }
		|        }
		|
		|        public string RepliedMessageId
		|        {
		|            get { return M_ByteMessage.RepliedMessageId; }
		|        }
		|    }//endClass
		|}//endnamespace
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "TcpClient" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace oscs
		|{
		|    public class TcpClient
		|    {
		|        public CsTcpClient dll_obj;
		|        public IScsClient M_TcpClient;
		|        public string Connected { get; set; }
		|        public string Disconnected { get; set; }
		|        public string MessageReceived { get; set; }
		|        public string MessageSent { get; set; }
		|
		|        public TcpClient(TcpEndPoint p1)
		|        {
		|            M_TcpClient = ScsClientFactory.CreateClient(p1.M_TcpEndPoint);
		|            M_TcpClient.Connected += M_TcpClient_Connected;
		|            M_TcpClient.Disconnected += M_TcpClient_Disconnected;
		|            M_TcpClient.MessageSent += M_TcpClient_MessageSent;
		|            M_TcpClient.MessageReceived += M_TcpClient_MessageReceived;
		|            Connected = """";
		|            Disconnected = """";
		|            MessageReceived = """";
		|            MessageSent = """";
		|        }
		|		
		|        private void M_TcpClient_MessageReceived(object sender, Hik.Communication.Scs.Communication.Messages.MessageEventArgs e)
		|        {
		|            if (dll_obj.MessageReceived != null)
		|            {
		|                oscs.MessageEventArgs MessageEventArgs1 = new oscs.MessageEventArgs(e.Message);
		|                MessageEventArgs1.EventAction = dll_obj.MessageReceived;
		|                MessageEventArgs1.Sender = this;
		|                CsMessageEventArgs CsMessageEventArgs1 = new CsMessageEventArgs(MessageEventArgs1);
		|                OneScriptClientServer.EventQueue.Enqueue(MessageEventArgs1);
		|            }
		|        }
		|
		|        private void M_TcpClient_MessageSent(object sender, Hik.Communication.Scs.Communication.Messages.MessageEventArgs e)
		|        {
		|            if (e.Message.GetType() == typeof(ScsPingMessage))
		|            {
		|                return;
		|            }
		|
		|            if (dll_obj.MessageSent != null)
		|            {
		|                oscs.MessageEventArgs MessageEventArgs1 = new oscs.MessageEventArgs(e.Message);
		|                MessageEventArgs1.EventAction = dll_obj.MessageSent;
		|                MessageEventArgs1.Sender = this;
		|                CsMessageEventArgs CsMessageEventArgs1 = new CsMessageEventArgs(MessageEventArgs1);
		|                OneScriptClientServer.EventQueue.Enqueue(MessageEventArgs1);
		|            }
		|        }
		|
		|        private void M_TcpClient_Disconnected(object sender, System.EventArgs e)
		|        {
		|            if (dll_obj.Disconnected != null)
		|            {
		|                oscs.EventArgs EventArgs1 = new oscs.EventArgs();
		|                EventArgs1.EventAction = dll_obj.Disconnected;
		|                EventArgs1.Sender = this;
		|                CsEventArgs CsEventArgs1 = new CsEventArgs(EventArgs1);
		|                OneScriptClientServer.EventQueue.Enqueue(EventArgs1);
		|            }
		|        }
		|
		|        private void M_TcpClient_Connected(object sender, System.EventArgs e)
		|        {
		|            if (dll_obj.Connected != null)
		|            {
		|                oscs.EventArgs EventArgs1 = new oscs.EventArgs();
		|                EventArgs1.EventAction = dll_obj.Connected;
		|                EventArgs1.Sender = this;
		|                CsEventArgs CsEventArgs1 = new CsEventArgs(EventArgs1);
		|                OneScriptClientServer.EventQueue.Enqueue(EventArgs1);
		|            }
		|        }
		|
		|        public void Disconnect()
		|        {
		|            M_TcpClient.Disconnect();
		|        }
		|
		|        public void Connect()
		|        {
		|            M_TcpClient.Connect();
		|        }
		|		
		|        public void SendMessage(IScsMessage p1)
		|        {
		|            M_TcpClient.SendMessage(p1);
		|        }
		|		
		|        public int CommunicationState
		|        {
		|            get { return (int)M_TcpClient.CommunicationState; }
		|        }
		|    }//endClass
		|}//endnamespace
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "TcpEndPoint" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace oscs
		|{
		|    public class TcpEndPoint
		|    {
		|        public string ipAddress;
		|        public int port;
		|        public CsTcpEndPoint dll_obj;
		|        public ScsTcpEndPoint M_TcpEndPoint;
		|
		|        public TcpEndPoint(string p1, int p2)
		|        {
		|            M_TcpEndPoint = new ScsTcpEndPoint(p1, p2);
		|        }
		|
		|        public TcpEndPoint(TcpEndPoint p1)
		|        {
		|            M_TcpEndPoint = p1.M_TcpEndPoint;
		|            ipAddress = p1.ipAddress;
		|            port = p1.port;
		|        }
		|		
		|        public TcpEndPoint(ScsEndPoint p1)
		|        {
		|            ScsTcpEndPoint p2 = (ScsTcpEndPoint)p1;
		|            M_TcpEndPoint = new ScsTcpEndPoint(p2.IpAddress, p2.TcpPort);
		|        }
		|
		|        public string IpAddress
		|        {
		|            get { return M_TcpEndPoint.IpAddress; }
		|            set { M_TcpEndPoint.IpAddress = value; }
		|        }
		|
		|        public int TcpPort
		|        {
		|            get { return M_TcpEndPoint.TcpPort; }
		|        }
		|    }//endClass
		|}//endnamespace
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "ScsSupport" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"#region Server
		|
		|namespace Hik.Communication.Scs.Server
		|{
		|    // Представляет сервер SCS, который используется для приема клиентских подключений и управления ими.
		|    public interface IScsServer
		|    {
		|        // Это событие возникает, когда новый клиент подключается к серверу.
		|        event EventHandler<ServerClientEventArgs> ClientConnected;
		|
		|        // Это событие возникает, когда клиент отключается от сервера.
		|        event EventHandler<ServerClientEventArgs> ClientDisconnected;
		|
		|        // Получает/устанавливает фабрику протоколов wire для создания объектов IWireProtocol.
		|        IScsWireProtocolFactory WireProtocolFactory { get; set; }
		|
		|        // Набор клиентов, подключенных к серверу.
		|        ThreadSafeSortedList<long, IScsServerClient> Clients { get; }
		|
		|        // Запускает сервер.
		|        void Start();
		|
		|        // Останавливает сервер.
		|        void Stop();
		|    }
		|    //=========================================================================================================================================
		|    // Этот класс используется для создания SCS-серверов.
		|    public static class ScsServerFactory
		|    {
		|        // Создает новый SCS-сервер, используя конечную точку.
		|        // ""endPoint"" - Конечная точка, представляющая адрес сервера
		|        // Возврат - Созданный TCP-сервер
		|        public static IScsServer CreateServer(ScsEndPoint endPoint)
		|        {
		|            return endPoint.CreateServer();
		|        }
		|    }
		|    //=========================================================================================================================================
		|    // Предоставляет некоторые функциональные возможности, которые используются серверами.
		|    internal static class ScsServerManager
		|    {
		|        // Используется для установки клиентам автоматического приращения уникального идентификатора.
		|        private static long _lastClientId;
		|
		|        // Получает уникальный номер, который будет использоваться в качестве идентификатора клиента.
		|        public static long GetClientId()
		|        {
		|            return Interlocked.Increment(ref _lastClientId);
		|        }
		|    }
		|    //=========================================================================================================================================
		|    // Этот класс представляет клиента на стороне сервера.
		|    internal class ScsServerClient : IScsServerClient
		|    {
		|        // Это событие возникает при получении нового сообщения.
		|        public event EventHandler<MessageEventArgs> MessageReceived;
		|
		|        // Это событие возникает, когда новое сообщение отправляется без какой-либо ошибки.
		|        // Это не гарантирует, что сообщение будет должным образом обработано удаленным приложением.
		|        public event EventHandler<MessageEventArgs> MessageSent;
		|
		|        // Это событие возникает, когда клиент отключен от сервера.
		|        public event EventHandler Disconnected;
		|
		|        // Уникальный идентификатор для этого клиента на сервере.
		|        public long ClientId { get; set; }
		|
		|        // Получает состояние связи Клиента.
		|        public CommunicationStates CommunicationState
		|        {
		|            get { return _communicationChannel.CommunicationState; }
		|        }
		|
		|        // Получает/устанавливает проводной протокол, который используется при чтении и записи сообщений.
		|        public IScsWireProtocol WireProtocol
		|        {
		|            get { return _communicationChannel.WireProtocol; }
		|            set { _communicationChannel.WireProtocol = value; }
		|        }
		|
		|        // Получает конечную точку удаленного приложения.
		|        public ScsEndPoint RemoteEndPoint
		|        {
		|            get { return _communicationChannel.RemoteEndPoint; }
		|        }
		|
		|        // Получает время последнего успешно полученного сообщения.
		|        public DateTime LastReceivedMessageTime
		|        {
		|            get { return _communicationChannel.LastReceivedMessageTime; }
		|        }
		|
		|        // Получает время последнего успешно отправленного сообщения.
		|        public DateTime LastSentMessageTime
		|        {
		|            get { return _communicationChannel.LastSentMessageTime; }
		|        }
		|
		|        // Канал связи, который используется клиентом для отправки и получения сообщений.
		|        private readonly ICommunicationChannel _communicationChannel;
		|
		|        // Создает новый объект ScsClient.
		|        // ""communicationChannel"" - Канал связи, который используется клиентом для отправки и получения сообщений
		|        public ScsServerClient(ICommunicationChannel communicationChannel)
		|        {
		|            _communicationChannel = communicationChannel;
		|            _communicationChannel.MessageReceived += CommunicationChannel_MessageReceived;
		|            _communicationChannel.MessageSent += CommunicationChannel_MessageSent;
		|            _communicationChannel.Disconnected += CommunicationChannel_Disconnected;
		|        }
		|
		|        // Отключается от клиента и закрывает базовый канал связи.
		|        public void Disconnect()
		|        {
		|            _communicationChannel.Disconnect();
		|        }
		|
		|        // Отправляет сообщение клиенту.
		|        // ""message"" - Сообщение, которое нужно отправить.
		|        public void SendMessage(IScsMessage message)
		|        {
		|            _communicationChannel.SendMessage(message);
		|        }
		|
		|        // Обрабатывает событие отключения объекта _communicationChannel.
		|        // ""sender"" - Источник события.
		|        // ""e"" - Аргументы события.
		|        private void CommunicationChannel_Disconnected(object sender, EventArgs e)
		|        {
		|            OnDisconnected();
		|        }
		|
		|        // Обрабатывает событие MessageReceived объекта _communicationChannel.
		|        // ""sender"" - Источник события.
		|        // ""e"" - Аргументы события.
		|        private void CommunicationChannel_MessageReceived(object sender, MessageEventArgs e)
		|        {
		|            var message = e.Message;
		|            if (message is ScsPingMessage)
		|            {
		|                _communicationChannel.SendMessage(new ScsPingMessage { RepliedMessageId = message.MessageId });
		|                return;
		|            }
		|
		|            OnMessageReceived(message);
		|        }
		|
		|        // Обрабатывает событие отправки сообщений объекта _communicationChannel.
		|        // ""sender"" - Источник события.
		|        // ""e"" - Аргументы события.
		|        private void CommunicationChannel_MessageSent(object sender, MessageEventArgs e)
		|        {
		|            OnMessageSent(e.Message);
		|        }
		|
		|        // Вызывает событие отключения.
		|        private void OnDisconnected()
		|        {
		|            var handler = Disconnected;
		|            if (handler != null)
		|            {
		|                handler(this, EventArgs.Empty);
		|            }
		|        }
		|
		|        // Вызывает событие MessageReceived.
		|        // ""message"" - Полученное сообщение.
		|        private void OnMessageReceived(IScsMessage message)
		|        {
		|            var handler = MessageReceived;
		|            if (handler != null)
		|            {
		|                handler(this, new MessageEventArgs(message));
		|            }
		|        }
		|
		|        // Вызывает событие messageSent.
		|        // ""message"" - Полученное сообщение.
		|        protected virtual void OnMessageSent(IScsMessage message)
		|        {
		|            var handler = MessageSent;
		|            if (handler != null)
		|            {
		|                handler(this, new MessageEventArgs(message));
		|            }
		|        }
		|    }
		|    //=========================================================================================================================================
		|    // Этот класс предоставляет базовую функциональность для серверных классов.
		|    internal abstract class ScsServerBase : IScsServer
		|    {
		|        // Это событие возникает при подключении нового клиента.
		|        public event EventHandler<ServerClientEventArgs> ClientConnected;
		|
		|        // Это событие возникает, когда клиент отключается от сервера.
		|        public event EventHandler<ServerClientEventArgs> ClientDisconnected;
		|
		|        // Получает/устанавливает проводной протокол, который используется при чтении и записи сообщений.
		|        public IScsWireProtocolFactory WireProtocolFactory { get; set; }
		|
		|        // Набор клиентов, подключенных к серверу.
		|        public ThreadSafeSortedList<long, IScsServerClient> Clients { get; private set; }
		|
		|        // Этот объект используется для прослушивания входящих подключений.
		|        private IConnectionListener _connectionListener;
		|
		|        // Конструктор.
		|        protected ScsServerBase()
		|        {
		|            Clients = new ThreadSafeSortedList<long, IScsServerClient>();
		|            WireProtocolFactory = WireProtocolManager.GetDefaultWireProtocolFactory();
		|        }
		|
		|        // Запускает сервер.
		|        public virtual void Start()
		|        {
		|            _connectionListener = CreateConnectionListener();
		|            _connectionListener.CommunicationChannelConnected += ConnectionListener_CommunicationChannelConnected;
		|            _connectionListener.Start();
		|        }
		|
		|        // Останавливает сервер.
		|        public virtual void Stop()
		|        {
		|            if (_connectionListener != null)
		|            {
		|                _connectionListener.Stop();
		|            }
		|
		|            foreach (var client in Clients.GetAllItems())
		|            {
		|                client.Disconnect();
		|            }
		|        }
		|
		|        // Этот метод реализуется производными классами для создания соответствующего прослушивателя соединений для прослушивания входящих запросов на подключение.
		|        protected abstract IConnectionListener CreateConnectionListener();
		|
		|        // Обрабатывает событие CommunicationChannelConnected объекта _connectionListener.
		|        // ""sender"" - Источник события.
		|        // ""e"" - Аргументы события.
		|        private void ConnectionListener_CommunicationChannelConnected(object sender, CommunicationChannelEventArgs e)
		|        {
		|            var client = new ScsServerClient(e.Channel)
		|            {
		|                ClientId = ScsServerManager.GetClientId(),
		|                WireProtocol = WireProtocolFactory.CreateWireProtocol()
		|            };
		|
		|            client.Disconnected += Client_Disconnected;
		|            Clients[client.ClientId] = client;
		|            OnClientConnected(client);
		|            e.Channel.Start();
		|        }
		|
		|        // Обрабатывает события отключенния всех подключенных клиентов.
		|        // ""sender"" - Источник события.
		|        // ""e"" - Аргументы события.
		|        private void Client_Disconnected(object sender, EventArgs e)
		|        {
		|            var client = (IScsServerClient)sender;
		|            Clients.Remove(client.ClientId);
		|            OnClientDisconnected(client);
		|        }
		|
		|        // Вызывает событие, связанное с клиентом.
		|        // ""client"" - Подключенный клиент.
		|        protected virtual void OnClientConnected(IScsServerClient client)
		|        {
		|            var handler = ClientConnected;
		|            if (handler != null)
		|            {
		|                handler(this, new ServerClientEventArgs(client));
		|            }
		|        }
		|
		|        // Вызывает событие ClientDisconnected.
		|        // ""client"" - Отключенный клиент.
		|        protected virtual void OnClientDisconnected(IScsServerClient client)
		|        {
		|            var handler = ClientDisconnected;
		|            if (handler != null)
		|            {
		|                handler(this, new ServerClientEventArgs(client));
		|            }
		|        }
		|    }
		|    //=========================================================================================================================================
		|    // Представляет клиента с точки зрения сервера.
		|    public interface IScsServerClient : IMessenger
		|    {
		|        // Это событие возникает, когда клиент отключается от сервера.
		|        event EventHandler Disconnected;
		|
		|        // Уникальный идентификатор для этого клиента на сервере.
		|        long ClientId { get; }
		|
		|        // Получает конечную точку удаленного приложения.
		|        ScsEndPoint RemoteEndPoint { get; }
		|
		|        // Получает текущее состояние связи.
		|        CommunicationStates CommunicationState { get; }
		|
		|        // Отключается от сервера.
		|        void Disconnect();
		|    }
		|}
		|
		|#endregion Server
		|
		|#region Client
		|
		|namespace Hik.Communication.Scs.Client.Tcp
		|{
		|    // Этот класс используется для связи с сервером по протоколу TCP/IP.
		|    internal class ScsTcpClient : ScsClientBase
		|    {
		|        // Адрес конечной точки сервера.
		|        private readonly ScsTcpEndPoint _serverEndPoint;
		|
		|        // Создает новый объект ScsTcpClient.
		|        // serverEndPoint - Адрес конечной точки для подключения к серверу
		|        public ScsTcpClient(ScsTcpEndPoint serverEndPoint)
		|        {
		|            _serverEndPoint = serverEndPoint;
		|        }
		|
		|        // Создает канал связи, используя ServerIpAddress и ServerPort.
		|        // Возвращает готовый канал связи для общения
		|        protected override ICommunicationChannel CreateCommunicationChannel()
		|        {
		|            EndPoint endpoint = null;
		|
		|            if (IsStringIp(_serverEndPoint.IpAddress))
		|            {
		|                endpoint = new IPEndPoint(IPAddress.Parse(_serverEndPoint.IpAddress), _serverEndPoint.TcpPort);
		|            }
		|            else
		|            {
		|                endpoint = new DnsEndPoint(_serverEndPoint.IpAddress, _serverEndPoint.TcpPort);
		|            }
		|
		|            return new TcpCommunicationChannel(
		|                TcpHelper.ConnectToServer(
		|                    endpoint,
		|                    ConnectTimeout
		|                    ));
		|        }
		|
		|        private bool IsStringIp(string address)
		|        {
		|            IPAddress ipAddress = null;
		|            return IPAddress.TryParse(address, out ipAddress);
		|        }
		|    }
		|    //=========================================================================================================================================
		|    // Этот класс используется для упрощения операций с TCP-сокетами.
		|    internal static class TcpHelper
		|    {
		|        // Этот код используется для подключения к TCP-сокету с опцией тайм-аута.
		|        // ""endPoint"" - IP-конечная точка удаленного сервера.
		|        // ""timeoutMs"" - Тайм-аут для ожидания подключения.
		|        // Возвращает объект сокета, подключенный к серверу
		|        // ""SocketException"" - Выдает исключение SocketException, если не удается подключиться.
		|        // ""TimeoutException"" - Выдает исключение TimeoutException, если не удается подключиться в течение указанного времени ожидания
		|        public static Socket ConnectToServer(EndPoint endPoint, int timeoutMs)
		|        {
		|            var socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
		|            try
		|            {
		|                socket.Blocking = false;
		|                socket.Connect(endPoint);
		|                socket.Blocking = true;
		|                return socket;
		|            }
		|            catch (SocketException socketException)
		|            {
		|                if (socketException.ErrorCode != 10035)
		|                {
		|                    socket.Close();
		|                    throw;
		|                }
		|
		|                if (!socket.Poll(timeoutMs * 1000, SelectMode.SelectWrite))
		|                {
		|                    socket.Close();
		|                    throw new TimeoutException(""The host failed to connect. Timeout occured."");
		|                }
		|
		|                socket.Blocking = true;
		|                return socket;
		|            }
		|        }
		|    }
		|    //=========================================================================================================================================
		|}
		|
		|namespace Hik.Communication.Scs.Client
		|{
		|    // Этот класс используется для автоматического повторного подключения к серверу при отключении.
		|    // Он периодически пытается повторно подключиться к серверу, пока соединение не будет установлено.
		|    public class ClientReConnecter : IDisposable
		|    {
		|        // Период проверки повторного подключения.
		|        // По умолчанию: 20 секунд.
		|        public int ReConnectCheckPeriod
		|        {
		|            get { return _reconnectTimer.Period; }
		|            set { _reconnectTimer.Period = value; }
		|        }
		|
		|        // Ссылка на клиентский объект.
		|        private readonly IConnectableClient _client;
		|
		|        // Таймер для периодической попытки повторного подключения ro.
		|        private readonly Hik.Threading.Timer _reconnectTimer;
		|
		|        // Указывает состояние удаления этого объекта.
		|        private volatile bool _disposed;
		|
		|        // Создает новый объект ClientReConnecter.
		|        // Запускать ClientReConnecter не требуется, поскольку он автоматически запускается при отключении клиента.
		|        // ""client"" - Ссылка на клиентский объект.
		|        // Исключение - ""ArgumentNullException"" - Выдает исключение ArgumentNullException, если значение client равно null.
		|        public ClientReConnecter(IConnectableClient client)
		|        {
		|            if (client == null)
		|            {
		|                throw new ArgumentNullException(""client"");
		|            }
		|
		|            _client = client;
		|            _client.Disconnected += Client_Disconnected;
		|            _reconnectTimer = new Hik.Threading.Timer(20000);
		|            _reconnectTimer.Elapsed += ReconnectTimer_Elapsed;
		|            _reconnectTimer.Start();
		|        }
		|
		|        // Распоряжается этим объектом.
		|        // Ничего не делает, если уже утилизирован.
		|        public void Dispose()
		|        {
		|            if (_disposed)
		|            {
		|                return;
		|            }
		|
		|            _disposed = true;
		|            _client.Disconnected -= Client_Disconnected;
		|            _reconnectTimer.Stop();
		|        }
		|
		|        // Обрабатывает отключенное событие объекта _client.
		|        // ""sender"" - Источник события.
		|        // ""e"" - Аргументы события.
		|        private void Client_Disconnected(object sender, EventArgs e)
		|        {
		|            _reconnectTimer.Start();
		|        }
		|
		|        // Hadles Прошедшее событие _reconnectTimer.
		|        // ""sender"" - Источник события.
		|        // ""e"" - Аргументы события.
		|        private void ReconnectTimer_Elapsed(object sender, EventArgs e)
		|        {
		|            if (_disposed || _client.CommunicationState == CommunicationStates.Connected)
		|            {
		|                _reconnectTimer.Stop();
		|                return;
		|            }
		|
		|            try
		|            {
		|                _client.Connect();
		|                _reconnectTimer.Stop();
		|            }
		|            catch
		|            {
		|                //No need to catch since it will try to re-connect again
		|            }
		|        }
		|    }
		|    //=========================================================================================================================================
		|    // Представляет клиент для серверов SCS.
		|    public interface IConnectableClient : IDisposable
		|    {
		|        // Это событие возникает, когда клиент подключается к серверу.
		|        event EventHandler Connected;
		|
		|        // Это событие возникает, когда клиент отключается от сервера.
		|        event EventHandler Disconnected;
		|
		|        // Тайм-аут для подключения к серверу (в миллисекундах).
		|        // Значение по умолчанию: 15 секунд (15000 мс).
		|        int ConnectTimeout { get; set; }
		|
		|        // Получает текущее состояние связи.
		|        CommunicationStates CommunicationState { get; }
		|
		|        // Подключается к серверу.
		|        void Connect();
		|
		|        // Отключается от сервера.
		|        // Ничего не делает, если уже отключен.
		|        void Disconnect();
		|    }
		|    //=========================================================================================================================================
		|    // Представляет клиента для подключения к серверу.
		|    public interface IScsClient : IMessenger, IConnectableClient
		|    {
		|        // Не определяет никакого дополнительного элемента.
		|    }
		|    //=========================================================================================================================================
		|    // Этот класс предоставляет базовую функциональность для клиентских классов.
		|    internal abstract class ScsClientBase : IScsClient
		|    {
		|        // Это событие возникает при получении нового сообщения.
		|        public event EventHandler<MessageEventArgs> MessageReceived;
		|
		|        // Это событие возникает, когда новое сообщение отправляется без какой-либо ошибки.
		|        // Это не гарантирует, что сообщение будет должным образом обработано удаленным приложением.
		|        public event EventHandler<MessageEventArgs> MessageSent;
		|
		|        // Это событие возникает при подключении.
		|        public event EventHandler Connected;
		|
		|        // Это событие возникает, когда клиент отключается от сервера.
		|        public event EventHandler Disconnected;
		|
		|        // Тайм-аут для подключения к серверу (в миллисекундах).
		|        // Значение по умолчанию: 15 секунд (15000 мс).
		|        public int ConnectTimeout { get; set; }
		|
		|        // Получает/устанавливает проводной протокол, который используется при чтении и записи сообщений.
		|        public IScsWireProtocol WireProtocol
		|        {
		|            get { return _wireProtocol; }
		|            set
		|            {
		|                if (CommunicationState == CommunicationStates.Connected)
		|                {
		|                    throw new ApplicationException(""Wire protocol can not be changed while connected to server."");
		|                }
		|
		|                _wireProtocol = value;
		|            }
		|        }
		|        private IScsWireProtocol _wireProtocol;
		|
		|        // Получает состояние связи Клиента.
		|        public CommunicationStates CommunicationState
		|        {
		|            get
		|            {
		|                return _communicationChannel != null
		|                           ? _communicationChannel.CommunicationState
		|                           : CommunicationStates.Disconnected;
		|            }
		|        }
		|
		|        // Получает время последнего успешно полученного сообщения.
		|        public DateTime LastReceivedMessageTime
		|        {
		|            get
		|            {
		|                return _communicationChannel != null
		|                           ? _communicationChannel.LastReceivedMessageTime
		|                           : DateTime.MinValue;
		|            }
		|        }
		|
		|        // Получает время последнего успешно отправленного сообщения.
		|        public DateTime LastSentMessageTime
		|        {
		|            get
		|            {
		|                return _communicationChannel != null
		|                           ? _communicationChannel.LastSentMessageTime
		|                           : DateTime.MinValue;
		|            }
		|        }
		|
		|        // Значение таймаута по умолчанию для подключения сервера.
		|        private const int DefaultConnectionAttemptTimeout = 15000; //15 seconds.
		|
		|        // Канал связи, который используется клиентом для отправки и получения сообщений.
		|        private ICommunicationChannel _communicationChannel;
		|
		|        // Этот таймер используется для периодической отправки сообщений PingMessage на сервер.
		|        private readonly Hik.Threading.Timer _pingTimer;
		|
		|        // Конструктор
		|        protected ScsClientBase()
		|        {
		|            _pingTimer = new Hik.Threading.Timer(30000);
		|            _pingTimer.Elapsed += PingTimer_Elapsed;
		|            ConnectTimeout = DefaultConnectionAttemptTimeout;
		|            WireProtocol = WireProtocolManager.GetDefaultWireProtocol();
		|        }
		|
		|        // Подключается к серверу.
		|        public void Connect()
		|        {
		|            WireProtocol.Reset();
		|            _communicationChannel = CreateCommunicationChannel();
		|            _communicationChannel.WireProtocol = WireProtocol;
		|            _communicationChannel.Disconnected += CommunicationChannel_Disconnected;
		|            _communicationChannel.MessageReceived += CommunicationChannel_MessageReceived;
		|            _communicationChannel.MessageSent += CommunicationChannel_MessageSent;
		|            _communicationChannel.Start();
		|            _pingTimer.Start();
		|            OnConnected();
		|        }
		|
		|        // Отключается от сервера.
		|        // Ничего не делает, если уже отключен.
		|        public void Disconnect()
		|        {
		|            if (CommunicationState != CommunicationStates.Connected)
		|            {
		|                return;
		|            }
		|
		|            _communicationChannel.Disconnect();
		|        }
		|
		|        // Удаляет этот объект и закрывает базовое соединение.
		|        public void Dispose()
		|        {
		|            Disconnect();
		|        }
		|
		|        // Отправляет сообщение на сервер.
		|        // ""message"" - Сообщение, которое нужно отправить
		|        // Исключение - ""CommunicationStateException"" - Выдает исключение CommunicationStateException, если клиент не подключен к серверу.
		|        public void SendMessage(IScsMessage message)
		|        {
		|            if (CommunicationState != CommunicationStates.Connected)
		|            {
		|                throw new CommunicationStateException(""Client is not connected to the server."");
		|            }
		|
		|            _communicationChannel.SendMessage(message);
		|        }
		|
		|        // Этот метод реализуется производными классами для создания соответствующего канала связи.
		|        // Возврат - Готовый канал связи для общения
		|        protected abstract ICommunicationChannel CreateCommunicationChannel();
		|
		|        // Обрабатывает событие MessageReceived объекта _communicationChannel.
		|        // ""sender"" - Источник события
		|        // ""e"" - Аргументы события
		|        private void CommunicationChannel_MessageReceived(object sender, MessageEventArgs e)
		|        {
		|            if (e.Message is ScsPingMessage)
		|            {
		|                return;
		|            }
		|
		|            OnMessageReceived(e.Message);
		|        }
		|
		|        // Handles MessageSent event of _communicationChannel object.
		|        // Обрабатывает событие отправки сообщений объекта _communicationChannel.
		|        // ""sender"" - Источник события
		|        // ""e"" - Аргументы события
		|        private void CommunicationChannel_MessageSent(object sender, MessageEventArgs e)
		|        {
		|            OnMessageSent(e.Message);
		|        }
		|
		|        // Обрабатывает событие отключения объекта _communicationChannel.
		|        // ""sender"">Source of event
		|        // ""e"" - Аргументы события.
		|        private void CommunicationChannel_Disconnected(object sender, EventArgs e)
		|        {
		|            _pingTimer.Stop();
		|            OnDisconnected();
		|        }
		|
		|        // Обрабатывает прошедшее событие _pingTimer для отправки сообщений PingMessage на сервер.
		|        // ""sender"" - Источник события.
		|        // ""e"" - Аргументы события.
		|        private void PingTimer_Elapsed(object sender, EventArgs e)
		|        {
		|            if (CommunicationState != CommunicationStates.Connected)
		|            {
		|                return;
		|            }
		|
		|            try
		|            {
		|                var lastMinute = DateTime.Now.AddMinutes(-1);
		|                if (_communicationChannel.LastReceivedMessageTime > lastMinute || _communicationChannel.LastSentMessageTime > lastMinute)
		|                {
		|                    return;
		|                }
		|
		|                _communicationChannel.SendMessage(new ScsPingMessage());
		|            }
		|            catch { }
		|        }
		|
		|        // Вызывает событие Connected.
		|        protected virtual void OnConnected()
		|        {
		|            var handler = Connected;
		|            if (handler != null)
		|            {
		|                handler(this, EventArgs.Empty);
		|            }
		|        }
		|
		|        // Вызывает событие Disconnected.
		|        protected virtual void OnDisconnected()
		|        {
		|            var handler = Disconnected;
		|            if (handler != null)
		|            {
		|                handler(this, EventArgs.Empty);
		|            }
		|        }
		|
		|        // Вызывает событие MessageReceived.
		|        // ""message"" - Сообщение.
		|        protected virtual void OnMessageReceived(IScsMessage message)
		|        {
		|            var handler = MessageReceived;
		|            if (handler != null)
		|            {
		|                handler(this, new MessageEventArgs(message));
		|            }
		|        }
		|
		|        // Вызывает событие MessageSent.
		|        // ""message"" - Сообщение.
		|        protected virtual void OnMessageSent(IScsMessage message)
		|        {
		|            var handler = MessageSent;
		|            if (handler != null)
		|            {
		|                handler(this, new MessageEventArgs(message));
		|            }
		|        }
		|    }
		|    //=========================================================================================================================================
		|    // Этот класс используется для создания клиентов SCS для подключения к серверу SCS.
		|    public static class ScsClientFactory
		|    {
		|        // Создает нового клиента для подключения к серверу с использованием конечной точки.
		|        // ""endpoint"" - Конечная точка сервера для его подключения
		|        // Возврат - Созданный TCP-клиент
		|        public static IScsClient CreateClient(ScsEndPoint endpoint)
		|        {
		|            return endpoint.CreateClient();
		|        }
		|
		|        // Создает нового клиента для подключения к серверу с использованием конечной точки.
		|        // ""endpointAddress"" - Адрес конечной точки сервера для его подключения
		|        // Возврат - Созданный TCP-клиент
		|        public static IScsClient CreateClient(string endpointAddress)
		|        {
		|            return CreateClient(ScsEndPoint.CreateEndPoint(endpointAddress));
		|        }
		|    }
		|    //=========================================================================================================================================
		|
		|}
		|
		|#endregion Client
		|
		|#region Communication
		|
		|namespace Hik.Communication.Scs.Communication.Channels.Tcp
		|{
		|    // Этот класс используется для связи с удаленным приложением по протоколу TCP/IP.
		|    internal class TcpCommunicationChannel : CommunicationChannelBase
		|    {
		|        // Получает конечную точку удаленного приложения.
		|        public override ScsEndPoint RemoteEndPoint
		|        {
		|            get
		|            {
		|                return _remoteEndPoint;
		|            }
		|        }
		|        private readonly ScsTcpEndPoint _remoteEndPoint;
		|
		|        // Размер буфера, который используется для приема байтов из TCP сокета.
		|        private const int ReceiveBufferSize = 2 * 4 * 1024; //8KB
		|
		|        // Этот буфер используется для приема байтов 
		|        private readonly byte[] _buffer;
		|
		|        // Объект сокета для отправки/получения сообщений.
		|        private readonly Socket _clientSocket;
		|
		|        // Флаг для управления запуском потока
		|        private volatile bool _running;
		|
		|        // Этот объект просто используется для синхронизации потоков (блокировки).
		|        private readonly object _syncLock;
		|		
		|        // Для определения типа переданных сторонним клиентом данных (строка / файл в виде двоичных данных).
		|        private static string magicSignature = "",89 50 4E 47 0D 0A 1A 0A,52 61 72 21 1A 07 01 00,52 61 72 21 1A 07 00,21 3C 61 72 63 68 3E,7B 5C 72 74 66 31,3C 3F 78 6D 6C 20,25 50 44 46 2D,52 49 46 46,50 4B 03 04,FF D8 FF E0,FF D8 FF E1,00 00 01 00,53 50 30 31,ED AB EE DB,EF BB BF,49 44 33,FF F2,FF F3,FF FB,42 4D,4D 5A,"";
		|
		|        // magicSignature.Add(""4D 5A""); // exe - DOS MZ executable file format and its descendants(including NE and PE).
		|        // magicSignature.Add(""42 4D""); // bmp - BMP file, a bitmap format used mostly in the Windows world.
		|        // magicSignature.Add(""FF FB""); // mp3 - MPEG-1 Layer 3 file without an ID3 tag or with an ID3v1 tag(which’s appended at the end of the file).
		|        // magicSignature.Add(""FF F3""); // mp3.
		|        // magicSignature.Add(""FF F2""); // mp3.
		|        // magicSignature.Add(""49 44 33""); // mp3.
		|        // magicSignature.Add(""EF BB BF""); // UTF-8 encoded Unicode byte order mark, commonly seen in text files.
		|        // magicSignature.Add(""ED AB EE DB""); // rpm - RedHat Package Manager (RPM)package[1].
		|        // magicSignature.Add(""53 50 30 31""); // bin - Amazon Kindle Update Package[2].
		|        // magicSignature.Add(""00 00 01 00""); // ico - Computer icon encoded in ICO file format[3].
		|        // magicSignature.Add(""FF D8 FF E1""); // jpg - JPEG raw or in the JFIF or Exif file format.
		|        // magicSignature.Add(""FF D8 FF E0""); // jpg - JPEG raw or in the JFIF or Exif file format.
		|        // magicSignature.Add(""50 4B 03 04""); // zip - zip file format and formats based on it, such as JAR, ODF, OOXML.
		|        // magicSignature.Add(""52 49 46 46""); // wav - Waveform Audio File Format.
		|        // magicSignature.Add(""52 49 46 46""); // avi - Audio Video Interleave video format.
		|        // magicSignature.Add(""25 50 44 46 2D""); // pdf - PDF document.
		|        // magicSignature.Add(""3C 3F 78 6D 6C 20""); // XML - eXtensible Markup Language when using the ASCII character encoding.
		|        // magicSignature.Add(""7B 5C 72 74 66 31""); // rtf - Rich Text Format.
		|        // magicSignature.Add(""21 3C 61 72 63 68 3E""); // - deb linux deb file.
		|        // magicSignature.Add(""52 61 72 21 1A 07 00""); // rar - RAR archive.
		|        // magicSignature.Add(""52 61 72 21 1A 07 01 00""); // rar - RAR archive.
		|        // magicSignature.Add(""89 50 4E 47 0D 0A 1A 0A""); // png - Image encoded in the Portable Network Graphics format[10].
		|
		|        // Создает новый объект TcpCommunicationChannel.
		|        // ""clientSocket"" - Подключенный объект сокета, который используется для обмена данными по сети.
		|        public TcpCommunicationChannel(Socket clientSocket)
		|        {
		|            _clientSocket = clientSocket;
		|            _clientSocket.NoDelay = true;
		|
		|            var ipEndPoint = (IPEndPoint)_clientSocket.RemoteEndPoint;
		|            _remoteEndPoint = new ScsTcpEndPoint(ipEndPoint.Address.ToString(), ipEndPoint.Port);
		|
		|            _buffer = new byte[ReceiveBufferSize];
		|            _syncLock = new object();
		|        }
		|
		|        // Отключается от удаленного приложения и закрывает канал.
		|        public override void Disconnect()
		|        {
		|            if (CommunicationState != CommunicationStates.Connected)
		|            {
		|                return;
		|            }
		|
		|            _running = false;
		|            try
		|            {
		|                if (_clientSocket.Connected)
		|                {
		|                    _clientSocket.Close();
		|                }
		|
		|                _clientSocket.Dispose();
		|            }
		|            catch { }
		|
		|            CommunicationState = CommunicationStates.Disconnected;
		|            OnDisconnected();
		|        }
		|
		|        // Запускает поток для получения сообщений из сокета.
		|        protected override void StartInternal()
		|        {
		|            _running = true;
		|            _clientSocket.BeginReceive(_buffer, 0, _buffer.Length, 0, new AsyncCallback(ReceiveCallback), null);
		|        }
		|
		|        // Отправляет сообщение удаленному приложению.
		|        // ""message"" - Сообщение, которое нужно отправить.
		|        protected override void SendMessageInternal(IScsMessage message)
		|        {
		|            // Отправить сообщение
		|            var totalSent = 0;
		|            lock (_syncLock)
		|            {
		|                if (oscs.OneScriptClientServer.thirdPartyClientMode != 0)
		|                {
		|                    byte[] sendBytes = new byte[0];
		|                    if (message.GetType() == typeof(ScsRawDataMessage))
		|                    {
		|                        sendBytes = ((ScsRawDataMessage)message).MessageData;
		|                    }
		|                    else if (message.GetType() == typeof(ScsTextMessage))
		|                    {
		|                        sendBytes = Encoding.UTF8.GetBytes(((ScsTextMessage)message).Text);
		|                    }
		|
		|                    // Отправьте все байты в удаленное приложение
		|                    SocketAsyncEventArgs SocketAsyncEventArgs1 = new SocketAsyncEventArgs();
		|                    SocketAsyncEventArgs1.AcceptSocket = _clientSocket;
		|                    SocketAsyncEventArgs1.SetBuffer(sendBytes, 0, sendBytes.Length);
		|                    var sent = _clientSocket.SendAsync(SocketAsyncEventArgs1);
		|
		|                    LastSentMessageTime = DateTime.Now;
		|                    OnMessageSent(message);
		|                }
		|                else
		|                {
		|                    // Создайте массив байтов из сообщения в соответствии с текущим протоколом
		|                    var messageBytes = WireProtocol.GetBytes(message);
		|
		|                    // Отправьте все байты в удаленное приложение
		|                    while (totalSent < messageBytes.Length)
		|                    {
		|                        var sent = _clientSocket.Send(messageBytes, totalSent, messageBytes.Length - totalSent, SocketFlags.None);
		|                        if (sent <= 0)
		|                        {
		|                            throw new CommunicationException(""Message could not be sent via TCP socket. Only "" + totalSent + "" bytes of "" + messageBytes.Length + "" bytes are sent."");
		|                        }
		|
		|                        totalSent += sent;
		|                    }
		|
		|                    LastSentMessageTime = DateTime.Now;
		|                    OnMessageSent(message);
		|                }
		|            }
		|        }
		|		
		|        private byte[] Combine(params byte[][] arrays)
		|        {
		|            byte[] rv = new byte[arrays.Sum(a => a.Length)];
		|            int offset = 0;
		|            foreach (byte[] array in arrays)
		|            {
		|                System.Buffer.BlockCopy(array, 0, rv, offset, array.Length);
		|                offset += array.Length;
		|            }
		|            return rv;
		|        }
		|
		|        bool out1 = false;
		|        byte[] rv = new byte[0];
		|
		|        // Этот метод используется в качестве метода обратного вызова в методе BeginReceive _clientSocket.
		|        // Он извлекает байты из сокета.
		|        // ""ar"" - Асинхронный результат вызова.
		|        private void ReceiveCallback(IAsyncResult ar)
		|        {
		|            if (!_running)
		|            {
		|                return;
		|            }
		|
		|            if (oscs.OneScriptClientServer.thirdPartyClientMode == 2) // Браузер
		|            {
		|                try
		|                {
		|                    System.Threading.Thread.Sleep(5); // без этого данные от разных отправок сторонних клиентов могут оказаться соединенными.
		|                    //Получить количество полученных байтов
		|                    var bytesRead = _clientSocket.EndReceive(ar);
		|
		|                    if (_clientSocket.Available == 0)
		|                    {
		|                        out1 = true;
		|                    }
		|
		|                    if (bytesRead > 0)
		|                    {
		|                        LastReceivedMessageTime = DateTime.Now;
		|
		|                        // Скопируйте полученные байты в новый массив байтов
		|                        var receivedBytes = new byte[bytesRead];
		|                        Array.Copy(_buffer, 0, receivedBytes, 0, bytesRead);
		|
		|                        rv = Combine(rv, receivedBytes); // Накопим данные из потока для одного клиента, если их больше 4096 байт.
		|
		|                        if (out1)
		|                        {
		|                            OnMessageReceived(new ScsTextMessage(Encoding.UTF8.GetString(rv)));
		|
		|                            rv = new byte[0];
		|                            out1 = false;
		|                        }
		|                    }
		|                    else
		|                    {
		|                        throw new CommunicationException(""Tcp socket is closed"");
		|                    }
		|                }
		|                catch
		|                {
		|                    Disconnect();
		|                }
		|            }
		|            else if (oscs.OneScriptClientServer.thirdPartyClientMode == 1) // Нативный
		|            {
		|                try
		|                {
		|                    System.Threading.Thread.Sleep(5); // без этого данные от разных отправок сторонних клиентов могут оказаться соединенными.
		|                    //Получить количество полученных байтов
		|                    var bytesRead = _clientSocket.EndReceive(ar);
		|
		|                    if (_clientSocket.Available == 0)
		|                    {
		|                        out1 = true;
		|                    }
		|
		|                    if (bytesRead > 0)
		|                    {
		|                        LastReceivedMessageTime = DateTime.Now;
		|
		|                        // Скопируйте полученные байты в новый массив байтов
		|                        var receivedBytes = new byte[bytesRead];
		|                        Array.Copy(_buffer, 0, receivedBytes, 0, bytesRead);
		|
		|                        rv = Combine(rv, receivedBytes); // Накопим данные из потока для одного клиента, если их больше 4096 байт.
		|
		|                        if (out1)
		|                        {
		|                            string magicSign = Convert.ToString(rv[0], 16).ToUpper() + "" "" +
		|                                Convert.ToString(rv[1], 16).ToUpper() + "" "" +
		|                                Convert.ToString(rv[2], 16).ToUpper() + "" "" +
		|                                Convert.ToString(rv[3], 16).ToUpper();
		|
		|                            if (magicSignature.Contains("","" + magicSign + "",""))
		|                            {
		|                                OnMessageReceived(new ScsRawDataMessage(rv));
		|                            }
		|                            else
		|                            {
		|                                OnMessageReceived(new ScsTextMessage(Encoding.UTF8.GetString(rv)));
		|                            }
		|
		|                            rv = new byte[0];
		|                            out1 = false;
		|                        }
		|                    }
		|                    else
		|                    {
		|                        throw new CommunicationException(""Tcp socket is closed"");
		|                    }
		|
		|                    // Прочитайте больше байтов, если все еще работаете
		|                    if (_running)
		|                    {
		|                        _clientSocket.BeginReceive(_buffer, 0, _buffer.Length, 0, new AsyncCallback(ReceiveCallback), null);
		|                    }
		|                }
		|                catch
		|                {
		|                    Disconnect();
		|                }
		|            }
		|            else
		|            {
		|                try
		|                {
		|                    // Получить количество полученных байтов
		|                    var bytesRead = _clientSocket.EndReceive(ar);
		|                    if (bytesRead > 0)
		|                    {
		|                        LastReceivedMessageTime = DateTime.Now;
		|
		|                        // Скопируйте полученные байты в новый массив байтов
		|                        var receivedBytes = new byte[bytesRead];
		|                        Array.Copy(_buffer, 0, receivedBytes, 0, bytesRead);
		|
		|                        // Считывать сообщения в соответствии с текущим проводным протоколом
		|                        var messages = WireProtocol.CreateMessages(receivedBytes);
		|
		|                        // Вызвать событие MessageReceived для всех полученных сообщений
		|                        foreach (var message in messages)
		|                        {
		|                            OnMessageReceived(message);
		|                        }
		|                    }
		|                    else
		|                    {
		|                        throw new CommunicationException(""Tcp socket is closed"");
		|                    }
		|
		|                    // Прочитайте больше байтов, если все еще работаете
		|                    if (_running)
		|                    {
		|                        _clientSocket.BeginReceive(_buffer, 0, _buffer.Length, 0, new AsyncCallback(ReceiveCallback), null);
		|                    }
		|                }
		|                catch
		|                {
		|                    Disconnect();
		|                }
		|            }
		|        }
		|    }
		|    //=========================================================================================================================================
		|    // Этот класс используется для прослушивания и приема входящих запросов на TCP-соединение через TCP-порт.
		|    internal class TcpConnectionListener : ConnectionListenerBase
		|    {
		|        // Адрес конечной точки сервера для прослушивания входящих подключений.
		|        private readonly ScsTcpEndPoint _endPoint;
		|
		|        // Серверный сокет для прослушивания входящих запросов на подключение.
		|        private TcpListener _listenerSocket;
		|
		|        // Поток для прослушивания сокета
		|        private Thread _thread;
		|
		|        // Флаг для управления запуском потока
		|        private volatile bool _running;
		|
		|        // Создает новый TcpConnectionListener для данной конечной точки.
		|        // ""endPoint"" - Адрес конечной точки сервера для прослушивания входящих подключений.
		|        public TcpConnectionListener(ScsTcpEndPoint endPoint)
		|        {
		|            _endPoint = endPoint;
		|        }
		|
		|        // Начинает прослушивать входящие соединения.
		|        public override void Start()
		|        {
		|            StartSocket();
		|            _running = true;
		|            _thread = new Thread(DoListenAsThread);
		|            _thread.Start();
		|        }
		|
		|        // Прекращает прослушивание входящих подключений.
		|        public override void Stop()
		|        {
		|            _running = false;
		|            StopSocket();
		|        }
		|
		|        // Начинает прослушивать сокет.
		|        private void StartSocket()
		|        {
		|            _listenerSocket = new TcpListener(System.Net.IPAddress.Any, _endPoint.TcpPort);
		|            _listenerSocket.Start();
		|        }
		|
		|        // Прекращает прослушивание сокета.
		|        private void StopSocket()
		|        {
		|            try
		|            {
		|                _listenerSocket.Stop();
		|            }
		|            catch { }
		|        }
		|
		|        // Точка входа нити.
		|        // Этот метод используется потоком для прослушивания входящих запросов.
		|        private void DoListenAsThread()
		|        {
		|            while (_running)
		|            {
		|                try
		|                {
		|                    var clientSocket = _listenerSocket.AcceptSocket();
		|                    if (clientSocket.Connected)
		|                    {
		|                        OnCommunicationChannelConnected(new TcpCommunicationChannel(clientSocket));
		|                    }
		|                }
		|                catch
		|                {
		|                    // Отключитесь, подождите некоторое время и подключите снова.
		|                    StopSocket();
		|                    Thread.Sleep(1000);
		|                    if (!_running)
		|                    {
		|                        return;
		|                    }
		|
		|                    try
		|                    {
		|                        StartSocket();
		|                    }
		|                    catch { }
		|                }
		|            }
		|        }
		|    }
		|    //=========================================================================================================================================
		|}
		|
		|namespace Hik.Communication.Scs.Communication.Channels
		|{
		|    // Этот класс обеспечивает базовую функциональность для всех классов каналов связи.
		|    internal abstract class CommunicationChannelBase : ICommunicationChannel
		|    {
		|        // Это событие возникает при получении нового сообщения.
		|        public event EventHandler<MessageEventArgs> MessageReceived;
		|
		|        // Это событие возникает, когда новое сообщение отправляется без какой-либо ошибки.
		|        // Это не гарантирует, что сообщение будет должным образом обработано удаленным приложением.
		|        public event EventHandler<MessageEventArgs> MessageSent;
		|
		|        // Это событие возникает, когда канал связи закрыт.
		|        public event EventHandler Disconnected;
		|
		|        // Получает конечную точку удаленного приложения.
		|        public abstract ScsEndPoint RemoteEndPoint { get; }
		|
		|        // Получает текущее состояние связи.
		|        public CommunicationStates CommunicationState { get; protected set; }
		|
		|        // Получает время последнего успешно полученного сообщения.
		|        public DateTime LastReceivedMessageTime { get; protected set; }
		|
		|        // Получает время последнего успешно отправленного сообщения.
		|        public DateTime LastSentMessageTime { get; protected set; }
		|
		|        // Получает/устанавливает проводной протокол, который использует канал.
		|        // Это свойство должно быть установлено перед первым сообщением.
		|        public IScsWireProtocol WireProtocol { get; set; }
		|
		|        // Конструктор.
		|        protected CommunicationChannelBase()
		|        {
		|            CommunicationState = CommunicationStates.Disconnected;
		|            LastReceivedMessageTime = DateTime.MinValue;
		|            LastSentMessageTime = DateTime.MinValue;
		|        }
		|
		|        // Отключается от удаленного приложения и закрывает этот канал.
		|        public abstract void Disconnect();
		|
		|        // Запускает связь с удаленным приложением.
		|        public void Start()
		|        {
		|            StartInternal();
		|            CommunicationState = CommunicationStates.Connected;
		|        }
		|
		|        // Отправляет сообщение удаленному приложению.
		|        // ""message"" - Сообщение, которое нужно отправить.
		|        // Исключение - ""ArgumentNullException"" - Выдает исключение ArgumentNullException, если сообщение равно null
		|        public void SendMessage(IScsMessage message)
		|        {
		|            if (message == null)
		|            {
		|                throw new ArgumentNullException(""message"");
		|            }
		|
		|            SendMessageInternal(message);
		|        }
		|
		|        // Действительно запускает связь с удаленным приложением.
		|        protected abstract void StartInternal();
		|
		|        // Отправляет сообщение удаленному приложению.
		|        // Этот метод переопределяется производными классами для реальной отправки в message.
		|        // ""message"" - Сообщение, которое нужно отправить.
		|        protected abstract void SendMessageInternal(IScsMessage message);
		|
		|        // Вызывает событие отключения.
		|        protected virtual void OnDisconnected()
		|        {
		|            var handler = Disconnected;
		|            if (handler != null)
		|            {
		|                handler(this, EventArgs.Empty);
		|            }
		|        }
		|
		|        // Вызывает событие MessageReceived.
		|        // ""message"" - Полученное сообщение.
		|        protected virtual void OnMessageReceived(IScsMessage message)
		|        {
		|            var handler = MessageReceived;
		|            if (handler != null)
		|            {
		|                handler(this, new MessageEventArgs(message));
		|            }
		|        }
		|
		|        // Вызывает событие messageSent.
		|        // ""message"" - Полученное сообщение.
		|        protected virtual void OnMessageSent(IScsMessage message)
		|        {
		|            var handler = MessageSent;
		|            if (handler != null)
		|            {
		|                handler(this, new MessageEventArgs(message));
		|            }
		|        }
		|    }
		|    //=========================================================================================================================================
		|    // Хранит информацию о канале связи, который будет использоваться событием.
		|    internal class CommunicationChannelEventArgs : EventArgs
		|    {
		|        // Канал связи, связанный с этим событием.
		|        public ICommunicationChannel Channel { get; private set; }
		|
		|        // Создает новый объект CommunicationChannelEventArgs.
		|        // ""channel"" - Канал связи, связанный с этим событием.
		|        public CommunicationChannelEventArgs(ICommunicationChannel channel)
		|        {
		|            Channel = channel;
		|        }
		|    }
		|    //=========================================================================================================================================
		|    // Этот класс предоставляет базовую функциональность для классов прослушивателей связи.
		|    internal abstract class ConnectionListenerBase : IConnectionListener
		|    {
		|        // Это событие возникает при подключении нового канала связи.
		|        public event EventHandler<CommunicationChannelEventArgs> CommunicationChannelConnected;
		|
		|        // Начинает прослушивать входящие соединения.
		|        public abstract void Start();
		|
		|        // Прекращает прослушивание входящих подключений.
		|        public abstract void Stop();
		|
		|        // Вызывает событие CommunicationChannelConnected.
		|        protected virtual void OnCommunicationChannelConnected(ICommunicationChannel client)
		|        {
		|            var handler = CommunicationChannelConnected;
		|            if (handler != null)
		|            {
		|                handler(this, new CommunicationChannelEventArgs(client));
		|            }
		|        }
		|    }
		|    //=========================================================================================================================================
		|    // Представляет собой канал связи.
		|    // Канал связи используется для связи (отправки/получения сообщений) с удаленным приложением.
		|    internal interface ICommunicationChannel : IMessenger
		|    {
		|        // Это событие возникает, когда клиент отключается от сервера.
		|        event EventHandler Disconnected;
		|
		|        // Получает конечную точку удаленного приложения.
		|        ScsEndPoint RemoteEndPoint { get; }
		|
		|        // Получает текущее состояние связи.
		|        CommunicationStates CommunicationState { get; }
		|
		|        // Запускает связь с удаленным приложением.
		|        void Start();
		|
		|        // Закрывает мессенджер.
		|        void Disconnect();
		|    }
		|    //=========================================================================================================================================
		|    // Представляет собой слушателя коммуникации.
		|    // Прослушиватель соединений используется для приема входящих запросов на подключение клиента.
		|    internal interface IConnectionListener
		|    {
		|        // Это событие возникает при подключении нового канала связи.
		|        event EventHandler<CommunicationChannelEventArgs> CommunicationChannelConnected;
		|
		|        // Начинает прослушивать входящие соединения.
		|        void Start();
		|
		|        // Прекращает прослушивание входящих подключений.
		|        void Stop();
		|    }
		|    //=========================================================================================================================================
		|
		|}
		|
		|namespace Hik.Communication.Scs.Communication.EndPoints.Tcp
		|{
		|    // Представляет конечную точку TCP в SCS.
		|    public sealed class ScsTcpEndPoint : ScsEndPoint
		|    {
		|        // Создает новый объект ScsTcpEndPoint с указанным IP-адресом и номером порта.
		|        // ""ipAddress"" - IP-адрес сервера
		|        // ""port"" - Прослушивание TCP-порта для входящих запросов на подключение на сервере
		|        public ScsTcpEndPoint(string ipAddress, int port)
		|        {
		|            IpAddress = ipAddress;
		|            TcpPort = port;
		|        }
		|
		|        // Создает новую точку ScsTcpEndPoint из строкового адреса.
		|        // Формат адреса должен быть похож на IPAddress:Port (например: 127.0.0.1:10085).
		|        // ""address"" - Адрес конечной точки TCP
		|        // Возврат - Созданный объект ScsTcpEndpoint
		|        public ScsTcpEndPoint(string address)
		|        {
		|            var splittedAddress = address.Trim().Split(':');
		|            IpAddress = splittedAddress[0].Trim();
		|            TcpPort = Convert.ToInt32(splittedAddress[1].Trim());
		|        }
		|
		|        // Создает новый объект ScsTcpEndPoint с указанным номером порта.
		|        // ""tcpPort"" - Прослушивание TCP-порта для входящих запросов на подключение на сервере
		|        public ScsTcpEndPoint(int tcpPort)
		|        {
		|            TcpPort = tcpPort;
		|        }
		|
		|        // IP-адрес сервера.
		|        public string IpAddress { get; set; }
		|
		|        // Прослушиваемый TCP-порт для входящих запросов на подключение на сервере.
		|        public int TcpPort { get; private set; }
		|
		|        // Создает сервер Scs, который использует эту конечную точку для прослушивания входящих подключений.
		|        // Возврат - Сервер Scs
		|        internal override IScsServer CreateServer()
		|        {
		|            return new ScsTcpServer(this);
		|        }
		|
		|        // Создает Scs-клиент, который использует эту конечную точку для подключения к серверу.
		|        // Возврат - Клиент Scs
		|        internal override IScsClient CreateClient()
		|        {
		|            return new ScsTcpClient(this);
		|        }
		|
		|        // Генерирует строковое представление этого объекта конечной точки.
		|        // Возврат - Строковое представление этого объекта конечной точки
		|        public override string ToString()
		|        {
		|            return string.IsNullOrEmpty(IpAddress) ? (""tcp://"" + TcpPort) : (""tcp://"" + IpAddress + "":"" + TcpPort);
		|        }
		|    }
		|    //=========================================================================================================================================
		|}
		|
		|namespace Hik.Communication.Scs.Communication.EndPoints
		|{
		|    // Представляет конечную точку на стороне сервера в SCS.
		|    public abstract class ScsEndPoint
		|    {
		|        // Создайте конечную точку Scs из строки.
		|        // Адрес должен быть отформатирован как: protocol://address
		|        // Например: tcp://89.43.104.179:10048 для конечной точки TCP с
		|        // IP 89.43.104.179 и портом 10048.
		|        // ""endPointAddress"" - Адрес для создания конечной точки
		|        // Возврат - Созданная конечная точка
		|        public static ScsEndPoint CreateEndPoint(string endPointAddress)
		|        {
		|            // Проверьте, является ли адрес конечной точки нулевым.
		|            if (string.IsNullOrEmpty(endPointAddress))
		|            {
		|                throw new ArgumentNullException(""endPointAddress"");
		|            }
		|
		|            // Если протокол не указан, предположим, что TCP.
		|            var endPointAddr = endPointAddress;
		|            if (!endPointAddr.Contains(""://""))
		|            {
		|                endPointAddr = ""tcp://"" + endPointAddr;
		|            }
		|
		|            // Разделить части протокола и адреса.
		|            var splittedEndPoint = endPointAddr.Split(new[] { ""://"" }, StringSplitOptions.RemoveEmptyEntries);
		|            if (splittedEndPoint.Length != 2)
		|            {
		|                throw new ApplicationException(endPointAddress + "" is not a valid endpoint address."");
		|            }
		|
		|            // Разделите конечную точку, найдите протокол и адрес.
		|            var protocol = splittedEndPoint[0].Trim().ToLower();
		|            var address = splittedEndPoint[1].Trim();
		|            switch (protocol)
		|            {
		|                case ""tcp"":
		|                    return new ScsTcpEndPoint(address);
		|                default:
		|                    throw new ApplicationException(""Неподдерживаемый протокол "" + protocol + "" в конечной точке "" + endPointAddress);
		|            }
		|        }
		|
		|        // Создает сервер Scs, который использует эту конечную точку для прослушивания входящих подключений.
		|        // Возврат - Scs Сервер
		|        internal abstract IScsServer CreateServer();
		|
		|        // Создает сервер Scs, который использует эту конечную точку для подключения к серверу.
		|        // Возврат - Scs Клиент
		|        internal abstract IScsClient CreateClient();
		|    }
		|    //=========================================================================================================================================
		|}
		|
		|namespace Hik.Communication.Scs.Communication.Messages
		|{
		|    // Представляет сообщение, которое отправляется и принимается сервером и клиентом.
		|    public interface IScsMessage
		|    {
		|        // Уникальный идентификатор для этого сообщения. 
		|        string MessageId { get; }
		|
		|        // Уникальный идентификатор для этого сообщения. 
		|        string RepliedMessageId { get; set; }
		|    }
		|    //=========================================================================================================================================
		|    // Это сообщение используется для отправки/получения сообщений ping.
		|    // Ping-сообщения используются для поддержания соединения между сервером и клиентом.
		|    [Serializable]
		|    public sealed class ScsPingMessage : ScsMessage
		|    {
		|        // Создает новый объект PingMessage.
		|        public ScsPingMessage()
		|        {
		|
		|        }
		|
		|        // Создает новый объект ответа PingMessage.
		|        // ""repliedMessageId"" - Идентификатор ответившего сообщения, если это ответ на сообщение.
		|        public ScsPingMessage(string repliedMessageId) : this()
		|        {
		|            RepliedMessageId = repliedMessageId;
		|        }
		|
		|        // Создает строку, представляющую этот объект.
		|        // Возврат - Строка представляющая этот объект
		|        public override string ToString()
		|        {
		|            return string.IsNullOrEmpty(RepliedMessageId)
		|                       ? string.Format(""ScsPingMessage [{0}]"", MessageId)
		|                       : string.Format(""ScsPingMessage [{0}] Replied To [{1}]"", MessageId, RepliedMessageId);
		|        }
		|    }
		|    //=========================================================================================================================================
		|    // Представляет сообщение, которое отправляется и принимается сервером и клиентом.
		|    // Это базовый класс для всех сообщений.
		|    [Serializable]
		|    public class ScsMessage : IScsMessage
		|    {
		|        // Уникальный идентификатор для этого сообщения.
		|        // Значение по умолчанию: Новый идентификатор GUID.
		|        // Не изменяйте, если вы не хотите вносить низкоуровневые изменения, такие как пользовательские проводные протоколы.
		|        public string MessageId { get; set; }
		|
		|        // Это свойство используется, чтобы указать, что это ответное сообщение на сообщение.
		|        // Это может быть значение null, если это не ответное сообщение.
		|        public string RepliedMessageId { get; set; }
		|
		|        // Создает новое ScsMessage.
		|        public ScsMessage()
		|        {
		|            MessageId = Guid.NewGuid().ToString();
		|        }
		|
		|        // Создает новый ответ ScsMessage.
		|        // ""repliedMessageId"" - Идентификатор ответившего сообщения, если это ответ на сообщение.
		|        public ScsMessage(string repliedMessageId) : this()
		|        {
		|            RepliedMessageId = repliedMessageId;
		|        }
		|
		|        // Создает строку, представляющую этот объект.
		|        // Возврат - Строка представляющая этот объект
		|        public override string ToString()
		|        {
		|            return string.IsNullOrEmpty(RepliedMessageId)
		|                       ? string.Format(""ScsMessage [{0}]"", MessageId)
		|                       : string.Format(""ScsMessage [{0}] Replied To [{1}]"", MessageId, RepliedMessageId);
		|        }
		|    }
		|    //=========================================================================================================================================
		|
		|    // Это сообщение используется для отправки/получения необработанного массива байтов в качестве данных сообщения.
		|    [Serializable]
		|    public class ScsRawDataMessage : ScsMessage
		|    {
		|        // Данные сообщения, которые передаются.
		|        public byte[] MessageData { get; set; }
		|
		|        // Пустой конструктор по умолчанию.
		|        public ScsRawDataMessage()
		|        {
		|        }
		|
		|        // Создает новый объект ScsRawDataMessage со свойством MessageData.
		|        // ""messageData"" - Данные сообщения, которые передаются.
		|        public ScsRawDataMessage(byte[] messageData)
		|        {
		|            MessageData = messageData;
		|        }
		|
		|        // Создает новый объект копию ScsRawDataMessage со свойством MessageData.
		|        // ""messageData"" - Данные сообщения, которые передаются.
		|        // ""repliedMessageId"" - Идентификатор ответившего сообщения, если это ответ на сообщение.
		|        public ScsRawDataMessage(byte[] messageData, string repliedMessageId) : this(messageData)
		|        {
		|            RepliedMessageId = repliedMessageId;
		|        }
		|
		|        // Создает строку, представляющую этот объект.
		|        // Возврат - Строка представляющая этот объект
		|        public override string ToString()
		|        {
		|            var messageLength = MessageData == null ? 0 : MessageData.Length;
		|            return string.IsNullOrEmpty(RepliedMessageId)
		|                       ? string.Format(""ScsRawDataMessage [{0}]: {1} bytes"", MessageId, messageLength)
		|                       : string.Format(""ScsRawDataMessage [{0}] Replied To [{1}]: {2} bytes"", MessageId, RepliedMessageId, messageLength);
		|        }
		|    }
		|    //=========================================================================================================================================
		|
		|    // Это сообщение используется для отправки/получения текста в качестве данных сообщения.
		|    [Serializable]
		|    public class ScsTextMessage : ScsMessage
		|    {
		|        // Текст сообщения, который передается.
		|        public string Text { get; set; }
		|
		|        // Создает новый объект ScsTextMessage.
		|        public ScsTextMessage()
		|        {
		|
		|        }
		|
		|        // Создает новый объект ScsTextMessage со свойством Text.
		|        // ""text"" - Текст сообщения, который передается.
		|        public ScsTextMessage(string text)
		|        {
		|            Text = text;
		|        }
		|
		|        // Создает новый объект ScsTextMessage со свойством Text.
		|        // ""text"" - Текст сообщения, который передается.
		|        // ""repliedMessageId"" - Идентификатор ответившего сообщения, если это ответ на сообщение.
		|        public ScsTextMessage(string text, string repliedMessageId) : this(text)
		|        {
		|            RepliedMessageId = repliedMessageId;
		|        }
		|
		|        // Создает строку, представляющую этот объект.
		|        // Возврат - Строка представляющая этот объект
		|        public override string ToString()
		|        {
		|            return string.IsNullOrEmpty(RepliedMessageId)
		|                       ? string.Format(""ScsTextMessage [{0}]: {1}"", MessageId, Text)
		|                       : string.Format(""ScsTextMessage [{0}] Replied To [{1}]: {2}"", MessageId, RepliedMessageId, Text);
		|        }
		|    }
		|    //=========================================================================================================================================
		|
		|    // Это сообщение используется для отправки/получения числа в качестве данных сообщения.
		|    [Serializable]
		|    public class ScsNumberMessage : ScsMessage
		|    {
		|        // Число сообщения, который передается.
		|        public decimal Number { get; set; }
		|
		|        // Создает новый объект ScsNumberMessage.
		|        public ScsNumberMessage()
		|        {
		|
		|        }
		|
		|        // Создает новый объект ScsNumberMessage со свойством Number.
		|        // ""number"" - Число, которое передается.
		|        public ScsNumberMessage(decimal number)
		|        {
		|            Number = number;
		|        }
		|
		|        // Создает новый объект ScsNumberMessage со свойством Number.
		|        // ""number"" - Число, которое передается.
		|        // ""repliedMessageId"" - Идентификатор ответившего сообщения, если это ответ на сообщение.
		|        public ScsNumberMessage(decimal number, string repliedMessageId) : this(number)
		|        {
		|            RepliedMessageId = repliedMessageId;
		|        }
		|
		|        // Создает строку, представляющую этот объект.
		|        // Возврат - Строка представляющая этот объект
		|        public override string ToString()
		|        {
		|            return string.IsNullOrEmpty(RepliedMessageId)
		|                       ? string.Format(""ScsNumberMessage [{0}]: {1}"", MessageId, Number)
		|                       : string.Format(""ScsNumberMessage [{0}] Replied To [{1}]: {2}"", MessageId, RepliedMessageId, Number);
		|        }
		|    }
		|    //=========================================================================================================================================
		|
		|    // Это сообщение используется для отправки/получения даты в качестве данных сообщения.
		|    [Serializable]
		|    public class ScsDateTimeMessage : ScsMessage
		|    {
		|        // Дата, которая передается.
		|        public DateTime DateVal { get; set; }
		|
		|        // Создает новый объект ScsDateTimeMessage.
		|        public ScsDateTimeMessage()
		|        {
		|
		|        }
		|
		|        // Создает новый объект ScsDateTimeMessage со свойством DateVal.
		|        // ""dateVal"" - Дата, которая передается.
		|        public ScsDateTimeMessage(DateTime dateVal)
		|        {
		|            DateVal = dateVal;
		|        }
		|
		|        // Создает новый объект ScsDateTimeMessage со свойством DateVal.
		|        // ""dateVal"" - Дата, которая передается.
		|        // ""repliedMessageId"" - Идентификатор ответившего сообщения, если это ответ на сообщение.
		|        public ScsDateTimeMessage(DateTime dateVal, string repliedMessageId) : this(dateVal)
		|        {
		|            RepliedMessageId = repliedMessageId;
		|        }
		|
		|        // Создает строку, представляющую этот объект.
		|        // Возврат - Строка представляющая этот объект
		|        public override string ToString()
		|        {
		|            return string.IsNullOrEmpty(RepliedMessageId)
		|                       ? string.Format(""ScsNumberMessage [{0}]: {1}"", MessageId, DateVal)
		|                       : string.Format(""ScsNumberMessage [{0}] Replied To [{1}]: {2}"", MessageId, RepliedMessageId, DateVal);
		|        }
		|    }
		|    //=========================================================================================================================================
		|
		|    // Это сообщение используется для отправки/получения числа в качестве данных сообщения.
		|    [Serializable]
		|    public class ScsBoolMessage : ScsMessage
		|    {
		|        // Булево, которое передается.
		|        public System.Boolean BoolVal { get; set; }
		|
		|        // Создает новый объект ScsBoolMessage.
		|        public ScsBoolMessage()
		|        {
		|
		|        }
		|
		|        // Создает новый объект ScsBoolMessage со свойством BoolVal.
		|        // ""boolVal"" - Булево, которое передается.
		|        public ScsBoolMessage(System.Boolean boolVal)
		|        {
		|            BoolVal = boolVal;
		|        }
		|
		|        // Создает новый объект ScsBoolMessage со свойством BoolVal.
		|        // ""boolVal"" - Булево, которое передается.
		|        // ""repliedMessageId"" - Идентификатор ответившего сообщения, если это ответ на сообщение.
		|        public ScsBoolMessage(System.Boolean boolVal, string repliedMessageId) : this(boolVal)
		|        {
		|            RepliedMessageId = repliedMessageId;
		|        }
		|
		|        // Создает строку, представляющую этот объект.
		|        // Возврат - Строка представляющая этот объект
		|        public override string ToString()
		|        {
		|            return string.IsNullOrEmpty(RepliedMessageId)
		|                       ? string.Format(""ScsNumberMessage [{0}]: {1}"", MessageId, BoolVal)
		|                       : string.Format(""ScsNumberMessage [{0}] Replied To [{1}]: {2}"", MessageId, RepliedMessageId, BoolVal);
		|        }
		|    }
		|    //=========================================================================================================================================
		|}
		|
		|namespace Hik.Communication.Scs.Communication.Messengers
		|{
		|    // Представляет объект, который может отправлять и получать сообщения.
		|    public interface IMessenger
		|    {
		|        // Это событие возникает при получении нового сообщения.
		|        event EventHandler<MessageEventArgs> MessageReceived;
		|
		|        // Это событие возникает, когда новое сообщение отправляется без какой-либо ошибки.
		|        // Это не гарантирует, что сообщение будет должным образом обработано удаленным приложением.
		|        event EventHandler<MessageEventArgs> MessageSent;
		|
		|        // Получает/устанавливает проводной протокол, который используется при чтении и записи сообщений.
		|        IScsWireProtocol WireProtocol { get; set; }
		|
		|        // Получает время последнего успешно полученного сообщения.
		|        DateTime LastReceivedMessageTime { get; }
		|
		|        // Получает время последнего успешно отправленного сообщения.
		|        DateTime LastSentMessageTime { get; }
		|
		|        // Отправляет сообщение удаленному приложению.
		|        // ""message"" - Сообщение, которое нужно отправить.
		|        void SendMessage(IScsMessage message);
		|    }
		|    //=========================================================================================================================================
		|    // Этот класс добавляет методы SendMessageAndWaitForResponse(...) и SendAndReceiveMessage в IMessenger для синхронного обмена сообщениями в стиле запроса/ответа.
		|    // Он также добавляет обработку входящих сообщений в очереди.
		|    // ""T"" - Тип объекта IMessenger для использования в качестве базового сообщения
		|    public class RequestReplyMessenger<T> : IMessenger, IDisposable where T : IMessenger
		|    {
		|        // Это событие возникает при получении нового сообщения от базового мессенджера.
		|        public event EventHandler<MessageEventArgs> MessageReceived;
		|
		|        // Это событие возникает, когда новое сообщение отправляется без какой-либо ошибки.
		|        // Это не гарантирует, что сообщение будет должным образом обработано удаленным приложением.
		|        public event EventHandler<MessageEventArgs> MessageSent;
		|
		|        // Получает/устанавливает проводной протокол, который используется при чтении и записи сообщений.
		|        public IScsWireProtocol WireProtocol
		|        {
		|            get { return Messenger.WireProtocol; }
		|            set { Messenger.WireProtocol = value; }
		|        }
		|
		|        // Получает время последнего успешно полученного сообщения.
		|        public DateTime LastReceivedMessageTime
		|        {
		|            get
		|            {
		|                return Messenger.LastReceivedMessageTime;
		|            }
		|        }
		|
		|        // Получает время последнего успешно отправленного сообщения.
		|        public DateTime LastSentMessageTime
		|        {
		|            get
		|            {
		|                return Messenger.LastSentMessageTime;
		|            }
		|        }
		|
		|        // Получает базовый объект IMessenger.
		|        public T Messenger { get; private set; }
		|
		|        // Значение таймаута в миллисекундах для ожидания получения сообщения с помощью методов SendMessageAndWaitForResponse и SendAndReceiveMessage.
		|        // Значение по умолчанию: 60000 (1 minute).
		|        public int Timeout { get; set; }
		|
		|        // Значение тайм-аута по умолчанию.
		|        private const int DefaultTimeout = 60000;
		|
		|        // Эти сообщения ожидают ответа, которые используются при вызове SendMessageAndWaitForResponse.
		|        // Key: MessageID ожидающего сообщения с запросом.
		|        // Value: Экземпляр WaitingMessage.
		|        private readonly SortedList<string, WaitingMessage> _waitingMessages;
		|
		|        // Этот объект используется для последовательной обработки входящих сообщений.
		|        private readonly SequentialItemProcessor<IScsMessage> _incomingMessageProcessor;
		|
		|        // Этот объект используется для синхронизации потоков.
		|        private readonly object _syncObj = new object();
		|
		|        // Создает новый RequestReplyMessenger.
		|        // ""messenger"" - Объект IMessenger для использования в качестве базового сообщения.
		|        public RequestReplyMessenger(T messenger)
		|        {
		|            Messenger = messenger;
		|            messenger.MessageReceived += Messenger_MessageReceived;
		|            messenger.MessageSent += Messenger_MessageSent;
		|            _incomingMessageProcessor = new SequentialItemProcessor<IScsMessage>(OnMessageReceived);
		|            _waitingMessages = new SortedList<string, WaitingMessage>();
		|            Timeout = DefaultTimeout;
		|        }
		|
		|        // Запускает мессенджер.
		|        public virtual void Start()
		|        {
		|            _incomingMessageProcessor.Start();
		|        }
		|
		|        // Останавливает мессенджер.
		|        // Отменяет все ожидающие потоки в методе SendMessageAndWaitForResponse и останавливает очередь сообщений.
		|        // Метод SendMessageAndWaitForResponse выдает исключение, если существует поток, ожидающий ответного сообщения.
		|        // Также останавливает обработку входящих сообщений и удаляет все сообщения в очереди входящих сообщений.
		|        public virtual void Stop()
		|        {
		|            _incomingMessageProcessor.Stop();
		|
		|            //Импульсные потоки ожидания входящих сообщений, поскольку базовый мессенджер отключен и больше не может получать сообщения.
		|            lock (_syncObj)
		|            {
		|                foreach (var waitingMessage in _waitingMessages.Values)
		|                {
		|                    waitingMessage.State = WaitingMessageStates.Cancelled;
		|                    waitingMessage.WaitEvent.Set();
		|                }
		|
		|                _waitingMessages.Clear();
		|            }
		|        }
		|
		|        // Вызывает метод Stop этого объекта.
		|        public void Dispose()
		|        {
		|            Stop();
		|        }
		|
		|        // Отправляет сообщение.
		|        // ""message"" - Сообщение, которое нужно отправить.
		|        public void SendMessage(IScsMessage message)
		|        {
		|            Messenger.SendMessage(message);
		|        }
		|
		|        // Отправляет сообщение и ожидает ответа на это сообщение.
		|        // Замечание - Ответное сообщение сопоставляется со свойством RepliedMessageId, поэтому, если из удаленного приложения получено какое-либо 
		|        // другое сообщение (которое не является ответом на отправленное сообщение), оно не рассматривается как ответ и не возвращается как 
		|        // возвращаемое значение этого метода.
		|        // Событие MessageReceived не вызывается для ответных сообщений.
		|        // ""message"" - сообщение для отправки.
		|        // Возврат - Ответное сообщение
		|        public IScsMessage SendMessageAndWaitForResponse(IScsMessage message)
		|        {
		|            return SendMessageAndWaitForResponse(message, Timeout);
		|        }
		|
		|        // Отправляет сообщение и ожидает ответа на это сообщение.
		|        // Ответное сообщение сопоставляется со свойством RepliedMessageId, поэтому, если из удаленного приложения получено какое-либо 
		|        // другое сообщение (которое не является ответом на отправленное сообщение), оно не рассматривается как ответ и не возвращается 
		|        // как возвращаемое значение этого метода.
		|        // Событие MessageReceived не вызывается для ответных сообщений.
		|        // ""message"" - сообщение для отправки.
		|        // ""timeoutMilliseconds"" - Продолжительность тайм-аута в миллисекундах.
		|        // Возврат - Ответное сообщение
		|        // Исключение - ""TimeoutException"" - Выдает исключение TimeoutException, если не удается получить ответное сообщение в значении тайм-аута
		|        // Исключение - ""CommunicationException"" - Выдает исключение CommunicationException, если связь завершается неудачей перед ответным сообщением.
		|        public IScsMessage SendMessageAndWaitForResponse(IScsMessage message, int timeoutMilliseconds)
		|        {
		|            //Создайте запись ожидающего сообщения и добавьте в список
		|            var waitingMessage = new WaitingMessage();
		|            lock (_syncObj)
		|            {
		|                _waitingMessages[message.MessageId] = waitingMessage;
		|            }
		|
		|            try
		|            {
		|                //Отправить сообщение
		|                Messenger.SendMessage(message);
		|
		|                //Дождитесь ответа
		|                waitingMessage.WaitEvent.Wait(timeoutMilliseconds);
		|
		|                //Проверьте наличие исключений
		|                switch (waitingMessage.State)
		|                {
		|                    case WaitingMessageStates.WaitingForResponse:
		|                        throw new TimeoutException(""Произошел тайм-аут. Может не получен ответ."");
		|                    case WaitingMessageStates.Cancelled:
		|                        throw new CommunicationException(""Отключен до получения ответа."");
		|                }
		|
		|                //вернуть ответное сообщение
		|                return waitingMessage.ResponseMessage;
		|            }
		|            finally
		|            {
		|                //Удалить сообщение из ожидающих сообщений
		|                lock (_syncObj)
		|                {
		|                    if (_waitingMessages.ContainsKey(message.MessageId))
		|                    {
		|                        _waitingMessages.Remove(message.MessageId);
		|                    }
		|                }
		|            }
		|        }
		|
		|        // Обрабатывает событие MessageReceived объекта Messenger.
		|        // ""sender"" - Источник события.
		|        // ""e"" - Аргументы события.
		|        private void Messenger_MessageReceived(object sender, MessageEventArgs e)
		|        {
		|            //Проверьте, есть ли ожидающий поток для этого сообщения в методе SendMessageAndWaitForResponse
		|            if (!string.IsNullOrEmpty(e.Message.RepliedMessageId))
		|            {
		|                WaitingMessage waitingMessage = null;
		|                lock (_syncObj)
		|                {
		|                    if (_waitingMessages.ContainsKey(e.Message.RepliedMessageId))
		|                    {
		|                        waitingMessage = _waitingMessages[e.Message.RepliedMessageId];
		|                    }
		|                }
		|
		|                //Если есть поток, ожидающий этого ответного сообщения, отправьте его импульсом
		|                if (waitingMessage != null)
		|                {
		|                    waitingMessage.ResponseMessage = e.Message;
		|                    waitingMessage.State = WaitingMessageStates.ResponseReceived;
		|                    waitingMessage.WaitEvent.Set();
		|                    return;
		|                }
		|            }
		|
		|            _incomingMessageProcessor.EnqueueMessage(e.Message);
		|        }
		|
		|        // Обрабатывает событие messageSent объекта Messenger.
		|        // ""sender"" - Источник события.
		|        // ""e"" - Аргументы события.
		|        private void Messenger_MessageSent(object sender, MessageEventArgs e)
		|        {
		|            OnMessageSent(e.Message);
		|        }
		|
		|        // Вызывает событие MessageReceived.
		|        // ""message"" - Полученное сообщение.
		|        protected virtual void OnMessageReceived(IScsMessage message)
		|        {
		|            var handler = MessageReceived;
		|            if (handler != null)
		|            {
		|                handler(this, new MessageEventArgs(message));
		|            }
		|        }
		|
		|        // Вызывает событие messageSent.
		|        // ""message"" - Полученное сообщение.
		|        protected virtual void OnMessageSent(IScsMessage message)
		|        {
		|            var handler = MessageSent;
		|            if (handler != null)
		|            {
		|                handler(this, new MessageEventArgs(message));
		|            }
		|        }
		|
		|        // Этот класс используется для хранения контекста обмена сообщениями для сообщения-запроса до получения ответа.
		|        private sealed class WaitingMessage
		|        {
		|            // Сообщение-ответ на сообщение-запрос (null, если ответ еще не получен).
		|            public IScsMessage ResponseMessage { get; set; }
		|
		|            // ManualResetEvent блокирует поток до тех пор, пока не будет получен ответ.
		|            public ManualResetEventSlim WaitEvent { get; private set; }
		|
		|            // Состояние сообщения с запросом.
		|            public WaitingMessageStates State { get; set; }
		|
		|            // Создает новый объект WaitingMessage.
		|            public WaitingMessage()
		|            {
		|                WaitEvent = new ManualResetEventSlim(false);
		|                State = WaitingMessageStates.WaitingForResponse;
		|            }
		|        }
		|
		|        // Это перечисление используется для хранения состояния ожидающего сообщения.
		|        private enum WaitingMessageStates
		|        {
		|            // Все еще жду ответа.
		|            WaitingForResponse,
		|
		|            // Отправка сообщения отменена.
		|            Cancelled,
		|
		|            // Ответ получен должным образом.
		|            ResponseReceived
		|        }
		|    }
		|    //=========================================================================================================================================
		|
		|    // Этот класс является оболочкой для IMessenger и используется для синхронизации операции получения сообщений.
		|    // Это расширяет RequestReplyMessenger.
		|    // Он подходит для использования в приложениях, которые хотят получать сообщения с помощью синхронизированных вызовов методов вместо асинхронного события MessageReceived.
		|    public class SynchronizedMessenger<T> : RequestReplyMessenger<T> where T : IMessenger
		|    {
		|        // Получает/устанавливает емкость очереди входящих сообщений.
		|        // Никакое сообщение не будет получено от удаленного приложения, если количество сообщений во внутренней очереди превышает это значение.
		|        // Значение по умолчанию: int.MaxValue (2147483647).
		|        public int IncomingMessageQueueCapacity { get; set; }
		|
		|        // Очередь, которая используется для хранения получаемых сообщений до тех пор, пока для их получения не будет вызван метод Receive(...).
		|        private readonly Queue<IScsMessage> _receivingMessageQueue;
		|
		|        // Этот объект используется для синхронизации/ожидания потоков.
		|        private readonly ManualResetEventSlim _receiveWaiter;
		|
		|        // Это логическое значение указывает на состояние выполнения этого класса.
		|        private volatile bool _running;
		|
		|        // Создает новый объект SynchronizedMessenger.
		|        // ""messenger"" - Объект IMessenger, который будет использоваться для отправки /получения сообщений.
		|        public SynchronizedMessenger(T messenger) : this(messenger, int.MaxValue)
		|        {
		|
		|        }
		|
		|        // Создает новый объект SynchronizedMessenger.
		|        // ""messenger"" - Объект IMessenger, который будет использоваться для отправки /получения сообщений.
		|        // ""incomingMessageQueueCapacity"" - емкость очереди входящих сообщений.
		|        public SynchronizedMessenger(T messenger, int incomingMessageQueueCapacity) : base(messenger)
		|        {
		|            _receiveWaiter = new ManualResetEventSlim();
		|            _receivingMessageQueue = new Queue<IScsMessage>();
		|            IncomingMessageQueueCapacity = incomingMessageQueueCapacity;
		|        }
		|
		|        // Запускает мессенджер.
		|        public override void Start()
		|        {
		|            lock (_receivingMessageQueue)
		|            {
		|                _running = true;
		|            }
		|
		|            base.Start();
		|        }
		|
		|        // Останавливает мессенджер.
		|        public override void Stop()
		|        {
		|            base.Stop();
		|
		|            lock (_receivingMessageQueue)
		|            {
		|                _running = false;
		|                _receiveWaiter.Set();
		|            }
		|        }
		|
		|        // Этот метод используется для получения сообщения от удаленного приложения.
		|        // Он ожидает, пока не будет получено сообщение.
		|        // Возврат - Полученное сообщение
		|        public IScsMessage ReceiveMessage()
		|        {
		|            return ReceiveMessage(System.Threading.Timeout.Infinite);
		|        }
		|
		|        // Этот метод используется для получения сообщения от удаленного приложения.
		|        // Он ожидает, пока не будет получено сообщение или не наступит тайм-аут.
		|        // ""timeout"" - Значение тайм-аута для ожидания, если сообщение не получено.
		|        // Используйте -1, чтобы ждать бесконечно.
		|        // Возврат - Полученное сообщение
		|        // Исключение - ""TimeoutException"" - Выдает исключение TimeoutException, если происходит тайм-аут
		|        // Исключение - ""Exception"" - Выдает исключение, если SynchronizedMessenger останавливается до получения сообщения
		|        public IScsMessage ReceiveMessage(int timeout)
		|        {
		|            while (_running)
		|            {
		|                lock (_receivingMessageQueue)
		|                {
		|                    //Проверьте, запущен ли SynchronizedMessenger
		|                    if (!_running)
		|                    {
		|                        throw new Exception(""SynchronizedMessenger is stopped. Can not receive message."");
		|                    }
		|
		|                    //Немедленно получите сообщение, если какое-либо сообщение действительно существует
		|                    if (_receivingMessageQueue.Count > 0)
		|                    {
		|                        return _receivingMessageQueue.Dequeue();
		|                    }
		|
		|                    _receiveWaiter.Reset();
		|                }
		|
		|                //Дождитесь сообщения
		|                var signalled = _receiveWaiter.Wait(timeout);
		|
		|                //Если сигнал не подан, выдайте исключение
		|                if (!signalled)
		|                {
		|                    throw new TimeoutException(""Timeout occured. Can not received any message"");
		|                }
		|            }
		|
		|            throw new Exception(""SynchronizedMessenger is stopped. Can not receive message."");
		|        }
		|
		|        // Этот метод используется для получения определенного типа сообщения от удаленного приложения.
		|        // Он ожидает, пока не будет получено сообщение.
		|        // Возврат - Полученное сообщение
		|        public TMessage ReceiveMessage<TMessage>() where TMessage : IScsMessage
		|        {
		|            return ReceiveMessage<TMessage>(System.Threading.Timeout.Infinite);
		|        }
		|
		|        // Этот метод используется для получения определенного типа сообщения от удаленного приложения.
		|        // Он ожидает, пока не будет получено сообщение или не наступит тайм-аут.
		|        // ""timeout"" - Значение тайм-аута для ожидания, если сообщение не получено.
		|        // Используйте -1, чтобы ждать бесконечно.
		|        // Возврат - Полученное сообщение
		|        public TMessage ReceiveMessage<TMessage>(int timeout) where TMessage : IScsMessage
		|        {
		|            var receivedMessage = ReceiveMessage(timeout);
		|            if (!(receivedMessage is TMessage))
		|            {
		|                throw new Exception(""Unexpected message received."" +
		|                                    "" Expected type: "" + typeof(TMessage).Name +
		|                                    "". Received message type: "" + receivedMessage.GetType().Name);
		|            }
		|
		|            return (TMessage)receivedMessage;
		|        }
		|
		|        // Переопределяет
		|        protected override void OnMessageReceived(IScsMessage message)
		|        {
		|            lock (_receivingMessageQueue)
		|            {
		|                if (_receivingMessageQueue.Count < IncomingMessageQueueCapacity)
		|                {
		|                    _receivingMessageQueue.Enqueue(message);
		|                }
		|
		|                _receiveWaiter.Set();
		|            }
		|        }
		|    }
		|    //=========================================================================================================================================
		|}
		|
		|namespace Hik.Communication.Scs.Communication.Protocols.BinarySerialization
		|{
		|    // Протокол связи по умолчанию между сервером и клиентами для отправки и получения сообщения.
		|    // Он использует двоичную сериализацию .NET для записи и чтения сообщений.
		|    // 
		|    // Формат сообщения:
		|    // [Message Length (4 bytes)][Serialized Message Content]
		|    // 
		|    // Если сообщение сериализуется в массив байтов в виде N байт, этот протокол добавляет информацию о размере 4 байт к 
		|    // заголовку байтов сообщения, так что общая длина составляет (4 + N) байт.
		|    // 
		|    // Этот класс может быть получен для изменения сериализатора (по умолчанию: BinaryFormatter). Для этого методы SerializeMessage и 
		|    // DeserializeMessage должны быть переопределены.
		|    public class BinarySerializationProtocol : IScsWireProtocol
		|    {
		|        // Максимальная длина сообщения.
		|        private const int MaxMessageLength = 128 * 1024 * 1024; //128 Megabytes.
		|
		|        // Этот объект MemoryStream используется для сбора байтов приема для построения сообщений.
		|        private MemoryStream _receiveMemoryStream;
		|
		|        // Создает новый экземпляр BinarySerializationProtocol.
		|        public BinarySerializationProtocol()
		|        {
		|            _receiveMemoryStream = new MemoryStream();
		|        }
		|
		|        // Сериализует сообщение в массив байтов для отправки удаленному приложению.
		|        // Этот метод синхронизирован. Таким образом, только один поток может вызывать его одновременно.
		|        // ""message"" - Сообщение, подлежащее сериализации.
		|        // Исключение - ""CommunicationException"" - Выдает исключение CommunicationException, если сообщение больше максимально допустимой длины сообщения.
		|        public byte[] GetBytes(IScsMessage message)
		|        {
		|            //Сериализуйте сообщение в массив байтов
		|            var serializedMessage = SerializeMessage(message);
		|
		|            //Проверьте длину сообщения
		|            var messageLength = serializedMessage.Length;
		|            if (messageLength > MaxMessageLength)
		|            {
		|                throw new CommunicationException(""Message is too big ("" + messageLength + "" bytes). Max allowed length is "" + MaxMessageLength + "" bytes."");
		|            }
		|
		|            //Создайте массив байтов, включающий длину сообщения (4 байта) и сериализованное содержимое сообщения
		|            var bytes = new byte[messageLength + 4];
		|            WriteInt32(bytes, 0, messageLength);
		|            Array.Copy(serializedMessage, 0, bytes, 4, messageLength);
		|
		|            //Возвращает сериализованное сообщение по этому протоколу
		|            return bytes;
		|        }
		|
		|        // Создает сообщения из массива байтов, полученного из удаленного приложения.
		|        // Массив байтов может содержать только часть сообщения, протокол должен накапливать байты для построения сообщений.
		|        // 
		|        // Этот метод синхронизирован. Таким образом, только один поток может вызывать его одновременно.
		|        // ""receivedBytes"" - Полученные байты от удаленного приложения.
		|        // Возврат - Список сообщений.
		|        // Протокол может генерировать более одного сообщения из массива байтов.
		|        // Кроме того, если полученных байтов недостаточно для построения сообщения, протокол может вернуть пустой список 
		|        // (и сохранить байты для объединения со следующим вызовом метода).
		|        public IEnumerable<IScsMessage> CreateMessages(byte[] receivedBytes)
		|        {
		|            // Запишите все полученные байты в _receiveMemoryStream
		|            _receiveMemoryStream.Write(receivedBytes, 0, receivedBytes.Length);
		|		
		|            // Создайте список для сбора сообщений
		|            var messages = new List<IScsMessage>();
		|		
		|            // Прочитайте все доступные сообщения и добавьте в коллекцию сообщений
		|            while (ReadSingleMessage(messages)) { }
		|		
		|            // Список возвращаемых сообщений
		|            return messages;
		|        }
		|
		|        // Этот метод вызывается при сбросе соединения с удаленным приложением (возобновлении соединения или первом подключении).
		|        // Итак, проводной протокол должен сбросить сам себя.
		|        public void Reset()
		|        {
		|            if (_receiveMemoryStream.Length > 0)
		|            {
		|                _receiveMemoryStream = new MemoryStream();
		|            }
		|        }
		|
		|        // Этот метод используется для сериализации IScsMessage в массив байтов.
		|        // Этот метод может быть переопределен производными классами для изменения стратегии сериализации.
		|        // Это пара с методом DeserializeMessage, и они должны быть переопределены вместе.
		|        // ""message"" - Сообщение, подлежащее сериализации.
		|        // Сериализованные байты сообщения.
		|        // Не включает длину сообщения.
		|        protected virtual byte[] SerializeMessage(IScsMessage message)
		|        {
		|            using (var memoryStream = new MemoryStream())
		|            {
		|                new BinaryFormatter().Serialize(memoryStream, message);
		|                return memoryStream.ToArray();
		|            }
		|        }
		|
		|        // Этот метод используется для десериализации IScsMessage из его байтов.
		|        // Этот метод может быть переопределен производными классами для изменения стратегии десериализации.
		|        // Это пара с методом SerializeMessage, и они должны быть переопределены вместе.
		|        // ""bytes"" - Байты сообщения, подлежащего десериализации (не включает длину сообщения.
		|        // Оно состоит из одного целого сообщения).
		|        // Возврат - Десериализованное сообщение
		|        protected virtual IScsMessage DeserializeMessage(byte[] bytes)
		|        {
		|            //Создайте MemoryStream для преобразования байтов в поток
		|            using (var deserializeMemoryStream = new MemoryStream(bytes))
		|            {
		|                //Идите к началу потока
		|                deserializeMemoryStream.Position = 0;
		|
		|                //Десериализуйте сообщение
		|                var binaryFormatter = new BinaryFormatter
		|                {
		|                    AssemblyFormat = System.Runtime.Serialization.Formatters.FormatterAssemblyStyle.Simple,
		|                    Binder = new DeserializationAppDomainBinder()
		|                };
		|
		|                //Верните десериализованное сообщение
		|                return (IScsMessage)binaryFormatter.Deserialize(deserializeMemoryStream);
		|            }
		|        }
		|
		|        // Этот метод пытается прочитать одно сообщение и добавить его в коллекцию сообщений. 
		|        // ""messages"" - Коллекция сообщений для сбора сообщений.
		|        // Возвращает логическое значение, указывающее на то, что при необходимости необходимо повторно вызвать этот метод.
		|        // Исключение - ""CommunicationException"" - Выдает исключение CommunicationException, если сообщение больше максимально допустимой длины сообщения.
		|        private bool ReadSingleMessage(ICollection<IScsMessage> messages)
		|        {
		|            //Идите к началу потока
		|            _receiveMemoryStream.Position = 0;
		|
		|            //Если поток содержит менее 4 байт, это означает, что мы даже не можем прочитать длину сообщения
		|            //Итак, верните значение false, чтобы дождаться дополнительных байтов от приложения remore.
		|            if (_receiveMemoryStream.Length < 4)
		|            {
		|                return false;
		|            }
		|
		|            //Прочитанная длина сообщения
		|            var messageLength = ReadInt32(_receiveMemoryStream);
		|            if (messageLength > MaxMessageLength)
		|            {
		|                throw new Exception(""Message is too big ("" + messageLength + "" bytes). Max allowed length is "" + MaxMessageLength + "" bytes."");
		|            }
		|
		|            //Если сообщение имеет нулевую длину (этого не должно быть, но хорошо бы проверить)
		|            if (messageLength == 0)
		|            {
		|                //если больше нет байтов, немедленно верните
		|                if (_receiveMemoryStream.Length == 4)
		|                {
		|                    _receiveMemoryStream = new MemoryStream(); // Очистите поток.
		|                    return false;
		|                }
		|
		|                //Создайте новый поток памяти из текущего, за исключением первых 4 байт.
		|                var bytes = _receiveMemoryStream.ToArray();
		|                _receiveMemoryStream = new MemoryStream();
		|                _receiveMemoryStream.Write(bytes, 4, bytes.Length - 4);
		|                return true;
		|            }
		|
		|            //Если все байты сообщения еще не получены, вернитесь, чтобы дождаться дополнительных байтов
		|            if (_receiveMemoryStream.Length < (4 + messageLength))
		|            {
		|                _receiveMemoryStream.Position = _receiveMemoryStream.Length;
		|                return false;
		|            }
		|
		|            //Считайте байты сериализованного сообщения и десериализуйте его
		|            var serializedMessageBytes = ReadByteArray(_receiveMemoryStream, messageLength);
		|            messages.Add(DeserializeMessage(serializedMessageBytes));
		|
		|            //Считывает оставшиеся байты в массив
		|            var remainingBytes = ReadByteArray(_receiveMemoryStream, (int)(_receiveMemoryStream.Length - (4 + messageLength)));
		|
		|            //Повторно создайте поток приемной памяти и запишите оставшиеся байты
		|            _receiveMemoryStream = new MemoryStream();
		|            _receiveMemoryStream.Write(remainingBytes, 0, remainingBytes.Length);
		|
		|            //Верните значение true для повторного вызова этого метода, чтобы попытаться прочитать следующее сообщение
		|            return (remainingBytes.Length > 4);
		|        }
		|
		|        // Записывает значение int в массив байтов из начального индекса.
		|        // ""buffer"" - Массив байтов для записи значения int.
		|        // ""startIndex"" - Начальный индекс массива байтов для записи.
		|        // ""number"" - Целочисленное значение для записи.
		|        private static void WriteInt32(byte[] buffer, int startIndex, int number)
		|        {
		|            buffer[startIndex] = (byte)((number >> 24) & 0xFF);
		|            buffer[startIndex + 1] = (byte)((number >> 16) & 0xFF);
		|            buffer[startIndex + 2] = (byte)((number >> 8) & 0xFF);
		|            buffer[startIndex + 3] = (byte)((number) & 0xFF);
		|        }
		|
		|        // Десериализует и возвращает сериализованное целое число.
		|        // Возврат - Десериализованное целое число
		|        private static int ReadInt32(Stream stream)
		|        {
		|            var buffer = ReadByteArray(stream, 4);
		|            return ((buffer[0] << 24) |
		|                    (buffer[1] << 16) |
		|                    (buffer[2] << 8) |
		|                    (buffer[3])
		|                   );
		|        }
		|
		|        // Считывает массив байтов заданной длины.
		|        // ""stream"" - Поток для чтения из.
		|        // ""length"" - Длина массива байтов для чтения.
		|        // Возврат - Считанный массив байтов
		|        // Исключение - ""EndOfStreamException"" - Выдает исключение EndOfStreamException, если не удается прочитать из потока.
		|        private static byte[] ReadByteArray(Stream stream, int length)
		|        {
		|            var buffer = new byte[length];
		|            var totalRead = 0;
		|            while (totalRead < length)
		|            {
		|                var read = stream.Read(buffer, totalRead, length - totalRead);
		|                if (read <= 0)
		|                {
		|                    throw new EndOfStreamException(""Can not read from stream! Input stream is closed."");
		|                }
		|
		|                totalRead += read;
		|            }
		|
		|            return buffer;
		|        }
		|
		|        // Этот класс используется при десериализации, чтобы разрешить десериализацию объектов, которые определены
		|        // в сборках, которые загружаются во время выполнения (например, плагины).
		|        protected sealed class DeserializationAppDomainBinder : SerializationBinder
		|        {
		|            public override Type BindToType(string assemblyName, string typeName)
		|            {
		|                var toAssemblyName = assemblyName.Split(',')[0];
		|                return (from assembly in AppDomain.CurrentDomain.GetAssemblies()
		|                        where assembly.FullName.Split(',')[0] == toAssemblyName
		|                        select assembly.GetType(typeName)).FirstOrDefault();
		|            }
		|        }
		|    }
		|    //=========================================================================================================================================
		|
		|    // Этот класс используется для создания объектов протокола двоичной сериализации.
		|    public class BinarySerializationProtocolFactory : IScsWireProtocolFactory
		|    {
		|        // Создает новый объект проводного протокола.
		|        // Возврат - Вновь созданный объект проводного протокола
		|        public IScsWireProtocol CreateWireProtocol()
		|        {
		|            return new BinarySerializationProtocol();
		|        }
		|    }
		|    //=========================================================================================================================================
		|
		|}
		|
		|namespace Hik.Communication.Scs.Communication.Protocols
		|{
		|    // Представляет собой протокол связи на байтовом уровне между приложениями.
		|    public interface IScsWireProtocol
		|    {
		|        // Сериализует сообщение в массив байтов для отправки удаленному приложению.
		|        // Этот метод синхронизирован. Таким образом, только один поток может вызывать его одновременно.
		|        // ""message"" - Сообщение, подлежащее сериализации.
		|        byte[] GetBytes(IScsMessage message);
		|
		|        // Создает сообщения из массива байтов, полученного из удаленного приложения.
		|        // Массив байтов может содержать только часть сообщения, протокол должен накапливать байты для построения сообщений.
		|        // Этот метод синхронизирован. Таким образом, только один поток может вызывать его одновременно.
		|        // ""receivedBytes"" - Полученные байты от удаленного приложения.
		|        // Возврат - 
		|        // Список сообщений.
		|        // Протокол может генерировать более одного сообщения из массива байтов.
		|        // Кроме того, если полученных байтов недостаточно для построения сообщения, протокол
		|        // может возвращать пустой список (и сохранять байты для объединения со следующим вызовом метода).
		|        IEnumerable<IScsMessage> CreateMessages(byte[] receivedBytes);
		|
		|        // Этот метод вызывается при сбросе соединения с удаленным приложением (возобновлении соединения или первом подключении).
		|        // Итак, проводной протокол должен сбросить сам себя.
		|        void Reset();
		|    }
		|    //=========================================================================================================================================
		|
		|    // Определяет класс Wire Protocol Factory, который используется для создания объектов Wire Protocol.
		|    public interface IScsWireProtocolFactory
		|    {
		|        // Создает новый объект проводного протокола.
		|        // Возврат - Вновь созданный объект проводного протокола
		|        IScsWireProtocol CreateWireProtocol();
		|    }
		|    //=========================================================================================================================================
		|
		|    // Этот класс используется для получения протоколов по умолчанию.
		|    internal static class WireProtocolManager
		|    {
		|        // Создает заводской объект проводного протокола по умолчанию, который будет использоваться при обмене приложениями.
		|        // Возврат - Новый экземпляр проводного протокола по умолчанию
		|        public static IScsWireProtocolFactory GetDefaultWireProtocolFactory()
		|        {
		|            return new BinarySerializationProtocolFactory();
		|        }
		|
		|        // Создает объект проводного протокола по умолчанию, который будет использоваться при взаимодействии приложений.
		|        // Возврат - Новый экземпляр проводного протокола по умолчанию
		|        public static IScsWireProtocol GetDefaultWireProtocol()
		|        {
		|            return new BinarySerializationProtocol();
		|        }
		|    }
		|    //=========================================================================================================================================
		|}
		|
		|namespace Hik.Communication.Scs.Communication
		|{
		|    // Это приложение выдает ошибку связи.
		|    [Serializable]
		|    public class CommunicationException : Exception
		|    {
		|        // Конструктор.
		|        public CommunicationException()
		|        {
		|        }
		|
		|        // Конструктор для сериализации.
		|        public CommunicationException(SerializationInfo serializationInfo, StreamingContext context) : base(serializationInfo, context)
		|        {
		|        }
		|
		|        // Конструктор.
		|        // ""message"" - Сообщение об исключении.
		|        public CommunicationException(string message) : base(message)
		|        {
		|        }
		|
		|        // Конструктор.
		|        // ""message"" - Сообщение об исключении.
		|        // ""innerException"" - Внутреннее исключение.
		|        public CommunicationException(string message, Exception innerException) : base(message, innerException)
		|        {
		|        }
		|    }
		|    //=========================================================================================================================================
		|
		|    // Это приложение запускается, если связь не является ожидаемым состоянием.
		|    [Serializable]
		|    public class CommunicationStateException : CommunicationException
		|    {
		|        // Конструктор.
		|        public CommunicationStateException()
		|        {
		|        }
		|
		|        // Конструктор для сериализации.
		|        public CommunicationStateException(SerializationInfo serializationInfo, StreamingContext context) : base(serializationInfo, context)
		|        {
		|        }
		|
		|        // Конструктор.
		|        // ""message"" - Сообщение об исключении.
		|        public CommunicationStateException(string message) : base(message)
		|        {
		|        }
		|
		|        // Конструктор.
		|        // ""message"" - Сообщение об исключении.
		|        // ""innerException"" - Внутреннее исключение.
		|        public CommunicationStateException(string message, Exception innerException) : base(message, innerException)
		|        {
		|        }
		|    }
		|    //=========================================================================================================================================
		|
		|    // Состояния соединения.
		|    public enum CommunicationStates
		|    {
		|        // Подключен.
		|        Connected,
		|
		|        // Отключен.
		|        Disconnected
		|    }
		|    //=========================================================================================================================================
		|}
		|
		|#endregion Communication
		|
		|#region ScsServices
		|
		|namespace Hik.Communication.ScsServices.Service
		|{
		|    // Представляет приложение службы SCS, которое используется для создания службы SCS и управления ею.
		|    public interface IScsServiceApplication
		|    {
		|        // Для получения списка клиентов на стороне сервера приложений.
		|        ThreadSafeSortedList<long, IScsServiceClient> Clients { get; }
		|		
		|        // Это событие возникает, когда новый клиент подключается к сервису.
		|        event EventHandler<ServiceClientEventArgs> ClientConnected;
		|
		|        // Это событие возникает, когда клиент отключается от службы.
		|        event EventHandler<ServiceClientEventArgs> ClientDisconnected;
		|
		|        // Запускает сервисное приложение.
		|        void Start();
		|
		|        // Останавливает сервисное приложение.
		|        void Stop();
		|
		|        // Добавляет объект службы в это приложение-службу.
		|        // Для типа интерфейса службы может быть добавлен только один объект службы.
		|        // ""TServiceInterface"" - Тип сервисного интерфейса
		|        // ""TServiceClass"" - Тип класса обслуживания. Должен быть доставлен из ScsService и должен реализовывать TServiceInterface.
		|        // ""service"" - Экземпляр TServiceClass.
		|        void AddService<TServiceInterface, TServiceClass>(TServiceClass service)
		|            where TServiceClass : ScsService, TServiceInterface
		|            where TServiceInterface : class;
		|
		|        // Удаляет ранее добавленный объект службы из этого приложения-службы.
		|        // Он удаляет объект в соответствии с типом интерфейса.
		|        // ""TServiceInterface"" - Тип сервисного интерфейса
		|        // Возврат - True: удалено. False: нет объекта службы с этим интерфейсом
		|        bool RemoveService<TServiceInterface>() where TServiceInterface : class;
		|    }
		|    //=========================================================================================================================================
		|
		|    // Представляет клиента, который использует службу SCS.
		|    public interface IScsServiceClient
		|    {
		|        // Гуид для этого клиента.
		|        string ClientGuid { get; set; }
		|        oscs.CsServiceApplicationClient dll_obj { get; set; }
		|		
		|        // Это событие возникает при отключении клиента от службы.
		|        event EventHandler Disconnected;
		|
		|        // Уникальный идентификатор для этого клиента.
		|        long ClientId { get; }
		|
		|        // Получает конечную точку удаленного приложения.
		|        ScsEndPoint RemoteEndPoint { get; }
		|
		|        // Получает состояние связи Клиента.
		|        CommunicationStates CommunicationState { get; }
		|
		|        // Закрывает клиентское соединение.
		|        void Disconnect();
		|
		|        // Получает клиентский прокси-интерфейс, который обеспечивает удаленный вызов клиентских методов.
		|        // ""T"" - Тип клиентского интерфейса
		|        // Возврат - Клиентский интерфейс
		|        T GetClientProxy<T>() where T : class;
		|    }
		|    //=========================================================================================================================================
		|
		|    // Базовый класс для всех служб, обслуживаемых IScsServiceApplication.
		|    // Класс должен быть производным от ScsService, чтобы служить в качестве службы SCS.
		|    public abstract class ScsService
		|    {
		|        // Текущий клиент для потока, который вызвал метод обслуживания.
		|        [ThreadStatic]
		|        private static IScsServiceClient _currentClient;
		|
		|        // Это свойство является потокобезопасным, если возвращает правильный клиент, когда 
		|        // вызывается в сервисном методе, если метод вызывается системой SCS, иначе выдает исключение.
		|        protected internal IScsServiceClient CurrentClient
		|        {
		|            get
		|            {
		|                if (_currentClient == null)
		|                {
		|                    throw new Exception(""Client channel can not be obtained. CurrentClient property must be called by the thread which runs the service method."");
		|                }
		|
		|                return _currentClient;
		|            }
		|
		|            internal set
		|            {
		|                _currentClient = value;
		|            }
		|        }
		|    }
		|    //=========================================================================================================================================
		|
		|    // Любой класс интерфейса службы SCS должен иметь этот атрибут.
		|    [AttributeUsage(AttributeTargets.Interface | AttributeTargets.Class)]
		|    public class ScsServiceAttribute : Attribute
		|    {
		|        // Служебная версия. Это свойство может быть использовано для указания версии кода.
		|        // Это значение отправляется клиентскому приложению при возникновении исключения, поэтому клиентское приложение может знать, что версия сервиса изменена.
		|        // Значение по умолчанию: NO_VERSION.
		|        public string Version { get; set; }
		|
		|        // Создает новый объект ScsServiceAttribute.
		|        public ScsServiceAttribute()
		|        {
		|            Version = ""NO_VERSION"";
		|        }
		|    }
		|    //=========================================================================================================================================
		|
		|    // Этот класс используется для создания приложений ScsService.
		|    public static class ScsServiceBuilder
		|    {
		|        // Создает новое приложение-службу SCS, используя конечную точку.
		|        // ""endPoint"" - Конечная точка, представляющая адрес службы.
		|        // Возврат - Созданное приложение службы SCS
		|        public static IScsServiceApplication CreateService(ScsEndPoint endPoint)
		|        {
		|            return new ScsServiceApplication(ScsServerFactory.CreateServer(endPoint));
		|        }
		|    }
		|    //=========================================================================================================================================
		|
		|    // Этот класс используется для создания объектов service client, которые используются на стороне сервера.
		|    internal static class ScsServiceClientFactory
		|    {
		|        // Создает новый объект клиента службы, который используется на стороне сервера.
		|        // ""serverClient"" - Базовый серверный клиентский объект.
		|        // ""requestReplyMessenger"" - Объект RequestReplyMessenger для отправки/получения сообщений через ServerClient.
		|        public static IScsServiceClient CreateServiceClient(IScsServerClient serverClient, RequestReplyMessenger<IScsServerClient> requestReplyMessenger)
		|        {
		|            return new ScsServiceClient(serverClient, requestReplyMessenger);
		|        }
		|    }
		|    //=========================================================================================================================================
		|}
		|
		|namespace Hik.Communication.ScsServices.Communication.Messages
		|{
		|    // Представляет удаленное исключение SCS.
		|    // Это исключение используется для отправки исключения из приложения в другое приложение.
		|    [Serializable]
		|    public class ScsRemoteException : Exception
		|    {
		|        // Конструктор.
		|        public ScsRemoteException()
		|        {
		|        }
		|
		|        // Конструктор.
		|        public ScsRemoteException(SerializationInfo serializationInfo, StreamingContext context) : base(serializationInfo, context)
		|        {
		|        }
		|
		|        // Конструктор.
		|        // ""message"" - Сообщение об исключении.
		|        public ScsRemoteException(string message) : base(message)
		|        {
		|        }
		|
		|        // Конструктор.
		|        // ""message"" - Сообщение об исключении.
		|        // ""innerException"" - Внутреннее исключение.
		|        public ScsRemoteException(string message, Exception innerException) : base(message, innerException)
		|        {
		|        }
		|    }
		|    //=========================================================================================================================================
		|
		|    // Это сообщение отправляется для вызова метода удаленного приложения.
		|    [Serializable]
		|    public class ScsRemoteInvokeMessage : ScsMessage
		|    {
		|        // Имя класса службы удаления.
		|        public string ServiceClassName { get; set; }
		|
		|        // Способ вызова удаленного приложения.
		|        public string MethodName { get; set; }
		|
		|        // Параметры метода.
		|        public object[] Parameters { get; set; }
		|
		|        // Представляет этот объект в виде строки.
		|        // Возврат - Строковое представление этого объекта
		|        public override string ToString()
		|        {
		|            return string.Format(""ScsRemoteInvokeMessage: {0}.{1}(...)"", ServiceClassName, MethodName);
		|        }
		|    }
		|    //=========================================================================================================================================
		|
		|    // Это сообщение отправляется в качестве ответного сообщения на ScsRemoteInvokeMessage.
		|    // Он используется для отправки возвращаемого значения вызова метода.
		|    [Serializable]
		|    public class ScsRemoteInvokeReturnMessage : ScsMessage
		|    {
		|        // Возвращаемое значение вызова удаленного метода.
		|        public object ReturnValue { get; set; }
		|
		|        // Если во время вызова метода возникло какое-либо исключение, это поле содержит объект исключения.
		|        // Если исключения не произошло, это поле равно нулю.
		|        public ScsRemoteException RemoteException { get; set; }
		|
		|        // Представляет этот объект в виде строки.
		|        // Возврат - Строковое представление этого объекта
		|        public override string ToString()
		|        {
		|            return string.Format(""ScsRemoteInvokeReturnMessage: Returns {0}, Exception = {1}"", ReturnValue, RemoteException);
		|        }
		|    }
		|    //=========================================================================================================================================
		|}
		|
		|namespace Hik.Communication.ScsServices.Communication
		|{
		|    // Этот класс расширяет RemoteInvokeProxy, чтобы обеспечить механизм автоматического подключения/ отключения, 
		|    // если клиент не подключен к серверу при вызове сервисного метода.
		|    // ""TProxy"" - Тип прокси-класса/интерфейса
		|    // ""TMessenger"" - Тип объекта messenger, который используется для отправки/получения сообщений
		|    internal class AutoConnectRemoteInvokeProxy<TProxy, TMessenger> : RemoteInvokeProxy<TProxy, TMessenger> where TMessenger : IMessenger
		|    {
		|        // Ссылка на объект клиента, который используется для подключения/отключения.
		|        private readonly IConnectableClient _client;
		|
		|        // Создает новый объект AutoConnectRemoteInvokeProxy.
		|        // ""clientMessenger"" - Объект Messenger, который используется для отправки/получения сообщений.
		|        // ""client"" - Ссылка на объект клиента, который используется для подключения/отключения.
		|        public AutoConnectRemoteInvokeProxy(RequestReplyMessenger<TMessenger> clientMessenger, IConnectableClient client) : base(clientMessenger)
		|        {
		|            _client = client;
		|        }
		|
		|        // Переопределяет вызовы сообщений и преобразует их в сообщения удаленному приложению.
		|        // ""msg"" - Сообщение о вызове метода (из базового класса RealProxy)
		|        // Возврат - Вызов метода возвращает сообщение (базовому классу RealProxy)
		|        public override IMessage Invoke(IMessage msg)
		|        {
		|            if (_client.CommunicationState == CommunicationStates.Connected)
		|            {
		|                //Если уже подключен, ведите себя как базовый класс (RemoteInvokeProxy).
		|                return base.Invoke(msg);
		|            }
		|
		|            //Подключитесь, вызовите метод и, наконец, отключитесь
		|            _client.Connect();
		|            try
		|            {
		|                return base.Invoke(msg);
		|            }
		|            finally
		|            {
		|                _client.Disconnect();
		|            }
		|        }
		|    }
		|    //=========================================================================================================================================
		|
		|    // Этот класс используется для создания динамического прокси-сервера для вызова удаленных методов.
		|    // Он переводит вызовы методов в обмен сообщениями.
		|    // ""TProxy"" - Тип прокси-класса/интерфейса
		|    // ""TMessenger"" - Тип объекта messenger, который используется для отправки/получения сообщений
		|    internal class RemoteInvokeProxy<TProxy, TMessenger> : RealProxy where TMessenger : IMessenger
		|    {
		|        // Объект Messenger, который используется для отправки/получения сообщений.
		|        private readonly RequestReplyMessenger<TMessenger> _clientMessenger;
		|
		|        // Создает новый объект RemoteInvokeProxy.
		|        // ""clientMessenger"" - Объект Messenger, который используется для отправки/получения сообщений.
		|        public RemoteInvokeProxy(RequestReplyMessenger<TMessenger> clientMessenger) : base(typeof(TProxy))
		|        {
		|            _clientMessenger = clientMessenger;
		|        }
		|
		|        // Переопределяет вызовы сообщений и преобразует их в сообщения удаленному приложению.
		|        // ""msg"" - Сообщение о вызове метода (из базового класса RealProxy)
		|        // Возврат - Вызов метода возвращает сообщение (базовому классу RealProxy)
		|        public override IMessage Invoke(IMessage msg)
		|        {
		|            var message = msg as IMethodCallMessage;
		|            if (message == null)
		|            {
		|                return null;
		|            }
		|
		|            var requestMessage = new ScsRemoteInvokeMessage
		|            {
		|                ServiceClassName = typeof(TProxy).Name,
		|                MethodName = message.MethodName,
		|                Parameters = message.InArgs
		|            };
		|
		|            var responseMessage = _clientMessenger.SendMessageAndWaitForResponse(requestMessage) as ScsRemoteInvokeReturnMessage;
		|            if (responseMessage == null)
		|            {
		|                return null;
		|            }
		|
		|            return responseMessage.RemoteException != null
		|                       ? new ReturnMessage(responseMessage.RemoteException, message)
		|                       : new ReturnMessage(responseMessage.ReturnValue, null, 0, message.LogicalCallContext, message);
		|        }
		|    }
		|    //=========================================================================================================================================
		|}
		|
		|namespace Hik.Communication.ScsServices.Client
		|{
		|    // Представляет клиента службы, который использует службу SCS.
		|    // ""T"" - Тип сервисного интерфейса
		|    public interface IScsServiceClient<out T> : IConnectableClient where T : class
		|    {
		|        // Ссылка на прокси-сервер службы для вызова методов удаленного обслуживания.
		|        T ServiceProxy { get; }
		|
		|        // Значение тайм-аута при вызове сервисного метода.
		|        // Если тайм-аут возникает до завершения вызова удаленного метода, генерируется исключение.
		|        // Используйте -1 для отсутствия тайм-аута (ожидание неопределенное).
		|        // Значение по умолчанию: 60000 (1 minute).
		|        int Timeout { get; set; }
		|    }
		|    //=========================================================================================================================================
		|
		|    // Представляет клиента службы, который использует службу SCS.
		|    // ""T"" - Тип сервисного интерфейса
		|    internal class ScsServiceClient<T> : IScsServiceClient<T> where T : class
		|    {
		|        // Это событие возникает, когда клиент подключается к серверу.
		|        public event EventHandler Connected;
		|
		|        // Это событие возникает, когда клиент отключается от сервера.
		|        public event EventHandler Disconnected;
		|
		|        // Тайм-аут для подключения к серверу (в миллисекундах).
		|        // Значение по умолчанию: 15 seconds (15000 ms).
		|        public int ConnectTimeout
		|        {
		|            get { return _client.ConnectTimeout; }
		|            set { _client.ConnectTimeout = value; }
		|        }
		|
		|        // Получает текущее состояние связи.
		|        public CommunicationStates CommunicationState
		|        {
		|            get { return _client.CommunicationState; }
		|        }
		|
		|        // Ссылка на прокси-сервер службы для вызова методов удаленного обслуживания.
		|        public T ServiceProxy { get; private set; }
		|
		|        // Значение тайм-аута при вызове сервисного метода.
		|        // Если тайм-аут возникает до завершения вызова удаленного метода, генерируется исключение.
		|        // Используйте -1 для отсутствия тайм-аута (ожидание неопределенное).
		|        // Значение по умолчанию: 60000 (1 minute).
		|        public int Timeout
		|        {
		|            get { return _requestReplyMessenger.Timeout; }
		|            set { _requestReplyMessenger.Timeout = value; }
		|        }
		|
		|        // Базовый объект IScsClient для связи с сервером.
		|        private readonly IScsClient _client;
		|
		|        // Объект Messenger для отправки/получения сообщений через _client.
		|        private readonly RequestReplyMessenger<IScsClient> _requestReplyMessenger;
		|
		|        // Этот объект используется для создания прозрачного прокси-сервера для вызова удаленных методов на сервере.
		|        private readonly AutoConnectRemoteInvokeProxy<T, IScsClient> _realServiceProxy;
		|
		|        // Клиентский объект, который используется для вызова метода, вызывается на стороне клиента.
		|        // Может быть нулевым, если у клиента нет методов, которые должны быть вызваны сервером.
		|        private readonly object _clientObject;
		|
		|        // Создает новый объект ScsServiceClient.
		|        // ""client"" - Базовый объект IScsClient для связи с сервером.
		|        // ""clientObject"" - Клиентский объект, который используется для вызова метода, вызывается на стороне клиента.
		|        // Может быть нулевым, если у клиента нет методов, которые должны быть вызваны сервером.
		|        public ScsServiceClient(IScsClient client, object clientObject)
		|        {
		|            _client = client;
		|            _clientObject = clientObject;
		|
		|            _client.Connected += Client_Connected;
		|            _client.Disconnected += Client_Disconnected;
		|
		|            _requestReplyMessenger = new RequestReplyMessenger<IScsClient>(client);
		|            _requestReplyMessenger.MessageReceived += RequestReplyMessenger_MessageReceived;
		|
		|            _realServiceProxy = new AutoConnectRemoteInvokeProxy<T, IScsClient>(_requestReplyMessenger, this);
		|            ServiceProxy = (T)_realServiceProxy.GetTransparentProxy();
		|        }
		|
		|        // Подключается к серверу.
		|        public void Connect()
		|        {
		|            _client.Connect();
		|        }
		|
		|        // Отключается от сервера.
		|        // Ничего не делает, если уже отключен.
		|        public void Disconnect()
		|        {
		|            _client.Disconnect();
		|        }
		|
		|        // Вызывает метод разъединения.
		|        public void Dispose()
		|        {
		|            Disconnect();
		|        }
		|
		|        // Обрабатывает событие MessageReceived мессенджера.
		|        // Он получает сообщения от сервера и вызывает соответствующий метод.
		|        // ""sender"" - Источник события.
		|        // ""e"" - Аргументы события.
		|        private void RequestReplyMessenger_MessageReceived(object sender, MessageEventArgs e)
		|        {
		|            //Отправьте сообщение в ScsRemoteInvokeMessage и проверьте его
		|            var invokeMessage = e.Message as ScsRemoteInvokeMessage;
		|            if (invokeMessage == null)
		|            {
		|                return;
		|            }
		|
		|            //Проверьте объект клиента.
		|            if (_clientObject == null)
		|            {
		|                SendInvokeResponse(invokeMessage, null, new ScsRemoteException(""Client does not wait for method invocations by server.""));
		|                return;
		|            }
		|
		|            //Вызовите метод
		|            object returnValue;
		|            try
		|            {
		|                var type = _clientObject.GetType();
		|                var method = type.GetMethod(invokeMessage.MethodName);
		|                returnValue = method.Invoke(_clientObject, invokeMessage.Parameters);
		|            }
		|            catch (TargetInvocationException ex)
		|            {
		|                var innerEx = ex.InnerException;
		|                SendInvokeResponse(invokeMessage, null, new ScsRemoteException(innerEx.Message, innerEx));
		|                return;
		|            }
		|            catch (Exception ex)
		|            {
		|                SendInvokeResponse(invokeMessage, null, new ScsRemoteException(ex.Message, ex));
		|                return;
		|            }
		|
		|            //Отправить возвращаемое значение
		|            SendInvokeResponse(invokeMessage, returnValue, null);
		|        }
		|
		|        // Отправляет ответ удаленному приложению, которое вызвало метод службы.
		|        // ""requestMessage"" - Сообщение с запросом.
		|        // ""returnValue"" - Возвращаемое значение для отправки.
		|        // ""exception"" - Исключение для отправки.
		|        private void SendInvokeResponse(IScsMessage requestMessage, object returnValue, ScsRemoteException exception)
		|        {
		|            try
		|            {
		|                _requestReplyMessenger.SendMessage(
		|                    new ScsRemoteInvokeReturnMessage
		|                    {
		|                        RepliedMessageId = requestMessage.MessageId,
		|                        ReturnValue = returnValue,
		|                        RemoteException = exception
		|                    });
		|            }
		|            catch { }
		|        }
		|
		|        // Обрабатывает подключенное событие объекта _client.
		|        // ""sender"" - Источник объекта.
		|        // ""e"" - Аргументы события.
		|        private void Client_Connected(object sender, EventArgs e)
		|        {
		|            _requestReplyMessenger.Start();
		|            OnConnected();
		|        }
		|
		|        // Обрабатывает отключенное событие объекта _client.
		|        // ""sender"" - Источник объекта.
		|        // ""e"" - Event arguments.
		|        private void Client_Disconnected(object sender, EventArgs e)
		|        {
		|            _requestReplyMessenger.Stop();
		|            OnDisconnected();
		|        }
		|
		|        // Вызывает связанное событие.
		|        private void OnConnected()
		|        {
		|            var handler = Connected;
		|            if (handler != null)
		|            {
		|                handler(this, EventArgs.Empty);
		|            }
		|        }
		|
		|        // Вызывает событие отключения.
		|        private void OnDisconnected()
		|        {
		|            var handler = Disconnected;
		|            if (handler != null)
		|            {
		|                handler(this, EventArgs.Empty);
		|            }
		|        }
		|    }
		|    //=========================================================================================================================================
		|
		|    // Этот класс используется для создания клиентов-служб для удаленного вызова методов службы SCS.
		|    public class ScsServiceClientBuilder
		|    {
		|        // Создает клиента для подключения к службе SCS.
		|        // ""T"" - Тип сервисного интерфейса для удаленного вызова метода
		|        // ""endpoint"" - Конечная точка сервера
		|        // ""clientObject"" - Объект на стороне клиента, который обрабатывает вызовы удаленных методов от сервера к клиенту.
		|        // Может быть нулевым, если у клиента нет методов, которые должны быть вызваны сервером
		|        // Возврат - Созданный клиентский объект для подключения к серверу
		|        public static IScsServiceClient<T> CreateClient<T>(ScsEndPoint endpoint, object clientObject = null) where T : class
		|        {
		|            return new ScsServiceClient<T>(endpoint.CreateClient(), clientObject);
		|        }
		|
		|        // Создает клиента для подключения к службе SCS.
		|        // ""T"" - Тип сервисного интерфейса для удаленного вызова метода
		|        // ""endpointAddress"" - Адрес конечной точки сервера
		|        // ""clientObject"" - Объект на стороне клиента, который обрабатывает вызовы удаленных методов от сервера к клиенту.
		|        // Может быть нулевым, если у клиента нет методов, которые должны быть вызваны сервером
		|        // Возврат - Созданный клиентский объект для подключения к серверу
		|        public static IScsServiceClient<T> CreateClient<T>(string endpointAddress, object clientObject = null) where T : class
		|        {
		|            return CreateClient<T>(ScsEndPoint.CreateEndPoint(endpointAddress), clientObject);
		|        }
		|    }
		|    //=========================================================================================================================================
		|}
		|
		|#endregion ScsServices
		|
		|#region Threading
		|
		|namespace Hik.Threading
		|{
		|    // Этот класс используется для последовательной многопоточной обработки элементов.
		|    // ""TItem"" - Тип элемента для обработки
		|    public class SequentialItemProcessor<TItem>
		|    {
		|        // Делегат метода, который вызывается для фактической обработки элементов.
		|        private readonly Action<TItem> _processMethod;
		|
		|        // Очередь элементов. Используется для последовательной обработки элементов.
		|        private readonly Queue<TItem> _queue;
		|
		|        // Ссылка на текущую задачу, которая обрабатывает элемент в методе ProcessItem.
		|        private Task _currentProcessTask;
		|
		|        // Указывает состояние обработки элемента.
		|        private bool _isProcessing;
		|
		|        // Логическое значение для управления запуском SequentialItemProcessor.
		|        private bool _isRunning;
		|
		|        // Объект для синхронизации потоков.
		|        private readonly object _syncObj = new object();
		|
		|        // Создает новый объект SequentialItemProcessor.
		|        // ""processMethod"" - Делегат метода, который вызывается для фактической обработки элементов.
		|        public SequentialItemProcessor(Action<TItem> processMethod)
		|        {
		|            _processMethod = processMethod;
		|            _queue = new Queue<TItem>();
		|        }
		|
		|        // Добавляет элемент в очередь для обработки элемента.
		|        // ""item"" - Элемент для добавления в очередь.
		|        public void EnqueueMessage(TItem item)
		|        {
		|            //Добавьте элемент в очередь и при необходимости запустите новую задачу
		|            lock (_syncObj)
		|            {
		|                if (!_isRunning)
		|                {
		|                    return;
		|                }
		|
		|                _queue.Enqueue(item);
		|
		|                if (!_isProcessing)
		|                {
		|                    _currentProcessTask = Task.Factory.StartNew(ProcessItem);
		|                }
		|            }
		|        }
		|
		|        // Запускает обработку элементов.
		|        public void Start()
		|        {
		|            _isRunning = true;
		|        }
		|
		|        // Останавливает обработку элементов и ожидает остановки текущего элемента.
		|        public void Stop()
		|        {
		|            _isRunning = false;
		|
		|            //Очистить все входящие сообщения
		|            lock (_syncObj)
		|            {
		|                _queue.Clear();
		|            }
		|
		|            //Проверьте, есть ли сообщение, которое сейчас обрабатывается
		|            if (!_isProcessing)
		|            {
		|                return;
		|            }
		|
		|            //Дождитесь завершения текущей задачи обработки
		|            try
		|            {
		|                _currentProcessTask.Wait();
		|            }
		|            catch { }
		|        }
		|
		|        // Этот метод выполняется в новой отдельной задаче (потоке) для обработки элементов в очереди.
		|        private void ProcessItem()
		|        {
		|            //Попробуйте получить элемент из очереди, чтобы обработать его.
		|            TItem itemToProcess;
		|            lock (_syncObj)
		|            {
		|                if (!_isRunning || _isProcessing)
		|                {
		|                    return;
		|                }
		|
		|                if (_queue.Count <= 0)
		|                {
		|                    return;
		|                }
		|
		|                _isProcessing = true;
		|                itemToProcess = _queue.Dequeue();
		|            }
		|
		|            //Обработайте элемент (вызвав делегат _processMethod)
		|            _processMethod(itemToProcess);
		|
		|            //Обработайте следующий элемент, если он доступен
		|            lock (_syncObj)
		|            {
		|                _isProcessing = false;
		|                if (!_isRunning || _queue.Count <= 0)
		|                {
		|                    return;
		|                }
		|
		|                //Начните новую задачу
		|                _currentProcessTask = Task.Factory.StartNew(ProcessItem);
		|            }
		|        }
		|    }
		|    //=========================================================================================================================================
		|
		|    // Этот класс представляет собой таймер, который периодически выполняет некоторые задачи.
		|    public class Timer
		|    {
		|        // Это событие периодически вызывается в соответствии с периодом таймера.
		|        public event EventHandler Elapsed;
		|
		|        // Период выполнения задания таймера (в миллисекундах).
		|        public int Period { get; set; }
		|
		|        // Указывает, вызывает ли таймер прошедшее событие при методе запуска таймера один раз.
		|        // По умолчанию: False.
		|        public bool RunOnStart { get; set; }
		|
		|        // Этот таймер используется для выполнения задачи через определенные промежутки времени.
		|        private readonly System.Threading.Timer _taskTimer;
		|
		|        // Указывает, запущен ли таймер или остановлен.
		|        private volatile bool _running;
		|
		|        // Указывает, что независимо от того, выполняется ли задача или _taskTimer находится в спящем режиме.
		|        // Это поле используется для ожидания выполнения задач при остановке таймера.
		|        private volatile bool _performingTasks;
		|
		|        // Создает новый таймер.
		|        // ""period"" - Период выполнения задания таймера (в миллисекундах)
		|        public Timer(int period) : this(period, false)
		|        {
		|        }
		|
		|        // Создает новый таймер.
		|        // ""period"" - Период выполнения задания таймера (в миллисекундах)
		|        // ""runOnStart"" - Указывает, вызывает ли таймер прошедшее событие при методе запуска таймера один раз.
		|        public Timer(int period, bool runOnStart)
		|        {
		|            Period = period;
		|            RunOnStart = runOnStart;
		|            _taskTimer = new System.Threading.Timer(TimerCallBack, null, Timeout.Infinite, Timeout.Infinite);
		|        }
		|
		|        // Запускает таймер.
		|        public void Start()
		|        {
		|            _running = true;
		|            _taskTimer.Change(RunOnStart ? 0 : Period, Timeout.Infinite);
		|        }
		|
		|        // Останавливает таймер.
		|        public void Stop()
		|        {
		|            lock (_taskTimer)
		|            {
		|                _running = false;
		|                _taskTimer.Change(Timeout.Infinite, Timeout.Infinite);
		|            }
		|        }
		|
		|        // Ожидает остановки службы.
		|        public void WaitToStop()
		|        {
		|            lock (_taskTimer)
		|            {
		|                while (_performingTasks)
		|                {
		|                    Monitor.Wait(_taskTimer);
		|                }
		|            }
		|        }
		|
		|        // Этот метод вызывается _taskTimer.
		|        // ""state"" - Неиспользованный аргумент.
		|        private void TimerCallBack(object state)
		|        {
		|            lock (_taskTimer)
		|            {
		|                if (!_running || _performingTasks)
		|                {
		|                    return;
		|                }
		|
		|                _taskTimer.Change(Timeout.Infinite, Timeout.Infinite);
		|                _performingTasks = true;
		|            }
		|
		|            try
		|            {
		|                if (Elapsed != null)
		|                {
		|                    Elapsed(this, new EventArgs());
		|                }
		|            }
		|            catch { }
		|            finally
		|            {
		|                lock (_taskTimer)
		|                {
		|                    _performingTasks = false;
		|                    if (_running)
		|                    {
		|                        _taskTimer.Change(Period, Timeout.Infinite);
		|                    }
		|
		|                    Monitor.Pulse(_taskTimer);
		|                }
		|            }
		|        }
		|    }
		|    //=========================================================================================================================================
		|}
		|
		|#endregion Threading
		|
		|#region Collections
		|
		|namespace Hik.Collections
		|{
		|    // Этот класс используется для хранения элементов на основе ключа-значения потокобезопасным способом.
		|    // Он использует System.Collections.Generic.SortedList изнутри.
		|    // ""TK"" - Тип ключа
		|    // ""TV"" - Тип значения
		|    public class ThreadSafeSortedList<TK, TV>
		|    {
		|        // Получает/добавляет/заменяет элемент по ключу.
		|        // ""key"" - Ключ для получения/установки значения
		|        // Возврат - Элемент, связанный с этим ключом
		|        public TV this[TK key]
		|        {
		|            get
		|            {
		|                _lock.EnterReadLock();
		|                try
		|                {
		|                    return _items.ContainsKey(key) ? _items[key] : default(TV);
		|                }
		|                finally
		|                {
		|                    _lock.ExitReadLock();
		|                }
		|            }
		|
		|            set
		|            {
		|                _lock.EnterWriteLock();
		|                try
		|                {
		|                    _items[key] = value;
		|                }
		|                finally
		|                {
		|                    _lock.ExitWriteLock();
		|                }
		|            }
		|        }
		|
		|        // Получает количество элементов в коллекции.
		|        public int Count
		|        {
		|            get
		|            {
		|                _lock.EnterReadLock();
		|                try
		|                {
		|                    return _items.Count;
		|                }
		|                finally
		|                {
		|                    _lock.ExitReadLock();
		|                }
		|            }
		|        }
		|
		|        // Внутренняя коллекция для хранения предметов.
		|        protected readonly SortedList<TK, TV> _items;
		|
		|        // Используется для синхронизации доступа к списку _items.
		|        protected readonly ReaderWriterLockSlim _lock;
		|
		|        // Создает новый объект ThreadSafeSortedList.
		|        public ThreadSafeSortedList()
		|        {
		|            _items = new SortedList<TK, TV>();
		|            _lock = new ReaderWriterLockSlim(LockRecursionPolicy.NoRecursion);
		|        }
		|
		|        // Проверяет, содержит ли коллекция специальный ключ.
		|        // ""key"" - Ключ для проверки
		|        // Возврат - True; если коллекция содержит данный ключ
		|        public bool ContainsKey(TK key)
		|        {
		|            _lock.EnterReadLock();
		|            try
		|            {
		|                return _items.ContainsKey(key);
		|            }
		|            finally
		|            {
		|                _lock.ExitReadLock();
		|            }
		|        }
		|
		|        // Проверяет, содержит ли коллекция определенный элемент.
		|        // ""item"" - Элемент для проверки
		|        // Возврат - True; если коллекция содержит данный элемент
		|        public bool ContainsValue(TV item)
		|        {
		|            _lock.EnterReadLock();
		|            try
		|            {
		|                return _items.ContainsValue(item);
		|            }
		|            finally
		|            {
		|                _lock.ExitReadLock();
		|            }
		|        }
		|
		|        // Удаляет элемент из коллекции.
		|        // ""key"" - Ключ элемента для удаления
		|        public bool Remove(TK key)
		|        {
		|            _lock.EnterWriteLock();
		|            try
		|            {
		|                if (!_items.ContainsKey(key))
		|                {
		|                    return false;
		|                }
		|
		|                _items.Remove(key);
		|                return true;
		|            }
		|            finally
		|            {
		|                _lock.ExitWriteLock();
		|            }
		|        }
		|
		|        // Получает все предметы в коллекции.
		|        // Возврат - Список элементов
		|        public List<TV> GetAllItems()
		|        {
		|            _lock.EnterReadLock();
		|            try
		|            {
		|                return new List<TV>(_items.Values);
		|            }
		|            finally
		|            {
		|                _lock.ExitReadLock();
		|            }
		|        }
		|
		|        // Удаляет все элементы из списка.
		|        public void ClearAll()
		|        {
		|            _lock.EnterWriteLock();
		|            try
		|            {
		|                _items.Clear();
		|            }
		|            finally
		|            {
		|                _lock.ExitWriteLock();
		|            }
		|        }
		|
		|        // Получает, затем удаляет все элементы в коллекции.
		|        // Возврат - Список элементов
		|        public List<TV> GetAndClearAllItems()
		|        {
		|            _lock.EnterWriteLock();
		|            try
		|            {
		|                var list = new List<TV>(_items.Values);
		|                _items.Clear();
		|                return list;
		|            }
		|            finally
		|            {
		|                _lock.ExitWriteLock();
		|            }
		|        }
		|    }
		|    //=========================================================================================================================================
		|}
		|
		|#endregion Collections		
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "ServerClient" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace oscs
		|{
		|    public class ServerClient
		|    {
		|        public CsServerClient dll_obj;
		|        public IScsServerClient M_ServerClient;
		|        public string Disconnected { get; set; }
		|        public string MessageReceived { get; set; }
		|        public string MessageSent { get; set; }
		|
		|        public ServerClient(IScsServerClient p1)
		|        {
		|            M_ServerClient = p1;
		|            M_ServerClient.Disconnected += M_ServerClient_Disconnected;
		|            M_ServerClient.MessageReceived += M_ServerClient_MessageReceived;
		|            M_ServerClient.MessageSent += M_ServerClient_MessageSent;
		|            Disconnected = """";
		|            MessageReceived = """";
		|            MessageSent = """";
		|        }
		|		
		|        private void M_ServerClient_MessageReceived(object sender, Hik.Communication.Scs.Communication.Messages.MessageEventArgs e)
		|        {
		|            if (dll_obj.MessageReceived != null)		
		|            {
		|                oscs.MessageEventArgs MessageEventArgs1 = new oscs.MessageEventArgs(e.Message);
		|                MessageEventArgs1.EventAction = dll_obj.MessageReceived;
		|                MessageEventArgs1.Sender = this;
		|                CsMessageEventArgs CsMessageEventArgs1 = new CsMessageEventArgs(MessageEventArgs1);
		|                OneScriptClientServer.EventQueue.Enqueue(MessageEventArgs1);
		|            }
		|        }
		|		
		|        private void M_ServerClient_MessageSent(object sender, Hik.Communication.Scs.Communication.Messages.MessageEventArgs e)
		|        {
		|            if (e.Message.GetType() == typeof(ScsPingMessage))
		|            {
		|                return;
		|            }
		|
		|            if (dll_obj.MessageSent != null)		
		|            {
		|                oscs.MessageEventArgs MessageEventArgs1 = new oscs.MessageEventArgs(e.Message);
		|                MessageEventArgs1.EventAction = dll_obj.MessageSent;
		|                MessageEventArgs1.Sender = this;
		|                CsMessageEventArgs CsMessageEventArgs1 = new CsMessageEventArgs(MessageEventArgs1);
		|                OneScriptClientServer.EventQueue.Enqueue(MessageEventArgs1);
		|            }
		|        }
		|
		|        private void M_ServerClient_Disconnected(object sender, System.EventArgs e)
		|        {
		|            if (dll_obj.Disconnected != null)		
		|            {
		|                oscs.EventArgs EventArgs1 = new oscs.EventArgs();
		|                EventArgs1.EventAction = dll_obj.Disconnected;
		|                EventArgs1.Sender = this;
		|                CsEventArgs CsEventArgs1 = new CsEventArgs(EventArgs1);
		|                OneScriptClientServer.EventQueue.Enqueue(EventArgs1);
		|            }
		|        }
		|		
		|        public void Disconnect()
		|        {
		|            M_ServerClient.Disconnect();
		|        }
		|
		|        public decimal ClientId
		|        {
		|            get { return Convert.ToDecimal(M_ServerClient.ClientId); }
		|        }
		|
		|        public int CommunicationState
		|        {
		|            get { return (int)M_ServerClient.CommunicationState; }
		|        }
		|
		|        public TcpEndPoint RemoteEndPoint
		|        {
		|            get { return new TcpEndPoint(M_ServerClient.RemoteEndPoint); }
		|        }
		|		
		|        public void SendMessage(IScsMessage p1)
		|        {
		|            M_ServerClient.SendMessage(p1);
		|        }
		|    }//endClass
		|}//endnamespace
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "TcpServer" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace Hik.Communication.Scs.Server.Tcp
		|{
		|    // Этот класс используется для создания TCP-сервера.
		|    internal class ScsTcpServer : ScsServerBase
		|    {
		|        // Адрес конечной точки сервера для прослушивания входящих подключений.
		|        private readonly ScsTcpEndPoint _endPoint;
		|
		|        // Создает новый объект ScsTcpServer.
		|        // ""endPoint"" - Адрес конечной точки сервера для прослушивания входящих подключений
		|        public ScsTcpServer(ScsTcpEndPoint endPoint)
		|        {
		|            _endPoint = endPoint;
		|        }
		|
		|        // Создает прослушиватель TCP-соединений.
		|        // Возврат - Созданный объект прослушивателя
		|        protected override IConnectionListener CreateConnectionListener()
		|        {
		|            return new TcpConnectionListener(_endPoint);
		|        }
		|    }
		|}
		|		
		|namespace oscs
		|{
		|    public class ScsServer
		|    {
		|        public CsTcpServer dll_obj;
		|        public IScsServer M_TcpServer;
		|        public string ClientConnected { get; set; }
		|        public string ClientDisconnected { get; set; }
		|
		|        public ScsServer(int p1)
		|        {
		|            ScsTcpEndPoint ScsTcpEndPoint1 = new ScsTcpEndPoint(p1);
		|            M_TcpServer = ScsServerFactory.CreateServer(ScsTcpEndPoint1);
		|            M_TcpServer.ClientConnected += M_TcpServer_ClientConnected;
		|            M_TcpServer.ClientDisconnected += M_TcpServer_ClientDisconnected;
		|            ClientConnected = """";
		|            ClientDisconnected = """";
		|        }
		|
		|        private void M_TcpServer_ClientDisconnected(object sender, Hik.Communication.Scs.Server.ServerClientEventArgs e)
		|        {
		|            if (dll_obj.ClientDisconnected != null)		
		|            {
		|                oscs.ServerClientEventArgs ServerClientEventArgs1 = new oscs.ServerClientEventArgs(e);
		|                ServerClientEventArgs1.EventAction = dll_obj.ClientDisconnected;
		|                ServerClientEventArgs1.Sender = this;
		|                ServerClientEventArgs1.Client = new CsServerClient(e.Client);
		|                CsServerClientEventArgs CsServerClientEventArgs1 = new CsServerClientEventArgs(ServerClientEventArgs1);
		|                OneScriptClientServer.EventQueue.Enqueue(ServerClientEventArgs1);
		|            }
		|        }
		|
		|        private void M_TcpServer_ClientConnected(object sender, Hik.Communication.Scs.Server.ServerClientEventArgs e)
		|        {
		|            if (dll_obj.ClientConnected != null)		
		|            {
		|                oscs.ServerClientEventArgs ServerClientEventArgs1 = new oscs.ServerClientEventArgs(e);
		|                ServerClientEventArgs1.EventAction = dll_obj.ClientConnected;
		|                ServerClientEventArgs1.Sender = this;
		|                oscs.CsServerClient CsServerClient1 = new CsServerClient(e.Client);
		|                CsServerClient1.MessageReceived = OneScriptClientServer.ServerMessageReceived;
		|                CsServerClient1.MessageSent = OneScriptClientServer.ServerMessageSent;
		|                ServerClientEventArgs1.Client = CsServerClient1;
		|                CsServerClientEventArgs CsServerClientEventArgs1 = new CsServerClientEventArgs(ServerClientEventArgs1);
		|                OneScriptClientServer.EventQueue.Enqueue(ServerClientEventArgs1);
		|            }
		|        }
		|
		|        public void Start()
		|        {
		|            M_TcpServer.Start();
		|        }
		|
		|        public void Stop()
		|        {
		|            M_TcpServer.Stop();
		|        }
		|		
		|        public ArrayImpl Clients
		|        {
		|            get
		|            {
		|                List<IScsServerClient> list = M_TcpServer.Clients.GetAllItems();
		|                ArrayImpl arrayImpl = new ArrayImpl();
		|                for (int i = 0; i < list.Count; i++)
		|                {
		|                    arrayImpl.Add(new CsServerClient(list[i]));
		|                }
		|                return arrayImpl;
		|            }
		|        }
		|    }//endClass
		|}//endnamespace
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "MessageEventArgs" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace Hik.Communication.Scs.Communication.Messages
		|{
		|    // Сохраняет сообщение, которое будет использоваться событием.
		|    public class MessageEventArgs : System.EventArgs
		|    {
		|        // Объект сообщение, связанный с этим событием.
		|        public IScsMessage Message { get; private set; }
		|
		|        // Создает новый объект MessageEventArgs.
		|        // ""message"" - Объект сообщение, связанный с этим событием.
		|        public MessageEventArgs(IScsMessage message)
		|        {
		|            Message = message;
		|        }
		|    }
		|}
		|
		|namespace oscs
		|{
		|    public class MessageEventArgs : oscs.EventArgs
		|    {
		|        public new CsMessageEventArgs dll_obj;
		|        private IScsMessage message;
		|
		|        public MessageEventArgs(IScsMessage p1)
		|        {
		|            message = p1;
		|        }
		|
		|        public MessageEventArgs(Hik.Communication.Scs.Communication.Messages.MessageEventArgs args)
		|        {
		|            message = args.Message;
		|        }
		|
		|        public dynamic Message
		|        {
		|            get
		|            {
		|                dynamic Obj1 = null;
		|                string str1 = message.GetType().ToString();
		|                string str2 = ""oscs."" + (str1.Substring(str1.LastIndexOf(""."") + 1).Replace(""Scs"", """").Replace(""RawDataMessage"", ""ByteMessage""));
		|                System.Type TestType = System.Type.GetType(str2, false, true);
		|                object[] args = { message };
		|                Obj1 = Activator.CreateInstance(TestType, args);
		|                return Obj1;
		|            }
		|        }
		|    }//endClass
		|}//endnamespace
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "ServerClientEventArgs" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace Hik.Communication.Scs.Server
		|{
		|    // Хранит информацию о клиенте, которая будет использоваться событием.
		|    public class ServerClientEventArgs : EventArgs
		|    {
		|        // Клиент, связанный с этим событием.
		|        public IScsServerClient Client { get; private set; }
		|
		|        // Создает новый объект ServerClientEventArgs.
		|        // ""client"" - Клиент, связанный с этим событием
		|        public ServerClientEventArgs(IScsServerClient client)
		|        {
		|            Client = client;
		|        }
		|    }
		|}
		|
		|namespace oscs
		|{
		|    public class ServerClientEventArgs : oscs.EventArgs
		|    {
		|        public new CsServerClientEventArgs dll_obj;
		|        private IScsServerClient client;
		|
		|        public ServerClientEventArgs(IScsServerClient p1)
		|        {
		|            client = p1;
		|        }
		|
		|        public ServerClientEventArgs(Hik.Communication.Scs.Server.ServerClientEventArgs args)
		|        {
		|            client = args.Client;
		|        }
		|
		|        public CsServerClient Client { get; set; }
		|    }//endClass
		|}//endnamespace
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	ИначеЕсли ИмяФайлаCs = "EventArgs" Тогда
		СтрВыгрузки = СтрВыгрузки + 
		"namespace oscs
		|{
		|    public class EventArgs
		|    {
		|        public CsEventArgs dll_obj;
		|        public dynamic Sender;
		|        public IValue EventAction;
		|
		|        public EventArgs()
		|        {
		|            Sender = null;
		|            EventAction = null;
		|        }
		|    }//endClass
		|}//endnamespace
		|";
		ТекстДокХХХ = Новый ТекстовыйДокумент;
		ТекстДокХХХ.УстановитьТекст(СтрВыгрузки);
		ТекстДокХХХ.Записать(КаталогВыгрузки + "\" + ИмяФайлаCs + ".cs");
	КонецЕсли;
КонецПроцедуры//СоздатьФайлCs

Процедура СортировкаКода()
	Таймер = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	ВыбранныеФайлы = НайтиФайлы(КаталогВыгрузки, "*.cs", Ложь);
	Найдено1 = 0;
	Для А = 0 По ВыбранныеФайлы.ВГраница() Цикл
		СтрДирективы = "";
		Директивы = Новый СписокЗначений;
		Классы1Уровня = Новый СписокЗначений;
		Классы2Уровня = Новый СписокЗначений;
		Классы3Уровня = Новый СписокЗначений;
		
		Если ВыбранныеФайлы[А].Имя = "TcpServer.cs" 
			или ВыбранныеФайлы[А].Имя = "ServerClientEventArgs.cs" 
			или ВыбранныеФайлы[А].Имя = "ScsSupport.cs" 
			или ВыбранныеФайлы[А].Имя = "MessageEventArgs.cs" 
			или ВыбранныеФайлы[А].Имя = "ServiceApplication.cs" 
			или ВыбранныеФайлы[А].Имя = "ServiceClient.cs" 
			или ВыбранныеФайлы[А].Имя = "ServiceClientEventArgs.cs" 
			или ВыбранныеФайлы[А].Имя = "ServiceApplicationClient.cs" 
			или ВыбранныеФайлы[А].Имя = "IMyService.cs" 
			или ВыбранныеФайлы[А].Имя = "MyService.cs" 
			или ВыбранныеФайлы[А].Имя = "IMyClient.cs" 
			или ВыбранныеФайлы[А].Имя = "MyClient.cs" 
			или ВыбранныеФайлы[А].Имя = "ClientInfo.cs" 
			или ВыбранныеФайлы[А].Имя = "Collection.cs" 
		Тогда
		
			Продолжить;
		КонецЕсли;
		
		ТекстДок = Новый ТекстовыйДокумент;
		ТекстДок.Прочитать(ВыбранныеФайлы[А].ПолноеИмя);
		
		Сообщить(" (" + Лев(Строка(((ТекущаяУниверсальнаяДатаВМиллисекундах() - Таймер)/1000)/60), 4) + " мин." + " " + (А + 1) + " из " + ВыбранныеФайлы.Количество() + ") " + ВыбранныеФайлы[А].ПолноеИмя);
		
		// Сообщить("=== " + ВыбранныеФайлы[А].Имя + " ========================================================================================");
		Стр = ТекстДок.ПолучитьТекст();
		М = СтрНайтиМежду(Стр, "using", "namespace", , );
		Если М.Количество() > 0 Тогда
			// Сообщить("=== " + ВыбранныеФайлы[А].Имя + " =========================================================================");
			СтрДирективы = М[0];
			СтрДирективы = СокрЛП(СтрДирективы);
			Директивы.Добавить("using " + СтрДирективы);
		КонецЕсли;
		
		Если Не (СтрДирективы = "") Тогда
			Стр = СтрЗаменить(Стр, СтрДирективы, "");
		КонецЕсли;
		
		//Классы3Уровня оставляем без изменения
		М = СтрНайтиМежду(Стр, "[ContextClass", "//endClass", , );
		Если М.Количество() > 0 Тогда
			Для А1 = 0 По М.ВГраница() Цикл
				СтрКлассы3Уровня = М[А1];
				СтрКлассы3Уровня = СокрЛП(СтрКлассы3Уровня);
				Классы3Уровня.Добавить("    [ContextClass " + СтрКлассы3Уровня);
			КонецЦикла;
			Стр = СтрЗаменить(Стр, СтрКлассы3Уровня, "");
		КонецЕсли;
		
		//Классы1Уровня оставляем без изменения
		М = СтрНайтиМежду(Стр, "public class", "//endClass", Ложь, );
		Если М.Количество() > 0 Тогда
			Для А1 = 0 По М.ВГраница() Цикл
				Если СтрНайти(М[А1], "Ex :") > 0 Тогда
					СтрКлассы1Уровня = М[А1];
					СтрКлассы1Уровня = СтрЗаменить(СтрКлассы1Уровня, "//endClass", "");
					СтрКлассы1Уровня = СокрЛП(СтрКлассы1Уровня);
					Классы1Уровня.Добавить("    " + СтрКлассы1Уровня);
					Стр = СтрЗаменить(Стр, СтрКлассы1Уровня, "");
				Иначе
					СтрКлассы2Уровня = М[А1];
					СтрКлассы2Уровня = СокрЛП(СтрКлассы2Уровня);
					Классы2Уровня.Добавить(СортировкаКласса2Уровня(СтрКлассы2Уровня));
					Стр = СтрЗаменить(Стр, СтрКлассы2Уровня, "");
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		
		Директивы.СортироватьПоЗначению();
		Стр = "";
		
		Для А1 = 0 По Директивы.Количество() - 1 Цикл
				Стр = Стр + Символы.ПС + Директивы.Получить(А1).Значение;
		КонецЦикла;
		Стр = Стр + Символы.ПС + Символы.ПС + "namespace oscs" + Символы.ПС + "{";
		Для А1 = 0 По Классы1Уровня.Количество() - 1 Цикл
			Стр = Стр + Символы.ПС + Классы1Уровня.Получить(А1).Значение;
		КонецЦикла;
		Если Классы2Уровня.Количество() > 0 Тогда
			Для А1 = 0 По Классы2Уровня.Количество() - 1 Цикл
				Стр = Стр + Символы.ПС + Классы2Уровня.Получить(А1).Значение;
				Стр = Стр + Символы.ПС;
				Стр = Стр + Символы.ПС + "    }" + Символы.ПС;
			КонецЦикла;
		КонецЕсли;
		Для А1 = 0 По Классы3Уровня.Количество() - 1 Цикл
			Стр = Стр + Символы.ПС + Классы3Уровня.Получить(А1).Значение;
		КонецЦикла;
		Стр = Стр + Символы.ПС + "}";
		
		//удалим "//endMethods"
		СтрКонечная = "";
		Для А1 = 1 По СтрЧислоСтрок(Стр) - 1 Цикл
			Фрагмент1 = СокрЛП(СтрПолучитьСтроку(Стр, А1)) + СокрЛП(СтрПолучитьСтроку(Стр, А1 + 1));
			Если Не (Фрагмент1 = "//endMethods") Тогда
				СтрКонечная = СтрКонечная + Символы.ПС + СтрПолучитьСтроку(Стр, А1);
			КонецЕсли;
		КонецЦикла;
		СтрКонечная = СтрКонечная + Символы.ПС + СтрПолучитьСтроку(Стр, СтрЧислоСтрок(Стр));
		Стр = СтрКонечная;
		СтрКонечная = "";
		Для А1 = 1 По СтрЧислоСтрок(Стр) Цикл
			Если Не (СокрЛП(СтрПолучитьСтроку(Стр, А1)) = "//endMethods") Тогда
				СтрКонечная = СтрКонечная + Символы.ПС + СтрПолучитьСтроку(Стр, А1);
			КонецЕсли;
		КонецЦикла;
		
		//удалим "//endProperty"
		Стр = СтрКонечная;
		СтрКонечная = "";
		Для А1 = 1 По СтрЧислоСтрок(Стр) - 1 Цикл
			Фрагмент1 = СокрЛП(СтрПолучитьСтроку(Стр, А1)) + СокрЛП(СтрПолучитьСтроку(Стр, А1 + 1));
			Если Не (Фрагмент1 = "//endProperty") Тогда
				СтрКонечная = СтрКонечная + Символы.ПС + СтрПолучитьСтроку(Стр, А1);
			КонецЕсли;
		КонецЦикла;
		СтрКонечная = СтрКонечная + Символы.ПС + СтрПолучитьСтроку(Стр, СтрЧислоСтрок(Стр));
		Стр = СтрКонечная;
		СтрКонечная = "";
		Для А1 = 1 По СтрЧислоСтрок(Стр) Цикл
			Если Не (СокрЛП(СтрПолучитьСтроку(Стр, А1)) = "//endProperty") Тогда
				СтрКонечная = СтрКонечная + Символы.ПС + СтрПолучитьСтроку(Стр, А1);
			КонецЕсли;
		КонецЦикла;
		
		СтрКонечная = СтрЗаменить(СтрКонечная, "//Свойства============================================================", "");
		СтрКонечная = СтрЗаменить(СтрКонечная, "//Методы============================================================", "");
		
		
		
		
		
		
		
		
		
		//заменим две пустые строки подряд на одну пустую
		Стр = СтрКонечная;
		СтрКонечная = "";
		Для А1 = 1 По СтрЧислоСтрок(Стр) - 1 Цикл
			Фрагмент1 = СокрЛП(СтрПолучитьСтроку(Стр, А1)) + СокрЛП(СтрПолучитьСтроку(Стр, А1 + 1));
			Если Не (Фрагмент1 = "") Тогда
				СтрКонечная = СтрКонечная + Символы.ПС + СтрПолучитьСтроку(Стр, А1);
			КонецЕсли;
		КонецЦикла;
		СтрКонечная = СтрКонечная + Символы.ПС + СтрПолучитьСтроку(Стр, СтрЧислоСтрок(Стр));
		
		//удалим "//end_constr"
		ПодстрокаПоиска = "//end_constr";
		ПодстрокаЗамены = "";
		СтрКонечная = СтрЗаменить(СтрКонечная, ПодстрокаПоиска, ПодстрокаЗамены);
		
		СтрКонечная = СокрЛП(СтрКонечная);
		// Сообщить("" + СтрКонечная);
		
		ТекстДок.УстановитьТекст(СтрКонечная);
		ТекстДок.Записать(ВыбранныеФайлы[А].ПолноеИмя);
	КонецЦикла;
	
	ВыбранныеФайлы = НайтиФайлы(КаталогВыгрузки, "*.cs", Ложь);
	Для А = 0 По ВыбранныеФайлы.ВГраница() Цикл
		ТекстДок = Новый ТекстовыйДокумент;
		ТекстДок.Прочитать(ВыбранныеФайлы[А].ПолноеИмя);
		Стр = ТекстДок.ПолучитьТекст();
		
		ПодстрокаПоиска = "        }
		|        
		|        //endMethods
		|    }//endClass
		|
		|}//endnamespace";
		ПодстрокаЗамены = "        }
		|    }
		|}";
		Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		ПодстрокаПоиска = "//endProperty
		|        //Методы============================================================";
		ПодстрокаЗамены = "//Методы============================================================";
		Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		ПодстрокаПоиска = ">
		|    {
		|
		|        public";
		ПодстрокаЗамены = ">
		|    {
		|        public";
		Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		ПодстрокаПоиска = "}
		|
		|    }
		|
		|    [ContextClass";
		ПодстрокаЗамены = "}
		|    }
		|
		|    [ContextClass";
		Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		ПодстрокаПоиска = "oscs
		|{
		|
		|    public";
		ПодстрокаЗамены = "oscs
		|{
		|    public";
		Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		ПодстрокаПоиска = "}
		|
		|    }
		|}";
		ПодстрокаЗамены = "}
		|    }
		|}";
		Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		ПодстрокаПоиска = "}
		|
		|    }
		|
		|    public class";
		ПодстрокаЗамены = "}
		|    }
		|
		|    public class";
		Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		ПодстрокаПоиска = "}
		|
		|    }
		|
		|}";
		ПодстрокаЗамены = "}
		|    }
		|}";
		Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		ПодстрокаПоиска = ";
		|        }
		|
		|    }";
		ПодстрокаЗамены = ";
		|        }
		|    }";
		Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		ПодстрокаПоиска = "//Свойства============================================================";
		ПодстрокаЗамены = "";
		Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		ПодстрокаПоиска = "//Методы============================================================";
		ПодстрокаЗамены = "";
		Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		
		ПодстрокаПоиска = "}//endClass";
		ПодстрокаЗамены = "}";
		Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		ПодстрокаПоиска = "}//end_constr";
		ПодстрокаЗамены = "}";
		Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		ПодстрокаПоиска = "        }
		|					
		|        //endMethods
		|    }
		|
		|}//endnamespace";
		ПодстрокаЗамены = "        }
		|    }
		|}";
		Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		ПодстрокаПоиска = "        }
		|
		|        
		|        //endMethods
		|    }
		|
		|}//endnamespace";
		ПодстрокаЗамены = "        }
		|    }
		|}";
		Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		ПодстрокаПоиска = "}//endnamespace";
		ПодстрокаЗамены = "}";
		Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		ПодстрокаПоиска = "        }
		|
		|    }
		|}";
		ПодстрокаЗамены = "        }
		|    }
		|}";
		Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		ПодстрокаПоиска = "        }
		|        
		|    }
		|";
		ПодстрокаЗамены = "        }
		|    }
		|";
		Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		ПодстрокаПоиска = "        }
		|
		|
		|        
		|        [ContextProperty(""ГуидКлиента"", ""ClientGuid"")]
		|";
		ПодстрокаЗамены = "        }
		|        
		|        [ContextProperty(""ГуидКлиента"", ""ClientGuid"")]
		|";
		Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		ПодстрокаПоиска = "        public string ClientName { get; set; }
		|
		|        
		|        //endMethods
		|    }
		|";
		ПодстрокаЗамены = "        public string ClientName { get; set; }
		|    }
		|";
		Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		ПодстрокаПоиска = "    }
		|
		|}
		|";
		ПодстрокаЗамены = "    }
		|}
		|";
		Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		
		
		
		// ПодстрокаПоиска = "";
		// ПодстрокаЗамены = "";
		// Стр = СтрЗаменить(Стр, ПодстрокаПоиска, ПодстрокаЗамены);
		
		ТекстДок.УстановитьТекст(Стр);
		ТекстДок.Записать(ВыбранныеФайлы[А].ПолноеИмя);
	КонецЦикла;
	
	Сообщить("Найдено " + ВыбранныеФайлы.Количество());
	Сообщить("Выполнено за: " + ((ТекущаяУниверсальнаяДатаВМиллисекундах() - Таймер)/1000)/60 + " мин.");
КонецПроцедуры//СортировкаКода()

Функция СортировкаКласса2Уровня(СтрКласса)
	Стр = СтрЗаменить(СтрКласса,  "}//endClass", "//end");
	
	М3 = СтрНайтиМежду(Стр, "[DllImport", ";", Ложь, );
	Для А = 0 По М3.ВГраница() Цикл
		Стр = СтрЗаменить(Стр, М3[А], "");
	КонецЦикла;
	
	//повставлять \r\n//end перед каждым private, public, [DllImport
	Стр = СтрЗаменить(Стр, "private", "//end" + Символы.ПС + "private");
	Стр = СтрЗаменить(Стр, "public", "//end" + Символы.ПС + "public");
	
	Голова = "";
	Поля = Новый СписокЗначений;
	Конструкторы = Новый СписокЗначений;
	Свойства = Новый СписокЗначений;
	Методы = Новый СписокЗначений;
	
	М = Новый Массив;
	М1 = СтрНайтиМежду(Стр, "private", "//end", , );
	М2 = СтрНайтиМежду(Стр, "public", "//end", , );
	Для А = 0 По М1.ВГраница() Цикл
		М.Добавить("private" + М1[А]);
	КонецЦикла;
	Для А = 0 По М2.ВГраница() Цикл
		М.Добавить("public" + М2[А]);
	КонецЦикла;
	Для А = 0 По М3.ВГраница() Цикл
		М.Добавить("" + М3[А]);
	КонецЦикла;
	
	Для А = 0 По М.ВГраница() Цикл
		Фрагмент = СокрЛП(М[А]);
		ВтороеСловоВоФрагменте = "";
		М125 = СтрРазделить(Фрагмент, "");
		Если М125.Количество() > 0 Тогда
			ВтороеСловоВоФрагменте = М125[1];
		КонецЕсли;
		
		ИмяКласса = "";
		СтрокаСИменемКласса = СтрПолучитьСтроку(СокрЛП(СтрКласса), 1);
		ИмяКласса = СтрРазделить(СтрПолучитьСтроку(СокрЛП(СтрКласса), 1), " ")[2];
		
		// если есть слово class тогда это Голова
		Если СтрНайти(Фрагмент, "class") > 0 Тогда
			Голова = Голова + Символы.ПС + "    " + Фрагмент;
		// если последний знак ; тогда это Поля
		ИначеЕсли (Прав(Фрагмент, 1) = ";") или (СтрНайти(Фрагмент, "DllImport") > 0) Тогда
			//создать представление
			Поля.Добавить("        " + Фрагмент, СтрРазделить(СтрПолучитьСтроку(Фрагмент, 1), " ")[2]);
		// если первая строка содержит имя класса со следующей за ним скобкой тогда это Конструкторы
		ИначеЕсли Лев(ВтороеСловоВоФрагменте, СтрДлина(ИмяКласса + "(")) = ИмяКласса + "(" Тогда
			Конструкторы.Добавить("        " + Фрагмент);
		// если есть слово set или get тогда это Свойства
		ИначеЕсли (СтрНайти(Фрагмент, "get") > 0) или (СтрНайти(Фрагмент, "set") > 0) Тогда
			Свойства.Добавить("        " + Фрагмент, СтрРазделить(СтрПолучитьСтроку(Фрагмент, 1), " ")[2]);
		// если в первой строке есть скобка ( тогда это Методы
		ИначеЕсли СтрНайти(СтрПолучитьСтроку(Фрагмент, 1), "(") > 0 Тогда
			Методы.Добавить("        " + Фрагмент, СтрРазделить(СтрПолучитьСтроку(Фрагмент, 1), " ")[2]);
		// иначе сообщить этот фрагмент
		Иначе
			Сообщить("=====================================");
			Сообщить("Не обработан фрагмент " + Символы.ПС + М[А]);
			Сообщить("=====================================");
		КонецЕсли;
	КонецЦикла;
	
	Поля.СортироватьПоПредставлению();
	Конструкторы.СортироватьПоЗначению();
	Свойства.СортироватьПоПредставлению();
	Методы.СортироватьПоПредставлению();

	Стр = Голова;
	Для А = 0 По Поля.Количество() - 1 Цикл
		Стр = Стр + Символы.ПС + Поля.Получить(А).Значение;
	КонецЦикла;
	Для А = 0 По Конструкторы.Количество() - 1 Цикл
		Стр = Стр + Символы.ПС + Символы.ПС + Конструкторы.Получить(А).Значение;
	КонецЦикла;
	Если Свойства.Количество() > 0 Тогда
		Стр = Стр + Символы.ПС + Символы.ПС + "        //Свойства============================================================";
		Для А = 0 По Свойства.Количество() - 1 Цикл
			Стр = Стр + Символы.ПС + Символы.ПС + Свойства.Получить(А).Значение;
		КонецЦикла;
	КонецЕсли;
	Если Методы.Количество() > 0 Тогда
		Стр = Стр + Символы.ПС + Символы.ПС + "        //Методы============================================================";
		Для А = 0 По Методы.Количество() - 1 Цикл
			Стр = Стр + Символы.ПС + Символы.ПС + Методы.Получить(А).Значение;
		КонецЦикла;
	КонецЕсли;
	
	
	Возврат Стр;
КонецФункции//СортировкаКласса2Уровня(СтрКласса)

КаталогСправки = "C:\444\OSClientServerRu";// без слэша в конце
КаталогВыгрузки = "C:\444\ВыгрузкаКлиентСервера";// без слэша в конце
// КаталогВыгрузки = "\\UBUNTU SHARE\allaccess";// без слэша в конце

ВыгрузкаДляCS();
СортировкаКода();
