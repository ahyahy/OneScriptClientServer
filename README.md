# OneScriptClientServer
Библиотека создания клиент-серверных приложений для сценарного языка OneScript.

### Подробнее можно узнать на этом сайте

> <https://ahyahy.github.io/OneScriptClientServer/index.html>
> 

Основой проекта послужила [разработка автора Halil ibrahim Kalkan](https://www.codeproject.com/Articles/155282/TCP-Server-Client-Communication-Implementation). Согласно документации на разработку (далее следует перевод) - клиенты смогут вызывать методы серверного приложения через интерфейс точно так же, как обычные вызовы методов в том же приложении. ... То есть должна получиться двусторонняя, ориентированная на подключение и асинхронная коммуникационная библиотека. После того, как клиент подключается к серверу, они смогут обмениваться данными ... асинхронно до тех пор, пока клиент или сервер не закроют соединение.

Что в итоге получилось при создании библиотеки.  

Можно обмениваться сообщениями, содержащими текст, двоичные данные или базовые типы данных.  
Клиент может подключившись к серверу вызывать методы скрипта, содержащего код сервера, и соответственно методы подключенного к этому скрипту других сценариев. В ответе сервера клиент может получить какое либо значение базового типа данных, или двоичные данные. А это дает возможность написать приложение, состоящее из множества сценариев, запустить его на компьютере-сервере и подключаясь одновременно с компьютеров-клиентов по сети управлять работой приложения.  
Сервер многопоточный (каждый клиент в своем потоке живет), асинхронный (обработка клиентов происходит асинхронно).

Вот как это выглядит в коде.

Файл Сервер.os

```bsl
Перем КС, ПриложениеСервис1;

Процедура МояПроцедураНаСервереСПараметрами(Параметр1, Параметр2, Параметр3) Экспорт
	ПриложениеСервис1.Результат = "Сумма параметров = " + (Параметр1 + Параметр2 + Параметр3) + " (" + ТекущаяУниверсальнаяДатаВМиллисекундах() + ")";
КонецПроцедуры

ПодключитьВнешнююКомпоненту("ВашКаталогНаДиске\OneScriptClientServer.dll");
КС = Новый КлиентСерверДляОдноСкрипта();
ПриложениеСервис1 = КС.ПриложениеСервис(10085, ЭтотОбъект);

// Запустим сервер
ПриложениеСервис1.Начать();
Сообщить("ПриложениеСервис запущен");

// Запустим цикл обработки событий
Пока КС.Продолжать Цикл
	Попытка
		КС.ПолучитьСобытие().Выполнить();
	Исключение
		КС.ВызватьМетод(ЭтотОбъект, КС.АргументыСобытия.ИмяМетода, КС.АргументыСобытия.МассивПараметров);
	КонецПопытки;
КонецЦикла;
```
Файл Клиент.os

```bsl
ПодключитьВнешнююКомпоненту("ВашКаталогНаДиске\OneScriptClientServer.dll");
КС = Новый КлиентСерверДляОдноСкрипта();
ПриложениеКлиент1 = КС.ПриложениеКлиент(КС.TCPКонечнаяТочка("127.0.0.1", 10085));

ПриложениеКлиент1.Подключить();

МассивПараметров = Новый Массив();
МассивПараметров.Добавить(125.35);
МассивПараметров.Добавить(25);
МассивПараметров.Добавить(75);

Если ПриложениеКлиент1.СостояниеСоединения = КС.СостояниеСоединения.Подключен Тогда
	Сообщить("Результат на клиенте = " + ПриложениеКлиент1.ВыполнитьНаСервере("МояПроцедураНаСервереСПараметрами", МассивПараметров));
КонецЕсли;

Приостановить(2000);
ПриложениеКлиент1.Отключить();
```

### Замеры производительности

Для замера производительности на одном и том же компьютере были запущены сервер и клиент.  
За одну секунду сервер подключил 1700 клиентов (экземпляров класса TCPКлиент(TcpClient)).  
В другом замере клиент успешно послал 15000 коротких текстовых сообщений за одну секунду.  
Размер пересылаемого сообщения ограничен 128 мегабайтами.  
Взаимодействие с такими клиентами как браузер (клиентами, не являющимися экземплярами классов TCPКлиент(TcpClient) или СерверКлиент(ServerClient)) возможно с использованием свойства КлиентСерверДляОдноСкрипта.РежимСтороннегоКлиента (OneScriptClientServer.ThirdPartyClientMode). При этом производительность снизится. Подробнее об этом с примерами смотрите в документации.

### Запуск и примеры

На компьютере должен быть установлен OneScript. Тестирование проводил для версии 1.7.0.214. Скомпилированную библиотеку можно найти в [каталоге docs](https://github.com/ahyahy/OneScriptClientServer/tree/main/docs) этого проекта с именем OneScriptClientServerх_х_х_х.zip. Создание сервера и клиента подробно приведено в примерах в разделе `Документация` сайта библиотеки <https://ahyahy.github.io/OneScriptClientServer/doc.html>.
