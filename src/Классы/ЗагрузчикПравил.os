#Использовать logos

#Область ОписаниеПеременных

Перем Лог; // Переменная для хранения логов
Перем СтруктураURI; // Структура URI

Перем ПравилаJSON; // JSON-объект правил (инициируется 1 раз при получении правил с удаленного узла) 
Перем ОшибкиJSON; // JSON-объект ошибок правил

#КонецОбласти


#Область ПрограммныйИнтерфейс

// Возвращает инициализированный объект загрузчика правил
//
// Параметры:
//   ПолныйАдресРесурса - Строка - Полный URL адрес
//   Логин - Строка - (не обязательный) Basic Auth: имя учетной записи
//   Пароль - Строка - (не обязательный) Basic Auth: пароль учетной записи 
//   Токен - Строка - (не обязательный) Baerer Token: токен
//
// Возвращаемое значение:
//   ЗагрузчикПравил - инициализированный объект загрузчика правил
//
Функция Инициализировать(ПолныйАдресРесурса, Логин, Пароль, Токен) Экспорт
	ИнициализироватьСтруктуруURI();
	ЗаполнитьБазовыеПараметрыСтруктурыURI(ПолныйАдресРесурса);
	ЗаполнитьПараметрыBasicAuth(Логин, Пароль);
	ЗаполнитьПараметрыBaererToken(Токен);

	Возврат ЭтотОбъект;
КонецФункции

// Читает файл с удаленного узла
// * Выполняет REST-запрос (GET)
//
// Параметры:
//   НовоеИмяФайла - Строка - если заполнено, то имя читаемого файла будет изменено
//   НовыйПутьНаСервере - Строка - если заполнено, будет использоваться указанный путь для получения читаемого файла
//
// Возвращаемое значение:
//   ЗагрузчикПравил - объект загрузчика правил
//
Функция ПрочитатьФайлСУдаленногоУзла(НовоеИмяФайла = "", НовыйПутьНаСервере = "") Экспорт

	ПроверитьНаличиеСтруктурыURI();

	ИмяФайла = НовоеИмяФайла;
	Если Не ЗначениеЗаполнено(ИмяФайла) Тогда
		ИмяФайла = ФайловыеОперации.ПолучитьИмяФайла(СтруктураURI.ИмяФайлаНаСервере);
	КонецЕсли;

	НоваяСтруктураURI = СоздатьКопиюСтруктурыURI(СтруктураURI, НовыйПутьНаСервере, ИмяФайла);

	ПолныйАдрес = НоваяСтруктураURI.ПолныйАдресРесурса;
	ПутьНаСервере = НоваяСтруктураURI.ПутьНаСервере;

	Лог.Отладка("Чтение файла '%1' с удаленного узла %2", ИмяФайла, ПолныйАдрес);

	ИмяМетода = "GET";
	РезультатЗапроса = Неопределено;

	HTTPЗаголовки = ПодготовитьHTTPЗаголовоки();
	HTTPЗапрос = ПодготовитьHTTPЗапрос(ИмяМетода, HTTPЗаголовки, "", ПутьНаСервере);
	РезультатЗапроса = ВыполнитьHTTPЗапрос(HTTPЗапрос, ИмяМетода);
	
	КодСостояния = РезультатЗапроса.КодСостояния;

	Если ЭтоДопустимыйКодСостоянияРезультата(КодСостояния) Тогда
		Лог.Отладка("Файл '%1' успешно прочитан с удаленного узла %2 [%3]", ИмяФайла, ПолныйАдрес, КодСостояния);
	Иначе
		Лог.Отладка("Не удалось прочитать файл '%1' с удаленного узла %2 [%3]", ИмяФайла, ПолныйАдрес, КодСостояния);
	КонецЕсли;

	ПроанализироватьКодСостоянияРезультата(РезультатЗапроса);

	Возврат РезультатЗапроса;

КонецФункции

// Получает файл правил с удаленного узла
// * Используется в качестве "обертки" над функцией "ПрочитатьФайлСУдаленногоУзла" с определенными параметрами
//
// Возвращаемое значение:
//   ЗагрузчикПравил - объект загрузчика правил
//
Функция ПолучитьПравилаСУдаленногоУзла() Экспорт
	РезультатЗапроса = ПрочитатьФайлСУдаленногоУзла();
	Если ЭтоДопустимыйКодСостоянияРезультата(РезультатЗапроса.КодСостояния) Тогда
		ИнициализироватьОбъектПравилИзТелаРезультатаЗапроса(РезультатЗапроса);
	КонецЕсли;
	Возврат ЭтотОбъект;
КонецФункции

// Получает файл ошибок правил с удаленного узла
// * Используется в качестве "обертки" над функцией "ПрочитатьФайлСУдаленногоУзла" с определенными параметрами
//
// Возвращаемое значение:
//   ЗагрузчикПравил - объект загрузчика правил
//
Функция ПолучитьОшибкиПравилСУдаленногоУзла() Экспорт
	КонтекстОшибок = ПараметрыПриложения.ПолучитьКонтекстОшибок();
	ИмяФайла = ФайловыеОперации.ПолучитьИмяФайла(КонтекстОшибок);
	РезультатЗапроса = ПрочитатьФайлСУдаленногоУзла(ИмяФайла);
	Если ЭтоДопустимыйКодСостоянияРезультата(РезультатЗапроса.КодСостояния) Тогда
		ИнициализироватьОбъектОшибокПравилИзТелаРезультатаЗапроса(РезультатЗапроса);
	КонецЕсли;
	Возврат ЭтотОбъект;
КонецФункции

// Отправляет файл на удаленный узел
// * Выполняет REST-запрос (PUT/POST)
// * В основном применяется для отправки правил/ошибок правил в Nexus
//
// Параметры:
//   ПутьФайла - Строка - (обязательный) путь до файла, содержимое которого нужно отправить на удаленный узел
//   УникальноеИмяФайла - Булево - Если Истина, то на удаленном узле будет создан файл с уникальный именем
//   НовоеИмяФайла - Строка - новое имя файла
//   НовыйПутьНаСервере - Строка - Специфический путь на сервере
//
// Возвращаемое значение:
//   HTTPРезультат - результат выполнения запроса
//
Функция ОтправитьФайлНаУдаленныйУзел(
	ПутьФайла, УникальноеИмяФайла = Ложь, НовоеИмяФайла = "", НовыйПутьНаСервере = "") Экспорт

	ПроверитьНаличиеСтруктурыURI();
	
	ИмяФайла = НовоеИмяФайла;
	Если Не ЗначениеЗаполнено(ИмяФайла) Тогда
		ИмяФайла = ФайловыеОперации.ПолучитьИмяФайла(ПутьФайла);
	КонецЕсли;

	НоваяСтруктураURI = СоздатьКопиюСтруктурыURI(СтруктураURI, НовыйПутьНаСервере, ИмяФайла);

	ТелоЗапроса = ФайловыеОперации.ПрочитатьФайл(ПутьФайла);

	Если НЕ ЗначениеЗаполнено(ТелоЗапроса) Тогда
		ВызватьИсключение СтрШаблон("Невозможно выполнить отправку пустого содержимого файла '%1'", ПутьФайла);
	КонецЕсли;

	ИмяМетода = "PUT";
	РезультатЗапроса = Неопределено;

	Если УникальноеИмяФайла Тогда
		ИмяМетода = "POST";
		УстановитьУникальноеИмяФайлаПравил();
	КонецЕсли;

	ПутьНаСервере = НоваяСтруктураURI.ПутьНаСервере;
	Если ЗначениеЗаполнено(НовыйПутьНаСервере) Тогда
		ПутьНаСервере = НовыйПутьНаСервере;
	КонецЕсли;

	ПолныйАдрес = НоваяСтруктураURI.ПолныйАдресРесурса;

	HTTPЗаголовки = ПодготовитьHTTPЗаголовоки();
	HTTPЗапрос = ПодготовитьHTTPЗапрос(ИмяМетода, HTTPЗаголовки, ТелоЗапроса, ПутьНаСервере);
	
	РезультатЗапроса = ВыполнитьHTTPЗапрос(HTTPЗапрос, ИмяМетода);
	КодСостояния = РезультатЗапроса.КодСостояния;
	
	ПроанализироватьКодСостоянияРезультата(РезультатЗапроса);
	
	Если ЭтоДопустимыйКодСостоянияРезультата(КодСостояния) Тогда
		Лог.Информация("Файл '%1' отправлен на удаленный узел %2 [%3]", ИмяФайла, ПолныйАдрес, КодСостояния);
	Иначе
		Лог.Отладка("Не удалось отправить файл '%1' с удаленного узла %2 [%3]", ИмяФайла, ПолныйАдрес, КодСостояния);
	КонецЕсли;
	
	
	Возврат РезультатЗапроса;

КонецФункции

// Отправляет файл правил на удаленный узел
// * Используется в качестве "обертки" над функцией "ОтправитьФайлНаУдаленныйУзел" с определенными параметрами
//
// Параметры:
//   ОтправитьПриНаличииОтличий - Булево - Если "Истина",
//   отправка будет выполнена только при наличии отличий правил контекста и правил полученных с удаленного узла
//   (по-умолчанию: Ложь)
//
// Возвращаемое значение:
//   ЗагрузчикПравил - объект загрузчика правил
//
Функция ОтправитьПравилаНаУдаленныйУзел(ОтправитьПриНаличииОтличий = Ложь) Экспорт
	
	ПроверитьНаличиеСтруктурыURI();

	Если ОтправитьПриНаличииОтличий Тогда
		
		Если НайтиОтличияПравилСУдаленногоУзлаИПравилКонтекста() Тогда
			Лог.Информация("Требуется обновление правил на удаленном узле");
			ОтправитьПравилаНаУдаленныйУзел();
		Иначе
			Лог.Информация("Обновление файла правил на удаленном узле не требуется");
		КонецЕсли;

		Возврат ЭтотОбъект;

	КонецЕсли;
 
	Контекст = ПараметрыПриложения.ПолучитьКонтекст();
	
	// Обработка результата запроса не требуется
	РезультатЗапроса = ОтправитьФайлНаУдаленныйУзел(Контекст);

	Возврат ЭтотОбъект;

КонецФункции

// Отправляет файл ошибок правил на удаленный узел
// * Используется в качестве "обертки" над функцией "ОтправитьФайлНаУдаленныйУзел" с определенными параметрами
//
// Параметры:
//   ОтправитьПриНаличииОтличий - Булево - Если "Истина",
//   отправка будет выполнена только при наличии отличий правил контекста и правил полученных с удаленного узла
//   (по-умолчанию: Ложь)
//
// Возвращаемое значение:
//   ЗагрузчикПравил - объект загрузчика правил
//
Функция ОтправитьОшибкиПравилНаУдаленныйУзел(ОтправитьПриНаличииОтличий = Ложь) Экспорт
	
	Если Не ПараметрыПриложения.ПолучитьРежимЗаписиОшибокПравил() Тогда
		Возврат ЭтотОбъект;
	КонецЕсли;

	ПроверитьНаличиеСтруктурыURI();

	Если ОтправитьПриНаличииОтличий Тогда
		
		Если НайтиОтличияОшибокПравилСУдаленногоУзлаИОшибокПравилКонтекста() Тогда
			Лог.Информация("Требуется обновление файла ошибок правил на удаленном узле");
			ОтправитьОшибкиПравилНаУдаленныйУзел();
		Иначе
			Лог.Информация("Обновление файла ошибок правил на удаленном узле не требуется");
		КонецЕсли;

		Возврат ЭтотОбъект;

	КонецЕсли;

	КонтекстОшибок = ПараметрыПриложения.ПолучитьКонтекстОшибок();
	
	// Обработка результата запроса не требуется
	РезультатЗапроса = ОтправитьФайлНаУдаленныйУзел(КонтекстОшибок, Ложь);

	Возврат ЭтотОбъект;

КонецФункции

#КонецОбласти


#Область СлужебныйПрограммныйИнтерфейс

// Устанавливает локальный контекст сохранения правил
//
// Параметры:
//   ПроверитьКонтекст - Булево - Если Истина - будет выполнена проверка существования контекста
//
// Возвращаемое значение:
//   ЗагрузчикПравил - объект загрузчика правил
//
Функция УстановитьЛокальныйКонтекстСохранения(ПроверитьКонтекст = Истина) Экспорт
	ПараметрыПриложения.УстановитьКонтекстСохранения("");
	
	Если ПроверитьКонтекст Тогда
		ПроверитьНаличиеКонтекста(ПараметрыПриложения.ПолучитьКонтекст());
	КонецЕсли;

	Возврат ЭтотОбъект;
КонецФункции

// Устанавливает локальный контекст сохранения ошибок
//
// Параметры:
//   ПроверитьКонтекстОшибок - Булево - Если Истина - будет выполнена проверка существования контекста
//
// Возвращаемое значение:
//   ЗагрузчикПравил - объект загрузчика правил
//
Функция УстановитьЛокальныйКонтекстСохраненияОшибок(ПроверитьКонтекстОшибок = Истина) Экспорт
	
	ПараметрыПриложения.УстановитьКонтекстСохраненияОшибок("");
	
	Если ПроверитьКонтекстОшибок Тогда
		КонтекстОшибок = ПараметрыПриложения.ПолучитьКонтекстОшибок();
		КорректныйПутьКонтекстаОшибок = ФайловыеОперации.ПолучитьКорректныйПутьФайла(КонтекстОшибок);
		Если Не ФайловыеОперации.ПроверитьСуществованиеФайла(КорректныйПутьКонтекстаОшибок) Тогда
			ФайловыеОперации.ЗаписатьОбъект(КорректныйПутьКонтекстаОшибок, Новый Массив);
			Лог.Информация("Создан пустой файл контекста ошибок: %1", КорректныйПутьКонтекстаОшибок);
		КонецЕсли;
		ПроверитьНаличиеКонтекста(ПараметрыПриложения.ПолучитьКонтекстОшибок());
	КонецЕсли;
	
	Возврат ЭтотОбъект;
КонецФункции

// Проверяет наличие (файла) контекста
// * В случае отсутствия файла по пути контекста - выполняется вызов исключения.
//
// Параметры:
//   Контекст - Строка - путь до файла контекста
//
// Возвращаемое значение:
//   ЗагрузчикПравил - объект загрузчика правил
//
Функция ПроверитьНаличиеКонтекста(Контекст) Экспорт
	КорректныйПутьФайлаКонтекста = ФайловыеОперации.ПолучитьКорректныйПутьФайла(Контекст);
	Если Не ФайловыеОперации.ПроверитьСуществованиеФайла(КорректныйПутьФайлаКонтекста) Тогда
		Лог.Ошибка("Отсутствует файл контекста сохранения %1", КорректныйПутьФайлаКонтекста);
		ВызватьИсключение("Ошибка получения файла контекста");
	КонецЕсли;
	Возврат ЭтотОбъект;
КонецФункции

// Выполняет отправку файла правил на удаленный узел 
// по текущему контексту,, при условии, что на удаленном узле такого файла нет.
//
// Возвращаемое значение:
//   ЗагрузчикПравил - объект загрузчика правил
//
Функция ЗагрузитьПравилаИзКонтекстаНаУдаленныйУзелПриОтсутствии() Экспорт
	Лог.Отладка("Проверка наличия файла правил на удаленном узле");
	РезультатЗапроса = ПрочитатьФайлСУдаленногоУзла();
	Если РезультатЗапроса.КодСостояния <> 200 Тогда
		Лог.Отладка("Необходимо отправить файл правил на удаленный узел");
		ОтправитьПравилаНаУдаленныйУзел();
	КонецЕсли;
	Возврат ЭтотОбъект;
КонецФункции

// Выполняет отправку файла ошибок правил на удаленный узел
// по текущему контексту ошибок, при условии, что на удаленном узле такого файла нет.
//
// Возвращаемое значение:
//   ЗагрузчикПравил - объект загрузчика правил
//
Функция ЗагрузитьОшибкиПравилИзКонтекстаНаУдаленныйУзелПриОтсутствии() Экспорт
	Лог.Отладка("Проверка наличия файла ошибок правил на удаленном узле");
	КонтекстОшибок = ПараметрыПриложения.ПолучитьКонтекстОшибок();
	ИмяФайла = ФайловыеОперации.ПолучитьИмяФайла(КонтекстОшибок);
	РезультатЗапросаОшибок = ПрочитатьФайлСУдаленногоУзла(ИмяФайла);
	Если РезультатЗапросаОшибок.КодСостояния <> 200 Тогда
		Лог.Отладка("Необходимо отправить файл ошибок правил на удаленный узел");
		ОтправитьОшибкиПравилНаУдаленныйУзел();
	КонецЕсли;
	Возврат ЭтотОбъект;
	
КонецФункции

// Переопределяет контекст сохранения
//
// Параметры:
//   ПутьФайла - Строка - путь до файла контекста
//
// Возвращаемое значение:
//   ЗагрузчикПравил - объект загрузчика правил
//
Функция ПереопределитьКонтекстСохранения(ПутьФайла = "") Экспорт
	НовыйКонтекст = ПолучитьПереопределенныйКонтекст(ПутьФайла);
	Лог.Отладка("Переопределеяем контекст сохранения");
	ПараметрыПриложения.УстановитьКонтекстСохранения(НовыйКонтекст);
	Возврат ЭтотОбъект;
КонецФункции

// Переопределяет контекст сохранения ошибок
//
// Параметры:
//   ПутьФайла - Строка - путь до файла контекста ошибок 
//
// Возвращаемое значение:
//   ЗагрузчикПравил - объект загрузчика правил
//
Функция ПереопределитьКонтекстСохраненияОшибок(ПутьФайла = "") Экспорт
	НовыйКонтекст = ПолучитьПереопределенныйКонтекст(ПутьФайла);
	Лог.Отладка("Переопределеяем контекст сохранения ошибок");
	ПараметрыПриложения.УстановитьКонтекстСохраненияОшибок(НовыйКонтекст);
	Возврат ЭтотОбъект;
КонецФункции

// Записывает правила из результата запроса в файл
//
// Возвращаемое значение:
//   ЗагрузчикПравил - объект загрузчика правил
//
Функция ЗаписатьПравилаВФайл() Экспорт
	ПутьФайла = ПараметрыПриложения.ПолучитьКонтекст();
	ФайловыеОперации.СоздатьСтруктуруКаталоговФайла(ПутьФайла, Истина);
	ФайловыеОперации.ЗаписатьОбъект(ПутьФайла, ПравилаJSON);
	Лог.Отладка("Файл правил записан по пути контекста %1", ПутьФайла);
	Возврат ЭтотОбъект;
КонецФункции

// Записывает ошибки правил из результата запроса в файл
//
// Возвращаемое значение:
//   ЗагрузчикПравил - объект загрузчика правил
//
Функция ЗаписатьОшибкиПравилВФайл() Экспорт
	ПутьФайла = ПараметрыПриложения.ПолучитьКонтекстОшибок();
	ФайловыеОперации.СоздатьСтруктуруКаталоговФайла(ПутьФайла, Истина);
	ФайловыеОперации.ЗаписатьОбъект(ПутьФайла, ОшибкиJSON);
	Лог.Отладка("Файл ошибок правил записан по пути контекста %1", ПутьФайла);
	Возврат ЭтотОбъект;
КонецФункции

Функция НайтиОтличияОшибокПравилСУдаленногоУзлаИОшибокПравилКонтекста() Экспорт
	
	КонтекстОшибокПравил = ПараметрыПриложения.ПолучитьКонтекстОшибок();
	ПутьФайлКонтекстаОшибокПравил = ФайловыеОперации.ПолучитьКорректныйПутьФайла(КонтекстОшибокПравил);
	ТекущийОбъектОшибокПравил = ФайловыеОперации.ПрочитатьОбъект(ПутьФайлКонтекстаОшибокПравил, Ложь);
	ОшибкиПравилУУ = ОшибкиJSON;
	ОшибкиПравилК = ТекущийОбъектОшибокПравил;

	МассивОтличий = ПолучитьОтличияДвухМассивоСтруктурПоКлючу(ОшибкиПравилУУ, ОшибкиПравилК, "ИсходнаяСтрока");
	
	Для Каждого Элемент Из МассивОтличий Цикл
		КодПравила = Элемент.КодПравила;
		СтрокаОшибки = Элемент.ИсходнаяСтрока;
		Лог.Отладка("Найдена ошибка в строке: %2%1(код правила: '%3')", Символы.ПС, СтрокаОшибки, КодПравила);
	КонецЦикла;
	
	Возврат МассивОтличий.Количество() > 0;
КонецФункции

// Возвращает результат проверки отличия правил контекста и правил,
// полученных с удаленного узла
//
// Возвращаемое значение:
//    Булево - Истина, если найдены отличия по первому совпадению
Функция НайтиОтличияПравилСУдаленногоУзлаИПравилКонтекста() Экспорт

	КонтекстПравил = ПараметрыПриложения.ПолучитьКонтекст();
	ПутьФайлКонтекстаПравил = ФайловыеОперации.ПолучитьКорректныйПутьФайла(КонтекстПравил);
	ТекущийОбъектПравил = ФайловыеОперации.ПрочитатьОбъект(ПутьФайлКонтекстаПравил, Ложь);
	ПравилаУУ = ПравилаJSON.Rules;
	ПравилаК = ТекущийОбъектПравил.Rules;

	МассивОтличий = ПолучитьОтличияДвухМассивоСтруктурПоКлючу(ПравилаУУ, ПравилаК, "Code");
	
	Для Каждого Элемент Из МассивОтличий Цикл
		Лог.Отладка("Найден отсутствующий код правил: '%1'", Элемент.Code);
	КонецЦикла;
	
	Возврат МассивОтличий.Количество() > 0;

КонецФункции


#КонецОбласти




#Область СлужебныеПроцедурыИФункции



#Область ЗаполнениеПараметровСтруктурыURI

// Инициализирует основные ключи для параметров структуры URI
//
// Перечень ключей структуры:
// * Cтруктура:
//    * * Схема - Строка - http/https 
//    * * Логин - Строка - имя пользователя
//    * * Пароль - Строка - пароль пользователя
//    * * Токен - Строка - (не реализовано) Baerer-токен
//    * * ИмяСервера - Строка - имя сервера (базовый URL)
//    * * Хост - Строка - имя удаленного хоста
//    * * Порт - Строка - порт удаленного хоста
//    * * ПутьНаСервере - Строка - путь до ресурса на удаленном хосте
//    * * ИмяФайлаНаСервере - Строка - имя ресурса (файла) на удаленном хосте
//    * * ПолныйАдресРесурса - Строка - полный адрес с учетом пути до ресурса
//
// Возвращаемое значение:
//   ЗагрузчикПравил - объект загрузчика правил
//
Функция ИнициализироватьСтруктуруURI()
	СтруктураURI = Новый Структура;
	СтруктураURI.Вставить("Схема", "");
	СтруктураURI.Вставить("Логин", "");
	СтруктураURI.Вставить("Пароль", "");
	СтруктураURI.Вставить("Токен", "");
	СтруктураURI.Вставить("ИмяСервера", "");
	СтруктураURI.Вставить("Хост", "");
	СтруктураURI.Вставить("Порт", "");
	СтруктураURI.Вставить("ПутьНаСервере", "");
	СтруктураURI.Вставить("ИмяФайлаНаСервере", "");
	СтруктураURI.Вставить("ПолныйАдресРесурса", "");
	Возврат ЭтотОбъект;
КонецФункции

// Выполняет заполнение инициализированной структуры с параметрами URI
//
// Параметры:
//   ПолныйАдресРесурса - Строка - полный путь (ссылка на удаленный файл)
//
// Возвращаемое значение:
//   ЗагрузчикПравил - объект загрузчика правил
//
Функция ЗаполнитьБазовыеПараметрыСтруктурыURI(ПолныйАдресРесурса)
	
	СтрокаURI = СокрЛП(ПолныйАдресРесурса);
	
	// схема
	Схема = "";
	Позиция = СтрНайти(СтрокаURI, "://");
	Если Позиция > 0 Тогда
		Схема = НРег(Лев(СтрокаURI, Позиция - 1));
		СтрокаURI = Сред(СтрокаURI, Позиция + 3);
	КонецЕсли;

	// строка соединения, путь и имя файла на сервере
	СтрокаСоединения = СтрокаURI;
	ПутьНаСервере = "";
	ИмяФайлаНаСервере = "";
	Позиция = СтрНайти(СтрокаСоединения, "/");
	Если Позиция > 0 Тогда
		ПутьНаСервере = Сред(СтрокаСоединения, Позиция + 1);
		СтрокаСоединения = Лев(СтрокаСоединения, Позиция - 1);
		Позиция = СтрНайти(ПутьНаСервере, "/", НаправлениеПоиска.СКонца);
		ИмяФайлаНаСервере = ?(Позиция > 0, Прав(ПутьНаСервере, СтрДлина(ПутьНаСервере) - Позиция), ПутьНаСервере);
	КонецЕсли;
		
	// информация пользователя и имя сервера
	СтрокаАвторизации = "";
	ИмяСервера = СтрокаСоединения;
	Позиция = СтрНайти(СтрокаСоединения, "@");
	Если Позиция > 0 Тогда
		СтрокаАвторизации = Лев(СтрокаСоединения, Позиция - 1);
		ИмяСервера = Сред(СтрокаСоединения, Позиция + 1);
	КонецЕсли;
	
	// логин и пароль
	Логин = СтрокаАвторизации;
	Пароль = "";
	Позиция = СтрНайти(СтрокаАвторизации, ":");
	Если Позиция > 0 Тогда
		Логин = Лев(СтрокаАвторизации, Позиция - 1);
		Пароль = Сред(СтрокаАвторизации, Позиция + 1);
	КонецЕсли;
	
	// хост и порт
	Хост = ИмяСервера;
	Порт = "";
	
	Позиция = СтрНайти(ИмяСервера, ":");
	Если Позиция > 0 Тогда
		Хост = Лев(ИмяСервера, Позиция - 1);
		Порт = Сред(ИмяСервера, Позиция + 1);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СтруктураURI) Тогда
		ИнициализироватьСтруктуруURI();
	КонецЕсли;

	СтруктураURI.Схема = Схема;
	
	Если ЗначениеЗаполнено(Логин) Тогда
		СтруктураURI.Логин = Логин;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Пароль) Тогда
		СтруктураURI.Пароль = Пароль;
	КонецЕсли;

	СтруктураURI.ИмяСервера = ИмяСервера;
	СтруктураURI.Хост = Хост;
	СтруктураURI.Порт = ?(Порт <> "", Число(Порт), Неопределено);
	СтруктураURI.ПутьНаСервере = ПутьНаСервере;
	СтруктураURI.ИмяФайлаНаСервере = ИмяФайлаНаСервере;
	СтруктураURI.ПолныйАдресРесурса = ПолныйАдресРесурса;
	
	Возврат ЭтотОбъект;

КонецФункции

// Выполняет заполнение учетных данных (логин, пароль) инициализированной структуры с параметрами URI
//
// Параметры:
//   Логин - Строка - имя пользователя
//   Пароль - Строка - пароль пользователя
//
Процедура ЗаполнитьПараметрыBasicAuth(Логин, Пароль)
	
	Если ЗначениеЗаполнено(Логин) Тогда
		СтруктураURI.Логин = Логин;
	КонецЕсли;

	Если ЗначениеЗаполнено(Пароль) Тогда
		СтруктураURI.Пароль = Пароль;
	КонецЕсли;

КонецПроцедуры

// Выполняет заполнение токена инициализированной структуры с параметрами URI
//
// Параметры:
//   Токен - Строка - токен пользователя
//
Процедура ЗаполнитьПараметрыBaererToken(Токен)
	
	Если ЗначениеЗаполнено(Токен) Тогда
		СтруктураURI.Токен = Токен;
	КонецЕсли;

КонецПроцедуры

#КонецОбласти



#Область HTTP_RestAPI

// Создает новый экземпляр класса HTTPСоединение
// * В качестве параметров по-умолчанию используется:
// * * Таймаут = 60 сек
//
// Возвращаемое значение:
//   HTTPСоединение - экземпляр класса HTTPСоединение
//
Функция ПодготовитьHTTPСоединение()
	
	SSL = Неопределено;

	Логин = ?(ЗначениеЗаполнено(СтруктураURI.Логин), СтруктураURI.Логин, Неопределено);
	Пароль = ?(ЗначениеЗаполнено(СтруктураURI.Пароль), СтруктураURI.Пароль, Неопределено);

	HTTPСоединение = Новый HTTPСоединение(СтруктураURI.Хост, СтруктураURI.Порт, Логин, Пароль, , 60, SSL);

	Возврат HTTPСоединение;

КонецФункции

// Создает коллекцию заголовков для HTTP запроса
//
// Возвращаемое значение:
//   Соответствие - коллекция заголовков
//
Функция ПодготовитьHTTPЗаголовоки()

	Логин = СтруктураURI.Логин;
	Пароль = СтруктураURI.Пароль;
	Токен = СтруктураURI.Токен;

	HTTPЗаголовки = Новый Соответствие;
	HTTPЗаголовки.Вставить("User-Agent", "curl/7.79.1");
	HTTPЗаголовки.Вставить("accept", "application/json; charset=utf-8");
	
	ЭтоБазоваяАутентификация = ЗначениеЗаполнено(Логин) И ЗначениеЗаполнено(Пароль);
	ЭтоТокенАутентификация = НЕ ЭтоБазоваяАутентификация И ЗначениеЗаполнено(Токен);

	СтрокаАвторизации = Неопределено;
	Если ЭтоБазоваяАутентификация Тогда
		ДвоичныеДанные = ПолучитьДвоичныеДанныеИзСтроки(СтрШаблон("%1:%2", Логин, Пароль), КодировкаТекста.UTF8, Ложь);
		СтрокаАвторизации = ПолучитьBase64СтрокуИзДвоичныхДанных(ДвоичныеДанные);
		Лог.Отладка("Аутентификация по логину и паролю");
		HTTPЗаголовки.Вставить("Authorization", "Basic " + СтрокаАвторизации); 
	ИначеЕсли ЭтоТокенАутентификация Тогда
		Лог.Отладка("Аутентификация по токену");
		HTTPЗаголовки.Вставить("Authorization", "Bearer " + Токен); 
	Иначе
		Лог.Отладка("Анонимная аутентификация");
	КонецЕсли;

	Возврат HTTPЗаголовки;

КонецФункции

// Создает новый экземпляр класса HTTPЗапрос
// * Если используются методы отличные от DELETE и GET, то в запрос добавляется строка с телом запроса
//
// Параметры:
//   ИмяМетода - Строка - имя REST-метода
//   HTTPЗаголовки - Соответствие, Неопределено - коллекция заголовков
//   СтрокаТелаЗапроса - Строка - Тело запроса
//   НовыйПутьНаСервере - Строка - Специфический путь на сервере
//
// Возвращаемое значение:
//   HTTPЗапрос - экземпляр класса HTTPЗапрос
//
Функция ПодготовитьHTTPЗапрос(ИмяМетода, HTTPЗаголовки = Неопределено, СтрокаТелаЗапроса = "", НовыйПутьНаСервере = "")
	
	ПутьНаСервере = СтруктураURI.ПутьНаСервере; // Путь на сервере по-умолчанию

	Если ЗначениеЗаполнено(СокрЛП(НовыйПутьНаСервере)) Тогда
		ПутьНаСервере = НовыйПутьНаСервере;
	КонецЕсли;
	
	HTTPЗапрос = Новый HTTPЗапрос(ПутьНаСервере, HTTPЗаголовки);
	Если ИмяМетода <> "DELETE" И ИмяМетода <> "GET" Тогда
		HTTPЗапрос.УстановитьТелоИзСтроки(СтрокаТелаЗапроса);
	КонецЕсли;
	Возврат HTTPЗапрос;
КонецФункции

// Выполняет HTTPЗапрос
//
// Параметры:
//   HTTPЗапрос - HTTPЗапрос - запрос, который нужно выполнить
//   ИмяМетода - Строка - имя REST-метода
//
// Возвращаемое значение:
//   HTTPРезультат - результат выполнения HTTPЗапроса
//
Функция ВыполнитьHTTPЗапрос(HTTPЗапрос, ИмяМетода)
	РезультатЗапроса = Неопределено;
	HTTPСоединение = ПодготовитьHTTPСоединение();
	Попытка
		РезультатЗапроса = HTTPСоединение.ВызватьHTTPМетод(ИмяМетода, HTTPЗапрос);
		ТелоРезультата = РезультатЗапроса.ПолучитьТелоКакСтроку(КодировкаТекста.UTF8);
		Лог.Отладка(СтрШаблон("Результат HTTP запроса:%1%2", Символы.ПС, ТелоРезультата));
	Исключение
		Лог.КритичнаяОшибка(ОписаниеОшибки());
		ВызватьИсключение;
	КонецПопытки; 
	Возврат РезультатЗапроса;
КонецФункции

// Анализирует типы кодов состояния от HTTPРезультата
// и выводит информацию в лог Предупреждений/Отладки/Ошибок
//
// Параметры:
//   РезультатЗапроса - HTTPРезультат - результат запроса
//
// Возвращаемое значение:
//   ЗагрузчикПравил - объект загрузчика правил
//
Функция ПроанализироватьКодСостоянияРезультата(РезультатЗапроса)

	КодСостояния = РезультатЗапроса.КодСостояния;

	ОбработатьКодСостоянияОшибкиКлиента(КодСостояния);
	ОбработатьКодСостоянияОшибкиСервера(КодСостояния);
	ОбработатьКодСостоянияПеренаправлений(КодСостояния);
	ОбработатьКодСостоянияУспешныхОтветов(КодСостояния);
	ОбработатьКодСостоянияИнформационныхСообщений(КодСостояния);

	Возврат ЭтотОбъект;

КонецФункции

// Получает тело результата запроса
//
// Параметры:
//   РезультатЗапроса - HTTPРезультат - результат выполнения запроса
//
// Возвращаемое значение:
//   Строка - тело результата запроса
//
Функция ПолучитьТелоРезультатаЗапроса(РезультатЗапроса)
	
	Если Не ЗначениеЗаполнено(РезультатЗапроса) Тогда
		Лог.Ошибка("Отсутствует результат запроса. Дальнейшая работа невозможна!");
		ВызватьИсключение("Результат запроса отсутствует или пустой!");
	КонецЕсли;

	ТелоЗапроса = РезультатЗапроса.ПолучитьТелоКакСтроку(КодировкаТекста.UTF8);
	Если Не ЗначениеЗаполнено(ТелоЗапроса) Тогда
		Лог.Предупреждение("Отсутствует тело запроса");
	КонецЕсли;

	Возврат ТелоЗапроса;

КонецФункции

// Инициалзирует переменную ПравилаJSON
// В эту переменную записывается объекта JSON из тела результата запроса
// * функция заполняет значение, только если оно отсутствует в переменной
//
// Параметры:
//   РезультатЗапроса - HTTPРезультат - результат запроса
//
// Возвращаемое значение:
//   ЗагрузчикПравил - объект загрузчика правил
//
Функция ИнициализироватьОбъектПравилИзТелаРезультатаЗапроса(РезультатЗапроса)
	Если Не ЗначениеЗаполнено(ПравилаJSON) Тогда
		ТелоЗапроса = ПолучитьТелоРезультатаЗапроса(РезультатЗапроса);
		Если ЗначениеЗаполнено(ТелоЗапроса) Тогда
			ПравилаJSON = ФайловыеОперации.ПолучитьОбъектИзСтрокиJSON(ТелоЗапроса);
		КонецЕсли;
	КонецЕсли;
	Возврат ЭтотОбъект;
КонецФункции

// Инициалзирует переменную ОшибкиJSON
// В эту переменную выполняется запись объекта JSON из тела результата запроса
// * функция заполняет значение, только если оно отсутствует в переменной
//
// Параметры:
//   РезультатЗапроса - HTTPРезультат - результат запроса
//
// Возвращаемое значение:
//   ЗагрузчикПравил - объект загрузчика правил
//
Функция ИнициализироватьОбъектОшибокПравилИзТелаРезультатаЗапроса(РезультатЗапроса)
	Если Не ЗначениеЗаполнено(ОшибкиJSON) Тогда
		ТелоЗапроса = ПолучитьТелоРезультатаЗапроса(РезультатЗапроса);
		Если ЗначениеЗаполнено(ТелоЗапроса) Тогда
			ОшибкиJSON = ФайловыеОперации.ПолучитьОбъектИзСтрокиJSON(ТелоЗапроса);
		КонецЕсли;
	КонецЕсли;
	Возврат ЭтотОбъект;
КонецФункции

// Проверяет соответствие кода результата перечню допустимых кодов
//
// Параметры:
//   КодСостояния - Целом - код состояния, который нужно проверить 
//
// Возвращаемое значение:
//   Булево - Если Истина, код состояния прошёл проверку по допустимым кодам
//
Функция ЭтоДопустимыйКодСостоянияРезультата(КодСостояния)
	Если Не ТипЗнч(КодСостояния) = Тип("Число") Тогда
		Возврат Ложь;
	КонецЕсли;

	ДопустимыеКодыСостояния = Новый Массив;
	ДопустимыеКодыСостояния.Добавить(200);
	ДопустимыеКодыСостояния.Добавить(201);
	ДопустимыеКодыСостояния.Добавить(202);
	
	Возврат Не ДопустимыеКодыСостояния.Найти(КодСостояния) = Неопределено;

КонецФункции

#КонецОбласти



#Область HTTP_RestStatusCodes

// Сообщает ошибку по коду состояния
// * коды состояния 100-199 (информационные ответы)
//
// Параметры:
//   КодСостояния - Число - Код состояния результата запроса
//
Процедура ОбработатьКодСостоянияИнформационныхСообщений(КодСостояния)
	Если КодСостояния >= 100 И КодСостояния < 200 Тогда 
		Лог.Отладка("Код состояния больше 1ХХ, информационный ответ. Код состояния: " + КодСостояния);
	КонецЕсли; 
КонецПроцедуры

// Сообщает ошибку по коду состояния
// * коды состояния 200-299 (успешные ответы)
//
// Параметры:
//   КодСостояния - Число - Код состояния результата запроса
//
Процедура ОбработатьКодСостоянияУспешныхОтветов(КодСостояния)
	Если КодСостояния >= 200 И КодСостояния < 300 Тогда 
		Лог.Отладка("Код состояния больше 2ХХ, успешный ответ. Код состояния: " + КодСостояния);
	КонецЕсли; 
КонецПроцедуры

// Сообщает ошибку по коду состояния
// * коды состояния 300-399 (перенаправление)
//
// Параметры:
//   КодСостояния - Число - Код состояния результата запроса
//
Процедура ОбработатьКодСостоянияПеренаправлений(КодСостояния)
	Если КодСостояния >= 300 И КодСостояния < 400  Тогда
		Лог.Ошибка("Код состояния больше 3XX, Перенаправление. Код состояния: " + КодСостояния);
	КонецЕсли;
КонецПроцедуры

// Сообщает ошибку по коду состояния
// * коды состояния 400-499 (ошибки клиента)
//
// Параметры:
//   КодСостояния - Число - Код состояния результата запроса
//
Процедура ОбработатьКодСостоянияОшибкиКлиента(КодСостояния)
	Если КодСостояния >= 400 И КодСостояния < 500  Тогда
		Лог.Ошибка("Код состояния больше 4XX, ошибка клиента. Код состояния: " + КодСостояния);
	КонецЕсли;
КонецПроцедуры

// Сообщает ошибку по коду состояния
// * коды состояния 500-599 (ошибки сервера)
//
// Параметры:
//   КодСостояния - Число - Код состояния результата запроса
//
Процедура ОбработатьКодСостоянияОшибкиСервера(КодСостояния)
	Если КодСостояния >= 500 И КодСостояния < 600  Тогда
		Лог.Ошибка("Код состояния больше 5XX, ошибка сервера. Код состояния: " + КодСостояния);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти



#Область Специфические

// Переопределяет путь файла контекста
// * Используется для того, чтобы изменения файла контекста выполнялись по отдельному пути
//
// Параметры:
//   ПереопределяемыйКонтекст - Строка - путь до файла контекста
//
// Возвращаемое значение:
//   Строка - переопределенный путь до файла контекст
//
Функция ПолучитьПереопределенныйКонтекст(ПереопределяемыйКонтекст)
	КорректныйПутьКонтекста = ФайловыеОперации.ПолучитьКорректныйПутьФайла(ПереопределяемыйКонтекст);
	ПутьУказан = ЗначениеЗаполнено(КорректныйПутьКонтекста);
	ИмяФайла = ФайловыеОперации.ПолучитьИмяФайла(КорректныйПутьКонтекста);
	ПутьКонтекстаПоУмолчанию = СтрШаблон("./.rules/%1", ИмяФайла);
	ПереопределенныйКонтекст = ?(ПутьУказан, КорректныйПутьКонтекста, ПутьКонтекстаПоУмолчанию);
	Возврат ПереопределенныйКонтекст;
КонецФункции

// Создает копию структуры URI с новыми параметрами
//
// Параметры:
//   СтруктураURI - Структура - структура параметров URI
//   НовыйПутьНаСервере - Строка - новый путь на сервере (за исключением имени конечного файла)
//   НовоеИмяФайла - Строка - новое имя файла
//
// Возвращаемое значение:
//   Структура - Новая структура URI
//
Функция СоздатьКопиюСтруктурыURI(СтруктураURI, НовыйПутьНаСервере = "", НовоеИмяФайла = "")
	
	НоваяСтруктураURI = СкопироватьСтруктуру(СтруктураURI);

	ИзменитьИмяФайла = ЗначениеЗаполнено(СокрЛП(НовоеИмяФайла));
	ИзменитьПутьНаСервере = ЗначениеЗаполнено(СокрЛП(НовыйПутьНаСервере));

	ИмяФайлаНаСервере = НоваяСтруктураURI.ИмяФайлаНаСервере;
	ПутьНаСервере = НоваяСтруктураURI.ПутьНаСервере;

	НоваяСтруктураURI.ИмяФайлаНаСервере = НовоеИмяФайла;
	
	Для Каждого ПараметрURI из НоваяСтруктураURI Цикл
		Ключ = ПараметрURI.Ключ;
		Значение = ПараметрURI.Значение;
		// 1. Меняем путь
		Если ИзменитьПутьНаСервере И СтрНайти(Значение, ПутьНаСервере, НаправлениеПоиска.СНачала) > 0 Тогда
			НоваяСтруктураURI[Ключ] = СтрЗаменить(Значение, ПутьНаСервере, НовыйПутьНаСервере);
		КонецЕсли;
		
		// 2. Меняем имя
		Если ИзменитьИмяФайла И СтрНайти(Значение, ИмяФайлаНаСервере, НаправлениеПоиска.СНачала) > 0 Тогда
			НоваяСтруктураURI[Ключ] = СтрЗаменить(Значение, ИмяФайлаНаСервере, НовоеИмяФайла);
		КонецЕсли;
	КонецЦикла;

	Возврат НоваяСтруктураURI;

КонецФункции

// Устанавливает уникальное имя файла в замен уже существующему в структуре параметров URI
// * При этом обновляются взимосвязанные значения
//
Процедура УстановитьУникальноеИмяФайлаПравил()
	
	Контекст = ПараметрыПриложения.ПолучитьКонтекст();

	ДатаВМиллисекундах = Строка(ТекущаяУниверсальнаяДатаВМиллисекундах());
	ГУИД = СтрЗаменить(Строка(Новый УникальныйИдентификатор()), "-", "");
	ИмяФайлаБезРасширения = ФайловыеОперации.ИмяБезРасширения(Контекст);
	УникальноеИмя = СтрШаблон("%1_%2_%3.json", ИмяФайлаБезРасширения, ГУИД, ДатаВМиллисекундах);
	
	НоваяСтруктураURI = СоздатьКопиюСтруктурыURI(СтруктураURI, "", УникальноеИмя);

	СтруктураURI = НоваяСтруктураURI;

КонецПроцедуры

// Проверяет наличие (заполненность) переменной "СтруктураURI"
// В ином случае - возвращает исключение
Процедура ПроверитьНаличиеСтруктурыURI()
	Если НЕ ЗначениеЗаполнено(СтруктураURI) Тогда
		ВызватьИсключение "Не выполнена инициализация параметров структуры URI!";
	КонецЕсли;
КонецПроцедуры

// Копирует структуру, указанную в параметре
//
// Параметры:
//   КопируемаяСтруктура - Структура - структура, которую нужно скопировать
//
// Возвращаемое значение:
//   Структура - скопированная структура
//
Функция СкопироватьСтруктуру(КопируемаяСтруктура)
	КопияСтруктуры = Новый Структура;
	Если Не ТипЗнч(КопируемаяСтруктура) = Тип("Структура") Тогда
		ВызватьИсключение "Невозможно скопировать структуру. Тип входящего параметра не соответветствует типу 'Структура'";
	КонецЕсли;
	Для Каждого ЭлементСтруктуры Из КопируемаяСтруктура Цикл
	  КопияСтруктуры.Вставить(ЭлементСтруктуры.Ключ, ЭлементСтруктуры.Значение);
	КонецЦикла;
	Возврат КопияСтруктуры;
КонецФункции

// Возвращает массив отличающихся структур между двумя массивами
// * Поиск отличий по указанному ключу
//
// Параметры:
//   РодительскийМассив - Массив - массив, в котором происходить поиск по дочернему массиву
//   ДочернийМассив - Массив - Массив, по которому будет выполняться поиск отличий
//   ПроверяемыйКлюч - Строка - ключ структуры, по которому может выполняться проверка отличий (по-умолчанию: не задан)
//
// Возвращаемое значение:
//   Массив - Массив отличающихся структур
//
Функция ПолучитьОтличияДвухМассивоСтруктурПоКлючу(РодительскийМассив, ДочернийМассив, ПроверяемыйКлюч)
		
	ОтличающиесяСтруктуры = Новый Массив;
	
	// На случай, когда в родительском массив нет элементов
	// (по сути массивы отличаются целиком)
	Если РодительскийМассив.Количество() = 0 Тогда
		Возврат ДочернийМассив;
	КонецЕсли;
	
	Для Каждого ЭлементДочернегоМассива Из ДочернийМассив Цикл
		НайденоСовпадение = Ложь;
		НайденныйКлючД = "";
		Если Не ЭлементДочернегоМассива.Свойство(ПроверяемыйКлюч, НайденныйКлючД) Тогда
			Продолжить;
		КонецЕсли;
		Для Каждого ЭлементРодительскогоМассива Из РодительскийМассив Цикл
			НайденныйКлючР = "";
			Если Не ЭлементРодительскогоМассива.Свойство(ПроверяемыйКлюч, НайденныйКлючР) Тогда
				Продолжить;
			КонецЕсли;
			Если НРег(СокрЛП(НайденныйКлючД)) = НРег(СокрЛП(НайденныйКлючР)) Тогда
				НайденоСовпадение = Истина;
			КонецЕсли;
		КонецЦикла;
		Если Не НайденоСовпадение Тогда
			ОтличающиесяСтруктуры.Добавить(ЭлементДочернегоМассива);
		КонецЕсли;
	КонецЦикла;

	Возврат ОтличающиесяСтруктуры;

КонецФункции

#КонецОбласти



#КонецОбласти


Лог = ПараметрыПриложения.Лог();
